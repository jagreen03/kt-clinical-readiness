# OBJECTIVES

> Forward queue. Items move to HISTORY.md on completion. Newest priority at top.
>
> Convention: [P{0|1|2}] [target-date] description -- owner. P0 = blocking; P1 = this weekend; P2 = next week.

---

## Today / tomorrow (2026-05-01 / 2026-05-02)

- [P0] [2026-05-01] Run _scripts/consolidate-vault.ps1 (dry-run first, then -Apply). Verify clean tree under Readiness (00_Inbox through 99_Archive present; Office files in 00_Inbox; no Files_* or orphan mnt). -- John
- [P0] [2026-05-02] Decide personal-computer machine-namespace string. Provision the same vault layout there. Set personal computer as source-of-truth. -- John
- [P0] [2026-05-02] Stand up a private Git remote (GitHub private repo recommended). git init on personal computer's vault, push, then git clone on work laptop. Both machines now in lockstep via Git. -- John
- [P0] [2026-05-02] Edit 03_Synthesis/2026-05-01_KTS-0000001_KT-bootstrap-SYN.md in your voice; tick the sign-off boxes; commit. -- John

## Weekend (2026-05-02 / 2026-05-03)

- [P1] [2026-05-02] Open KTS-0000002. Prompt body: master prompts (Claude and Gemini, unchanged) plus two attachments inlined: (a) extracted text and tables from the three Elevance Office files, (b) raw output of gh repo list jagreen03 --limit 50. Save raw at 00_Inbox/2026-05-02_KTS-0000002_*-RAW.md, cleaned at 01_Prompts/_shared/...-CLEAN.md. -- John
- [P1] [2026-05-03] Receive Claude and Gemini responses to KTS-0000002. Expected deliverables: LinkedIn Learning course list, GitHub project ideas, interview talking points. -- John
- [P1] [2026-05-03] Author KTS-0000002 synthesis. -- John
- [P1] [2026-05-03] Stand up Ollama on personal computer. Pull nomic-embed-text and llama3.1:8b-instruct-q4_K_M. Verify sqlite-vec extension loads in Python. -- John
- [P1] [2026-05-03] Promote 07_RAG/pipeline/ingest.py.draft to runnable ingest.py. Smoke-test on 01_Prompts/ and 02_Responses/. -- John
- [P1] [2026-05-03] Order Threadripper 7960X workstation parts from personal computer. -- John
- [P1] [2026-05-03] Scaffold first Spring Boot repo skeleton under 04_Applications/spring-boot-clinical-rest/. -- John

## Next week (2026-05-04 onward)

- [P2] [2026-05-08] Course selection from KTS-0000002 synthesis. Schedule actual viewing windows. -- John
- [P2] [2026-05-08] Stand up Spring Boot BFF mirror of BlueSand.RiverHorse.Gateway: same OAuth 2.0 plus PKCE flow, Spring Authorization Server or Keycloak as IDP. -- John
- [P2] [2026-05-09] First public GitHub repo push for the BFF skeleton. -- John
- [P2] [2026-05-10] MongoDB schema sketch for clinical-style document model. -- John
- [P2] [2026-05-11] JPA read-only orientation: JpaRepository, @Entity, @Transactional. One reading session. Goal: defend the choice not to use JPA. -- John

## Backlog

- JSP MVC reference app: small, focused. JSP plus Thymeleaf in same project for explicit comparison.
- AWS deployment target decision: ECS Fargate vs EKS vs Elastic Beanstalk. Decision in synthesis.
- Long-form: a "translating .NET to Spring Boot" article. Companion to RDIMM Tax piece. Not for this weekend.