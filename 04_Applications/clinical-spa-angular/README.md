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