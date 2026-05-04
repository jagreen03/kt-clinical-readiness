# Triage Protocol

## Purpose

Pre-agent cleaning step. Prevents rants and unstructured input from being routed to Cynthia (1b), Mike (Pilot), or Casey (Runner) where they would be compressed, architected, or executed against unstable substrate.

Without triage, agents diverge: each interprets ambiguity differently, produces output that conflicts with the others, and Catalyst-001 spends downstream cycles reconciling.

## Owner

Triage is prompt middleware for AI. Its function is to detect unhealthy prompts before they reach working agents (Cynthia 1b Strategic, Mike Pilot, Casey Runner). Unhealthy prompts include rant-shaped, mixed-scope, ambiguous, emotionally-loaded, or drifting input.

**Primary owner:** Radar (Node 1c). Dedicated triage role. Refuses to compress, architect, or execute. Routes only.

**Backup paths when Radar is unavailable or itself compromised:**

1. Casey (Runner) refusal at execution time. If Radar cleared a prompt but Casey detects ambiguity at the disk-write level, Casey kicks back to Radar with the specific ambiguity flagged.

2. Radar peer review with Cynthia 1a (Director). When Radar is uncertain about a prompt's health, Radar may request Cynthia 1a review before routing. Cynthia 1a holds narrative state and has a different cognitive surface than 1b/Strategic, providing independent assessment.

**Sources of drift (explicitly NOT triage owners):**

- Catalyst-001 (John). Human prime mover, but also primary source of human drift: ADHD-driven scope leak, end-of-day fatigue, ROI anxiety bleeding into technical specs, rant-shaped brain dumps. Catalyst-001 *originates* prompts; Radar *triages* them. Naming Catalyst-001 as triage owner is asking the source of drift to police itself.

- Cynthia 1b (Strategic). Compresses prompts but cannot triage them. Drift in her own compression output (scope leak, hallucinated novel scope, missing original scope) is itself a triage failure mode that Radar must catch.

- Mike (Pilot). Architectural authority but cannot triage incoming prompts that have not yet reached architectural specification.

- Casey (Runner). Executes only. Cannot triage upstream prompts; only executes-time refusal is permitted.

No agent compresses, architects, or executes input that has not passed triage.

## Recognition

Input requires triage when ANY of the following are true:

- Multiple concerns are glued together in the same paragraph
- Stream-of-consciousness phrasing without explicit DREAM/Prompt-able/PROMPT framing
- Reference to past decisions without cite path
- Mixed scope (current saga concerns plus future-saga concerns plus unrelated tangents)
- Emotional content (frustration, fatigue, ROI anxiety) intermixed with technical content
- "Rant" or "brain dump" framing

## Protocol

1. Read input completely before tagging anything.

2. Tag each discrete idea with:
   - `[DREAM]` — raw, unformed, exploratory
   - `Prompt-able` — has structure, ready for Cynthia 1b compression
   - `[PROMPT]` — locked execution spec, route to Casey directly
   - `Tangent` — belongs in a different saga, park as separate DREAM
   - `Already-decided` — exists in saga record, no new work needed

3. Group tagged ideas by saga. Anything that doesn't fit the active saga gets parked as a separate DREAM in `00_Inbox/`.

4. Output per agent:
   - Cynthia 1b gets only Prompt-able-tagged content for compression
   - Mike (Pilot) gets only architectural-decision-required content
   - Casey gets only [PROMPT]-tagged content for execution

5. Confirm each output is internally consistent before routing.

## Agent Recognition

Cynthia, Mike, and Casey: if you receive input that exhibits triage-recognition signs above, refuse to compress/architect/execute. Route back to Catalyst-001 with: "This input needs triage. Tagging detected: [list signs]. Triage before routing."

## Cross-Reference

Triage is the first stage of the Idea Compression Pipeline (see doctrine-and-roster.md). Pipeline: Triage -> [DREAM] -> Prompt-able -> Prompt-ized -> [PROMPT].

The original pipeline omitted triage as an explicit step. Adding it formalizes what was previously implicit, and prevents the failure mode where unstable input gets compressed prematurely.