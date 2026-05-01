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