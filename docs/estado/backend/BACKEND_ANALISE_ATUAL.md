# Análise do Backend — Estado Atual

Documento técnico descrevendo o estado atual do backend do projeto **eventhub**. O código do servidor está em **`art56_server_v3/`**. Baseado exclusivamente no que existe no repositório.

---

## 1. Visão geral do backend

- **Stack:** Node.js, **Express** (API HTTP), **TypeScript**, **Prisma** (ORM), banco **MySQL**. Runtime: Node (dev com `ts-node-dev`).
- **Principais libs:** `express`, `cors`, `jsonwebtoken`, `bcryptjs`, `zod`, `multer` / `multer-s3`, `@aws-sdk/client-s3` e `lib-storage`, `sharp`, `nodemailer`, `firebase-admin`, `web-push`, `socket.io` (dependência presente; uso em rotas não identificado).
- **Infra local:** Sem `app.listen` no repositório; aplicação exporta o `app` para o **Vercel** (`vercel.json` aponta `src/server.ts` como handler). Desenvolvimento local via `npm run dev` (ts-node-dev).
- **Padrão arquitetural:** Monolito modular com **use cases**: rotas → controllers (factories) → use cases → repositórios Prisma. Uso de interfaces de repositório em parte dos use cases. Validação com Zod nos controllers. Padrão próximo a “Clean Architecture” simplificado (camadas controller → use case → repository), sem camada de domínio rica.

---

## 2. Estrutura de pastas

Estrutura relevante (dentro de `art56_server_v3/`):

```
art56_server_v3/
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── src/
│   ├── server.ts                 # Montagem do app Express e rotas
│   ├── router/                   # 29 arquivos de rotas (auth, user, venue, organization, ...)
│   ├── middleware/               # ensureAuthenticate.ts
│   ├── use-cases/                # Por recurso: auth, user, venue, proposal, image, email, ...
│   │   └── <recurso>/<ação>/    # controller-*, use-case-*, factory-*
│   ├── repositories/
│   │   ├── in-prisma/            # Implementações Prisma (venue, user, proposal, ...)
│   │   └── interface/            # Interfaces dos repositórios
│   ├── services/                 # prisma-client, upload-config-sw (S3), firebase, web-push, send-forgot-password-email
│   ├── provider/                 # refresh-token, generate-refresh-token
│   ├── config/                   # firebaseAdmin
│   ├── errors/
│   │   ├── error-handler.ts
│   │   ├── errors-type/          # HttpTokenError, HttpConflictError, HttpBadRequestError, etc.
│   │   └── validators/
│   ├── zod/                      # Schemas por recurso (venue, user, auth, proposal, ...)
│   ├── utils/                    # sendNotification (Firebase)
│   └── scripts/                 # generate-vapid-keys.ts
├── vercel.json
├── package.json
├── tsconfig.json
└── vitest.config.ts
```

**Pontos positivos**

- Separação clara: router → controller (factory) → use case → repository.
- Repositórios abstraídos por interfaces em vários use cases.
- Validação concentrada em schemas Zod por recurso (`src/zod/`).
- Erros HTTP tipados e handler central (`handleErrors`).
- Prisma com singleton para dev (`globalThis.prisma`) e migrations versionadas.

**Problemas**

- Duplicação de `express.json()` em `server.ts` (linhas 42 e 44) e body limit 50mb aplicado depois de outro `express.json()` sem limit.
- Nenhum middleware global de erro (async rejections não capturadas se o controller não fizer try/catch); `express-async-errors` está no `package.json` mas **não é importado** em `server.ts`.
- Inconsistência de proteção por rota: vários recursos (image, document, payment, text, clause, contact, etc.) sem `ensureAuthenticate`.
- Nomenclatura e typos: comentários em `seasonal-fee.ts` usam `seasonalfeeRoutes`; em `dateEvent.ts` trechos comentados referenciam `getTextByIdFactory`/`getTextByAreaFactory` (provavelmente deveriam ser de dateEvent).

