# MongoDB Schema Intent (Speculative)

> **Status:** TODO / INTENTIONAL — Forward Architecture Only
>
> No MongoDB integration exists in the current Spring Boot 4.0.1 implementation. This diagram documents architectural intent for the eventual persistence layer. The `RESUME_GAP` entity is marked speculative and originates from a separate Catalyst-001 directive about resume year/gap grading; it may be promoted to a separate repo or removed in implementation.

## Schema Sketch

````mermaid
erDiagram
    USER ||--o{ PROFESSIONAL_TRACK : "manages"
    PROFESSIONAL_TRACK ||--o{ SKILL_NODE : "contains"
    SKILL_NODE ||--o{ RESUME_GAP : "identifies"
    
    USER {
        string userId PK
        string email
        string activeRole
    }
    
    PROFESSIONAL_TRACK {
        string trackId PK
        string technologyStack
    }
    
    SKILL_NODE {
        string skillId PK
        string skillName
        int proficiencyLevel
    }
    
    RESUME_GAP {
        string gapId PK
        string description
    }
````

## Notes

- `RESUME_GAP` is speculative. May relocate to a separate repository per Catalyst-001 prior directive.
- All entities are forward-architecture. No implementation exists.
- Schema shape pending Mike (Pilot) review when online.