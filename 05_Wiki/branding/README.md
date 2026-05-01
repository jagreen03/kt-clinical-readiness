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