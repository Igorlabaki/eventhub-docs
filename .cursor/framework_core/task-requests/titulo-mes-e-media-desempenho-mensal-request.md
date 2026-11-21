# Solicitacao da Tarefa

## Nome sugerido da tarefa

Titulo do mes e linha da media no Desempenho Mensal

## Resumo da solicitacao

Com um mes selecionado na visao geral, o grafico que hoje se chama Desempenho Mensal passa a dizer de qual mes fala (ex.: Novembro ao longo dos anos) e ganha uma linha horizontal com a media da receita desse mes nos anos que o grafico ja mostra.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: a media usar anos diferentes dos que estao no eixo, ou o titulo novo vazar para o Desempenho Anual
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: backend, regra dos anos com receita, Desempenho Anual, cards de KPI, proximo evento, proxima visita, seletor de mes e ano
- prova minima desta execucao: em `/venue/:id` com novembro selecionado, o titulo diz Novembro ao longo dos anos; uma linha tracejada marca a media das barras do eixo, com rotulo compacto; ao trocar o mes, titulo e media acompanham; em `Anual`, o titulo continua Desempenho Anual e nao ha linha de media
- criterio de escalada: permanece `smart`; sobe para `spec` se a media precisar de outra lista de anos vinda do backend
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenuePerformanceSeries.tsx` em `trendPerformancePoints` e no `variant === "trend"`; `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx` no titulo do card
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenuePerformanceChart.tsx`; `eventhub-vista-dashboard/src/components/venue/VenuePerformanceSeries.test.tsx`; `eventhub-vista-dashboard/src/components/reports/report-metrics.ts` so para leitura
- palavras-chave ou simbolos de busca: `Desempenho Mensal`, `selectedMonth`, `trendPerformancePoints`, `sameMonthRevenueByYear`, `Tendência`, `ReferenceLine`, `REPORT_MONTHS`
- testes provaveis: media de tres anos com um em zero; um ano so; todos os anos em zero; lista vazia sem linha; titulo por extenso para cada mes; `Anual` sem media e com o titulo antigo
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com print da visao geral do AR756 em novembro: o card se chama Desempenho Mensal e mostra 2025 (19,7 mil), 2026 (9,1 mil) e 2027 (zero), com a linha de Tendencia ligando as barras. O titulo deve falar do mes especifico, e o grafico deve ter uma linha da media desse mes ao longo dos anos, na mesma regra de corte de anos.

## Problema atual

O titulo Desempenho Mensal sugere uma serie de meses, mas o eixo sao anos do mesmo mes. Nao ha referencia de quanto o mes costuma render, so a tendencia ponto a ponto.

## Objetivo da mudanca

Quem abre a visao geral num mes sabe que esta comparando aquele mes entre os anos e ve, de relance, se o ano atual esta acima ou abaixo da media do mes.

## Escopo inicial percebido

Troca de texto no titulo do card e uma linha de referencia no grafico de tendencia. A media sai de `sameMonthRevenueByYear`, que ja vem filtrado pelos anos com receita (`revenueYears` no backend). Sem endpoint, contrato ou schema novo.

## Itens incluidos neste request

- titulo do card com mes selecionado: `<Mes por extenso> ao longo dos anos`, com inicial maiuscula
- titulo com `Anual`: continua `Desempenho Anual`
- linha horizontal tracejada na media da receita dos anos do eixo, em cor distinta da barra e da tendencia
- rotulo da linha com a media compacta (ex.: `Média 9,6 mil`), no padrao de `performanceLabel`
- item `Média` na legenda do rodape do grafico e na lista `sr-only`

## Requisitos implicitos ja visiveis

- media = soma da receita dos pontos de `sameMonthRevenueByYear` / quantidade de pontos
- os anos da media sao exatamente os anos do eixo, inclusive os que estao em zero no mes
- a linha de Tendencia continua como esta
- o eixo Y continua cobrindo a media (ela nunca passa do maior valor)
- o nome do mes vem do mes selecionado, nao de valor fixo

## Casos de erro e borda ja percebidos

- lista vazia: continua `Sem anos com registro`, sem linha de media
- um ano so: a media e o valor desse ano
- todos os anos em zero no mes: linha em zero, sem rotulo
- ano futuro com receita em outro mes e zero no mes selecionado (2027 no print): entra na media e puxa o valor para baixo
- `month=all` ou serie `null`: sem media, desenho atual
- tela estreita: o grafico continua oculto abaixo de `lg`, como hoje

## Dependencias

- `sameMonthRevenueByYear` ja vem com os anos com receita (request [desempenho-mensal-anos-com-receita](desempenho-mensal-anos-com-receita-request.md))
- `VenuePerformanceSeries` ja tem o `variant="trend"` com barra e linha

## Restricoes e cuidados

- nao mudar backend nem a regra de anos
- nao alterar o Desempenho Anual nem os graficos dos relatorios
- nao copiar valores do print como dado fixo
- reaproveitar `performanceLabel` e `money` para os rotulos

## Perguntas em aberto

- O titulo fica `Novembro ao longo dos anos` ou `Desempenho de novembro`? Premissa: `Novembro ao longo dos anos`, que diz que o eixo sao anos.
- O ano futuro em zero no mes (2027 no print) entra na media? Premissa: sim, mesma regra de corte do eixo; corta-lo seria outra regra.
- A linha de Tendencia continua junto com a media? Premissa: sim; a media e uma linha a mais.

## Prioridade sugerida

Media. O grafico funciona; o ganho e leitura do titulo e referencia de comparacao.

## Faixa sugerida para task workflow

- `A` — texto de um titulo e uma linha de referencia calculada no front, sem contrato novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so o frontend, dados que a tela ja recebe

## Sugestao de slug da spec

- `framework_core/specs/titulo-mes-e-media-desempenho-mensal/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `titulo-mes-e-media-desempenho-mensal-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: `performanceTitle` e `averageRevenue` em `VenuePerformanceSeries.tsx`; `ReferenceLine` tracejada com `Média` na legenda e no `sr-only`; titulo do card em `VenueDashboard.tsx`; vitest 9 em `VenuePerformanceSeries.test.tsx` e 183 na suite; eslint sem erro nos arquivos tocados; browser parado no login
- derivacao repo-local: `nao se aplica`
