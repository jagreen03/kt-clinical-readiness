# KTS-0000007 Pass 2: Security Config & Pom Revisions

## Decisions & Architecture Notes

* **Spring Boot Version**: Pinned to `4.0.5` per Pilot arbitration.
* **Resilience4j Deferral**: Dropped `resilience4j-spring-boot3` from `pom.xml`. The 4.x/Framework 7 compatibility is unverified at this time, so to avoid a blocked compile state, we are shipping A-#4 without the `@CircuitBreaker` and `@Bulkhead` annotations. This is an accepted gap in the saga record.
* **AOP Dependency**: `spring-boot-starter-aop` added unconditionally.
* **Spring Session Addition**: Pilot requested a `CookieSerializer` bean to explicitly set `SameSite=Lax`. `CookieSerializer` is a Spring Session API interface (`org.springframework.session.web.http.CookieSerializer`). I added `spring-session-core` to `pom.xml` to satisfy the compilation requirement for this bean.
* **Spring Security 7 Deltas**: 
  - `GatewayApplication.java` compiles identically; the boot entrypoint is unchanged in 4.x.
  - The lambda DSL for `HttpSecurity` configuration (e.g., `authorizeHttpRequests(auth -> ...)`) is strictly enforced in Spring Security 7. The deprecated chaining methods from early 6.x are physically removed, but our KTS-0000006 baseline was already using the lambda DSL, so no structural refactoring was required.
  - `DefaultOAuth2AuthorizationRequestResolver` and `OAuth2ParameterNames` APIs are stable and present with the same signatures in Spring Security 7.

## Claude Review Fixes Applied
* PKCE A-#2 (a): `StandardCharsets.US_ASCII` applied to `getBytes()` inside the customizer.
* PKCE A-#2 (b): `OAuth2ParameterNames.CODE_VERIFIER` used for the attribute key instead of a literal string.
* Happy-path A-#3 (a): Implicit default callback path used; no `loginProcessingUrl` override.
* Happy-path A-#3 (b): `.sessionFixation(fixation -> fixation.migrateSession())` explicitly declared.
* Happy-path A-#3 (c): `CookieSerializer` bean declared with `.setSameSite("Lax")`.