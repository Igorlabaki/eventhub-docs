# Lista paginada de orcamentos no painel

## Identificacao

- nome da feature: lista paginada de orcamentos no painel
- slug: `lista-painel-orcamentos`
- status: codigo escrito; prova no browser pendente
- origem: `task-requests/lista-painel-orcamentos-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: a pagina de orcamentos baixa o mes inteiro e filtra no navegador, sem pagina nem cards
- resultado esperado: a tela fica parecida com a referencia, e pagina, filtros, ordenacao e KPIs vem do `GET /proposal/list`

## Contexto base

- requests relacionados: `task-requests/lista-painel-orcamentos-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project/project-decisions.md#D-01`, `#D-05`, `#D-06` e `#D-07`

## Estado atual da feature

- fase atual: `T-01` a `T-04` escritas; indice no `main`
- task em andamento: nenhuma
- proxima task recomendada: prova no browser, depois `fw:review` se quiser

## Observacoes

- restricoes: sem status Enviado, sem coluna nova, sem redesenhar a pagina de eventos
- riscos principais: o default de `approved` hoje esconde o Fechado; a data da lista nao usa wall-clock