---

## 3. API: rotas/endpoints e recursos

### 3.1 Grupos de rotas (prefixos)

| Prefixo | Autenticação | Recursos principais |
|--------|----------------|---------------------|
| `/auth` | Parcial (apenas update-password) | register, register/google, authenticate, refresh, reset-password, forgot-password, update-password |
| `/user` | Todas (`use(ensureAuthenticate)`) | update, updatePassword, createNewUser, getById, getByEmail, delete, list, fcm-token |
| `/venue` | Maioria (getById e getWebData sem auth) | create, list, permittedVenueList, trafficCount, analysisByMonth, getById, getWebData, update, update/payment-info, update/info, delete, analytics |
| `/organization` | Maioria (getHubData, getOrganizationWebData sem auth) | create, list, getHubData, getById, delete, getOrganizationWebData, update, update-venue-organization-images |
| `/token` | Não | refresh (POST) |
| `/text` | Não | create, create-text-organization, list, list-text-organization, delete, update, update-text-organization, getById, getByArea |
| `/image` | Não | upload, upload/image-organization, list, organization/list, delete, getByTag, getByTag/image-organization, update, organization/update |
| `/goal`, `/expense`, `/attachment`, `/owner`, `/userVenuePermission`, `/userOrganization`, `/userOrganizationPermission` | Todas (`use(ensureAuthenticate)`) | CRUD / list / get conforme recurso |
| `/service` | create, delete, update (list sem auth) | create, list, delete, update |
| `/proposal` | updatePerPerson, updatePerDay, list, delete (create e byId sem auth) | createPerPerson, createPerDay, byId, updatePerPerson, updatePersonalInfo, updatePerDay, list, delete |
| `/payment`, `/document`, `/contact`, `/clause`, `/contract`, `/question`, `/schedule`, `/dateEvent`, `/notification`, `/email`, `/emailConfig`, `/seasonalFee` | Parcial ou nenhuma | CRUD/list/get conforme arquivo em `src/router/` |

### 3.2 Convenções

- **REST:** Uso de GET/POST/PUT/DELETE; muitos recursos seguem padrão create/list/getById/update/delete. Algumas rotas misturam query e path (ex.: `getById?:venueId?/:userId?`, `list?:organizationId?/:name?`).
- **Versionamento:** Não há (ex.: sem `/v1/`).
- **Status codes:** Definidos no `error-handler` (400, 401, 409, 500) e nos controllers (ex.: 201 em create). Não há padronização explícita de documento de API.
- **Resposta de sucesso:** Geralmente `res.json(data)`. Resposta de erro: `handleErrors(error)` retorna `{ statusCode, body: { title, message } }`.

### 3.3 Padrão de resposta e erros

- Sucesso: JSON com o payload do use case (sem envelope único definido).
- Erro: `{ title, message }` com status HTTP no handler (400 para Zod/validação, 401 para token, 409 para conflito Prisma P2002, 500 genérico). Em produção, `error.toString()` no 500 pode vazar detalhes.

---

## 4. Regras de negócio e fluxos

- **Fluxos principais percebidos:** (1) Auth: registro (email e Google), login, refresh token, forgot/reset password; (2) Organização → Venues → Proposals/DateEvents/Payments/Services/Expenses; (3) Proposals com pessoas, pagamentos, documentos e notificações; (4) Permissões por organização e por venue (UserOrganization, UserVenuePermission, UserOrganizationPermission); (5) Envio de e-mail (proposta, contrato, confirmação de presença, forgot password); (6) Notificações (Firebase, Web Push); (7) Upload de imagens/documentos (S3, conversão WebP com Sharp).
- **Onde estão:** Lógica nos **use cases** (`src/use-cases/`) e em **repositórios** (`src/repositories/in-prisma/`). Controllers em `use-cases/<recurso>/<ação>/controller-*.ts`; factories injetam repositório no use case e use case no controller.
- **Acoplamento e risco:** (1) Controllers de image/organization/document fazem chamadas diretas a S3 e Sharp (lógica de infra no controller). (2) E-mail e notificação instanciados dentro de use cases (nodemailer, Firebase), sem abstração única. (3) `ensureAuthenticate` só valida JWT; não preenche `req.userId` (código que fazia isso está comentado em `ensureAuthenticate.ts`), então autorização por recurso (ex.: “só dono do venue”) depende de parâmetros enviados pelo cliente. (4) Criação de proposta e de eventos (createPerPerson, createPerDay, createSameDay, createOvernigth) com múltiplas escritas; apenas create-venue usa `$transaction` no repositório.

