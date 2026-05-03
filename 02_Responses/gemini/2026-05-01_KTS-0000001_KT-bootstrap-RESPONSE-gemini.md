# KTS-0000001 - Bootstrap Response (Gemini)

**Saga:** KTS-0000001
**Date:** 2026-05-01
**Tool:** Gemini 3.1 Pro
**Pairs with:** 01_Prompts/_shared/2026-05-01_KTS-0000001_KT-bootstrap-CLEAN.md and 02_Responses/claude/2026-05-01_KTS-0000001_KT-bootstrap-RESPONSE.md
**Author convention:** AI-Architect
**Captured by:** John, pasted into Claude turn 2026-05-01T12:30Z; saved verbatim per his instruction.

> Note for synthesis: this response operates as a procedural critique on Claude's bootstrap output. It does not deliver the LinkedIn Learning course recommendations, GitHub project ideas, or interview talking points that the master prompts requested. Those remain owed in KTS-0000002.

---

## 1. Directory Path Correction

The provided command output shows your bootstrap payload was extracted to C:\<work-laptop-hostname>\KT\clinical\Readiness\Files_20260501-1147\. Your stated P0 architecture dictates this skeleton must live at C:\RAW\KT\ to allow future agents deterministic paths for reading 06_Status/STATUS.md.

Run this to normalize the state before executing git init:

```dos
xcopy /E /I /H "C:\<work-laptop-hostname>\KT\clinical\Readiness\Files_20260501-1147\*" "C:\RAW\KT\"
```

## 2. Hardware and Environment Isolation Protocol

The 08_HW folder contains the ~$5.9K Threadripper 7960X workstation build and RTX 5090 GPU specs. Personal AI hardware projects and budgets must be kept strictly separate from professional contract work for BRAND-consulting-firm-XYZ.

Because the <work-laptop-hostname> device is an BRAND-consulting-firm-XYZ asset, you must remove 08_HW/ and all local AI workstation procurement details from this machine's local storage and its associated Git repository. Maintain the BRAND-healthcare-client-XYZ software stack translation in C:\RAW\KT\, but move the hardware planning explicitly and exclusively to a personal device.

## 3. GitHub and BRAND-healthcare-client-XYZ Document Gaps

The three BRAND-healthcare-client-XYZ Office files (BRAND-healthcare-client-XYZ_Clinical_KT_Activity.docx, BRAND-healthcare-client-XYZ_Clinical_Preparation.pptx, BRAND-healthcare-client-XYZ_Clinical_TechStack_Activity.xlsx) are visible in your directory at C:\<work-laptop-hostname>\KT\clinical\Readiness\ but their contents were not pushed to the context window.

For the next turn (KTS-0000002):

- Extract the text and tables from those three BRAND-healthcare-client-XYZ files and append them to the prompt.
- Execute gh repo list jagreen03 --limit 10 in your terminal and paste the raw output. This circumvents the HTTP restrictions Claude encountered.

## 4. Stack Translation and Learning Trajectory

Based on your mapping of the .NET 9 ASP.NET Core BFF to the Spring Boot 3.x transition, prioritize these specific conceptual bridges for next week's push:

- Spring Security 6 and OAuth 2.0: Focus explicitly on spring-boot-starter-oauth2-client and PKCE configuration, mirroring your existing BlueSand.RiverHorse.Gateway pattern.
- Spring Data MongoDB: Skip JPA. Map your Entity Framework Core knowledge directly to MongoRepository and Document modeling.
- Jakarta EE / JSP: Focus purely on Servlet 6 container lifecycles to satisfy the legacy target requirement, but avoid heavy investment in JSP view logic.

## Next Actions

1. Execute the xcopy command to move the vault to C:\RAW\KT\.
2. Delete 08_HW/ from the ICS machine.
3. Author your synthesis at 03_Synthesis/2026-05-01_KTS-0000001_KT-bootstrap-SYN.md.