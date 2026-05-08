package com.bluesand.riverhorse.gateway.identity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.EnumSet;
import java.util.Set;

@Document(collection = "role_assignments")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoleAssignment {

    @Id
    private String id;

    /** RBAC lookup key — must be unique. */
    @Indexed(unique = true)
    private String email;

    /** References the existing 13-role enum. */
    private Set<UserRole> roles;

    public static RoleAssignment of(String email, UserRole... roles) {
        return RoleAssignment.builder()
                .email(email)
                .roles(EnumSet.copyOf(Set.of(roles)))
                .build();
    }
}