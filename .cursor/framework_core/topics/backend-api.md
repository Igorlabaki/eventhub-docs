# Backend and API

## Mapa

- repo: `backend` (`art56_server_v3/`);
- entrada: `src/server.ts` (Vercel); local: `src/dev-server.ts` (porta 3000);
- 33 routers, 184 endpoints, 96 autenticados, 88 publicos; catalogo em `project/api-endpoints.md`;
- fluxo: router -> factory -> controller (Zod) -> use case -> repository interface -> Prisma;
- 36 dominios de use case, 35 repositorios, 211 schemas Zod, 48 specs Vitest;
- estrutura, stack, helpers e pontos de atencao em `project/backend-map.md`.

## Contrato HTTP

- prefixos por recurso (`/auth`, `/user`, `/organization`, `/venue`, `/proposal`, `/dateEvent`, `/payment`, `/document`, `/person`, `/schedule`, `/contract`, `/clause`, `/service`, `/seasonalFee`, `/minimumPricePeriod`, `/goal`, `/expense`, `/venue-rule`, `/venue-amenity`, `/contact`, `/notification`, `/integrations/google-calendar` e outros);
- convencao de nome mista (`camelCase`, `kebab-case`, typos como `createOvernigth`); manter o nome existente ao estender;
- sem versionamento `/v1`;
- sucesso devolve objeto direto; listas novas usam `page` e `summary` (proposal, contact, notification);
- erro `{ title, message }`; 500 devolve `error.toString()`;
- health simples em `GET /`;
- payloads detalhados em `docs/referencias/API_CONTRACTS.md`.

## Cuidados

- 14 routers inteiros sem auth; protecao por recurso so em poucos authorizers (`topics/permissions-catalog.md`);
- CORS `*`, sem helmet, rate limit, logger nem handler global de erro;
- dois `express.json()`: o limite efetivo de JSON e 100 kb, nao 50 MB;
- uploads em memoria; so contact e service limitam tamanho;
- integracoes (S3, e-mail, Google) sincronas na request, sem fila nem retry;
- fluxos multi-escrita (criar proposta com servicos, pagamento + `amountPaid`) nem sempre usam `prisma.$transaction`;
- regras de preco em `topics/pricing-and-proposal-calculation.md`; KPIs em `topics/reports-and-kpis.md`.

## Como estender

1. criar `zod/<dominio>/*-schema.ts`;
2. criar `use-cases/<dominio>/<caso>/` com controller, factory e use case;
3. estender interface e implementacao Prisma do repositorio;
4. registrar rota no router do prefixo, com `ensureAuthenticate` salvo publico intencional documentado;
5. authorizer por venue quando a acao depende de permissao;
6. spec em `functions/` ou `use-cases/` e `npm test -- --run`.

## Leitura minima

`product/02-business-rules.md`, `project/project-decisions.md`, router do recurso, use case, repository, Zod e testes. Contrato compartilhado: tambem `project/frontend-map.md` e o service correspondente.
