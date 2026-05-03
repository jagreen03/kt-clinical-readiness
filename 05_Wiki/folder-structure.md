# Folder Structure

**Status:** stable as of `KTS-0000001`. Changes require a synthesis doc and a `HISTORY.md` entry.

## Why numbered prefixes

Mirrors your `C:\BRAND-engagement-codename-XYZ` Obsidian convention. Numbered prefixes give deterministic sort order in any file explorer and are tool-agnostic (Windows Explorer, Obsidian, VS Code, `ls`). The numbers don't imply workflow phases — they imply visual priority.

## Why split `_shared` from tool-specific subfolders

Most prompts are tool-agnostic — the master prompts you wrote for Claude and Gemini overlap ~80%. `_shared/` holds the reusable masters; `claude/` and `gemini/` hold the genuine tool-specific deltas (e.g., a Claude prompt that leans on long-context reasoning, or a Gemini prompt that leans on tool-use). This keeps the masters greppable without duplication.

## Why `03_Synthesis` is a first-class folder

The synthesis is the artifact that survives. Individual responses from Claude and Gemini are inputs; the synthesis is your engineering judgment, written in your voice. Interviewers, future you, and your RAG should weight synthesis docs highest. It deserves its own tier, not a `notes/` subfolder.

## Why `04_Applications` is separate from `05_Wiki`

Applications are code with their own Git history once they mature — they will eventually leave this vault. The wiki is the durable knowledge that stays. Keeping them separate prevents the wiki from drifting into stale code commentary.

## Why `06_Status` is at tier 6 not tier 0

Counterintuitive, but deliberate. Tier 0 (`00_Inbox`) is rawest; tier 99 (`99_Archive`) is most processed. Status sits in the middle because it's a continuous reflection of work-in-flight — neither raw input nor archived output. Putting it at tier 0 would tempt agents to read inbox before status; putting it at tier 99 would imply it's complete. The middle is correct.

## Why `07_RAG` is in-vault, not external

The corpus IS the vault. Putting embeddings outside the vault creates a synchronization problem you do not need. SQLite vector DBs are single-file and trivially portable; they belong with the data they index. Add `07_RAG/embeddings/*.db` to `.gitignore` if you don't want vector blobs in version control — but the corpus and manifest are committed.

## Why `08_HW` exists for this track

BRAND-engagement-codename-XYZ has its own hardware build registry (`HW-BLD-001`, the EPYC Milan workstation). This track is a different machine with different constraints (CUDA-first, single-GPU, $6K budget vs BRAND-engagement-codename-XYZ's dual-GPU). Keeping the build registries separate prevents cross-contamination of decisions.

## What does NOT go in this vault

- BRAND-healthcare-bpo-XYZ / BRAND-engagement-codename-XYZ materials. Those live at `C:\BRAND-engagement-codename-XYZ\`.
- Personal estate / family materials.
- Anything client-confidential without explicit authorization to local-store.
- Generated AI output that you didn't deliberately keep — let `99_Archive/` handle "kept but superseded"; just don't keep noise in the first place.
