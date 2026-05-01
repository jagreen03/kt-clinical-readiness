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