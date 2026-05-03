# KTS-0000007 Pass 4: Controllers & Routing Implementation

## Decisions & Architecture Notes

* **Source Confirmation**: Applied literal transcription from KTS-0000006 A-#3 and A-#4 syntheses.
* **RestClient Configuration Location**: Configured via a separate `@Configuration` class (`RestClientConfig.java`). This keeps the controller clean of builder boilerplate, handles the `@EnableConfigurationProperties` wiring for the proxy routes, and makes the customized client available for potential future consumers.
* **Spring Boot 4 / Framework 7 API Checks**: 
  - `HttpMethod` in Spring Framework 6+ is a class, not an enum. The `.name()` method used in the allowlist check remains valid and stable. 
  - `RestClient` API is fully stable since its introduction in 6.1. 
  - `@AuthenticationPrincipal OidcUser` remains the correct idiom for extracting upstream Google IdP claims.
* **Resilience4j**: As arbitrated in Pass 2, `@CircuitBreaker` and `@Bulkhead` annotations are omitted pending Spring Boot 4 compatibility verification.
* **Pass 2 Failure Handler**: Added to `SecurityConfig.java` within the `oauth2Login` DSL block, returning the requested `{"error":"authentication_failed"}` JSON.

## A-#4 Proxy Review Fixes Mapped

1. **Hop-by-hop Filtering**: `HOP_BY_HOP` and `SUPPRESS` static sets defined at the top of `ProxyController`. Applied to incoming request headers and downstream response headers.
2. **Body Buffering Limitation**: Javadoc added to `ProxyController` class level explicitly naming the `byte[]` memory limitation and citing `InputStreamResource` / `StreamingResponseBody` as the production path.
3. **serviceId Regex Validation**: `^[a-zA-Z0-9-]{1,32}$` pattern applied immediately upon method entry, yielding 400 Bad Request on failure.
4. **HTTP Method Allowlist**: `ALLOWED_METHODS` set expanded to include GET, POST, PUT, DELETE, PATCH, and HEAD. Yields 405 Method Not Allowed on failure.
5. **Null-Safety on OidcUser**: Defensive check implemented yielding 401 `{"error":"authentication_required"}` JSON if the principal is null.

## Pass 5 YAML Prerequisites

The `ProxyRouteProperties` record requires the following keys to be added to `application.yml` in Pass 5:

```yaml
proxy:
  internal-api-key: ${INTERNAL_API_KEY}
  services:
    clinical: [https://clinical-internal.example.com](https://clinical-internal.example.com)
    # Add other services as needed