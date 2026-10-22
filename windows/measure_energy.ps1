# Замір енерговитрат (п. 3 і 4.4) на Windows.
#
# Джерело: лічильники Windows "Energy Meter" (EMI) — це ті самі апаратні RAPL-регістри Intel/AMD
# (RAPL_Package0_PKG = весь CPU-пакет, _PP0 = ядра, _DRAM = пам'ять), які на Linux читає
# `perf stat -e power/energy-pkg/`. Права адміністратора не потрібні.
#
# Методика:
#   1) IDLE: N секунд простою -> базова потужність P_idle;
#   2) для кожної збірки: програма запускається повторно, доки не мине N секунд,
#      паралельно раз на секунду знімається потужність пакета і завантаження CPU;
#   3) енергія СИСТЕМИ (3.1)       = інтеграл P(t) за вікно (+ дельта лічильника Energy як перевірка);
#   4) енергія ПРОГРАМИ (3.2), два способи:
#        A. маржинальна:  (E_window - P_idle * T) / кількість_запусків
#        B. за часткою CPU: E_window * (CPU-час програми / CPU-час усієї системи) / кількість_запусків
#
# Запуск: подвійний клік на run_energy.bat (або: powershell -ExecutionPolicy Bypass -File measure_energy.ps1)

param(
    [int]$WindowSec = 30,   # тривалість вікна заміру на кожну збірку
    [int]$IdleSec   = 30    # тривалість заміру простою
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $here
$out = New-Object System.Collections.Generic.List[string]
function Log([string]$s) { Write-Host $s; $out.Add($s) }

# ---------- інформація про систему ----------
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$os  = Get-CimInstance Win32_OperatingSystem
$nLogical = [int]$cpu.NumberOfLogicalProcessors

Add-Type -Namespace W -Name K -MemberDefinition '[DllImport("kernel32.dll")] public static extern bool IsProcessorFeaturePresent(uint f);'
$hasAvx2 = [W.K]::IsProcessorFeaturePresent(40)   # PF_AVX2_INSTRUCTIONS_AVAILABLE

$power = (Get-CimInstance Win32_ComputerSystem)
$battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue

Log "=== SYSTEM ==="
Log ("CPU: {0} | cores={1} logical={2} | AVX2={3}" -f $cpu.Name.Trim(), $cpu.NumberOfCores, $nLogical, $hasAvx2)
Log ("OS: {0} {1} | RAM={2:N1} GB" -f $os.Caption, $os.Version, ($power.TotalPhysicalMemory/1GB))
if ($battery) { Log ("Battery: present, status={0}, charge={1}%" -f $battery.BatteryStatus, $battery.EstimatedChargeRemaining) } else { Log "Battery: none (desktop)" }

# ---------- пошук лічильників енергії ----------
# Спершу через WMI (не залежить від мови Windows), потім через Get-Counter (англ. назви).
$energyMode = $null
$emClass = $null
foreach ($cls in 'Win32_PerfRawData_Counters_EnergyMeter','Win32_PerfFormattedData_Counters_EnergyMeter') {
    try {
        $probe = Get-CimInstance $cls -ErrorAction Stop
        if ($probe) { $emClass = $cls; break }
    } catch {}
}
if ($emClass) {
    $energyMode = 'wmi'
    Log "Energy source: WMI $emClass"
    foreach ($i in (Get-CimInstance $emClass)) { Log ("  instance {0}: Power={1} Energy={2}" -f $i.Name, $i.Power, $i.Energy) }
} else {
    try {
        $set = Get-Counter -ListSet 'Energy Meter' -ErrorAction Stop
        $energyMode = 'counter'
        Log "Energy source: Get-Counter 'Energy Meter'"
        Log ("  paths: " + ($set.PathsWithInstances -join ', '))
    } catch {
        Log "!! Energy Meter counters NOT found on this PC."
        $cands = Get-CimClass -Namespace root/cimv2 | Where-Object { $_.CimClassName -match 'Energy|Power' -and $_.CimClassName -match 'Perf' } | Select-Object -ExpandProperty CimClassName
        Log ("  candidate classes: " + ($cands -join ', '))
    }
}

function Read-Energy {
    # Повертає hashtable: instance -> @{Power(mW); Energy(raw)}
    $r = @{}
    if ($energyMode -eq 'wmi') {
        foreach ($i in (Get-CimInstance $emClass)) { $r[$i.Name] = @{ Power = [double]$i.Power; Energy = [double]$i.Energy } }
    } elseif ($energyMode -eq 'counter') {
        $s = (Get-Counter -Counter '\Energy Meter(*)\Power','\Energy Meter(*)\Energy' -ErrorAction SilentlyContinue).CounterSamples
        foreach ($x in $s) {
            $inst = $x.InstanceName
            if (-not $r.ContainsKey($inst)) { $r[$inst] = @{ Power = 0.0; Energy = 0.0 } }
            if ($x.Path -match '\\power$') { $r[$inst].Power = [double]$x.CookedValue } else { $r[$inst].Energy = [double]$x.RawValue }
        }
    }
    return $r
}

function Read-CpuBusy {
    # % завантаження CPU (усі ядра), незалежно від мови ОС
    (Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'").PercentProcessorTime
}

function Pick-Pkg($h) {
    # обираємо інстанс "пакет CPU"
    $k = $h.Keys | Where-Object { $_ -match 'PKG' } | Select-Object -First 1
    if (-not $k) { $k = $h.Keys | Where-Object { $_ -notmatch 'DRAM|PP1|GPU' } | Select-Object -First 1 }
    return $k
}

# ---------- одне вікно заміру ----------
function Measure-Window([string]$exe, [int]$sec) {
    $samples = New-Object System.Collections.Generic.List[object]
    $e0 = Read-Energy
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $runs = 0; $cpuProg = 0.0; $progTimes = @()
    $p = $null
    $lastSample = -1.0
    while ($true) {
        if ($exe -and (-not $p -or $p.HasExited)) {
            if ($p) {
                $cpuProg += $p.TotalProcessorTime.TotalSeconds
                $progTimes += $p.ExitTime.Subtract($p.StartTime).TotalSeconds
                $runs++
                $p.Dispose(); $p = $null
            }
            if ($sw.Elapsed.TotalSeconds -ge $sec) { break }
            $p = Start-Process -FilePath $exe -NoNewWindow -PassThru -RedirectStandardOutput "$env:TEMP\perf_lab_out.txt"
            $null = $p.Handle   # щоб коректно прочитати TotalProcessorTime після виходу
        }
        if (-not $exe -and $sw.Elapsed.TotalSeconds -ge $sec) { break }
        $t = $sw.Elapsed.TotalSeconds
        if ($t - $lastSample -ge 1.0) {
            $lastSample = $t
            $en = Read-Energy
            $k = Pick-Pkg $en
            $pw = if ($k) { $en[$k].Power } else { [double]::NaN }
            $samples.Add([pscustomobject]@{ t = $t; P_mW = $pw; busy = (Read-CpuBusy) })
        } else {
            Start-Sleep -Milliseconds 100
        }
    }
    $T = $sw.Elapsed.TotalSeconds
    $e1 = Read-Energy
    $k = Pick-Pkg $e1
    $res = [ordered]@{
        T = $T; runs = $runs; cpuProg = $cpuProg; progTimes = $progTimes
        P_avg_W = [double]::NaN; E_int_J = [double]::NaN; dEnergyRaw = [double]::NaN
        busy_avg = ($samples | Measure-Object busy -Average).Average
        perInstance = @{}
    }
    if ($k) {
        $pAvg = ($samples | Where-Object { -not [double]::IsNaN($_.P_mW) } | Measure-Object P_mW -Average).Average / 1000.0
        $res.P_avg_W = $pAvg
        $res.E_int_J = $pAvg * $T
        $res.dEnergyRaw = $e1[$k].Energy - $e0[$k].Energy
        foreach ($inst in $e1.Keys) { $res.perInstance[$inst] = $e1[$inst].Energy - $e0[$inst].Energy }
    }
    return $res
}

# ---------- прогін ----------
$variants = @('prog_O0.exe','prog_O3.exe')
if ($hasAvx2) { $variants += 'prog_avx2.exe' } else { Log "AVX2 not supported -> prog_avx2.exe skipped" }

Log ""
Log "Warm-up run..."
& ".\prog_O3.exe" | Out-Null

Log ("=== IDLE {0}s (не чіпай комп'ютер) ===" -f $IdleSec)
Start-Sleep -Seconds 3
$idle = Measure-Window $null $IdleSec
Log ("IDLE: T={0:N1}s  P_pkg_avg={1:N2} W  E={2:N1} J  dEnergyRaw={3}  CPU busy={4:N1}%" -f $idle.T, $idle.P_avg_W, $idle.E_int_J, $idle.dEnergyRaw, $idle.busy_avg)

$rows = @()
foreach ($v in $variants) {
    Log ""
    Log ("=== {0}: вікно {1}s ===" -f $v, $WindowSec)
    Start-Sleep -Seconds 3
    $m = Measure-Window (Join-Path $here $v) $WindowSec
    $tAvg = ($m.progTimes | Measure-Object -Average).Average
    $eMarg = ($m.E_int_J - $idle.P_avg_W * $m.T) / [math]::Max($m.runs,1)
    $sysCpu = ($m.busy_avg / 100.0) * $m.T * $nLogical
    $share = if ($sysCpu -gt 0) { [math]::Min($m.cpuProg / $sysCpu, 1.0) } else { [double]::NaN }
    $eShare = $m.E_int_J * $share / [math]::Max($m.runs,1)
    Log ("runs={0}  T_window={1:N1}s  t_run_avg={2:N3}s  CPU_prog={3:N1}s  CPU busy={4:N1}%" -f $m.runs, $m.T, $tAvg, $m.cpuProg, $m.busy_avg)
    Log ("SYSTEM (pkg): P_avg={0:N2} W  E_window={1:N1} J  dEnergyRaw={2}" -f $m.P_avg_W, $m.E_int_J, $m.dEnergyRaw)
    Log ("  per-instance dEnergyRaw: " + (($m.perInstance.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '; '))
    Log ("PROGRAM per run: A) marginal={0:N2} J   B) cpu-share={1:N2} J (share={2:P1})" -f $eMarg, $eShare, $share)
    $rows += [pscustomobject]@{ variant=$v; runs=$m.runs; t_run=$tAvg; P_W=$m.P_avg_W; dP_W=($m.P_avg_W-$idle.P_avg_W); E_marg_J=$eMarg; E_share_J=$eShare }
}

Log ""
Log "=== SUMMARY ==="
Log ("{0,-14} {1,9} {2,9} {3,9} {4,12} {5,12}" -f 'variant','t_run,s','P,W','dP,W','E_marg,J','E_share,J')
foreach ($r in $rows) { Log ("{0,-14} {1,9:N3} {2,9:N2} {3,9:N2} {4,12:N2} {5,12:N2}" -f $r.variant, $r.t_run, $r.P_W, $r.dP_W, $r.E_marg_J, $r.E_share_J) }
Log ("idle P = {0:N2} W" -f $idle.P_avg_W)

$txt = $out -join "`r`n"
$txt | Set-Content -Encoding UTF8 (Join-Path $here 'energy_results.txt')
try { Set-Clipboard -Value $txt; $clip = $true } catch { $clip = $false }
Write-Host ""
Write-Host "Saved: energy_results.txt" -ForegroundColor Green
if ($clip) { Write-Host "Result copied to clipboard - paste it into the Claude chat (Ctrl+V)." -ForegroundColor Green }
