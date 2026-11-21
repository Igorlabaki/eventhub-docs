# Solicitacao da Tarefa

## Nome sugerido da tarefa

Linha da media no Desempenho Anual

## Resumo da solicitacao

Com `Anual` selecionado na visao geral, o grafico Desempenho Anual ganha a mesma linha horizontal tracejada de media que o grafico do mes ao longo dos anos ja tem, agora com a media da receita dos meses do ano.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: a media aparecer tambem no grafico de barra unica (fallback do mes sem `sameMonthRevenueByYear`), ou usar meses diferentes dos que estao no eixo
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: backend, linha de Meta, linha de Tendencia, titulo dos cards, grafico do mes ao longo dos anos, graficos dos relatorios, cards de KPI, seletor de mes e ano
- prova minima desta execucao: em `/venue/:id` com `Anual` selecionado, uma linha tracejada marca a media das 12 barras do eixo, com rotulo compacto (ex.: `Média 16,9 mil`) que nao cobre o rotulo de nenhuma barra; `Média` aparece na legenda e no `sr-only`; ao trocar o ano, a media acompanha; com um mes selecionado e serie `null`, a barra unica continua sem media
- criterio de escalada: permanece `smart`; sobe para `normal` se a regra dos meses da media precisar de dado novo do backend
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenuePerformanceSeries.tsx` em `averageRevenue`, `annualPerformancePoints` e no calculo de `average` dentro de `VenuePerformanceSeries`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenuePerformanceChart.tsx` (ramo `selectedMonth === "all"`); `eventhub-vista-dashboard/src/components/venue/VenuePerformanceChartAllMonths.tsx`; `eventhub-vista-dashboard/src/components/venue/VenuePerformanceSeries.test.tsx`
- palavras-chave ou simbolos de busca: `averageRevenue`, `annualPerformancePoints`, `variant === "trend"`, `ReferenceLine`, `insideTopRight`, `Média`
- testes provaveis: anual com media dos 12 meses (meses em zero entram); anual com todos os meses em zero sem rotulo; `Média` na legenda e no `sr-only` do anual; barra unica do mes continua sem `Média`; grafico do mes ao longo dos anos continua com a media atual
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com print da visao geral em `Anual` (2026): o card Desempenho Anual mostra jan. a dez. com receita e a linha de Meta, mas nao tem media. O usuario quer a media do ano assim como o grafico do mes ao longo dos anos ja tem a media entre os anos.

## Problema atual

O Desempenho Anual nao da uma referencia de quanto o espaco fatura num mes tipico do ano; so da para comparar cada mes com a Meta.

## Objetivo da mudanca

Quem abre a visao geral em `Anual` ve, de relance, quais meses ficaram acima ou abaixo da media mensal daquele ano.

## Escopo inicial percebido

Ligar no Desempenho Anual a linha de media que ja existe para o grafico do mes ao longo dos anos. A media sai dos pontos de `annualPerformancePoints`, que a tela ja recebe. Sem endpoint, contrato ou schema novo.

## Itens incluidos neste request

- linha horizontal tracejada na media da receita dos 12 meses do eixo, no mesmo estilo da media do mensal
- rotulo compacto `Média <valor>` no padrao de `performanceLabel`, posicionado sem cobrir rotulos de barra
- item `Média` na legenda do rodape do grafico e na lista `sr-only`
- vale para os dois lugares que desenham o anual: `VenuePerformanceChart` com `selectedMonth === "all"` e `VenuePerformanceChartAllMonths`

## Requisitos implicitos ja visiveis

- media = soma da receita dos 12 pontos de `annualPerformancePoints` / 12
- meses em zero (ex.: julho no print) e meses futuros entram na conta, mesma regra do mensal, que conta os anos zerados do eixo
- a linha de Meta continua como esta
- o eixo Y continua cobrindo a media
- a barra unica do mes (fallback sem `sameMonthRevenueByYear`) continua sem media
- a media do grafico do mes ao longo dos anos nao muda

## Casos de erro e borda ja percebidos

- todos os meses em zero: linha em zero, sem rotulo
- rotulo da media perto da barra mais alta da direita (dez. no print): nao pode sobrepor o rotulo da barra
- media muito proxima da Meta: as duas linhas continuam distinguiveis pela cor e pelo tracejado
- tela estreita: o grafico continua oculto abaixo de `lg`, como hoje

## Dependencias

- `averageRevenue` e a `ReferenceLine` de media ja existem em `VenuePerformanceSeries` (request [titulo-mes-e-media-desempenho-mensal](titulo-mes-e-media-desempenho-mensal-request.md))

## Restricoes e cuidados

- muda conscientemente a regra do request anterior, que dizia que o Anual ficava sem linha de media
- nao alterar backend nem os graficos dos relatorios
- nao copiar valores do print como dado fixo
- reaproveitar `averageRevenue`, `performanceLabel` e `money`

## Perguntas em aberto

- Quais meses entram na media? Premissa: os 12 do eixo, inclusive os zerados e os futuros (cerca de 16,9 mil no print); a alternativa, so meses com receita, daria cerca de 18,4 mil e seria outra regra.
- O rotulo fica a direita, como no mensal? Premissa: no anual fica a esquerda (`insideTopLeft`), onde as barras costumam ser mais baixas; no mensal continua a direita.

## Prioridade sugerida

Media. O grafico funciona; o ganho e uma referencia de comparacao.

## Faixa sugerida para task workflow

- `A` — uma linha de referencia ja existente ligada em outro grafico, calculada no front, sem contrato novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so o frontend, dados que a tela ja recebe

## Sugestao de slug da spec

- `framework_core/specs/media-desempenho-anual/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `media-desempenho-anual-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
- entrega: prop `showAverage` em `VenuePerformanceSeries` (default so no `trend`), ligada em `VenuePerformanceChart` com `all` e em `VenuePerformanceChartAllMonths`; a pedido do usuario, o valor saiu do canto do grafico e foi para a legenda (`Média <valor>`), no anual e no mensal; vitest 10 em `VenuePerformanceSeries.test.tsx` e 188 na suite; eslint sem erro nos arquivos tocados (so avisos antigos de fast refresh); browser parado no login
