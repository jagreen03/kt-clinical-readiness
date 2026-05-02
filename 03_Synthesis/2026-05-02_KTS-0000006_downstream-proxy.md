# KTS-0000006: Downstream Proxy Design (A-#4)

## 1. Token Strategy Decision
* Decision: Service-account credential with user claim header propagation (Option A).
* Rationale: For an interview-defense portfolio, this strikes the balance between demonstrable zero-trust mechanics and manageable infrastructure. The BFF acts as a confidential client. It strips the external Google context, authenticates itself to the downstream service using a static internal API key (or client credentials token), and asserts the user's identity via `X-User-Id` headers.
* Carelon-Scale Reality: At enterprise scale (healthcare/fintech), this transitions to Token Exchange (RFC 8693) backed by mTLS. The BFF would swap the external Google token for an internal, short-lived, audience-restricted JWT signed by an internal authorization server (Ping/Okta). Attempting to mock a full internal IdP in this portfolio piece dilutes the focus on the BFF itself.

## 2. Spring Cloud Gateway MVC vs. Hand-Rolled @RestController
* Decision: Hand-rolled `@RestController`.
* Rationale: Reversing the earlier mention of Spring Cloud Gateway. Gateway MVC is idiomatic for pure infrastructure routing driven by YAML. However, for a portfolio piece meant to defend a .NET-to-Java architectural translation, a hand-rolled proxy controller makes the HTTP mechanics (header stripping, context propagation, client usage) explicit and readable in code. It provides concrete artifacts to point to during an interview.

## 3. Route Mapping Pattern
* Pattern: `/api/proxy/{serviceId}/**`
* Approach: A dynamic map backed by `@ConfigurationProperties`. The controller captures the `{serviceId}` path variable and looks up the internal base URL from configuration. This avoids recompiling the BFF when a new internal service is added.

## 4. HTTP Client Choice
* Decision: `RestClient`.
* Rationale: Spring 3.2+ standard for synchronous, blocking execution. Since the BFF is built on the standard Servlet stack (Spring Web MVC) to map cleanly to ASP.NET Core MVC, pulling in `WebClient` would unnecessarily introduce Project Reactor dependencies and reactive paradigms into a blocking application. `RestClient` offers a fluent API over the standard Java HTTP Client.

## 5. Path and Header Forwarding Rules
* Strip Prefix: Yes. `/api/proxy/clinical/patients/123` strips `/api/proxy/clinical` and forwards `/patients/123` to the registered `clinical` service base URL.
* Block (Inbound -> Outbound):
  * `Cookie` (Never leak the SPA's `JSESSIONID` downstream).
  * `Authorization` (Never pass the external Google token or SPA's CSRF header downstream).
* Pass (Inbound -> Outbound):
  * `Content-Type`, `Accept`, `Accept-Language`.
* Inject (BFF -> Outbound):
  * `Authorization` (The BFF's internal service credential/API key).
  * `X-User-Id`, `X-User-Email` (Extracted from the Spring `SecurityContext`).
  * `X-Correlation-ID` (Generated if absent, passed through if present, for distributed tracing).

## 6. Resilience Minimums
* Timeouts: Must be explicitly configured on the `RestClient` underlying request factory. Hard defaults: 2 seconds connect timeout, 5 seconds read timeout. Infinite hanging is the primary cause of BFF thread pool exhaustion.
* Circuit Breakers: Resilience4j `@CircuitBreaker` and `@Bulkhead` annotations belong directly on the service layer class wrapping the `RestClient` execution, isolating failures per `{serviceId}`.

## 7. Error Handling
* Upstream Surfacing: If the downstream returns a 5xx, the BFF returns a generic 502 Bad Gateway to the SPA. Downstream 4xx (e.g., 404, 400 validation errors) are passed through to the SPA with their original status codes.
* Logging: Log the `X-Correlation-ID`, HTTP status, target URL, and execution time.
* Redaction: Never log the contents of the `Authorization` header, the user's raw token, or PII from the request/response body.

## 8. Sample Controller Method

```java
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestClient;

import java.util.UUID;

@RestController
@RequestMapping("/api/proxy")
public class ProxyController {

    private final RestClient restClient;
    private final ProxyRouteProperties routeProperties;

    public ProxyController(RestClient.Builder restClientBuilder, ProxyRouteProperties routeProperties) {
        this.restClient = restClientBuilder.build();
        this.routeProperties = routeProperties;
    }

    @RequestMapping(value = "/{serviceId}/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<byte[]> proxyRequest(
            @PathVariable String serviceId,
            HttpServletRequest request,
            HttpMethod method,
            @RequestBody(required = false) byte[] body,
            @AuthenticationPrincipal OidcUser user) {

        // 1. Lookup Target
        String targetBaseUrl = routeProperties.getServices().get(serviceId);
        if (targetBaseUrl == null) {
            return ResponseEntity.notFound().build();
        }

        // 2. Compute Downstream Path
        String prefix = "/api/proxy/" + serviceId;
        String remainingPath = request.getRequestURI().substring(prefix.length());
        String queryString = request.getQueryString() != null ? "?" + request.getQueryString() : "";
        String targetUrl = targetBaseUrl + remainingPath + queryString;

        // 3. Correlation ID
        String correlationId = request.getHeader("X-Correlation-ID");
        if (correlationId == null) {
            correlationId = UUID.randomUUID().toString();
        }

        // 4. Execute Forward
        return restClient.method(method)
                .uri(targetUrl)
                .headers(headers -> {
                    // Pass safe headers
                    if (request.getContentType() != null) headers.setContentType(org.springframework.http.MediaType.valueOf(request.getContentType()));
                    headers.set(HttpHeaders.ACCEPT, request.getHeader(HttpHeaders.ACCEPT));
                    
                    // Inject Identity and Auth
                    headers.set("X-User-Id", user.getSubject());
                    headers.set("X-User-Email", user.getEmail());
                    headers.set("X-Correlation-ID", correlationId);
                    headers.set(HttpHeaders.AUTHORIZATION, "Bearer " + routeProperties.getInternalApiKey());
                })
                .body(body == null ? new byte[0] : body)
                .exchange((clientRequest, clientResponse) -> {
                    // 5. Response Translation
                    return ResponseEntity.status(clientResponse.getStatusCode())
                            .headers(clientResponse.getHeaders())
                            .body(clientResponse.getBody().readAllBytes());
                });
    }
}