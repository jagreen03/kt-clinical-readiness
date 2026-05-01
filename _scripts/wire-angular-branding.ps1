<#
.SYNOPSIS
    Wire KT Clinical branding into an Angular project.

.DESCRIPTION
    Two modes.

    SCAFFOLD MODE (default): writes a wiring kit at
        $VaultRoot\04_Applications\clinical-spa-angular\
    Branding files copied in. README explains the ng new bootstrap
    and merge step. Not a runnable project on its own.

    COPY MODE: pass -CopyToProject "C:\path\to\existing\angular\project".
    Copies branding to that project's src\assets\branding\. Writes
    wiring snippets into KT-WIRING\ subfolder for manual merge.
    Does not overwrite existing styles.scss, index.html, or app files.

    Both modes ASCII only, idempotent, dry-run by default.

.PARAMETER VaultRoot
    Vault root path. Default: C:\ICS-LT-FYXFHG4\KT\clinical\Readiness

.PARAMETER CopyToProject
    Optional. Path to an existing Angular project. If set, runs in copy mode.
    If empty, runs in scaffold mode.

.PARAMETER Apply
    Switch. Default is dry-run. Pass -Apply to actually write files.

.EXAMPLE
    .\wire-angular-branding.ps1
    .\wire-angular-branding.ps1 -Apply
    .\wire-angular-branding.ps1 -CopyToProject "C:\dev\my-angular-app" -Apply

.NOTES
    Saga: KTS-0000003 (branding) extension
    ASCII only. Compatible with Windows PowerShell 5.x and PowerShell 7+.
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
function Copy-Branding([string]$destDir) {
    $src = Join-Path $VaultRoot "05_Wiki\branding"
    if (-not (Test-Path $src)) { throw "Branding source not found: $src" }
    Run "Copy branding from $src to $destDir" {
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Copy-Item -Path "$src\*" -Destination $destDir -Recurse -Force
    }
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
    Note "Mode: COPY (apply branding to existing project at $CopyToProject)"
} else {
    $mode = "scaffold"
    $angularRoot = Join-Path $VaultRoot "04_Applications\clinical-spa-angular"
    Note "Mode: SCAFFOLD (write wiring kit at $angularRoot)"
}
if ($Apply) { Note "Action: APPLY (will mutate)" } else { Note "Action: DRY-RUN (read only)" }

# ============================================================================
# Define content (shared between modes)
# ============================================================================

$stylesScss = @'
// KT Clinical brand integration
@import "assets/branding/brand-tokens";

// Global app baseline
html, body {
  height: 100%;
  margin: 0;
  font-family: $kt-font-family;
  background: $kt-bg-light;
  color: $kt-text-dark;
}

// Main content area
.kt-main {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

// Reusable primary button
.kt-button-primary {
  background: $kt-purple;
  color: $kt-text-light;
  border: none;
  border-radius: $kt-radius-md;
  padding: 0.75rem 1.5rem;
  font-family: $kt-font-family;
  font-weight: 700;
  cursor: pointer;
  transition: background 150ms ease;
}

.kt-button-primary:hover {
  background: $kt-blue;
}

.kt-button-primary:focus-visible {
  outline: 2px solid $kt-green;
  outline-offset: 2px;
}
'@

$indexHtml = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>KT Clinical</title>
  <base href="/">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- KT Clinical branding -->
  <link rel="icon" type="image/svg+xml" href="assets/branding/favicon.svg">
  <meta property="og:title" content="KT Clinical">
  <meta property="og:description" content="Stack translation and readiness vault">
  <meta property="og:image" content="assets/branding/open-graph.svg">
  <meta name="theme-color" content="#7C3AED">

</head>
<body>
  <app-root></app-root>
</body>
</html>
'@

$indexHeadSnippet = @'
<!-- KT Clinical branding (paste inside <head> of your existing index.html) -->
<link rel="icon" type="image/svg+xml" href="assets/branding/favicon.svg">
<meta property="og:title" content="KT Clinical">
<meta property="og:description" content="Stack translation and readiness vault">
<meta property="og:image" content="assets/branding/open-graph.svg">
<meta name="theme-color" content="#7C3AED">
'@

$headerTs = @'
import { Component } from "@angular/core";
import { RouterLink, RouterLinkActive } from "@angular/router";

@Component({
  selector: "app-header",
  standalone: true,
  imports: [RouterLink, RouterLinkActive],
  templateUrl: "./header.component.html",
  styleUrls: ["./header.component.scss"]
})
export class HeaderComponent {
  title = "KT Clinical";
}
'@

$headerHtml = @'
<header class="kt-header">
  <a class="kt-header-logo" routerLink="/">
    <img src="assets/branding/logo-horizontal-dark.svg" alt="KT Clinical" />
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
  color: $kt-text-light;
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
  color: $kt-text-light;
  text-decoration: none;
  font-family: $kt-font-family;
  font-weight: 500;
  padding: 0.25rem 0;
  border-bottom: 2px solid transparent;
  transition: border-color 150ms ease, color 150ms ease;
}

