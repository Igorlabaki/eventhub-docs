# Project Catalog Entry — EventHub

## Identificacao

- nome do projeto: EventHub;
- nome curto: eventhub;
- status: produto existente em evolucao;
- dominio: gestao comercial e operacional de espacos de eventos;
- produto pai: nao identificado no workspace.

## Ownership

- owner principal: nao documentado; confirmacao humana necessaria;
- time responsavel: nao documentado;
- tech lead: nao documentado;
- contato de produto: nao documentado;
- canal principal: nao documentado.

## Escopo

- objetivo: administrar organizacoes e venues, propostas, contratos, agenda, pagamentos, documentos, pessoas, servicos e comunicacoes;
- publico: administradores, operadores de venue, equipe e clientes/convidados em fluxos publicos;
- capacidades: auth, permissoes, propostas, agenda, pagamentos, contratos, site, relatorios, notificacoes e integracoes.

## Mapa operacional de repositorios

- repo id: `backend`
  - caminho: `art56_server_v3/`
  - remoto: `https://github.com/Igorlabaki/art56_server_v3.git`
  - branch: `main`
  - papel: API Express, regras, Prisma/MySQL e integracoes de servidor
  - depende de: MySQL, S3, e-mail, Web Push e Google Calendar
- repo id: `frontend`
  - caminho: `eventhub-vista-dashboard/`
  - remoto: `https://github.com/Igorlabaki/eventhub-vista-dashboard.git`
  - branch: `main`
  - papel: dashboard e formularios publicos React/Vite
  - depende de: backend, Google OAuth e analytics Vercel opcional
- repo id: `framework-global`
  - caminho: `framework_global/`
  - remoto: `https://github.com/edge-labs-br/framework_global.git`
  - branch: `main`
  - papel: prompts, templates e libs globais
  - depende de: nenhuma dependencia de runtime.

## Partes importantes

- backend: `src/server.ts`, `src/router/`, `src/use-cases/`, `src/repositories/`, `prisma/schema.prisma`;
- frontend: `src/App.tsx`, `src/pages/`, `src/components/`, `src/services/`, `src/hooks/`, `src/store/`;
- mobile, workers e IA: nao existem no runtime mapeado;
- integracoes: S3, e-mail, Web Push e Google Calendar.

## Dependencias relevantes

- banco: MySQL via Prisma;
- filas: nenhuma;
- storage: S3;
- autenticacao: JWT Bearer, Session/RefreshToken e Google login;
- externos: Google Calendar, e-mail e Web Push.

## Documentacao

- produto: `product/01-product-vision.md`;
- regras: `product/02-business-rules.md`;
- jornadas: `product/04-user-journeys.md`;
- topics: `topics/README.md`;
- decisoes: `project/project-decisions.md`;
- backlog: `BOARD.md`;
- agentes: `project/agent-entrypoint.md`.

## Observabilidade e riscos

- logs: console, sem formato estruturado;
- alertas, dashboards e tracing: nao mapeados;
- runbooks: `docs/planos/PRODUCTION_SETUP.md` e `docs/INTEGRATIONS_GOOGLE_CALENDAR.md`;
- riscos: endpoints sem auth, refresh divergente, CORS aberto, cobertura baixa, transacoes incompletas e listas sem paginacao;
- superficies sensiveis: PII, auth, permissoes, pagamentos, uploads, OAuth e segredos.
