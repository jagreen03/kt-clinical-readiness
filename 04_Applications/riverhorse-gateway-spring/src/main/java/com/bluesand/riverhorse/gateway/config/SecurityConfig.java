package com.bluesand.riverhorse.gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AnonymousAuthenticationFilter;
import org.springframework.security.web.context.SecurityContextHolderFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            VerificationFreshnessFilter freshnessFilter,
            PersonaSelectionFilter personaFilter) throws Exception {

        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/", "/error", "/favicon.ico", "/branding/**").permitAll()
                .requestMatchers("/persona/**").authenticated()       // any logged-in user can pick
                .requestMatchers("/api/me", "/persona/me").authenticated()
                .requestMatchers("/admin/**").hasRole("ADMINISTRATOR")
                .requestMatchers("/dev/**").hasRole("LEAD_DEVELOPER")
                .anyRequest().authenticated()
            )
            .oauth2Login(oauth -> oauth
                // existing /api/me-driving config preserved here
            )
            .logout(logout -> logout
                .logoutSuccessUrl("/")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            )
            // Order: freshness gate first, then persona narrowing
            .addFilterAfter(freshnessFilter, SecurityContextHolderFilter.class)
            .addFilterAfter(personaFilter, VerificationFreshnessFilter.class);

        return http.build();
    }
}