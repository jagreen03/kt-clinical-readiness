# KTS-0000006: application.yml - Claude Review (A-#1)

Path: 03_Synthesis/2026-05-02_KTS-0000006_application-yml-review.md
Reviewer: Claude
Subject: 2026-05-02_KTS-0000006_application-yml.md (Cynthia A. River)
Verdict: Accepted with Pilot resolutions applied.

## Strengths

- Hardened defaults across the board. include-stacktrace=never, include-message=never, actuator exposure limited to health, show-details=never.
- SameSite=lax with explicit justification (strict would break the 302 from Google). Resolves the SameSite ambiguity flagged in the security-config first pass.
- Multi-file profile separation (application.yml + application-dev.yml) over multi-document separator syntax. More idiomatic in Spring Boot 3.x.
- user-name-attribute: sub is correct. Google's "name" and "email" claims can change; "sub" is the stable canonical user ID.
- issuer-uri delegates endpoint discovery to Google's openid-configuration discovery document. Resilient to IdP endpoint changes.
- Env var injection pattern for client-id and client-secret, never hardcoded.

## Pilot Resolutions Applied

Three items were raised in review. All resolved by the Pilot prior to landing this review file.

1. redirect-uri inconsistency. Cynthia's value resolves to Spring's default /login/oauth2/code/google, contradicting the saga's earlier deliverables which specify /auth/callback. Pilot chose Path B: accept the Spring default. Rationale: less configuration surface, framework-idiomatic, no security or functional value lost. Follow-up: bff-endpoints.md and happy-path-trace.md will be amended to reflect Path B in a small post-saga cleanup pass.

2. Cookie persistence vs session timeout mismatch. Server-side timeout was 30m, cookie max-age was 8h. Pilot chose Option B: drop max-age entirely. Cookie becomes a session cookie, dies with browser. Simplest BFF model. Amendment applied via amend-applicationyml-kts0000006.ps1.

3. Scope format. Cynthia used comma-separated string. Pilot adopted YAML list syntax for idiomatic clarity. Amendment applied via amend-applicationyml-kts0000006.ps1.

## Known Mitigation Logged

A Gemini web client rendering bug surfaced during this slice: chat-rendered output occasionally wraps URLs in markdown link syntax that does not exist in the actual emitted file content. Verification pattern going forward: when reviewing URL or special-character content in Cynthia's output, always check the file on disk, never trust chat rendering.

A second clipboard-side bug also surfaced: copy-paste from chat output through some clipboard tool wraps filenames and URLs in markdown link syntax. This broke a PowerShell heredoc in this slice. Mitigation: prefer manual Notepad save for review files going forward; reserve PowerShell scripts for mechanical filesystem operations only.

## Doctrine Note: Standalone File Emission

Cynthia emitted application-dev.yaml as a standalone file in addition to the markdown. Second occurrence of this pattern (A-#2 emitted standalone .java files). Pilot decision: accept and live with extras in Downloads. The doctrine reminder in prompts may not be steerable via Gemini's emission behavior. Cost is one ignored file per pass; not worth fighting.

## Forward Note

When the project skeleton is bootstrapped (KTS-0000007 candidate), both YAML files land at the project resources directory under 04_Applications/riverhorse-gateway-spring.

## Disposition

Cynthia's application-yml.md plus Pilot's two amendments are canonical. This review file documents the synthesis-pass decisions for saga record continuity.