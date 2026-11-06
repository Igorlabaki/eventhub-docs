# Spec — Desempenho mensal do mesmo mes em todos os anos

## Problema

Com um mes selecionado, o Desempenho Mensal da visao geral mostra um unico ponto: a receita daquele mes no ano filtrado, e a meta na linha. Quem olha o mes nao ve como ele se comportou nos outros anos em que o espaco tem registro.

## Objetivos

- mostrar a receita do mes escolhido em cada ano com registro do espaco
- desenhar essa serie como os relatorios: barra e linha de tendencia da mesma receita
- manter o Desempenho Anual como os doze meses do ano escolhido

## Fora de escopo

- Desempenho Anual, cards, proximo evento, proxima visita e o seletor de mes e ano
- abas de relatorio e a meta no grafico mensal
- schema, migration e a correcao da janela de data do KPI `monthlyRevenue`
- endpoint novo

## User stories ou cenarios principais

- Com novembro selecionado num espaco que tem orcamento em 2024, 2025 e 2026, a pessoa ve tres barras, uma por ano, com a receita de novembro e a linha de tendencia.
- Com o ano inteiro selecionado, a pessoa continua vendo o Desempenho Anual dos doze meses.

## Criterios de aceite

- `R-01`: com um mes selecionado, a resposta da visao geral traz uma entrada por ano de `proposalYears`, do mais antigo ao mais recente, com a receita desse mes
- `R-02`: a receita de cada ano soma `totalAmount` dos eventos `EVENT` cujo mes e ano de parede coincidem com o mes selecionado e o ano da entrada
- `R-03`: ano presente em `proposalYears` e sem evento nesse mes entra com receita zero
- `R-04`: espaco sem ano em `proposalYears` devolve lista vazia; com `month=all`, o campo vem `null`
- `R-05`: o Desempenho Mensal desenha uma barra por ano e a linha de tendencia sobre a mesma receita, no desenho de Orcamentos e Evento
- `R-06`: o rotulo da barra omite o zero; o tooltip mostra o valor em real
- `R-07`: lista vazia mostra o estado vazio, sem coluna inventada
- `R-08`: o Desempenho Anual continua os doze meses do ano escolhido, com receita em barra e meta em linha
- `R-09`: trocar o mes pede de novo a serie daquele mes; cards, proximo evento, proxima visita, seletor e relatorios nao mudam

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a serie sai no mesmo `getVenueAnalytics` ja usado pela visao geral; esta feature nao abre rota nem afrouxa a autorizacao existente
- erros e mensagens esperadas: lista vazia vira o texto "Sem anos com registro"; falha da API continua o erro que a visao geral ja mostra
- observabilidade minima: nenhuma; a prova e o teste da funcao e o grafico na tela
- concorrencia, idempotencia ou retry: nenhum; leitura agregada
- rollout, fallback ou degradacao: se o campo ainda nao veio, o mensal mantem a barra unica do ano filtrado; campo presente, inclusive vazio, manda no grafico

## Casos de erro e borda obrigatorios

- caso: um unico ano com registro
  impacto: uma barra e um ponto de tendencia
  cobertura esperada: `T-01` e `T-02`
- caso: ano com registro e sem evento no mes
  impacto: receita zero e sem rotulo
  cobertura esperada: `T-01` e `T-02`
- caso: evento de outro mes ou que nao seja `EVENT`
  impacto: nao entra na soma
  cobertura esperada: `T-01`
- caso: `month=all`
  impacto: campo `null` e o anual inalterado
  cobertura esperada: `T-01` e `T-02`
- caso: data na borda do mes, guardada em UTC como relogio de parede
  impacto: entra no mes de `wallClockMonth`, nao no mes do fuso local
  cobertura esperada: `T-01`

## Impacto esperado

A visao geral passa a comparar o mesmo mes entre anos. O contrato ganha um campo. O KPI de receita do mes pode divergir da barra do ano selecionado quando o evento cai nas primeiras horas do mes no fuso local.

## Areas impactadas

- `art56_server_v3`: `getVenueAnalytics` e o tipo `VenueAnalyticsResponse`
- `eventhub-vista-dashboard`: tipo da visao geral e o grafico Desempenho Mensal

## Restricoes e cuidados

- `D-06`: a serie usa `wallClockYear` e `wallClockMonth`; nao converter a agenda como instante local
- `D-07`: a soma continua em `number`, como `monthlyRevenue`; sem migrar para Decimal
- `D-01`: o campo e o contrato compartilhado; a execucao pode ser dividida por repo depois da spec

## Dependencias

- `proposalYears` ja lista os anos de `startDate` dos orcamentos do espaco
- a receita atual do grafico ja soma `EVENT` com `proposal.totalAmount`
- Orcamentos e Evento ja entregam barra com linha de tendencia

## Mapeamento leve requisito -> task -> prova

- `R-01` a `R-04` -> `T-01` -> unitario
- `R-05` a `R-09` -> `T-02` -> unitario

## Perguntas em aberto

- ver `02-clarify.md`; nenhuma bloqueia a execucao

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
