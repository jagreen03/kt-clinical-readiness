# KTS-0000006: Downstream Proxy - Claude Review (A-#4)

Path: 03_Synthesis/2026-05-02_KTS-0000006_downstream-proxy-review.md
Reviewer: Claude
Subject: 2026-05-02_KTS-0000006_downstream-proxy.md (Cynthia A. River)
Verdict: Accepted with three real gaps and two minor notes. None structural.

## Strengths

- Token strategy decision is the right one for portfolio-defense scope. Service-account credential plus user claim header propagation gives interviewable mechanics without infrastructure overengineering.
- The Carelon-scale forward-look (RFC 8693 token exchange, mTLS, internal authorization server) is the kind of senior-vs-mid distinction that lands in interviews. Keep this paragraph; it shows the candidate has thought past the demo.
- Spring Cloud Gateway MVC reversal in favor of hand-rolled @RestController is correct for portfolio-visibility goals. The HTTP mechanics are visible in code rather than buried in YAML.
- RestClient choice is right. The BFF is a Servlet-stack blocking application; pulling Reactor in for one proxy would be architectural malpractice.
- Header allow/block/inject taxonomy is clean. Cookie and Authorization correctly identified as inbound-block.
- Resilience4j placement (service layer wrapping RestClient, per-serviceId circuit breaker) is the idiomatic location. Bulkhead callout is good.
- Correlation ID handling (generate if absent, pass through if present) matches modern observability practice.

## Gap 1: Hop-by-hop response header leak

The controller returns clientResponse.getHeaders() directly to the SPA without filtering. Two problem classes:

Hop-by-hop headers per RFC 7230 must not propagate across a proxy hop: Connection, Keep-Alive, Transfer-Encoding, TE, Trailer, Upgrade, Proxy-Authorization, Proxy-Authenticate. These are connection-scoped.

Information-leak headers reveal internal architecture to anyone with browser dev tools open: Server, X-Powered-By, internal trace or service identifiers.

Fix is one filtered copy on the response side, mirroring the inbound block list pattern. The inbound side is correctly handled; the outbound side is not. Asymmetric defense is the issue worth naming.

Suggested addition to the controller:

    private static final Set<String> HOP_BY_HOP = Set.of(
        "connection", "keep-alive", "transfer-encoding", "te",
        "trailer", "upgrade", "proxy-authorization", "proxy-authenticate"
    );

    private static final Set<String> SUPPRESS = Set.of(
        "server", "x-powered-by"
    );

Then in the response builder, copy headers selectively rather than wholesale.

## Gap 2: Body buffering on both ends

Both inbound (@RequestBody byte[]) and outbound (clientResponse.getBody().readAllBytes()) fully buffer in memory.

For a clinical or healthcare proxy this matters: lab result PDFs, imaging payloads, large FHIR bundles. Two failure modes:

- OOM under load when several large requests buffer simultaneously.
- Latency spike on first byte. The SPA waits for the entire downstream response before any byte ships, defeating any downstream streaming.

Not a blocker for the synthesis-pass artifact. Worth naming as a known limitation of the illustrative implementation with a forward-pointer to streaming via InputStreamResource or StreamingResponseBody. The interview defense answer to "what breaks at scale" needs this callout in the back pocket.

## Gap 3: serviceId validation

The map lookup checks for null but not for shape:

    String targetBaseUrl = routeProperties.getServices().get(serviceId);
    if (targetBaseUrl == null) {
        return ResponseEntity.notFound().build();
    }

If a malformed serviceId bypasses Spring's path normalization (URL-encoded slashes, traversal sequences), the prefix-strip substring arithmetic can produce bizarre forwarded URLs. Spring 6 path normalization is generally robust but defense-in-depth says: validate serviceId against the configured map keys as the first thing the method does, and reject anything that does not match a strict character class such as a-z, A-Z, 0-9, dash, length 1-32.

Treat this as belt-and-suspenders. The map lookup catches unregistered service IDs; the regex catches malformed input before it reaches the lookup.

## Minor 1: HTTP method allowlist incomplete

The @RequestMapping declares GET, POST, PUT, DELETE but omits PATCH and HEAD. Modern REST APIs use PATCH for partial updates and clinical services certainly will. Add both. OPTIONS is typically handled by Spring's CORS layer separately.

## Minor 2: Null-safety on @AuthenticationPrincipal

If user is null at the method (the authorization filter should prevent this, but defense-in-depth), the user.getSubject() and user.getEmail() calls will NPE and surface a 500 to the SPA. A null-check returning 401 is more correct than relying on filter-chain guarantees. The controller method should be defensible standalone.

## Forward Note

When the project skeleton is bootstrapped (KTS-0000007 candidate), the controller class lands at:

  04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/controllers/ProxyController.java

The ProxyRouteProperties @ConfigurationProperties class lands beside it in a config package.

## Disposition

Cynthia's downstream-proxy.md accepted as canonical first-pass artifact. The three gaps are interview-defense material rather than blockers; they should be folded into the implementation when the project tree is bootstrapped, not retrofitted into the synthesis markdown. This review file documents the synthesis-pass decisions for saga record continuity.