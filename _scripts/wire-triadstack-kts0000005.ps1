<#
.SYNOPSIS
    KTS-0000005 revision 3. Wire TriadStack into a modern Angular project.

.DESCRIPTION
    Self-contained, idempotent, ASCII only.

    REVISION HISTORY:
    - rev 1: scaffold mode wiped whole folder (destroyed ng new output). Bug.
    - rev 2: removed whole-folder wipe. Wrote to app.component.ts.
             Worked for Angular <19 but produced orphans in Angular 19+
             (where ng new generates app.ts, not app.component.ts).
    - rev 3: writes to modern Angular 19+ paths (app.ts, app.html, header.ts).
             Removes orphan .component.* files from prior revisions.

    Two modes.

    SCAFFOLD MODE (default): overlays TriadStack wiring on top of ng new
    output at VaultRoot\04_Applications\clinical-spa-angular\. Detects
    Angular naming convention and writes to the right paths. Cleans up
    orphan .component.* files left by previous script versions.

    COPY MODE (-CopyToProject "C:\path\to\angular\app"): copies branding
    into that project's src\assets\branding\ and drops wiring snippets in
    KT-WIRING\ for manual merge.

.PARAMETER VaultRoot
    Vault root path. Default: C:\ICS-LT-FYXFHG4\KT\clinical\Readiness

.PARAMETER CopyToProject
    Optional. Path to an existing Angular project. If set, runs in copy mode.

.PARAMETER Apply
    Switch. Default is dry-run.

.NOTES
    Saga: KTS-0000005 (revision 3)
    Workflow: clean folder -> ng new -> this script.
    Modern Angular: class App, class Header (no .component suffix).
#>

