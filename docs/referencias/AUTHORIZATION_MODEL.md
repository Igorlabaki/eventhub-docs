# Modelo de autorização — EventHub

**Objetivo:** Descrever autenticação (JWT/refresh/session), autorização (permissões org e venue) com base em routers, stores e services; tabela Ação → Recurso → Quem pode; lacunas atuais e plano incremental sem quebrar produção.

**Fontes no repositório:** `art56_server_v3/src/middleware/ensureAuthenticate.ts`, `art56_server_v3/src/router/*.ts`, `art56_server_v3/src/use-cases/token/`, `eventhub-vista-dashboard/src/components/ProtectedRoute.tsx`, `eventhub-vista-dashboard/src/types/permissions.ts`, `eventhub-vista-dashboard/src/App.tsx`, [BACKEND_ANALISE_ATUAL.md](./BACKEND_ANALISE_ATUAL.md), [INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md](./INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md).

---

## 1. Modelo de autenticação

| Aspecto | Implementação (conforme código) |
|---------|----------------------------------|
| **Token de acesso** | JWT gerado no login/registro; assinado com `JWT_SECRET_KEY`. |
| **Onde é guardado** | Frontend: `localStorage` (`@EventHub:token`). Não há httpOnly cookie. |
| **Envio** | Header `Authorization: Bearer <token>` (interceptor Axios). |
| **Refresh** | FE: em 401 chama GET `/auth/refresh` sem body. BE: GET `/auth/refresh` usa controller que faz `refreshTokenSchema.parse(req.body)` — **req.body vazio em GET**; POST `/token/refresh` existe e espera `{ accessToken }` no body (FE não usa). |
| **Sessão** | Modelos `Session` e `RefreshToken` no Prisma; FE guarda `@EventHub:session` (id, userId, refreshTokenId, expiresAt). No BE, o trecho do middleware que validava sessão, renovava token e setava `req.userId` está **comentado**. |
| **Middleware ativo** | `ensureAuthenticate`: verifica JWT, decodifica e seta `(req as AuthenticatedRequest).user = { id: decoded.id }`. `ensurePermission(permission)` lê organizationId de query/body e checa UserVenuePermission; responde 403 se não tiver. |

Rotas de integração Google Calendar e dateEvent usam ensureAuthenticate; integração usa ensurePermission(VIEW_VENUE_CALENDAR | EDIT_VENUE_CALENDAR). Autorização “quem pode acessar este recurso” no BE é feita via ensurePermission nas rotas de integração.

---

## 2. Modelo de autorização (quem pode o quê)

### 2.1 Backend: onde há `ensureAuthenticate`

| Router | Uso de ensureAuthenticate |
|--------|----------------------------|
| auth | Apenas PUT `/auth/update-password` |
| user | `userRoutes.use(ensureAuthenticate)` — todas as rotas de /user |
| venue | create, list, permittedVenueList, trafficCount, analysisByMonth, update, update/payment-info, update/info, delete, analytics. **Sem auth:** getById, getWebData |
| organization | create, list, getById, delete, update, update-venue-organization-images. **Sem auth:** getHubData, getOrganizationWebData |
| proposal | updatePerPerson, updatePerDay, list, delete. **Sem auth:** createPerPerson, createPerDay, byId, updatePersonalInfo |
| service | create, delete, update. **Sem auth:** list |
| goal, expense, attachment | Todas as rotas com `use(ensureAuthenticate)` |
| owner, userOrganization, userVenuePermission, userOrganizationPermission | Todas com `use(ensureAuthenticate)` |
| image, document, payment, text, clause, contact, contract, question, schedule, notification, emailConfig, seasonalFee | **Nenhuma** rota com ensureAuthenticate (confirmado nos routers) |
| dateEvent | Todas com `dateEventRoutes.use(ensureAuthenticate)` |
| integrations/google-calendar | Todas com ensureAuthenticate; auto-status, connect-url, calendars com ensurePermission(VIEW_VENUE_CALENDAR); select-calendar e disconnect com ensurePermission(EDIT_VENUE_CALENDAR). Callback sem auth (redirect OAuth). |

### 2.2 Frontend: permissões por rota

O FE usa `ProtectedRoute` com `requiredPermission` (string). Permissões definidas em `types/permissions.ts`:

- **Organização:** VIEW_ORG_VENUES, VIEW_ORG_OWNERS, VIEW_ORG_SITE, VIEW_ORG_INFO, VIEW_ORG_CONTRACTS, VIEW_ORG_PERMISSIONS.
- **Venue:** VIEW_VENUE_INFO, VIEW_VENUE_SITES, VIEW_VENUE_PRICES, VIEW_VENUE_EVENTS, VIEW_VENUE_ANALYSIS, VIEW_VENUE_CALENDAR, VIEW_VENUE_CONTACTS, VIEW_VENUE_SERVICES, VIEW_VENUE_EXPENSES, VIEW_VENUE_PROPOSALS, VIEW_VENUE_PERMISSIONS, VIEW_VENUE_NOTIFICATIONS, VIEW_VENUE_CONFIG, VIEW_VENUE_NEW_BUDGET, EDIT_VENUE_INFO, **EDIT_VENUE_CALENDAR** (editar calendário e integração Google Calendar; sync create/update/delete).
- **Proposal:** VIEW_PROPOSAL_INFO, VIEW_PROPOSAL_DATES, VIEW_PROPOSAL_HISTORY, VIEW_PROPOSAL_CONTACT, VIEW_PROPOSAL_PAYMENT, VIEW_PROPOSAL_DOCUMENTS, VIEW_PROPOSAL_SCHEDULE, VIEW_PROPOSAL_ATTENDANCE_LIST, VIEW_PROPOSAL_SEND, SEND_PROPOSAL_DOCUMENTS, SEND_PROPOSAL_TEXT, SEND_PROPOSAL_INFO.

