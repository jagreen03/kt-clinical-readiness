# Robust Runner-Prompt Template

Copy this entire file as the starting point for any new pass prompt.
Replace every [BRACKETED] placeholder with concrete content.
Delete sections only with N/A + one-line reason.

Reference doctrine: 01_Prompts/_shared/PROMPT_PATTERN_robust-runner-prompts.md

---

## SAGA & PRIOR PASS

SAGA: KTS-[XXXXXXX]  PASS: [N.M]
PRIOR PASS: 02_Responses/[claude|gemini]/KTS-[XXXXXXX]-pass[N.(M-1)].md

## ENVIRONMENT DECLARATION

Answer YES/NO before starting:
- A. Read existing files from disk: [?]
- B. Write/save files to disk that the human can keep: [?]
- C. Execute build/lint/test commands and observe output: [?]
- D. Read formula text / structural metadata from binary files (xlsx, docx, pdf): [?]

CONSEQUENCES:
- A=NO -> request prior file contents and pause; do not reconstruct from memory
- B=NO -> output remediation steps only; do not attempt edits
- C=NO -> every Acceptance Test below is UNVERIFIED until next pass
- D=NO -> workbook structural checks become MANDATORY remediation

## OPERATING MODE

- No clarifying questions
- One comprehensive report at end
- Document each decision inline in code comments
- Anything unverified becomes MANDATORY remediation in CONTINUITY

## CONTEXT (no more than 3 sentences)

Pass [N.M] closes [specific scope]. Prior pass left [specific state]. Goal of this pass: [one-sentence outcome].

## INVARIANTS (must NOT regress)

- [Behavior that must keep working, e.g. "ng build succeeds with zero errors"]
- [Method/signature that must remain callable]
- [File or folder that must remain populated]
- [Test case that must keep passing, with specific values]
- [Add lines as needed; be exhaustive, not aspirational]

## SCOPE (per file: FULL / PATCH / NEW)

1. [FULL FILE REPLACEMENT | EXACT PATCH | NEW FILE]: [absolute or repo-relative path]

   [If FULL: complete file contents]
   [If PATCH:
       FROM:
         [old text with enough surrounding context to disambiguate]
       TO:
         [new text]
   ]
   [If NEW: complete file contents]

2. [next file...]

## ACCEPTANCE TESTS (binary, runnable, mechanical)

- A. [Command, e.g. `ng build --configuration=development`]
     PASS = [literal expected condition, e.g. "exit code 0, zero errors"]

- B. [Specific value assertion]
     PASS = [exact value or condition, with what to report as ac