# Clarify — Desempenho mensal do mesmo mes em todos os anos

## Perguntas criticas

- Quais anos entram? Premissa: os de `proposalYears`, ja usados no seletor. Risco se estiver errada: um ano que so tem evento, sem `startDate` de orcamento, fica de fora.
- Qual receita? Premissa: a mesma conta do grafico atual, soma de `totalAmount` dos `EVENT`. Risco se estiver errada: a barra nao bate com o que a visao geral ja chama de receita.
- A linha e a meta ou a tendencia? Premissa: tendencia da receita; a meta sai do mensal. Risco se estiver errada: o grafico deixa de comparar o mes com a meta.
- O anual muda? Premissa: nao. Risco se estiver errada: a pessoa perde a meta no ano.

## Respostas confirmadas

- o pedido pede o mes selecionado em todos os anos com registro e o grafico de tendencia dos relatorios
- a visao geral abre no mes corrente e o seletor troca o mes
- `proposalYears` sai de `uniqueProposalYears` sobre o `startDate` dos orcamentos, em ordem crescente, via `wallClockYear`

## Requisitos implicitos confirmados

- ano sem evento no mes aparece zerado
- sem anos, nao ha coluna inventada
- o grafico mensal segue oculto abaixo de `lg`

## Premissas assumidas

- a serie nova usa relogio de parede (`wallClockMonth` e `wallClockYear`), por `D-06`
- a janela local de `monthlyRevenue` nao e corrigida aqui; a barra do ano selecionado pode divergir do KPI na borda do mes
- `month=all` nao calcula a serie
- se o campo ainda nao veio na resposta, o mensal mantem a barra unica atual

## Perguntas de erro e borda ainda abertas

- nenhuma alem das premissas acima

## Itens bloqueantes

- nenhum

## O que pode seguir mesmo com lacunas

- `T-01` e `T-02` seguem pelas premissas. Se o produto quiser a meta de volta no mensal, ou os anos vindos dos eventos em vez dos orcamentos, a spec e reaberta.