A checagem é feita no cliente: `currentUserVenuePermission.permissions.includes(requiredPermission)` ou equivalente para organização. O BE **não** valida essas strings por rota; apenas exige ou não token.

---

## 3. Tabela Ação → Recurso → Quem pode (estado atual)

| Ação (exemplo) | Recurso | Quem pode (BE) | Quem pode (FE) |
|----------------|---------|-----------------|----------------|
| Criar/editar/deletar venue | Venue | Qualquer um com token válido | Protegido por rota; permissão EDIT/VIEW conforme menu |
| Listar venues | Venue | Com token (list, permittedVenueList) | Usuário com acesso à org/venue |
| Ver venue por ID / web data | Venue | Público (sem auth) | Público ou logado conforme rota |
| Criar/editar/deletar organização | Organization | Com token | Protegido por rota (VIEW_ORG_*) |
| Criar proposta | Proposal | **Público** (sem auth) | Rotas públicas para form/view |
| Ver proposta por ID | Proposal | **Público** | Público em /proposal/:id/view; logado em outras |
| Listar/atualizar/deletar proposta | Proposal | Com token | Protegido (VIEW_PROPOSAL_*, etc.) |
| Upload imagem/documento/pagamento | Image, Document, Payment | **Público** (sem auth no BE) | Logado no fluxo normal |
| CRUD texto, cláusula, contrato, contato, etc. | Text, Clause, Contract, Contact, … | **Público** (sem auth) | Logado no fluxo normal |
| Listar/criar/editar permissões org/venue | UserOrganizationPermission, UserVenuePermission | Com token | VIEW_ORG_PERMISSIONS / VIEW_VENUE_PERMISSIONS |

**Lacuna:** Muitas ações que alteram dados (image, document, payment, text, clause, contract, contact, notification, emailConfig, schedule, question, seasonalFee, proposal create/updatePersonalInfo) não exigem token no BE. dateEvent e integrations/google-calendar exigem ensureAuthenticate; integração valida VIEW_VENUE_CALENDAR e EDIT_VENUE_CALENDAR no BE. Quem pode é efetivamente “qualquer um que conheça a URL”.

---

## 4. Lacunas atuais e plano incremental

### Lacunas

1. **`req.user`** — Implementado: ensureAuthenticate seta req.user.id; ensurePermission usa em endpoints Google Calendar. Lacuna restante: checar no BE “este venue pertence ao usuário” ou “este usuário tem permissão X no venue”.
2. **Refresh quebrado** — GET `/auth/refresh` sem body vs controller que espera body; risco de logout desnecessário em 401.
3. **Rotas sensíveis sem auth** — image, document, payment, text, clause, contract, contact, notification, emailConfig, dateEvent, schedule, question, seasonalFee, proposal (create, byId, updatePersonalInfo), service (list).
4. **Autorização por permissão só no FE** — BE não valida VIEW_ORG_* / VIEW_VENUE_*; um token válido dá acesso a qualquer recurso do mesmo usuário (e sem token muitas rotas seguem abertas).
5. **Typo no FE** — `organizattionId` em store e ProtectedRoute (service usa `organizationId`).

### Plano incremental (sem quebrar produção)

| Fase | Ação | Observação |
|------|------|------------|
| 1 | Decodificar JWT em `ensureAuthenticate` e setar `req.userId` (e tipar `Request`) | Compatível; não altera contratos. |
| 2 | FE: trocar refresh para POST `/token/refresh` com body `{ accessToken }` | Alinha com BE; manter GET `/auth/refresh` temporariamente se houver outros clientes. |
| 3 | Aplicar `ensureAuthenticate` em rotas que alteram dados (image, document, payment, text, etc.) | Fazer por recurso; exceção explícita para rotas realmente públicas (ex.: createProposal, byId para view público). |
| 4 | (Opcional) Middleware de autorização “tem acesso a este venueId/organizationId?” usando `req.userId` e UserVenuePermission/UserOrganizationPermission | Requer consulta ao banco por request; pode ser em camada fina após ensureAuthenticate. |
| 5 | Corrigir typo `organizattionId` → `organizationId` no FE | Renomear em store e ProtectedRoute; manter contrato do service. |

---

## Decisões e recomendações

- Implementar fases 1 e 2 primeiro (req.userId + refresh) para habilitar autorização no BE e estabilizar sessão.
- Documentar rotas que permanecem **intencionalmente** públicas (ex.: proposal create, byId, venue getWebData, organization getHubData/getOrganizationWebData) em um único lugar (ex.: README ou este doc).
- Não remover auth de rotas já protegidas; ao adicionar auth em rotas novas, garantir que o FE sempre envie o token nesses fluxos (e tratar 401 com refresh ou redirect).
