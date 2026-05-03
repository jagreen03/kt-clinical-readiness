# KTS-0000007 Pass 1: Build Blockers Resolution

## Revisions Applied

* **Spring Boot Version Correction**: The `spring-boot-starter-parent` version has been amended from `4.0.5` to `4.0.1`. 
    * *Origin of the Error*: In the Pass 1 review cycle, the synthesis text provided to me explicitly stated: *"As of today (May 3, 2026), Spring Boot 4.0.5 is the latest stable release...".* I accepted this injected context as a ground-truth environmental constraint. The Pilot's correction to `4.0.1` based on actual Maven Central availability is accepted and applied.
* **AOP Dependency Resolution**: Selected **Option A** (Remove the dependency entirely).
    * *Rationale*: The `spring-boot-starter-aop` dependency was originally added to support Resilience4j's `@CircuitBreaker` and `@Bulkhead` annotations. Since we explicitly deferred Resilience4j in Pass 2 pending Spring Boot 4 compatibility checks, the AOP capability is currently dead weight. Rather than renaming it to the new `spring-boot-starter-aspectj`, the cleanest architectural choice is to remove it entirely until a cross-cutting concern (like Resilience4j or custom logging aspects) actually requires it.

## Junior Developer Perspective: The Major Version Migration Trap
This scenario highlights a critical lesson for junior engineers regarding major framework upgrades (e.g., Spring Boot 3.x to 4.x): **Trust the Migration Guide over institutional memory.**

A junior developer will often copy-paste a `pom.xml` from an older project or rely on muscle memory for starter dependencies, assuming the ecosystem is static. When the build fails, they might attempt to force the old dependency by overriding versions. The professional approach is to recognize that major version bumps *always* include breaking changes, dependency renames, and removals. Reading the official migration guide before compiling is not optional; it is the primary defense against ghost dependencies and broken builds. In this case, Spring correctly narrowed the scope of the AOP starter to specifically denote AspectJ, forcing developers to audit whether they actually need it.

## Confirmation of Unchanged Artifacts
No Java source files or application configurations were modified in this pass.