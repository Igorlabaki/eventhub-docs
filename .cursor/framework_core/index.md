# EventHub Framework Core

## Leitura minima

1. `project/agent-entrypoint.md`
2. `project/active-libs.md`
3. `project/project-decisions.md` quando houver decisao estrutural ou excecao
4. `BOARD.md`
5. artefato de trabalho indicado no board

## Mapa

- `product/`: snapshot operacional do produto, regras de negocio, dominio e modelo de dados completo
- `project/`: workspace e repositorios (`workspace-map.md`), backend (`backend-map.md`), catalogo de endpoints (`api-endpoints.md`), frontend (`frontend-map.md`), infra, banco PlanetScale (`planetscale.md`), stack e decisoes locais
- `topics/`: mapas curtos por area (API, frontend, dados, auth, permissoes, preco, relatorios, paginas publicas, integracoes, entrega e lacunas, docs legados, framework global) e o backlog vivo de problemas e melhorias (`topics/improvement-backlog.md`)
- `flows/`: fluxos ponta a ponta atuais (ciclo da proposta, pedido publico, operacao do evento, auth, Google Calendar)
- `task-requests/`: entradas canonicas do fluxo normal
- `specs/`: features e iniciativas maiores
- `*-by-repo/`: pacotes derivados para `backend` e `frontend`
- `plans/` e `roadmaps/`: descoberta de solucao e direcao macro
- `management/`: decisoes, riscos, capacidade e status

## Camada global

Os prompts, templates e bibliotecas ficam no repositorio aninhado `eventhub-docs/framework_global/` (citado nos artefatos como `.cursor/framework_global/`). A memoria especifica do EventHub fica somente neste core. Como usar o global no EventHub: `topics/framework-global-map.md`.
