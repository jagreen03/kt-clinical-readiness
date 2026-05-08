package com.bluesand.riverhorse.gateway.config;

import com.bluesand.riverhorse.gateway.identity.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;

/**
 * Enforces the verification freshness window. If the User's emailVerifiedAt
 * is older than the configured window, the session is invalidated and the
 * user is bounced back through OIDC for a fresh handshake.
 */
@Component
public class VerificationFreshnessFilter extends OncePerRequestFilter {

    private final UserRepository userRepo;
    private final long windowHours;

    public VerificationFreshnessFilter(
            UserRepository userRepo,
            @Value("${odin.security.verification-window-hours:6}") long windowHours) {
        this.userRepo = userRepo;
        this.windowHours = windowHours;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain)
            throws ServletException, IOException {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null
                && auth.isAuthenticated()
                && auth.getPrincipal() instanceof OidcUser oidc) {

            String sub = oidc.getSubject();
            boolean fresh = userRepo.findById(sub)
                    .map(u -> u.getEmailVerifiedAt())
                    .map(stamp -> Duration.between(stamp, LocalDateTime.now()).toHours() < windowHours)
                    .orElse(false);

            if (!fresh) {
                HttpSession session = request.getSession(false);
                if (session != null) session.invalidate();
                SecurityContextHolder.clearContext();
                response.sendRedirect("/oauth2/authorization/google");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}