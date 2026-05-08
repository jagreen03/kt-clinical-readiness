# Robust Runner-Prompt Pattern

**Purpose:** A reusable structural template for prompts sent to AI runners (Claude/Cassy, Gemini/Cynthia, Copilot, etc.) in the Triad pattern, designed to eliminate the bug classes that have emerged through real use.

**Where this lives:** `05_Wiki/` (durable knowledge) or `01_Prompts/_shared/` (master prompt template).

**When to use it:** Any time you're handing work to a runner and you want a binary pass/fail outcome, not a Q&A loop. Use it for code generation, file editing, document production, or workbook manipulation.

---

## 1. Why this template exists

### Bug classes observed in the ODIN-Carelon work

| Bug class | What happened | Root cause |
|---|---|---|
| **Dropped state** | Pass 2 had four stub methods; Pass 2.5 silently dropped them. | No explicit invariants list; the runner only thought about what changed, not what had to be preserved. |
| **Cross-file inconsistency** | Gantt HTML called `getTooltip()` and `timelineDates`; Gantt TS didn't define them. | Each file was treated as an isolated artifact, not as part of a contract. |
| **Snippet-vs-full-file ambiguity** | One response showed FILE 3 as a 9-line block; it got saved as the entire file. | The prompt didn't specify "full file replacement" vs "patch." |
| **Compilation breakers slipped** | `Computed` type doesn't exist in Angular; ran for two passes before being caught. | No acceptance test required `ng build` to succeed. |
| **Empty folders break router** | App routes lazy-loaded four components that didn't exist on disk. | Implicit assumption that the runner would scaffold reachable files. |
| **"Pass closed" without verification** | Runner declared a pass complete based on intent, not on actual on-disk state. | No self-audit step. |
| **Drift across passes** | Each pass had to fix issues the previous pass introduced. | No reconciliation step against the prior pass. |

The fix is not "be smarter." Smart prompts still hit these bugs. The fix is structural — every robust prompt has the same seven sections, in the same order, and each section eliminates one bug class.

---

## 2. The seven-section template

Every robust runner-prompt is built from these seven sections in this order. Sections are not optional. If a section is genuinely irrelevant, write "N/A" and a one-line reason.

### Section 0 — Pre-flight

The runner declares its environment before doing anything. Forces honesty up front instead of mid-task surprise.

```
SAGA: KTS-XXXXXXX  PASS: N.M
PRIOR PASS: KTS-XXXXXXX-passN.(M-1)  (path to its output in 02_Responses/)

ENVIRONMENT DECLARATION (answer YES/NO before starting):
  A. Can you read existing files in this project from disk?
  B. Can you write/save files to disk that the human can keep?
  C. Can you execute commands (build, lint, test) and observe output?
  D. Can you read formula text / structural metadata from binary files
     (xlsx, docx, pdf)?

CONSEQUENCES:
  - If A=NO: section "Reconcile" below cannot run; you MUST request the
    prior file contents in the response and pause.
  - If C=NO: every "Acceptance test" command must be reported as
    UNVERIFIED; the runner cannot declare the pass closed.
```

### Section 1 — Context (≤ 3 sentences)

What this pass exists to do. What state the prior pass left. No preamble, no pep talk.

```
CONTEXT:
Pass N.M closes [specific scope]. Prior pass left [specific state].
Goal of this pass: [one-sentence outcome].
```

### Section 2 — Invariants (must NOT change)

Explicit list of state that must survive this pass. The runner is forbidden from removing or altering these unless this prompt explicitly says to.

```
INVARIANTS — these MUST exist and behave identically after this pass:
- File X must continue to compile.
- Method Y on service Z must remain callable with signature (a, b) => c.
- Test case T-53 parsing must continue to produce 14 phases across 2
  sections.
- Folder structure /src/app/components/{team-list,team-detail,
  dashboards,gantt} must remain populated.
- [list every behavior, type, file, method that must NOT regress]
```

This section is the antidote to dropped state. If the runner is about to remove or rewrite something, the invariants list catches it.

### Section 3 — Scope (what changes, exactly)

For every file touched, declare one of:
- **FULL FILE REPLACEMENT** — runner outputs the entire file content; treat any prior version as discarded.
- **EXACT PATCH** — runner outputs old text and new text with enough surrounding context to disambiguate.
- **NEW FILE** — runner creates a new file at a specified path.

No middle ground. Snippet-style "here's the part that changes" is forbidden.

```
SCOPE:
1. EXACT PATCH in src/app/components/gantt/gantt.component.html
   FROM:
     <div class="cell month" style="flex: 1.5">MARCH</div>
     <div class="cell month" style="flex: 4">APRIL</div>
     ...
   TO:
     <div class="cell month" style="flex: 2">MARCH</div>
     <div class="cell month" style="flex: 4">APRIL</div>
     ...

2. FULL FILE REPLACEMENT in src/app/services/project.service.ts
   [complete file contents]

3. NEW FILE at src/app/components/team-list/team-list.component.ts
   [complete file contents]
```

