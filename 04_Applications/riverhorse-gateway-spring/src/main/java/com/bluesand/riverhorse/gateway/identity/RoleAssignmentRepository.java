package com.bluesand.riverhorse.gateway.identity;

import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface RoleAssignmentRepository extends MongoRepository<RoleAssignment, String> {
    Optional<RoleAssignment> findByEmail(String email);
}