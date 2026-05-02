$vault = "C:\ICS-LT-FYXFHG4\KT\clinical\Readiness"
$path = Join-Path $vault "03_Synthesis\2026-05-02_KTS-0000006_application-yml.md"

$content = Get-Content -Path $path -Raw

# Drop max-age line (handle both CRLF and LF)
$content = $content.Replace("        max-age: 8h`r`n", "")
$content = $content.Replace("        max-age: 8h`n", "")

# Convert scope from comma-string to YAML list
$old = "            scope: openid, profile, email"
$new = "            scope:`r`n              - openid`r`n              - profile`r`n              - email"
$content = $content.Replace($old, $new)

Set-Content -Path $path -Value $content -NoNewline

Set-Location $vault
git add -A
git commit -m "KTS-0000006: A-#1 Pilot resolutions (drop max-age, list scope)"
git push

Write-Host "Done."