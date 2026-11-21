# Project Catalog Entry — EventHub

## Identificacao

- nome do projeto: EventHub;
- nome curto: eventhub;
- status: produto existente em evolucao, em producao; o espaco AR756 aparece como venue principal nos artefatos, no nome do banco (`ar756`), no repo do backend e no remetente de e-mail;
- dominio: gestao comercial e operacional de espacos de eventos;
- produto pai: nao identificado no workspace.

## Ownership

- owner principal: nao documentado; confirmacao humana necessaria;
- time responsavel: nao documentado;
- tech lead: nao documentado;
- contato de produto: nao documentado;
- canal principal: nao documentado.

## Escopo

- objetivo: administrar organizacoes e venues, propostas, contratos, agenda, pagamentos, documentos, pessoas, servicos, precos, metas, despesas, relatorios, site e comunicacoes;
- publico: administradores, operadores de venue, equipe e clientes/convidados/fornecedores em links publicos;
- capacidades: auth, permissoes, propostas com preco calculado, apresentacao publica do orcamento, agenda com Google, pagamentos, contratos em PDF, listas publicas, relatorios e KPIs, notificacoes, site e integracoes.

## Mapa operacional de repositorios

- repo id: `backend`
  - caminho: `art56_server_v3/`
  - remoto: `https://github.com/Igorlabaki/art56_server_v3.git`
  - branch: `main`
  - papel: API Express, regras, Prisma/PlanetScale e integracoes de servidor
  - depende de: PlanetScale MySQL, S3, SMTP Hostinger, Gmail e Google Calendar
  - mapa: `project/backend-map.md`, `project/api-endpoints.md`
- repo id: `frontend`
  - caminho: `eventhub-vista-dashboard/`
  - remoto: `https://github.com/Igorlabaki/eventhub-vista-dashboard.git`
  - branch: `main`
  - papel: painel e paginas publicas React/Vite
  - depende de: backend, Google OAuth e Vercel Insights
  - mapa: `project/frontend-map.md`
- repo id: `docs`
  - caminho: `eventhub-docs/`
  - remoto: `https://github.com/Igorlabaki/eventhub-docs.git`
  - branch: `main`
  - papel: este core (`.cursor/framework_core/`), regra do Cursor, `AGENTS.md` e docs legados (`docs/`)
  - depende de: nenhuma dependencia de runtime
- repo id: `framework-global`
  - caminho: `eventhub-docs/framework_global/` (repo aninhado)
  - remoto: `https://github.com/edge-labs-br/framework_global.git`
  - branch: `main`
  - papel: prompts, templates, agentes e libs globais
  - depende de: nenhuma dependencia de runtime
  - mapa: `topics/framework-global-map.md`

Visao da raiz e de como as pastas se ligam: `project/workspace-map.md`.

## Partes importantes

- backend: `src/server.ts`, `src/router/`, `src/use-cases/`, `src/repositories/`, `src/functions/`, `src/zod/`, `prisma/schema.prisma`;
- frontend: `src/App.tsx`, `src/pages/`, `src/components/`, `src/services/`, `src/hooks/`, `src/store/`, `src/lib/`;
- mobile, workers, filas e IA: nao existem no runtime mapeado;
- integracoes: S3, SMTP/Gmail, Google OAuth, Google Calendar e Vercel Insights.

## Dependencias relevantes

- banco: PlanetScale MySQL via Prisma 5 (`project/planetscale.md`);
- filas: nenhuma;
- storage: S3;
- autenticacao: JWT Bearer, Session/RefreshToken e Google login;
- externos: Google Calendar, SMTP Hostinger, Gmail e Vercel.

## Documentacao

- produto: `product/01-product-vision.md`;
- regras: `product/02-business-rules.md`;
- jornadas: `product/04-user-journeys.md`;
- dados: `product/08-data-model.md`;
- topics: `topics/README.md`;
- decisoes: `project/project-decisions.md`;
- backlog: `BOARD.md`;
- agentes: `project/agent-entrypoint.md`;
- docs legados: `topics/legacy-docs-map.md`.

## Observabilidade e riscos

- logs: console, sem formato estruturado;
- alertas, dashboards e tracing: nao mapeados;
- runbooks: `docs/planos/PRODUCTION_SETUP.md`, `docs/INTEGRATIONS_GOOGLE_CALENDAR.md` e `project/planetscale.md`;
- riscos: 88 endpoints publicos, refresh e `PUBLIC_ROUTES` divergentes, CORS aberto, sem rate limit, cobertura baixa de fluxos HTTP, transacoes incompletas, divergencias entre specs e codigo;
- superficies sensiveis: PII, dados bancarios, auth, permissoes, pagamentos, uploads, OAuth e segredos.
