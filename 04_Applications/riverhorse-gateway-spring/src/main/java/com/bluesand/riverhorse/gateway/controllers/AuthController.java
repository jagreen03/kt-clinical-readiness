package com.bluesand.riverhorse.gateway.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.Map;

@RestController
public class AuthController {

    @GetMapping("/api/me")
    public ResponseEntity<Map<String, Object>> me(@AuthenticationPrincipal OidcUser oidcUser) {
        if (oidcUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "authentication_required"));
        }

        return ResponseEntity.ok(Map.of(
            "sub", oidcUser.getSubject(),
            "email", oidcUser.getEmail(),
            "name", oidcUser.getFullName(),
            "roles", oidcUser.getAuthorities()
        ));
    }

    @PostMapping("/auth/logout")
    public ResponseEntity<Map<String, String>> logout(HttpServletRequest request, HttpServletResponse response) {
        new SecurityContextLogoutHandler().logout(
            request, 
            response, 
            SecurityContextHolder.getContext().getAuthentication()
        );
        return ResponseEntity.ok(Map.of("message", "logged_out"));
    }
}