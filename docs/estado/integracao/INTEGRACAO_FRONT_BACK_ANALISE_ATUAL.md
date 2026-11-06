# Integração Frontend–Backend — Análise Atual

**Escopo:** comunicação entre o frontend (`eventhub-vista-dashboard/`) e o backend (`art56_server_v3/`).  
**Data:** fevereiro/2025.  
**Base:** apenas o que existe no repositório (código, configs, docs).

---

## 1. Visão geral da integração

- **Comunicação:** O frontend (React + Vite) consome a API REST do backend (Express) via **HTTP/JSON**. Não há GraphQL, nem uso ativo de WebSocket ou SSE no fluxo de integração.
- **Cliente HTTP:** Uma única instância **Axios** em `eventhub-vista-dashboard/src/lib/axios.ts`, com `baseURL` definida por `import.meta.env.VITE_API_URL`. Todas as chamadas passam por essa instância (services em `src/services/` usam `api.get/post/put/delete`).
- **Protocolo:** REST (GET/POST/PUT/DELETE). Não há versionamento de API (ex.: `/v1/`) no backend.
- **Ambientes:** Alternância por variável de ambiente no frontend (`VITE_API_URL`). No backend, configuração via `process.env` (ex.: `DATABASE_URL`, `JWT_SECRET_KEY`). Não há arquivo `.env.example` em nenhum dos dois projetos; documentação de variáveis obrigatórias não encontrada.

---

## 2. Configuração de ambiente e base URLs

### Frontend

| Onde | O que |
|------|--------|
| `eventhub-vista-dashboard/src/lib/axios.ts` | `baseURL = import.meta.env.VITE_API_URL` |
| `eventhub-vista-dashboard/src/App.tsx` | `VITE_GOOGLE_CLIENT_ID` para OAuth |
| `eventhub-vista-dashboard/src/services/document.service.ts` | Declara `const API_URL = import.meta.env.VITE_API_URL` mas não usa (variável morta) |
| `eventhub-vista-dashboard/src/services/analytics.service.ts` | `VITE_VERCEL_PROJECT_ID`, `VITE_VERCEL_API_TOKEN` (chamadas a API Vercel, fora do BE do projeto) |

**Variáveis de ambiente usadas no FE (nomes reais):** `VITE_API_URL`, `VITE_GOOGLE_CLIENT_ID`, `VITE_VERCEL_PROJECT_ID`, `VITE_VERCEL_API_TOKEN`.

### Backend

| Onde | O que |
|------|--------|
| `art56_server_v3/src/server.ts` | CORS, `express.json`, montagem de rotas; não define base path |
| Uso em use cases/middleware | `process.env.JWT_SECRET_KEY`, `DATABASE_URL`, `AWS_*`, etc. |

**Problemas comuns:**

- **Hardcode:** Nenhuma URL do BE está hardcoded no FE; tudo passa por `VITE_API_URL`.
- **Env faltando:** Não existe `.env.example` em FE nem em BE; onboarding e deploy dependem de documentação externa ou memória da equipe.
- **Divergência:** FE e BE assumem que a mesma base (ex.: `http://localhost:3000` para o BE) é usada; não há config explícita de “ambientes” (dev/staging/prod) além da troca da URL no FE.

---

## 3. Mapeamento das chamadas do frontend para o backend

Tabela por **service** (arquivo FE) e **endpoint BE** correspondente. Auth = token enviado via header `Authorization: Bearer` quando a rota está protegida no BE.

