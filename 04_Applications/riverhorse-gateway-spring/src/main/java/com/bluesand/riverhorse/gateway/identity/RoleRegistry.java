/* Path: 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/identity/RoleRegistry.java */
package com.bluesand.riverhorse.gateway.identity;

import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
public class RoleRegistry {

    private final Map<String, UserRole> registry = new HashMap<>();

    public RoleRegistry() {
        // TODO: Transition to persistent store in future persistence saga
        registry.put("jagreen03@gmail.com", UserRole.ADMINISTRATOR);
    }

    public UserRole getRoleForEmail(String email) {
        return registry.get(email);
    }
}