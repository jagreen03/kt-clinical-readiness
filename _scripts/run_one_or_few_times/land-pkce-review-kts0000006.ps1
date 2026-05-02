$vault = "C:\ICS-LT-FYXFHG4\KT\clinical\Readiness"
$reviewPath = Join-Path $vault "03_Synthesis\2026-05-02_KTS-0000006_pkce-resolver-review.md"

$reviewContent = @'
# KTS-0000006: PKCE Resolver - Claude Review (A-#2)

**Path:** 03_Synthesis/2026-05-02_KTS-0000006_pkce-resolver-review.md
**Reviewer:** Claude
**Subject:** 2026-05-02_KTS-0000006_pkce-resolver.md (Cynthia A. River)
**Verdict:** Accept with three addenda. None structural.

## Strengths

* Confidential client question answered correctly. Defense-in-depth framing matches OAuth 2.0 BCP guidance. The "why force PKCE" answer is the question a senior interviewer asks first; this is the right answer.
* Verifier length choice (96 bytes, ~128 base64url chars) is defensible per RFC 7636 and maximizes entropy within the spec.
* Repository class named correctly: HttpSessionOAuth2AuthorizationRequestRepository. This is where the verifier lives between the auth request and the token exchange.
* Nonce vs PKCE distinction is clean and accurate. Different threat models (id_token replay vs code interception), both needed.
* attributes() vs additionalParameters() split is correct. Verifier in attributes (server-side, persisted), challenge in additionalParameters (URL to Google).

## Gap 1: Charset bug on getBytes()

```java
byte[] digest = md.digest(codeVerifier.getBytes());
```

This uses the platform default charset. RFC 7636 specifies ASCII for the code verifier. Fix:

```java
import java.nio.charset.StandardCharsets;

byte[] digest = md.digest(codeVerifier.getBytes(StandardCharsets.US_ASCII));
```

Works on every reasonable JVM today because base64url output is ASCII-safe, but it relies on undefined behavior. One-line fix, zero runtime cost.

## Gap 2: Use the framework constant for code_verifier

```java
customizer.attributes(attrs -> attrs.put("code_verifier", codeVerifier));
```

The string literal works because Spring's own retrieval logic uses the same value. But Spring exposes this as a constant: `OAuth2ParameterNames.CODE_VERIFIER`. Match framework idiom:

```java
import org.springframework.security.oauth2.core.endpoint.OAuth2ParameterNames;

customizer.attributes(attrs ->
    attrs.put(OAuth2ParameterNames.CODE_VERIFIER, codeVerifier));
```

Same value, but signals familiarity with the API surface and survives any future constant rename in framework releases.

## Gap 3: Currency check on Spring Security version

The hand-rolled resolver pattern is canonical for Spring Security 5.2 through 6.0-6.2. Spring Security has continued to evolve PKCE support since; the version pulled in by your target Spring Boot 3.x dependency may offer a simpler toggle for confidential clients now.

Before locking in this implementation:
1. Check the Spring Security version transitively pulled by your chosen Spring Boot 3.x BOM.
2. Read the OAuth2 client release notes for that version's PKCE changes.
3. If a one-liner exists for confidential-client PKCE, document both patterns. The hand-rolled version retains interview-defense value because it teaches the cryptographic mechanics that a `.pkce(true)` toggle hides.

Treat this as a verification step, not a blocker. Cynthia's resolver is correct for any modern Spring Security 6.x; the question is whether it is the *idiomatic* choice for the latest release.

## Forward Note

When the project skeleton is bootstrapped (KTS-0000007 candidate), the SecurityConfig class lands at:

  04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/config/SecurityConfig.java

Cynthia emitted standalone .java files in this saga which were not slotted - their content is already canonical inside this synthesis markdown. Doctrine going forward: code stays in markdown code fences during synthesis. It moves to the project tree only when the project tree exists.

## Disposition

Cynthia's pkce-resolver.md accepted as canonical first-pass artifact. This review file lives alongside as the synthesis layer's notes. The two redundant .java files in the user's Downloads folder are not committed and are scheduled for local deletion at the user's discretion.
'@

Set-Content -Path $reviewPath -Value $reviewContent -Encoding UTF8

Set-Location $vault
git add -A
git commit -m "KTS-0000006: A-#2 review notes (Claude synthesis pass)"
git push

Write-Host "Done."