| Tela/Fluxo | Arquivo(s) FE | Endpoint BE | Método | Auth? (BE) | Observações / Riscos |
|------------|--------------|-------------|--------|------------|------------------------|
| Login | `auth.service.ts` | `/auth/authenticate` | POST | Não | Credenciais + opcional fcmToken |
| Registro | `auth.service.ts` | `/auth/register` | POST | Não | |
| Registro/Login Google | `auth.service.ts` | `/auth/register/google` | POST | Não | |
| Refresh token | `lib/axios.ts` (interceptor) | `/auth/refresh` | GET | Não | **Risco:** BE usa mesmo controller que espera `req.body.accessToken`; GET não envia body → refresh pode falhar |
| Logout | `auth.service.ts` | — | — | — | Apenas limpa localStorage |
| Atualizar senha | `user.service.ts` | `/auth/update-password` | PUT | Sim | |
| Buscar usuário por ID | `user.service.ts`, `useBootstrapUser` | `/user/getById?userId=` | GET | Sim | BE retorna envelope `{ success, message, data, count, type }`; FE usa `response.data.data \|\| response.data` |
| Listar venues permitidos | `venue.service.ts` | `/venue/permittedVenueList?organizationId=&userId=` | GET | Sim | |
| Venue por ID | `venue.service.ts` | `/venue/getById?venueId=&userId=` | GET | Não | getById e getWebData sem ensureAuthenticate |
| Criar venue | `venue.service.ts` | `/venue/create` | POST | Sim | multipart (file = logo) |
| Atualizar venue | `venue.service.ts` | `/venue/update`, `/venue/update/payment-info`, `/venue/update/info` | PUT | Sim | create/update com multer `file` |
| Deletar venue | `venue.service.ts` | `/venue/delete/:venueId` | DELETE | Sim | |
| Dashboard/analytics venue | `venue.service.ts` | `/venue/analytics/:venueId`, `/venue/analysisByMonth`, `/venue/trafficCount` | GET | Sim (analytics) / Não (outros conforme router) | |
| Listar organizações | `organization.service.ts` | `/organization/list?userId=` | GET | Sim | |
| Organização por ID | `organization.service.ts` | `/organization/getById?organizationId=` | GET | Sim | |
| Criar/atualizar organização | `organization.service.ts` | `/organization/create`, `/organization/update` | POST/PUT | Sim | multipart (logoFile) |
| Criar proposta (per person/day) | `proposal.service.ts` | `/proposal/createPerPerson`, `/proposal/createPerDay` | POST | Não | Rotas de criação sem auth no BE |
| Proposta por ID | `proposal.service.ts` | `/proposal/byId/:proposalId` | GET | Não | |
| Listar/atualizar/deletar proposta | `proposal.service.ts` | `/proposal/list`, `/proposal/updatePerPerson`, `/proposal/updatePersonalInfo`, `/proposal/updatePerDay`, `/proposal/delete/:proposalId` | GET/PUT/DELETE | Parcial (list, updatePerDay, delete com auth; updatePersonalInfo sem auth) | Inconsistência de proteção |
| Listar/criar/atualizar/deletar pagamento | `payment.service.ts` | `/payment/list`, `/payment/create`, `/payment/update`, `/payment/delete/:paymentId` | GET/POST/PUT/DELETE | Não (nenhuma rota com ensureAuthenticate) | **Risco:** FE chama `GET /payment/byId/:paymentId`; **essa rota não existe no BE** (apenas list, create, update, delete) |
| Documento por ID | `document.service.ts` | `GET /document/${id}` | GET | Não | **Risco:** BE não expõe GET por ID (rota comentada em `router/document.ts`); chamada pode resultar em 404 |
| Listar/criar/atualizar/deletar documento | `document.service.ts` | `/document/list`, `/document/create`, `/document/update`, `/document/delete/:documentId` | GET/POST/PUT/DELETE | Não | |
| Upload/listar/atualizar/deletar imagem | `image.service.ts` | `/image/upload`, `/image/upload/image-organization`, `/image/list`, `/image/getByTag`, `/image/delete/:imageId`, `/image/update`, etc. | Diversos | Não | Nenhuma rota de image com ensureAuthenticate |
| Permissões organização | `userOrganizationPermission.service.ts` | `/userOrganizationPermission/...` | GET/POST/PUT/DELETE | Sim | Store usa typo `organizattionId`; service recebe `organizationId` |
| Permissões venue | `userVenuePermissions.service.ts` | `/userVenuePermission/list?organizationId=` | GET | Sim | |
| Outros (goal, expense, contract, clause, notification, schedule, dateEvent, attachment, owner, text, email, emailConfig, seasonalFee, contact) | Services em `src/services/` | Prefixos `/goal`, `/expense`, `/contract`, etc. | Conforme recurso | Parcial ou nenhum em vários | Vários recursos sem auth no BE |

