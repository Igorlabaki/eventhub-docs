# Variacao anual dos KPIs na lista de orcamentos

## Identificacao

- nome da feature: variacao anual dos KPIs na lista de orcamentos
- slug: `variacao-anual-kpis-orcamentos`
- status: spec pronta; nenhuma task executada
- origem: `task-requests/variacao-anual-kpis-painel-orcamentos-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: os tres cards mostram o periodo e nao dizem se ele esta acima ou abaixo do mesmo periodo no ano anterior
- resultado esperado: o canto superior direito de cada card mostra o percentual inteiro dessa variacao

## Contexto base

- requests relacionados: `task-requests/variacao-anual-kpis-painel-orcamentos-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project/project-decisions.md#D-01`, `#D-06` e `#D-08`

## Estado atual da feature

- fase atual: planejamento
- task em andamento: nenhuma
- proxima task recomendada: `T-01`

## Observacoes

- restricoes: sem endpoint novo, sem schema, sem mudar o numero principal dos cards
- riscos principais: o percentual nascer das linhas da pagina, ou comparar um dia com o mes inteiro
