# KTS-0000012 — Pass 1: Persistence Substrate

**Date:** 2026-05-05
**Status:** In flight
**Predecessor:** KTS-0000011 (Identity Engine Foundation, passes 1–4)
**Stack:** Spring Boot 3 / Java 21 / Spring Data MongoDB / Mongo 7 (Docker local)

## Intent

Replace the volatile in-memory role map with a persistent identity store.
Adheres to the Code-First Doctrine: `@Document` classes define the schema;
Mongo is provisioned to match.

## Files Touched

- `identity/User.java` — new `@Document`, `@Id` = OIDC `sub`
- `identity/RoleAssignment.java` — new `@Document`, `@Indexed(unique=true)` on email
- `identity/UserRepository.java` — new `MongoRepository`
- `identity/RoleAssignmentRepository.java` — new `MongoRepository`
- `config/RoleMappingConfig.java` — rewritten to upsert User on login and resolve roles via repo
- `pom.xml` — added `spring-boot-starter-data-mongodb`
- `application.yml` — `spring.data.mongodb.uri` + `auto-index-creation: true`
- `docker-compose.yml` — Mongo 7 + mongo-express on :8081 (new)
- `.env` — local credentials (gitignored)
- `.gitignore` — ignore `.env`, `mongo_data/`

## Doctrinal Notes

- **Vendor-agnostic:** Local-first Mongo via Docker; promotion to Atlas
  requires changing only `SPRING_DATA_MONGODB_URI`. No code changes.
- **One-Way Ticket (deferred):** `persona_audit` collection and
  `@EnableMongoAuditing` to be added in pass 2 once CRUD is verified.
- **Bootstrap:** `seedAdmin` `CommandLineRunner` keyed on
  `ODIN_BOOTSTRAP_ADMIN_EMAIL` — idempotent, runs once.
- **Index verification:** After first green run, confirm
  `db.role_assignments.getIndexes()` shows `email_1` with `unique: true`.
  If not, `auto-index-creation` is wrong or ignored.

## Migration Path for `RoleRegistry`

The existing `identity/RoleRegistry.java` becomes redundant once the mapper
queries the repo directly. Pass 2 will either delete it or refactor it into
a thin read-through cache facade — decision deferred until pass 2 review.

## Verification Steps

1. `cd 04_Applications\riverhorse-gateway-spring`
2. `docker compose up -d`
3. Set env: `set ODIN_BOOTSTRAP_ADMIN_EMAIL=<your gmail>`
4. Boot the app, complete OIDC login
5. Inspect via mongo-express on http://localhost:8081
   - `users` collection: one document keyed by your Google `sub`
   - `role_assignments` collection: one document with full role set
6. Re-login: `lastLogin` updates; no duplicate User documents created
7. Confirm unique index: `db.role_assignments.getIndexes()`

## Status

Ready for Casey L Jones to commit.

## Mid-Pass Bug Fix (regex audit catch)

Pre-flight regex search across the repo for `ODIN_BOOTSTRAP_*` revealed two
stacked bugs in the legacy in-memory `RoleRegistry`:

1. **Literal-string-as-key:** `registry.put("ODIN_BOOTSTRAP_ADMIN_EMAIL ", ...)`
   stored the env var NAME as the lookup key, not the resolved value. Spring
   property substitution does not run on Java string literals.
2. **Trailing whitespace** on the admin key: `"ODIN_BOOTSTRAP_ADMIN_EMAIL "`
   (extra space before the closing quote) — a near-miss key no email could
   match even if substitution had worked.

**Net effect:** the bootstrap has been a no-op since KTS-0000011 pass 1.
ADMINISTRATOR and LEAD_DEVELOPER roles were never actually granted; every
login fell through to ROLE_USER. The OAuth handshake succeeded, so the bug
went unobserved.

**Persistence migration corrects this** by routing bootstrap through
`@Value` substitution (which DOES resolve env vars) and storing actual
emails in `role_assignments`. Lookup is normalized (`trim().toLowerCase()`)
on both seed and read paths to defend against case mismatch in env var
entry vs. OIDC `id_token.email`.

**Spec correction:** initial pass-1 only seeded ADMINISTRATOR. Restored
parity with prior (broken) intent by adding `ODIN_BOOTSTRAP_LEAD_DEVELOPER_EMAIL`
slot and unifying both seeds in `seedBootstrapRoles`.

## RoleRegistry.java disposition

Now orphaned. Defer deletion to Pass 2 alongside the audit trail work — a
quick `findstr /s /i "RoleRegistry"` across the source tree should be run
first to confirm no other callers before removal.