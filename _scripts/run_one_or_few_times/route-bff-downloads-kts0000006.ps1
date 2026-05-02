$src = "$env:USERPROFILE\Downloads"
$vault = "C:\ICS-LT-FYXFHG4\KT\clinical\Readiness"

$tooling = Join-Path $vault "05_Wiki\tooling"
$synth = Join-Path $vault "03_Synthesis"
$triad = Join-Path $vault "05_Wiki\Triad"

if (-not (Test-Path $tooling)) { New-Item -ItemType Directory -Path $tooling | Out-Null }

Copy-Item (Join-Path $src "gemini-code-1777733022994.md") (Join-Path $tooling "ide-tooling-java.md") -Force
Copy-Item (Join-Path $src "gemini-code-1777733024928.md") (Join-Path $synth "2026-05-02_KTS-0000006_naming.md") -Force
Copy-Item (Join-Path $src "gemini-code-1777733026952.md") (Join-Path $synth "2026-05-02_KTS-0000006_project-skeleton.md") -Force
Copy-Item (Join-Path $src "gemini-code-1777733029671.md") (Join-Path $synth "2026-05-02_KTS-0000006_security-config.md") -Force
Copy-Item (Join-Path $src "2026-05-02_KTS-0000006_bff-endpoints.md") (Join-Path $synth "2026-05-02_KTS-0000006_bff-endpoints.md") -Force

$stackTarget = Join-Path $triad "stack-map-dotnet-to-java.md"
$stackSource = Join-Path $src "gemini-code-1777733087392.md"
$incoming = Get-Content -Path $stackSource -Raw
Add-Content -Path $stackTarget -Value ([Environment]::NewLine + $incoming)

Write-Host "Done."