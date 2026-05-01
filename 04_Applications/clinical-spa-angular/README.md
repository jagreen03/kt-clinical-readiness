# TriadStack SPA - Angular wiring kit

This folder is a WIRING KIT, not a runnable Angular project. Three more steps turn it into a working app.

## Step 1: Install Node.js and Angular CLI

If not already installed:
- Node.js 20 LTS or newer: https://nodejs.org
- Angular CLI: npm install -g @angular/cli

## Step 2: Bootstrap a fresh Angular project IN THIS FOLDER

From this folder:

  ng new triadstack-spa --routing=true --style=scss --standalone=true --skip-git=true --directory=.

When prompted:
- Server-Side Rendering: No
- Static Site Generation: No

## Step 3: Re-apply the wiring

ng new will overwrite some files this script wrote. Re-run this script to restore them:

  C:\ICS-LT-FYXFHG4\KT\clinical\Readiness\_scripts\wire-triadstack-kts0000005.ps1 -Apply

## Step 4: Run

  npm start

Open http://localhost:4200. The TriadStack header (mark plus wordmark on dark background) shows three nav links. Routed empty content area below.

## What this kit wires

- src/styles.scss: imports brand-tokens, baseline body, .kt-button-primary utility, accessibility-aware focus states.
- src/index.html: favicon, Open Graph meta, theme color.
- src/app/app.component.ts and .html: standalone root component with header + router outlet.
- src/app/shared/header/header.component.{ts,html,scss}: TriadStack toolbar, dark background, brand colors paired with hover states.
- src/assets/branding/: brand-tokens (CSS, SCSS, JSON), PGB.md doctrine, TriadStack logos and favicon.

## Tip: shorten brand-tokens import paths

After ng new, edit angular.json and add to your build target:

  "stylePreprocessorOptions": {
    "includePaths": ["src/assets/branding"]
  }

Then any component scss can do:

  @import "brand-tokens";

instead of long relative paths.

## Brand colors

- Purple #7C3AED (front layer, primary actions, unexpected/usable content)
- Green #10B981 (middle layer, hover and success, delivered as specified)
- Blue #3B82F6 (back layer, secondary, exceptional quality)

PGB doctrine in src/assets/branding/PGB.md.

## Three viewing modes (auto and manual)

brand-tokens.css ships with light, dark, and high-contrast modes. Resolution order:

1. Manual: html element data-theme attribute. Set "light", "dark", or "high-contrast".
2. Auto: prefers-contrast: more then prefers-color-scheme: dark.
3. Default: light.

A user-facing toggle should set data-theme on the html element to guarantee AAA-tier access regardless of OS configuration.