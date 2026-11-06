# Limitações e dívidas conhecidas — EventHub

**Objetivo:** Limitações e dívidas técnicas por camada (FE, BE, integração, DB); bugs prováveis; workarounds temporários; o que monitorar em produção. Tudo baseado no repositório.

**Fontes no repositório:** [FRONTEND_ANALISE_ATUAL.md](./FRONTEND_ANALISE_ATUAL.md), [BACKEND_ANALISE_ATUAL.md](./BACKEND_ANALISE_ATUAL.md), [INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md](./INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md), [FRONTEND_TODO_PRIORIDADE.md](./FRONTEND_TODO_PRIORIDADE.md), código referenciado nesses docs.

---

## 1. Frontend

| Limitação / dívida | Onde | Impacto |
|--------------------|------|---------|
| Dupla fonte de verdade (Zustand + React Query) | Stores e hooks (ex.: venue); páginas usam ambos | Dados dessincronizados; refetch redundante |
| Typo `organizattionId` | userOrganizationPermissionStore, ProtectedRoute | Risco ao corrigir só em um lugar; service usa organizationId |
| Hook useGetVenuesList com assinatura errada | hooks/venue/queries/list.ts | Chama getAllVenues(organizationId) com 1 arg; service espera { organizationId, userId } |
| Rotas públicas duplicadas | lib/axios.ts, useBootstrapUser.ts | Alteração em uma e não na outra → inconsistência (redirect vs token) |
| ProtectedRoute complexo | ProtectedRoute.tsx | Muitos useEffects, getState() em async; difícil testar |
| App.tsx com muitas rotas e imports | App.tsx | Bundle grande; sem lazy loading |
| TypeScript strict desligado | tsconfig.app.json | strict: false, noImplicitAny: false |
| Sem .env.example | Raiz do app | Onboarding e deploy sem lista de variáveis |
| Placeholders em rotas | ProposalContact, ProposalSend | Retornam div simples |
| Nomes com typo | OrganizationPermissionsv2, ContarctPjForm, ContarctPFForm | Legibilidade |

**Bugs prováveis:** Lista de venues pode falhar ou usar userId indefinido por causa do hook; redirect para login em rotas que deveriam ser públicas se a lista de rotas públicas divergir entre axios e useBootstrapUser.

---

## 2. Backend

| Limitação / dívida | Onde | Impacto |
|--------------------|------|---------|
| req.userId não definido | ensureAuthenticate.ts | Impossível autorizar por recurso no servidor |
| Rotas sensíveis sem auth | image, document, payment, text, clause, contract, contact, notification, emailConfig, dateEvent, schedule, question, seasonalFee, proposal (create, byId, updatePersonalInfo), service list | Acesso não autorizado |
| express-async-errors não importado | server.ts | Rejeições async podem não virar resposta JSON |
| Sem middleware global de erro (4 params) | server.ts | Erros não tratados em try/catch não passam por handleErrors |
| CORS origin: "*" | server.ts | Qualquer origem |
| Body limit 50mb | server.ts | Risco DoS |
| Duplicação express.json() | server.ts linhas 42–44 | Comportamento confuso |
| 500 expõe error.toString() | error-handler.ts | Vazamento de detalhes |
| Sem transação em fluxos com múltiplas escritas | proposal, payment, dateEvent | Inconsistência em falha parcial |
| Listas sem paginação | Repositórios (venue, proposal, user, organization, etc.) | Performance e memória |
| Sem .env.example | art56_server_v3 | Onboarding/deploy |

**Bugs prováveis:** Qualquer handler async que lance sem try/catch pode resultar em resposta vazia ou 500 não padronizado.

---

## 3. Integração FE ↔ BE

| Limitação / bug | Onde | Impacto |
|-----------------|------|---------|
| ~~Cláusulas do contrato em ordem aleatória no PDF~~ | `contract-in-prisma-repository.ts`, `ContractPdfGenerator.tsx` | **Resolvido (Fase 1, jul/2026)** — ver [planos/contrato-clausulas](../../planos/contrato-clausulas/README.md) |
| ~~Update de contrato duplicava cláusulas no banco~~ | `contract-form.tsx`, `contract-in-prisma-repository.ts` | **Resolvido (Fase 2, jul/2026)** — FE envia `clauses[].id` em edição; ver [planos/contrato-clausulas](../../planos/contrato-clausulas/README.md) |
| ~~UI de contrato não mostrava ordem real das cláusulas~~ | `contract-form.tsx` | **Resolvido (Fase 2, jul/2026)** — lista ordenada + reordenação ↑↓ |
| Refresh token: FE GET sem body, BE espera body | axios.ts interceptor; auth router | Refresh em 401 falha; usuário deslogado |
| GET /document/:id inexistente no BE | document.service.ts; router/document.ts | 404 ao abrir documento por ID |
| GET /payment/byId/:paymentId inexistente no BE | payment.service.ts; router/payment.ts | 404 ao buscar pagamento por ID |
| Envelope de resposta inconsistente | BE retorna às vezes { data }, às vezes { success, message, data }, às vezes direto | FE usa fallbacks (response.data.data \|\| response.data); frágil |
| Horário de evento deslocado (UTC) | FE/BE — `toTimeString`, calendário local, e-mails BE | **Parcialmente mitigado (Fase 1 FE, jul/2026):** P0 corrigido (`VenueSchedule`, proposta); demais telas e e-mails pendentes (Fases 2–3). Ver [planos/horario-wall-clock](../../planos/horario-wall-clock/README.md). |

---

## 4. Banco de dados

| Limitação | Onde | Impacto |
|-----------|------|---------|
| relationMode = "prisma" | schema.prisma | Sem FKs no MySQL; integridade só na aplicação |
| Transação só em create-venue | venue-in-prisma-repository | Outros fluxos (proposal, payment, dateEvent) sem transação |
| Campos legado (teste) | ProposalCost.teste, ProposalService.teste | Nomenclatura confusa |

---

## 5. Workarounds temporários

- **Documento por ID:** Usar list por proposalId e filtrar no cliente até GET /document/getById existir no BE.
- **Pagamento por ID:** Usar list por proposalId/venueId e filtrar no cliente até GET /payment/byId existir.
- **Refresh:** Evitar que sessão expire (ou aceitar logout) até FE usar POST /token/refresh com body.
- **Permissões:** Autorização efetiva só no FE; BE confia no token para rotas protegidas (e muitas rotas ainda sem token).

---

## 6. O que monitorar em produção

- Taxa de 401 e de redirect para login (possível efeito do refresh quebrado).
- Chamadas a GET /document/:id e GET /payment/byId (404).
- Latência de listagens (venue, proposal, organization) com muitos registros.
- Uso de rotas que ainda não exigem auth (logs ou métricas por path).
- Erros 500 com corpo de resposta (vazamento de detalhes).
- Falhas após deploy (async não tratado).

---

## Decisões e recomendações

- Priorizar correções de integração (refresh, GET document/payment) e auth (req.userId, ensureAuthenticate) conforme [SECURITY_HARDENING.md](./SECURITY_HARDENING.md) e [ROADMAP_TECHNICAL.md](./ROADMAP_TECHNICAL.md).
- Manter esta lista atualizada quando novas limitações forem descobertas ou resolvidas.
