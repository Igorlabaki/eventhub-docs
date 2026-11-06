# Setup de produção e ambiente — EventHub

**Objetivo:** Como rodar local (FE e BE), variáveis de ambiente (lista completa + exemplo `.env.example`), deploy atual (Vercel), aplicar migrations com segurança, checklist de smoke test pós-deploy e validação de S3/e-mail/Firebase.

**Fontes no repositório:** `art56_server_v3/package.json`, `art56_server_v3/vercel.json`, `art56_server_v3/src/server.ts`, `eventhub-vista-dashboard/package.json`, uso de `process.env` e `import.meta.env` no código (grep), [INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md](./INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md).

---

## 1. Rodar local

### Backend (`art56_server_v3/`)

- **Pré-requisitos:** Node.js, MySQL (ou banco acessível via `DATABASE_URL`).
- **Comandos:**
  - `npm install` (ou `yarn install`)
  - Configurar `.env` (ver seção 2).
  - `npx prisma generate`
  - `npm run dev` (ts-node-dev) — sobe o Express; **não há `app.listen` no repo** — para rodar local como servidor HTTP é necessário que o script `dev` ou outro chame `app.listen(port)`. **Não confirmado no repositório** se o `dev` já faz listen; em deploy Vercel o handler é o `app` exportado.
- **Observação:** Para Vercel, o handler é o default export de `src/server.ts`; localmente pode ser necessário um script que importe `app` e chame `app.listen()`.

### Frontend (`eventhub-vista-dashboard/`)

- **Comandos:**
  - `npm install` (ou `yarn install`)
  - Configurar `.env` com `VITE_API_URL` apontando para o BE (ex.: `http://localhost:3000`).
  - `npm run dev` — Vite dev server.
  - `npm run build` — build de produção; `npm run preview` — preview do build.

---

## 2. Variáveis de ambiente

### Backend (art56_server_v3)

| Variável | Onde é usada | Obrigatória |
|----------|--------------|-------------|
| `DATABASE_URL` | Prisma | Sim |
| `SHADOW_DATABASE_URL` | Prisma (migrations) | Sim (para migrate) |
| `JWT_SECRET_KEY` | ensureAuthenticate, refresh-token, access-token, use-case-refresh-token | Sim |
| `AWS_BUCKET_NAME` | Upload S3 (venue, organization, image, document, payment, emailConfig) | Sim (se usar upload) |
| `AWS_REGION` | S3, upload-config-sw | Sim (se usar S3) |
| `AWS_ACCESS_KEY_ID` | S3, upload-config-sw | Sim (se usar S3) |
| `AWS_SECRET_ACCESS_KEY` | S3, upload-config-sw | Sim (se usar S3) |
| `EMAIL_PASSWORD` | send-proposal-to-email, send-contract-to-email, send-attendence-confirmation | Se usar envio de e-mail |
| `EMAIL_GMAIL_PASSWORD` | send-forgot-password-email | Se usar forgot password |
| `FIREBASE_PROJECT_ID` | firebase-notification-service | Se usar Firebase |
| `FIREBASE_CLIENT_EMAIL` | firebase-notification-service | Se usar Firebase |
| `FIREBASE_PRIVATE_KEY` | firebase-notification-service | Se usar Firebase |
| `VAPID_PUBLIC_KEY` | web-push-service | Se usar Web Push |
| `VAPID_PRIVATE_KEY` | web-push-service | Se usar Web Push |
| `GOOGLE_CLIENT_ID` | integração Google Calendar (OAuth) | Se usar integração Google Calendar |
| `GOOGLE_CLIENT_SECRET` | integração Google Calendar (OAuth) | Se usar integração Google Calendar |
| `GOOGLE_REDIRECT_URI` | callback OAuth (ex.: `https://api.seudominio.com/integrations/google-calendar/callback`) | Se usar integração Google Calendar |
| `ENCRYPTION_KEY` | criptografia de tokens Google (AES-256-GCM; base64 32 bytes) | Se usar integração Google Calendar |
| `FRONTEND_URL` | redirecionamento pós-callback OAuth (ex.: `https://app.eventhub.com`) | Opcional; default localhost:5173 |
| `NODE_ENV` | prisma-client (singleton em dev) | Opcional |

**Não confirmado no repositório:** variáveis de host/smtp para Nodemailer além de pass; podem estar em código não varrido.

### Frontend (eventhub-vista-dashboard)

