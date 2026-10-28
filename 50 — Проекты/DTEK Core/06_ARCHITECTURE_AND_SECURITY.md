---
title: Architecture and Security Map
type: architecture-map
status: active
updated: 2026-10-26
tags:
  - dtek
  - architecture
  - security
---

# Architecture & Security Map

## Current Runtime

```mermaid
flowchart LR
    U["Browser"] --> N["Next.js App Router"]
    N --> SC["Server Components"]
    N --> SA["Server Actions / Route Handlers"]
    SA --> A["Supabase Auth"]
    SA --> P["PostgreSQL"]
    P --> R["RLS"]
    SA --> RB["Server-side RBAC"]
```

## Target Platform Layers

```mermaid
flowchart TB
    S["Imports / Connectors / Collectors / Providers"] --> G["Ingestion Gateway"]
    G --> E["Evidence Layer"]
    E --> I["Identity Resolution"]
    I --> D["Discovery Inbox"]
    D --> M["Assets / Identities / Relations"]
    M --> T["Trust Engine"]
    T --> F["Findings / Risks / Impact"]
    F --> RM["Recommendations / Remediation"]
    RM --> V["Verification"]
```

## Domain Evolution

| Current | Planned extension | Правило |
|---|---|---|
| Organization | Workspace: Business/Home/Personal | Additive migration, не rename |
| Object | Asset/Device/Identity views | Canonical identity и tenant scope |
| Import source block | Evidence source/batch/assertion/binding | No direct connector business writes |
| Risk | Finding + contextual Risk | Finding не создаёт risk автоматически |
| Score | Mode-specific score models | Business ADR-001 сохраняется |
| Relation | Evidence-backed graph edges | Low-confidence не влияет без review |
| Manual action | Recommendation/Remediation/Verification | No autonomous remediation in MVP |

## Security Gates

| Surface | Главные угрозы | Roadmap control |
|---|---|---|
| Current Business | Privilege escalation, blocked-user bypass, cross-tenant links | Security Gate |
| Workspace | Cross-mode/tenant leakage | Sprint 16 + two-workspace tests |
| Connectors | Secrets, SSRF, hostile payload, confused deputy | Sprint 20–21 admission |
| Assessment | Command injection, resource abuse, unsafe scope | Sprint 19 sandbox/bounds |
| Home | Unauthorized LAN scanning, household privacy | Sprint 25–27 pairing/scope gate |
| Personal | PII/breach leakage, consent, retention | Sprint 28–30 privacy gate |
| Exposure | Doxxing, enumeration, SSRF, provider abuse | Sprint 31 capability controls |
| Knowledge | Unsafe remediation instructions | Sprint 18/32 content review |

## Source Documents

- [[50 — Проекты/DTEK Core/Репозиторий/ARCHITECTURE_DECISIONS]]
- [[50 — Проекты/DTEK Core/Репозиторий/docs/architecture/System_Architecture|Current System Architecture]]
- [[50 — Проекты/DTEK Core/Репозиторий/docs/architecture/DTEK_PLATFORM_ARCHITECTURE|Target Platform Architecture]]
- [[50 — Проекты/DTEK Core/Репозиторий/docs/architecture/DTEK_PLATFORM_GAP_ANALYSIS|Gap Analysis]]
- [[50 — Проекты/DTEK Core/Репозиторий/docs/architecture/Connector_Framework_Architecture|Connector Framework]]
- [[50 — Проекты/DTEK Core/Репозиторий/docs/architecture/Evidence_Layer_Data_Model|Evidence Data Model]]
- [[50 — Проекты/DTEK Core/Репозиторий/docs/security/SECURITY_OVERVIEW|Security Overview]]
- [[50 — Проекты/DTEK Core/Репозиторий/docs/security/DTEK_PLATFORM_SECURITY_PRINCIPLES|Platform Security Principles]]
- [[50 — Проекты/DTEK Core/Репозиторий/docs/security/CONNECTOR_SECURITY_MODEL|Connector Security Model]]
