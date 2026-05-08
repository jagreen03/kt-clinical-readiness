package com.bluesand.riverhorse.gateway.config;

import com.bluesand.riverhorse.gateway.identity.PersonaSelectionService;
import com.bluesand.riverhorse.gateway.identity.UserRole;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Optional;
import java.util.Set;

/**
 * Enforces the single-persona-per-session invariant.
 *
 * - 0 personas: pass through (caller will land at guest-landing-path).
 * - 1 persona: auto-select; no picker.
 * - 2+ personas, no selection, request not on picker path: redirect to picker.
 * - 2+ personas, selection present: narrow authorities to the chosen persona.
 *
 * Switching personas requires logout/login. The filter does not promote
 * mid-session changes; that is the One-Way Ticket invariant.
 */
@Component
public class PersonaSelectionFilter extends OncePerRequestFilter {

    private final PersonaSelectionService personas;
    private final String pickerPath;

    public PersonaSelectionFilter(
            PersonaSelectionService personas,
            @Value("${odin.security.persona-picker-path:/persona/select}") String pickerPath) {
        this.personas = personas;
        this.pickerPath = pickerPath;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain)
            throws ServletException, IOException {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (!(auth instanceof OAuth2AuthenticationToken oauth) || !auth.isAuthenticated()) {
            chain.doFilter(request, response);
            return;
        }

        Set<UserRole> available = personas.availablePersonas(auth);

        if (available.isEmpty()) {
            // Guest path. ROLE_USER stays in place; no narrowing needed.
            chain.doFilter(request, response);
            return;
        }

        Optional<UserRole> selected;
        if (available.size() == 1) {
            UserRole only = available.iterator().next();
            personas.selectPersona(request, only);
            selected = Optional.of(only);
        } else {
            selected = personas.selectedPersona(request);
        }

        if (selected.isEmpty()) {
            // Multi-role user has not picked yet. Allow access to the picker only.
            String path = request.getRequestURI();
            if (path.startsWith(pickerPath) || path.startsWith("/persona/")) {
                chain.doFilter(request, response);
            } else {
                response.sendRedirect(pickerPath);
            }
            return;
        }

        // Narrow authorities to the chosen persona for this request.
        UserRole active = selected.get();
        OAuth2AuthenticationToken narrowed = new OAuth2AuthenticationToken(
                oauth.getPrincipal(),
                Set.<GrantedAuthority>of(new SimpleGrantedAuthority("ROLE_" + active.name())),
                oauth.getAuthorizedClientRegistrationId());
        narrowed.setDetails(oauth.getDetails());

        SecurityContextHolder.getContext().setAuthentication(narrowed);
        try {
            chain.doFilter(request, response);
        } finally {
            // Restore original auth so session-stored context isn't permanently mutated.
            SecurityContextHolder.getContext().setAuthentication(oauth);
        }
    }
}