# KT Clinical SPA (TriadStack)

TriadStack-branded Single Page Application (SPA) providing the frontend interface for KT Clinical Readiness. This Angular application integrates directly with a Spring Boot Backend-For-Frontend (BFF) to handle Google OAuth 2.0 authentication, session management, and secure proxying of downstream microservice requests.

## Tech Stack
* Angular 19+ (Standalone Components)
* TypeScript
* Zoneless Change Detection

## Required Environment Variables
No environment variables are required directly by the SPA. All runtime configuration (OAuth client secrets, internal API keys) is managed by the BFF. See the `riverhorse-gateway-spring` README for backend environment requirements.

## Local Development Workflow
1. Start the BFF on port `8080` (ensure BFF environment variables are set).
2. Start the SPA via Angular CLI: `ng serve --proxy-config proxy.conf.json`
3. The SPA runs on `http://localhost:4200` and transparently proxies `/api`, `/auth`, `/oauth2`, and `/login` traffic to the BFF, simulating a same-origin production environment to bypass local CORS and CSRF restrictions.

## Build & Run Commands
* **Compile**: `ng build`
* **Test**: `ng test`
* **Run Dev**: `ng serve --proxy-config proxy.conf.json`
* **Production Build**: `ng build --configuration production`

## Architectural Notes
* **Cookie-Based Auth**: No JWTs are stored in local storage or memory. Session (`BFF_SESSION`) and CSRF (`XSRF-TOKEN`) cookies are managed entirely by the BFF and the browser.
* **Protected Routes**: `/`, `/dashboard`, and `/proxy-demo` are available. The `authGuard` enforces authentication on protected routes.
* **Interceptors**: 
  * `credentials`: Appends `withCredentials: true` to ensure cookies flow to the BFF.
  * `csrf`: Appends the `X-XSRF-TOKEN` header on mutating requests (defensive cross-origin fallback).
  * `error`: Centralized handling for 401 (redirects to public landing), 403, and network failures.

## Saga Record & Decisions
The architectural decisions, threat models, and review artifacts that shaped this integration are stored in the parent vault at `03_Synthesis/`. Refer to saga `KTS-0000008`.

## Known Limitations & Deferred Items
* **CSRF Interceptor**: The custom `csrfInterceptor` is currently a defensive duplicate of the `proxy.conf.json` same-origin behavior. It may be removed once production deployment topologies are finalized and guaranteed same-origin.
* **Client Hydration**: `provideClientHydration` is enabled but currently inactive (no SSR). Scheduled for removal or correct implementation in a future technical debt saga.
* **Testing**: No component test files (`.spec.ts`) are currently emitted. Scheduled for a future polish pass.
* **Placeholders**: `HomeComponent` and `DashboardComponent` are inline placeholders in `app.routes.ts` pending real feature implementations.