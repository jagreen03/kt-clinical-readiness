package com.bluesand.riverhorse.gateway.identity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Document(collection = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    /** Maps to the Google OIDC 'sub' claim. */
    @Id
    private String id;

    @Indexed
    private String email;

    private String fullName;

    private Map<String, Object> preferences = new HashMap<>();

    private LocalDateTime lastLogin;

    /**
     * Stamp of most recent successful OIDC handshake. Drives the freshness gate.
     * Re-stamped on every login. If older than the configured window, elevated
     * authorities are revoked until the user re-authenticates.
     */
    private LocalDateTime emailVerifiedAt;
}