---

## 5. Camada de dados (DB/ORM)

- **Banco e ORM:** **MySQL** (env `DATABASE_URL` e `SHADOW_DATABASE_URL`). **Prisma** como ORM.
- **Schema:** `prisma/schema.prisma` com `relationMode = "prisma"` (sem FKs no banco; Prisma gerencia relações em runtime). Modelos: User, RefreshToken, Session, Organization, UserOrganization, UserVenuePermission, UserOrganizationPermission, Venue, Proposal, Person, Service, Payment, Expense, Notification, DateEvent, Image, Text, Document, Question, Contract, Clause, Attachment, Owner, OwnerVenue, Contact, Goal, SeasonalFee, EmailConfig, etc. Enums para tipos (ProposalType, TrafficSource, PaymentMethod, etc.).
- **Migrations:** `prisma/migrations/` (ex.: `20250410160223_f`, `20250425133417_google_id`). Migrations em SQL (MySQL).
- **Seeds:** Não encontrado.
- **Padrões de query:** Uso de `findMany`, `findFirst`, `findUnique`, `create`, `update`, `delete` com `select`/`include` em vários pontos. Exemplo de boa prática: `venue-in-prisma-repository.ts` usa `select` enxuto e `_count` para eventos do mês. **`PrismaContractRepository`:** inclui `clauses` com `orderBy` por `position` asc e `createdAt` asc em `create`, `getById`, `update` (retorno) e `list` — garante ordem estável nas leituras de contrato. **Transações:** Apenas em `venue-in-prisma-repository.ts` no create (`.$transaction`). Outros fluxos com múltiplas escritas (proposal, payment, dateEvent) não usam transação explícita.
- **Consistência:** Risco em fluxos que criam/atualizam várias entidades sem `$transaction` (proposal + persons + dateEvents + payments, etc.).

---

## 6. Autenticação e autorização

- **Estratégia:** **JWT** (Bearer). Biblioteca `jsonwebtoken`; verificação em `src/middleware/ensureAuthenticate.ts` com `process.env.JWT_SECRET_KEY`.
- **Onde acontece:** Middleware `ensureAuthenticate` aplicado por rota ou com `router.use(ensureAuthenticate)` em alguns routers (user, owner, organization, userVenuePermission, userOrganization, useOrganizationPermission, goal, expense, attachment). Rotas de auth (register, authenticate, forgot-password, refresh, etc.) não exigem token; apenas `PUT /auth/update-password` exige.
- **Refresh/sessão:** Modelos `RefreshToken` e `Session` existem no schema; há `provider/refresh-token-provider` e `GenerateRefreshToken`; rota `GET /auth/refresh` e `POST /token/refresh`. O middleware ativo **só faz verify do JWT**; o trecho que validava sessão, renovava token e setava `req.userId` está comentado.
- **Problemas:** (1) **`req.userId` não é definido** no middleware ativo — autorização “quem pode editar este venue” não pode ser feita de forma confiável no servidor. (2) Várias rotas sensíveis **sem** `ensureAuthenticate`: upload de imagem, documento, pagamento, texto, cláusula, contrato, contato, proposta (criação e byId), listagem de serviços, notificações, configuração de e-mail, etc. (3) Sem roles/RBAC no middleware (apenas “autenticado ou não”). (4) Uso de `process.env.JWT_SECRET_KEY!` sem checagem; se faltar, falha em runtime.

