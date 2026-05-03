# KTS-0000001 — Bootstrap Response (Claude)

**Saga:** KTS-0000001
**Date:** 2026-05-01
**Tool:** Claude (Opus 4.7)
**Pairs with:** `01_Prompts/_shared/2026-05-01_KTS-0000001_KT-bootstrap-CLEAN.md`
**Author convention:** AI-Architect (per AI Ledger System)

---

## 1. Folder layout (delivered on disk)

```
C:\RAW\KT\
├── README.md                  (orientation; how a future agent bootstraps)
├── 00_Inbox\                  (raw drops — never edit)
├── 01_Prompts\
│   ├── _shared\               (tool-agnostic master prompts)
│   ├── claude\                (Claude-specific prompts)
│   └── gemini\                (Gemini-specific prompts)
├── 02_Responses\
│   ├── claude\
│   └── gemini\
├── 03_Synthesis\              (you author after multi-tool responses)
├── 04_Applications\           (one sub-folder per app; each becomes a Git repo)
├── 05_Wiki\                   (durable knowledge: stack maps, glossary, conventions)
├── 06_Status\                 (STATUS.md, HISTORY.md, OBJECTIVES.md)
├── 07_RAG\                    (corpus, embeddings, ingest pipeline)
├── 08_HW\                     (workstation build registry)
└── 99_Archive\                (move-only, never delete)
```

Why this shape: it mirrors your existing `C:\BRAND-engagement-codename-XYZ` Obsidian conventions (numbered tier prefixes, inbox-first, archive-last) and adds explicit `claude/` vs `gemini/` subfolders so parallel-tool consultation produces clean, comparable artifacts. The `03_Synthesis/` step is the human-authored merge — that step is what an interviewer would actually see, and what your RAG should weight highest at retrieval time.

## 2. Saga numbering

Format: `KT-{BAND}-{7-digit}` for atomic artifacts; `KTS-{7-digit}` for groupings.

| Band | Use |
|---|---|
| `PRMPT` | Individual prompts |
| `RESP` | Individual responses |
| `SYN` | Synthesis docs |
| `APP` | Application milestones (commit-pinned) |
| `HW` | Hardware decisions (HW-BLD-002 lives here) |
| `WIKI` | Wiki entries when stable enough to assign IDs |

Filename convention: `YYYY-MM-DD_KTS-NNNNNNN_short-slug.md`. The saga ID (`KTS-...`) lets you `glob` everything for one turn across folders. Individual band IDs (`KT-PRMPT-...`) live in front-matter when an artifact needs its own identity (e.g. wiki entries, application releases). This turn = `KTS-0000001`.

## 3. Status protocol

Three files in `06_Status/`:

- **`STATUS.md`** — current snapshot, **overwritten** on update. Has stable headers (`## Active Saga`, `## Current Stack Position`, `## Open Questions`, `## Hardware State`, `## Last Update`). Future AI greps these headers deterministically.
- **`HISTORY.md`** — append-only chronological log. Each entry: timestamp, saga ID, one-line summary, link to artifact paths.
- **`OBJECTIVES.md`** — forward queue. Bulleted, dated, with priority. Items move to `HISTORY.md` on completion.

Bootstrap convention for any new AI agent: `cat 06_Status/STATUS.md 06_Status/OBJECTIVES.md && tail -50 06_Status/HISTORY.md`. Three files, full state.

## 4. Local RAG (for the laptop, until new HW arrives)

Your laptop (16GB RAM / 6GB VRAM) can host a credible KT-scale RAG. The corpus will be small (master prompts, responses, syntheses, course notes, code snippets) — well under 10K chunks. Build with portable pieces so migration to the new workstation is just a directory copy.

**Stack (one-liners):**
- **Embedding model:** `nomic-embed-text` via Ollama (768-dim, runs on 6GB GPU comfortably; or BGE-small on CPU as fallback)
- **Vector store:** `sqlite-vec` extension — single-file DB, lives at `07_RAG/embeddings/kt.db`, trivial to back up and migrate
- **Chunker:** markdown-aware splitter (split on `##` headings, fallback to 800-token chunks with 100-token overlap)
- **Generator:** `Phi-4 14B Q4_K_M` (~9GB on disk, tight on 6GB VRAM with offload) or `Llama 3.1 8B Q4` (fits comfortably) — both via Ollama
- **Pipeline runner:** Python script `07_RAG/pipeline/ingest.py` that watches `00_Inbox/`, `01_Prompts/`, `02_Responses/`, `03_Synthesis/`, `05_Wiki/`; computes content hash; skips unchanged; writes a JSONL manifest for audit (mirrors your Cyclopter audit-log pattern)
- **Query:** `07_RAG/pipeline/query.py "your question"` returns top-K chunks + LLM answer + source paths

The ingest script needs a manifest: `07_RAG/manifest.jsonl` — append-only, hash-chained, `{saga_id, source_path, chunk_id, sha256, embedded_at}`. This is the audit lineage so you always know which response your RAG is grounding on.

When new HW arrives: same code, swap Ollama target to a 70B-class model (Llama 3.3 70B, Qwen 2.5 72B), bump embedding model to BGE-large, raise chunk top-K. No schema change.

I dropped a draft `ingest.py` skeleton at `07_RAG/pipeline/ingest.py.draft` — it is a sketch with the structure and dependencies called out, not runnable. Treat it as a starting commit.

