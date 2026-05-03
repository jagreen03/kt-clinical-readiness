# KTS-0000007 Pass 1: Project Skeleton & Dependency Bootstrap

## Decisions & Architecture Notes

* **Spring Boot Version**: Pinned to `3.2.5`. Rationale: Current stable GA in the 3.2.x LTS-aligned track. Offers robust Java 21 virtual thread support out-of-the-box without bleeding-edge milestone risks.
* **Resilience4j Version**: Pinned to `2.2.0` via `resilience4j-spring-boot3`. Rationale: Version 2.2.x is specifically compiled for Spring Boot 3 / Jakarta EE namespaces and integrates cleanly with Spring Boot 3.2.x autoconfiguration.
* **Test Dependencies**: The standard `spring-boot-starter-test` transitive dependency tree (JUnit Jupiter 5.x, AssertJ, Mockito) is entirely sufficient for the required JUnit/Spring Boot smoke testing and MockMvc controller layers. No explicit test library additions are required.
* **Minimal Valid Placeholder Definition**: 
  - `.java` files: Contain standard package declarations and empty class definitions (except `GatewayApplication` which includes the bare minimum `main` execution method to satisfy application context loading in tests).
  - `.yml` files: Empty. Spring Boot permits empty configuration files without failing initialization.
  - `.md` files: Standard markdown header.
* **Cross-Renderer Syntax Drift (CRSD)**: Verified ASCII-only generation.

## Scaffold Structure

```text
riverhorse-gateway-spring/
  pom.xml
  README.md
  .gitignore
  src/main/java/com/bluesand/riverhorse/gateway/
    GatewayApplication.java
    config/
      SecurityConfig.java
      ProxyRouteProperties.java
    controllers/
      AuthController.java
      ProxyController.java
  src/main/resources/
    application.yml
    application-dev.yml
  src/test/java/com/bluesand/riverhorse/gateway/
    GatewayApplicationTests.java