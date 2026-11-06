# Active Libs — EventHub

Fonte de verdade da stack observada em 2026-11-02.

## Libs ativas

- `node`: backend Node.js, Express 4 e TypeScript CommonJS em `art56_server_v3/`; ler `.cursor/framework_global/framework-libs/node/index.md`.
- `react`: dashboard React 18, Vite 5 e TypeScript em `eventhub-vista-dashboard/`; ler `.cursor/framework_global/framework-libs/react/index.md`.
- `database`: MySQL via Prisma 5, com `relationMode = "prisma"`; ler `.cursor/framework_global/framework-libs/database/index.md`.
- `aws`: armazenamento S3, nao a plataforma inteira de deploy; ler `.cursor/framework_global/framework-libs/aws/index.md`.
- `design`: Tailwind CSS, shadcn/Radix e componentes locais; ler `.cursor/framework_global/framework-libs/design/index.md`.
- `security`: obrigatoria em auth, permissoes, PII, pagamentos, uploads, OAuth e segredos; ler `.cursor/framework_global/framework-libs/security/index.md`.
- `architecture`: contratos multi-repo e decisoes estruturais; ler `.cursor/framework_global/framework-libs/architecture/index.md`.
- `patterns`: padrao router -> controller -> use case -> repository; ler `.cursor/framework_global/framework-libs/patterns/index.md`.
- `observability`: baseline para logs, health, metricas e alertas hoje ausentes; ler `.cursor/framework_global/framework-libs/observability/index.md`.

## Variantes locais

- HTTP: Express 4; nao migrar framework como efeito colateral.
- ORM: Prisma 5 com migrations MySQL.
- validacao: Zod nos dois repositorios.
- frontend: TanStack React Query e Zustand coexistem; evitar terceira abordagem.
- deploy observado: Vercel serverless para API e SPA.
- testes: Vitest nos dois repositorios, com cobertura muito baixa.

## Leituras por frente

- API: `node` + `patterns`, somando `database` ao persistir.
- UI: `react` + `design`, somando `security` para guards ou dados sensiveis.
- schema: `database` + `node`.
- S3: `aws` + `security`.
- Google Calendar/OAuth: `node` + `security` + `observability`.
- contrato multi-repo: `architecture`, `topics/backend-api.md` e `topics/frontend-application.md`.

## Nao ativas

`k8s`, `java`, `python`, `react-native`, `llm`, `agents`, `mcp`, `ml` e `aiops` nao aparecem no runtime. `github` nao e ativa porque nao ha CI/CD de produto mapeado.
