# Backend Map — EventHub

Repo `backend` em `art56_server_v3/`. Observado em 2026-11-10 no codigo da `main`. Endpoints um a um ficam em `project/api-endpoints.md`.

## Estrutura

| Caminho | Papel |
|---|---|
| `src/server.ts` | cria o app Express, middlewares globais e monta 33 routers; exportado para a Vercel |
| `src/dev-server.ts` | `app.listen(PORT || 3000)` para uso local |
| `src/router/` | 33 arquivos, um por prefixo HTTP |
| `src/use-cases/<dominio>/<caso>/` | trio `controller-*` + `factory-*` + `use-case-*`; 36 pastas de dominio |
| `src/repositories/interface/` | 35 interfaces `*-repository-interface.ts` |
| `src/repositories/in-prisma/` | 35 implementacoes `*-in-prisma-repository.ts` |
| `src/repositories/in-memory/` | refresh-token, session e user (testes) |
| `src/zod/` | 33 pastas, 211 schemas de entrada (alguns arquivos `* copy.ts` legados) |
| `src/functions/` | regras puras: preco, wall-clock, relatorios, storage de imagem |
| `src/services/` | prisma-client, S3/multer, criptografia, Google Calendar, e-mail de reset, web push |
| `src/middleware/` | `ensureAuthenticate.ts` (+ `readOptionalUserId`) e `ensurePermission.ts` |
| `src/errors/` | `error-handler.ts`, classes `Http*Error` e validador de params |
| `src/provider/` | geracao de access token, refresh token e sessao (JWT + dayjs) |
| `src/controllers/`, `src/factories/` | apenas email-config, fora do padrao trio |
| `src/types/` | `AuthenticatedRequest` e tipos de clausula |
| `src/scripts/generate-vapid-keys.ts` | gera chaves VAPID |
| `prisma/schema.prisma`, `prisma/migrations/` | schema MySQL e 19 migrations SQL |
| raiz | `vercel.json`, `vitest.config.ts`, `tsconfig.json`, `global.d.ts`, scripts soltos `test-duration.js` e `test-organization.js`, sobras `debug-upload-*.bin` e `yarn-error.log`, `package-lock.json` e `yarn.lock` juntos |

Nao existem `.github/`, Dockerfile, ESLint nem Prettier.

## Fluxo de uma requisicao

```text
router (prefixo + middleware de auth/upload)
  -> factory (instancia repositorios Prisma)
    -> controller (Zod parse de params/body, try/catch, handleErrors)
      -> use case (regra; authorizer por venue quando existe)
        -> repository interface -> implementacao Prisma
```

Excecoes: Google Calendar tem handlers no proprio router; email-config usa `controllers/` + `factories/`; alguns routers chamam `controller.handle` sem `await` (document, image, payment, user).

## Stack e scripts

- Node + Express `^4.21`, TypeScript `^5.6` (`target es2020`, `module commonjs`, `strict`), Prisma `^5.22`, Zod `^3.23`, Vitest `^2.1`.
- auth: `jsonwebtoken`, `bcryptjs`; datas: `date-fns`, `dayjs`, `moment`, `moment-timezone`; imagem: `sharp`; upload: `multer` + `multer-s3` + `@aws-sdk/lib-storage` (o `@aws-sdk/client-s3` chega so como transitiva).
- integracoes: `googleapis`, `nodemailer`, `web-push`.
- instaladas e nao usadas: `pdf-lib`, `canvas`, `@napi-rs/canvas`, `socket.io`, `socket.io-client`, `axios`, `jwt-decode`, `moment-timezone`, `express-async-errors` (nunca importado); `pdf2pic` importado com miniatura comentada.
- tipos e ferramentas de dev (`@types/*`, `ts-node-dev`, `vitest`) estao em `dependencies`.
- `package.json`: nome `meu-projeto`, `main: dist/app.js` inexistente, sem script `build`.

| Script | Comando |
|---|---|
| `dev` | `npx ts-node-dev src/dev-server.ts` |
| `test` / `test:watch` / `test:coverage` | `vitest` / `vitest --watch` / `vitest --coverage` |
| `vercel-build` | `prisma generate echo hello` (comando anomalo) |
| `generate-vapid` | `npx ts-node src/scripts/generate-vapid-keys.ts` |

