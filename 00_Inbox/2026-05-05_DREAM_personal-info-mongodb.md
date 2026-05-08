# DREAM: Personal Information + MongoDB

Catalyst-001, end of day 2026-05-05 (~05:00 EDT).

## Raw Thought

Want to start storing "personal information" in MongoDB. Thought arose
immediately after closing KTS-0000011 with the SPA-to-BFF auth wired.

## What Needs Triage

- "Personal information" is undefined. User profile? Persona preferences?
  Audit log? Something else? Multiple things glued together?
- Why MongoDB specifically vs other persistence (Postgres, file, current
  in-memory RoleRegistry extension)?
- Is this the natural successor to KTS-0000011 or is it momentum?
- The MongoDB ER diagram from KTS-0000009 (04_MongoDB_Schema_Intent.md)
  is marked TODO/INTENTIONAL with USER, PROFESSIONAL_TRACK, SKILL_NODE,
  RESUME_GAP entities. Is that the schema we'd implement, or is the
  "personal information" thought pointing somewhere different?

## Open Questions for Mike (Pilot)

- Is MongoDB the right persistence target for this BFF, or is the choice
  driven by the diagram already on disk?
- How does the persistence layer interact with the existing in-memory
  RoleRegistry?
- Spring Data MongoDB or raw MongoDB driver?
- Schema-first or code-first?
- Local MongoDB instance vs MongoDB Atlas for dev?

## Open Questions for Cynthia (1b Strategic)

- Compress the "personal information" thought into specific entities and
  use cases.
- Sequence relative to other carry-forward work: [object Object] role bug,
  BlueSand integration, RBAC matrix, audit logging.

## Status

[DREAM] - parked. Triage required before Cynthia compresses.

## NEXT ACTION

Open Cynthia, paste: "Cynthia, compress the DREAM in
00_Inbox/2026-05-05_DREAM_personal-info-mongodb.md after Catalyst-001
provides scope clarification on what 'personal information' means in
this context."