/* Path: 03_Synthesis/2026-05-04_KTS-0000011_pass2-persona-switch-hardening.md */
# KTS-0000011 Pass 2: Persona Switch Hardening

## Accomplishments
- Restored CSRF protection using `CookieCsrfTokenRepository` and `CsrfTokenRequestAttributeHandler`.
- Secured `PersonaController` using `@PreAuthorize("hasRole('ADMINISTRATOR')")`.
- Implemented robust input validation in `PersonaController` (Enum safety and `isEnabled` checks).
- Updated `HomeController` to properly handle CSRF tokens in hidden form inputs.
- Enabled `@EnableMethodSecurity` for fine-grained authorization control.

- Restored CSRF protection with Cookie-based token repository.
- Secured `PersonaController` with `@PreAuthorize("hasRole('ADMINISTRATOR')")`.
- **Implemented "One-Way Ticket" UI Doctrine:** Admins can inhabit roles, but cannot revert to Admin without a full logout.

## Architectural Decision Records (ADR)
- **CSRF Restoration:** Disabling CSRF for development convenience was identified as an architectural regression. We chose to implement proper token handling in the `HomeController` to match the rigor expected in the final Angular SPA.
- **AuthZ Guards:** The persona switcher is now restricted to administrators only, preventing privilege escalation vulnerabilities where non-admin users could grant themselves higher authorities.

## Status: HARDENED