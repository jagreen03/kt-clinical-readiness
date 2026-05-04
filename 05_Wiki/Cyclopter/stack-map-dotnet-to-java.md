# Stack Map — .NET → Java / Spring Boot

**Status:** seed — to be expanded across sagas as you encounter actual translation friction. Do not pre-fill from training data; this should grow from real work.

## Concept-level mapping

| .NET concept | Java/Spring equivalent | Notes |
|---|---|---|
| ASP.NET Core MVC | Spring MVC (or Spring WebFlux for reactive) | Spring MVC is your default for Clinical given JSP target |
| Controllers + Action Filters | `@RestController` / `@Controller` + Spring Interceptors / `@Aspect` | Filters → interceptors; richer behavior via AOP |
| `Startup.cs` / `Program.cs` | `@SpringBootApplication` main + `@Configuration` classes | Auto-config replaces explicit DI registration |
| `appsettings.json` | `application.yml` (or `.properties`) + Spring Profiles | Profiles parallel ASP.NET environment names |
| DI built-in | Spring DI (constructor injection preferred) | Same patterns; annotations differ |
| Entity Framework Core | Spring Data JPA (relational) / Spring Data MongoDB (document) | Repositories generated from interfaces — `JpaRepository`, `MongoRepository` |
| LINQ | Java Streams + JPA Criteria / QueryDSL | Streams are functionally close; QueryDSL is the LINQ-like DSL |
| `IHostedService` / Background Service | `@Scheduled` / Spring Batch / `ApplicationRunner` | For long-running, Spring Batch is the heavyweight |
| ASP.NET Core Identity | Spring Security + Spring Authorization Server (or Keycloak) | OAuth 2.0 + PKCE story is mature here |
| `IOptions<T>` | `@ConfigurationProperties` | Type-safe config binding |
| Serilog + structured logs | SLF4J + Logback / Logstash encoder | `MDC` is the parallel to `LogContext` |
| xUnit / NUnit | JUnit 5 + Mockito + AssertJ | AssertJ is closest to FluentAssertions |
| Razor Views | JSP (Clinical target) or Thymeleaf (more common modern default) | JSP is server-side templating with scriptlets — older idiom; clarify why Clinical still uses it |
| SignalR | Spring WebSockets / STOMP | Less batteries-included; you assemble more |
| Blazor | Angular or React (per Clinical stack) | Not a direct mapping; presentation layer is genuinely different |

## Library-level mapping

| .NET library | Java equivalent |
|---|---|
| Newtonsoft.Json / System.Text.Json | Jackson |
| AutoMapper | MapStruct |
| Polly | Resilience4j |
| MediatR | Spring's `ApplicationEventPublisher` or Axon |
| FluentValidation | Bean Validation (Jakarta Validation) + Hibernate Validator |
| Dapper | Spring JDBC + JdbcTemplate / NamedParameterJdbcTemplate |
| Hangfire / Quartz.NET | Quartz (same project, JVM origin) or Spring Batch |

## OAuth 2.0 + PKCE — your specific case

Your existing `BlueSand.RiverHorse.Gateway` (.NET 9 ASP.NET Core MVC BFF + Google OAuth 2.0 + PKCE) translates to:

- **BFF host:** Spring Boot 3.x with `spring-boot-starter-oauth2-client` and `spring-boot-starter-oauth2-resource-server` (BFF talks to your IDP and exposes session-cookie + signed-token APIs to the Angular SPA).
- **IDP:** Spring Authorization Server (Java native, current) OR Keycloak (containerized, the de facto enterprise choice).
- **PKCE:** built-in to `spring-security-oauth2-client` — set `client.authentication-method: none` and `code-challenge-method: S256`.
- **SPA:** Angular with `@auth0/angular-oauth2-oidc` or `angular-auth-oidc-client` for the front-channel auth code flow.
- **Cookie strategy:** mirror your .NET version — HttpOnly + SameSite=Lax for session, short-lived access tokens proxied by the BFF, refresh tokens never leaving the server.

## What this map is NOT

Not a tutorial. Not a training corpus. This is a translation lookup for moments when you hit something in Spring and want to ask "what's the .NET-shaped name for this?" or vice versa. Expand as you go; mark entries with caveats when the mapping isn't clean.



## [2026-05-02] KTS-0000006: BFF Architectural Mapping

| ASP.NET Core (.NET 9) | Spring Boot 3.x (Java 21) | Architectural Notes |
| :--- | :--- | :--- |
| Program.cs (Top-level) | @SpringBootApplication class | Java retains public static void main(String[] args) entry point. |
| IMiddleware | OncePerRequestFilter | Extends OncePerRequestFilter to guarantee single execution per dispatch. |
| appsettings.json | application.yml | YAML is standard in Spring vs JSON in .NET. |
| IOptions<T> | @ConfigurationProperties | Binds YAML branches to POJOs. Requires @EnableConfigurationProperties. |
| AddTransient/Scoped/Singleton | @Component, @RequestScope, @Scope("prototype") | Spring is Singleton by default. Scoped/Transient require annotations. |
| IHostedService / BackgroundService | @Scheduled or ApplicationRunner | ApplicationRunner for startup. @Scheduled for recurring timers. |
| IActionFilter | HandlerInterceptor or AOP (@Around) | AspectJ is more idiomatic in Spring for cross-cutting controller concerns. |
| HttpClientFactory | RestClient | RestClient (introduced in Spring 3.2) replaces RestTemplate and WebClient for sync. |
