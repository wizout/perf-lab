# Прогін фаз для заміру енергії через HWiNFO (п. 3 і 4.4).
# HWiNFO паралельно пише лог датчиків (CPU Package Power) у CSV,
# а цей скрипт фіксує точні часові межі кожної фази + дані про процес.
# Потім лог HWiNFO ріжеться по цих межах (scripts/energy_from_hwinfo.py).
#
# Фази: IDLE (простій) -> prog_O0 -> prog_O3 -> prog_avx2, кожна по WindowSec секунд.

param([int]$WindowSec = 30, [int]$IdleSec = 30)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $here
$outFile = Join-Path $here 'phases.csv'
$nLogical = [int](Get-CimInstance Win32_Processor | Measure-Object NumberOfLogicalProcessors -Sum).Sum
$cpuName = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name.Trim()

function Ts { (Get-Date).ToString('yyyy-MM-dd HH:mm:ss.fff') }

function Get-SysCpuSec {
    # сумарний CPU-час усіх процесів (с) — для частки CPU нашої програми
    $s = 0.0
    foreach ($p in Get-Process) { try { $s += $p.TotalProcessorTime.TotalSeconds } catch {} }
    return $s
}

$rows = New-Object System.Collections.Generic.List[object]

function Run-Phase([string]$name, [string]$exe, [int]$sec) {
    Write-Host ("[{0}] {1}: {2}s ..." -f (Ts), $name, $sec)
    $sys0 = Get-SysCpuSec
    $start = Ts
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $runs = 0; $cpuProg = 0.0; $wall = 0.0
    if (-not $exe) {
        Start-Sleep -Seconds $sec
    } else {
        while ($sw.Elapsed.TotalSeconds -lt $sec) {
            $p = Start-Process -FilePath $exe -NoNewWindow -PassThru -RedirectStandardOutput "$env:TEMP\perf_lab_out.txt"
            $null = $p.Handle
            $p.WaitForExit()
            $cpuProg += $p.TotalProcessorTime.TotalSeconds
            $wall    += ($p.ExitTime - $p.StartTime).TotalSeconds
            $runs++
            $p.Dispose()
        }
    }
    $T = $sw.Elapsed.TotalSeconds
    $end = Ts
    $sys1 = Get-SysCpuSec
    $rows.Add([pscustomobject]@{
        phase = $name; start = $start; end = $end; T_s = [math]::Round($T,3)
        runs = $runs; prog_cpu_s = [math]::Round($cpuProg,3); prog_wall_s = [math]::Round($wall,3)
        sys_cpu_s = [math]::Round($sys1 - $sys0,3); n_logical = $nLogical
    })
    Write-Host ("    runs={0} prog_cpu={1:N2}s" -f $runs, $cpuProg)
}

Write-Host "CPU: $cpuName ($nLogical logical)"
Write-Host "Warm-up..."
& ".\prog_O3.exe" | Out-Null
Start-Sleep -Seconds 5

Run-Phase 'IDLE' $null $IdleSec
Start-Sleep -Seconds 5
foreach ($v in 'prog_O0','prog_O3','prog_avx2') {
    Run-Phase $v (Join-Path $here "$v.exe") $WindowSec
    Start-Sleep -Seconds 5      # пауза між фазами, щоб потужність встигла впасти
}

$rows | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8
Write-Host ""
Write-Host "Saved: $outFile" -ForegroundColor Green
Write-Host "Phases done." -ForegroundColor Green
