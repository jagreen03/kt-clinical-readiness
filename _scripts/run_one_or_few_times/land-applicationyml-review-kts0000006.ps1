$vault = "C:\ICS-LT-FYXFHG4\KT\clinical\Readiness"
$reviewPath = Join-Path $vault "03_Synthesis\2026-05-02_KTS-0000006_application-yml-review.md"

$reviewContent = @'
# KTS-0000006: application.yml - Claude Review (A-#1)

**Path:** 03_Synthesis/2026-05-02_KTS-0000006_application-yml-review.md
**Reviewer:** Claude
**Subject:** 2026-05-02_KTS-0000006_application-yml.md (Cynthia A. River)
**Verdict:** Accept with one critical verification, one architectural decision required, two minor addenda.

## Strengths

* Hardened defaults across the board. show-stacktrace=never, show-message=never, actuator exposure limited to health, show-details=never. These are the right production stances.
* SameSite=lax with explicit justification (strict would break the 302 from Google). Resolves the SameSite ambiguity flagged in the security-config first pass.
* Multi-file profile separation (application.yml + application-dev.yml) over multi-document `---` syntax. More idiomatic in Spring Boot 3.x.
* user-name-attribute: sub is correct. Google's "name" and "email" claims can change; "sub" is the stable canonical user ID.
* issuer-uri delegates endpoint discovery to Google's .well-known/openid-configuration. Resilient to IdP endpoint changes.
* Env var injection pattern for client-id and client-secret, never hardcoded.

## Critical: Verify issuer-uri syntax

Cynthia's response in chat rendered the issuer-uri line as: