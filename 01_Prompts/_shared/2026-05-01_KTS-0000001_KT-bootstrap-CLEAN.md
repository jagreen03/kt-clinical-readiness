# KTS-0000001 — Bootstrap Prompt (Cleaned)

**Saga:** KTS-0000001
**Date:** 2026-05-01
**Tool-agnostic:** yes — usable verbatim with Claude, Gemini, or any future model
**Tone:** senior-to-senior, dense, copy-paste ready

---

## Context

I am a Senior Software Engineer (.NET / C# / SQL Server / healthcare / OWASP, ~20 yrs). I am preparing for an BRAND-healthcare-client-XYZ **Clinical** engagement (target stack: Java, Spring Boot, JSP, MongoDB, AWS, React/Angular). This is a stack translation, not a junior on-ramp. I am separately the technical lead on BRAND-engagement-codename-XYZ (BRAND-healthcare-bpo-XYZ, BRAND-consulting-firm-XYZ); the Clinical effort is a parallel track.

I want to operate this prep work as a self-documenting vault on my workstation at `C:\RAW\KT\`, with the goal that any future AI tool can pick up the work by reading status files on disk.

## What I want from you

Deliver six things:

1. **Folder/vault layout** under `C:\RAW\KT\` that supports: an inbox for raw drops, prompts paired with responses by saga ID, a wiki, an applications area for code, a status/history layer, a RAG corpus, and a hardware planning area.
2. **A saga-numbering convention** so prompts, responses, syntheses, applications, hardware decisions, and wiki entries are all greppable.
3. **A status protocol** — three living files (`STATUS.md`, `HISTORY.md`, `OBJECTIVES.md`) that future AI agents read first and write last.
4. **A local RAG approach** that runs on my current laptop (16GB RAM, i7, 6GB GPU) until new hardware arrives — and migrates cleanly to the new box.
5. **Hardware recommendations** for a $6K-budget local-AI workstation. **One line per option, no exposition.** I have already considered Mac Mini, Xeon workstation, and mid-tier Threadripper (4-channel DDR5). I want to avoid top-end Threadripper PRO. Note any anti-recommendations.
6. **A read of my GitHub** at `https://github.com/jagreen03` to feed into JSP / Java backend / Angular OAuth 2.0 expansion plans for this weekend's push. If the profile is unreachable, list the artifacts you would expect to see and what I should bring in.

## Constraints

- One file per turn for prompt and response; saga ID in every filename.
- All filenames lowercased to one convention (`YYYY-MM-DD_KTS-NNNNNNN_short-slug.md`).
- Tool-agnostic naming where possible; tool-specific subfolders (`claude/`, `gemini/`) only where the prompt is truly tool-tuned.
- Status files use stable headers so a regex/grep can find current state without parsing prose.
- No motivational language, no preamble, no "you got this" wrap-ups.

## Deliverables on disk

This prompt lives at `01_Prompts/_shared/2026-05-01_KTS-0000001_KT-bootstrap-CLEAN.md`.
The raw version lives at `00_Inbox/2026-05-01_KTS-0000001_bootstrap-prompt-RAW.md`.
The response should land at `02_Responses/{tool}/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE.md`.
Once two tools have responded, I author the synthesis at `03_Synthesis/2026-05-01_KTS-0000001_KT-bootstrap-SYN.md`.