## Configuracao (somente nomes)

- `.env.example`: `DATABASE_URL`, `SHADOW_DATABASE_URL`, `JWT_SECRET_KEY`, `AWS_BUCKET_NAME`, `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `EMAIL_PASSWORD`, `EMAIL_GMAIL_PASSWORD`, `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `NODE_ENV`, `CORS_ORIGIN`, `PORT`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_REDIRECT_URI`, `ENCRYPTION_KEY`.
- usada no codigo e ausente no exemplo: `FRONTEND_URL` (callback do Google e descricao de evento).
- presente no exemplo e ignorada: `CORS_ORIGIN`.
- o exemplo contem um valor com aparencia de credencial; tratar como incidente, nunca reproduzir.

## Bootstrap HTTP

1. `cors({ origin: "*", methods: [GET, POST, DELETE, "UPDATE", PUT, PATCH] })`;
2. `express.json()` sem limite (100 kb) seguido de `express.json({ limit: "50mb" })`: o primeiro vence, JSON acima de 100 kb recebe 413;
3. `express.urlencoded({ limit: "50mb" })`;
4. 33 routers; `GET /` responde `API online!`.

Ausentes: helmet, rate limit, logger HTTP, handler global de erro e 404 proprio, versionamento `/v1`.

## Autenticacao e autorizacao no codigo

- `ensureAuthenticate`: pega o segundo pedaco do header `Authorization`, `verify` com `JWT_SECRET_KEY`, exige `decoded.id` e grava `req.user.id`. Nao consulta Session nem revogacao (versao antiga comentada).
- `readOptionalUserId(req)`: devolve o user do token se houver; usado so na apresentacao publica da proposta para liberar reordenar/trocar fotos.
- `ensurePermission(perm)`: exige `organizationId` em query/body e passa se o usuario tiver a permissao em qualquer venue da organizacao; usado apenas no Google Calendar.
- authorizers por venue dentro de use cases: `venue-price-authorizer` (VIEW/EDIT_VENUE_PRICES), `venue-rule-authorizer`, `venue-amenity-authorizer`, `service-authorizer` (EDIT_VENUE_SERVICES), `proposal-quote-authorizer` (VIEW_VENUE_PROPOSALS ou EDIT_VENUE_INFO), `replace-proposal-indications` (SEND_PROPOSAL_INFO), `venue-site-edit-permission` (EDIT_VENUE_SITE).
- catalogo de permissoes: `topics/permissions-catalog.md`.

## Convencao de resposta

- sucesso: objeto direto, sem envelope;
- erro: `handleErrors` devolve `{ title, message }` com status do `Http*Error`; Zod 400; Prisma `P2002` 409 (`{ message: "ja existe" }`), `P2007` e validacao 400; qualquer outro 500 com `error.toString()` (vaza detalhe interno);
- email-config responde `{ message }`; `ensurePermission` tem mensagem fixa sobre calendario.

## Dominios de use case

| Dominio | Casos |
|---|---|
| auth | authenticate-user, forgot-password, register-google-user, register-user, reset-password |
| token / session | refresh-token; create-session, get-session-by-user-id |
| user | create-new-user, delete, get-by-email, get-by-id, list, update, update-password |
| organization | create, delete, get-organization-by-user-id, list, update, update-venue-organization-images |
| user-organization / -permission / user-venue-permission | CRUD de vinculo e permissoes |
| venue | create, delete, get-analysis-by-month, get-by-id, get-traffic-count, get-venue-analytics, list-permitted, list, update-info, update-payment-info, update |
| proposal | create-per-day, create-per-person, quote, update-per-day, update-per-person, update-personal-info, get-by-id, get-presentation, list, delete, choose-image, reorder-images, recalculate-public, update-public-services, list/replace-indications |
| data-event | create (mesmo dia), create-overnight, update-same-day, update-overnight, list, delete, get-by-id-venue |
| payment, document, person, schedule | CRUD (person tem create-many e web-list) |
| contract, clause, attachment | CRUD de contrato por organizacao |
| service, seasonal-fee, minimum-price-period, goal, expense | precificacao e financeiro (expense tem analysis) |
| venue-rule, venue-amenity | CRUD com authorizer; regra tem listagem publica |
| contact, question, text, text-organization, image, image-organization, email-config | conteudo, site e contatos |
| notification | create, delete, list, read-all, read-by-proposal |
| email | send-proposal, send-contract, send-attendance-confirmation |
| owner | CRUD de proprietarios (organizacao e venue) |
| webData | hub, web, web-organization (dados do site publico) |

## Helpers em `src/functions/`

- preco: `proposal-amounts` (nucleo atual), `quote-service-lines`, `resolve-minimum-price`, `adjust-proposal-unit-price` (versao antiga em horario local), `calc-custom-total-amount`, `calc-event-duration`, `calc-extra-hour-price`, `calc-extra-hours-qty`; legados `calc-base-price` (valores fixos), `calc-standart-total-amount`, `calc-price-per-day` (vazio);
- datas: `wall-clock-datetime`, `transform-date` (moment), `format-date`;
- relatorios: `monthly-average-by-years`, `same-month-revenue-by-year`, `yearly-change`, `report-year-range`, `proposal-years`, `event-category`;
- apresentacao publica: `to-proposal-presentation`, `plan-image-choice`, `plan-visible-image-positions`;
- storage: `service-image(-storage)` e `contact-logo(-storage)` (sharp -> webp 1200px q80, limite 5 MB, S3);
- outros: `people-within-guest-cap`, `capitalize`.

Regras de calculo detalhadas em `topics/pricing-and-proposal-calculation.md`; KPIs em `topics/reports-and-kpis.md`.

## Services e integracoes

- `prisma-client.ts`: singleton em `globalThis` fora de producao;
- `upload-config-sw.ts`: `s3Client` e `upload` multer-s3; a maioria dos controllers usa multer em memoria + `PutObjectCommand`; update apaga o objeto antigo; URL publica `https://<bucket>.s3.<region>.amazonaws.com/<key>`;
- `encryption-service.ts`: AES-256-GCM com `ENCRYPTION_KEY` (base64 32 bytes), formato base64(iv12 + tag16 + ciphertext);
- `google-calendar-service.ts` e `google-calendar-sync-service.ts`: OAuth, refresh, CRUD de eventos e calendarios;
- `send-forgot-password-email.ts`: Gmail com conta fixa no codigo e link fixo `event-hub-dashboard.vercel.app/reset-password`;
- `web-push-service.ts`: so usado pelo script de chaves; nenhuma rota envia push.

