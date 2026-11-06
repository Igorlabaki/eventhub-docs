# Backend and API

## Mapa

- repo: `backend`;
- entrada: `src/server.ts`; local: `src/dev-server.ts`;
- 30 routers em `src/router/`;
- fluxo: router -> controller/factory -> use case -> repository interface/Prisma;
- validacao: aproximadamente 185 arquivos Zod por dominio;
- persistencia: 33 implementacoes Prisma e interfaces correspondentes;
- dominios: auth, user, organization, venue, proposal, date-event, payment, contract, clause, document, attachment, person, schedule, service, expense, goal, notification, site e permissoes.

## Contrato HTTP

- prefixos principais: `/auth`, `/user`, `/organization`, `/venue`, `/proposal`, `/dateEvent`, `/payment`, `/contract`, `/document` e `/integrations/google-calendar`;
- sem versionamento `/v1`;
- sucesso normalmente retorna objeto direto;
- erro normalmente retorna `{ title, message }`;
- health simples em `GET /`;
- docs detalhados em `docs/referencias/API_CONTRACTS.md`.

## Cuidados

- protecao de rota e inconsistente;
- CORS aceita qualquer origem;
- `express.json()` esta duplicado e o limite de 50 MB e alto;
- nao ha middleware global de erro confiavel;
- uploads/processamento e integracoes ocorrem sincronos;
- listas frequentemente nao paginam;
- somente dois specs backend foram mapeados.

## Leitura minima

`product/02-business-rules.md`, `project/project-decisions.md`, router do recurso, use case, repository, Zod e testes. Para contrato compartilhado, ler tambem `topics/frontend-application.md`.
