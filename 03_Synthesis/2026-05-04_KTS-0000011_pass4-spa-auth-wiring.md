/* Path: 03_Synthesis/2026-05-04_KTS-0000011_pass4-spa-auth-wiring.md */
# KTS-0000011 Pass 4: SPA Authentication Wiring

## Accomplishments
- Replaced the inline placeholder `HomeComponent` with a fully realized, standalone component utilizing Angular 19 structure.
- Wired the Angular SPA to the Spring Boot BFF's authentication state via the `AuthService.me()` / `/api/me` contract.
- Implemented the reactive signal-based UI pattern: the `@if` / `@else` control flow natively reacts to the `currentUser` tri-state (`undefined` | `User` | `null`) without requiring manual subscription management in the template.

## Architectural Decision Records (ADR)
- **HttpStatusEntryPoint Contract:** The `SecurityConfig` was updated to return a raw `401 Unauthorized` JSON payload for `/api/**` paths rather than issuing an OAuth 302 redirect. This empowers the SPA to intercept the 401, set the `currentUser` signal to `null`, and gracefully render the unauthenticated state (Login Button) rather than failing into a CORS redirect loop.
- **Signal-Driven Architecture:** By centralizing the state in the `currentUser` signal, the `HomeComponent` template acts purely as a reflection of the `AuthService`. The component logic is minimal, focusing solely on triggering the initial `me()` request and handling the `logout()` execution stream using `takeUntilDestroyed` for rigorous memory management.
- **Proxy Alignment:** The login affordance exclusively routes through `AuthService.login()` to guarantee the environment's BFF base URL is respected, preventing hardcoded local ports from escaping into higher environments.

## Status: SPA WIRED