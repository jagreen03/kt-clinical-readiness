# DREAM: RBAC Permission Matrix and Role Implementation

Catalyst-001, morning of 2026-05-04. Surfaced via Cynthia A. River conversation.

## Raw Thought

Spring Security and Angular Route Guards working together to implement role-based access control. Permission matrix mapping roles to features. Graceful degradation for "no role" / anonymous state.

## Open Threads from Cynthia's Initial Pass

Cynthia produced a permission matrix sketch that needs review before adoption:

- Roles proposed: SME (Client), Client Onboarding Mgr, Contracting Onboarding, Lead Developer, Candidate, Guest. These roles are not derived from KT Clinical Readiness reality - they may be speculative. Real roles for THIS portfolio piece need to be defined first.
- "Approve PRs" appearing as a feature in the matrix conflates code review with feature acceptance. Worth separating.
- Industry comparison (ICS vs Infosys) is uncited speculation. Either remove or replace with actual citable references.

## Real Question for This Saga

For a demo BFF in a portfolio piece, what's the minimum credible RBAC implementation that shows enterprise security thinking without over-engineering?

Possibilities:
- Two-role minimum: authenticated user vs anonymous
- Three-role: anonymous, user, admin
- Full enterprise: multi-role with delegation, role hierarchies, attribute-based extensions

Recommendation pending Strategic compression: probably three-role for demo purposes, with documentation of how it would extend.

## Implementation Surface

- Spring Security: Role enum, @PreAuthorize annotations, method security configuration
- Angular: RoleGuard, signal-based currentUser.roles[] check, conditional UI rendering via @if
- BFF: 403 Forbidden response shape consistency with existing JSON envelope pattern
- Test coverage: role-based test fixtures

## Sequencing

This DREAM is queued AFTER the diagrams DREAM (2026-05-04_DREAM_spring-architect-pitch.md). Diagrams come first because they document what already works. RBAC is new feature work that requires architectural decisions before code.

## Status

[DREAM] - parked. Cynthia 1b will compress to Prompt-able when KTS-0000010 (or later) opens.

## Cross-Reference

- Sister DREAM: 00_Inbox/2026-05-04_DREAM_spring-architect-pitch.md (diagrams, primary trajectory)
- Saga record: 03_Synthesis/ for KTS-0000007 (security model already drafted, RBAC will extend it)