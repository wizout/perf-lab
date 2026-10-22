# читає потужності з hwinfo shared memory раз на секунду, стоп по stop.flag
param([string]$Out = "$PSScriptRoot\power.csv", [string]$Stop = "$PSScriptRoot\stop.flag")

Add-Type -AssemblyName System.Core
$enc = [Text.Encoding]::Default

$mmf = $null
for ($i = 0; $i -lt 20 -and -not $mmf; $i++) {
    try {
        $mmf = [IO.MemoryMappedFiles.MemoryMappedFile]::OpenExisting('Global\HWiNFO_SENS_SM2', [IO.MemoryMappedFiles.MemoryMappedFileRights]::Read)
    } catch {
        Start-Sleep -Milliseconds 500
    }
}
if (-not $mmf) {
    "ERROR: HWiNFO shared memory not found" | Set-Content "$PSScriptRoot\power_error.txt"
    exit 1
}
$acc = $mmf.CreateViewAccessor(0, 0, [IO.MemoryMappedFiles.MemoryMappedFileAccess]::Read)

function Str([long]$off, [int]$len) {
    $b = New-Object byte[] $len
    [void]$acc.ReadArray($off, $b, 0, $len)
    $n = [Array]::IndexOf($b, [byte]0)
    if ($n -lt 0) { $n = $len }
    $enc.GetString($b, 0, $n)
}

$w = New-Object IO.StreamWriter($Out, $false, [Text.Encoding]::UTF8)
$w.WriteLine('ts,label,value_w')
while (-not (Test-Path $Stop)) {
    $offR = $acc.ReadUInt32(32)
    $szR = $acc.ReadUInt32(36)
    $nR = $acc.ReadUInt32(40)
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss.fff')
    for ($k = 0; $k -lt $nR; $k++) {
        # офсети полів з структури HWiNFO_SENSORS_READING
        $base = [long]$offR + [long]$k * $szR
        $unit = Str ($base + 268) 16
        if ($unit -ne 'W') { continue }
        $label = (Str ($base + 12) 128) -replace ',', ';'
        $val = $acc.ReadDouble($base + 284)
        $w.WriteLine(('{0},{1},{2}' -f $ts, $label, $val.ToString([Globalization.CultureInfo]::InvariantCulture)))
    }
    $w.Flush()
    Start-Sleep -Milliseconds 1000
}
$w.Close()
