# KTS-0000007 Pass 3: Application YAML Configuration

## Decisions & Architecture Notes

* **Source Confirmation**: Pulled baseline configuration from KTS-0000006 A-#1, applying Pilot resolutions (scope as YAML list, max-age dropped, issuer-uri unbracketed, implicit default redirect-uri for Path B).
* **Spring Boot 4.0 / Framework 7 Verification**: All targeted property paths remain stable in 4.0.5. No structural renames or deprecations affect our YAML footprint:
  - `server.servlet.session.*`: Stable.
  - `spring.security.oauth2.client.*`: Stable.
  - `spring.session.store-type`: Stable.
  - `management.endpoints.*`: Stable.
* **SameSite Resolution**: `server.servlet.session.cookie.same-site` is explicitly set to `lax`. This is the active enforcement mechanism in Spring Boot 3.x and 4.x. The `CookieSerializer` bean injected into `SecurityConfig.java` during Pass 2 is confirmed redundant and can be excised in a future cleanup pass.
* **Runtime Dependencies**: `mvn spring-boot:run` will fail context load unless the following environment variables are exported to the shell running the process:
  - `GOOGLE_OAUTH_CLIENT_ID`
  - `GOOGLE_OAUTH_CLIENT_SECRET`