KTS-0000001 closing status update for Gemini
I am circling back to close the loop on KTS-0000001 (the KT vault bootstrap you and Claude both responded to earlier today). Brief status, then what I want from you.
What got built since your last response:
The vault is now live at C:\<work-laptop-hostname>\KT\clinical\Readiness\ and mirrored privately at https://github.com/jagreen03/kt-clinical-readiness. Folder tree is 00_Inbox through 99_Archive plus _scripts and 04_Applications. Git is initialized, first commit landed, branch tracking origin. The three Elevance Office files moved into 00_Inbox/. Master prompts canonical at 01_Prompts/_shared/ (yours and Claude's both). Your bootstrap response is saved verbatim at 02_Responses/gemini/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE-gemini.md.
Where I diverged from your recommendations, and why:

Vault root stayed at C:\<machine-namespace>\KT\clinical\Readiness\, not C:\RAW\KT\. The hostname-as-folder is my machine-disambiguation classification across work and personal devices, not a corporate-policy boundary. Your xcopy command would have flattened that scheme.
08_HW/HW-BLD-002_KT-workstation.md (Threadripper 7960X build) stays in the vault. Both my work laptop and personal computer are under my chain of custody. The hostname prefix is namespace, not asset class. Source-of-truth rule: primary writes happen on personal computer; work laptop is a Git-mirrored read-only copy. Sync via Git, not OneDrive.
Your "skip JPA entirely" was softened to "JPA read-deep-enough-to-defend." An interviewer probing relational vs document modeling expects the choice to be articulated, not absent.
Your "avoid heavy investment in JSP view logic" was rejected. The master prompt explicitly asks for a JSP MVC demonstration project. Plan: one minimal JSP controller plus view, one Thymeleaf controller plus view, same project, README explains the trade-off.
Spring Security 6 plus OAuth 2.0 client plus PKCE focus is kept as your top recommendation; that is the cleanest .NET-to-Spring conceptual translation given my existing BlueSand.RiverHorse.Gateway work.

The synthesis with these decisions lives at 03_Synthesis/2026-05-01_KTS-0000001_KT-bootstrap-SYN.md.
What I am asking you to do for KTS-0000002:
Your bootstrap response gave procedural critique but did not deliver the actual asks from the master prompt -- LinkedIn Learning courses, GitHub project ideas, and interview talking points. That is now what KTS-0000002 needs. Re-read your own master prompt at MASTER_PROMPT_for_GEMINI.md if useful.
For the next turn I will provide three new context blocks:

Extracted text and tables from Elevance_Clinical_KT_Activity.docx, Elevance_Clinical_Preparation.pptx, and Elevance_Clinical_TechStack_Activity.xlsx -- so your stack list is grounded in the actual client artifacts and not inferred.
Output of gh repo list jagreen03 --limit 50 -- so your project recommendations build on what I already have on GitHub instead of starting blank.
Confirmation of any client-specific stack constraints (Java version, Spring Boot version, JSP vs Thymeleaf actuality, MongoDB Atlas vs self-hosted, AWS service whitelist, Angular version) once I have read through the three files.

When that arrives, I want from you, by stack area (Java, Spring Boot, JSP, MongoDB, AWS, React/Angular):
A. Specific LinkedIn Learning courses -- one or two per area, named, with one-line rationale. Exclude beginner content. Prefer courses that assume prior programming experience and have hands-on or GitHub-linked exercises.
B. One or two GitHub project ideas per area. Each idea must specify: core features, technologies exercised, the .NET concept it maps to, what the interview claim becomes when the repo is on my profile.
C. Interview talking-point seeds: how I explain learning Java/Spring quickly given 20+ years in C#/.NET, how I justify JSP usage if asked about it, how I address clinical data integrity and security (HIPAA, OWASP, audit logging, PHI handling).
Format: section per stack area, courses first, projects second, talking points last. Bullet points. No motivational language. Senior-to-senior tone. Assume the GitHub repos will be public.
One question before then:
I am running this prep work on my work laptop (the <work-laptop-hostname> machine, an Infinite Computer Solutions asset), with the actual self-study and code authoring planned for my personal computer once the new workstation is built. Both machines are private, both under my chain of custody. You flagged hostname-asset isolation last time. Given my correction on chain-of-custody and the source-of-truth rule (personal computer is primary, work laptop is a Git-mirrored read-only working copy), do you have any remaining concerns about the split, or any specific files in the vault you would treat as personal-only and exclude from the work-laptop mirror? Be specific if so. If not, say so.