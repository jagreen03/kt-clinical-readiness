# riverhorse-gateway-spring

Backend-For-Frontend (BFF) Gateway for the KT Clinical SPA. This service handles Google OAuth 2.0 authentication with PKCE, maintains the secure server-side session, and acts as a hardened reverse proxy routing requests to internal microservices. Uses the Spring default callback pathing (Path B).

## Tech Stack

- Java 21 (LTS)
- Spring Boot 4.0.5
- Maven

## Required Environment Variables

The application context requires the following variables to be exported in the runtime environment:

- GOOGLE_OAUTH_CLIENT_ID: Google Cloud Console OAuth Client ID
- GOOGLE_OAUTH_CLIENT_SECRET: Google Cloud Console OAuth Client Secret
- INTERNAL_API_KEY: Downstream credential used to authenticate the BFF to internal services

## Build & Run

Requires Maven 3.9+ on PATH and Java 21.

Commands:

- Compile: mvn clean compile
- Test: mvn clean test (uses the test profile with stubbed credentials)
- Run: mvn spring-boot:run
- Run with dev profile: mvn spring-boot:run -Dspring-boot.run.profiles=dev

A Maven wrapper is not shipped. To add one, install Maven, run mvn -N wrapper:wrapper from the project root, then prefer ./mvnw over mvn for build invocations.

## Architectural Decisions and Saga Record

Architectural decisions, threat models, and review artifacts that shaped this repository are stored in the parent vault at 03_Synthesis/. Refer to sagas KTS-0000006 and KTS-0000007.

## Known Limitations

- Body Buffering: The proxy layer currently buffers request and response bodies in memory (byte[]). Documented portfolio limitation; production scale requires migration to InputStreamResource streaming.
- Resilience4j: Circuit breaker and bulkhead annotations are temporarily deferred pending Spring Boot 4.x compatibility verification.
- Redundant Bean: CookieSerializer bean in SecurityConfig.java is currently redundant since SameSite=Lax is enforced via application YAML properties. Scheduled for future cleanup.
- JSON Envelope Inconsistency: Auth failure responses use {"error": ...} while logout uses {"message": ...}. Normalize in a future pass.