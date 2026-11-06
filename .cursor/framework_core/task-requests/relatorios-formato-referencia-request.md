# Solicitacao da Tarefa

## Nome sugerido da tarefa

Relatorios no formato da referencia

## Resumo da solicitacao

A tela de relatorios do espaco passa a mostrar orcamentos como na referencia: abas e ano no topo, quatro indicadores com variacao anual, grafico mensal em colunas com tendencia, origem dos leads e principais insights. A aba Evento usa o mesmo desenho. A aba Financeiro fica como esta.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: trocar o desenho e perder um numero que a tela ja mostra, ou inventar a variacao contra o ano anterior
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: aba Financeiro, API, schema, lista de orcamentos e visao geral
- prova minima desta execucao: em `/venue/:id/reports`, aba Orcamentos, ver os quatro cards, o grafico mensal em colunas com a linha de tendencia, a origem dos leads e os quatro insights; a aba Evento no mesmo desenho; a aba Financeiro inalterada
- criterio de escalada: permanece `normal`; sobe para `spec` se a variacao anual precisar de contrato novo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueReports.tsx` no bloco das abas, do ano e do relatorio ativo
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx`; `eventhub-vista-dashboard/src/components/reports/ReportsHeader.tsx`; `eventhub-vista-dashboard/src/components/reports/BudgetsReport.tsx`; `eventhub-vista-dashboard/src/components/reports/EventsReport.tsx`; `eventhub-vista-dashboard/src/components/proposal/ProposalListSummaryCards.tsx`
- palavras-chave ou simbolos de busca: `ReportsChartCard`, `ReportsHeader`, `analysisProposalByMonth`, `sortedSources`, `ProposalSparkline`
- testes provaveis: quatro indicadores com os totais ja exibidos; grafico dos doze meses; insights coerentes com o maior mes e o maior canal; Financeiro sem o desenho novo
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com dois prints. O primeiro e o formato desejado da aba Orcamentos. O segundo e a tela atual: barras horizontais de mes, textos soltos de total, media, ticket e conversao, e as origens embaixo. Os numeros dos dois prints sao os mesmos.

## Problema atual

A tela de relatorios mostra o ano em barras horizontais e os indicadores como texto. Nao ha cards, variacao contra o ano anterior, grafico em colunas, linha de tendencia nem bloco de insights.

## Objetivo da mudanca

Quem abre Relatorios ve a aba Orcamentos no formato da referencia, e a aba Evento no mesmo formato.

## Escopo inicial percebido

Rearranjo visual de uma tela, com contas em cima dos dados que o relatorio anual ja devolve. Sem rota, contrato ou schema novo.

## Itens incluidos neste request

Tirar o titulo e o subtitulo da pagina. Deixar as abas a esquerda e o ano numa pilula central. Quatro cards: total, taxa de conversao, ticket medio e pessoas em media, cada um com variacao contra o ano anterior e o tracinho dos meses. Grafico "por mes" em colunas, com o valor em cada ponto, linha de tendencia e troca entre quantidade e taxa de conversao. Abaixo, origem dos leads e principais insights: melhor mes, participacao desse mes, canal principal e canal social lider. A aba Evento repete esse desenho com os rotulos de evento.

## Requisitos implicitos ja visiveis

- os numeros continuam os que a tela ja calcula; a referencia nao e valor fixo
- a variacao anual usa o ano anterior no mesmo relatorio
- a linha de tendencia acompanha a serie mensal exibida
- o canal social lider sai de Instagram, TikTok e Facebook
- a aba Financeiro nao entra nesse desenho

## Casos de erro e borda ja percebidos

- ano anterior sem dado: a variacao nao inventa percentual
- mes ou canal com zero: o insight nao aponta um vazio como destaque
- tela estreita: cards e as duas colunas de baixo quebram a linha
- troca de ano: os cards, o grafico, as origens e os insights acompanham o ano escolhido

## Dependencias

- a tela ja carrega o ano, os meses e as origens
- a lista de orcamentos ja tem o card com variacao e tracinho, como modelo visual

## Restricoes e cuidados

- nao alterar a aba Financeiro
- nao criar endpoint nem coluna para a variacao anual
- nao copiar os numeros do print como dado fixo
- nao mudar a lista de orcamentos nem a visao geral

## Perguntas em aberto

- A aba Evento entra no mesmo formato? Premissa: sim; as duas abas compartilham o mesmo bloco.
- A aba Financeiro muda? Premissa: nao; a referencia so mostra Orcamentos.
- A variacao anual pode usar o relatorio do ano anterior? Premissa: sim; se faltar contrato, escalar para spec em vez de inventar a conta.
- O titulo "Relatorios" sai? Premissa: sim; a referencia nao tem titulo de pagina.

## Prioridade sugerida

Media. O relatorio funciona; a diferenca e o formato da leitura.

## Faixa sugerida para task workflow

- `B` — uma tela, duas abas no mesmo desenho, com variacao anual em cima do relatorio que ja existe
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so o frontend, sem contrato novo. Vira spec se a variacao anual exigir endpoint ou schema.

## Sugestao de slug da spec

- `framework_core/specs/relatorios-formato-referencia/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `relatorios-formato-referencia-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: aba Orcamentos no formato da referencia; aba Evento no mesmo desenho; Financeiro intacto; vitest 6 em `report-metrics.test.ts` e `ReportsChartCard.test.tsx`; browser parado no login
- derivacao repo-local: `nao se aplica`
