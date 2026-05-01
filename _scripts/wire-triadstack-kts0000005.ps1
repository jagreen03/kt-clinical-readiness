<#
.SYNOPSIS
    KTS-0000005. Wire TriadStack branding into an Angular project.

.DESCRIPTION
    Self-contained, idempotent, ASCII only.

    FIX (revision 2): scaffold mode no longer wipes the whole target folder.
    The previous version destroyed ng new output if you ran it after ng new.
    Now it only overwrites the specific wiring files and wipes the branding
    asset folder. ng new artifacts (package.json, angular.json, node_modules,
    main.ts, app.config.ts, app.routes.ts, etc.) are preserved.

    Two modes.

    SCAFFOLD MODE (default): writes wiring kit at
        VaultRoot\04_Applications\clinical-spa-angular\
    Expects the folder to either be empty OR to contain ng new output.
    Overlays TriadStack styles, header component, branding assets on top.
    Re-running is safe: overwrites wiring files in place, wipes only
    src\assets\branding\ before re-copying.

    COPY MODE (-CopyToProject "C:\path\to\angular\app"): copies branding into
    that project's src\assets\branding\ (wiping that folder first to clear
    orphans). Drops wiring snippets into KT-WIRING\ for manual merge.
    Does not touch the project's existing styles.scss, index.html, or app
    files.

    Both modes ASCII only, dry-run by default.

.PARAMETER VaultRoot
    Vault root path. Default: C:\ICS-LT-FYXFHG4\KT\clinical\Readiness

.PARAMETER CopyToProject
    Optional. Path to an existing Angular project. If set, runs in copy mode.

.PARAMETER Apply
    Switch. Default is dry-run.

.EXAMPLE
    .\wire-triadstack-kts0000005.ps1
    .\wire-triadstack-kts0000005.ps1 -Apply

.NOTES
    Saga: KTS-0000005 (revision 2)
    Supersedes: _scripts/wire-angular-branding.ps1 (KTS-0000003)
    Workflow: clean folder -> ng new -> this script.
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
# Wiring content (shared between modes)
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
  title = "triadstack-spa";
}
'@

$appComponentHtml = @'
<app-header></app-header>
<main class="kt-main">
  <router-outlet></router-outlet>
</main>
'@

$scaffoldReadme = @'
# TriadStack SPA - Angular project

This Angular project uses the TriadStack architectural identity for branding.

## Workflow used to build this

1. Wiped the empty target folder.
2. Ran ng new in the empty folder:
     ng new triadstack-spa --routing=true --style=scss --standalone=true --skip-git=true --directory=.
   Prompts answered: SSR No, zoneless Yes, AI tools None.
3. Ran wire-triadstack-kts0000005.ps1 -Apply to overlay TriadStack wiring on top.

To re-apply branding after pulling new branding source from the vault, just re-run the script. It overwrites wiring files in place and refreshes src/assets/branding/. ng new artifacts are preserved.

## Run

  npm start

Open http://localhost:4200. The TriadStack header (mark plus wordmark on dark background) shows three nav links. Routed empty content area below.

## What the script wired

- src/styles.scss: imports brand-tokens, baseline body, .kt-button-primary utility, accessibility-aware focus states.
- src/index.html: favicon, Open Graph meta, theme color.
- src/app/app.component.ts and .html: standalone root component with header + router outlet.
- src/app/shared/header/header.component.{ts,html,scss}: TriadStack toolbar, dark background, brand colors paired with hover states.
- src/assets/branding/: brand-tokens (CSS, SCSS, JSON), PGB.md doctrine, TriadStack logos and favicon.

## What ng new provided (untouched)

- package.json, package-lock.json, node_modules
- angular.json, tsconfig*.json
- src/main.ts, src/app/app.config.ts, src/app/app.routes.ts
- src/app/app.component.spec.ts
- public/ folder (Angular 17+) or src/assets/ scaffolding
- .editorconfig, .gitignore (project-level), README.md (overwritten by this script)

## Tip: shorten brand-tokens import paths

Edit angular.json and add to your build target options:

  "stylePreprocessorOptions": {
    "includePaths": ["src/assets/branding"]
  }

Then any component scss can do:

  @import "brand-tokens";

instead of long relative paths.

## Brand colors and PGB doctrine

- Purple #7C3AED (front layer, primary actions, unexpected/usable content)
- Green #10B981 (middle layer, hover and success, delivered as specified)
- Blue #3B82F6 (back layer, secondary, exceptional quality)

Full doctrine in src/assets/branding/PGB.md.

## Three viewing modes

brand-tokens.css ships with light, dark, and high-contrast modes. Resolution order:

1. Manual: html element data-theme attribute. Set "light", "dark", or "high-contrast".
2. Auto: prefers-contrast: more then prefers-color-scheme: dark.
3. Default: light.

