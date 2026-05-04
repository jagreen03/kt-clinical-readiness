Cynthia, Radar protocol acknowledged. Doctrine committed. Sending
the triaged Architect Pitch for proper compression.

Triage applied to the original DREAM at:
00_Inbox/2026-05-04_DREAM_spring-architect-pitch.md

Tagging:

  [DREAM] — content stays in inbox for future sagas:
    - "Tree topology / Leaf deployment" metaphor
    - Cloud target debate (EKS / AKS / Lambda / Functions)
    - Capacity Engine framing

  Tangent — parked separately:
    - RBAC permission matrix and role engine
      (parked at 00_Inbox/2026-05-04_DREAM_rbac-permission-matrix.md
       for KTS-0000010 or later)

  Already-decided — exists in saga record, no new work needed:
    - Spring Boot 4.0.1 + Java 21 baseline
    - PKCE handshake via PkceParameterNames
    - RestClient inline builder pattern (Option A)
    - Angular 19 signal-based AuthService
    - proxy.conf.json same-origin local dev

  Prompt-able — KTS-0000009 scope, ready for compression:

    Diagram set, dependency-ordered:

    01. BFF Trust Boundary diagram (existing reality)
        Mermaid sequence + architecture. Shows the BFF as OAuth 2.0
        broker between SPA and Google. Anchors security rigor.

    02. Signal-Based Frontend Architecture diagram (existing reality)
        Mermaid sequence + state. Shows the AuthService tri-state
        signal lifecycle, interceptor pipeline, route guard
        activation flow.

    03. PKCE Token Flow diagram (existing reality, distinct from 01)
        Mermaid sequence focused on the cryptographic handshake:
        code_verifier generation -> code_challenge derivation
        (SHA-256 + base64url) -> authorization request -> token
        exchange -> session establishment.

    04. MongoDB ER Diagram (forward-architecture, schema sketch only)
        Mermaid ER. Documents architectural intent for the
        persistence layer. No actual MongoDB integration exists yet.
        Diagram captures intended entities and relationships for
        the eventual implementation. Marked as TODO/forward state
        in the diagram itself.

    05. BlueSand Integration Bridge document (forward-architecture)
        Markdown + Mermaid. Documents how Spring Boot business
        logic pulls into the BlueSand pattern. Anchors the
        portfolio piece's distinguishing thesis - this is what
        separates the saga from a generic Spring Boot tutorial.

  Pilot decisions required:
    - None for diagrams 01, 02, 03 (Casey-executable from saga
      record).
    - For diagram 04: Mike (when online) confirms intended schema
      shape. Catalyst-001 may decide to proceed with Casey's
      best-judgment sketch and have Mike review later.
    - For document 05: Catalyst-001 provides a pointer to the
      BlueSand repo or representative artifact so Cynthia/Casey
      have rigor benchmark to match.

Compress this package to Prompt-ized state. Do not jump to [PROMPT]
yet. Catalyst-001 reviews the Prompt-ized output before Casey gets
locked execution-ready specs.