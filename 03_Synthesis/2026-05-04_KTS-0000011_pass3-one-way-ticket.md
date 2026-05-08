# KTS-0000011 Pass 3: One-Way Ticket Persona Doctrine

## Status: Verified at Runtime

## Summary

Pass 3 closes the persona switch implementation with an architectural doctrine: privilege descent is allowed, privilege escalation through the switcher is not. An ADMINISTRATOR can inhabit any enabled role for a session; returning to ADMINISTRATOR requires full logout and re-authentication. The UI enforces this by hiding switcher controls once the user has descended.

## Architectural Decision: One-Way Ticket

The persona switcher in Pass 2 allowed bidirectional transitions: ADMINISTRATOR could become SME, then click "Reset to Admin" to climb back. This was a security smell. A persona switcher that lets you escalate back to your original privilege without re-authenticating creates a class of audit-trail and lateral-movement risks that are inappropriate for the architect-pitch reference implementation.

The corrected pattern: persona inhabitation is a one-way descent. Once an administrator inhabits SME, the only way back to ADMINISTRATOR is to log out and log in again. The session that inhabited SME ends there; a new session begins clean.

## UX Consequence

The HomeController gates switcher button rendering on the `ROLE_ADMINISTRATOR` authority. The boolean `isAdmin` is computed from the current Authentication's authorities, not from the OidcUser email. This is intentional: after a switch, the OidcUser identity is unchanged but the authorities have been replaced. The UI reads the authorities, not the identity.

Result:

- Login as ADMINISTRATOR: switcher buttons render. Logout button renders.
- Click "Inhabit SME": SecurityContextHolder is replaced with a new OAuth2AuthenticationToken carrying only ROLE_SME. Page re-renders.
- After re-render: switcher buttons are absent. Only the logout button remains. Inhabiting SME has burned the ticket.
- Login as a non-administrator (e.g., LEAD_DEVELOPER): switcher buttons never render. The "Persona Mode Active" message acknowledges the role without offering controls the user couldn't exercise anyway.

This is more honest UX than rendering buttons that 403 on click. The interface tells the truth about what's possible.

## Test-Case Equivalence

Catalyst-001's observation: the One-Way Ticket pattern is structurally identical to enterprise QA test-user workflows. An admin "inhabiting" SME is the same shape as a tester impersonating a customer to verify what the customer sees:

- The tester cannot accidentally exercise admin powers during the test.
- Role transitions are atomic and audit-loggable.
- Resuming admin work requires a formal session boundary, not a button click.

This means the persona switcher is not a novel pattern; it is an instance of a pattern enterprise systems already implement under names like "support impersonation," "shadow user," or "QA shadow account." Naming it explicitly as "One-Way Ticket" gives it a clean teaching label without losing the audit-trail rigor of the established pattern.

## Defense-in-Depth Layers

The implementation enforces the pattern at three layers:

1. UI layer (HomeController): switcher controls are not rendered for non-administrators.
2. Authorization layer (PersonaController @PreAuthorize): only ADMINISTRATOR authority can invoke /switch-persona.
3. Doctrine layer (UserRole.isEnabled): even an administrator cannot inhabit a disabled role; the PersonaController validates target.isEnabled() before mutating the SecurityContext.

Removing any single layer would not break the security model. Removing the UI gate would expose buttons that 403 on click (poor UX, but security holds). Removing @PreAuthorize would let a non-administrator POST directly to /switch-persona (UI gate prevents the button, but a determined user could craft the request, and only @PreAuthorize would block them). Removing isEnabled would let administrators inhabit roles that haven't been deliberately turned on.

The three layers are independent and complementary. This is the Spring Security architectural literacy that distinguishes a hardened BFF from a demo.

## CSRF Restoration Confirmed

Pass 2 of this saga restored CSRF protection after Pass 1's dev-convenience disable. Pass 3 verified that the One-Way Ticket flow still works with CSRF active. The HomeController emits hidden _csrf inputs in every form via the CsrfToken request attribute. The switcher and logout forms both submit valid tokens. No 403 errors during the runtime test.

## Files Changed

- 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/config/SecurityConfig.java (CSRF restored, @EnableMethodSecurity active)
- 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/identity/PersonaController.java (@PreAuthorize, enum validation, isEnabled check)
- 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/HomeController.java (One-Way UI: isAdmin gate, no Reset button, CSRF token injection)

## Carry-Forward to Future Sagas

- Audit logging: the SecurityContext mutation in PersonaController is a security-relevant event that should produce an audit trail entry beyond the current SLF4J log line. Future saga: structured audit log with user identity, source role, target role, timestamp, request ID.
- Session timeout interaction: the One-Way Ticket pattern assumes the user logs out to reset. If the session times out while inhabiting SME, the next login starts fresh as ADMINISTRATOR, which is the desired behavior. Worth confirming in a future test pass.
- The Angular SPA has not yet been updated to consume role information from the BFF. KTS-0000008 Pass 4 ProxyDemoComponent reads currentUser but not roles. Future saga will surface roles to the SPA and use them for route-level authorization.
- Role enablement is currently hardcoded in the UserRole enum. Future saga will move this to configuration (application.yml or persistent store) so administrators can enable/disable roles without code changes.

## Saga Status

KTS-0000011 Pass 3 closed. The Identity Engine demonstrates Spring Security RBAC with multi-layered enforcement, hot-swap persona inhabitation under the One-Way Ticket doctrine, and CSRF protection across all mutating endpoints.