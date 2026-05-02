# Spring Security 6 + OAuth 2.0 (Google PKCE)

Non-Obvious Traps vs. ASP.NET Core:
1. CSRF Protection: ASP.NET Core requires explicit [ValidateAntiForgeryToken]. Spring Security enables CSRF by default for all POST/PUT/DELETE requests. For an Angular SPA, you must configure Spring to expose the CSRF token in a cookie (CookieCsrfTokenRepository) so Angular's HttpClient can automatically attach it to the X-XSRF-TOKEN header.
2. Auth Magic: .AddGoogle() in .NET hides the protocol. Spring requires explicitly defining Google in application.yml under spring.security.oauth2.client.registration.
3. SameSite Cookies: Spring Session does not default to SameSite=Strict. It must be explicitly configured via a CookieSerializer bean.

SecurityFilterChain Snippet:

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/**", "/actuator/health").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2Login(oauth2 -> oauth2
                .authorizationEndpoint(authEndpoint -> authEndpoint
                    .authorizationRequestResolver(pkceResolver(clientRegistrationRepository()))
                )
            )
            .csrf(csrf -> csrf
                .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                .csrfTokenRequestHandler(new CsrfTokenRequestAttributeHandler())
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
            );

        return http.build();
    }
}