This section is the antidote to snippet ambiguity. Every change has an unambiguous on-disk effect.

### Section 4 — Acceptance Tests (binary)

Concrete, runnable, non-subjective. Each test is either PASS or FAIL — no "looks good," no "should work."

```
ACCEPTANCE TESTS — run all, report each as PASS/FAIL with actual output:

A. Build:  `ng build --configuration=development`
   PASS = exit code 0, zero TypeScript errors, zero template errors.

B. Specific value:
   Load fixture data; assert that team T-53 parses to 14 phases across
   exactly 2 sections, with phase IDs P32.1...P32.7 in each section.
   PASS = the assertion holds; report `team.sections.length` and
   `team.sections.map(s => s.phases.length)` as actual values.

C. File existence:
   Verify these files exist on disk:
     src/app/components/team-list/team-list.component.ts
     src/app/components/team-detail/team-detail.component.ts
     src/app/components/dashboards/phase-dashboard.component.ts
     src/app/components/dashboards/milestone-dashboard.component.ts
   PASS = all four files exist with non-empty content.

D. Recalculation (workbook tasks):
   `python /mnt/skills/public/xlsx/scripts/recalc.py FILE.xlsx`
   PASS = status "success", total_errors = 0.
```

Tests follow a few rules:

- **Binary.** Either passes or doesn't. No spectrum.
- **Mechanical.** A non-expert could run them.
- **Specific values.** "T-53 has 14 phases" not "T-53 parses correctly."
- **Cover the bug class** the prompt is trying to prevent — if the prior pass dropped four methods, an acceptance test asserts those four methods exist.

This section is the antidote to compilation breakers and silent regressions.

### Section 5 — Self-Audit (closing step)

Before the runner declares the pass closed, it runs its own acceptance tests and reports the output. Not "I believe this should pass" — actual command output, actual values, actual file states.

```
SELF-AUDIT (mandatory before declaring pass closed):
1. Run every Acceptance Test from Section 4.
2. For each, report PASS or FAIL with the literal output.
3. If any test FAILs: do NOT declare the pass closed. Return the
   failure and propose a fix or request guidance.
4. If environment limits prevent running a test (per Section 0
   declaration): mark UNVERIFIED and add to the next pass's
   Acceptance Tests as MANDATORY.
```

This section is the antidote to "Pass closed" claims that don't reflect reality.

### Section 6 — Continuity

Where the output goes; what gets updated downstream; how the next pass will pick up.

```
CONTINUITY:
- Save runner response to 02_Responses/{tool}/KTS-XXXXXXX-passN.M.md
- Update 06_Status/STATUS.md: "Pass N.M closed" with date.
- Append to 06_Status/HISTORY.md: one line per acceptance test result.
- If any UNVERIFIED items: list them in 06_Status/OBJECTIVES.md
  under the next pass's saga ID.
- Next saga ID for follow-up: KTS-XXXXXXX-passN.(M+1) or
  KTS-(XXXXXXX+1) if scope changes.
```

This section integrates with your vault structure so prompts/responses/state stay coupled.

---

## 3. Mapping bug classes to template sections

| Bug class | Template section that fixes it |
|---|---|
| Dropped state | Section 2 (Invariants) |
| Cross-file inconsistency | Section 4 (Acceptance Tests, specifically the "build succeeds" test) |
| Snippet-vs-full-file ambiguity | Section 3 (Scope, with explicit FULL/PATCH/NEW labels) |
| Compilation breakers | Section 4 (build test) + Section 5 (Self-Audit forces it to actually run) |
| Empty folders break references | Section 2 (Invariants list folder contents) + Section 4 (file existence test) |
| "Pass closed" without verification | Section 5 (Self-Audit) |
| Drift across passes | Section 0 (PRIOR PASS reference) + Section 2 (Invariants reference prior state) |

If a prompt skips a section, you can predict which bug will show up.

---

## 4. Worked example — what Pass 3 looks like under this template

Pass 3 of the ODIN planner is "real dashboards + SheetJS export." Under the template:

