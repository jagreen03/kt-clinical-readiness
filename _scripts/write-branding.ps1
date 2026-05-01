<#
.SYNOPSIS
    Write the KT Clinical brand asset set to 05_Wiki/branding/.

.DESCRIPTION
    Self-contained, idempotent, ASCII only. Produces:
      - logo-mark.svg
      - logo-square.svg
      - logo-horizontal.svg
      - logo-horizontal-dark.svg
      - logo-mono-purple.svg
      - logo-mono-white.svg
      - open-graph.svg
      - favicon.svg
      - brand-tokens.css
      - brand-tokens.scss
      - brand-tokens.json
      - README.md

    DRY-RUN by default. Pass -Apply to mutate.

.PARAMETER VaultRoot
    Vault root path. Default: C:\ICS-LT-FYXFHG4\KT\clinical\Readiness

.PARAMETER Apply
    Switch. Default is dry-run.

.EXAMPLE
    .\write-branding.ps1
    .\write-branding.ps1 -Apply

.NOTES
    Saga: KTS-0000003 (branding)
    ASCII only. Compatible with Windows PowerShell 5.x and PowerShell 7+.
#>

[CmdletBinding()]
param(
    [string]$VaultRoot = "C:\ICS-LT-FYXFHG4\KT\clinical\Readiness",
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

function Step([string]$msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Note([string]$msg) { Write-Host "    $msg" }
function Run([string]$desc, [scriptblock]$action) {
    if ($Apply) {
        Write-Host "    [APPLY] $desc"
        & $action
    } else {
        Write-Host "    [DRYRUN] $desc"
    }
}
function Write-VaultFile([string]$relPath, [string]$content) {
    $full = Join-Path $VaultRoot $relPath
    $dir = Split-Path -Parent $full
    Run "Write $relPath" {
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Set-Content -Path $full -Value $content -Encoding UTF8 -NoNewline
    }
}

# ============================================================================
# Validate
# ============================================================================
Step "Validating VaultRoot"
if (-not (Test-Path $VaultRoot)) { throw "Vault root not found: $VaultRoot" }
Note "VaultRoot: $VaultRoot"
if ($Apply) { Note "Mode: APPLY (will mutate)" } else { Note "Mode: DRY-RUN (read only)" }

# ============================================================================
# Write brand assets
# ============================================================================
Step "Writing brand assets to 05_Wiki/branding/"

$logoMark = @'
<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>KT mark</title>
  <desc>Three layered rounded squares in blue, green, and purple.</desc>
  <rect x="156" y="156" width="280" height="280" rx="32" fill="#3B82F6"/>
  <rect x="136" y="136" width="280" height="280" rx="32" fill="#10B981"/>
  <rect x="116" y="116" width="280" height="280" rx="32" fill="#7C3AED"/>
</svg>
'@
Write-VaultFile "05_Wiki/branding/logo-mark.svg" $logoMark

$logoSquare = @'
<svg viewBox="0 0 680 680" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>KT logo</title>
  <desc>Stylized KT monogram with three layered rounded squares in blue, green, and purple.</desc>
  <rect x="210" y="210" width="360" height="360" rx="40" fill="#3B82F6"/>
  <rect x="185" y="185" width="360" height="360" rx="40" fill="#10B981"/>
  <rect x="160" y="160" width="360" height="360" rx="40" fill="#7C3AED"/>
  <text x="340" y="340" font-family="Arial, Helvetica, sans-serif" font-size="200" font-weight="800" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
</svg>
'@
Write-VaultFile "05_Wiki/branding/logo-square.svg" $logoSquare

$logoHorizontal = @'
<svg viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>KT Clinical horizontal logo</title>
  <desc>Horizontal lockup with mark and wordmark for nav bars on light backgrounds.</desc>
  <rect x="50" y="50" width="120" height="120" rx="14" fill="#3B82F6"/>
  <rect x="35" y="35" width="120" height="120" rx="14" fill="#10B981"/>
  <rect x="20" y="20" width="120" height="120" rx="14" fill="#7C3AED"/>
  <text x="80" y="80" font-family="Arial, Helvetica, sans-serif" font-size="68" font-weight="800" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
  <text x="220" y="120" font-family="Arial, Helvetica, sans-serif" font-size="56" font-weight="700" fill="#1F2937">KT Clinical</text>
</svg>
'@
Write-VaultFile "05_Wiki/branding/logo-horizontal.svg" $logoHorizontal

$logoHorizontalDark = @'
<svg viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>KT Clinical horizontal logo dark</title>
  <desc>Horizontal lockup with mark and white wordmark for nav bars on dark backgrounds.</desc>
  <rect x="50" y="50" width="120" height="120" rx="14" fill="#3B82F6"/>
  <rect x="35" y="35" width="120" height="120" rx="14" fill="#10B981"/>
  <rect x="20" y="20" width="120" height="120" rx="14" fill="#7C3AED"/>
  <text x="80" y="80" font-family="Arial, Helvetica, sans-serif" font-size="68" font-weight="800" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
  <text x="220" y="120" font-family="Arial, Helvetica, sans-serif" font-size="56" font-weight="700" fill="#FFFFFF">KT Clinical</text>
</svg>
'@
Write-VaultFile "05_Wiki/branding/logo-horizontal-dark.svg" $logoHorizontalDark

$logoMonoPurple = @'
<svg viewBox="0 0 680 680" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>KT logo purple monochrome</title>
  <desc>Single color purple version for one-color contexts.</desc>
  <rect x="160" y="160" width="360" height="360" rx="40" fill="#7C3AED"/>
  <text x="340" y="340" font-family="Arial, Helvetica, sans-serif" font-size="200" font-weight="800" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
</svg>
'@
Write-VaultFile "05_Wiki/branding/logo-mono-purple.svg" $logoMonoPurple

$logoMonoWhite = @'
<svg viewBox="0 0 680 680" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>KT logo white outline</title>
  <desc>White outline version for dark backgrounds.</desc>
  <rect x="160" y="160" width="360" height="360" rx="40" fill="none" stroke="#FFFFFF" stroke-width="8"/>
  <text x="340" y="340" font-family="Arial, Helvetica, sans-serif" font-size="200" font-weight="800" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
</svg>
'@
Write-VaultFile "05_Wiki/branding/logo-mono-white.svg" $logoMonoWhite

$openGraph = @'
<svg viewBox="0 0 1200 630" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>KT Clinical Readiness social card</title>
  <desc>Open Graph image with logo and tagline on dark background.</desc>
  <rect width="1200" height="630" fill="#0F172A"/>
  <rect x="160" y="240" width="240" height="240" rx="28" fill="#3B82F6"/>
  <rect x="135" y="215" width="240" height="240" rx="28" fill="#10B981"/>
  <rect x="110" y="190" width="240" height="240" rx="28" fill="#7C3AED"/>
  <text x="230" y="310" font-family="Arial, Helvetica, sans-serif" font-size="140" font-weight="800" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
  <text x="450" y="290" font-family="Arial, Helvetica, sans-serif" font-size="80" font-weight="700" fill="#FFFFFF">KT Clinical</text>
  <text x="450" y="370" font-family="Arial, Helvetica, sans-serif" font-size="36" font-weight="400" fill="#94A3B8">Stack translation and readiness vault</text>
</svg>
'@
Write-VaultFile "05_Wiki/branding/open-graph.svg" $openGraph

$favicon = @'
<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>KT favicon</title>
  <rect x="22" y="22" width="32" height="32" rx="6" fill="#3B82F6"/>
  <rect x="18" y="18" width="32" height="32" rx="6" fill="#10B981"/>
  <rect x="14" y="14" width="32" height="32" rx="6" fill="#7C3AED"/>
</svg>
'@
Write-VaultFile "05_Wiki/branding/favicon.svg" $favicon

$tokensCss = @'
:root {
  --kt-purple: #7C3AED;
  --kt-green: #10B981;
  --kt-blue: #3B82F6;
  --kt-text-dark: #1F2937;
  --kt-text-light: #FFFFFF;
  --kt-bg-dark: #0F172A;
  --kt-bg-light: #FFFFFF;
  --kt-text-muted: #94A3B8;

  --kt-radius-sm: 6px;
  --kt-radius-md: 14px;
  --kt-radius-lg: 28px;
  --kt-radius-xl: 40px;

  --kt-font-family: "Arial", "Helvetica", sans-serif;
}
'@
Write-VaultFile "05_Wiki/branding/brand-tokens.css" $tokensCss

$tokensScss = @'
$kt-purple: #7C3AED;
$kt-green: #10B981;
$kt-blue: #3B82F6;
$kt-text-dark: #1F2937;
$kt-text-light: #FFFFFF;
$kt-bg-dark: #0F172A;
$kt-bg-light: #FFFFFF;
$kt-text-muted: #94A3B8;

$kt-radius-sm: 6px;
$kt-radius-md: 14px;
$kt-radius-lg: 28px;
$kt-radius-xl: 40px;

$kt-font-family: "Arial", "Helvetica", sans-serif;
'@
Write-VaultFile "05_Wiki/branding/brand-tokens.scss" $tokensScss

$tokensJson = @'
{
  "color": {
    "purple": "#7C3AED",
    "green": "#10B981",
    "blue": "#3B82F6",
    "text-dark": "#1F2937",
    "text-light": "#FFFFFF",
    "bg-dark": "#0F172A",
    "bg-light": "#FFFFFF",
    "text-muted": "#94A3B8"
  },
  "radius": {
    "sm": "6px",
    "md": "14px",
    "lg": "28px",
    "xl": "40px"
  },
  "font": {
    "family": "Arial, Helvetica, sans-serif"
  }
}
'@
Write-VaultFile "05_Wiki/branding/brand-tokens.json" $tokensJson

$readme = @'
# KT Clinical Branding

Brand asset set for the KT Clinical Readiness vault and the projects under 04_Applications. Use these in:

- Spring Boot project READMEs and Thymeleaf templates
- JSP page headers
- Angular SPA toolbar and favicon
- GitHub repo social cards

## Files

| File | Use |
|---|---|
| logo-mark.svg | Just the layered mark, no text. App icons, large favicons, decorative. |
| logo-square.svg | Primary square logo with KT monogram. Default for repo READMEs. |
| logo-horizontal.svg | Mark plus KT Clinical wordmark. Nav bars on light backgrounds. |
| logo-horizontal-dark.svg | Same, white wordmark for dark backgrounds. |
| logo-mono-purple.svg | Single color purple. Print, one-color contexts. |
| logo-mono-white.svg | White outline. Dark backgrounds, dark mode. |
| open-graph.svg | 1200x630 social card for GitHub repo Open Graph. |
| favicon.svg | Simplified mark for browser tabs. |
| brand-tokens.css | CSS custom properties (colors, radii). |
| brand-tokens.scss | SCSS variables (same tokens). |
| brand-tokens.json | Design tokens as JSON for design tools. |

## Colors

- Purple: #7C3AED (front layer)
- Green: #10B981 (middle layer)
- Blue: #3B82F6 (back layer)

The three colors layer front to back: purple front, green middle, blue back. Order is deliberate.

## Usage in Angular

Copy this folder into src/assets/branding/ in the Angular project. Then in styles.scss:

@import "assets/branding/brand-tokens";

In a component:

.app-header {
  background: $kt-bg-dark;
  color: $kt-text-light;
}

In index.html for favicon:

<link rel="icon" type="image/svg+xml" href="assets/branding/favicon.svg"/>

In a toolbar template:

<img src="assets/branding/logo-horizontal-dark.svg" alt="KT Clinical" height="48"/>

## Usage in Spring Boot Thymeleaf

Place the SVG files in src/main/resources/static/branding/. Reference from a layout fragment:

<img th:src="@{/branding/logo-horizontal.svg}" alt="KT Clinical" height="48"/>

## Usage in JSP

Place the SVG files in WEB-INF/static/branding/ or src/main/webapp/branding/. Reference from a JSP:

<img src="<c:url value='/branding/logo-horizontal.svg'/>" alt="KT Clinical" height="48"/>

## Usage as GitHub repo social card

Upload open-graph.svg (or a PNG export) under repo Settings, Social preview. Recommended size 1200x630 already matches.

## Cross-renderer compatibility

ASCII only in all SVG content per CRSD mitigation (Cross-Renderer Syntax Drift). No em-dashes, no smart quotes, no special characters in titles or descriptions. Renders in browsers, GitHub markdown, VSCode, Obsidian, Inkscape, Figma.
'@
Write-VaultFile "05_Wiki/branding/README.md" $readme

# ============================================================================
# Final report
# ============================================================================
Step "Final state"
if ($Apply) {
    Write-Host ""
    Write-Host "Brand assets written to:" -ForegroundColor Green
    Write-Host "  $VaultRoot\05_Wiki\branding\"
    Write-Host ""
    Write-Host "Files:" -ForegroundColor Cyan
    Get-ChildItem -Path "$VaultRoot\05_Wiki\branding" | Sort-Object Name | ForEach-Object { Write-Host "  $($_.Name)" }
} else {
    Write-Host ""
    Write-Host "DRY RUN COMPLETE. Re-run with -Apply to mutate." -ForegroundColor Yellow
    Write-Host "Suggested: .\write-branding.ps1 -Apply"
}