.kt-header-nav a:hover {
  color: $kt-green;
  border-bottom-color: $kt-green;
}

.kt-header-nav a.active {
  border-bottom-color: $kt-purple;
}
'@

$appComponentTs = @'
import { Component } from "@angular/core";
import { RouterOutlet } from "@angular/router";
import { HeaderComponent } from "./shared/header/header.component";

@Component({
  selector: "app-root",
  standalone: true,
  imports: [RouterOutlet, HeaderComponent],
  templateUrl: "./app.component.html"
})
export class AppComponent {
  title = "kt-clinical-spa";
}
'@

$appComponentHtml = @'
<app-header></app-header>
<main class="kt-main">
  <router-outlet></router-outlet>
</main>
'@

$scaffoldReadme = @'
# KT Clinical SPA - Angular wiring kit

This folder is a WIRING KIT, not a runnable Angular project. Three more steps turn it into a working app.

## Step 1: Install Node.js and Angular CLI

If not already installed:
- Node.js 20 LTS or newer: https://nodejs.org
- Angular CLI: npm install -g @angular/cli

## Step 2: Bootstrap a fresh Angular project IN THIS FOLDER

From this folder (clinical-spa-angular):

  ng new clinical-spa --routing=true --style=scss --standalone=true --skip-git=true --directory=.

When prompted:
- Server-Side Rendering: No
- Static Site Generation: No

This generates package.json, angular.json, tsconfig, node_modules.

## Step 3: Re-apply the wiring

ng new will overwrite some files this script wrote. Re-run this script to restore them:

  ..\.._scripts\wire-angular-branding.ps1 -Apply

(Adjust path to wherever the script lives.)

## Step 4: Run

  npm start

Open http://localhost:4200. You should see the KT Clinical branded header with three nav links and a routed empty content area.

## What this kit wires

- src/styles.scss: imports brand-tokens, baseline body, `.kt-button-primary` utility.
- src/index.html: favicon, Open Graph meta, theme color.
- src/app/app.component.ts and .html: standalone root component with header + router outlet.
- src/app/shared/header/header.component.{ts,html,scss}: brand toolbar.
- src/assets/branding/: full brand asset set.

## Tip: shorten brand-tokens import paths

Long relative paths like ../../../assets/branding/brand-tokens get tedious. After ng new, edit angular.json and add to your build target:

  "stylePreprocessorOptions": {
    "includePaths": ["src/assets/branding"]
  }

Then any component scss can do:

  @import "brand-tokens";

## Brand colors

- Purple #7C3AED (front layer, primary actions)
- Green #10B981 (middle layer, hover and success)
- Blue #3B82F6 (back layer, secondary)

Order is deliberate.
'@

$copyReadme = @'
# KT Clinical branding - merge guide

The branding asset set was just copied to your project's src/assets/branding/.

The files in this KT-WIRING/ folder are SNIPPETS to be merged into your existing Angular files. Do NOT blindly overwrite your styles.scss or index.html or app.component files.

## What got copied automatically

- src/assets/branding/ : full brand asset set (SVG logos, brand-tokens.css, brand-tokens.scss, brand-tokens.json, README.md).

## What you merge manually

### styles.scss

The provided styles.scss adds:
- @import "assets/branding/brand-tokens"; at the top
- html, body baseline rules
- .kt-main wrapper rule
- .kt-button-primary utility class

