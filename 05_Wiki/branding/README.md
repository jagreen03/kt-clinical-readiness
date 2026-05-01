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