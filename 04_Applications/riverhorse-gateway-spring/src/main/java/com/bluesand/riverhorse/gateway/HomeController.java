/* Path: 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/HomeController.java */
package com.bluesand.riverhorse.gateway;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import jakarta.servlet.http.HttpServletRequest;
import java.util.stream.Collectors;

@RestController
public class HomeController {

    @GetMapping("/")
    public String home(@AuthenticationPrincipal OidcUser user, Authentication auth, HttpServletRequest request) {
        if (user != null) {
            CsrfToken csrf = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
            String csrfInput = (csrf != null) 
                ? String.format("<input type='hidden' name='%s' value='%s'>", csrf.getParameterName(), csrf.getToken())
                : "";

            String roles = auth.getAuthorities().stream()
                .map(a -> a.getAuthority())
                .collect(Collectors.joining(", "));

            boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMINISTRATOR"));

            StringBuilder sb = new StringBuilder();
            sb.append("<h1>RiverHorse Gateway: Persona Dashboard</h1>");
            sb.append(String.format("<p><strong>Current User:</strong> %s</p>", user.getFullName()));
            sb.append(String.format("<p><strong>Active Persona:</strong> [%s]</p>", roles));
            sb.append("<hr>");

            if (isAdmin) {
                sb.append("<h3>Inhabit Persona (One-Way Ticket)</h3>");
                sb.append("<p><small>Warning: Switching roles will revoke Admin authorities for this session.</small></p>");
                sb.append("<form action='/switch-persona' method='post' style='display:inline;'>");
                sb.append(csrfInput);
                sb.append("  <input type='hidden' name='role' value='SME'>");
                sb.append("  <button type='submit'>Inhabit SME</button>");
                sb.append("</form> ");
                sb.append("<form action='/switch-persona' method='post' style='display:inline;'>");
                sb.append(csrfInput);
                sb.append("  <input type='hidden' name='role' value='TOWER_LEAD'>");
                sb.append("  <button type='submit'>Inhabit Tower Lead</button>");
                sb.append("</form>");
            } else {
                sb.append("<h3>Persona Mode Active</h3>");
                sb.append("<p>You have successfully inhabited a restricted role. Admin features are disabled.</p>");
            }

            sb.append("<hr>");
            sb.append("<form action='/logout' method='post'>");
            sb.append(csrfInput);
            sb.append("  <button type='submit' style='background-color:#ffcccc;'>Log Out to Reset (Full Clear)</button>");
            sb.append("</form>");

            return sb.toString();
        }
        return "<h1>Welcome to the RiverHorse Gateway</h1>" +
               "<p>Please <a href='/login'>login with Google</a> to continue.</p>";
    }
}