# Desempenho mensal do mesmo mes em todos os anos

## Identificacao

- nome da feature: desempenho mensal do mesmo mes em todos os anos
- slug: `desempenho-mensal-mesmo-mes-nos-anos`
- status: `T-01` e `T-02` escritas; review pendente
- origem: `task-requests/desempenho-mensal-mesmo-mes-nos-anos-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: o Desempenho Mensal mostra so a receita do mes no ano filtrado
- resultado esperado: o grafico mostra esse mes em cada ano com registro, com barra e linha de tendencia

## Contexto base

- requests relacionados: `task-requests/desempenho-mensal-mesmo-mes-nos-anos-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project/project-decisions.md#D-01`, `#D-06` e `#D-07`

## Estado atual da feature

- fase atual: execucao concluida no codigo
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; review de entrega

## Observacoes

- restricoes: sem schema; Desempenho Anual, KPIs e relatorios ficam como estao
- riscos principais: a barra do ano selecionado divergir do KPI nas bordas do mes, porque a serie nova usa relogio de parede e o KPI ainda nao
