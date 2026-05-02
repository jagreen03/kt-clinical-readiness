# KTS-0000006: BFF End-to-End Happy-Path Trace (A-#3)

```mermaid
sequenceDiagram
    participant SPA as Angular SPA (Browser)
    participant BFF as Spring Boot BFF
    participant Google as Google IdP

    SPA->>BFF: 1. GET /auth/login
    BFF->>SPA: 2. 302 Redirect to Google (with PKCE, State, Nonce)
    SPA->>Google: 3. User Authenticates (Black Box)
    Google->>SPA: 4a. 302 Redirect to /auth/callback?code=...&state=...
    SPA->>BFF: 4b. GET /auth/callback?code=...&state=...
    BFF->>Google: 4c. POST /token (code + code_verifier)
    Google->>BFF: 5. Token Response (id_token, access_token)
    BFF->>BFF: 6. Session Creation & CSRF Token Issue
    BFF->>SPA: 7. 302 Redirect to SPA Root (Set-Cookie)
    SPA->>BFF: 8. GET /api/me (JSESSIONID, X-XSRF-TOKEN)
    BFF->>SPA: 9. 200 OK (JSON Claims)