# Solicitacao da Tarefa

## Nome sugerido da tarefa

Graficos da visao geral no estilo dos relatorios

## Resumo da solicitacao

Os graficos Desempenho Mensal e Desempenho Anual da visao geral do espaco passam a usar o mesmo desenho dos graficos de Orcamentos, Evento e Financeiro: barra em degradê, linha da segunda serie, rotulo compacto, grade horizontal e meses abreviados.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: alterar a receita ou a meta que o grafico ja mostra, ou redesenhar os relatorios que servem de modelo
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: abas de relatorio, cards de KPI, proximo evento, proxima visita, seletor de mes e ano, API e cadastro de meta
- prova minima desta execucao: em `/venue/:id`, no mes, uma barra de receita e um ponto de meta no desenho dos relatorios; no ano, as doze barras e a linha da meta no mesmo desenho; tooltip com o valor em real; Orcamentos, Evento e Financeiro iguais ao que estao
- criterio de escalada: permanece `smart`; sobe para `spec` se a serie da meta exigir contrato ou calculo novo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx` no bloco Desempenho Mensal e Desempenho Anual
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenuePerformanceChart.tsx`; `eventhub-vista-dashboard/src/components/venue/VenuePerformanceChartAllMonths.tsx`; `eventhub-vista-dashboard/src/components/reports/FinancialReportCard.tsx`; `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx`
- palavras-chave ou simbolos de busca: `VenuePerformanceChart`, `VenuePerformanceChartAllMonths`, `Desempenho Mensal`, `Desempenho Anual`, `Receita`, `Meta`
- testes provaveis: mes com receita e meta; ano com os doze meses; mes sem meta; receita zero; rotulo que nao estoura a barra vizinha
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com quatro prints. Os dois primeiros sao a visao geral: no mes, duas barras solidas de receita e meta; no ano, barras azuis de receita e linha roxa de meta, com o valor completo em cima de cada barra. Os dois seguintes sao o modelo: Orcamentos por mes e Receita x despesa, com barra em degradê, linha, ponto vazado, rotulo curto e meses abreviados.

## Problema atual

Desempenho Mensal e Desempenho Anual usam outro desenho. No anual, o valor em real completo se sobrepoe entre as barras.

## Objetivo da mudanca

Quem abre a visao geral ve receita e meta no mesmo grafico de Orcamentos, Evento e Financeiro, no mes e no ano.

## Escopo inicial percebido

Troca visual de dois graficos que a visao geral ja renderiza. Receita e meta continuam as que a tela ja carrega. Sem rota, contrato ou schema novo.

## Itens incluidos neste request

No mes e no ano: receita como barra em degradê e meta como linha com ponto vazado. Rotulo compacto sobre a receita. Grade so horizontal, sem eixo marcado. Meses abreviados como nos relatorios. Legenda de receita e meta no rodape do grafico. Tooltip com o valor em real.

## Requisitos implicitos ja visiveis

- os numeros continuam os da visao geral; o print nao e valor fixo
- a meta continua a meta do mes ja usada no grafico
- o mes unico mostra uma barra e o ponto da meta; o ano mostra os doze meses
- o rotulo curto evita a sobreposicao do valor completo
- Orcamentos, Evento e Financeiro nao mudam de desenho

## Casos de erro e borda ja percebidos

- mes sem meta cadastrada: a linha fica em zero e o grafico nao inventa meta
- receita zero: a barra nao aparece com rotulo e o eixo nao quebra
- valor alto ao lado de valor baixo: o rotulo compacto nao cobre a barra vizinha
- troca de mes e de ano: o grafico acompanha o periodo ja escolhido na visao geral
- tela estreita: o grafico da visao geral continua oculto abaixo de `lg`, como hoje

## Dependencias

- a visao geral ja carrega a receita do periodo e as metas do espaco
- Orcamentos, Evento e Financeiro ja entregam o desenho de barra, linha, rotulo e meses abreviados

## Restricoes e cuidados

- nao alterar os graficos das abas de relatorio
- nao mudar cards, proximo evento, proxima visita nem o seletor de mes e ano
- nao criar endpoint nem recalcular receita ou meta
- nao copiar os valores dos prints como dado fixo

## Perguntas em aberto

- No mes, receita e meta continuam em duas barras ou a meta vira linha, como a despesa no financeiro? Premissa: meta vira linha nos dois modos, no desenho de Receita x despesa.
- O rotulo da barra fica abreviado (`6,9 mil`) ou em real completo? Premissa: abreviado no grafico e real completo no tooltip, como no financeiro.
- O nome do mes no eixo fica abreviado (`nov.`) ou por extenso? Premissa: abreviado, como nos relatorios.

## Prioridade sugerida

Media. A visao geral ja mostra receita e meta; a diferenca e o desenho do grafico.

## Faixa sugerida para task workflow

- `A` — dois graficos de uma tela, copiando um desenho que o frontend ja tem, sem conta nem contrato novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so o frontend, sem contrato novo. Vira spec se a meta do grafico passar a depender de calculo ou endpoint que a visao geral nao tem.

## Sugestao de slug da spec

- `framework_core/specs/graficos-visao-geral-estilo-relatorios/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `graficos-visao-geral-estilo-relatorios-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: Desempenho Mensal e Desempenho Anual com receita em barra degradê e meta em linha; meses abreviados; rotulo compacto; vitest 3 em `VenuePerformanceSeries.test.tsx`; browser parado no login
- derivacao repo-local: `nao se aplica`