## 5. Hardware — one line per option

Budget: $6K. Workload: KT RAG today, 70B-class inference and Java/Spring + Angular dev tomorrow. Excludes monitor/peripherals.

- **Mac Mini M4 Pro 64GB** (~$2.4K) — MLX inference is real, but no CUDA cuts you off from the PyTorch/HF ecosystem you'll need for evals; leaves $3.6K stranded.
- **Mac Studio M4 Max 128GB** (~$4.7K) — best raw inference-per-dollar for 70B via MLX, but locks you out of CUDA tooling and adds an OS context-switch you don't need; **anti-recommend given your tooling history**.
- **AM5 Ryzen 9950X + RTX PRO 4500 Blackwell 32GB + 2×32GB DDR5 + 2TB NVMe** (~$4.5K) — your published Path D from the RDIMM Tax paper; only 2 memory channels though, which contradicts your 4-channel intuition.
- **Threadripper 7960X (24c) + ASUS Pro WS TRX50-SAGE WIFI + 4×32GB DDR5 ECC + RTX 5090 32GB GDDR7 + Samsung 990 Pro 4TB** (~$5.9K) — **top pick**; your stated 4-channel intuition is correct, full CUDA, 128GB ECC, RTX 5090 lands you native 70B Q4 inference today; same workstation hosts Java + Angular dev cleanly.
- **Threadripper PRO 7965WX + WRX90** ($8K+ before GPU) — 8 channels but blows budget; **anti-recommend per your stated constraint**.
- **Xeon W7-2495X (24c) + ASUS Pro WS W790-ACE + 8×16GB DDR5 ECC + RTX 5090** (~$6.5K) — 8-channel ECC if you really want it, but Xeon-W premium pushes you 8% over budget for marginal gain over TR 7960X for your workload; **second choice**.
- **Used EPYC 7543 + H12SSL-CT + dual RTX PRO 4500 Blackwell** (~$5K, your existing BRAND-engagement-codename-XYZ spec) — earmarked for BRAND-engagement-codename-XYZ; **anti-recommend mixing tracks**.

**Call:** Threadripper 7960X build. Reasoning lives at `08_HW/HW-BLD-002_KT-workstation.md`.

## 6. GitHub read

Direct fetch of `https://github.com/jagreen03` failed (HTTP error from my fetch tool — likely fetch-tool restriction, not a profile issue), and search did not surface the handle either. I cannot deliver the expansion-plan read this turn.

**What I'd expect to see and would map against:**
- A `BlueSand.RiverHorse.Gateway` repo or similar — your .NET 9 ASP.NET Core MVC BFF with Google OAuth 2.0 + PKCE. The Java/Spring translation target is a Spring Boot BFF using Spring Authorization Server (or Keycloak) + WebClient + an Angular SPA on the front. This is the natural OAuth 2.0 expansion.
- An BRAND-engagement-codename-XYZ P0 stack repo or `OdinP0Stack.cs`-equivalent.
- An OpenLocate / AudioJeller artifact set.
- Any JSP scaffolding (which I'd guess is not yet present — JSP is the new-stack item, not a legacy you carry).

**Action:** add to `06_Status/OBJECTIVES.md`:
- Confirm GitHub username spelling (`jagreen03` vs `jgreen03` vs other) and whether the profile is public.
- On next turn, paste a `gh repo list` output or screenshot, or grant me a specific repo URL to fetch.

## 7. What you should do this weekend (push order)

This is a recommendation, not a deliverable — drop or reorder freely.

1. **Saturday morning.** Drop the contents of `/mnt/user-data/outputs/KT/` into `C:\RAW\KT\`. Initialize Git (`git init`, gitignore `07_RAG/embeddings/`, `99_Archive/` if you want).
2. **Saturday midday.** Take this exact response file to Gemini using the master Gemini prompt. Save Gemini's response at `02_Responses/gemini/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE-gemini.md`.
3. **Saturday afternoon.** Author `03_Synthesis/2026-05-01_KTS-0000001_KT-bootstrap-SYN.md` — your reconciled call on layout, saga scheme, hardware, RAG.
4. **Saturday evening.** Stand up Ollama + sqlite-vec + the ingest sketch. Smoke-test by ingesting just `01_Prompts/` and `02_Responses/` and querying against them.
5. **Sunday.** Order the workstation parts. Open the LinkedIn Learning courses Gemini surfaces, queue the Spring Boot one to start Monday. Scaffold the first GitHub repo (Spring Boot REST + MongoDB skeleton) and commit empty.
6. **Logging.** Every time you finish a step, append one line to `HISTORY.md` and update `STATUS.md`. The whole point of the vault is that a future you (or future AI) can rejoin without re-reading chats.

## Known gaps

- The three Office attachments (`BRAND-healthcare-client-XYZ_Clinical_KT_Activity.docx`, `..._Preparation.pptx`, `..._TechStack_Activity.xlsx`) did not transfer — re-upload next turn so I can incorporate the official BRAND-healthcare-bpo-XYZ-vs-BRAND-healthcare-client-XYZ stack delta and any required course list.
- GitHub fetch did not resolve — provide a working URL or paste contents next turn.
- LinkedIn Learning course recommendations and GitHub project plans are deferred to the **second saga (KTS-0000002)** — that's where the master prompts (Claude/Gemini) get used in earnest, after the vault is on disk.
