# KT - BRAND-healthcare-client-XYZ Knowledge Transfer Vault

**Root path (Windows):** `C:\<machine-namespace>\KT\clinical\Readiness\`
This machine: `C:\<work-laptop-hostname>\KT\clinical\Readiness\`

**Owner:** John Green
**Purpose:** Stack-translation effort for BRAND-healthcare-client-XYZ engagement (.NET to Java/Spring Boot/JSP/MongoDB/AWS/Angular). Distinct from BRAND-engagement-codename-XYZ (BRAND-healthcare-bpo-XYZ/BRAND-consulting-firm-XYZ). The `<machine-namespace>` prefix is John's machine-disambiguation classification (so synced files are traceable to their origin machine). It is NOT a corporate-policy boundary. Both work and personal laptops are under John's chain of custody.

## Folder Map

| Folder | Purpose | Write rules |
|---|---|---|
| `00_Inbox` | Raw drops: original prompts, screenshots, transcripts, attachments | Never edit; archive only |
| `01_Prompts/_shared` | Master prompts intended for ANY AI tool | Versioned by date plus saga ID |
| `01_Prompts/claude` | Prompts sent specifically to Claude | One file per turn |
| `01_Prompts/gemini` | Prompts sent specifically to Gemini | One file per turn |
| `02_Responses/claude` | Claude responses, paired by saga ID | One file per turn |
| `02_Responses/gemini` | Gemini responses, paired by saga ID | One file per turn |
| `03_Synthesis` | Reconciled outputs across tools, decisions, deltas | Author: human (you) |
| `04_Applications` | Code projects (sub-folder per app, each becomes a Git repo) | Each app self-contained |
| `05_Wiki` | Persistent durable knowledge: taxonomy, mappings, glossary | Living docs |
| `06_Status` | Living state: STATUS.md, HISTORY.md, OBJECTIVES.md | Always read first by any AI agent |
| `07_RAG` | Local AI knowledge base: corpus, embeddings, ingest pipeline | Auto-maintained by ingest script |
| `08_HW` | Hardware decisions for THIS workstation build (HW-BLD-002, distinct from BRAND-engagement-codename-XYZ HW-BLD-001) | Versioned |
| `99_Archive` | Superseded artifacts: never deleted | Move-only |

## Source-of-Truth Rule

- Primary writes: personal computer's vault.
- Mirror (read-only, sync via Git pull): work laptop's vault.
- Sync mechanism: private Git remote (GitHub private repo or self-hosted). NOT OneDrive or Dropbox.

## Saga Numbering

Format: KT-{BAND}-{7-digit}. Bands: PRMPT, RESP, SYN, APP, HW, WIKI. Saga groupings: KTS-{7-digit}. Filenames carry the saga ID so prompt, response, and synthesis are obvious to glob.

## How a Future AI Agent Bootstraps Itself

1. Read 06_Status/STATUS.md for current state.
2. Read 06_Status/OBJECTIVES.md for what is next.
3. Tail 06_Status/HISTORY.md for recent decisions.
4. Query 07_RAG/ for topic-specific context.
5. Before any new work, append to HISTORY.md and update STATUS.md.