Detalhe operacional em `topics/integrations.md`.

## Testes

- Vitest, `globals`, ambiente `node`, sem setup file; 48 arquivos `*.spec.ts` em `src/`;
- cobertura concentrada em `functions/` (preco, wall-clock, relatorios), `proposal/*`, `service`, `venue-rule`, `venue-amenity`, `minimum-price-period`, `notification`, `contact`, `person/create-many`, refresh token e schemas Zod;
- sem teste de router/integracao HTTP, auth negativa global, payment, document ou contract;
- comando: `npm test -- --run`; prova de schema: `npx prisma validate`.

## Pontos de atencao do codigo

- TIERED existe no schema (`TieredPrice`, `Tier`) sem calculo;
- regra sazonal + meta implementada em tres lugares (`proposal-amounts`, `adjust-proposal-unit-price`, copia inline em `create-proposal-per-day`);
- `monthlyRevenueAnalysis` e `getVenueAnalytics` usam horario local; listagens usam UTC/wall-clock;
- `calc-standart-total-amount` chama `calcExtraHoursQty` com um argumento so;
- rotas com defeito: `GET /person/list` duplicado, `PUT /person/getById`, `/contract/list` com `:venueId` repetido, padroes `?:param` que casam prefixos inesperados;
- remetentes de e-mail e URLs fixos no codigo;
- campos legados `teste` em `ProposalService`/`ProposalCost` e relacao `noificationList`.