**Resumo de riscos de mapeamento:**

- **Refresh token:** FE usa GET `/auth/refresh` sem body; BE controller (compartilhado com POST `/token/refresh`) espera `body.accessToken` → fluxo de refresh quebrado ou dependente de implementação não óbvia.
- **GET document by ID:** FE chama `GET /document/:id`; BE não possui essa rota (comentada).
- **GET payment by ID:** FE chama `GET /payment/byId/:paymentId`; BE não possui essa rota.

---

## 4. Autenticação e sessão (end-to-end)

- **Login:** FE envia POST `/auth/authenticate` com `{ email, password, fcmToken? }`. BE valida e retorna `{ accessToken, session: { id, userId, refreshTokenId, expiresAt } }`. FE grava em `localStorage`: `@EventHub:token` (accessToken) e `@EventHub:session` (JSON da session).
- **Onde o token nasce:** No BE, em `use-cases/auth/authenticate-user` (e register/register-google); geração via `RefreshTokenProvider` e sessão/refresh token no banco.
- **Onde é guardado:** No FE, apenas em `localStorage` (não há httpOnly cookie). Interceptor de request em `axios.ts` lê `localStorage.getItem('@EventHub:token')` e seta `Authorization: Bearer <token>`.
- **Refresh:** Em 401, o interceptor chama `api.get('/auth/refresh')` (sem body), espera `response.data.accessToken`, grava o novo token no localStorage e reenvia a request. O BE expõe GET `/auth/refresh` usando o mesmo `RefreshTokenController` que faz `refreshTokenSchema.parse(req.body)` → em GET `req.body` está vazio/undefined → **refresh tende a falhar**. POST `/token/refresh` existe e espera `{ accessToken }` no body; o FE não o utiliza.
- **Riscos:** (1) Token em localStorage (XSS pode roubar). (2) Fluxo de refresh GET quebrado por incompatibilidade FE/BE. (3) Middleware `ensureAuthenticate` no BE apenas valida JWT; **não seta `req.userId`** (código que fazia isso está comentado), então autorização por recurso no servidor não é confiável. (4) Várias rotas sensíveis (image, document, payment, text, proposal create/byId, etc.) sem `ensureAuthenticate`.

---

## 5. Contratos de dados (DTOs) e tipagem

- **Frontend:** DTOs e tipos em `eventhub-vista-dashboard/src/types/` (venue, user, organization, proposal, payment, document, image, etc.). Services importam esses tipos e tipam respostas como `api.get<VenueListResponse>(...)`. Em `venue.ts` há comentários com `any[]` para relações não tipadas; em outros pontos há `any` ou `as any` e `@ts-expect-error` (ex.: `lib/error-handler.ts`).
- **Backend:** Request validado com **Zod** em `art56_server_v3/src/zod/` (por recurso). Response não tem DTOs documentados; controllers retornam o que o use case devolve (objeto direto ou formato ad hoc; ex.: user getById retorna `{ success, message, data, count, type }`).
- **Alinhamento:** Parcial. FE assume estruturas (ex.: `response.data.venueList`, `response.data.data`) que dependem do formato real do BE; nem todos os endpoints retornam envelope padronizado (ex.: alguns `res.json(data)` direto, outros com `success/message/data`). Não há validação runtime no FE (Zod nos forms existe; não há schemas de resposta da API).
- **Naming:** BE (Prisma/DB) e Zod tendem a **camelCase**; FE types também camelCase. Não foi encontrada transformação sistemática snake_case ↔ camelCase; inconsistências pontuais (ex.: typo `organizattionId` no store vs `organizationId` no service).
- **Inconsistências:** (1) Envelope de sucesso não único: às vezes `{ data }`, às vezes `{ success, message, data, count, type }`, às vezes payload direto. (2) FE `BackendResponse<T>` em `error-handler.ts` define `success, message, data`; BE nem sempre retorna esse formato. (3) Campos opcionais/nulos: tipos no FE podem não refletir exatamente o que o BE retorna (ex.: relações com `any[]` comentadas).

