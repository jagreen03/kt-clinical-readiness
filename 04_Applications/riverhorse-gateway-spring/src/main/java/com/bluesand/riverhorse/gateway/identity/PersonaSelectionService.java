package com.bluesand.riverhorse.gateway.identity;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Single source of truth for the user's currently active persona.
 *
 * Persona selection is HTTP-session-scoped. Logout clears the session, which
 * forces a fresh selection on next login (the One-Way Ticket invariant).
 */
@Service
public class PersonaSelectionService {

    public static final String SESSION_KEY = "odin.selected.persona";

    /** All personas a user holds, derived from their current authorities. */
    public Set<UserRole> availablePersonas(Authentication auth) {
        if (auth == null) return Set.of();
        return auth.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .filter(a -> a.startsWith("ROLE_"))
                .map(a -> a.substring("ROLE_".length()))
                .filter(PersonaSelectionService::isKnownRole)
                .map(UserRole::valueOf)
                .collect(Collectors.toSet());
    }

    public Optional<UserRole> selectedPersona(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return Optional.empty();
        Object raw = session.getAttribute(SESSION_KEY);
        return raw instanceof UserRole role ? Optional.of(role) : Optional.empty();
    }

    public void selectPersona(HttpServletRequest request, UserRole role) {
        request.getSession(true).setAttribute(SESSION_KEY, role);
    }

    public void clearPersona(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) session.removeAttribute(SESSION_KEY);
    }

    private static boolean isKnownRole(String name) {
        try {
            UserRole.valueOf(name);
            return true;
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }
}