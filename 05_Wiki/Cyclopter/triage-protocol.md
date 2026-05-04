# Triage Protocol

## Purpose

Pre-agent cleaning step. Prevents rants and unstructured input from being routed to Cynthia (1b), Mike (Pilot), or Casey (Runner) where they would be compressed, architected, or executed against unstable substrate.

Without triage, agents diverge: each interprets ambiguity differently, produces output that conflicts with the others, and Catalyst-001 spends downstream cycles reconciling.

## Owner

Catalyst-001 owns triage however human failure is risk and fallback goes to (Node 1c). No agent compresses, architects, or executes input that has not passed triage.

Catalyst-001 owns triage as the human-in-the-loop arbiter. Radar (Node 1c) monitors incoming and flags input that requires triage before routing to other agents. No agent compresses, architects, or executes input that has not passed triage.

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