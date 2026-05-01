<#
.SYNOPSIS
    KTS-0000004 brand split. Apply Gemini decisions to vault branding.

.DESCRIPTION
    Splits 05_Wiki/branding/ into two sub-brands (layeredkt, triadstack)
    sharing one PGB doctrine and one accessibility-aware token set.

    Per Gemini KTS-0000004 verdicts:
    - Decisions 1, 2, 4, 5, 6: Hold.
    - Decision 3: Expand. Manual data-theme override plus prefers-color-scheme
      and prefers-contrast media queries.
    - Contrast tweaks for body text:
        light bg: green #047857, blue #1D4ED8, purple #7C3AED
        dark bg:  green #10B981, blue #3B82F6, purple #A78BFA

    Self-contained, idempotent, ASCII only. DRY-RUN by default.

.PARAMETER VaultRoot
    Vault root path. Default: C:\ICS-LT-FYXFHG4\KT\clinical\Readiness

.PARAMETER Apply
    Switch. Default is dry-run. Pass -Apply to mutate.

.EXAMPLE
    .\split-branding-kts0000004.ps1
    .\split-branding-kts0000004.ps1 -Apply

.NOTES
    Saga: KTS-0000004
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
function Write-File([string]$fullPath, [string]$content) {
    $dir = Split-Path -Parent $fullPath
    Run "Write $fullPath" {
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
    }
}
function Remove-IfExists([string]$path, [string]$desc) {
    if (Test-Path $path) {
        Run "Remove $desc" {
            Remove-Item -Path $path -Force
        }
    }
}

# ============================================================================
# Validate
# ============================================================================
Step "Validating VaultRoot"
if (-not (Test-Path $VaultRoot)) { throw "Vault root not found: $VaultRoot" }
Note "VaultRoot: $VaultRoot"
if ($Apply) { Note "Mode: APPLY (will mutate)" } else { Note "Mode: DRY-RUN (read only)" }

$brandingRoot = Join-Path $VaultRoot "05_Wiki\branding"

# ============================================================================
# Save Gemini KTS-0000004 response verbatim
# ============================================================================
Step "Saving Gemini KTS-0000004 decisions response"

$geminiResponse = @'
# KTS-0000004 - Decisions Response (Gemini)

**Saga:** KTS-0000004
**Date:** 2026-05-02
**Tool:** Gemini 3.1 Pro
**Pairs with:** 01_Prompts/gemini/2026-05-02_KTS-0000004_decisions-made-gemini.md
**Author convention:** AI-Architect (with WCAG 2.1 accessibility lens)

---

I hear you. Let's drop the meta-commentary and focus entirely on execution. Here is the evaluation of the six decisions against WCAG 2.1 and brand-system standards, followed by the contrast analysis.

## Decision Evaluation

### Decision 1: Reframe to two brands plus one doctrine

Hold. Sound systems-architecture choice. Eliminates redundant asset generation. PGB functions effectively as a design token root rather than a stamped mark.

### Decision 2: One font. Inter.

Hold. Inter is a WCAG-friendly UI workhorse. Optical sizing and high legibility at small x-heights make it ideal for dense architectural interfaces and clear wordmarks.

### Decision 3: Three viewing modes.

Expand. You defined the visual states, but lack the technical enforcement mechanism. To meet WCAG 1.4.8 (Visual Presentation), define whether modes are enforced via OS-level media queries (prefers-color-scheme, prefers-contrast) or a user-facing toggle. Given the "high-contrast" requirement, a manual toggle overriding system defaults is highly recommended so users aren't locked out of the AAA tier if their OS isn't configured for it.

### Decision 4: Cross-brand consistency rules.

Hold. Explicitly pairing color with shape and layer offset satisfies WCAG 1.4.1 (Use of Color). The system relies on geometry, not just chroma, for identity.

### Decision 5: Monorepo for TriadStack work.

Hold. Standard enterprise pattern. Keeps front-end (Angular), BFF (Spring Boot), and IaC (AWS) synchronized for atomic commits and easier local spin-up for interviews.

### Decision 6: Vault update path.