---

## 7. Validação, serialização e contratos

- **Request:** Validação com **Zod** nos controllers: `schema.parse(body)` ou `schema.parse(params/query)`. Schemas em `src/zod/` por recurso (ex.: `zod/venue/create-venue-request-schema.ts`, `zod/auth/authenticate-user-params-schema.ts`). Em muitos use cases os parâmetros são tipados com `z.infer<typeof schema>`.
- **Response:** Sem DTOs ou schemas de resposta documentados; retorno é o objeto do use case/repositório. Risco de vazar campos (ex.: hash de senha) se o use case retornar o modelo bruto.
- **Inconsistências:** (1) Algumas rotas recebem parâmetros por query/path com convenções frágeis (`?:organizationId?/:name?`), o que dificulta validação e documentação. (2) Não há validação centralizada de `req.params`/`req.query` em middleware (cada controller chama parse). (3) Arquivo duplicado/cópia: `list-service-by-venue-param-schema copy.ts` em `zod/services/`.

---

## 8. Tratamento de erros e logging

- **Estratégia de erros:** `src/errors/error-handler.ts` — função `handleErrors(error)` que trata: erros HTTP custom (HttpTokenError, HttpStandartError, HttpConflictError, HttpBadRequestError, HttConfigurationError, HttpResourceNotFoundError, HttDateEventAvailableError, HttpInvalidCredentialsError), **ZodError** (400 com mensagens dos campos), **PrismaClientKnownRequestError** (P2002 → 409, P2007 → 400), **PrismaClientValidationError** (400). Erro genérico → 500 com `error.toString()`. Cada controller chama `handleErrors` no `catch` e devolve `status(errorResponse.statusCode).json(errorResponse.body)`.
- **Problema:** Não existe middleware global de erro (4 params) no Express; `express-async-errors` não está importado. Se um handler async lançar sem try/catch, a rejeição pode não ser convertida em resposta (comportamento dependente do Node/Express).
- **Logging:** Uso de `console.log`/`console.error` em vários controllers e use cases (ex.: create-image, update-document, delete-document). **Não há** lib estruturada (pino, winston) nem formato padrão ou correlation id.
- **Observabilidade:** Não encontrado (OpenTelemetry, Sentry, APM, health check dedicado). Rota `GET /` retorna “API online!” (pode ser usada como health simples).

---

## 9. Segurança

- **CORS:** `cors({ origin: "*", methods: ["GET", "POST", "DELETE", "UPDATE", "PUT", "PATCH"] })` — qualquer origem permitida. Inadequado para produção com credenciais.
- **Headers:** Nenhum middleware de segurança explícito (Helmet, X-Content-Type-Options, etc.) encontrado.
- **Rate limit:** Não encontrado.
- **Body/upload:** `express.json({ limit: "50mb" })` e `urlencoded({ limit: "50mb" })` — limite alto; risco de DoS por payload grande.
- **Sanitização:** Apenas validação Zod (tipos e formato); não há sanitização explícita de HTML/SQL (Prisma mitiga SQL injection).
- **Secrets:** Uso de `process.env` (JWT_SECRET_KEY, DATABASE_URL, AWS_*, etc.). **Não há `.env.example`** no repositório; documentação de variáveis obrigatórias inexistente.
- **Riscos:** (1) CORS `*` com possível uso de credenciais. (2) Muitos endpoints sem autenticação (upload, documentos, pagamentos, textos, etc.). (3) Resposta 500 pode expor `error.toString()`. (4) JWT sem checagem de revogação/sessão ativa (middleware simplificado).

---

## 10. Integrações, filas, jobs e webhooks

