/* Path: 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/identity/RoleRegistry.java */
package com.bluesand.riverhorse.gateway.identity;

import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
public class RoleRegistry {

    private final Map<String, UserRole> registry = new HashMap<>();

    public RoleRegistry() {
        registry.put("jagreen03@gmail.com", UserRole.ADMINISTRATOR);
        registry.put("jagdavit123@gmail.com", UserRole.LEAD_DEVELOPER);
    }

    public UserRole getRoleForEmail(String email) {
        return registry.get(email);
    }
}