[CmdletBinding()]
param(
    [string]$VaultRoot = "C:\ICS-LT-FYXFHG4\KT\clinical\Readiness",
    [string]$CopyToProject = "",
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
function Write-File([string]$fullPath, [string]$content) {
    $dir = Split-Path -Parent $fullPath
    Run "Write $fullPath" {
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
    }
}
function Wipe-IfExists([string]$path, [string]$desc) {
    if (Test-Path $path) {
        Run "Wipe $desc at $path" {
            Remove-Item -Path $path -Recurse -Force
        }
    }
}
function Remove-FileIfExists([string]$path, [string]$desc) {
    if (Test-Path $path) {
        Run "Remove orphan $desc" {
            Remove-Item -Path $path -Force
        }
    }
}
function Copy-One([string]$src, [string]$dest, [string]$label) {
    if (-not (Test-Path $src)) { throw "Source not found: $src" }
    $destDir = Split-Path -Parent $dest
    Run "Copy $label" {
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Copy-Item -Path $src -Destination $dest -Force
    }
}
function Copy-TriadStackAssets([string]$brandingDir) {
    $brandingSource = Join-Path $VaultRoot "05_Wiki\branding"
    $triadSource = Join-Path $brandingSource "triadstack"

    if (-not (Test-Path $brandingSource)) { throw "Branding source not found: $brandingSource" }
    if (-not (Test-Path $triadSource)) { throw "TriadStack source not found: $triadSource (run split-branding-kts0000004.ps1 first)" }

    Wipe-IfExists $brandingDir "existing branding folder"

    Copy-One (Join-Path $brandingSource "brand-tokens.css")  (Join-Path $brandingDir "brand-tokens.css")  "brand-tokens.css"
    Copy-One (Join-Path $brandingSource "brand-tokens.scss") (Join-Path $brandingDir "brand-tokens.scss") "brand-tokens.scss"
    Copy-One (Join-Path $brandingSource "brand-tokens.json") (Join-Path $brandingDir "brand-tokens.json") "brand-tokens.json"
    Copy-One (Join-Path $brandingSource "PGB.md")            (Join-Path $brandingDir "PGB.md")            "PGB.md doctrine"

    Copy-One (Join-Path $triadSource "README.md")                 (Join-Path $brandingDir "README.md")                 "TriadStack README"
    Copy-One (Join-Path $triadSource "favicon.svg")               (Join-Path $brandingDir "favicon.svg")               "favicon"
    Copy-One (Join-Path $triadSource "logo-mark.svg")             (Join-Path $brandingDir "logo-mark.svg")             "logo-mark"
    Copy-One (Join-Path $triadSource "logo-horizontal.svg")       (Join-Path $brandingDir "logo-horizontal.svg")       "logo-horizontal"
    Copy-One (Join-Path $triadSource "logo-horizontal-dark.svg")  (Join-Path $brandingDir "logo-horizontal-dark.svg")  "logo-horizontal-dark"
    Copy-One (Join-Path $triadSource "open-graph.svg")            (Join-Path $brandingDir "open-graph.svg")            "open-graph"
}

# ============================================================================
# Validate and pick mode
# ============================================================================
Step "Validating"
if (-not (Test-Path $VaultRoot)) { throw "Vault root not found: $VaultRoot" }

if ($CopyToProject -ne "") {
    if (-not (Test-Path $CopyToProject)) { throw "CopyToProject path not found: $CopyToProject" }
    $mode = "copy"
    $angularRoot = $CopyToProject
    Note "Mode: COPY (apply TriadStack branding to existing project at $CopyToProject)"
} else {
    $mode = "scaffold"
    $angularRoot = Join-Path $VaultRoot "04_Applications\clinical-spa-angular"
    Note "Mode: SCAFFOLD (overlay TriadStack wiring at $angularRoot)"
}
if ($Apply) { Note "Action: APPLY (will mutate)" } else { Note "Action: DRY-RUN (read only)" }

# ============================================================================
# Wiring content (modern Angular 19+ naming)
# ============================================================================

$stylesScss = @'
// TriadStack brand integration
@import "assets/branding/brand-tokens";

// Global app baseline using brand tokens
html, body {
  height: 100%;
  margin: 0;
  font-family: $kt-font-family;
  background: $kt-bg-light;
  color: $kt-text-on-light;
}

// Main content area
.kt-main {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

// Reusable primary button (front layer of PGB doctrine)
.kt-button-primary {
  background: $kt-purple;
  color: $kt-text-on-light;
  border: none;
  border-radius: $kt-radius-md;
  padding: 0.75rem 1.5rem;
  font-family: $kt-font-family;
  font-weight: $kt-font-weight-bold;
  cursor: pointer;
  transition: background 150ms ease;
}

.kt-button-primary:hover {
  background: $kt-blue;
  color: #FFFFFF;
}

.kt-button-primary:focus-visible {
  outline: 2px solid $kt-text-green-on-light;
  outline-offset: 2px;
}
'@

$indexHtml = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>TriadStack</title>
  <base href="/">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- TriadStack branding -->
  <link rel="icon" type="image/svg+xml" href="assets/branding/favicon.svg">
  <meta property="og:title" content="TriadStack">
  <meta property="og:description" content="Full-stack architectural identity">
  <meta property="og:image" content="assets/branding/open-graph.svg">
  <meta name="theme-color" content="#7C3AED">
</head>
<body>
  <app-root></app-root>
</body>
</html>
'@

$indexHeadSnippet = @'
<!-- TriadStack branding (paste inside <head> of your existing index.html) -->
<link rel="icon" type="image/svg+xml" href="assets/branding/favicon.svg">
<meta property="og:title" content="TriadStack">
<meta property="og:description" content="Full-stack architectural identity">
<meta property="og:image" content="assets/branding/open-graph.svg">
<meta name="theme-color" content="#7C3AED">
'@

# Modern Angular 19+: class App (no .component suffix)
$appTs = @'
import { Component } from "@angular/core";
import { RouterOutlet } from "@angular/router";
import { Header } from "./shared/header/header";

@Component({
  selector: "app-root",
  imports: [RouterOutlet, Header],
  templateUrl: "./app.html",
  styleUrl: "./app.scss"
})
export class App {
  protected title = "triadstack-spa";
}
'@

$appHtml = @'
<app-header></app-header>
<main class="kt-main">
  <router-outlet></router-outlet>
</main>
'@

# Modern Angular 19+: class Header (no .component suffix)
$headerTs = @'
import { Component } from "@angular/core";
import { RouterLink, RouterLinkActive } from "@angular/router";

@Component({
  selector: "app-header",
  imports: [RouterLink, RouterLinkActive],
  templateUrl: "./header.html",
  styleUrl: "./header.scss"
})
export class Header {
  title = "TriadStack";
}
'@

$headerHtml = @'
<header class="kt-header">
  <a class="kt-header-logo" routerLink="/">
    <img src="assets/branding/logo-horizontal-dark.svg" alt="TriadStack" />
  </a>
  <nav class="kt-header-nav">
    <a routerLink="/dashboard" routerLinkActive="active">Dashboard</a>
    <a routerLink="/encounters" routerLinkActive="active">Encounters</a>
    <a routerLink="/profile" routerLinkActive="active">Profile</a>
  </nav>
</header>
'@

$headerScss = @'
@import "../../../assets/branding/brand-tokens";

.kt-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 2rem;
  background: $kt-bg-dark;
  color: $kt-text-on-dark;
}

.kt-header-logo img {
  height: 48px;
  display: block;
}

.kt-header-nav {
  display: flex;
  gap: 1.5rem;
}

.kt-header-nav a {
  color: $kt-text-on-dark;
  text-decoration: none;
  font-family: $kt-font-family;
  font-weight: $kt-font-weight-medium;
  padding: 0.25rem 0;
  border-bottom: 2px solid transparent;
  transition: border-color 150ms ease, color 150ms ease;
}

.kt-header-nav a:hover {
  color: $kt-text-green-on-dark;
  border-bottom-color: $kt-text-green-on-dark;
}

.kt-header-nav a.active {
  border-bottom-color: $kt-text-purple-on-dark;
}
'@

$scaffoldReadme = @'
# TriadStack SPA - Angular project

This Angular project uses the TriadStack architectural identity for branding.

## Build sequence

1. Wipe the folder if it has stale state.
2. Run ng new in the empty folder:
     ng new triadstack-spa --routing=true --style=scss --standalone=true --skip-git=true --directory=.
   Prompts: SSR No, zoneless Yes, AI tools None.
3. Run wire-triadstack-kts0000005.ps1 -Apply to overlay TriadStack wiring.

To re-apply branding after pulling new branding source from the vault, just re-run the script. It overwrites wiring files in place and refreshes src/assets/branding/. ng new artifacts (package.json, angular.json, node_modules, etc.) are preserved.

## Run

  npm start

Open http://localhost:4200. The TriadStack header (mark plus wordmark on dark background) shows three nav links. Routed empty content area below.

## What the script wired

- src/styles.scss: brand-tokens import, baseline body, .kt-button-primary utility, accessibility-aware focus states.
- src/index.html: TriadStack title, favicon, Open Graph meta, theme color.
- src/app/app.ts and app.html: standalone root component with header + router outlet.
- src/app/shared/header/header.{ts,html,scss}: TriadStack toolbar, dark background, brand colors paired with hover states.
- src/assets/branding/: brand-tokens (CSS, SCSS, JSON), PGB.md doctrine, TriadStack logos and favicon.

## Brand colors (PGB doctrine)

- Purple #7C3AED (front layer, primary actions, unexpected/usable content)
- Green #10B981 (middle layer, hover and success, delivered as specified)
- Blue #3B82F6 (back layer, secondary, exceptional quality)

Full doctrine in src/assets/branding/PGB.md.

## Three viewing modes

brand-tokens.css ships with light, dark, and high-contrast modes:

1. Manual: html element data-theme attribute.
2. Auto: prefers-contrast: more then prefers-color-scheme: dark.
3. Default: light.
'@

$copyReadme = @'
# TriadStack branding - merge guide

Branding asset set was just copied to your project's src/assets/branding/. The files in this KT-WIRING/ folder are SNIPPETS to be merged into your existing Angular files.

NOTE: snippets target modern Angular 19+ naming (app.ts, header.ts, no .component suffix). If your project uses the older app.component.ts convention, you will need to translate.

## What got copied

src/assets/branding/ contents:
- brand-tokens.css, brand-tokens.scss, brand-tokens.json
- PGB.md (doctrine)
- README.md (TriadStack guide)
- favicon.svg, logo-mark.svg, logo-horizontal.svg, logo-horizontal-dark.svg, open-graph.svg

## What you merge manually

### styles.scss
Add brand-tokens import, baseline body, .kt-main wrapper, .kt-button-primary utility from KT-WIRING/styles.scss into your existing src/styles.scss.

### index.html
Paste the head additions from KT-WIRING/index-head-snippet.html inside your existing src/index.html <head>.

### Header component
Three new files at app/shared/header/. Drop them into src/app/shared/header/ in your project.

In src/app/app.ts (or app.component.ts) add:
  import { Header } from "./shared/header/header";

And add Header to the imports array.

In src/app/app.html (or app.component.html) add near the top:
  <app-header></app-header>
'@

# ============================================================================
# Execute based on mode
# ============================================================================

if ($mode -eq "scaffold") {
    Step "Scaffold mode: overlaying TriadStack wiring on existing folder"
    Note "Targeting modern Angular 19+ paths (app.ts, header.ts)"
    Note "ng new artifacts (package.json, angular.json, etc.) preserved"

    # Detect Angular naming convention
    $modernAppTs = Join-Path $angularRoot "src\app\app.ts"
    $classicAppTs = Join-Path $angularRoot "src\app\app.component.ts"

    if (Test-Path $modernAppTs) {
        Note "Detected: modern naming (app.ts present)"
    } elseif (Test-Path $classicAppTs) {
        Write-Host "    [WARN] Classic naming detected (app.component.ts). This script targets modern naming." -ForegroundColor Yellow
        Write-Host "    [WARN] You may need to manually rename or run an older Angular project." -ForegroundColor Yellow
    } else {
        Write-Host "    [WARN] Neither app.ts nor app.component.ts found. Did ng new run?" -ForegroundColor Yellow
    }

    # Write wiring files at modern paths
    Write-File (Join-Path $angularRoot "src\styles.scss") $stylesScss
    Write-File (Join-Path $angularRoot "src\index.html") $indexHtml
    Write-File (Join-Path $angularRoot "src\app\app.ts") $appTs
    Write-File (Join-Path $angularRoot "src\app\app.html") $appHtml
    Write-File (Join-Path $angularRoot "src\app\shared\header\header.ts") $headerTs
    Write-File (Join-Path $angularRoot "src\app\shared\header\header.html") $headerHtml
    Write-File (Join-Path $angularRoot "src\app\shared\header\header.scss") $headerScss
    Write-File (Join-Path $angularRoot "README.md") $scaffoldReadme

    # Clean up orphans from prior script revisions (.component.* files)
    Step "Removing orphan .component.* files from prior script runs"
    Remove-FileIfExists (Join-Path $angularRoot "src\app\app.component.ts") "src\app\app.component.ts"
    Remove-FileIfExists (Join-Path $angularRoot "src\app\app.component.html") "src\app\app.component.html"
    Remove-FileIfExists (Join-Path $angularRoot "src\app\shared\header\header.component.ts") "src\app\shared\header\header.component.ts"
    Remove-FileIfExists (Join-Path $angularRoot "src\app\shared\header\header.component.html") "src\app\shared\header\header.component.html"
    Remove-FileIfExists (Join-Path $angularRoot "src\app\shared\header\header.component.scss") "src\app\shared\header\header.component.scss"

    Copy-TriadStackAssets (Join-Path $angularRoot "src\assets\branding")

} else {
    Step "Copy mode: applying TriadStack to existing project"

    Copy-TriadStackAssets (Join-Path $angularRoot "src\assets\branding")

    $wiring = Join-Path $angularRoot "KT-WIRING"
    Wipe-IfExists $wiring "existing KT-WIRING folder"

    Write-File (Join-Path $wiring "styles.scss") $stylesScss
    Write-File (Join-Path $wiring "index-head-snippet.html") $indexHeadSnippet
    Write-File (Join-Path $wiring "app\app.ts") $appTs
    Write-File (Join-Path $wiring "app\app.html") $appHtml
    Write-File (Join-Path $wiring "app\shared\header\header.ts") $headerTs
    Write-File (Join-Path $wiring "app\shared\header\header.html") $headerHtml
    Write-File (Join-Path $wiring "app\shared\header\header.scss") $headerScss
    Write-File (Join-Path $wiring "README.md") $copyReadme
}

# ============================================================================
# Final report
# ============================================================================
Step "Final state"
if ($Apply) {
    Write-Host ""
    if ($mode -eq "scaffold") {
        Write-Host "TriadStack wiring overlaid on:" -ForegroundColor Green
        Write-Host "  $angularRoot"
        Write-Host ""
        Write-Host "Verifying ng new artifacts (must be present for npm start to work):" -ForegroundColor Cyan
        $required = @("package.json", "angular.json", "src\main.ts", "src\app\app.config.ts", "src\app\app.routes.ts")
        foreach ($f in $required) {
            $p = Join-Path $angularRoot $f
            if (Test-Path $p) {
                Write-Host "  PRESENT $f" -ForegroundColor Green
            } else {
                Write-Host "  MISSING $f" -ForegroundColor Red
            }
        }
        Write-Host ""
        Write-Host "Verifying TriadStack wiring at modern paths:" -ForegroundColor Cyan
        $wired = @("src\app\app.ts", "src\app\app.html", "src\app\shared\header\header.ts", "src\app\shared\header\header.html", "src\app\shared\header\header.scss", "src\assets\branding\brand-tokens.scss")
        foreach ($f in $wired) {
            $p = Join-Path $angularRoot $f
            if (Test-Path $p) {
                Write-Host "  PRESENT $f" -ForegroundColor Green
            } else {
                Write-Host "  MISSING $f" -ForegroundColor Red
            }
        }
        Write-Host ""
        Write-Host "Next:" -ForegroundColor Cyan
        Write-Host "  cd $angularRoot"
        Write-Host "  npm start"
        Write-Host "  Open http://localhost:4200 -- TriadStack header should render."
    } else {
        Write-Host "TriadStack branding applied to:" -ForegroundColor Green
        Write-Host "  $angularRoot\src\assets\branding\"
        Write-Host ""
        Write-Host "Wiring snippets at:" -ForegroundColor Green
        Write-Host "  $angularRoot\KT-WIRING\"
    }
} else {
    Write-Host ""
    Write-Host "DRY RUN COMPLETE. Re-run with -Apply to mutate." -ForegroundColor Yellow
    if ($mode -eq "scaffold") {
        Write-Host "Suggested: .\wire-triadstack-kts0000005.ps1 -Apply"
    } else {
        Write-Host "Suggested: .\wire-triadstack-kts0000005.ps1 -CopyToProject `"$angularRoot`" -Apply"
    }
}