- **O que existe:**  
  - **AWS S3:** Upload de imagens (venue, organization, image, image-organization), documentos e configuração de e-mail. Uso de `@aws-sdk/client-s3` (PutObjectCommand, DeleteObjectCommand) e em um ponto `upload-config-sw.ts` com `multer-s3`.  
  - **E-mail:** Nodemailer em `send-forgot-password-email.ts` e nos use cases de envio (proposta, contrato, confirmação de presença). Transport criado dentro de cada use case com variáveis de ambiente.  
  - **Firebase Admin:** Notificações (`firebase-notification-service.ts`, `utils/sendNotification.ts`, `config/firebaseAdmin`).  
  - **Web Push:** `web-push-service.ts` e script `generate-vapid-keys.ts`.
- **Filas / jobs / cron:** Não encontrado (sem BullMQ, Agenda, Cloud Tasks, etc.).
- **Webhooks:** Não encontrado.
- **Confiabilidade:** Sem retry ou fila para e-mail/S3/notificação; falha no envio resulta em falha da request. Sem idempotência documentada (ex.: chave idempotency em criação de proposta/pagamento).

---

## 11. Performance e escalabilidade

- **Gargalos prováveis:** (1) Listas sem paginação (venue, proposal, user, organization, etc.) — `findMany` sem `take`/`skip` em vários repositórios. (2) Possível N+1 onde listas retornam e depois se acessam relações em loop (não mapeado em detalhe; em venue list há `include`/`select` bem definidos). (3) Endpoints que fazem upload + processamento (Sharp + S3) síncronos na request. (4) Body 50mb permite requests muito grandes.
- **Cache:** Não encontrado (Redis ou in-memory).
- **Melhorias rápidas:** (1) Adicionar paginação (limit/offset ou cursor) nas listagens principais. (2) Importar `express-async-errors` e adicionar middleware global de erro. (3) Reduzir `console.log` e considerar logger estruturado. **Estruturais:** (1) Mover upload/processamento para job assíncrono ou fila. (2) Introduzir cache para leituras pesadas (ex.: listagem de venues por organização). (3) Revisar índices no Prisma/MySQL para filtros e ordenações mais usados.

---

## 12. Testes

- **O que existe:** Vitest configurado em `vitest.config.ts` (ambiente node, coverage text/json/html). Apenas **2 arquivos de spec** encontrados: `src/use-cases/session/get-session-by-user-id/use-case-get-session-by-user-id.spec.ts` e `src/provider/refresh-token-provider.spec.ts`. Um teste está com `it.skip` no refresh-token-provider.
- **O que não existe:** Testes de integração (API/HTTP), e2e, testes de rotas, testes da maioria dos use cases e repositórios. Nenhum mock de Prisma/S3/email sistemático.
- **Recomendação mínima viável:** (1) Testes unitários para use cases críticos (auth, create proposal, create payment) com repositórios mockados. (2) Um pequeno conjunto de testes de integração com banco em memória ou container (ex.: auth + um fluxo de venue). (3) Remover `it.skip` e garantir que os 2 specs passem.
- **Pirâmide sugerida:** Base: unitários em use cases e em `handleErrors`; meio: integração em rotas críticas (auth, venue, proposal); topo: poucos e2e para fluxo principal (registro → login → criar proposta).

---

## 13. Dívidas técnicas priorizadas

### Crítico (precisa corrigir já)