---

## 6. Tratamento de erros (end-to-end)

- **Backend:** `art56_server_v3/src/errors/error-handler.ts` — `handleErrors(error)` retorna `{ statusCode, body: { title, message } }`. Trata: erros HTTP custom (HttpTokenError, HttpConflictError, HttpBadRequestError, etc.), **ZodError** (400 com mensagens dos campos), **PrismaClientKnownRequestError** (P2002 → 409, P2007 → 400), **PrismaClientValidationError** (400). Erro genérico → 500 com `body.message: error.toString()` (risco de vazar detalhes em produção). Cada controller chama `handleErrors` no `catch` e responde `status(...).json(body)`. **Não há** middleware global de erro (4 params) e `express-async-errors` não é importado em `server.ts` → rejeições não tratadas podem não virar resposta JSON.
- **Frontend:** `eventhub-vista-dashboard/src/lib/error-handler.ts` — `handleBackendError(error, defaultMessage)` extrai `error.response?.data?.title` e `error.response?.data?.message` e retorna `{ title, message }`. Compatível com o formato `body: { title, message }` do BE. Serviços e componentes usam esse helper ou tratam `axios.isAxiosError` manualmente; não há interceptor global que normalize todos os erros para um formato único na UI.
- **Padronização:** BE padroniza corpo de erro em `{ title, message }`; FE espera esse formato. Falta: código de erro interno (ex.: `code`) para decisões programáticas; padronização de mensagens em um único lugar; e garantia de que 500 em produção não exponha `error.toString()`.

**Sugestão de padrão simples:** Manter `{ title, message }` e adicionar opcional `code: string` no BE; FE usar sempre `handleBackendError` (ou interceptor) e exibir `title`/`message`; em produção, 500 com mensagem genérica e log completo apenas no servidor.

---

## 7. Uploads, arquivos e mídia (se existir)

- **Como FE envia:** FormData com `multipart/form-data`. Ex.: venue create/update (`venue.service.ts`) envia campos + `file` (logo); organization idem; image (`image.service.ts`) envia `file`, `tag`, `venueId`, etc.; document (`document.service.ts`) envia `title`, `proposalId`, `fileType`, `file`; payment (`payment.service.ts`) envia campos + `file` para comprovante.
- **Como BE recebe:** **Multer** (memória: `multer.memoryStorage()`) em rotas de upload (venue, organization, image, document, payment). Arquivos processados em controller/use case (ex.: S3, Sharp para imagens). Limite de body global: `express.json({ limit: "50mb" })` e `urlencoded({ limit: "50mb" })` em `server.ts` — alto para produção.
- **Limites e validação:** Nenhum limite por arquivo documentado no FE; BE usa multer sem `limits` explícito no trecho analisado. Validação de tipo de arquivo não centralizada (Zod em alguns bodies; tipo de arquivo pode ser validado em use case).
- **Problemas:** (1) Body 50mb facilita DoS. (2) Rotas de upload (image, document, payment) sem `ensureAuthenticate`. (3) Inconsistência de nomes de campo: FE venue usa `logoFile` no DTO e envia como `file` no FormData; BE venue espera `upload.single("file")` — alinhado; outros recursos conferir conforme router.

---

