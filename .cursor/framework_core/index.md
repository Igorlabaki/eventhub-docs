# EventHub Framework Core

## Leitura minima

1. `project/agent-entrypoint.md`
2. `project/active-libs.md`
3. `project/project-decisions.md` quando houver decisao estrutural ou excecao
4. `BOARD.md`
5. artefato de trabalho indicado no board

## Mapa

- `product/`: snapshot operacional do produto e das regras de negocio
- `project/`: repositorios, stack, arquitetura real e decisoes locais
- `topics/`: mapas curtos para as areas criticas do sistema
- `flows/`: fluxos ponta a ponta atuais
- `task-requests/`: entradas canonicas do fluxo normal
- `specs/`: features e iniciativas maiores
- `*-by-repo/`: pacotes derivados para `backend` e `frontend`
- `plans/` e `roadmaps/`: descoberta de solucao e direcao macro
- `management/`: decisoes, riscos, capacidade e status

## Camada global

Os prompts, templates e bibliotecas ficam em `.cursor/framework_global/`, vinculado ao repositorio `framework_global/`. A memoria especifica do EventHub fica somente neste core.