| Problema | Onde | Impacto | Sugestão |
|----------|------|--------|----------|
| Rotas sensíveis sem autenticação | `router/image.ts`, `router/document.ts`, `router/payment.ts`, `router/text.ts`, `router/emailConfig.ts`, entre outros | Acesso não autorizado a dados e uploads | Aplicar `ensureAuthenticate` (ou middleware de autorização) em todas as rotas que alteram dados ou retornam dados restritos |
| CORS `origin: "*"` | `src/server.ts` | Permite qualquer origem; risco com credenciais | Restringir `origin` a domínios conhecidos (env) |
| `req.userId` não definido após auth | `src/middleware/ensureAuthenticate.ts` | Impossível autorizar por recurso no servidor | Decodificar JWT no middleware e setar `req.userId` (e opcionalmente renovar sessão/refresh como no código comentado) |
| Async sem tratamento global | `server.ts` não importa `express-async-errors`; sem middleware de erro 4 params | Rejeições não tratadas podem resultar em 500 sem resposta controlada | Importar `express-async-errors` no topo de `server.ts` e adicionar middleware de erro global que chame `handleErrors` e responda com JSON |
| Resposta 500 expõe detalhes | `src/errors/error-handler.ts` (último return) | `error.toString()` pode vazar stack ou dados internos | Em produção retornar mensagem genérica e logar o erro completo apenas no servidor |

### Importante (próximas sprints)

| Problema | Onde | Impacto | Sugestão |
|----------|------|--------|----------|
| Listas sem paginação | Repositórios em `repositories/in-prisma/` (list de venue, proposal, user, organization, etc.) | Performance e uso de memória com muitos registros | Adicionar parâmetros `page`/`limit` ou `cursor`/`take` e usar `skip`/`take` no Prisma |
| Duplicação de `express.json()` e ordem do body limit | `src/server.ts` linhas 42–45 | Comportamento confuso e possível conflito | Um único `express.json({ limit: "..." })` e um único `urlencoded(...)` com limite definido |
| Falta de transação em fluxos com múltiplas escritas | Use cases de proposal, payment, dateEvent | Inconsistência em falha parcial | Usar `prisma.$transaction` nos fluxos que criam/atualizam várias entidades (ex.: proposta + pessoas + dateEvents) |
| Lógica de S3/Sharp nos controllers | `controller-create-image.ts`, `controller-update-image.ts`, etc. | Acoplamento e difícil teste | Extrair serviço de upload (ex.: `ImageStorageService`) e injetar nos controllers |
| Sem `.env.example` | Raiz do projeto / art56_server_v3 | Onboarding e deploy sem lista de variáveis | Criar `.env.example` com todas as chaves necessárias (sem valores sensíveis) |

### Melhorias (quando der)

| Problema | Onde | Impacto | Sugestão |
|----------|------|--------|----------|
| Logging com `console.log` | Vários controllers e use cases | Ruim para produção e correlação | Introduzir logger (pino/winston) e remover logs de debug em produção |
| Typo/nome errado em comentário e rota comentada | `src/router/seasonal-fee.ts` (`seasonalfeeRoutes`), `src/router/dateEvent.ts` (getTextById/getTextByArea) | Confusão e rotas getById/getByArea de dateEvent não expostas | Corrigir nome e, se desejado, expor getById/getByArea de dateEvent com factories corretas |
| Arquivo duplicado | `zod/services/list-service-by-venue-param-schema copy.ts` | Poluição e dúvida de qual usar | Remover cópia e usar um único schema |
| Sem rate limit | Aplicação inteira | Risco de abuso e DoS | Adicionar rate limit por IP ou por token (ex.: express-rate-limit) nas rotas de auth e nas públicas |
| Body limit 50mb | `server.ts` | DoS por payload grande | Reduzir para valor adequado (ex.: 10mb) e tratar uploads grandes via multipart com tamanho máximo por campo |

---

## 14. Próximos passos sugeridos (plano de 2 semanas)

- **Semana 1**
  - **Dia 1–2:** (1) Importar `express-async-errors` e adicionar middleware global de erro; (2) Ajustar `handleErrors` para não vazar detalhes no 500 em produção; (3) Decodificar JWT em `ensureAuthenticate` e setar `req.userId` (e tipar `Request` com `userId`).
  - **Dia 3:** Aplicar `ensureAuthenticate` nas rotas que hoje estão desprotegidas (image, document, payment, text, emailConfig, proposal create/byId, etc.) e testar fluxos principais.
  - **Dia 4:** Configurar CORS a partir de variável de ambiente (lista de origens) e criar `.env.example` com DATABASE_URL, JWT_SECRET_KEY, AWS_*, etc.
  - **Dia 5:** Corrigir `server.ts` (um único `express.json` com limit adequado, ex.: 10mb) e remover arquivo `list-service-by-venue-param-schema copy.ts`.