## 8. Realtime / Eventos / Notificações (se existir)

- **WebSocket/SSE:** Não encontrado no frontend (nenhum `WebSocket`, `EventSource`, `socket.io-client` em uso no fluxo de integração com o backend). No backend, `socket.io` e `socket.io-client` estão no `package.json` de `art56_server_v3`, mas **nenhuma rota ou handler de Socket.IO** foi identificado em `src/router` ou `server.ts`; uso em outros pontos não mapeado.
- **Polling / webhooks:** Não identificado como padrão de integração FE↔BE.
- **Conclusão:** Realtime não está implementado na integração atual. Notificações (Firebase, Web Push) são tratadas no BE; o FE não consome eventos em tempo real via essa API.

---

## 9. CORS, segurança e políticas de rede

- **CORS no BE:** `art56_server_v3/src/server.ts`: `cors({ origin: "*", methods: ["GET", "POST", "DELETE", "UPDATE", "PUT", "PATCH"] })`. Qualquer origem permitida; inadequado para produção com credenciais (cookies, se no futuro).
- **Headers e cookies:** FE envia apenas `Authorization: Bearer` e `Content-Type`; não há uso de cookies para sessão/token. BE não envia `Set-Cookie` no fluxo analisado. SameSite/Secure não aplicável ao fluxo atual (token em localStorage).
- **Rate limit:** Não encontrado no BE.
- **Proteção básica:** Muitos endpoints sem autenticação (image, document, payment, text, parte de proposal, etc.); CORS `*`; body 50mb; 500 pode vazar detalhes.

---

## 10. Principais gargalos e riscos atuais

- **Estabilidade:** Refresh token GET sem body vs BE que espera body; rotas FE inexistentes no BE (GET document by ID, GET payment by ID); ausência de middleware global de erro e de `express-async-errors` no BE (rejeições async podem não virar resposta).
- **Segurança:** Token em localStorage (XSS); CORS `origin: "*"`; várias rotas sensíveis sem auth; `req.userId` não preenchido no middleware; 500 expondo `error.toString()`.
- **Velocidade de desenvolvimento:** Contratos não documentados (sem OpenAPI/Swagger); envelope de resposta inconsistente; typo `organizattionId` e hook `useGetVenuesList` com assinatura errada (só `organizationId`, sem `userId`); rotas públicas duplicadas (axios vs useBootstrapUser).
- **Bugs em produção:** Chamadas a GET document/:id e GET payment/byId/:id que retornam 404; refresh que pode falhar; dupla fonte de verdade (Zustand + React Query) pode gerar dados dessincronizados.

---

## 11. Dívidas técnicas priorizadas (integração)

### Crítico

| Problema | Onde | Impacto | Sugestão |
|----------|------|----------|----------|
| Refresh token: FE usa GET sem body, BE espera body | FE: `eventhub-vista-dashboard/src/lib/axios.ts` (interceptor). BE: `art56_server_v3/src/router/auth.ts` (GET /auth/refresh usa controller que parse req.body) | Refresh em 401 falha; usuário é deslogado sem conseguir renovar token | FE: trocar para POST `/token/refresh` com body `{ accessToken: localStorage.getItem('@EventHub:token') }`; ou BE: criar handler GET /auth/refresh que leia token do header Authorization e renove |
| GET document by ID inexistente no BE | FE: `document.service.ts` (`/document/${id}`). BE: `art56_server_v3/src/router/document.ts` (rota getById comentada) | 404 ao abrir documento por ID | Implementar GET /document/getById/:documentId no BE (ou GET /document/:id) e expor no router; ou FE remover/ajustar chamada até rota existir |
| GET payment by ID inexistente no BE | FE: `payment.service.ts` (`/payment/byId/${paymentId}`). BE: `art56_server_v3/src/router/payment.ts` (sem rota byId) | 404 ao buscar pagamento por ID | Implementar GET /payment/byId/:paymentId no BE; ou FE usar apenas list e filtrar no cliente até rota existir |
| Rotas sensíveis sem autenticação | BE: `router/image.ts`, `router/document.ts`, `router/payment.ts`, `router/text.ts`, `router/proposal.ts` (create, byId), etc. | Acesso não autorizado a dados e uploads | Aplicar `ensureAuthenticate` (ou middleware de autorização) em rotas que alteram ou retornam dados restritos; exceção explícita apenas para rotas realmente públicas |
| Typo `organizattionId` no store | FE: `store/userOrganizationPermissionStore.ts`, `components/ProtectedRoute.tsx` | Nome errado propagado; risco ao corrigir só em um lugar | Renomear para `organizationId` em store e ProtectedRoute; service já usa `organizationId` |
| Hook useGetVenuesList com assinatura errada | FE: `hooks/venue/queries/list.ts` — chama `venueService.getAllVenues(organizationId)` com 1 arg; service espera `{ organizationId, userId }` | Lista de venues pode falhar ou usar valor indefinido | Ajustar hook para receber `organizationId` e `userId` e chamar `venueService.getAllVenues({ organizationId, userId })` |

