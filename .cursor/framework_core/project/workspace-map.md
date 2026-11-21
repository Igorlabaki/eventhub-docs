# Workspace Map — EventHub

Mapa da raiz do workspace `eventhub/`, observado em 2026-11-10. Fato atual; desejo futuro fica em roadmap, plan ou spec.

## Raiz

```text
eventhub/
  art56_server_v3/            repo-id backend   (API Express + Prisma)
  eventhub-vista-dashboard/   repo-id frontend  (SPA React + Vite)
  eventhub-docs/              repo-id docs      (memoria viva, docs legados e framework global)
    .cursor/
      framework_core/         memoria viva do EventHub (este core)
      rules/framework.mdc     regra always-apply que roteia o agente para o core
      cola.md                 cola pessoal de gatilhos
    framework_global/         repo aninhado edge-labs-br/framework_global (camada global)
    docs/                     documentacao legada/detalhada (marco/2025 em diante)
    AGENTS.md                 instrucoes para agentes no workspace
```

Nao existe repositorio na raiz `eventhub/`: cada pasta e um repositorio git independente.

## Repositorios

| repo-id | Pasta | Remoto | Branch | Ultimo commit observado |
|---|---|---|---|---|
| `backend` | `art56_server_v3/` | `github.com/Igorlabaki/art56_server_v3` | `main` (unica) | `d9f0bce7` 2026-11-09 categoria do evento, cotacao e resumo de notificacoes |
| `frontend` | `eventhub-vista-dashboard/` | `github.com/Igorlabaki/eventhub-vista-dashboard` | `main` (unica) | `95757ff` 2026-11-10 |
| `docs` | `eventhub-docs/` | `github.com/Igorlabaki/eventhub-docs` | `main` | `f5f1c9e` 2026-11-06 primeiro commit do framework; core com muitas mudancas nao commitadas |
| `framework-global` | `eventhub-docs/framework_global/` | `github.com/edge-labs-br/framework_global` | `main` | `09191bc` 2026-09-28 merge `aiops_manage` |

`framework_global/` e um repositorio aninhado dentro de `eventhub-docs/` (sem `.gitmodules`); atualiza-se com `git pull` dentro dele e nunca recebe memoria do EventHub.

## Como as pastas conversam

- `frontend` chama `backend` por HTTP em `VITE_API_URL` com JWT Bearer; nao ha pacote de tipos compartilhado; contrato vive em `project/api-endpoints.md` e `docs/referencias/API_CONTRACTS.md`.
- `backend` persiste em PlanetScale (MySQL/Vitess) via Prisma; detalhes em `project/planetscale.md`.
- os dois repos de codigo fazem deploy em Vercel (`vercel.json` em cada um); nao ha CI.
- `docs` nao tem runtime; o core roteia e resume, `docs/` guarda analises extensas.
- links publicos enviados a clientes usam o dominio fixo `event-hub-dashboard.vercel.app` em varios pontos do frontend e no e-mail de reset do backend.

## Caminhos do framework

- o `AGENTS.md`, `rules/framework.mdc` e varios artefatos citam `.cursor/framework_global/...`; essa pasta nao existe. O caminho real e `eventhub-docs/framework_global/`. Ao seguir referencias, trocar `.cursor/framework_global/` por `framework_global/` a partir de `eventhub-docs/`.
- validador (Windows, a partir de `eventhub-docs/`): `py -3 framework_global/framework-base/tools/validate-framework.py --core .cursor/framework_core --global-root framework_global --strict`.

## Estado dos working trees (2026-11-10)

- `backend`: alteracoes locais em `event-category`, `monthly-average-by-years`, repositorio de proposal e novo `report-year-range` (relatorios por categoria/ano).
- `frontend`: alteracoes locais em `components/reports/*`, `venueReportsStore` e `types/venue.ts`.
- `docs`: core com dezenas de task-requests e specs novas nao commitadas.

## Mapas detalhados

| Assunto | Arquivo |
|---|---|
| backend: estrutura, stack, modulos, helpers, testes | `project/backend-map.md` |
| catalogo completo de endpoints HTTP com auth | `project/api-endpoints.md` |
| frontend: rotas, paginas, services, estado, UI | `project/frontend-map.md` |
| banco PlanetScale | `project/planetscale.md` |
| ambientes, deploy e configuracao | `project/infra-map.md` |
| documentacao legada em `docs/` | `topics/legacy-docs-map.md` |
| framework global (o que existe e quando ler) | `topics/framework-global-map.md` |
