package com.bluesand.riverhorse.gateway.controllers;

import com.bluesand.riverhorse.gateway.config.ProxyRouteProperties;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClient;
import jakarta.servlet.http.HttpServletRequest;

import java.util.Collections;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * ProxyController routes requests to downstream internal services.
 *
 * LIMITATION: Body buffering. Currently uses byte[] for inbound and outbound bodies,
 * buffering the entire payload in memory. For production scale with large payloads,
 * migrate to InputStreamResource / StreamingResponseBody to stream data directly.
 */
@RestController
public class ProxyController {

    private static final Pattern SERVICE_ID_PATTERN = Pattern.compile("^[a-zA-Z0-9-]{1,32}$");
    
    private static final Set<String> ALLOWED_METHODS = Set.of(
        "GET", "POST", "PUT", "DELETE", "PATCH", "HEAD"
    );

    private static final Set<String> HOP_BY_HOP = Set.of(
        "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
        "te", "trailer", "transfer-encoding", "upgrade"
    );

    private static final Set<String> INBOUND_BLOCK = Set.of(
        "cookie", "authorization"
    );

    private static final Set<String> SUPPRESS = Set.of(
        "content-length", "server", "x-powered-by"
    );

    private final RestClient restClient;
    private final ProxyRouteProperties proxyRoutes;

    public ProxyController(RestClient proxyRestClient, ProxyRouteProperties proxyRoutes) {
        this.restClient = proxyRestClient;
        this.proxyRoutes = proxyRoutes;
    }

    @RequestMapping("/api/proxy/{serviceId}/**")
    public ResponseEntity<?> proxy(
            @PathVariable String serviceId,
            @RequestBody(required = false) byte[] body,
            HttpMethod method,
            HttpServletRequest request,
            @AuthenticationPrincipal OidcUser oidcUser) {

        if (oidcUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "authentication_required"));
        }

        if (!SERVICE_ID_PATTERN.matcher(serviceId).matches()) {
            return ResponseEntity.badRequest().body(Map.of("error", "invalid_service_id"));
        }

        if (!ALLOWED_METHODS.contains(method.name())) {
            return ResponseEntity.status(405).body(Map.of("error", "method_not_allowed"));
        }

        String baseUrl = proxyRoutes.services().get(serviceId);
        if (baseUrl == null) {
            return ResponseEntity.status(404).body(Map.of("error", "service_not_found"));
        }

        String path = request.getRequestURI().substring(("/api/proxy/" + serviceId).length());
        String query = request.getQueryString() != null ? "?" + request.getQueryString() : "";
        String targetUrl = baseUrl + path + query;

        RestClient.RequestBodySpec requestBuilder = restClient.method(method)
            .uri(targetUrl)
            .headers(headers -> {
                Collections.list(request.getHeaderNames()).forEach(headerName -> {
                    String lowerName = headerName.toLowerCase();
                    if (!HOP_BY_HOP.contains(lowerName) && !INBOUND_BLOCK.contains(lowerName)) {
                        headers.addAll(headerName, Collections.list(request.getHeaders(headerName)));
                    }
                });
                headers.set("X-Internal-Api-Key", proxyRoutes.internalApiKey());
                headers.set("X-User-Sub", oidcUser.getSubject());
            });

        if (body != null && body.length > 0) {
            requestBuilder.body(body);
        }

        return requestBuilder.exchange((clientRequest, clientResponse) -> {
            HttpHeaders responseHeaders = new HttpHeaders();
            clientResponse.getHeaders().forEach((name, values) -> {
                String lowerName = name.toLowerCase();
                if (!HOP_BY_HOP.contains(lowerName) && !SUPPRESS.contains(lowerName)) {
                    responseHeaders.addAll(name, values);
                }
            });
            
            byte[] responseBody = clientResponse.getBody().readAllBytes();
            
            return ResponseEntity.status(clientResponse.getStatusCode())
                    .headers(responseHeaders)
                    .body(responseBody);
        });
    }
}