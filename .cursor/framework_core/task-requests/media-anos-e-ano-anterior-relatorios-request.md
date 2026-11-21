# Solicitacao da Tarefa

## Nome sugerido da tarefa

Linhas da media dos anos e do ano anterior no grafico por mes dos relatorios

## Resumo da solicitacao

O grafico `Orçamentos por mês` (e `Eventos por mês`) da tela de relatorios ganha duas linhas novas: a do ano anterior, mes a mes, e a da media de cada mes nos anos com receita do espaco, na mesma regra de anos do Desempenho Mensal da visao geral.

## Context Pack

- frente principal: frontend, com dado novo do backend para a media
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: a media usar anos diferentes da regra do mensal (anos de propostas com data errada, como 6 ou 1996) ou contar o mes pelo fuso do servidor em vez do wall-clock; as linhas novas sairem cortadas porque o eixo Y so olha a serie atual
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: cards de KPI, Origem dos leads, Principais insights, aba Financeiro, graficos da visao geral (`VenuePerformanceSeries`), regra de `revenueYears`, schema e migration
- prova minima desta execucao: em `/venue/:id/reports` na aba Orçamentos de 2026, o grafico mostra a barra e a Tendência como hoje, mais uma linha de 2025 mes a mes e uma linha tracejada `Média dos anos`; no toggle `Taxa de conversão`, as duas linhas trocam para a taxa; ao trocar o ano no cabecalho, as linhas acompanham; a aba Eventos se comporta igual; legenda, tooltip e `sr-only` listam as series novas
- criterio de escalada: `normal`; sobe para `spec` se a media precisar de rota nova com contrato proprio ou mudar o seletor de ano
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx` em `MonthlyChart`; `eventhub-vista-dashboard/src/components/reports/report-metrics.ts` em `ReportInput` e `buildReportModel`; `art56_server_v3/src/use-cases/venue/get-analysis-by-month-venue/use-case-get-analysis-by-month-venue.ts`
- libs obrigatorias: `node`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/node/index.md`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/reports/BudgetsReport.tsx`; `eventhub-vista-dashboard/src/components/reports/EventsReport.tsx`; `eventhub-vista-dashboard/src/components/reports/useAnalysisYear.ts`; `eventhub-vista-dashboard/src/types/venue.ts` (`AnalysisData`); `art56_server_v3/src/functions/same-month-revenue-by-year.ts` (`revenueEventWhere`, `revenueYears`); `art56_server_v3/src/functions/wall-clock-datetime.ts`; `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts` em `getVenueAnalytics`, so para leitura
- palavras-chave ou simbolos de busca: `MonthlyChart`, `quantitySeries`, `conversionSeries`, `alignMonths`, `useAnalysisYear`, `analysisProposalByMonth`, `analysisEventsByMonth`, `revenueYears`, `revenueEventWhere`, `wallClockMonth`, `wallClockYear`
- testes provaveis: media de tres anos com um mes em zero; um ano so; espaco sem ano com receita (sem linha de media); ano anterior sem dado (sem linha); conversao agregada com mes sem proposta em todos os anos (zero); eixo Y cobrindo a maior das tres series; legenda e `sr-only` com as series novas
- nao ler por padrao: `security`, `database`, `topics/`, schema e specs da visao geral

## Contexto informado na entrada

Pedido em chat, com print de `Orçamentos por mês` em 2026 (barras de jan. a dez. com a linha de Tendência): "preciso de mais uma linha da media dos anos com a mesma regra do mensal e preciso de uma linha mostrando o ano anterior". Decisoes tomadas no chat: a media usa os anos com receita da regra do mensal; o ano selecionado entra na conta; a media da conversao e a taxa sobre a soma dos anos.

## Problema atual

O grafico mostra so o ano selecionado. Nao da para ver, mes a mes, se o ano esta acima ou abaixo do ano anterior nem do que o mes costuma render ao longo dos anos.

## Objetivo da mudanca

Quem abre o grafico por mes dos relatorios compara cada mes do ano selecionado com o mesmo mes do ano anterior e com a media daquele mes nos anos com receita do espaco.

## Escopo inicial percebido

A linha do ano anterior sai do que a tela ja busca: `useAnalysisYear` do ano anterior devolve `analysisProposalByMonth` e `analysisEventsByMonth`, hoje usados so nos totais dos KPIs. A media precisa de dado novo: a rota de analise por mes devolve um ano por vez, e a lista de anos com receita so existe dentro de `getVenueAnalytics`. A resposta da analise por mes ganha, de forma aditiva, os anos usados e a media por mes.

## Itens incluidos neste request

- backend: a resposta de analise por mes passa a trazer os anos da media e, para cada mes, a media de orcamentos, a media de aprovados e a taxa agregada; os campos atuais ficam iguais
- frontend: series do ano anterior e da media no modelo do relatorio, para quantidade e conversao, nas abas Orçamentos e Eventos
- grafico: linha do ano anterior em cor neutra e linha `Média dos anos` tracejada em cor distinta da barra e da Tendência, as duas sem rotulo de valor sobre os pontos
- legenda do rodape, tooltip e lista `sr-only` com o ano anterior (ex.: `2025`) e `Média dos anos`

## Requisitos implicitos ja visiveis

- anos da media = `revenueYears` do espaco (eventos `type: "EVENT"` com `totalAmount` maior que zero, em qualquer mes), mesma regra do Desempenho Mensal
- o ano selecionado entra na media quando estiver na lista de anos com receita
- media de quantidade do mes = soma da quantidade do mes em todos os anos da lista / quantidade de anos; ano com receita e zero no mes entra como zero
- media da conversao do mes = aprovados do mes somados nos anos / propostas do mes somadas nos anos; mes sem proposta em nenhum ano fica em zero
- mes e ano da media pelo wall-clock da data do evento, sem converter fuso
- a linha de Tendência e os rotulos da serie atual continuam como estao
- o dominio do eixo Y considera a serie atual, o ano anterior e a media
- o nome do ano anterior vem do ano selecionado menos um, nao de valor fixo

## Casos de erro e borda ja percebidos

- espaco sem ano com receita: sem linha de media, grafico atual
- um ano so com receita: a media e o valor desse ano
- ano anterior ainda carregando ou com erro: sem linha do ano anterior, sem quebrar o grafico
- ano anterior todo em zero: linha em zero
- ano selecionado fora da lista de anos com receita (ex.: ano futuro): a media continua sendo dos anos da lista
- ano com data errada e com receita (ex.: 0006): entra na media, mesma limitacao do mensal; correcao do dado fica fora

## Dependencias

- `revenueYears` e `revenueEventWhere` ja existem (request [desempenho-mensal-anos-com-receita](desempenho-mensal-anos-com-receita-request.md))
- `useAnalysisYear` ja busca o ano anterior em `BudgetsReport` e `EventsReport`
- `MonthlyChart` ja desenha barra e linha em `ComposedChart`

## Restricoes e cuidados

- mudanca aditiva no contrato da analise por mes; nao remover nem renomear campos atuais
- nao mudar a regra de `revenueYears` nem os graficos da visao geral
- nao criar coluna nem migration
- nao copiar valores do print como dado fixo
- execucao toca dois repos; pode ser derivada com `tasking/task-request-repo-split-prompt.md` se preferir entregar backend e frontend separados

## Perguntas em aberto

- A media vem na mesma rota de analise por mes ou numa rota nova? Premissa: na mesma, como campo aditivo, calculada so quando a rota e chamada para o ano selecionado.
- A conta do mes na parte atual da rota continua com `toLocaleString` no fuso do servidor? Premissa: sim neste request; so a media usa wall-clock. Alinhar o resto da rota e outra tarefa.
- Aprovado, para a media de conversao, segue a mesma definicao da rota hoje (`proposal.approved`)? Premissa: sim.
- Na aba Eventos, a media de quantidade e de eventos aprovados? Premissa: sim, espelhando a serie atual da aba.

## Prioridade sugerida

Media. O grafico funciona; o ganho e referencia de comparacao.

## Faixa sugerida para task workflow

- `B` — dois repos e campo novo no contrato, mas um objetivo so e sem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, contrato aditivo, sem migration nem fluxo sensivel

## Sugestao de slug da spec

- `framework_core/specs/media-anos-e-ano-anterior-relatorios/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `media-anos-e-ano-anterior-relatorios-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica` (executado nos dois repos de uma vez)
- entrega: backend com `monthlyAverageByYears` e `yearsProposalWhere` em `functions/monthly-average-by-years.ts`, `revenueYearsProposals` no repositorio de proposta e `average=true` opcional na analise por mes (`averageYears`, `averageByMonth`); frontend pede a media em `fetchBudgetsData`, monta ano anterior e media em `report-metrics.ts` (`averageMonths`) e desenha as duas linhas em `MonthlyChart` com legenda, tooltip e `sr-only`; vitest 16 no backend (2 arquivos) e 19 em `components/reports`; `tsc` sem erro novo nos arquivos tocados (o `onChange={setMode}` do `SeriesToggle` ja falhava, igual ao `FinancialReportCard`); eslint so com o `any` antigo da store; `API_CONTRACTS.md` atualizado; browser parado no login
