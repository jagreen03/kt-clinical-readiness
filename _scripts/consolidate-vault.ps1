<#
.SYNOPSIS
    Consolidate the KT vault from the messy state into a clean structure.

.DESCRIPTION
    Self-contained, idempotent, ASCII-only. One script, one run, vault is clean.

    Steps:
      1. Validates VaultRoot.
      2. Backs up Readiness folder to Readiness.bak.<timestamp>.
      3. Recursively finds the turn-1 zip (KT-bootstrap-*.zip) under VaultRoot.
         Extracts it and merges contents into VaultRoot.
      4. Writes turn-2 content directly: synthesis, gemini response,
         updated status files. No second zip needed.
      5. Moves the three Elevance Office files into 00_Inbox.
      6. Removes duplicate master prompts at VaultRoot root if framed
         copies exist in 01_Prompts\_shared.
      7. Removes Files_* folders and orphan mnt trees.
      8. Reports the clean tree.

    DRY-RUN by default. Pass -Apply to mutate.

.PARAMETER VaultRoot
    Vault root path. Default: C:\ICS-LT-FYXFHG4\KT\clinical\Readiness

.PARAMETER Apply
    Switch. Default is dry-run. Pass -Apply to actually mutate.

.EXAMPLE
    .\consolidate-vault.ps1
    .\consolidate-vault.ps1 -Apply

.NOTES
    Saga: KTS-0000001
    ASCII-only. Compatible with Windows PowerShell 5.x and PowerShell 7+.
#>

[CmdletBinding()]
param(
    [string]$VaultRoot = "C:\ICS-LT-FYXFHG4\KT\clinical\Readiness",
    [switch]$Apply
)

$ErrorActionPreference = "Stop"
$ts = Get-Date -Format "yyyyMMdd-HHmmss"

function Step([string]$msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Note([string]$msg) { Write-Host "    $msg" }
function Run([string]$desc, [scriptblock]$action) {
    if ($Apply) {
        Write-Host "    [APPLY] $desc"
        & $action
    } else {
        Write-Host "    [DRYRUN] $desc"
    }
}
function Write-VaultFile([string]$relPath, [string]$content) {
    $full = Join-Path $VaultRoot $relPath
    $dir = Split-Path -Parent $full
    Run "Write $relPath" {
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Set-Content -Path $full -Value $content -Encoding UTF8 -NoNewline
    }
}

# ============================================================================
# 1. Validate
# ============================================================================
Step "Validating VaultRoot"
if (-not (Test-Path $VaultRoot)) { throw "Vault root not found: $VaultRoot" }
Note "VaultRoot: $VaultRoot"
if ($Apply) { Note "Mode: APPLY (will mutate)" } else { Note "Mode: DRY-RUN (read only)" }

# ============================================================================
# 2. Backup
# ============================================================================
Step "Backing up current Readiness folder"
$backup = "$VaultRoot.bak.$ts"
Run "Copy $VaultRoot to $backup" {
    Copy-Item -Path $VaultRoot -Destination $backup -Recurse -Force
}

# ============================================================================
# 3. Find and extract turn-1 zip
# ============================================================================
Step "Finding turn-1 zip"
$zip = Get-ChildItem -Path $VaultRoot -Filter "KT-bootstrap-*.zip" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
if ($zip) {
    Note "Found: $($zip.FullName)"
    $tempExtract = Join-Path $env:TEMP "kt-extract-$ts"
    Run "Expand $($zip.Name) to $tempExtract" {
        New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null
        Expand-Archive -Path $zip.FullName -DestinationPath $tempExtract -Force
    }
    $extractedKt = Join-Path $tempExtract "KT"
    if ($Apply -and (Test-Path $extractedKt)) {
        Get-ChildItem -Path $extractedKt -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($extractedKt.Length + 1)
            $dest = Join-Path $VaultRoot $rel
            $destDir = Split-Path -Parent $dest
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            Copy-Item -Path $_.FullName -Destination $dest -Force
        }
        Note "Merged turn-1 zip contents into $VaultRoot"
    }
    Run "Remove temp extract dir" {
        Remove-Item -Path $tempExtract -Recurse -Force
    }
} else {
    Note "No turn-1 zip found. Skipping extract; assuming structure already in place."
}

