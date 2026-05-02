# KTS-0000006: Spring Boot BFF application.yml (A-#1)

```yaml
# application.yml (Base / Production Default)
server:
  port: 8080
  servlet:
    session:
      # How long a BFF session lives before forcing re-auth if idle.
      timeout: 30m
      cookie:
        name: BFF_SESSION
        http-only: true
        # Secure must be true in production (requires HTTPS).
        secure: true
        # SameSite was noted as undefaulted in earlier passes. 
        # Must be 'lax'. 'strict' will break the 302 redirect back from Google.
        same-site: lax
  error:
    # Hardened defaults to prevent stack trace or message leakage on 500s.
    include-stacktrace: never
    include-message: never
    include-exception: false

spring:
  application:
    name: riverhorse-gateway-spring
  session:
    # Default to standard servlet in-memory session. Override to 'redis' in prod.
    store-type: none 
  security:
    oauth2:
      client:
        registration:
          google:
            # Never hardcode. Injected via environment variables at runtime.
            client-id: ${GOOGLE_OAUTH_CLIENT_ID}
            client-secret: ${GOOGLE_OAUTH_CLIENT_SECRET}
            # OIDC standard scopes. offline_access omitted as BFF does not perform background syncing.
            scope:
              - openid
              - profile
              - email
            # Standard Spring Boot template. {action} resolves to 'login'.
            redirect-uri: "{baseUrl}/{action}/oauth2/code/{registrationId}"
            authorization-grant-type: authorization_code
        provider:
          google:
            # Using issuer-uri delegates endpoint discovery to Google's .well-known/openid-configuration.
            # Superior to hardcoding authorization/token endpoints manually.
            issuer-uri: [https://accounts.google.com](https://accounts.google.com)
            user-name-attribute: sub

management:
  endpoints:
    web:
      exposure:
        # Expose ONLY health in base/prod config to prevent actuator data leaks.
        include: health
  endpoint:
    health:
      show-details: never

logging:
  level:
    root: INFO
    org.springframework.security: INFO
    org.springframework.security.oauth2: INFO