```
SAGA: KTS-0000013  PASS: 3.0
PRIOR PASS: 02_Responses/claude/KTS-0000013-pass2.6.md (build green, four
            placeholders in place)

ENVIRONMENT DECLARATION (YES/NO):
  A. Read existing files: ?
  B. Write files to disk: ?
  C. Execute build/test: ?
  D. Read xlsx structurally: ?

CONTEXT:
Pass 3 implements the four placeholder components into real views and adds
.xlsx export. Prior pass left a green build with placeholders. Goal: a
demo-able UI where a user can load V11 workbook, navigate teams, see
both dashboards, edit a sub-task via cadence modal, export modified
workbook, re-open in Excel without errors.

INVARIANTS — must NOT regress:
- ng build succeeds with zero errors.
- T-53 parsing produces 14 phases across 2 sections.
- T-29 / T-13 / T-24 each produce 7 phases in 1 section.
- RollupService.calculatePhase still returns Partial<PhaseHeader> with
  the four computed* fields plus computedStatus.
- Helper-column logic in V11 workbook is preserved on round-trip:
  column K must be regenerated as "<phase_id>#<header_row>" on export.
- Phase-header formulas in team sheets (Days/Start/End/% Done) must NOT
  be overwritten during export — they're array formulas the SheetJS write
  must leave alone.
- All routes from app.routes.ts must remain navigable.

SCOPE:
1. FULL FILE REPLACEMENT: src/app/components/team-list/team-list.component.ts
   (full implementation: card grid with status badges)
2. FULL FILE REPLACEMENT: src/app/components/team-detail/team-detail.component.ts
   (full implementation: phase-grouped editable plan)
3. FULL FILE REPLACEMENT: src/app/components/dashboards/phase-dashboard.component.ts
   (full implementation: sortable/filterable table)
4. FULL FILE REPLACEMENT: src/app/components/dashboards/milestone-dashboard.component.ts
   (full implementation: sortable/filterable table)
5. EXACT PATCH: src/app/services/project.service.ts
   FROM: async exportToXlsx(): Promise<Blob> { return new Blob(); }
   TO: [full export implementation that round-trips V11 layout]
6. NEW FILE: src/app/services/xlsx-export.service.ts
   (extracted helper for export logic)

ACCEPTANCE TESTS:
A. ng build --configuration=development → exit 0, zero errors.
B. Load V11 fixture → teams().length === 9.
C. T-53 sections.length === 2 AND each section's phases.length === 7.
D. From team-detail view, opening edit modal on T-29/P0/0.1 then changing
   days from current value to current+5 produces a phase rollup preview
   showing the new days total in the impact step.
E. Click Export → produces a Blob; save as test.xlsx; re-open with
   recalc.py → status: success, total_errors: 0.
F. After export round-trip, V11 helper column K still exists in column K
   of every team sheet, hidden, with values matching pattern P*#NN.
G. After export round-trip, phase-header formulas in C/D/E/I are still
   array formulas (not replaced with static values).

SELF-AUDIT:
Run A–G; report each PASS/FAIL with literal output. If any FAIL, do not
declare closed.

CONTINUITY:
Save to 02_Responses/{tool}/KTS-0000013-pass3.0.md
Update 06_Status/STATUS.md: "Pass 3.0 closed [date]" or "Pass 3.0
in-progress, blocked on [test ID]"
Append acceptance test results to 06_Status/HISTORY.md.
```

That's a runnable Pass 3 prompt under the template.

---

## 5. Anti-patterns to avoid

These are the prompt-writer mistakes that produce the bug classes:

**Anti-pattern: "Implicit invariants."** Saying "fix the date deserialization" without explicitly listing what should still work. The runner has license to remove anything it didn't think was relevant. Always enumerate invariants.

**Anti-pattern: "Show the part that changes."** Tempting because it's shorter. Costly because the human reader has to mentally diff and the runner gets ambiguous instructions. Always specify FULL or PATCH with surrounding context.

**Anti-pattern: "Trust the runner's claim of done."** Runners hallucinate completion. The Self-Audit section is mandatory because runners reliably claim closure they haven't earned.

**Anti-pattern: "One prompt, multiple new concerns."** When a prompt fixes Pass N issues AND introduces Pass N+1 work, it cannot be properly tested. Split into two prompts.

**Anti-pattern: "Pass numbers without saga IDs."** "Pass 2.5" alone is ambiguous if there are multiple sagas in flight. Always pair with a saga ID and a path to the prior pass artifact.

**Anti-pattern: "Subjective acceptance."** "Looks clean" or "executive-grade" is not testable. Replace with mechanical assertions: column widths, file existence, recalculation results, specific cell values.

---

## 6. Triad-specific notes

The Triad has Architect (you) → Designer/Refiner (one AI) → Runner (same or other AI). The robust pattern works whether one AI plays both Designer and Runner or whether they're split.

When split:
- The Designer's job is to author Sections 0–6 of the prompt.
- The Runner's job is to execute Section 3 and report Section 5.
- The Architect's job (you) is to confirm Section 4 outputs reconcile with reality on disk.

When the same AI plays both:
- Watch for Designer-bias-toward-easier-tests, where the Runner inherits the test set the Designer wrote and avoids the hard cases. Mitigate by having the OTHER AI (the one not implementing) review and harden Section 4 before the Runner sees it.

---

## 7. Quick-reference checklist

Before sending a prompt to a runner, verify it has:

- [ ] Saga ID and pass number
- [ ] Path to prior-pass artifact
- [ ] Environment Declaration prompt
- [ ] Operating Mode (no Q&A, document inline)
- [ ] Context (≤ 3 sentences)
- [ ] Explicit invariants list (what must NOT change)
- [ ] Scope with FULL / PATCH / NEW labels per file
- [ ] At least 3 binary acceptance tests
- [ ] Mandatory Self-Audit step
- [ ] Continuity instructions (save path, STATUS update, next saga ID)

If any box is unchecked, the prompt isn't robust yet.

---

*Living document. Update as new bug classes emerge or template sections need refinement.*