Open KT-WIRING/styles.scss and your project's src/styles.scss side by side. Add the import line and any rules you want.

### index.html

The provided index-head-snippet.html shows the head additions for branding (favicon, Open Graph, theme-color). Paste those lines inside your existing src/index.html <head>.

### Header component

Three new files at app/shared/header/. Drop them as-is into your project at src/app/shared/header/.

In your src/app/app.component.ts, add the import:

  import { HeaderComponent } from "./shared/header/header.component";

And add HeaderComponent to the standalone imports array.

In your src/app/app.component.html, add near the top:

  <app-header></app-header>

If you are NOT using standalone components, declare HeaderComponent in your AppModule instead.

## Tip: shorten brand-tokens import paths

Edit angular.json under your build target options:

  "stylePreprocessorOptions": {
    "includePaths": ["src/assets/branding"]
  }

Then any component scss can do @import "brand-tokens"; directly.

## Brand colors

- Purple #7C3AED (front layer, primary actions)
- Green #10B981 (middle layer, hover and success)
- Blue #3B82F6 (back layer, secondary)

Order is deliberate.
'@

# ============================================================================
# Execute based on mode
# ============================================================================

if ($mode -eq "scaffold") {
    Step "Scaffold mode: writing Angular wiring kit"

    Write-File (Join-Path $angularRoot "src\styles.scss") $stylesScss
    Write-File (Join-Path $angularRoot "src\index.html") $indexHtml
    Write-File (Join-Path $angularRoot "src\app\app.component.ts") $appComponentTs
    Write-File (Join-Path $angularRoot "src\app\app.component.html") $appComponentHtml
    Write-File (Join-Path $angularRoot "src\app\shared\header\header.component.ts") $headerTs
    Write-File (Join-Path $angularRoot "src\app\shared\header\header.component.html") $headerHtml
    Write-File (Join-Path $angularRoot "src\app\shared\header\header.component.scss") $headerScss
    Write-File (Join-Path $angularRoot "README.md") $scaffoldReadme

    Copy-Branding (Join-Path $angularRoot "src\assets\branding")

} else {
    Step "Copy mode: applying branding and writing wiring snippets"

    Copy-Branding (Join-Path $angularRoot "src\assets\branding")

    $wiring = Join-Path $angularRoot "KT-WIRING"
    Write-File (Join-Path $wiring "styles.scss") $stylesScss
    Write-File (Join-Path $wiring "index-head-snippet.html") $indexHeadSnippet
    Write-File (Join-Path $wiring "app\shared\header\header.component.ts") $headerTs
    Write-File (Join-Path $wiring "app\shared\header\header.component.html") $headerHtml
    Write-File (Join-Path $wiring "app\shared\header\header.component.scss") $headerScss
    Write-File (Join-Path $wiring "app\app.component.ts") $appComponentTs
    Write-File (Join-Path $wiring "app\app.component.html") $appComponentHtml
    Write-File (Join-Path $wiring "README.md") $copyReadme
}

# ============================================================================
# Final report
# ============================================================================
Step "Final state"
if ($Apply) {
    Write-Host ""
    if ($mode -eq "scaffold") {
        Write-Host "Wiring kit written to:" -ForegroundColor Green
        Write-Host "  $angularRoot"
        Write-Host ""
        Write-Host "Next: read $angularRoot\README.md and run ng new in that folder." -ForegroundColor Cyan
    } else {
        Write-Host "Branding applied to:" -ForegroundColor Green
        Write-Host "  $angularRoot\src\assets\branding\"
        Write-Host ""
        Write-Host "Wiring snippets written to:" -ForegroundColor Green
        Write-Host "  $angularRoot\KT-WIRING\"
        Write-Host ""
        Write-Host "Next: read $angularRoot\KT-WIRING\README.md and merge snippets into your existing files." -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "DRY RUN COMPLETE. Re-run with -Apply to mutate." -ForegroundColor Yellow
    if ($mode -eq "scaffold") {
        Write-Host "Suggested: .\wire-angular-branding.ps1 -Apply"
    } else {
        Write-Host "Suggested: .\wire-angular-branding.ps1 -CopyToProject `"$angularRoot`" -Apply"
    }
}
