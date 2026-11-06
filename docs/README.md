
# Documentação EventHub

**Objetivo:** Índice central da documentação técnica do EventHub (frontend, backend, integração, banco, produção e evolução incremental). Tudo baseado no repositório; sistema em produção — não perder dados/banco.

**Mapa completo:** Use [INDEX.md](./INDEX.md) como referência oficial (estrutura de pastas, Mapa por Área, Regras de Ouro e política de atualização).

---

## Estrutura de pastas (docs/)

| Pasta | Conteúdo |
|-------|----------|
| **planos/** | Roadmaps, planos de feature/infra (ROADMAP_TECHNICAL, PLANO_INTEGRACAO_DOCUSIGN, OBSERVABILITY_PLAN, PERFORMANCE_PLAN, PRODUCTION_SETUP) |
| **referencias/** | Consulta: API, domínio, modelo de dados, regras, auth, arquitetura |
| **estado/backend/** | Análise atual do backend |
| **estado/frontend/** | Análise e backlog do frontend |
| **estado/integracao/** | Integração FE↔BE, limitações, backlog consolidado (TODO_MASTER) |
| **processo/** | Guia de implementação, migração, segurança |

---

## Índice de documentos

| Documento | Descrição |
|-----------|-----------|
| [referencias/ARCHITECTURE_OVERVIEW.md](./referencias/ARCHITECTURE_OVERVIEW.md) | Visão geral do sistema, componentes, diagramas e fluxos principais |
| [referencias/DOMAIN_MODEL.md](./referencias/DOMAIN_MODEL.md) | Glossário, ciclo de vida da Proposal, invariantes e dependências |
| [referencias/AUTHORIZATION_MODEL.md](./referencias/AUTHORIZATION_MODEL.md) | Auth (JWT/refresh/session), permissões org/venue, lacunas |
| [referencias/DATA_MODEL_EXPLAINED.md](./referencias/DATA_MODEL_EXPLAINED.md) | Banco em termos de domínio, ER, campos sensíveis, integridade |
| [planos/PRODUCTION_SETUP.md](./planos/PRODUCTION_SETUP.md) | Rodar local, envs, deploy (Vercel), migrations, smoke test |
| [processo/SECURITY_HARDENING.md](./processo/SECURITY_HARDENING.md) | Threat model, riscos no código, mitigações incrementais, plano 2 sprints |
| [processo/MIGRATION_STRATEGY.md](./processo/MIGRATION_STRATEGY.md) | Regras de ouro, versionamento de API/contrato/banco, rollback |
| [estado/integracao/KNOWN_LIMITATIONS.md](./estado/integracao/KNOWN_LIMITATIONS.md) | Limitações e dívidas por camada, bugs prováveis, workarounds |
| [planos/ROADMAP_TECHNICAL.md](./planos/ROADMAP_TECHNICAL.md) | Roadmap 30/60/90 dias, prioridades, entregáveis por semana |
| [referencias/API_VERSIONING_STRATEGY.md](./referencias/API_VERSIONING_STRATEGY.md) | Introdução de /v1 ou X-Api-Version, depreciação |
| [planos/OBSERVABILITY_PLAN.md](./planos/OBSERVABILITY_PLAN.md) | Logs, métricas, alertas, healthcheck, onde instrumentar |
| [planos/PERFORMANCE_PLAN.md](./planos/PERFORMANCE_PLAN.md) | Paginação, índices, transações, upload/Sharp/S3 |

---

## Por onde começar

1. **Novo na equipe / visão geral:** [referencias/ARCHITECTURE_OVERVIEW.md](./referencias/ARCHITECTURE_OVERVIEW.md) → [referencias/DOMAIN_MODEL.md](./referencias/DOMAIN_MODEL.md)
2. **Deploy / rodar local:** [planos/PRODUCTION_SETUP.md](./planos/PRODUCTION_SETUP.md)
3. **Segurança e auth:** [referencias/AUTHORIZATION_MODEL.md](./referencias/AUTHORIZATION_MODEL.md) → [processo/SECURITY_HARDENING.md](./processo/SECURITY_HARDENING.md)
4. **Mudar banco/API sem quebrar:** [processo/MIGRATION_STRATEGY.md](./processo/MIGRATION_STRATEGY.md) → [referencias/DATA_MODEL_EXPLAINED.md](./referencias/DATA_MODEL_EXPLAINED.md)
5. **O que não fazer / bugs conhecidos:** [estado/integracao/KNOWN_LIMITATIONS.md](./estado/integracao/KNOWN_LIMITATIONS.md)
6. **Planejamento:** [planos/ROADMAP_TECHNICAL.md](./planos/ROADMAP_TECHNICAL.md)

---

## Documentos de referência (fontes)

- [estado/frontend/FRONTEND_ANALISE_ATUAL.md](./estado/frontend/FRONTEND_ANALISE_ATUAL.md) — Análise detalhada do frontend
- [estado/backend/BACKEND_ANALISE_ATUAL.md](./estado/backend/BACKEND_ANALISE_ATUAL.md) — Análise detalhada do backend
- [estado/integracao/INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md](./estado/integracao/INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md) — Integração FE↔BE
- [referencias/API_CONTRACTS.md](./referencias/API_CONTRACTS.md) — Contratos dos endpoints (gerado a partir do código)
- [referencias/database.dbml](./referencias/database.dbml) — Modelo de dados em DBML (derivado do Prisma)
- [estado/frontend/FRONTEND_TODO_PRIORIDADE.md](./estado/frontend/FRONTEND_TODO_PRIORIDADE.md) — TODO priorizado do frontend

---

## Mapa rápido de pastas (código)

| Camada | Caminho | Observação |
|--------|---------|------------|
| **Frontend** | `eventhub-vista-dashboard/` | Vite, React, TypeScript, Zustand, React Query, Axios |
| **Backend** | `art56_server_v3/` | Express, Prisma (MySQL), use cases, routers em `src/` |
| **Prisma** | `art56_server_v3/prisma/` | `schema.prisma`, `migrations/` |
| **Rotas BE** | `art56_server_v3/src/router/` | Um arquivo por recurso (auth, venue, proposal, etc.) |
| **Use cases** | `art56_server_v3/src/use-cases/` | controller / use-case / factory por ação |
| **FE services** | `eventhub-vista-dashboard/src/services/` | Chamadas HTTP por domínio |
| **FE stores** | `eventhub-vista-dashboard/src/store/` | Zustand por entidade |
| **FE hooks** | `eventhub-vista-dashboard/src/hooks/` | React Query (queries/mutations) |
| **Docs** | `docs/` | planos, referencias, estado (backend/frontend/integracao), processo; INDEX.md na raiz |

---

*Última atualização: março/2025. Conteúdo baseado exclusivamente no repositório.*
