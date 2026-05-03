# HISTORY (append-only)

> Append-only chronological log. Newest at the bottom. Each entry: ISO timestamp, saga ID, one-line summary, paths touched.
>
> AI agents: never edit prior entries. Append only.

---

## 2026-05-01T15:30Z - KTS-0000001 - Bootstrap

KT vault skeleton authored by Claude (Opus 4.7). Folder tree created under <machine-ns>\KT\clinical\Readiness\. Saga numbering convention adopted: KT-{BAND}-{7-digit} for atomic artifacts, KTS-{7-digit} for groupings. Status protocol established: STATUS.md (overwrite), HISTORY.md (append), OBJECTIVES.md (queue).

Artifacts written: README.md, 00_Inbox/bootstrap-prompt-RAW.md, 01_Prompts/_shared/{KT-bootstrap-CLEAN, MASTER_PROMPT_for_CLAUDE, MASTER_PROMPT_for_GEMINI}.md, 02_Responses/claude/KT-bootstrap-RESPONSE.md, 05_Wiki/{folder-structure, saga-numbering, stack-map-dotnet-to-java}.md, 06_Status/{STATUS, HISTORY, OBJECTIVES}.md, 07_RAG/README.md, 07_RAG/pipeline/ingest.py.draft, 08_HW/HW-BLD-002_KT-workstation.md.

Gaps logged for next turn: GitHub fetch of jagreen03 failed (Claude tool restriction); three BRAND-healthcare-client-XYZ Office attachments did not transfer.

## 2026-05-01T17:00Z - KTS-0000001 - Gemini response received, synthesis seeded

Gemini 3.1 Pro response received via paste. Saved verbatim to 02_Responses/gemini/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE-gemini.md.

Gemini's procedural critique acknowledged: disk state messy (flat files, master prompt dupes, orphan mnt tree); cleanup needed. Office files visible on disk but never made it into a tool's context: owed for KTS-0000002. gh repo list jagreen03 workaround correct: owed for KTS-0000002.

Gemini's overreach corrected: path normalization to C:\RAW\KT\ would have destroyed John's <machine-ns>\KT\<track>\<phase>\ classification: kept original. "Delete 08_HW from this machine" rejected: both machines under John's chain of custody, source-of-truth = personal computer. "Skip JPA" softened to "JPA read-deep-enough-to-defend." "Avoid JSP view logic" rejected: contradicts master prompt's actual ask.

Gemini's omissions logged for KTS-0000002: LinkedIn Learning courses (6 stack areas); GitHub project ideas with .NET-mapping rationale; interview talking points.

## 2026-05-01T17:30Z - KTS-0000001 - Disk consolidated via single PowerShell script

Single-script approach replaced multi-zip downloads going forward. _scripts/consolidate-vault.ps1 ran: backed up Readiness to Readiness.bak.<ts>, extracted turn-1 zip, wrote turn-2 content via embedded here-strings, moved Office files to 00_Inbox, removed duplicate master prompts at Readiness root, removed Files_* folders and orphan mnt trees. Idempotent: can re-run safely.

Convention going forward: one PS1 per turn. No zips. No individual file downloads. The script is the deliverable; running it brings the vault to the desired state. ASCII-only content to avoid Windows PowerShell 5.x ANSI/UTF-8 mismatch.

Next: John edits and signs the synthesis, runs git init plus remote, opens KTS-0000002.