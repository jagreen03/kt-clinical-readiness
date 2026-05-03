# KTS-0000007 Pass 1: Build Blockers Resolution (SecurityConfig)

## Revisions Applied

* **PKCE Constant Resolution**: The constants `CODE_VERIFIER`, `CODE_CHALLENGE`, and `CODE_CHALLENGE_METHOD` were failing to compile because they do not exist in `OAuth2ParameterNames`. They have been correctly repointed to `org.springframework.security.oauth2.core.endpoint.PkceParameterNames`. 

## Junior Developer Perspective: Trust the Compiler, Verify the Reviewer
This is a classic "Reviewer Hallucination" trap. In Pass 2, the Claude synthesis explicitly directed the use of `OAuth2ParameterNames` for the PKCE constants. We implemented the spec exactly as requested, and the build broke. 

A junior developer might spend hours checking Maven dependencies, invalidating IDE caches, or rolling back Spring Boot versions, assuming the framework is broken. The lesson here is paramount: **The compiler is the ultimate source of truth, not the Senior Reviewer (and certainly not the AI).** When a `cannot find symbol` error occurs on a framework constant, the immediate next step is to open the Javadoc or use the IDE's symbol search. Frameworks like Spring segregate concepts strictly (e.g., separating core OAuth2 params from PKCE params). Always verify the API surface manually when an instructed class name fails to resolve.

## Confirmation of Unchanged Artifacts
No other files were modified in this pass.