/* Path: 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/config/RoleMappingConfig.java */
package com.bluesand.riverhorse.gateway.config;

import com.bluesand.riverhorse.gateway.identity.RoleRegistry;
import com.bluesand.riverhorse.gateway.identity.UserRole;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.authority.mapping.GrantedAuthoritiesMapper;
import org.springframework.security.oauth2.core.oidc.user.OidcUserAuthority;

import java.util.HashSet;
import java.util.Set;

@Configuration
public class RoleMappingConfig {

    private static final Logger log = LoggerFactory.getLogger(RoleMappingConfig.class);

    @Bean
    public GrantedAuthoritiesMapper userAuthoritiesMapper(RoleRegistry roleRegistry) {
        return (authorities) -> {
            Set<SimpleGrantedAuthority> mappedAuthorities = new HashSet<>();

            authorities.forEach(authority -> {
                if (authority instanceof OidcUserAuthority oidcAuth) {
                    String email = oidcAuth.getIdToken().getEmail();
                    UserRole role = roleRegistry.getRoleForEmail(email);

                    if (role != null) {
                        if (role.isEnabled()) {
                            log.info("Mapping role {} for user {}", role.name(), email);
                            mappedAuthorities.add(new SimpleGrantedAuthority("ROLE_" + role.name()));
                        } else {
                            log.warn("Role {} for user {} is present but DISABLED at runtime", role.name(), email);
                        }
                    }
                }
            });

            return mappedAuthorities;
        };
    }
}