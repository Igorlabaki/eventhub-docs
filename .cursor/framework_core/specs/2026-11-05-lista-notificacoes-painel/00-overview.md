# KPIs, filtros, paginas e leitura na lista de notificacoes

## Identificacao

- nome da feature: KPIs, filtros, paginas e leitura na lista de notificacoes
- slug: `lista-notificacoes-painel`
- status: codigo escrito; prova no browser pendente
- origem: `task-requests/lista-notificacoes-painel-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: Notificacoes devolve no maximo 25 linhas, filtra no navegador e nunca grava `isRead`
- resultado esperado: busca, tipo, lida/nao lida, pagina de 10 e os quatro cards saem do `GET /notification/list/:venueId`; abrir o orcamento no painel marca as notificacoes dele; um botao marca todas as nao lidas do espaco

## Contexto base

- requests relacionados: `task-requests/lista-notificacoes-painel-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project/project-decisions.md#D-02` e `#D-05`

## Estado atual da feature

- fase atual: `T-01` a `T-04` escritas
- task em andamento: nenhuma
- proxima task recomendada: prova no browser

## Observacoes

- restricoes: sem schema novo; `GET /proposal/byId` nao grava `isRead`; a lista sem `page` continua no teto de 25
- riscos principais: cards contados so nas dez linhas; leitura publica do orcamento marcar como lida
