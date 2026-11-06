# Contratos da API (EventHub / art56_server_v3)

Documentação gerada a partir do código em `art56_server_v3/src`: routers, controllers, middleware `ensureAuthenticate` e schemas Zod. Base URL das rotas conforme `server.ts`.

---

## Índice por recurso

- [Raiz](#get-)
- [Auth](#auth)
- [User](#user)
- [Token](#token)
- [Venue](#venue)
- [Organization](#organization)
- [Proposal](#proposal)
- [Person](#person)
- [Payment](#payment)
- [Service](#service)
- [Text](#text)
- [Image](#image)
- [Document](#document)
- [DateEvent](#dateevent)
- [Integrations Google Calendar](#integrations-google-calendar)
- [Contract](#contract)
- [Clause](#clause)
- [Attachment](#attachment)
- [Notification](#notification)
- [Schedule](#schedule)
- [Question](#question)
- [Owner](#owner)
- [Contact](#contact)
- [Expense](#expense)
- [SeasonalFee](#seasonalfee)
- [Goal](#goal)
- [Email](#email)
- [EmailConfig](#emailconfig)
- [UserOrganization](#userorganization)
- [UserVenuePermission](#uservenuepermission)
- [UserOrganizationPermission](#userorganizationpermission)
- [Padrões e inconsistências](#padrões-atuais-e-inconsistências)

---

## GET /

**Descrição:** Health check da API.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Headers:** não encontrado  

**Query Params:** não encontrado  

**Path Params:** não encontrado  

**Body (Request):** N/A  

**Response (Success):**  
status: 200  
`"API online!"` (text/plain)  

**Arquivos de referência:**  
backend: art56_server_v3/src/server.ts  

---

## Auth

Base path: `/auth`

### POST /auth/register

**Descrição:** Registro de novo usuário (email/senha).  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: application/json  

**Query Params:** não encontrado  

**Path Params:** não encontrado  

**Body (Request):**  
Schema Zod em `src/zod/user/create-user-params-schema.ts` (não validado neste controller por arquivo; validação pode estar no use case). Payload esperado tipicamente: email, username, password.  

```json
{}
```

**Response (Success):**  
status: 201 (inferido por padrão de criação)  
`{}`  

**Erros comuns:**  
400 — validação Zod  
409 — conflito (ex.: email já existe)  
500 — payload: `{ "title": "Server Error", "message": "..." }`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/auth.ts, art56_server_v3/src/use-cases/auth/register-user  

---

### POST /auth/register/google

**Descrição:** Registro/login com Google.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: application/json  

**Body (Request):**  
`{}` (payload exato não encontrado no repositório)  

**Response (Success):**  
status: 200/201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/auth.ts, art56_server_v3/src/use-cases/auth/register-google-user  

---

### POST /auth/authenticate

**Descrição:** Login (email/senha). Retorna token e dados do usuário.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: application/json  

**Body (Request):**  
Conforme Zod: `src/zod/auth/authenticate-user-params-schema.ts`  

```json
{
  "email": "string (obrigatório, email válido)",
  "password": "string (obrigatório)",
  "fcmToken": "string (opcional)"
}
```

**Response (Success):**  
status: 200  
Resposta direta (objeto com token e possivelmente user); formato exato no use case.  

**Erros comuns:**  
400 — validação (title: "Erro na validacao dos parametros da requisicao", message com detalhes Zod)  
401 — credenciais inválidas  
500 — payload: `{ "title": "Server Error", "message": "..." }`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/auth.ts, art56_server_v3/src/use-cases/auth/authenticate-user/controller-authenticate-user.ts  

---

### GET /auth/refresh

**Descrição:** Renovação de token (refresh).  
**Auth:** Nenhuma (usa cookie ou body conforme implementação).  
**Permissões:** não encontrado  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/auth.ts (chama refreshTokenFactory)  

---

### PUT /auth/reset-password

**Descrição:** Redefinição de senha (fluxo com token de reset).  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Body (Request):**  
`{}` (não encontrado no repositório)  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/auth.ts, art56_server_v3/src/use-cases/auth/reset-password  

---

### POST /auth/forgot-password

**Descrição:** Solicitação de “esqueci minha senha”.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Body (Request):**  
`{}` (não encontrado no repositório)  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/auth.ts, art56_server_v3/src/use-cases/auth/forgot-password  

---

### PUT /auth/update-password

**Descrição:** Atualização de senha do usuário autenticado.  
**Auth:** Bearer JWT (ensureAuthenticate)  
**Permissões:** não encontrado  

**Headers:**  
- Authorization: Bearer &lt;token&gt;  
- Content-Type: application/json  

**Body (Request):**  
`{}` (não encontrado no repositório)  

**Erros comuns:**  
401 — token ausente ou inválido; payload: `{ "title": "...", "message": "..." }` (handleErrors)  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/auth.ts, art56_server_v3/src/middleware/ensureAuthenticate.ts  

---

## User

Base path: `/user`

### PUT /user/update

**Descrição:** Atualização de dados do usuário (inclui avatar via upload).  
**Auth:** não encontrado (rota sem ensureAuthenticate no router).  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data (upload de arquivo)  

**Body (Request):**  
multipart com campo `file` (imagem). Demais campos conforme Zod em `src/zod/user/update-user-params-schema.ts`.  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/user.ts, art56_server_v3/src/use-cases/user/update  

---

### PUT /user/updatePassword

**Descrição:** Alteração de senha do usuário.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/user.ts, art56_server_v3/src/use-cases/user/update-password  

---

### POST /user/createNewUser

**Descrição:** Criação de novo usuário (admin ou público).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/user/create-user-params-schema.ts`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/user.ts, art56_server_v3/src/use-cases/user/create-new-user  

---

### GET /user/getById

**Descrição:** Busca usuário por ID.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- userId (tipo string, descrição não encontrada)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/user.ts, art56_server_v3/src/use-cases/user/get-by-id  

---

### GET /user/getByEmail

**Descrição:** Busca usuário por email.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- email (tipo string)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/user.ts, art56_server_v3/src/use-cases/user/get-by-email  

---

### DELETE /user/delete/:userId

**Descrição:** Exclusão de usuário por ID.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- userId (string, obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/user.ts, art56_server_v3/src/use-cases/user/delete-user  

---

### GET /user/list

**Descrição:** Listagem de usuários (filtros por organização/email).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- organizationId (opcional), email (opcional) — conforme Zod em `src/zod/user/list-user-query-schema.ts`  

**Response (Success):**  
status: 200  
`[]` ou array de usuários  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/user.ts, art56_server_v3/src/use-cases/user/list-user  

---

### PUT /user/fcm-token

**Descrição:** Atualização do FCM token (notificações push).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/user/update-fcm-token-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/user.ts, art56_server_v3/src/use-cases/user/update-fcm-token  

---

## Token

Base path: `/token`

### POST /token/refresh

**Descrição:** Refresh do access token.  
**Auth:** Nenhuma (token de refresh no body ou cookie).  
**Permissões:** não encontrado  

**Body (Request):**  
`{}` (payload exato não encontrado)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/token.ts, art56_server_v3/src/use-cases/token  

---

## Venue

Base path: `/venue`

### POST /venue/create

**Descrição:** Criação de venue (com upload de logo/arquivo).  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Headers:**  
- Authorization: Bearer &lt;token&gt;  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com campo `file`. Demais campos conforme Zod em `src/zod/venue/create-venue-request-schema.ts`.  

**Response (Success):**  
status: 201  
`{}`  

**Erros comuns:**  
401 — token ausente ou inválido  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/create-venue  

---

### GET /venue/list

**Descrição:** Listagem de venues por organização e nome.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Query Params:**  
- organizationId (string, obrigatório no schema Zod), name (string, opcional) — `src/zod/venue/list-venue-query-schema.ts`  

**Response (Success):**  
status: 200  
Array de venues (resposta direta, sem envelope).  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/list-venue  

---

### GET /venue/permittedVenueList

**Descrição:** Lista de venues permitidos para um usuário.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Query Params:**  
- organizationId (opcional), name (opcional)  
**Path Params:**  
- userId (opcional, na rota express)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/list-permitted-venues  

---

### GET /venue/trafficCount

**Descrição:** Contagem de tráfego por venue/ano/aprovação.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Query Params:**  
- venueId, year (opcional), approved (opcional) — conforme schema em `src/zod/venue/get-venue-traffic-count-params-schema.ts`  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/get-traffic-count-venue  

---

### GET /venue/analysisByMonth

**Descrição:** Análise por mês (venue, ano, aprovado).  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Query Params:**  
- venueId, year (opcional), approved (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/get-analysis-by-month-venue  

---

### GET /venue/getById

**Descrição:** Busca venue por ID (público ou com userId).  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Query Params:**  
- venueId (opcional), userId (opcional) — schema em `src/zod/venue/get-by-id-venue-param-schema.ts`  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/get-by-id-venue  

---

### GET /venue/getWebData/:venueId?

**Descrição:** Dados públicos do venue para site (landing).  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/webData/web  

---

### PUT /venue/update

**Descrição:** Atualização de venue (com upload de arquivo).  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Headers:**  
- Authorization: Bearer &lt;token&gt;  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`. Demais campos em `src/zod/venue/update-venue-params-schema.ts`.  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/update-venue  

---

### PUT /venue/update/payment-info

**Descrição:** Atualização de informações de pagamento do venue.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme `src/zod/venue/update-payment-info-venue-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/update-payment-info-venue  

---

### PUT /venue/update/info

**Descrição:** Atualização de informações gerais do venue.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme `src/zod/venue/update-info-venue-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/update-info-venue  

---

### DELETE /venue/delete/:venueId

**Descrição:** Exclusão de venue.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (string, obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/delete-venue  

---

### GET /venue/analytics/:venueId

**Descrição:** Analytics do venue.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (string, obrigatório)  

**Response (Success):**  
status: 200  
`data.proposalYears`: anos (wall-clock de `startDate`) em que o espaço tem pelo menos um orçamento, ordem crescente, sem repetir. A lista não depende do mês/ano filtrado.

**Arquivos de referência:**  
backend: art56_server_v3/src/router/venue.ts, art56_server_v3/src/use-cases/venue/get-venue-analytics  

---

## Organization

Base path: `/organization`

### POST /organization/create

**Descrição:** Criação de organização (com upload de logo).  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Headers:**  
- Authorization: Bearer &lt;token&gt;  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`. Demais campos não documentados no repositório.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/organization.ts, art56_server_v3/src/use-cases/organization/create-organization  

---

### GET /organization/list

**Descrição:** Listagem de organizações (userId, name).  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Query Params:**  
- userId (opcional), name (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/organization.ts, art56_server_v3/src/use-cases/organization/list-organization  

---

### GET /organization/getHubData

**Descrição:** Dados do hub por organização.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Query Params:**  
- organizationId (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/organization.ts, art56_server_v3/src/use-cases/webData/hub  

---

### GET /organization/getById

**Descrição:** Busca organização por ID.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Query Params:**  
- organizationId (opcional), venueName (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/organization.ts, art56_server_v3/src/use-cases/organization/get-organization-by-user-id  

---

### DELETE /organization/delete/:organizationId

**Descrição:** Exclusão de organização.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Path Params:**  
- organizationId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/organization.ts, art56_server_v3/src/use-cases/organization/delete-organization  

---

### GET /organization/getOrganizationWebData/:organizationId?

**Descrição:** Dados públicos da organização para site.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Path Params:**  
- organizationId (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/organization.ts, art56_server_v3/src/use-cases/webData/web-organization  

---

### PUT /organization/update

**Descrição:** Atualização de organização (com upload).  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Headers:**  
- Authorization: Bearer &lt;token&gt;  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/organization.ts, art56_server_v3/src/use-cases/organization/update-organization  

---

### PUT /organization/update-venue-organization-images

**Descrição:** Atualização de imagens venue/organização.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/organization.ts, art56_server_v3/src/use-cases/organization/update-venue-organization-images  

---

## Proposal

Base path: `/proposal`

### POST /proposal/createPerPerson

**Descrição:** Criação de proposta por pessoa.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Body (Request):**  
Campos conforme model Proposal (venueId, completeClientName, type, trafficSource, guestNumber, startDate, endDate, email, whatsapp, description, basePrice, etc.).  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/proposal.ts, art56_server_v3/src/use-cases/proposal/create-proposal-per-person  

---

### POST /proposal/createPerDay

**Descrição:** Criação de proposta por dia.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/proposal.ts, art56_server_v3/src/use-cases/proposal/create-proposal-per-day  

---

### GET /proposal/byId/:proposalId

**Descrição:** Busca proposta por ID.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Path Params:**  
- proposalId (obrigatório)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/proposal.ts, art56_server_v3/src/use-cases/proposal/get-proposal-by-id  

---

### PUT /proposal/updatePerPerson

**Descrição:** Atualização de proposta por pessoa.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/proposal.ts, art56_server_v3/src/use-cases/proposal/update-proposal-per-person  

---

### PUT /proposal/updatePersonalInfo

**Descrição:** Atualização de dados pessoais da proposta.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/proposal.ts, art56_server_v3/src/use-cases/proposal/update-proposal-personal-info  

---

### PUT /proposal/updatePerDay

**Descrição:** Atualização de proposta por dia.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/proposal.ts, art56_server_v3/src/use-cases/proposal/update-proposal-per-day  

---

### GET /proposal/list

**Descrição:** Listagem de propostas do espaço. Com `page`, devolve no máximo 10 linhas e o total do filtro. Sem `page`, devolve a lista inteira.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Query Params:**  
- `venueId` (obrigatório)
- `completeClientName` (opcional, até 80 caracteres; vazio é ignorado)
- `email`, `month` (1–12), `year`, `day` (1–31; exige `month`)
- `approved`: ausente = Aberto e Fechado; `true` = só Fechado; `false` = só Aberto
- `minAmount`: número ≥ 0. Ausente ou vazio não filtra. Presente exige `totalAmount` maior ou igual, na lista inteira e no total. Não numérico ou negativo responde 400
- `page`: inteiro ≥ 1. Ausente = lista inteira, sem `pagination`
- `sortBy`: `startDate` (padrão), `totalAmount` ou `status`
- `sortDir`: `asc` (padrão) ou `desc`. Empate desempata por `id`
- `pageSize` enviado pelo cliente é ignorado; o servidor usa 10
- `summary=true` exige `page` e devolve os KPIs. `total` e `conversionRate` (inteiro; 0 se não houver linha) seguem o filtro inteiro, inclusive busca, status e `minAmount`, não a página. `monthAmount` e `daily.amount` somam `totalAmount` só dos aprovados na janela de mês ou dia, e ignoram busca, status e `minAmount`. `amountMax` é o maior `totalAmount` dessa mesma janela, também ignorando esses filtros; 0 se não houver linha. `daily` traz um ponto por dia da janela, com zero nos dias vazios. `change.total`, `change.monthAmount` e `change.conversionRate` comparam cada número com a mesma janela um ano antes: o inteiro de `Math.round(((atual - anterior) / anterior) * 100)`, ou `null` quando o anterior é 0. A janela anterior repete mês e, se houver, o dia. Total e conversão repetem busca, status e `minAmount`; `monthAmount` repete só os aprovados. Sem mês, com dia inválido ou com 29 de fevereiro sem par, os três campos são `null` e não há segunda leitura

A data do evento é filtrada em wall-clock (componentes UTC). Dia inexistente no mês devolve lista vazia.

**Response (Success):**  
status: 200  
Cada item traz `approved` e `status` (`ABERTO` ou `FECHADO`).  
Com `page`: `pagination` `{ page, pageSize: 10, total, totalPages }`. `count` é o tamanho da página.

**Arquivos de referência:**  
backend: art56_server_v3/src/router/proposal.ts, art56_server_v3/src/use-cases/proposal/list-proposal  

---

### DELETE /proposal/delete/:proposalId

**Descrição:** Exclusão de proposta.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Path Params:**  
- proposalId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/proposal.ts, art56_server_v3/src/use-cases/proposal/delete-proposal  

---

## Person

Base path: `/person`

### POST /person/create

**Descrição:** Criação de pessoa (convidado/trabalhador) em proposta.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/person.ts  

---

### POST /person/createMany

**Descrição:** Criação em lote de pessoas.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/person.ts  

---

### GET /person/list

**Descrição:** Listagem de pessoas (proposalId, type, name).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- proposalId, type, name (opcionais)  

**Response (Success):**  
status: 200  
`[]`  

**Notas:** Duas rotas GET /person/list no mesmo router (uma chama listPersonFactory, outra listWebPersonFactory).  
**Arquivos de referência:**  
backend: art56_server_v3/src/router/person.ts  

---

### DELETE /person/delete/:personId

**Descrição:** Exclusão de pessoa.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- personId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/person.ts  

---

### PUT /person/update

**Descrição:** Atualização de pessoa.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/person.ts  

---

### PUT /person/getById/:personId

**Descrição:** Busca pessoa por ID (uso de PUT para get é inconsistente).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- personId (obrigatório)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/person.ts  

---

## Payment

Base path: `/payment`

### POST /payment/create

**Descrição:** Criação de pagamento (com upload de comprovante).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`. Campos: proposalId, venueId, amount, paymentDate, paymentMethod, etc.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/payment.ts  

---

### GET /payment/list

**Descrição:** Listagem de pagamentos (venueId, proposalId).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- venueId, proposalId (opcionais)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/payment.ts  

---

### DELETE /payment/delete/:paymentId

**Descrição:** Exclusão de pagamento.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- paymentId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/payment.ts  

---

### PUT /payment/update

**Descrição:** Atualização de pagamento (com upload).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/payment.ts  

---

## Service

Base path: `/service`

### POST /service/create

**Descrição:** Criação de serviço do venue.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/services/create-service-params-schema.ts`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/service.ts  

---

### GET /service/list/:venueId?/:name?

**Descrição:** Listagem de serviços por venue e nome.  
**Auth:** não encontrado (rota sem ensureAuthenticate).  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (opcional), name (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/service.ts  

---

### DELETE /service/delete/:serviceId

**Descrição:** Exclusão de serviço.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Path Params:**  
- serviceId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/service.ts  

---

### PUT /service/update

**Descrição:** Atualização de serviço.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/services/update-service-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/service.ts  

---

## Text

Base path: `/text`

### POST /text/create

**Descrição:** Criação de texto (venue ou área).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/text/create-text-params-schema.ts`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/text.ts  

---

### POST /text/create-text-organization

**Descrição:** Criação de texto de organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/text-organization/create-text-organization-params-schema.ts`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/text.ts  

---

### GET /text/list/:venueId?/:area?

**Descrição:** Listagem de textos por venue e área.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (opcional), area (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/text.ts  

---

### GET /text/list-text-organization/:organizationId?/:area?

**Descrição:** Listagem de textos da organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- organizationId (opcional), area (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/text.ts  

---

### DELETE /text/delete/:textId

**Descrição:** Exclusão de texto.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- textId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/text.ts  

---

### PUT /text/update

**Descrição:** Atualização de texto.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/text/update-text-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/text.ts  

---

### PUT /text/update-text-organization

**Descrição:** Atualização de texto da organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/text-organization/update-text-organization-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/text.ts  

---

### GET /text/getById/:textId

**Descrição:** Busca texto por ID.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- textId (obrigatório)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/text.ts  

---

### GET /text/getByArea/:area

**Descrição:** Busca texto por área.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- area (obrigatório)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/text.ts  

---

## Image

Base path: `/image`

### POST /image/upload

**Descrição:** Upload de imagem (venue).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com campo `file`. Demais campos no body (venueId, group, description, position, etc.).  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/image.ts, art56_server_v3/src/use-cases/image/create-image  

---

### POST /image/upload/image-organization

**Descrição:** Upload de imagem de organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/image.ts  

---

### GET /image/list

**Descrição:** Listagem de imagens por venue e descrição.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- venueId (opcional), description (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/image.ts  

---

### GET /image/organization/list

**Descrição:** Listagem de imagens da organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- organizationId (opcional), description (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/image.ts  

---

### DELETE /image/delete/:imageId

**Descrição:** Exclusão de imagem.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- imageId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/image.ts  

---

### GET /image/getByTag

**Descrição:** Busca imagens por tag (e venueId, responsiveMode).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- venueId (opcional), tag (opcional), responsiveMode (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/image.ts  

---

### GET /image/getByTag/image-organization

**Descrição:** Busca imagens da organização por tag.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- organizationId (opcional), tag (opcional), responsiveMode (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/image.ts  

---

### PUT /image/update

**Descrição:** Atualização de imagem (com upload).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/image.ts  

---

### PUT /image/organization/update

**Descrição:** Atualização de imagem da organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/image.ts  

---

## Document

Base path: `/document`

### POST /document/create

**Descrição:** Criação de documento (proposta/pagamento) com upload.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`. Campos: proposalId, paymentId (opcional), title, fileType, etc.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/document.ts  

---

### GET /document/list

**Descrição:** Listagem de documentos (proposalId, title).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- proposalId (opcional), title (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/document.ts  

---

### DELETE /document/delete/:documentId

**Descrição:** Exclusão de documento.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- documentId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/document.ts  

---

### PUT /document/update

**Descrição:** Atualização de documento (com upload).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/document.ts  

---

## DateEvent

Base path: `/dateEvent`

### POST /dateEvent/createSameDay

**Descrição:** Criação de evento no mesmo dia. Sync 1-way para Google Calendar se integração ativa e usuário com EDIT_VENUE_CALENDAR.  
**Auth:** ensureAuthenticate  
**Permissões:** Sync interno checa EDIT_VENUE_CALENDAR; rota exige apenas token válido  

**Body (Request):**  
Campos: venueId, title, startDate, endDate, type, proposalId (opcional), etc.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/dateEvent.ts  

---

### POST /dateEvent/createOvernigth

**Descrição:** Criação de evento pernoite. Sync 1-way para Google Calendar se integração ativa e usuário com EDIT_VENUE_CALENDAR.  
**Auth:** ensureAuthenticate  
**Permissões:** Sync interno checa EDIT_VENUE_CALENDAR; rota exige apenas token válido  

**Body (Request):**  
`{}`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/dateEvent.ts  

---

### POST /dateEvent/updateSameDay

**Descrição:** Atualização de evento mesmo dia. Sync para Google Calendar se aplicável.  
**Auth:** ensureAuthenticate  
**Permissões:** Sync interno checa EDIT_VENUE_CALENDAR  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/dateEvent.ts  

---

### POST /dateEvent/updateOverNight

**Descrição:** Atualização de evento pernoite. Sync para Google Calendar se aplicável.  
**Auth:** ensureAuthenticate  
**Permissões:** Sync interno checa EDIT_VENUE_CALENDAR  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/dateEvent.ts  

---

### GET /dateEvent/list/:venueId?/:proposalId?

**Descrição:** Listagem de eventos por venue e proposta.  
**Auth:** ensureAuthenticate  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (opcional), proposalId (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/dateEvent.ts  

---

### DELETE /dateEvent/delete/:dateEventId

**Descrição:** Exclusão de evento. Remove do Google Calendar se integração ativa e EDIT_VENUE_CALENDAR.  
**Auth:** ensureAuthenticate  
**Permissões:** Sync interno checa EDIT_VENUE_CALENDAR  

**Path Params:**  
- dateEventId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/dateEvent.ts  

---

## Integrations Google Calendar

Base path: `/integrations/google-calendar`

Todos os endpoints exigem **ensureAuthenticate**. Permissões: VIEW_VENUE_CALENDAR (leitura/status/calendários/connect-url), EDIT_VENUE_CALENDAR (select-calendar, disconnect). O parâmetro `organizationId` é obrigatório (query ou body) para resolução de permissão.

### GET /integrations/google-calendar/auto-status

**Descrição:** Retorna status da integração (conectado, necessidade de reconexão).  
**Auth:** ensureAuthenticate  
**Permissões:** VIEW_VENUE_CALENDAR (organizationId por query)

**Query Params:** organizationId (obrigatório)

**Response (Success):**  
status: 200  
`{ connected: boolean, needsGooglePermission?: boolean, calendarId?: string }`

**Arquivos de referência:**  
backend: art56_server_v3/src/router/integrations-google-calendar.ts  

---

### GET /integrations/google-calendar/connect-url

**Descrição:** Retorna URL de autorização OAuth para o frontend redirecionar o usuário.  
**Auth:** ensureAuthenticate  
**Permissões:** VIEW_VENUE_CALENDAR

**Query Params:** organizationId (obrigatório)

**Response (Success):**  
status: 200  
`{ redirectUrl: string }`

**Arquivos de referência:**  
backend: art56_server_v3/src/router/integrations-google-calendar.ts  

---

### GET /integrations/google-calendar/callback

**Descrição:** Callback OAuth (sem Bearer). Google redireciona com code e state. State é JWT com userId e organizationId.  
**Auth:** Nenhuma (rota pública por redirect)

**Query Params:** code, state (fornecidos pelo Google)

**Response:** Redirecionamento para FRONTEND_URL com ?google_calendar=connected|error e organizationId/message.

**Arquivos de referência:**  
backend: art56_server_v3/src/router/integrations-google-calendar.ts  

---

### GET /integrations/google-calendar/calendars

**Descrição:** Lista calendários do usuário no Google para seleção.  
**Auth:** ensureAuthenticate  
**Permissões:** VIEW_VENUE_CALENDAR

**Query Params:** organizationId (obrigatório)

**Response (Success):**  
status: 200  
Array de calendários (id, summary, etc.)

**Arquivos de referência:**  
backend: art56_server_v3/src/router/integrations-google-calendar.ts  

---

### POST /integrations/google-calendar/select-calendar

**Descrição:** Define o calendário Google onde os eventos serão sincronizados.  
**Auth:** ensureAuthenticate  
**Permissões:** EDIT_VENUE_CALENDAR

**Body (Request):**  
organizationId (string), calendarId (string)

**Response (Success):**  
status: 200  
`{}`

**Arquivos de referência:**  
backend: art56_server_v3/src/router/integrations-google-calendar.ts  

---

### POST /integrations/google-calendar/disconnect

**Descrição:** Remove/invalida a integração Google Calendar da organização.  
**Auth:** ensureAuthenticate  
**Permissões:** EDIT_VENUE_CALENDAR

**Body (Request):**  
organizationId (string)

**Response (Success):**  
status: 200  
`{}`

**Arquivos de referência:**  
backend: art56_server_v3/src/router/integrations-google-calendar.ts  

---

## Contract

Base path: `/contract`

**Ordenação:** o array `clauses` nas respostas de create, update, list e byId é ordenado por `position` ascendente (ordenação secundária por `createdAt`). Cláusulas com `position` nulo aparecem por último na API; o PDF aplica sort defensivo com o mesmo critério.

### POST /contract/create

**Descrição:** Criação de contrato.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
name, title, organizationId, venueIds/clauseIds conforme relação N:N no schema.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/contract.ts  

---

### GET /contract/list/:venueId?/:venueId?/:name?

**Descrição:** Listagem de contratos (path com dois venueId na rota).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (repetido), name (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/contract.ts  

---

### DELETE /contract/delete/:contractId

**Descrição:** Exclusão de contrato.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- contractId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/contract.ts  

---

### PUT /contract/update

**Descrição:** Atualização de contrato.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`contractId`, `name`, `title`, `venueIds[]`, `clauses[]` com `{ text, title, position, id? }`.

**Cláusulas no update:** incluir `id` da cláusula **vinculada ao contrato** para atualizar posição/texto sem recriar registro; omitir `id` para cláusulas novas (backend cria cópia e associa). Cláusulas ausentes no array são desconectadas do contrato.

**Response (Success):**  
status: 200  
Contrato com `clauses` ordenadas por `position` ascendente.

**Arquivos de referência:**  
backend: art56_server_v3/src/router/contract.ts, art56_server_v3/src/zod/contract/update-contract-params-schema.ts  

---

### GET /contract/getById/:contractId

**Descrição:** Busca contrato por ID.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- contractId (obrigatório)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/contract.ts  

---

## Clause

Base path: `/clause`

### POST /clause/create

**Descrição:** Criação de cláusula.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
text, title, position, organizationId (opcional).  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/clause.ts  

---

### GET /clause/list

**Descrição:** Listagem de cláusulas por organização e título.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- organizationId (opcional), title (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/clause.ts  

---

### DELETE /clause/delete/:clauseId

**Descrição:** Exclusão de cláusula.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- clauseId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/clause.ts  

---

### PUT /clause/update

**Descrição:** Atualização de cláusula.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/clause.ts  

---

## Attachment

Base path: `/attachment`

Todas as rotas de attachment usam `attachmentRoutes.use(ensureAuthenticate)`.

### POST /attachment/create

**Descrição:** Criação de anexo.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
text, title, organizationId (opcional), venueId (opcional).  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/attachment.ts  

---

### GET /attachment/list/:venueId?/:name?

**Descrição:** Listagem de anexos.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (opcional), name (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/attachment.ts  

---

### DELETE /attachment/delete/:attachmentId

**Descrição:** Exclusão de anexo.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Path Params:**  
- attachmentId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/attachment.ts  

---

### PUT /attachment/update

**Descrição:** Atualização de anexo.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/attachment.ts  

---

## Notification

Base path: `/notification`

### GET /notification/list/:venueId

**Descrição:** Listagem de notificações do venue. Com `page`, devolve 10 linhas e `pagination`. Com `summary=true` (só junto de `page`), devolve os quatro counts do mesmo filtro, sem recortar pela página. Sem `page`, devolve no máximo 25 linhas, sem `pagination` e sem `summary`.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (obrigatório)  

**Query Params:**  
- page (opcional, inteiro >= 1). Ausente = teto de 25  
- summary (`true` ou `false`). `true` sem `page` responde 400  
- q (opcional, até 80). Casa `content`  
- type (opcional): `VISIT`, `EVENT`, `OTHER`, `BARTER`, `PROPOSAL`, `OVERNIGHT`, `PRODUCTION`  
- isRead (opcional): `true` ou `false`  
- pageSize enviado pelo cliente é ignorado. O servidor usa 10  

**Response (Success):**  
status: 200  

```json
{
  "data": {
    "notificationList": [],
    "summary": { "unread": 0, "last7Days": 0, "last30Days": 0, "newProposals": 0 }
  },
  "count": 0,
  "pagination": { "page": 1, "pageSize": 10, "total": 0, "totalPages": 0 }
}
```

`summary` só vem com `summary=true`. `pagination` só vem com `page`. `count` é o tamanho da página. `unread` é `isRead` falso no filtro (`isRead=true` zera). `last7Days` e `last30Days` usam `createdAt` contra o instante do servidor menos 7 ou 30 dias de 24 horas. `newProposals` é `PROPOSAL` nessa janela de 30 dias. Ordem: `createdAt` descendente, `id` descendente.

**Arquivos de referência:**  
backend: art56_server_v3/src/router/notification.ts  
backend: art56_server_v3/src/use-cases/notification/list-notification/use-case-list-notification.ts  

### PATCH /notification/read-by-proposal/:proposalId

**Descrição:** Marca como lidas as notificações não lidas daquele orçamento, no espaço do orçamento.  
**Auth:** `ensureAuthenticate`  
**Permissões:** qualquer `UserVenuePermission` do usuário naquele espaço  

**Path Params:**  
- proposalId (obrigatório)  

**Response (Success):**  
status: 200  
`{ "data": { "updated": 0 } }`  

**Response (Error):**  
- 401 sem token  
- 403 sem permissão no espaço, nenhuma linha muda  
- 404 orçamento ou espaço ausente  

Zero linhas atualizadas é sucesso. Repetir a chamada não altera linha já lida. `GET /proposal/byId/:proposalId` não grava `isRead`.

**Arquivos de referência:**  
backend: art56_server_v3/src/use-cases/notification/read-by-proposal/use-case-read-by-proposal.ts  

### PATCH /notification/read-all/:venueId

**Descrição:** Marca como lidas todas as notificações não lidas do espaço. Ignora página, busca e filtro.  
**Auth:** `ensureAuthenticate`  
**Permissões:** qualquer `UserVenuePermission` do usuário naquele espaço  

**Path Params:**  
- venueId (obrigatório)  

**Response (Success):**  
status: 200  
`{ "data": { "updated": 0 } }`  

**Response (Error):**  
- 401 sem token  
- 403 sem permissão no espaço, nenhuma linha muda  
- 404 espaço ausente  

Zero linhas atualizadas é sucesso.

**Arquivos de referência:**  
backend: art56_server_v3/src/use-cases/notification/read-all/use-case-read-all.ts  

---

## Schedule

Base path: `/schedule`

### POST /schedule/create

**Descrição:** Criação de escala/cronograma.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
name, workerNumber, description, startHour, endHour, proposalId.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/schedule.ts  

---

### GET /schedule/list

**Descrição:** Listagem de escalas (proposalId, name).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- proposalId (opcional), name (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/schedule.ts  

---

### DELETE /schedule/delete/:scheduleId

**Descrição:** Exclusão de escala.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- scheduleId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/schedule.ts  

---

### PUT /schedule/update

**Descrição:** Atualização de escala.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/schedule.ts  

---

### GET /schedule/getById/:scheduleId

**Descrição:** Busca escala por ID.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- scheduleId (obrigatório)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/schedule.ts  

---

## Question

Base path: `/question`

### POST /question/create

**Descrição:** Criação de pergunta (FAQ).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
question, response, venueId.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/question.ts  

---

### GET /question/list/:venueId?/:question?

**Descrição:** Listagem de perguntas.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (opcional), question (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/question.ts  

---

### DELETE /question/delete/:questionId

**Descrição:** Exclusão de pergunta.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- questionId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/question.ts  

---

### PUT /question/update

**Descrição:** Atualização de pergunta.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/question.ts  

---

### GET /question/getById/:questionId

**Descrição:** Busca pergunta por ID.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- questionId (obrigatório)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/question.ts  

---

### GET /question/getByArea/:area

**Descrição:** Busca pergunta por área.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- area (obrigatório)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/question.ts  

---

## Owner

Base path: `/owner`

### POST /owner/createOrganizationOwner

**Descrição:** Criação de dono da organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
completeName, cpf, pix, endereço, banco, organizationId, etc.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/owner.ts  

---

### POST /owner/createVenueOwner

**Descrição:** Criação de dono do venue.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/owner.ts  

---

### GET /owner/listByOrganization/:organizationId?/:venueName?

**Descrição:** Listagem de donos por organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- organizationId (opcional), venueName (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/owner.ts  

---

### GET /owner/listByVenue/:organizationId?/:venueId?/:venueName?

**Descrição:** Listagem de donos por venue.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- organizationId (opcional), venueId (opcional), venueName (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/owner.ts  

---

### PUT /owner/update

**Descrição:** Atualização de dono.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/owner.ts  

---

### DELETE /owner/delete/:ownerId

**Descrição:** Exclusão de dono.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- ownerId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/owner.ts  

---

## Contact

Base path: `/contact`

### POST /contact/create

**Descrição:** Criação de contato do venue.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
name, role, whatsapp, venueId, email, type (TEAM_MEMBER | SUPPLIER), etc.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/contact.ts  

---

### GET /contact/list

**Descrição:** Listagem de contatos do espaço. Sem `page`, devolve a lista inteira, sem `pagination` e sem `summary`. Com `page`, devolve no máximo 10 e o total do filtro.  
**Auth:** não encontrado (a rota não usa `ensureAuthenticate`)  
**Permissões:** não encontrado  

**Query:**  
- `venueId` (obrigatório)  
- `name` (opcional): trecho do nome  
- `type` (opcional): `SUPPLIER` ou `TEAM_MEMBER`  
- `q` (opcional): até 80 caracteres; casa nome, função, WhatsApp ou e-mail  
- `category` (opcional): enum de categoria do parceiro; `OUTROS` não inclui categoria nula  
- `page` (opcional): inteiro >= 1. O tamanho da página é 10 no servidor  
- `summary` (opcional): `true` exige `page` e devolve os cards do filtro inteiro; sem `page` responde 400  

**Response (Success):**  
status: 200  
`{ data: { contactList, summary? }, count, pagination?: { page, pageSize: 10, total, totalPages }, type: "List" }`  

`summary`, quando pedido: `{ total, withLogo, withDescription }`. Logo e descrição só entram se tiverem texto depois do trim. `count` é o tamanho da página, não o total.  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/contact.ts  

---

### DELETE /contact/delete/:contactId

**Descrição:** Exclusão de contato.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- contactId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/contact.ts  

---

### PUT /contact/update

**Descrição:** Atualização de contato.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/contact.ts  

---

## Expense

Base path: `/expense`

### POST /expense/create

**Descrição:** Criação de despesa.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
name, amount, type, category, recurring, venueId, paymentDate (opcional), description (opcional).  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/expense.ts  

---

### GET /expense/list

**Descrição:** Listagem de despesas por venue.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path/Query conforme router (venueId, etc.).**  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/expense.ts  

---

### DELETE /expense/delete/:expenseId

**Descrição:** Exclusão de despesa.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- expenseId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/expense.ts  

---

### PUT /expense/update

**Descrição:** Atualização de despesa.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/expense.ts  

---

## SeasonalFee

Base path: `/seasonalFee`

### POST /seasonalFee/create

**Descrição:** Criação de taxa sazonal.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/seasonalFee/create-seasonal-fee-params-schema.ts` (type, title, fee, venueId, startDay, endDay, affectedDays).  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/seasonal-fee.ts  

---

### GET /seasonalFee/list/:venueId?/:title?

**Descrição:** Listagem de taxas sazonais.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (opcional), title (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/seasonal-fee.ts  

---

### DELETE /seasonalFee/delete/:seasonalFeeId

**Descrição:** Exclusão de taxa sazonal.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- seasonalFeeId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/seasonal-fee.ts  

---

### PUT /seasonalFee/update

**Descrição:** Atualização de taxa sazonal.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/seasonalFee/update-seasonal-fee-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/seasonal-fee.ts  

---

## Goal

Base path: `/goal`

Todas as rotas usam `goalRoutes.use(ensureAuthenticate)`.

### POST /goal/create

**Descrição:** Criação de meta (venue).  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
minValue, maxValue (opcional), increasePercent, months, venueId.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/goal.ts  

---

### GET /goal/list/:venueId?/:minValue?

**Descrição:** Listagem de metas.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (opcional), minValue (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/goal.ts  

---

### DELETE /goal/delete/:goalId

**Descrição:** Exclusão de meta.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Path Params:**  
- goalId (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/goal.ts  

---

### PUT /goal/update

**Descrição:** Atualização de meta.  
**Auth:** Bearer JWT  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/goal.ts  

---

## Email

Base path: `/email`

### POST /email/contract

**Descrição:** Envio de contrato por e-mail.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Body (Request):**  
Payload com dados do contrato e destinatário (não encontrado no repositório).  

**Response (Success):**  
status: 200  
`{ "message": "E-mail enviado com sucesso" }`  

**Erros comuns:**  
400 — `{ "message": "Erro ao enviar e-mail", "error": "..." }`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/email.ts, art56_server_v3/src/use-cases/email/send-contratct-to-email-case  

---

### POST /email/proposal

**Descrição:** Envio de proposta por e-mail.  
**Auth:** Nenhuma  
**Permissões:** não encontrado  

**Body (Request):**  
`{}`  

**Response (Success):**  
status: 200  
`{ "message": "E-mail enviado com sucesso" }`  

**Erros comuns:**  
400 — `{ "message": "Erro ao enviar e-mail", "error": "..." }`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/email.ts, art56_server_v3/src/use-cases/email/send-proposal-to-email  

---

## EmailConfig

Base path: `/emailConfig`

### POST /emailConfig/create

**Descrição:** Criação de configuração de e-mail do venue (com upload).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`. Campos: venueId, type, title, message, etc.  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/email-config.ts  

---

### GET /emailConfig/list/:venueId

**Descrição:** Listagem de configurações de e-mail do venue.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (obrigatório)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/email-config.ts  

---

### GET /emailConfig/getByType/:venueId?/:type?

**Descrição:** Busca configuração por tipo.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- venueId (opcional), type (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/email-config.ts  

---

### DELETE /emailConfig/delete/:id

**Descrição:** Exclusão de configuração de e-mail.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- id (obrigatório)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/email-config.ts  

---

### PUT /emailConfig/update

**Descrição:** Atualização de configuração de e-mail (com upload).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Headers:**  
- Content-Type: multipart/form-data  

**Body (Request):**  
multipart com `file`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/email-config.ts  

---

## UserOrganization

Base path: `/userOrganization`

### GET /userOrganization/list

**Descrição:** Listagem de vínculos usuário-organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- userId (opcional), username (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userOrganization.ts  

---

### POST /userOrganization/create

**Descrição:** Criação de vínculo usuário-organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/user-organization/create-user-organization-params-schema.ts`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userOrganization.ts  

---

### PUT /userOrganization/update

**Descrição:** Atualização de vínculo.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/user-organization/update-user-organization-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userOrganization.ts  

---

### GET /userOrganization/byOrganizationlist/:organizationId?/:username?

**Descrição:** Listagem por organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- organizationId (opcional), username (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userOrganization.ts  

---

### GET /userOrganization/getById/:organizationId?

**Descrição:** Busca vínculo por organização (ou por ID).  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- organizationId (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userOrganization.ts  

---

### DELETE /userOrganization/delete/:userOrganizationId?

**Descrição:** Exclusão de vínculo.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- userOrganizationId (opcional)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userOrganization.ts  

---

## UserVenuePermission

Base path: `/userVenuePermission`

### GET /userVenuePermission/list

**Descrição:** Listagem de permissões usuário-venue.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- userVenuePermissionId (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userVenuePermission.ts  

---

### GET /userVenuePermission/get

**Descrição:** Busca permissão por venue/organization/user.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- venueId (opcional), organizationId (opcional), userId (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userVenuePermission.ts  

---

### POST /userVenuePermission/create

**Descrição:** Criação de permissão usuário-venue.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/user-venue-permission/create-user-venue-permission-params-schema.ts`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userVenuePermission.ts  

---

### PUT /userVenuePermission/update

**Descrição:** Atualização de permissão.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/user-venue-permission/update-user-venue-permission-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userVenuePermission.ts  

---

### DELETE /userVenuePermission/delete/:userVenuePermissionId?

**Descrição:** Exclusão de permissão.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- userVenuePermissionId (opcional)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/userVenuePermission.ts  

---

## UserOrganizationPermission

Base path: `/userOrganizationPermission`

### GET /userOrganizationPermission/list

**Descrição:** Listagem de permissões de organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- userOrganizationPermissionId (opcional)  

**Response (Success):**  
status: 200  
`[]`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/useOrganizationPermission.ts  

---

### GET /userOrganizationPermission/byId

**Descrição:** Busca permissão por organização/usuário.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Query Params:**  
- organizationId (opcional), userId (opcional)  

**Response (Success):**  
status: 200  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/useOrganizationPermission.ts  

---

### POST /userOrganizationPermission/create

**Descrição:** Criação de permissão de organização.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/user-organization-permission/create-user-organization-permission-params-schema.ts`  

**Response (Success):**  
status: 201  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/useOrganizationPermission.ts  

---

### PUT /userOrganizationPermission/update

**Descrição:** Atualização de permissão.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Body (Request):**  
Conforme Zod: `src/zod/user-organization-permission/update-user-organization-permission-params-schema.ts`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/useOrganizationPermission.ts  

---

### DELETE /userOrganizationPermission/delete/:userOrganizationPermissionId?

**Descrição:** Exclusão de permissão.  
**Auth:** não encontrado  
**Permissões:** não encontrado  

**Path Params:**  
- userOrganizationPermissionId (opcional)  

**Response (Success):**  
status: 200 ou 204  
`{}`  

**Arquivos de referência:**  
backend: art56_server_v3/src/router/useOrganizationPermission.ts  

---

## Padrões atuais e inconsistências

### Formato de resposta
- **Sucesso:** Resposta direta (objeto ou array), sem envelope. Ex.: `resp.status(200).json(response)` ou `resp.json(token)`.
- **Exceção:** Alguns endpoints de e-mail retornam `{ "message": "..." }`; a maioria dos erros usa o formato do `handleErrors`: `{ "title": "<NomeDoErro>", "message": "..." }`.

### Padrão de erro
- **400:** Validação Zod — `title: "Erro na validacao dos parametros da requisicao"`, `message` com detalhes concatenados.
- **401:** Token ausente ou inválido — retornado pelo middleware `ensureAuthenticate`; body com `title` e `message`.
- **404:** Recurso não encontrado (ex.: HttpResourceNotFoundError).
- **409:** Conflito (ex.: Prisma P2002 — unique constraint); body com `message: "ja existe"`.
- **500:** Erro genérico — `title: "Server Error"`, `message: error.toString()`.
- Não há padrão único para 403 (forbidden por role); não encontrado no código.

### Paginação
- **Não encontrado** padrão de paginação (offset/cursor) nos routers. Listagens retornam array completo; filtros via query ou path params (ex.: venueId, organizationId, name, month, year).

### Naming
- **URLs:** camelCase (ex.: `getById`, `permittedVenueList`, `createPerPerson`).
- **Body/JSON:** Uso de camelCase nos schemas Zod e no Prisma (client).
- **Banco:** Prisma usa `@@map` em várias tabelas para snake_case (ex.: `refresh_token`, `userOrganization`).

### Datas e timezone
- Prisma usa `DateTime`; não foi encontrada definição explícita de timezone (ISO 8601 ou UTC) nos contratos.

### Money (valores monetários)
- Model usa `Float` para `basePrice`, `totalAmount`, `amount`, etc. Não há convenção explícita de inteiro (centavos) vs decimal vs string no código documentado.

### Auth
- **Bearer JWT** via header `Authorization: Bearer <token>` no middleware `ensureAuthenticate`.
- Rotas protegidas: venue (create, list, update, delete, analytics, permittedVenueList, trafficCount, analysisByMonth), organization (create, list, getById, delete, update, update-venue-organization-images), proposal (updatePerPerson, updatePerDay, list, delete), service (create, delete, update), goal (todas), attachment (todas).
- Inconsistência: várias rotas sensíveis (user, payment, person, proposal create, etc.) **não** usam `ensureAuthenticate`.

---

## Sugestão de padronização mínima (sem quebrar produção)

1. **Envelope de erro único:** Manter `{ "title", "message" }` para todos os erros (4xx/5xx) e documentar; opcionalmente adicionar `code` numérico ou string para o cliente tratar.
2. **Auth em rotas sensíveis:** Estender `ensureAuthenticate` de forma incremental a rotas que alteram dados (user/update, user/delete, payment, proposal/create, person, document, etc.) ou documentar claramente quais são públicas por design.
3. **Paginação:** Para listas que podem crescer (proposals, payments, notifications), adicionar query params opcionais `limit` e `offset` (ou `page`/`pageSize`) e retornar metadados apenas quando solicitados (ex.: `?paginate=true`).
4. **Datas em ISO 8601:** Garantir que todos os `DateTime` retornados em JSON estejam em UTC com sufixo `Z` ou timezone explícito, e documentar na API.
5. **GET vs PUT para leitura:** Trocar `PUT /person/getById/:personId` para `GET /person/getById/:personId` (ou `GET /person/:personId`) em próxima versão; manter PUT temporariamente com deprecation.
6. **Roteamento de list:** Unificar convenção de filtros em query params (ex.: sempre `?venueId=...&name=...`) em vez de misturar path opcional e query, para facilitar documentação e clientes.
7. **Money:** Definir e documentar convenção (ex.: valores em reais com 2 decimais ou inteiros em centavos) e aplicar de forma consistente em novos endpoints; migração de existentes apenas se necessário.

---

*Documento gerado a partir do código em art56_server_v3. Última varredura: routers, middleware ensureAuthenticate, error-handler, schemas Zod referenciados.*
