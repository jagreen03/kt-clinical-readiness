package com.bluesand.riverhorse.gateway.config;

import com.bluesand.riverhorse.gateway.identity.RoleAssignment;
import com.bluesand.riverhorse.gateway.identity.RoleAssignmentRepository;
import com.bluesand.riverhorse.gateway.identity.User;
import com.bluesand.riverhorse.gateway.identity.UserRepository;
import com.bluesand.riverhorse.gateway.identity.UserRole;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.authority.mapping.GrantedAuthoritiesMapper;
import org.springframework.security.oauth2.core.oidc.OidcIdToken;
import org.springframework.security.oauth2.core.oidc.user.OidcUserAuthority;

import java.time.LocalDateTime;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.Set;
import java.util.stream.Collectors;

@Configuration
public class RoleMappingConfig {

    @Bean
    public GrantedAuthoritiesMapper userAuthoritiesMapper(
            UserRepository userRepo,
            RoleAssignmentRepository roleRepo) {

        return authorities -> {
            OidcUserAuthority oidc = authorities.stream()
                    .filter(OidcUserAuthority.class::isInstance)
                    .map(OidcUserAuthority.class::cast)
                    .findFirst()
                    .orElse(null);

            if (oidc == null) {
                return Set.of(new SimpleGrantedAuthority("ROLE_USER"));
            }

            OidcIdToken idToken = oidc.getIdToken();
            String sub = idToken.getSubject();
            String email = idToken.getEmail();
            String fullName = idToken.getFullName();
            LocalDateTime now = LocalDateTime.now();

            // Upsert User; stamp lastLogin AND emailVerifiedAt on every successful OIDC handshake
            if (sub != null) {
                User user = userRepo.findById(sub).orElseGet(() -> {
                    User u = new User();
                    u.setId(sub);
                    u.setPreferences(new HashMap<>());
                    return u;
                });
                user.setEmail(email);
                user.setFullName(fullName);
                user.setLastLogin(now);
                user.setEmailVerifiedAt(now);   // <-- the freshness anchor
                userRepo.save(user);
            }

            String normalizedEmail = normalize(email);
            if (normalizedEmail == null) {
                return Set.of(new SimpleGrantedAuthority("ROLE_USER"));
            }

            // Return the FULL role set. PersonaSelectionFilter narrows to one per session.
            return roleRepo.findByEmail(normalizedEmail)
                    .map(RoleAssignment::getRoles)
                    .filter(roles -> !roles.isEmpty())
                    .map(roles -> roles.stream()
                            .map(r -> new SimpleGrantedAuthority("ROLE_" + r.name()))
                            .collect(Collectors.<GrantedAuthority>toSet()))
                    .orElseGet(() -> Set.of(new SimpleGrantedAuthority("ROLE_USER")));
        };
    }

    @Bean
    public CommandLineRunner seedBootstrapRoles(
            RoleAssignmentRepository roleRepo,
            @Value("${odin.bootstrap.admin-email:}") String adminEmail,
            @Value("${odin.bootstrap.lead-developer-email:}") String leadDevEmail) {

        return args -> {
            seedRole(roleRepo, adminEmail, UserRole.ADMINISTRATOR);
            seedRole(roleRepo, leadDevEmail, UserRole.LEAD_DEVELOPER);
        };
    }

    private static void seedRole(RoleAssignmentRepository roleRepo, String email, UserRole role) {
        String normalized = normalize(email);
        if (normalized == null) return;
        roleRepo.findByEmail(normalized).ifPresentOrElse(
                existing -> {
                    if (existing.getRoles().add(role)) roleRepo.save(existing);
                },
                () -> roleRepo.save(RoleAssignment.builder()
                        .email(normalized)
                        .roles(EnumSet.of(role))
                        .build())
        );
    }

    private static String normalize(String email) {
        if (email == null) return null;
        String trimmed = email.trim().toLowerCase();
        return trimmed.isEmpty() ? null : trimmed;
    }
}