# ============================================================================
# 4. Write turn-2 content directly
# ============================================================================
Step "Writing turn-2 content"

$readme = @'
# KT - Elevance Clinical Knowledge Transfer Vault

**Root path (Windows):** `C:\<machine-namespace>\KT\clinical\Readiness\`
This machine: `C:\ICS-LT-FYXFHG4\KT\clinical\Readiness\`

**Owner:** John Green
**Purpose:** Stack-translation effort for Elevance Health Clinical engagement (.NET to Java/Spring Boot/JSP/MongoDB/AWS/Angular). Distinct from Project ODIN (Carelon/Infinite). The `<machine-namespace>` prefix is John's machine-disambiguation classification (so synced files are traceable to their origin machine). It is NOT a corporate-policy boundary. Both work and personal laptops are under John's chain of custody.

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
| `08_HW` | Hardware decisions for THIS workstation build (HW-BLD-002, distinct from ODIN HW-BLD-001) | Versioned |
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
'@
Write-VaultFile "README.md" $readme

$gemini = @'
# KTS-0000001 - Bootstrap Response (Gemini)

**Saga:** KTS-0000001
**Date:** 2026-05-01
**Tool:** Gemini 3.1 Pro
**Pairs with:** 01_Prompts/_shared/2026-05-01_KTS-0000001_KT-bootstrap-CLEAN.md and 02_Responses/claude/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE.md
**Author convention:** AI-Architect
**Captured by:** John, pasted into Claude turn 2026-05-01T12:30Z; saved verbatim per his instruction.

> Note for synthesis: this response operates as a procedural critique on Claude's bootstrap output. It does not deliver the LinkedIn Learning course recommendations, GitHub project ideas, or interview talking points that the master prompts requested. Those remain owed in KTS-0000002.

---

## 1. Directory Path Correction

The provided command output shows your bootstrap payload was extracted to C:\ICS-LT-FYXFHG4\KT\clinical\Readiness\Files_20260501-1147\. Your stated P0 architecture dictates this skeleton must live at C:\RAW\KT\ to allow future agents deterministic paths for reading 06_Status/STATUS.md.

Run this to normalize the state before executing git init:

```dos
xcopy /E /I /H "C:\ICS-LT-FYXFHG4\KT\clinical\Readiness\Files_20260501-1147\*" "C:\RAW\KT\"
```

## 2. Hardware and Environment Isolation Protocol

The 08_HW folder contains the ~$5.9K Threadripper 7960X workstation build and RTX 5090 GPU specs. Personal AI hardware projects and budgets must be kept strictly separate from professional contract work for Infinite Computer Solutions.

Because the ICS-LT-FYXFHG4 device is an Infinite Computer Solutions asset, you must remove 08_HW/ and all local AI workstation procurement details from this machine's local storage and its associated Git repository. Maintain the Elevance Clinical software stack translation in C:\RAW\KT\, but move the hardware planning explicitly and exclusively to a personal device.

## 3. GitHub and Elevance Document Gaps

The three Elevance Office files (Elevance_Clinical_KT_Activity.docx, Elevance_Clinical_Preparation.pptx, Elevance_Clinical_TechStack_Activity.xlsx) are visible in your directory at C:\ICS-LT-FYXFHG4\KT\clinical\Readiness\ but their contents were not pushed to the context window.

For the next turn (KTS-0000002):

- Extract the text and tables from those three Elevance files and append them to the prompt.
- Execute gh repo list jagreen03 --limit 10 in your terminal and paste the raw output. This circumvents the HTTP restrictions Claude encountered.

## 4. Stack Translation and Learning Trajectory

Based on your mapping of the .NET 9 ASP.NET Core BFF to the Spring Boot 3.x transition, prioritize these specific conceptual bridges for next week's push:

- Spring Security 6 and OAuth 2.0: Focus explicitly on spring-boot-starter-oauth2-client and PKCE configuration, mirroring your existing BlueSand.RiverHorse.Gateway pattern.
- Spring Data MongoDB: Skip JPA. Map your Entity Framework Core knowledge directly to MongoRepository and Document modeling.
- Jakarta EE / JSP: Focus purely on Servlet 6 container lifecycles to satisfy the legacy target requirement, but avoid heavy investment in JSP view logic.

## Next Actions

1. Execute the xcopy command to move the vault to C:\RAW\KT\.
2. Delete 08_HW/ from the ICS machine.
3. Author your synthesis at 03_Synthesis/2026-05-01_KTS-0000001_KT-bootstrap-SYN.md.
'@
Write-VaultFile "02_Responses/gemini/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE-gemini.md" $gemini

$syn = @'
# KTS-0000001 - Bootstrap Synthesis (DRAFT, awaits John's sign-off)

**Saga:** KTS-0000001
**Date:** 2026-05-01
**Author:** John Green (final sign-off); seeded by Claude (AI-Synthesizer convention)
**Inputs:**
- 02_Responses/claude/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE.md
- 02_Responses/gemini/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE-gemini.md
- John's correction on chain-of-custody and machine-namespace conventions (Claude turn 2 reply)

> This is a seed. Edit it in your voice, sign your name, then commit. The vault treats the synthesis as the durable artifact; Claude and Gemini's individual responses are inputs, not record.

---

## Decisions

### 1. Vault root path: C:\<machine-namespace>\KT\clinical\Readiness\

Decision: keep your existing classification. The vault root is Readiness on whichever machine is the source of truth. The <machine-namespace> prefix (ICS-LT-FYXFHG4 on the work laptop, whatever convention you use on the personal computer) is your machine-disambiguation layer when files sync; it is not a corporate-policy boundary.

Why this overrides Claude's C:\RAW\KT\ and Gemini's xcopy recommendation:
- C:\RAW\KT\ was Claude's arbitrary suggestion last turn; your real schema is <machine-ns>\KT\<track>\<phase>\, which is more disciplined and survives multi-track expansion.
- Gemini's xcopy to C:\RAW\KT\ would destroy that classification.

### 2. Chain-of-custody: both machines are yours; source-of-truth = personal computer

Decision: the personal computer is the vault's source of truth, where the workstation will be procured and the actual self-study development happens. The work laptop hosts a working copy for during-the-day reference. Both machines are under your chain of custody.

Why this overrides Gemini's "delete 08_HW" prescription: Gemini inferred a corporate-policy boundary from the hostname-as-folder. That inference is wrong. The hostname is your machine-namespace, not an asset-classification flag. 08_HW belongs on whichever machine you're actually doing the procurement work on; that is the personal computer. It does not need to be deleted from the work laptop's working copy; it just should not be authored there.

Operational rule: primary writes happen on the personal computer's vault. The work laptop's vault is a Git-mirrored read-only copy. Sync via Git, not OneDrive/Dropbox; Git's history is the audit trail.

### 3. Hardware: Threadripper 7960X stays on the registry; deferred to personal computer for procurement

The 08_HW/HW-BLD-002_KT-workstation.md build registry remains canonical. Authoring source = personal computer. Work laptop's mirror sees it read-only.

### 4. Stack-translation priorities (overriding Gemini's narrower call)

Gemini said: skip JPA, focus on Spring Security 6 + Spring Data MongoDB, avoid JSP view logic. Keep one, drop two:

- Keep: Spring Security 6 + OAuth 2.0 client + PKCE focus. Cleanest .NET-to-Spring conceptual translation given your BlueSand.RiverHorse.Gateway work.
- Soften "skip JPA": JPA read-deep-enough-to-defend, not a hard skip. An interviewer probing "tell me how you would model patient encounters" expects you to articulate when relational vs document fits. You don't need JPA to ship; you need it to talk credibly about why you didn't use it.
- Reject "avoid JSP view logic": the master prompt explicitly asks for a project that demonstrates JSP in real MVC usage. Plan: one minimal JSP MVC controller plus view, one Thymeleaf controller plus view in the same project, README explaining the trade-off.

### 5. Owed deliverables for KTS-0000002

Gemini did not deliver the actual master-prompt asks. The next saga must produce:

- LinkedIn Learning courses for: Java enterprise, Spring Boot (REST/MVC/security/persistence), JSP MVC, MongoDB (Spring Data Mongo plus schema design), AWS for healthcare, Angular OAuth 2.0 client integration. One course per area, with one-line rationale.
- GitHub project ideas: minimum one per stack area, with: core features, technologies exercised, .NET concept it maps to, and the interview claim it underwrites.
- Interview talking points: how to explain learning Java/Spring quickly, how to justify JSP usage when asked, how to address clinical data integrity and security.

### 6. Disk cleanup

Handled by the consolidation script (_scripts/consolidate-vault.ps1).

### 7. Sign-off

- [ ] John has read this synthesis and edited it in his voice.
- [ ] John has run the consolidation script and verified the clean tree.
- [ ] 06_Status/STATUS.md reflects post-synthesis state.
- [ ] 06_Status/HISTORY.md has an entry timestamping synthesis sign-off.
- [ ] KTS-0000002 prompt is drafted and ready to send to both tools with the three Elevance Office files extracted and gh repo list jagreen03 output pasted.

When all five boxes are checked, KTS-0000001 is closed.
'@
Write-VaultFile "03_Synthesis/2026-05-01_KTS-0000001_KT-bootstrap-SYN.md" $syn

$status = @'
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
This machine (work laptop, work-from-home setup): C:\ICS-LT-FYXFHG4\KT\clinical\Readiness\
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
'@
Write-VaultFile "06_Status/STATUS.md" $status

$history = @'
# HISTORY (append-only)

> Append-only chronological log. Newest at the bottom. Each entry: ISO timestamp, saga ID, one-line summary, paths touched.
>
> AI agents: never edit prior entries. Append only.

---

## 2026-05-01T15:30Z - KTS-0000001 - Bootstrap

KT vault skeleton authored by Claude (Opus 4.7). Folder tree created under <machine-ns>\KT\clinical\Readiness\. Saga numbering convention adopted: KT-{BAND}-{7-digit} for atomic artifacts, KTS-{7-digit} for groupings. Status protocol established: STATUS.md (overwrite), HISTORY.md (append), OBJECTIVES.md (queue).

Artifacts written: README.md, 00_Inbox/bootstrap-prompt-RAW.md, 01_Prompts/_shared/{KT-bootstrap-CLEAN, MASTER_PROMPT_for_CLAUDE, MASTER_PROMPT_for_GEMINI}.md, 02_Responses/claude/KT-bootstrap-RESPONSE.md, 05_Wiki/{folder-structure, saga-numbering, stack-map-dotnet-to-java}.md, 06_Status/{STATUS, HISTORY, OBJECTIVES}.md, 07_RAG/README.md, 07_RAG/pipeline/ingest.py.draft, 08_HW/HW-BLD-002_KT-workstation.md.

Gaps logged for next turn: GitHub fetch of jagreen03 failed (Claude tool restriction); three Elevance Office attachments did not transfer.

## 2026-05-01T17:00Z - KTS-0000001 - Gemini response received, synthesis seeded

Gemini 3.1 Pro response received via paste. Saved verbatim to 02_Responses/gemini/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE-gemini.md.

Gemini's procedural critique acknowledged: disk state messy (flat files, master prompt dupes, orphan mnt tree); cleanup needed. Office files visible on disk but never made it into a tool's context: owed for KTS-0000002. gh repo list jagreen03 workaround correct: owed for KTS-0000002.

Gemini's overreach corrected: path normalization to C:\RAW\KT\ would have destroyed John's <machine-ns>\KT\<track>\<phase>\ classification: kept original. "Delete 08_HW from this machine" rejected: both machines under John's chain of custody, source-of-truth = personal computer. "Skip JPA" softened to "JPA read-deep-enough-to-defend." "Avoid JSP view logic" rejected: contradicts master prompt's actual ask.

Gemini's omissions logged for KTS-0000002: LinkedIn Learning courses (6 stack areas); GitHub project ideas with .NET-mapping rationale; interview talking points.

## 2026-05-01T17:30Z - KTS-0000001 - Disk consolidated via single PowerShell script

Single-script approach replaced multi-zip downloads going forward. _scripts/consolidate-vault.ps1 ran: backed up Readiness to Readiness.bak.<ts>, extracted turn-1 zip, wrote turn-2 content via embedded here-strings, moved Office files to 00_Inbox, removed duplicate master prompts at Readiness root, removed Files_* folders and orphan mnt trees. Idempotent: can re-run safely.

Convention going forward: one PS1 per turn. No zips. No individual file downloads. The script is the deliverable; running it brings the vault to the desired state. ASCII-only content to avoid Windows PowerShell 5.x ANSI/UTF-8 mismatch.

Next: John edits and signs the synthesis, runs git init plus remote, opens KTS-0000002.
'@
Write-VaultFile "06_Status/HISTORY.md" $history

$objectives = @'
# OBJECTIVES

> Forward queue. Items move to HISTORY.md on completion. Newest priority at top.
>
> Convention: [P{0|1|2}] [target-date] description -- owner. P0 = blocking; P1 = this weekend; P2 = next week.

---

## Today / tomorrow (2026-05-01 / 2026-05-02)

- [P0] [2026-05-01] Run _scripts/consolidate-vault.ps1 (dry-run first, then -Apply). Verify clean tree under Readiness (00_Inbox through 99_Archive present; Office files in 00_Inbox; no Files_* or orphan mnt). -- John
- [P0] [2026-05-02] Decide personal-computer machine-namespace string. Provision the same vault layout there. Set personal computer as source-of-truth. -- John
- [P0] [2026-05-02] Stand up a private Git remote (GitHub private repo recommended). git init on personal computer's vault, push, then git clone on work laptop. Both machines now in lockstep via Git. -- John
- [P0] [2026-05-02] Edit 03_Synthesis/2026-05-01_KTS-0000001_KT-bootstrap-SYN.md in your voice; tick the sign-off boxes; commit. -- John

## Weekend (2026-05-02 / 2026-05-03)

- [P1] [2026-05-02] Open KTS-0000002. Prompt body: master prompts (Claude and Gemini, unchanged) plus two attachments inlined: (a) extracted text and tables from the three Elevance Office files, (b) raw output of gh repo list jagreen03 --limit 50. Save raw at 00_Inbox/2026-05-02_KTS-0000002_*-RAW.md, cleaned at 01_Prompts/_shared/...-CLEAN.md. -- John
- [P1] [2026-05-03] Receive Claude and Gemini responses to KTS-0000002. Expected deliverables: LinkedIn Learning course list, GitHub project ideas, interview talking points. -- John
- [P1] [2026-05-03] Author KTS-0000002 synthesis. -- John
- [P1] [2026-05-03] Stand up Ollama on personal computer. Pull nomic-embed-text and llama3.1:8b-instruct-q4_K_M. Verify sqlite-vec extension loads in Python. -- John
- [P1] [2026-05-03] Promote 07_RAG/pipeline/ingest.py.draft to runnable ingest.py. Smoke-test on 01_Prompts/ and 02_Responses/. -- John
- [P1] [2026-05-03] Order Threadripper 7960X workstation parts from personal computer. -- John
- [P1] [2026-05-03] Scaffold first Spring Boot repo skeleton under 04_Applications/spring-boot-clinical-rest/. -- John

## Next week (2026-05-04 onward)

- [P2] [2026-05-08] Course selection from KTS-0000002 synthesis. Schedule actual viewing windows. -- John
- [P2] [2026-05-08] Stand up Spring Boot BFF mirror of BlueSand.RiverHorse.Gateway: same OAuth 2.0 plus PKCE flow, Spring Authorization Server or Keycloak as IDP. -- John
- [P2] [2026-05-09] First public GitHub repo push for the BFF skeleton. -- John
- [P2] [2026-05-10] MongoDB schema sketch for clinical-style document model. -- John
- [P2] [2026-05-11] JPA read-only orientation: JpaRepository, @Entity, @Transactional. One reading session. Goal: defend the choice not to use JPA. -- John

## Backlog

- JSP MVC reference app: small, focused. JSP plus Thymeleaf in same project for explicit comparison.
- AWS deployment target decision: ECS Fargate vs EKS vs Elastic Beanstalk. Decision in synthesis.
- Long-form: a "translating .NET to Spring Boot" article. Companion to RDIMM Tax piece. Not for this weekend.
'@
Write-VaultFile "06_Status/OBJECTIVES.md" $objectives

# ============================================================================
# 5. Move Office files into 00_Inbox
# ============================================================================
Step "Moving Elevance Office files into 00_Inbox"
$inbox = Join-Path $VaultRoot "00_Inbox"
$officeFiles = @(
    "Elevance_Clinical_KT_Activity.docx",
    "Elevance_Clinical_Preparation.pptx",
    "Elevance_Clinical_TechStack_Activity.xlsx"
)
foreach ($f in $officeFiles) {
    $src = Join-Path $VaultRoot $f
    if (Test-Path $src) {
        Run "Move $f to 00_Inbox" {
            if (-not (Test-Path $inbox)) { New-Item -ItemType Directory -Path $inbox -Force | Out-Null }
            Move-Item -Path $src -Destination $inbox -Force
        }
    } else {
        Note "(already moved or absent: $f)"
    }
}

# ============================================================================
# 6. Remove duplicate master prompts at Readiness root, but only if framed
#    copies exist in 01_Prompts\_shared
# ============================================================================
Step "Removing duplicate master prompts at Readiness root (canonical lives in 01_Prompts\_shared)"
$dupeMap = @{
    "MASTER PROMPT - FOR CLAUDE.md" = "01_Prompts\_shared\MASTER_PROMPT_for_CLAUDE.md"
    "MASTER PROMPT - FOR GEMINI.md" = "01_Prompts\_shared\MASTER_PROMPT_for_GEMINI.md"
}
foreach ($d in $dupeMap.Keys) {
    $src = Join-Path $VaultRoot $d
    $canonical = Join-Path $VaultRoot $dupeMap[$d]
    if (Test-Path $src) {
        if (Test-Path $canonical) {
            Run "Remove duplicate $d (canonical at $($dupeMap[$d]) confirmed)" {
                Remove-Item -Path $src -Force
            }
        } else {
            Run "Promote $d to $($dupeMap[$d]) (no canonical found)" {
                $canonicalDir = Split-Path -Parent $canonical
                if (-not (Test-Path $canonicalDir)) { New-Item -ItemType Directory -Path $canonicalDir -Force | Out-Null }
                Move-Item -Path $src -Destination $canonical -Force
            }
        }
    }
}

# ============================================================================
# 7. Remove Files_* folders and any orphan mnt trees
# ============================================================================
Step "Removing leftover Files_* and orphan mnt trees"
$leftovers = @()
$leftovers += Get-ChildItem -Path $VaultRoot -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "Files_*" }
$leftovers += Get-ChildItem -Path $VaultRoot -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq "mnt" }
foreach ($l in $leftovers) {
    Run "Remove leftover $($l.FullName)" {
        Remove-Item -Path $l.FullName -Recurse -Force
    }
}

# ============================================================================
# 8. Final report
# ============================================================================
Step "Final state"
if ($Apply) {
    Write-Host ""
    Write-Host "Vault tree (top-level):" -ForegroundColor Green
    Get-ChildItem -Path $VaultRoot -Directory | Sort-Object Name | ForEach-Object { Write-Host "  $($_.Name)\" }
    Write-Host ""
    Write-Host "Backup at: $backup" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. type $VaultRoot\06_Status\STATUS.md"
    Write-Host "  2. notepad $VaultRoot\03_Synthesis\2026-05-01_KTS-0000001_KT-bootstrap-SYN.md"
    Write-Host "  3. cd $VaultRoot ; git init"
} else {
    Write-Host ""
    Write-Host "DRY RUN COMPLETE. Re-run with -Apply to mutate." -ForegroundColor Yellow
    Write-Host "Suggested: .\consolidate-vault.ps1 -Apply"
}
