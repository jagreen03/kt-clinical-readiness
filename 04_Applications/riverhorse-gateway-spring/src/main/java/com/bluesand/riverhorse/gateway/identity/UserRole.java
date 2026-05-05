/* Path: 04_Applications/riverhorse-gateway-spring/src/main/java/com/bluesand/riverhorse/gateway/identity/UserRole.java */
package com.bluesand.riverhorse.gateway.identity;

public enum UserRole {
    // Primary Authority
    ADMINISTRATOR("System Administrator", true),

    // Grouping: Client/Stakeholder
    SME("Subject Matter Expert", true),
    CLIENT_REPORTING_MANAGER("Client Reporting Manager", false),
    CLIENT_ONBOARDING_MANAGER("Client Onboarding Manager", false),
    CLIENT_ONBOARDING_STATUS("Client Onboarding Status", false),

    // Grouping: Contracting/Vendor
    CONTRACTING_REPORTING_MANAGER("Contracting Reporting Manager", false),
    CONTRACTING_COMPANY_ONBOARDING("Contracting Company Onboarding", false),

    // Grouping: Development Team
    LEAD_DEVELOPER("Lead Developer", true),
    LEAD_QA("Lead QA", false),
    SCRUM_MASTER("Scrum Master", false),
    TOWER_LEAD("Tower Lead", true),
    INTERVIEWER("Interviewer", false),
    CANDIDATE("Candidate", false);

    private final String description;
    private final boolean enabled;

    UserRole(String description, boolean enabled) {
        this.description = description;
        this.enabled = enabled;
    }

    public String getDescription() {
        return description;
    }

    public boolean isEnabled() {
        return enabled;
    }
}