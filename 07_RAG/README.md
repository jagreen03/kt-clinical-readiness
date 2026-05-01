# Local RAG — `07_RAG`

**Purpose:** A local-first, vendor-agnostic knowledge base over the contents of `C:\RAW\KT\`. Future AI agents (Claude, Gemini, local models, whatever comes next) can use this RAG to answer questions about your prep work without you having to re-paste context.

## Components

| Piece | Tool | Path |
|---|---|---|
| Embedding model | Ollama: `nomic-embed-text` (768-dim) | local Ollama server |
| Vector store | `sqlite-vec` extension on SQLite | `07_RAG/embeddings/kt.db` |
| Generator | Ollama: `llama3.1:8b-instruct-q4_K_M` (laptop) or `llama3.3:70b-instruct-q4_K_M` (workstation) | local Ollama server |
| Ingest pipeline | Python script | `07_RAG/pipeline/ingest.py` (currently `.draft`) |
| Query interface | Python script | `07_RAG/pipeline/query.py` (TBD) |
| Audit manifest | JSONL append-only, hash-chained | `07_RAG/manifest.jsonl` |

## Watched paths

The ingest pipeline watches and indexes:

- `00_Inbox/` — raw prompts (good as ground truth for "what did I actually ask")
- `01_Prompts/` — cleaned/master prompts (good as patterns)
- `02_Responses/` — AI responses (lots of content, weight by tool quality)
- `03_Synthesis/` — your reconciled judgment (highest weight)
- `05_Wiki/` — durable knowledge (highest weight, never stale)
- `06_Status/` — current state (cite at the top of every retrieval)

It does NOT index:
- `04_Applications/` — code is better served by direct Git/grep
- `07_RAG/` itself — would create a feedback loop
- `08_HW/` — small enough to read directly
- `99_Archive/` — by definition superseded; if you need it, you're spelunking, not querying

## Chunking strategy

- Markdown-aware: split on `##` headings first, then `###`, then fall back to ~800-token chunks with 100-token overlap.
- Preserve front-matter (saga ID, date, tool) as metadata on every chunk.
- Strip raw verbatim user prompts down to the structural prompt (don't embed extremely long pasted artifacts as one chunk).

## Why sqlite-vec, not Chroma / LanceDB / pgvector

- Single file, lives next to the corpus.
- Trivially backed up (it's a `.db`).
- Migrates by `cp` to the new workstation.
- No server process to manage on your laptop.
- Works fine up to ~100K chunks, well past KT scale.

If the corpus ever grows past where sqlite-vec is comfortable, swap to LanceDB — the chunk schema and embedding format don't change, only the storage layer.

## Migration to new workstation

When the Threadripper build comes online:

1. `rsync` (or robocopy) the entire `C:\RAW\KT\` to the new box.
2. Install Ollama on the new box; `ollama pull nomic-embed-text llama3.3:70b-instruct-q4_K_M`.
3. Update `07_RAG/pipeline/config.yml` (proposed) to point at the new Ollama instance and bump generator model.
4. Re-run `ingest.py --rebuild` if you want fresh embeddings under the new model. (Otherwise the existing 8B-era embeddings remain valid since you're not changing embedding model.)

## What this RAG is NOT

- Not a chat replacement. You will still talk to Claude and Gemini for new reasoning. RAG is the memory layer behind those conversations.
- Not a search engine. It's optimized for "summarize what I decided" and "what did I conclude about X" — not exact-match lookup.
- Not a code search tool. For code, use `ripgrep` against `04_Applications/`.