| Variável | Onde é usada | Obrigatória |
|----------|--------------|-------------|
| `VITE_API_URL` | lib/axios.ts (baseURL) | Sim |
| `VITE_GOOGLE_CLIENT_ID` | App.tsx (OAuth Google) | Se usar login Google |
| `VITE_VERCEL_PROJECT_ID` | analytics.service.ts | Opcional (analytics Vercel) |
| `VITE_VERCEL_API_TOKEN` | analytics.service.ts | Opcional (analytics Vercel) |

### Exemplo `.env.example` (nomes apenas, sem segredos)

**Backend (art56_server_v3/.env.example):**

```env
DATABASE_URL=
SHADOW_DATABASE_URL=
JWT_SECRET_KEY=
AWS_BUCKET_NAME=
AWS_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
EMAIL_PASSWORD=
EMAIL_GMAIL_PASSWORD=
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=
VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=
ENCRYPTION_KEY=
FRONTEND_URL=
NODE_ENV=development
```

**Frontend (eventhub-vista-dashboard/.env.example):**

```env
VITE_API_URL=
VITE_GOOGLE_CLIENT_ID=
VITE_VERCEL_PROJECT_ID=
VITE_VERCEL_API_TOKEN=
```

*(Criar esses arquivos no repositório se ainda não existirem.)*

---

## 3. Deploy atual

- **Backend:** Vercel. `vercel.json`: `builds` com `src/server.ts` e `@vercel/node`; `routes` redirecionam `/(.*)` para `src/server.ts`. A aplicação exporta o `app` Express como default; Vercel usa esse app como serverless function.
- **Frontend:** **Não confirmado no repositório** (pode ser Vercel, Netlify ou outro); configurar `VITE_API_URL` para a URL do BE em produção.
- **Banco:** MySQL gerenciado externamente; `DATABASE_URL` e `SHADOW_DATABASE_URL` configurados no painel da Vercel (ou secrets).

---

## 4. Aplicar migrations com segurança

- **Comando:** `npx prisma migrate deploy` (produção). Nunca usar `migrate dev` em produção.
- **Regras:** (1) Sempre backups antes de migrate. (2) Migrations aditivas (novas colunas nullable, novas tabelas) primeiro; alterações destrutivas (drop column, change type) em etapas com compatibilidade. (3) Testar em staging com cópia de dados. (4) Ver [MIGRATION_STRATEGY.md](./MIGRATION_STRATEGY.md).
- **Shadow database:** Prisma exige `SHADOW_DATABASE_URL` para gerar migrations; em produção o deploy da migration é feito com `migrate deploy` (não usa shadow no deploy).

---

## 5. Checklist de smoke test pós-deploy

- [ ] GET `/` → "API online!" (health).
- [ ] POST `/auth/authenticate` com credenciais válidas → 200 e `accessToken` + session.
- [ ] Request com `Authorization: Bearer <token>` → 200 em rota protegida (ex.: GET `/venue/list?organizationId=...`).
- [ ] Refresh: após expirar token, 401 e (quando FE usar POST `/token/refresh`) renovação e nova request com sucesso. *(Atualmente GET `/auth/refresh` pode falhar por incompatibilidade.)*
- [ ] Listar venues (ou permittedVenueList) e listar organizações.
- [ ] Upload de imagem (se S3 configurado) → 201 e URL retornada.
- [ ] Criar proposta (createPerPerson ou createPerDay) → 201.
- [ ] FE: login, navegação dashboard → organização → venue → proposta; abrir proposta e uma tela de pagamento/documento (se aplicável).

---

## 6. S3 / E-mail / Firebase — envs e como validar

| Integração | Envs | Como validar |
|------------|------|----------------|
| **S3** | AWS_BUCKET_NAME, AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY | Fazer upload de imagem (venue ou image/upload); checar URL retornada e objeto no bucket. |
| **E-mail** | EMAIL_PASSWORD ou EMAIL_GMAIL_PASSWORD (conforme use case) | Enviar proposta/contrato/confirmação ou forgot-password; checar caixa de entrada. |
| **Firebase** | FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY | Enviar notificação (fluxo que chama firebase-notification-service); checar dispositivo/console Firebase. |
| **Web Push** | VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY | Subscription e envio de notificação web push; checar no browser. |

---

## Decisões e recomendações

- Criar e manter `.env.example` em BE e FE com todas as variáveis listadas acima (sem valores sensíveis).
- Documentar na Vercel (ou onde for) quais envs são obrigatórias para o BE e o que cada uma controla.
- Smoke test deve ser executado após cada deploy em produção; considerar automação (ex.: script curl ou teste E2E mínimo).
