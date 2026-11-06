# Roadmap técnico — EventHub

**Objetivo:** Roadmap 30/60/90 dias; prioridades (estabilização → padronização → segurança → performance → DX); entregáveis por semana (pequenos, compatíveis com produção); riscos e dependências.

**Fontes no repositório:** [KNOWN_LIMITATIONS.md](./KNOWN_LIMITATIONS.md), [SECURITY_HARDENING.md](./SECURITY_HARDENING.md), [INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md](./INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md), [FRONTEND_TODO_PRIORIDADE.md](./FRONTEND_TODO_PRIORIDADE.md).

---

## 1. Prioridades (ordem)

1. **Estabilização** — Corrigir bugs de integração e erros não tratados (refresh, rotas 404, middleware global).
2. **Padronização** — Auth consistente (req.userId, ensureAuthenticate), CORS, body limit, envelope de resposta, rotas públicas documentadas.
3. **Segurança** — Rotas sensíveis protegidas, 500 sem vazamento, rate limit, token/sessão (melhorias incrementais).
4. **Performance** — Paginação, transações onde faltam, índices se necessário.
5. **DX** — .env.example, TypeScript strict gradual, testes mínimos, documentação de API.

---

## 2. Roadmap 30 dias (estabilização + padronização inicial)

| Semana | Entregáveis | Riscos / dependências |
|--------|-------------|-------------------------|
| **1** | BE: express-async-errors + middleware global de erro; 500 em produção sem vazamento; req.userId no ensureAuthenticate; um único express.json/urlencoded com limit 10mb. | Nenhum breaking |
| **2** | BE: CORS por env; ensureAuthenticate em image, document, payment. FE: refresh com POST /token/refresh; typo organizattionId; useGetVenuesList(organizationId, userId). | FE e BE alinhados no refresh |
| **3** | BE: ensureAuthenticate em text, clause, contract, contact, emailConfig, notification, dateEvent, schedule, question, seasonalFee. Documentar rotas públicas. FE: constants/publicRoutes.ts; .env.example (FE e BE). | Testes manuais em fluxos críticos |
| **4** | BE: GET /document/getById e GET /payment/byId (ou equivalente) para eliminar 404. FE: usar novas rotas onde hoje chama por ID. Revisão smoke test. | Garantir que FE não quebra |

---

## 3. Roadmap 60 dias (+ segurança e performance básica)

| Semana | Entregáveis | Riscos / dependências |
|--------|-------------|-------------------------|
| **5** | Rate limit em /auth e /token. Revisão de rotas ainda públicas; lista final em doc. | - |
| **6** | Paginação (page/limit ou cursor) em list de venue, proposal, organization (parâmetros opcionais). | Compatibilidade: sem paginação = comportamento atual |
| **7** | Transação em criação de proposta (proposal + persons + dateEvents quando aplicável). Testes unitários 2–3 use cases críticos (auth, create-venue). | Backup antes de alterar fluxo de proposta |
| **8** | ProtectedRoute: extrair usePreloadRouteContext; testes unitários mínimos (auth sim/não, permissão). FE: convenção de dados (React Query como fonte para lista de venues em um fluxo piloto). | - |

---

## 4. Roadmap 90 dias (+ performance e DX)

| Semana | Entregáveis | Riscos / dependências |
|--------|-------------|-------------------------|
| **9** | Paginação em list de payment, user (e outros conforme uso). Observabilidade: logs estruturados em 1–2 rotas e em handleErrors (ver [OBSERVABILITY_PLAN.md](./OBSERVABILITY_PLAN.md)). | - |
| **10** | Lazy loading de rotas no FE (2–3 páginas pesadas); redução de bundle. TypeScript: strictNullChecks ou noImplicitAny em lib/ e um módulo piloto. | - |
| **11** | Documentação de API (OpenAPI ou README com endpoints críticos). .env.example completo e revisado. Opcional: health check com checagem de DB. | - |
| **12** | Revisão de dívidas restantes (placeholders, nomes com typo, Prettier). Plano de testes E2E (Playwright) para fluxo login → venue → proposal. | - |

---

## 5. Riscos e dependências gerais

| Risco | Mitigação |
|-------|-----------|
| Deploy BE antes do FE (refresh, rotas por ID) | Manter compatibilidade: GET /auth/refresh pode ser estendido para ler header; novas rotas GET document/payment opcionais ao lado do uso de list. |
| Aplicar auth em rotas usadas por cliente público | Lista explícita de rotas públicas; exceção apenas para proposal create, byId, getWebData, getHubData, etc. |
| Migrations em produção | Backup; migrations aditivas; ver [MIGRATION_STRATEGY.md](./MIGRATION_STRATEGY.md). |
| Regressão em fluxos críticos | Smoke test após cada deploy; checklist em [PRODUCTION_SETUP.md](./PRODUCTION_SETUP.md). |

---

## Decisões e recomendações

- Priorizar sempre compatibilidade com produção; nenhuma mudança que exija “big bang” de deploy FE+BE.
- Revisar este roadmap a cada 30 dias e ajustar entregáveis conforme capacidade e descobertas.
- Entregas por semana devem ser pequenas e testáveis em staging antes de produção.
