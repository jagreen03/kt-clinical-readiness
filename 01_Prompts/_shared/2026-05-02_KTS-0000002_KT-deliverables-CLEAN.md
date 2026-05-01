# KTS-0000002 — Deliverables prompt (sanitized)

Both Claude and Gemini, this turn produces the actual master-prompt deliverables that KTS-0000001 deferred: LinkedIn Learning courses, GitHub project ideas, and interview talking points. Use the master prompts at `01_Prompts/_shared/MASTER_PROMPT_for_CLAUDE.md` and `01_Prompts/_shared/MASTER_PROMPT_for_GEMINI.md` as your authoritative ask. The three context blocks below ground the work in real artifacts instead of inferred ones.

### Block 1: Sanitized stack constraints from Elevance Clinical materials

[PASTE PUBLIC-SHAPED TECHNICAL THEMES HERE]

### Block 2: GitHub repository inventory

[PASTE CONTENTS OF 00_Inbox\2026-05-01_KTS-0000002_gh-repo-list-RAW.txt HERE]

### Block 3: My positioning anchors (already on GitHub or in flight)

- `BlueSand.RiverHorse.Gateway` — .NET 9 ASP.NET Core MVC BFF with Google OAuth 2.0 + PKCE. This is the natural anchor for a Spring Boot BFF translation project.
- 20+ years C#/.NET across healthcare (Ingenious Med EDI), fintech/payments (Planet Payment, Alogent), IoT/utilities (Landis+Gyr), and regulatory compliance (HIPAA, PCI-DSS).
- Recent technical writing: SSRN paper on the RDIMM Tax (DDR5 supply economics). Comfortable publishing.

---

## What I want from you, by stack area (Java, Spring Boot, JSP, MongoDB, AWS, React/Angular):

**A. LinkedIn Learning courses.** One or two per area. Named. One-line rationale each. Exclude beginner content. Prefer instructors who assume prior programming experience and link to GitHub demo repos.

**B. GitHub project ideas.** One or two per area. Each must specify:
* Core features (3-5 bullets)
* Technologies exercised
* The .NET concept it maps to (so the README can frame it as a translation, not a from-scratch learning project)
* The interview claim it underwrites (one sentence: "with this repo I can credibly say...")

**C. Interview talking points.** Three short paragraphs:
* How I explain learning Java/Spring quickly given 20+ years C#/.NET. Frame as translation, not greenfield learning.
* How I justify JSP usage when an interviewer asks "isn't that legacy?" Defend the choice without disparaging it.
* How I address clinical data integrity and security: HIPAA, OWASP Top 10, audit logging, PHI handling, OAuth scope discipline.

### Format constraints:
* Section per stack area; courses first, projects second within each.
* Talking points as a single closing section.
* Bullet points throughout, no motivational language, senior-to-senior tone.
* Assume each GitHub repo will be public when ready; until then they live private under `04_Applications/*`.
* Cross-reference to existing repos in Block 2 where relevant — "this builds on your existing X" is more useful than "here's a brand new idea."
* If anything in Block 1 is too sparse to give a credible recommendation, say so explicitly rather than guessing. I will go back to the source documents and extract more.