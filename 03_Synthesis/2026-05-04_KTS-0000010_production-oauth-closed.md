/* Path: 03_Synthesis/2026-05-04_KTS-0000010_production-oauth-closed.md */
# Saga Record: KTS-000010 (Production OAuth Handshake)

## Status: CLOSED

## Accomplishments
- Registered 'Riverhorse Gateway' in Google Cloud Console.
- Hardened application.yml to use environment variables for secrets.
- Validated end-to-end OAuth 2.0 PKCE flow.
- Successfully extracted OidcUser identity (Name, Email, Sub) from live tokens.
- Resolved root-path 404 Whitelabel error via HomeController.

## Files Changed
- 04_Applications/riverhorse-gateway-spring/src/main/resources/application.yml
- 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/HomeController.java
- 04_Applications/riverhorse-gateway-spring/README.md (Updated)

## Doctrine Notes
- **Secret Hygiene:** Credentials stay in terminal environment; code remains public-facing safe.
- **High Road Validation:** Production handshakes must precede identity engine abstractions to ensure a stable substrate.

## Carry-Forward to KTS-000011
- Implement Identity Engine (Pass 1).
- Map Google 'email' claim to custom UserRole authorities.
- Enable ADMINISTRATOR role for ODIN_BOOTSTRAP_ADMIN_EMAIL .