A user-facing toggle should set data-theme on the html element to guarantee AAA-tier access regardless of OS configuration.
'@

$copyReadme = @'
# TriadStack branding - merge guide

The TriadStack branding asset set was just copied to your project's src/assets/branding/. The files in this KT-WIRING/ folder are SNIPPETS to be merged into your existing Angular files.

## What got copied automatically

src/assets/branding/ contents (flattened TriadStack):
- brand-tokens.css (three viewing modes)
- brand-tokens.scss (full token set)
- brand-tokens.json
- PGB.md (doctrine)
- README.md (TriadStack guide)
- favicon.svg
- logo-mark.svg
- logo-horizontal.svg
- logo-horizontal-dark.svg
- open-graph.svg

## What you merge manually

### styles.scss

Provided KT-WIRING/styles.scss adds brand-tokens import, baseline body, .kt-main wrapper, .kt-button-primary utility. Merge into your existing src/styles.scss.

### index.html

Provided KT-WIRING/index-head-snippet.html shows head additions (favicon, Open Graph, theme-color). Paste those lines inside your existing src/index.html <head>.

### Header component

Three new files at app/shared/header/. Drop them as-is into your project.

In src/app/app.component.ts add the import:

  import { HeaderComponent } from "./shared/header/header.component";

And add HeaderComponent to the standalone imports array.

In src/app/app.component.html add near the top:

  <app-header></app-header>

If using NgModules instead of standalone, declare HeaderComponent in your AppModule.

## Tip: shorten brand-tokens import paths

In angular.json under your build target options:

  "stylePreprocessorOptions": {
    "includePaths": ["src/assets/branding"]
  }

Then any component scss can do @import "brand-tokens"; directly.

## Brand colors and PGB doctrine

See src/assets/branding/PGB.md.

## Three viewing modes

Auto via prefers-color-scheme and prefers-contrast media queries. Manual override via the html element data-theme attribute. See brand-tokens.css for full token set.
'@

# ============================================================================
# Execute based on mode
# ============================================================================

if ($mode -eq "scaffold") {
    Step "Scaffold mode: overlaying TriadStack wiring on existing folder"
    Note "ng new artifacts (package.json, angular.json, etc.) preserved"

    # NOTE: NO whole-folder wipe. Only specific wiring files are overwritten.
    # Copy-TriadStackAssets wipes src\assets\branding\ to clear orphan brand files.

    Write-File (Join-Path $angularRoot "src\styles.scss") $stylesScss
    Write-File (Join-Path $angularRoot "src\index.html") $indexHtml
    Write-File (Join-Path $angularRoot "src\app\app.component.ts") $appComponentTs
    Write-File (Join-Path $angularRoot "src\app\app.component.html") $appComponentHtml
    Write-File (Join-Path $angularRoot "src\app\shared\header\header.component.ts") $headerTs
    Write-File (Join-Path $angularRoot "src\app\shared\header\header.component.html") $headerHtml
    Write-File (Join-Path $angularRoot "src\app\shared\header\header.component.scss") $headerScss
    Write-File (Join-Path $angularRoot "README.md") $scaffoldReadme

    Copy-TriadStackAssets (Join-Path $angularRoot "src\assets\branding")

} else {
    Step "Copy mode: applying TriadStack to existing project"

    Copy-TriadStackAssets (Join-Path $angularRoot "src\assets\branding")

    $wiring = Join-Path $angularRoot "KT-WIRING"
    Wipe-IfExists $wiring "existing KT-WIRING folder"

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
        Write-Host "TriadStack wiring overlaid on:" -ForegroundColor Green
        Write-Host "  $angularRoot"
        Write-Host ""
        Write-Host "Verify ng new produced these (must be present for npm start to work):" -ForegroundColor Cyan
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
        Write-Host "Next:" -ForegroundColor Cyan
        Write-Host "  cd $angularRoot"
        Write-Host "  npm start"
        Write-Host ""
        Write-Host "If MISSING items appear above, run ng new in the folder first:" -ForegroundColor Yellow
        Write-Host "  cd $angularRoot"
        Write-Host "  ng new triadstack-spa --routing=true --style=scss --standalone=true --skip-git=true --directory=."
        Write-Host "  Then re-run this script."
    } else {
        Write-Host "TriadStack branding applied to:" -ForegroundColor Green
        Write-Host "  $angularRoot\src\assets\branding\"
        Write-Host ""
        Write-Host "Wiring snippets at:" -ForegroundColor Green
        Write-Host "  $angularRoot\KT-WIRING\"
        Write-Host ""
        Write-Host "Next: read $angularRoot\KT-WIRING\README.md and merge snippets into your existing files." -ForegroundColor Cyan
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
