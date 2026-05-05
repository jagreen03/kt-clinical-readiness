/* Path: 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/HomeController.java */
package com.bluesand.riverhorse.gateway;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.stream.Collectors;

@RestController
public class HomeController {

    @GetMapping("/")
    public String home(@AuthenticationPrincipal OidcUser user, Authentication auth) {
        if (user != null) {
            String name = user.getFullName();
            String email = user.getEmail();
            String roles = auth.getAuthorities().stream()
                .map(a -> a.getAuthority())
                .collect(Collectors.joining(", "));

            return String.format(
                "<h1>RiverHorse Gateway: Authentication Verified</h1>" +
                "<p><strong>User:</strong> %s</p>" +
                "<p><strong>Email:</strong> %s</p>" +
                "<p><strong>Active Roles:</strong> [%s]</p>" +
                "<p><strong>Status:</strong> Identity Engine Pass 1 Active</p>" +
                "<hr>" +
                "<p><em>Next Step: Role-Switcher Logic and Context Clearing</em></p>",
                name, email, roles.isEmpty() ? "NONE" : roles
            );
        }
        return "Welcome to the RiverHorse Gateway. Please <a href='/login'>login</a> to continue.";
    }
}