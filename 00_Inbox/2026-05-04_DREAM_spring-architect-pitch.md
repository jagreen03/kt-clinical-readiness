# DREAM: Spring Boot Architect Pitch — Diagram Rigor Match

Catalyst-001, end of day 2026-05-03.

## Raw Thought

The riverhorse-gateway-spring BFF needs the same diagram rigor that lives in the BlueSand repo. Specifically:

- Mermaid architecture diagrams matching BlueSand standard
- ER diagrams for a MongoDB layer (not yet built — placeholder TODO state)
- Sequence diagrams for OAuth flow, proxy round-trip, error paths
- Token flow diagrams (PKCE code_verifier → code_challenge → token exchange → session)
- Bridge document showing how Spring Boot business logic pulls into the BlueSand pattern

## Why This Matters

Pitching as Spring Boot architect is the unemployment hedge. The BFF works end-to-end as of today. The next layer is the artifact rigor that proves architecture-level thinking, not just running code. ROI on the diagram work is high if unemployment hits, and high enough to potentially prevent unemployment if it lands as a credible portfolio piece in placement conversations.

## Reference Points

- BlueSand repo (existing, has the diagram rigor that should be matched)
- riverhorse-gateway-spring (current state, working but undiagrammed)
- Casey's saga record from KTS-0000006 through KTS-0000008 (architectural decisions captured in prose, not yet in diagrams)

## Open Questions for Cynthia (1b Strategic) Compression

- Which diagrams are highest leverage for placement conversations?
- MongoDB ER is theoretical — should it stay theoretical (architectural future state) or do we build the actual MongoDB integration first?
- BlueSand pattern integration — is this a separate saga or a sub-saga of the diagram work?
- Saga sequencing: diagrams first, then MongoDB, then BlueSand pull? Or interleave?

## Status

[DREAM] — not yet Prompt-able. Cynthia 1b takes this from raw thought to specification tomorrow when Catalyst-001 is rested.

Closing for the night.

NEXT ACTION: Open Cynthia, paste: "Cynthia, compress the DREAM in 00_Inbox/2026-05-04_DREAM_spring-architect-pitch.md. Take it to Prompt-able first."