$vault = "C:\ICS-LT-FYXFHG4\KT\clinical\Readiness"
$canon = Join-Path $vault "05_Wiki\stack-map-dotnet-to-java.md"
$triad = Join-Path $vault "05_Wiki\Triad\stack-map-dotnet-to-java.md"
$archiveDir = Join-Path $vault "99_Archive"
$archive = Join-Path $archiveDir "stack-map-dotnet-to-java.05_Wiki-root-orphan.md"

if (-not (Test-Path $archiveDir)) { New-Item -ItemType Directory -Path $archiveDir | Out-Null }

$canonContent = Get-Content -Path $canon -Raw
$triadContent = Get-Content -Path $triad -Raw

$combined = $canonContent + [Environment]::NewLine + [Environment]::NewLine + $triadContent
Set-Content -Path $triad -Value $combined -NoNewline

Move-Item -Path $canon -Destination $archive -Force

Write-Host "Consolidated to Triad. Root orphan moved to 99_Archive."