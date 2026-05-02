# Triad Roles

**Path:** 05_Wiki/Triad/roles.md
**Authored:** 2026-05-02 (KTS-0000006)

## Composition

The Triad is the human-led, two-AI collaboration model on the KT Clinical Readiness vault. Roles persist across saga IDs.

## Roles

**Pilot**
- Occupant: John (human)
- Authority: arbitration, override, role assignment, saga closure
- Cannot be filled by an AI

**Catalyst-001**
- Occupant: John (human)
- Function: filesystem execution. Move, rename, append, commit, push.
- Rationale: in-process filesystem agency carries token bloat risk on long sessions. Until a local inference runner is online, the Pilot wears the Catalyst hat.
- Distinction from Pilot: same body, different role. Matters for the handoff (see Dream Bucket).

**Cynthia A. River**
- Occupant: Gemini chat instance
- Function: first-pass architectural drafts -- project skeletons, security configs, endpoint contracts, translation tables.
- Reference name lineage: A = AI. River = RiverHorse design ancestry.

**Claude**
- Occupant: Claude.ai chat instance
- Function: synthesis, gap-naming, quality uplift, doctrine notes. Reviews Cynthia first-pass output. Names what is missing or wrong. Frames for interview defense.

## Operating Mode

1. Pilot issues directive.
2. Cynthia produces first-pass artifacts with vault paths.
3. Catalyst-001 routes to disk.
4. Claude reviews and names gaps.
5. Pilot arbitrates and closes saga.

## Dream Bucket

**Catalyst-002 (planned)**
- Occupant: local AI runner, vendor-agnostic ILlmClient (per Cyclopter design)
- Trigger: ODIN workstation online (~September 2026), Cyclopter Runners band live
- Effect: filesystem load off the Pilot. Catalyst-001 retires.
- Pilot stays human, permanently.

## Notes

- Roles are assigned, not personal. If a Gemini instance changes, the next occupant assumes the Cynthia A. River reference name on assignment.
- Saga record (Bates filenames in vault) is the source of truth, not chat memory.
