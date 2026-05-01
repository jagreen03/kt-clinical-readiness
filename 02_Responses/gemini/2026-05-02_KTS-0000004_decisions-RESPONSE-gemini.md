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