# Phase 1 overlay spike benchmark (Windows).
# Builds each strategy in release mode, runs it unattended, and collects the
# JSON each run writes. Leave the mouse alone while it runs (~4 min).
#
#   powershell -ExecutionPolicy Bypass -File tool\spike_bench.ps1 [-Seconds 30]
param([int]$Seconds = 30)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $root 'build\spike'
New-Item -ItemType Directory -Force $out | Out-Null

$configs = @(
  @{ Name = 'A60'; Defines = @('SPIKE=A', 'HZ=60') },
  @{ Name = 'A30'; Defines = @('SPIKE=A', 'HZ=30') },
  @{ Name = 'B';   Defines = @('SPIKE=B') },
  @{ Name = 'C';   Defines = @('SPIKE=C') }
)

Push-Location $root
try {
  foreach ($c in $configs) {
    $json = Join-Path $out "$($c.Name).json"
    $defs = @($c.Defines + "BENCH=$Seconds" + "OUT=$json") | ForEach-Object { "--dart-define=$_" }
    Write-Host "== Building $($c.Name)"
    flutter build windows --release @defs | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "build failed for $($c.Name)" }
    Write-Host "== Running $($c.Name) for ~$([int]($Seconds * 2 + 4)) s"
    $exe = Join-Path $root 'build\windows\x64\runner\Release\desk_buddy.exe'
    $p = Start-Process $exe -PassThru
    if (-not $p.WaitForExit(($Seconds * 2 + 30) * 1000)) { $p.Kill(); throw "$($c.Name) timed out" }
  }
} finally { Pop-Location }

Write-Host "`n== Results (CPU % of one core | fps | raster p90 ms | native calls/s)"
foreach ($c in $configs) {
  $r = Get-Content (Join-Path $out "$($c.Name).json") -Raw | ConvertFrom-Json
  foreach ($ph in $r.phases) {
    '{0,-4} {1,-14} cpu {2,6:N2}%  fps {3,5:N1}  raster p90 {4,5}  calls/s {5,5:N1}' -f `
      $c.Name, $ph.phase, $ph.cpuPctOfOneCore, $ph.fps, $ph.rasterMs.p90, $ph.nativeCallsPerSec
  }
}
