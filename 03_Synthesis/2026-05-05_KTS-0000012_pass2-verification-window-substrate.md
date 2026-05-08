# KTS-0000012 — Pass 2: Verification Window & Persona Handshake

**Date:** 2026-05-05
**Status:** Spec complete, awaiting Casey L commit
**Predecessor:** KTS-0000012 pass 1 (persistence substrate, MongoDB live)
**Doctrinal pivot:** Domain-Wide Auto-Role -> Live Verification

## Intent

Replace implicit "logged-in == authorized" with two stricter invariants:
1. **6-hour verification window** — elevated authorities require a fresh OIDC
   handshake within a configurable window (default 6h). Stale sessions get
   bounced through `/oauth2/authorization/google`.
2. **Single-persona handshake** — multi-role users pick exactly one role per
   session. Switching requires logout/login. The One-Way Ticket invariant.

Verified users with no role assignment land at the guest/branding path
(`/`) under `ROLE_USER`.

## Files Touched

- `identity/User.java` — added `emailVerifiedAt`
- `identity/PersonaSelectionService.java` — new (session-scoped persona helper)
- `identity/PersonaController.java` — rewrite (REST endpoints for picker)
- `config/RoleMappingConfig.java` — stamps `emailVerifiedAt` on every login
- `config/VerificationFreshnessFilter.java` — new (6h gate)
- `config/PersonaSelectionFilter.java` — new (per-request authority narrowing)
- `config/SecurityConfig.java` — registers filters, route rules
- `application.yml` — `odin.security.verification-window-hours` (default 6)

## Configuration

| Property                                  | Default | Override env var                              |
|-------------------------------------------|---------|-----------------------------------------------|
| odin.security.verification-window-hours   | 6       | ODIN_SECURITY_VERIFICATION_WINDOW_HOURS       |
| odin.security.persona-picker-path         | /persona/select | (yaml only)                           |
| odin.security.guest-landing-path          | /       | (yaml only)                                   |

## One-Way Ticket Enforcement

`PersonaSelectionFilter` narrows authorities per-request and restores them
in `finally`. Persona selection lives in `HttpSession` only. Logout clears
the session, which forces a fresh pick on next login. There is no
mid-session promotion or demotion path.

## Known Limitations (deferred to Pass 3)

- Role removal mid-session: if an admin revokes a user's `ADMINISTRATOR`
  role while that user has the persona active, the change takes effect on
  next login, not immediately. Hard real-time enforcement requires a
  Mongo round-trip on every request — defer until ROI is clear.
- Audit trail (`persona_audit` collection) — original Pass 2 scope. Moved
  to Pass 3 because freshness + persona logic was independently substantial.
- Angular persona-picker UI — Pass 2b in `clinical-spa-angular`,
  consuming `GET /persona/options` and `POST /persona/select`.

## RoleRegistry.java cleanup

Cleanup gate before delete:
`findstr /s /i /c:"RoleRegistry" src\main\java\*.java`
If only the file itself shows up, delete. Otherwise refactor callers first.

## Verification

1. Boot with `ODIN_SECURITY_VERIFICATION_WINDOW_HOURS=6` (or unset; default takes).
2. Single-role user: confirm auto-select; no picker shown.
3. Dual-role user (seed both `ODIN_BOOTSTRAP_*` env vars to same email):
   - First request after login redirects to `/persona/select`
   - `POST /persona/select {"role":"ADMINISTRATOR"}` succeeds
   - Subsequent `/admin/**` requests pass; `/dev/**` requests 403
   - Logout, log back in: picker appears again
4. No-role user: lands at `/` under `ROLE_USER`.
5. Set window to 1 minute (`ODIN_SECURITY_VERIFICATION_WINDOW_HOURS=0`
   actually disables; use `1` and wait): subsequent request redirects to
   `/oauth2/authorization/google`.

## Status

Ready for Casey L Jones to commit.
Next checkpoint: persona switching cycle verified end-to-end with both
admin and lead-developer roles bound to your account.