### Importante

| Problema | Onde | Impacto | Sugestão |
|----------|------|----------|----------|
| Rotas públicas duplicadas | FE: `lib/axios.ts` (PUBLIC_ROUTES) e `hooks/useBootstrapUser.ts` (PUBLIC_ROUTES) | Alteração em uma lista e não na outra gera comportamento inconsistente | Centralizar em `src/constants/publicRoutes.ts` e importar nos dois arquivos |
| Envelope de resposta inconsistente | BE: alguns endpoints retornam `{ data }`, outros `{ success, message, data, count, type }`, outros payload direto | FE precisa fallbacks (`response.data.data \|\| response.data`); frágil | Padronizar no BE um formato único (ex.: sempre `{ data }` para sucesso) e documentar; FE ajustar services para um único padrão |
| req.userId não definido após auth | BE: `middleware/ensureAuthenticate.ts` (trecho que setava req.userId comentado) | Impossível autorizar por recurso no servidor | Decodificar JWT no middleware e setar `req.userId` (e tipar Request); reativar lógica de sessão/refresh se necessário |
| CORS origin "*" | BE: `server.ts` | Permite qualquer origem; risco com credenciais | Restringir `origin` a domínios conhecidos (variável de ambiente) |
| Falta de .env.example | FE e BE | Onboarding e deploy sem lista de variáveis | Criar `.env.example` em ambos com nomes das variáveis (sem valores sensíveis) |

### Melhorias

| Problema | Onde | Impacto | Sugestão |
|----------|------|----------|----------|
| Tratamento de erro da API não unificado na UI | FE: services e componentes usam handleBackendError ou try/catch ad hoc | Mensagens e comportamento diferentes por tela | Interceptor de response que normaliza erro e opcionalmente dispara toast; serviços lançando erro tipado único |
| Validação de resposta no FE (Zod/runtime) | FE: tipos apenas em compile-time | Resposta inesperada do BE pode quebrar em runtime | Opcional: schemas Zod para respostas críticas (ex.: auth, user) e parse antes de usar |
| Documentação da API (OpenAPI/Swagger) | BE | Contratos implícitos; integração manual | Gerar ou escrever OpenAPI e, se possível, gerar tipos do FE a partir dele |

---

## 12. Plano de evolução em 2 semanas

Foco: **padronização de contratos e erros**, **auth segura**, **DX (tipos/contratos)** e **observabilidade mínima**.

### Semana 1