- **Semana 2**
  - **Dia 1–2:** Introduzir paginação nas listagens mais usadas (venue, proposal, user, organization) — parâmetros `page` e `limit` e uso de `skip`/`take` no Prisma.
  - **Dia 3:** Envolver criação de proposta (e fluxos relacionados que fazem várias escritas) em `prisma.$transaction`.
  - **Dia 4:** Escrever testes unitários para 2–3 use cases críticos (ex.: authenticate-user, create-venue) com mocks de repositório; garantir que os specs existentes passem e remover `it.skip`.
  - **Dia 5:** Revisão de segurança (listar endpoints ainda públicos por decisão) e documentar em README ou em `/docs`; opcionalmente adicionar rate limit em `/auth` e `/token`.

---

## Ajustes recentes

- **Router `dateEvent`:** Handlers que chamam controllers autenticados passam `req` com asserção para `AuthenticatedRequest` (`req as AuthenticatedRequest` ou `req as unknown as AuthenticatedRequest` na rota delete), eliminando erros TS2345 e alinhando a tipagem ao middleware `ensureAuthenticate`.
- **`google-calendar-service.ts`:** Removido o import de `OAuth2Client` de `google-auth-library` e passou a usar o tipo do próprio `googleapis` (`InstanceType<typeof google.auth.OAuth2>`), eliminando conflito entre duas instalações de `google-auth-library` (TS2741/TS2769) e permitindo que o backend compile e suba; necessário para o endpoint `/auth/register/google` e para a integração Google Calendar.
- **Servidor local:** Criado `src/dev-server.ts`, que importa o `app` de `server.ts` e chama `app.listen(PORT)`. O script `yarn dev` passou a usar `dev-server.ts`; a porta é `process.env.PORT` ou 3000, e o terminal exibe "Servidor rodando em http://localhost:3000" (ou a porta configurada). O `server.ts` continua apenas exportando o app para o Vercel.
- **Router `integrations-google-calendar.ts`:** Handlers que faziam `return res.xxx()` passaram a usar `return void res.xxx()` para que o tipo de retorno seja `void | Promise<void>`, eliminando erros TS2769 (RequestHandler espera void, não Response).

---

## Resumo do que foi encontrado

- Backend em **Express + TypeScript + Prisma (MySQL)** na pasta **`art56_server_v3/`**, deploy configurado para **Vercel**; padrão em camadas (router → controller → use case → repository) com **Zod** para validação.
- **Autenticação** por JWT no middleware `ensureAuthenticate`; **`req.userId` não é preenchido** (código comentado) e **várias rotas sensíveis estão sem proteção** (image, document, payment, text, emailConfig, parte de proposal, etc.).
- **Segurança:** CORS `origin: "*"`, body limit 50mb, sem rate limit, sem `.env.example`; resposta 500 pode expor detalhes.
- **Erros:** Handler central `handleErrors` (Zod, Prisma, erros HTTP); **não há** middleware global de erro nem uso de `express-async-errors`, com risco de rejeições não tratadas.
- **Dados:** Uso de **transação** apenas no create de venue; listas **sem paginação**; integrações com **S3**, **Nodemailer**, **Firebase** e **Web Push** sem filas/retry.
- **Testes:** Apenas **2 specs** (session, refresh-token); Vitest configurado; sem testes de integração/e2e.
- **Qualidade:** Duplicação de `express.json()`, `console.log` em vários pontos, um arquivo Zod duplicado e comentários com typos/rotas erradas em seasonal-fee e dateEvent.
