# DREAM: ODIN Persistence & Identity Substrate
**Current Status:** [DREAM] -> [PROMPT-ABLE]
**Cross-References:** KTS-0000012, KTS-0000013

## Refined Intent
Transition the ODIN Planner from Mode A (Excel Volatile) to a Hybrid Mode B (MongoDB Primary / Excel Secondary). MongoDB will act as the source of truth for the browser app, allowing for real-time collaboration and identity-based access control.

## MongoDB Schema Expansion
- **Collection: `odin_teams`**
  - Document structure mirroring the `Team` interface.
  - Linked to `user_id` of the Tower Lead.
- **Collection: `odin_tasks`**
  - Flattened task list with `team_id` and `phase_id` references for fast querying.
- **Collection: `approval_queue`**
  - Stores OIDC login attempts from unknown emails.
  - Fields: `email`, `provider` (Google/Microsoft), `timestamp`, `status` (PENDING/APPROVED).

## Identity Refinement
- **Multi-Provider:** Configure Spring Security for Entra ID (Microsoft) alongside Google.
- **Domain Gate:** Silently reject any email not belonging to `@carelon.com`, `@elevancehealth.com`, or specifically authorized Gmails.
- **Admin Elevation:** Only `ROLE_ADMINISTRATOR` (John) can move users from `approval_queue` to `role_assignments`.