| Dia | Tarefa | Responsável | Detalhe |
|-----|--------|-------------|---------|
| 1 | Corrigir refresh token | FE + BE | FE: passar a usar POST `/token/refresh` com body `{ accessToken }` no interceptor; ou BE: implementar GET `/auth/refresh` que leia token do header e chame o use case de refresh |
| 1 | Expor GET document by ID e GET payment by ID | BE | Implementar rotas no router e use cases (ou confirmar se há factory existente); aplicar ensureAuthenticate onde fizer sentido |
| 2 | Aplicar ensureAuthenticate nas rotas sensíveis | BE | image, document, payment, text, emailConfig, proposal (create/byId conforme regra de negócio); testar fluxos principais (login, upload, proposta, pagamento) |
| 2 | Corrigir typo organizattionId e hook useGetVenuesList | FE | Renomear em store e ProtectedRoute; ajustar hook para `{ organizationId, userId }` |
| 3 | Centralizar rotas públicas e criar .env.example | FE | `constants/publicRoutes.ts`; `.env.example` com VITE_API_URL, VITE_GOOGLE_CLIENT_ID, etc. |
| 3 | Padronizar envelope de sucesso no BE | BE | Definir formato único (ex.: `{ data }` ou `{ success, data }`) e ajustar controllers críticos (auth, user, venue); documentar em comentário ou README |
| 4 | Setar req.userId no ensureAuthenticate | BE | Decodificar JWT e atribuir `req.userId`; tipar `Request` com `userId?: string` |
| 4 | CORS por variável de ambiente | BE | `origin: process.env.CORS_ORIGIN?.split(',') || '*'` e criar .env.example |
| 5 | Tratamento global de erros no BE | BE | Importar `express-async-errors` no topo de server.ts; middleware de erro (4 params) que chame handleErrors e responda JSON; em produção não retornar `error.toString()` no 500 |

### Semana 2

| Dia | Tarefa | Responsável | Detalhe |
|-----|--------|-------------|---------|
| 1 | Padronizar corpo de erro (opcional code) | BE | Adicionar `code?: string` no body de erro; FE: usar handleBackendError em fluxos que ainda não usam |
| 2 | Ajustar FE para envelope único | FE | Onde o BE tiver padronizado, remover fallbacks `response.data.data \|\| response.data` e usar apenas um formato |
| 3 | Documentar contratos (OpenAPI ou README) | BE | Listar endpoints, método, auth, body de request/response para auth, user, venue, proposal, payment, document |
| 4 | Observabilidade mínima | BE | Health check já existe (GET /); considerar log estruturado (ex.: pino) em 1–2 rotas piloto e em handleErrors |
| 5 | Revisão e testes manuais | FE + BE | Testar login, refresh, lista de venues, proposta, documento, pagamento; validar que nenhuma chamada FE aponta para rota inexistente |

---

## Resumo do que foi encontrado

- **Integração:** FE (React, Axios) consome API REST do BE (Express); uma base URL por env (`VITE_API_URL`); sem versionamento de API, sem GraphQL/WS/SSE em uso.
- **Auth:** Login/registro retornam `accessToken` e `session`; FE guarda em localStorage; interceptor adiciona Bearer e em 401 chama GET `/auth/refresh` **sem body**, enquanto o BE espera body com `accessToken` → **refresh quebrado**.
- **Rotas FE sem equivalente no BE:** GET `/document/:id` e GET `/payment/byId/:paymentId`; várias rotas sensíveis no BE sem `ensureAuthenticate`.
- **Contratos:** BE valida request com Zod; response sem padrão único (às vezes envelope `{ data }` ou `{ success, message, data }`, às vezes payload direto); FE tem tipos em `src/types/` e helper de erro compatível com `{ title, message }`.
- **Uploads:** FormData + Multer; limite 50mb no BE; rotas de image/document/payment sem auth.
- **Segurança:** CORS `*`; token em localStorage; `req.userId` não setado; 500 pode vazar detalhes; sem rate limit.
- **Dívidas de integração:** Typo `organizattionId`; hook `useGetVenuesList` com um só argumento; rotas públicas duplicadas; ausência de middleware global de erro e de `.env.example` em FE e BE.

**Fim do documento.**
