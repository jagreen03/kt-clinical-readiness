package com.bluesand.riverhorse.gateway.identity;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/persona")
public class PersonaController {

    private final PersonaSelectionService personas;

    public PersonaController(PersonaSelectionService personas) {
        this.personas = personas;
    }

    /** Available personas for the current user + currently selected (if any). */
    @GetMapping("/options")
    public Map<String, Object> options(Authentication auth, HttpServletRequest request) {
        Set<UserRole> available = personas.availablePersonas(auth);
        return Map.of(
                "available", available,
                "selected", personas.selectedPersona(request).orElse(null),
                "multiRequiresChoice", available.size() > 1
        );
    }

    /** Picker landing endpoint — frontend renders the choice; backend returns options. */
    @GetMapping("/select")
    public Map<String, Object> picker(Authentication auth, HttpServletRequest request) {
        return options(auth, request);
    }

    /** Commit a persona choice for this session. */
    @PostMapping("/select")
    public ResponseEntity<Map<String, Object>> commit(
            @RequestBody PersonaChoice choice,
            Authentication auth,
            HttpServletRequest request) {

        Set<UserRole> available = personas.availablePersonas(auth);
        UserRole requested;
        try {
            requested = UserRole.valueOf(choice.role());
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(Map.of("error", "unknown role"));
        }

        if (!available.contains(requested)) {
            return ResponseEntity.status(403).body(Map.of("error", "role not assigned to user"));
        }

        personas.selectPersona(request, requested);
        return ResponseEntity.ok(Map.of("selected", requested));
    }

    /** Identity probe — frontend tri-state signals consume this. */
    @GetMapping("/me")
    public Map<String, Object> me(@AuthenticationPrincipal OidcUser oidc,
                                  Authentication auth,
                                  HttpServletRequest request) {
        if (oidc == null) {
            return Map.of("authenticated", false);
        }
        return Map.of(
                "authenticated", true,
                "email", oidc.getEmail(),
                "fullName", oidc.getFullName(),
                "available", personas.availablePersonas(auth),
                "selected", personas.selectedPersona(request).orElse(null)
        );
    }

    public record PersonaChoice(String role) {}
}