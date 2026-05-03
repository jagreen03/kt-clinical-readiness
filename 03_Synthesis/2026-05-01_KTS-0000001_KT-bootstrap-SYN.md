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

Decision: keep your existing classification. The vault root is Readiness on whichever machine is the source of truth. The <machine-namespace> prefix (<work-laptop-hostname> on the work laptop, whatever convention you use on the personal computer) is your machine-disambiguation layer when files sync; it is not a corporate-policy boundary.

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
- [ ] KTS-0000002 prompt is drafted and ready to send to both tools with the three BRAND-healthcare-client-XYZ Office files extracted and gh repo list jagreen03 output pasted.

When all five boxes are checked, KTS-0000001 is closed.