Hold. Directory mapping is logical and separates concerns between shared tokens, doctrine, and specific brand marks.

## WCAG AA 4.5:1 Contrast Verification

Applying the proposed palette (#7C3AED, #10B981, #3B82F6) against Light (#FFFFFF) and Dark (#0F172A) backgrounds.

Note: WCAG AA requires 4.5:1 for normal text and 3.0:1 for large text (18pt+) or UI components (graphics/logos).

- Green (#10B981) on Light (#FFFFFF): FAILS. Ratio is ~2.1:1. Fails both text (4.5:1) and non-text graphical component (3.0:1) standards.
  - Tweak: Use #047857 (Emerald 700) for text/icons on light backgrounds (ratio ~7.3:1).

- Blue (#3B82F6) on Light (#FFFFFF): FAILS (for normal text). Ratio is ~3.2:1. Passes for large text/logos, but fails normal UI text.
  - Tweak: Use #1D4ED8 (Blue 700) for body text on light backgrounds (ratio ~6.2:1).

- Purple (#7C3AED) on Light (#FFFFFF): PASSES. Ratio is ~4.9:1. Safe for normal text and logos.

- Purple (#7C3AED) on Dark (#0F172A): FAILS (for normal text). Ratio is ~3.1:1. Passes for large text/logos, but fails normal UI text.
  - Tweak: Use #A78BFA (Purple 400) for body text on dark backgrounds (ratio ~5.9:1).

- Green (#10B981) on Dark (#0F172A): PASSES. Ratio is ~6.5:1. Safe for all uses.

- Blue (#3B82F6) on Dark (#0F172A): PASSES. Ratio is ~4.5:1. Just hits the AA threshold for normal text.

Summary for CSS Tokens: Keep your core 3 hexes for logos and large structural elements. You must generate a secondary "Text/Foreground" token set using the tweaks above to ensure standard text remains readable across the viewing modes.
'@
Write-File (Join-Path $VaultRoot "02_Responses\gemini\2026-05-02_KTS-0000004_decisions-RESPONSE-gemini.md") $geminiResponse

# ============================================================================
# Write PGB.md doctrine
# ============================================================================
Step "Writing PGB doctrine"

$pgbDoctrine = @'
# PGB - PurpleGreenBlue Doctrine

PGB is not a brand. It is the quality doctrine that the brand colors encode.

## The three layers and what they mean

The shape grammar across all KT Clinical brand identities is three offset rounded squares in fixed front-to-back order. The order has meaning. Each layer is a quality bar.

| Layer | Color | Hex | Quality bar |
|---|---|---|---|
| Front | Purple | #7C3AED | Unexpected, usable content. Goes beyond what was asked. |
| Middle | Green | #10B981 | Delivered as specified. Meets the requirement on the page. |
| Back | Blue | #3B82F6 | Exceptional quality. Standards-compliant, accessible, durable. |

Read top down: a piece of work that earns the front layer also earned the middle and back layers underneath it.

## How to use this doctrine

When reviewing work (mine, AI output, contractor deliverables), ask in this order:

1. Did this hit the back layer? Standards (WCAG, OWASP, SOLID, the spec). Yes/No.
2. Did this hit the middle layer? Delivered what was specified. Yes/No.
3. Did this hit the front layer? Surpassed the spec with usable, unexpected value. Yes/No.

Three Yes = production ready. Two Yes = ship with caveats. One or zero = rework.

## Visual implication

Logo art renders all three layers because all three are required. Removing a layer would break PGB. The layered offset is mandatory. Layer order is mandatory.

## Accessibility note

The brand hex codes (#7C3AED, #10B981, #3B82F6) are reserved for logos and large structural blocks where the WCAG 3.0:1 ratio for graphical components applies. Body text and small UI elements use the per-mode foreground tokens defined in brand-tokens.css. Per Gemini KTS-0000004 verification:

- Light backgrounds: purple text uses #7C3AED, green text uses #047857 (Emerald 700), blue text uses #1D4ED8 (Blue 700).
- Dark backgrounds: purple text uses #A78BFA (Purple 400), green text uses #10B981, blue text uses #3B82F6.
- High-contrast mode: black on white only; brand colors used as solid blocks paired with text labels.

## Cross-reference

- Branded surfaces: layeredkt/ (personal portfolio), triadstack/ (architectural projects).
- Token source: brand-tokens.css, brand-tokens.scss, brand-tokens.json.
- Viewing modes: light (default), dark (auto via prefers-color-scheme or manual), high-contrast (auto via prefers-contrast or manual).
- Mode override: set the data-theme attribute on the html element to "light", "dark", or "high-contrast" to override OS preferences.
'@
Write-File (Join-Path $brandingRoot "PGB.md") $pgbDoctrine

# ============================================================================
# Write top-level README.md
# ============================================================================
Step "Writing top-level branding README"

$topReadme = @'
# KT Clinical Readiness branding

Two brands sharing one color system, one shape grammar, and one PGB doctrine.

## When to use which

| Surface | Brand |
|---|---|
| Personal portfolio (jagreen03/jagreen03 PORTFOLIO_README) | layeredkt/ |
| CV-style materials | layeredkt/ |
| Personal social cards | layeredkt/ |
| Article author byline graphics | layeredkt/ |
| TriadStack monorepo (jagreen03/PurpleGreenBlue) | triadstack/ |
| Spring Boot + Angular full-stack work | triadstack/ |
| AWS infra repos under TriadStack | triadstack/ |
| Architectural diagrams and READMEs | triadstack/ |

## Folder map

| Path | Purpose |
|---|---|
| brand-tokens.css | CSS custom properties, three viewing modes |
| brand-tokens.scss | SCSS variables, full token set |
| brand-tokens.json | Design tokens for tools that consume JSON |
| PGB.md | Doctrine: what the three layers mean |
| README.md | This file |
| layeredkt/ | Personal portfolio brand (KT monogram on front) |
| triadstack/ | Architectural brand (no monogram) |

## Viewing modes

Three modes defined per Gemini KTS-0000004 (Decision 3 expand for WCAG 1.4.8):

- light (default): white background, dark text, full-saturation logos.
- dark: near-black background (#0F172A), light text, slightly desaturated logo colors.
- high-contrast: pure black on pure white, brand colors paired with text labels only.

Mode resolution order:

1. If html element has data-theme attribute, use it (manual override).
2. Else if OS prefers-contrast: more, use high-contrast.
3. Else if OS prefers-color-scheme: dark, use dark.
4. Else light (default).

A user-facing toggle should set data-theme on the html element. This guarantees AAA-tier access regardless of OS configuration.

## Accessibility

WCAG 2.1 AA conformance applied to all text tokens. Brand hex codes are reserved for logos and structural elements at 3.0:1 contrast minimum. Body text uses per-mode tweaked colors:

- Purple text: #7C3AED on light, #A78BFA on dark.
- Green text: #047857 on light, #10B981 on dark.
- Blue text: #1D4ED8 on light, #3B82F6 on dark.

WCAG 1.4.1 (Use of Color): every brand color usage pairs with shape, text label, or icon. Color is never the only signal.

## Font

Inter, weight 400/500/700/900. CSS stack: "Inter", system-ui, "Arial", sans-serif. Inter is OFL licensed and widely available; system-ui is the fallback chain. SVG logos reference the same stack so they degrade gracefully on systems without Inter.
'@
Write-File (Join-Path $brandingRoot "README.md") $topReadme

# ============================================================================
# Write brand-tokens.css with three modes and accessibility-aware foregrounds
# ============================================================================
Step "Writing brand-tokens.css"

$tokensCss = @'
/* KT Clinical Readiness brand tokens */
/* Per WCAG 2.1 AA contrast verification (Gemini KTS-0000004) */

:root {
  /* Brand hex - logos and large structural elements only */
  --kt-purple: #7C3AED;
  --kt-green: #10B981;
  --kt-blue: #3B82F6;

  /* Geometry */
  --kt-radius-sm: 6px;
  --kt-radius-md: 14px;
  --kt-radius-lg: 28px;
  --kt-radius-xl: 40px;

  /* Typography */
  --kt-font-family: "Inter", system-ui, "Arial", sans-serif;
  --kt-font-weight-regular: 400;
  --kt-font-weight-medium: 500;
  --kt-font-weight-bold: 700;
  --kt-font-weight-black: 900;

  /* Light mode (default) */
  --kt-bg: #FFFFFF;
  --kt-text: #1F2937;
  --kt-text-muted: #475569;
  --kt-text-purple: #7C3AED;
  --kt-text-green: #047857;
  --kt-text-blue: #1D4ED8;
}

/* Dark mode (auto via OS preference) */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme]) {
    --kt-bg: #0F172A;
    --kt-text: #F1F5F9;
    --kt-text-muted: #94A3B8;
    --kt-text-purple: #A78BFA;
    --kt-text-green: #10B981;
    --kt-text-blue: #3B82F6;
  }
}

/* High contrast (auto via OS preference) */
@media (prefers-contrast: more) {
  :root:not([data-theme]) {
    --kt-bg: #FFFFFF;
    --kt-text: #000000;
    --kt-text-muted: #000000;
    --kt-text-purple: #5B21B6;
    --kt-text-green: #064E3B;
    --kt-text-blue: #1E3A8A;
  }
}

/* Manual override: data-theme="light" */
:root[data-theme="light"] {
  --kt-bg: #FFFFFF;
  --kt-text: #1F2937;
  --kt-text-muted: #475569;
  --kt-text-purple: #7C3AED;
  --kt-text-green: #047857;
  --kt-text-blue: #1D4ED8;
}

/* Manual override: data-theme="dark" */
:root[data-theme="dark"] {
  --kt-bg: #0F172A;
  --kt-text: #F1F5F9;
  --kt-text-muted: #94A3B8;
  --kt-text-purple: #A78BFA;
  --kt-text-green: #10B981;
  --kt-text-blue: #3B82F6;
}

/* Manual override: data-theme="high-contrast" */
:root[data-theme="high-contrast"] {
  --kt-bg: #FFFFFF;
  --kt-text: #000000;
  --kt-text-muted: #000000;
  --kt-text-purple: #5B21B6;
  --kt-text-green: #064E3B;
  --kt-text-blue: #1E3A8A;
}
'@
Write-File (Join-Path $brandingRoot "brand-tokens.css") $tokensCss

# ============================================================================
# Write brand-tokens.scss
# ============================================================================
Step "Writing brand-tokens.scss"

$tokensScss = @'
// KT Clinical Readiness brand tokens
// Per WCAG 2.1 AA contrast verification (Gemini KTS-0000004)

// Brand hex - logos and large structural elements only
$kt-purple: #7C3AED;
$kt-green: #10B981;
$kt-blue: #3B82F6;

// Per-mode background tokens
$kt-bg-light: #FFFFFF;
$kt-bg-dark: #0F172A;
$kt-bg-hc-light: #FFFFFF;
$kt-bg-hc-dark: #000000;

// Per-mode body text tokens
$kt-text-on-light: #1F2937;
$kt-text-on-dark: #F1F5F9;
$kt-text-on-hc-light: #000000;
$kt-text-on-hc-dark: #FFFFFF;

$kt-text-muted-on-light: #475569;
$kt-text-muted-on-dark: #94A3B8;

// Per-mode brand text tokens (accessibility-tweaked)
$kt-text-purple-on-light: #7C3AED;
$kt-text-purple-on-dark: #A78BFA;
$kt-text-green-on-light: #047857;
$kt-text-green-on-dark: #10B981;
$kt-text-blue-on-light: #1D4ED8;
$kt-text-blue-on-dark: #3B82F6;

// High-contrast brand text (deepest accessible shades)
$kt-text-purple-on-hc: #5B21B6;
$kt-text-green-on-hc: #064E3B;
$kt-text-blue-on-hc: #1E3A8A;

// Typography
$kt-font-family: "Inter", system-ui, "Arial", sans-serif;
$kt-font-weight-regular: 400;
$kt-font-weight-medium: 500;
$kt-font-weight-bold: 700;
$kt-font-weight-black: 900;

// Geometry
$kt-radius-sm: 6px;
$kt-radius-md: 14px;
$kt-radius-lg: 28px;
$kt-radius-xl: 40px;
'@
Write-File (Join-Path $brandingRoot "brand-tokens.scss") $tokensScss

# ============================================================================
# Write brand-tokens.json
# ============================================================================
Step "Writing brand-tokens.json"

$tokensJson = @'
{
  "color": {
    "brand": {
      "purple": "#7C3AED",
      "green": "#10B981",
      "blue": "#3B82F6"
    },
    "bg": {
      "light": "#FFFFFF",
      "dark": "#0F172A",
      "hc-light": "#FFFFFF",
      "hc-dark": "#000000"
    },
    "fg": {
      "on-light": "#1F2937",
      "on-dark": "#F1F5F9",
      "on-hc-light": "#000000",
      "on-hc-dark": "#FFFFFF",
      "muted-on-light": "#475569",
      "muted-on-dark": "#94A3B8"
    },
    "brand-text": {
      "purple-on-light": "#7C3AED",
      "purple-on-dark": "#A78BFA",
      "purple-on-hc": "#5B21B6",
      "green-on-light": "#047857",
      "green-on-dark": "#10B981",
      "green-on-hc": "#064E3B",
      "blue-on-light": "#1D4ED8",
      "blue-on-dark": "#3B82F6",
      "blue-on-hc": "#1E3A8A"
    }
  },
  "radius": {
    "sm": "6px",
    "md": "14px",
    "lg": "28px",
    "xl": "40px"
  },
  "font": {
    "family": "Inter, system-ui, Arial, sans-serif",
    "weight": {
      "regular": 400,
      "medium": 500,
      "bold": 700,
      "black": 900
    }
  }
}
'@
Write-File (Join-Path $brandingRoot "brand-tokens.json") $tokensJson

# ============================================================================
# LayeredKT subfolder
# ============================================================================
Step "Writing layeredkt/ subfolder"

$lktReadme = @'
# LayeredKT

Personal portfolio identity. Three offset layered rounded squares with KT monogram on the front purple layer.

## When to use

- Personal portfolio (jagreen03/jagreen03 PORTFOLIO_README repo)
- CV-style documents
- Personal social cards
- Article author byline graphics
- Avatar in authoring contexts

## Files

| File | Purpose |
|---|---|
| logo-mark.svg | Three layered squares, no monogram. Decorative use only. |
| logo-square.svg | KT monogram inside layers. Primary mark. |
| logo-horizontal.svg | Mark plus LayeredKT wordmark, light bg. |
| logo-horizontal-dark.svg | Mark plus white wordmark, dark bg. |
| logo-mono-purple.svg | Single-color purple, KT monogram inside. |
| logo-mono-white.svg | White outline, KT monogram inside. |
| open-graph.svg | 1200x630 social card. |
| favicon.svg | Layered squares, no monogram. |

## Specs

- Layer order: purple front, green middle, blue back. Mandatory per PGB doctrine.
- Font: Inter, weight 700 wordmark, weight 900 monogram. Stack: Inter, system-ui, Arial, sans-serif.
- Hex: #7C3AED, #10B981, #3B82F6 per PGB.md.
'@
Write-File (Join-Path $brandingRoot "layeredkt\README.md") $lktReadme

$lktMark = @'
<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>LayeredKT mark</title>
  <desc>Three layered rounded squares in blue, green, and purple.</desc>
  <rect x="156" y="156" width="280" height="280" rx="32" fill="#3B82F6"/>
  <rect x="136" y="136" width="280" height="280" rx="32" fill="#10B981"/>
  <rect x="116" y="116" width="280" height="280" rx="32" fill="#7C3AED"/>
</svg>
'@
Write-File (Join-Path $brandingRoot "layeredkt\logo-mark.svg") $lktMark

$lktSquare = @'
<svg viewBox="0 0 680 680" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>LayeredKT logo square</title>
  <desc>KT monogram inside three layered rounded squares.</desc>
  <rect x="210" y="210" width="360" height="360" rx="40" fill="#3B82F6"/>
  <rect x="185" y="185" width="360" height="360" rx="40" fill="#10B981"/>
  <rect x="160" y="160" width="360" height="360" rx="40" fill="#7C3AED"/>
  <text x="340" y="340" font-family="Inter, system-ui, Arial, sans-serif" font-size="200" font-weight="900" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
</svg>
'@
Write-File (Join-Path $brandingRoot "layeredkt\logo-square.svg") $lktSquare

$lktHorizontal = @'
<svg viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>LayeredKT horizontal logo</title>
  <desc>Mark with KT monogram plus LayeredKT wordmark for light backgrounds.</desc>
  <rect x="50" y="50" width="120" height="120" rx="14" fill="#3B82F6"/>
  <rect x="35" y="35" width="120" height="120" rx="14" fill="#10B981"/>
  <rect x="20" y="20" width="120" height="120" rx="14" fill="#7C3AED"/>
  <text x="80" y="80" font-family="Inter, system-ui, Arial, sans-serif" font-size="68" font-weight="900" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
  <text x="220" y="120" font-family="Inter, system-ui, Arial, sans-serif" font-size="56" font-weight="700" fill="#1F2937">LayeredKT</text>
</svg>
'@
Write-File (Join-Path $brandingRoot "layeredkt\logo-horizontal.svg") $lktHorizontal

$lktHorizontalDark = @'
<svg viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>LayeredKT horizontal logo dark</title>
  <desc>Mark with KT monogram plus white LayeredKT wordmark for dark backgrounds.</desc>
  <rect x="50" y="50" width="120" height="120" rx="14" fill="#3B82F6"/>
  <rect x="35" y="35" width="120" height="120" rx="14" fill="#10B981"/>
  <rect x="20" y="20" width="120" height="120" rx="14" fill="#7C3AED"/>
  <text x="80" y="80" font-family="Inter, system-ui, Arial, sans-serif" font-size="68" font-weight="900" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
  <text x="220" y="120" font-family="Inter, system-ui, Arial, sans-serif" font-size="56" font-weight="700" fill="#F1F5F9">LayeredKT</text>
</svg>
'@
Write-File (Join-Path $brandingRoot "layeredkt\logo-horizontal-dark.svg") $lktHorizontalDark

$lktMonoPurple = @'
<svg viewBox="0 0 680 680" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>LayeredKT logo purple monochrome</title>
  <desc>Single-color purple LayeredKT for one-color contexts.</desc>
  <rect x="160" y="160" width="360" height="360" rx="40" fill="#7C3AED"/>
  <text x="340" y="340" font-family="Inter, system-ui, Arial, sans-serif" font-size="200" font-weight="900" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
</svg>
'@
Write-File (Join-Path $brandingRoot "layeredkt\logo-mono-purple.svg") $lktMonoPurple

$lktMonoWhite = @'
<svg viewBox="0 0 680 680" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>LayeredKT logo white outline</title>
  <desc>White outline LayeredKT for dark backgrounds.</desc>
  <rect x="160" y="160" width="360" height="360" rx="40" fill="none" stroke="#FFFFFF" stroke-width="8"/>
  <text x="340" y="340" font-family="Inter, system-ui, Arial, sans-serif" font-size="200" font-weight="900" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
</svg>
'@
Write-File (Join-Path $brandingRoot "layeredkt\logo-mono-white.svg") $lktMonoWhite

$lktOpenGraph = @'
<svg viewBox="0 0 1200 630" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>LayeredKT social card</title>
  <desc>Open Graph image with KT monogram and LayeredKT wordmark on dark background.</desc>
  <rect width="1200" height="630" fill="#0F172A"/>
  <rect x="160" y="240" width="240" height="240" rx="28" fill="#3B82F6"/>
  <rect x="135" y="215" width="240" height="240" rx="28" fill="#10B981"/>
  <rect x="110" y="190" width="240" height="240" rx="28" fill="#7C3AED"/>
  <text x="230" y="310" font-family="Inter, system-ui, Arial, sans-serif" font-size="140" font-weight="900" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">KT</text>
  <text x="450" y="290" font-family="Inter, system-ui, Arial, sans-serif" font-size="80" font-weight="700" fill="#F1F5F9">LayeredKT</text>
  <text x="450" y="370" font-family="Inter, system-ui, Arial, sans-serif" font-size="36" font-weight="400" fill="#94A3B8">Personal portfolio mark</text>
</svg>
'@
Write-File (Join-Path $brandingRoot "layeredkt\open-graph.svg") $lktOpenGraph

$lktFavicon = @'
<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>LayeredKT favicon</title>
  <rect x="22" y="22" width="32" height="32" rx="6" fill="#3B82F6"/>
  <rect x="18" y="18" width="32" height="32" rx="6" fill="#10B981"/>
  <rect x="14" y="14" width="32" height="32" rx="6" fill="#7C3AED"/>
</svg>
'@
Write-File (Join-Path $brandingRoot "layeredkt\favicon.svg") $lktFavicon

# ============================================================================
# TriadStack subfolder
# ============================================================================
Step "Writing triadstack/ subfolder"

$tsReadme = @'
# TriadStack

Architectural identity for full-stack work. Three offset layered rounded squares with no monogram. The three layers ARE the mark.

## When to use

- TriadStack monorepo (jagreen03/PurpleGreenBlue)
- Spring Boot + Angular projects under TriadStack
- AWS infra repos under TriadStack
- Architectural diagrams
- Tech blog post graphics where the system is the subject

## Files

| File | Purpose |
|---|---|
| logo-mark.svg | Three layered squares. Primary mark. |
| logo-horizontal.svg | Mark plus TriadStack wordmark, light bg. |
| logo-horizontal-dark.svg | Mark plus white wordmark, dark bg. |
| open-graph.svg | 1200x630 social card. |
| favicon.svg | Three layered squares. |

## Specs

- Layer order: purple front, green middle, blue back. Mandatory per PGB doctrine.
- No monogram. Layers carry the identity.
- Font: Inter, weight 700 wordmark. Stack: Inter, system-ui, Arial, sans-serif.
- Hex: #7C3AED, #10B981, #3B82F6 per PGB.md.
'@
Write-File (Join-Path $brandingRoot "triadstack\README.md") $tsReadme

$tsMark = @'
<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>TriadStack mark</title>
  <desc>Three layered rounded squares in blue, green, and purple.</desc>
  <rect x="156" y="156" width="280" height="280" rx="32" fill="#3B82F6"/>
  <rect x="136" y="136" width="280" height="280" rx="32" fill="#10B981"/>
  <rect x="116" y="116" width="280" height="280" rx="32" fill="#7C3AED"/>
</svg>
'@
Write-File (Join-Path $brandingRoot "triadstack\logo-mark.svg") $tsMark

$tsHorizontal = @'
<svg viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>TriadStack horizontal logo</title>
  <desc>Layered mark plus TriadStack wordmark for light backgrounds.</desc>
  <rect x="50" y="50" width="120" height="120" rx="14" fill="#3B82F6"/>
  <rect x="35" y="35" width="120" height="120" rx="14" fill="#10B981"/>
  <rect x="20" y="20" width="120" height="120" rx="14" fill="#7C3AED"/>
  <text x="220" y="120" font-family="Inter, system-ui, Arial, sans-serif" font-size="56" font-weight="700" fill="#1F2937">TriadStack</text>
</svg>
'@
Write-File (Join-Path $brandingRoot "triadstack\logo-horizontal.svg") $tsHorizontal

$tsHorizontalDark = @'
<svg viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>TriadStack horizontal logo dark</title>
  <desc>Layered mark plus white TriadStack wordmark for dark backgrounds.</desc>
  <rect x="50" y="50" width="120" height="120" rx="14" fill="#3B82F6"/>
  <rect x="35" y="35" width="120" height="120" rx="14" fill="#10B981"/>
  <rect x="20" y="20" width="120" height="120" rx="14" fill="#7C3AED"/>
  <text x="220" y="120" font-family="Inter, system-ui, Arial, sans-serif" font-size="56" font-weight="700" fill="#F1F5F9">TriadStack</text>
</svg>
'@
Write-File (Join-Path $brandingRoot "triadstack\logo-horizontal-dark.svg") $tsHorizontalDark

$tsOpenGraph = @'
<svg viewBox="0 0 1200 630" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>TriadStack social card</title>
  <desc>Open Graph image with layered mark and TriadStack wordmark on dark background.</desc>
  <rect width="1200" height="630" fill="#0F172A"/>
  <rect x="160" y="240" width="240" height="240" rx="28" fill="#3B82F6"/>
  <rect x="135" y="215" width="240" height="240" rx="28" fill="#10B981"/>
  <rect x="110" y="190" width="240" height="240" rx="28" fill="#7C3AED"/>
  <text x="450" y="290" font-family="Inter, system-ui, Arial, sans-serif" font-size="80" font-weight="700" fill="#F1F5F9">TriadStack</text>
  <text x="450" y="370" font-family="Inter, system-ui, Arial, sans-serif" font-size="36" font-weight="400" fill="#94A3B8">Full-stack architectural identity</text>
</svg>
'@
Write-File (Join-Path $brandingRoot "triadstack\open-graph.svg") $tsOpenGraph

$tsFavicon = @'
<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" role="img">
  <title>TriadStack favicon</title>
  <rect x="22" y="22" width="32" height="32" rx="6" fill="#3B82F6"/>
  <rect x="18" y="18" width="32" height="32" rx="6" fill="#10B981"/>
  <rect x="14" y="14" width="32" height="32" rx="6" fill="#7C3AED"/>
</svg>
'@
Write-File (Join-Path $brandingRoot "triadstack\favicon.svg") $tsFavicon

# ============================================================================
# Remove now-orphan files at branding root
# ============================================================================
Step "Removing orphan files at branding root"

$orphans = @(
    "favicon.svg",
    "logo-horizontal-dark.svg",
    "logo-horizontal.svg",
    "logo-mark.svg",
    "logo-mono-purple.svg",
    "logo-mono-white.svg",
    "logo-square.svg",
    "open-graph.svg"
)
foreach ($f in $orphans) {
    Remove-IfExists (Join-Path $brandingRoot $f) "orphan $f at branding root"
}

# ============================================================================
# Final report
# ============================================================================
Step "Final state"
if ($Apply) {
    Write-Host ""
    Write-Host "KTS-0000004 brand split applied at:" -ForegroundColor Green
    Write-Host "  $brandingRoot"
    Write-Host ""
    Write-Host "Top-level branding tree:" -ForegroundColor Cyan
    Get-ChildItem -Path $brandingRoot | Sort-Object Name | ForEach-Object {
        $marker = if ($_.PSIsContainer) { "DIR " } else { "FILE" }
        Write-Host "  $marker $($_.Name)"
    }
    Write-Host ""
    Write-Host "Next:" -ForegroundColor Cyan
    Write-Host "  1. git add 02_Responses\gemini\ 05_Wiki\branding\"
    Write-Host "  2. git status (review)"
    Write-Host "  3. git commit -m `"KTS-0000004: brand split, accessibility tokens, three viewing modes`""
    Write-Host "  4. git push"
    Write-Host ""
    Write-Host "Heads up:" -ForegroundColor Yellow
    Write-Host "  wire-angular-branding.ps1 still references the old flat branding/ layout."
    Write-Host "  When applying TriadStack to an Angular project, the source path needs to"
    Write-Host "  point at 05_Wiki\branding\triadstack\ rather than 05_Wiki\branding\."
    Write-Host "  KTS-0000005 will update that script."
} else {
    Write-Host ""
    Write-Host "DRY RUN COMPLETE. Re-run with -Apply to mutate." -ForegroundColor Yellow
    Write-Host "Suggested: .\split-branding-kts0000004.ps1 -Apply"
}
