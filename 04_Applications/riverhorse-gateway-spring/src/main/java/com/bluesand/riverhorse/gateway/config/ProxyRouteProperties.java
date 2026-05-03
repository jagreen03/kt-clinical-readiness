package com.bluesand.riverhorse.gateway.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.Map;

@ConfigurationProperties(prefix = "proxy")
public record ProxyRouteProperties(
    Map<String, String> services,
    String internalApiKey
) {}