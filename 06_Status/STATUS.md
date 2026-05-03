# STATUS

> Stable headers: do not rename. Future AI agents grep these by exact match.
> Overwrite this file on each meaningful update; full history lives in HISTORY.md.

## Active Saga

KTS-0000001: KT vault bootstrap. Both Claude and Gemini responses are in. Synthesis seed authored, pending John's sign-off and disk cleanup. Closes when sign-off checklist in 03_Synthesis/2026-05-01_KTS-0000001_KT-bootstrap-SYN.md is fully checked.

Next saga: KTS-0000002: fulfill the actual master-prompt deliverables (LinkedIn Learning courses, GitHub project ideas, interview talking points), grounded in the three Elevance Office files and the gh repo list jagreen03 output that Gemini also flagged were missing.

## Current Stack Position

- Source stack: .NET 9 / C# / SQL Server / ASP.NET Core / Kubernetes (proficient).
- Target stack: Java 21+, Spring Boot 3.x, JSP (Servlet 6 / Jakarta EE), MongoDB, AWS, Angular.
- Engagement: Elevance Health Clinical (parallel to Project ODIN/Carelon).
- Stack-translation priorities (per synthesis):
  - Spring Security 6 plus OAuth 2.0 client plus PKCE: primary.
  - Spring Data MongoDB: primary; JPA read-deep-enough-to-defend, not skipped entirely.
  - JSP: minimal but real working sample required, paired with Thymeleaf comparison.

## Vault Path Convention

Vault root: C:\<machine-namespace>\KT\clinical\Readiness\
This machine (work laptop, work-from-home setup): C:\<work-laptop-hostname>\KT\clinical\Readiness\
Personal computer (source-of-truth, where the workstation lives): namespace TBD on first commit.

## Source-of-Truth Rule

- Primary writes: personal computer's vault.
- Mirror (read-only, sync via Git pull): work laptop's vault.
- Sync mechanism: private Git remote (GitHub private repo or self-hosted). NOT OneDrive or Dropbox.

## Open Questions

- Personal computer's machine-namespace string (decide on first commit on personal box).
- Three Elevance Office files: visible on disk in 00_Inbox post-cleanup; content not yet ingested into a Claude/Gemini turn. Extract text and tables and bundle into KTS-0000002 prompt.
- GitHub handle: gh repo list jagreen03 --limit 10 output needed in KTS-0000002 prompt to bypass HTTP fetch restriction.
- Private vs public Git repo for the vault: lean private; public repos for individual 04_Applications/* projects only when ready.

## Hardware State

- Current dev box (this turn): Work laptop, 16GB RAM, i7, 6GB GPU. Adequate for KT-scale RAG with Llama 3.1 8B Q4 plus nomic-embed-text once Ollama is set up; but Ollama install plus actual self-study development belongs on personal computer per source-of-truth rule.
- Build registry: 08_HW/HW-BLD-002_KT-workstation.md: canonical, lives in vault, mirrored to both machines, but procurement happens from personal computer.
- Current pick: Threadripper 7960X (24c) plus TRX50 plus 4x32GB DDR5 ECC plus RTX 5090 32GB GDDR7 plus 4TB NVMe, ~$5.9K. Pending order.

## RAG State

- Corpus path: 07_RAG/corpus/ (empty).
- Vector DB path: 07_RAG/embeddings/kt.db (not yet created).
- Manifest: 07_RAG/manifest.jsonl (not yet created).
- Pipeline: sketch only at 07_RAG/pipeline/ingest.py.draft: not runnable.
- Embedding model: nomic-embed-text via Ollama (planned, on personal computer).
- Generator model: Llama 3.1 8B Q4 on personal computer laptop tier; Llama 3.3 70B Q4 once new HW lands.

## Last Update

2026-05-01: Disk consolidation script run; messy Files_* folders removed; turn-1 zip extracted; turn-2 content (gemini response, synthesis seed, status updates) written; Office files migrated to 00_Inbox. Path convention corrected to <machine-ns>\KT\clinical\Readiness.