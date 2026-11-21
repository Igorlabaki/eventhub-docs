# Solicitacao da Tarefa

## Nome sugerido da tarefa

Grafico de rosca com a distribuicao por categoria do evento nos relatorios

## Resumo da solicitacao

Nas abas `Orçamentos` e `Evento` de `/venue/:id/reports`, um card novo mostra em grafico de rosca como as propostas do ano se distribuem entre as categorias do evento (Empresarial / confraternização, Aniversário, Despedida de solteiro, Casamento, Coffee break, Outro), com uma fatia `Sem categoria` para o que nao tem categoria.

## Context Pack

- frente principal: frontend, com um acrescimo pequeno no contrato do backend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: o total da rosca nao bater com o total da aba (orcamentos do ano em `Orçamentos`, aprovados em `Evento`), ou o filtro de ano repetir o bug do `trafficCount` (`lt: new Date(year, 12, 31)` = 31/01 do ano seguinte)
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: receita por categoria, aba `Financeiro`, visao geral do espaco, filtro por categoria nas listas, classificar propostas antigas, schema e migration
- prova minima desta execucao: em `/venue/:id/reports`, aba `Orçamentos`, a rosca mostra as categorias com quantidade e % e a soma das fatias e igual ao total de orcamentos do ano; na aba `Evento`, a soma e igual ao total de eventos aprovados; propostas sem categoria aparecem em `Sem categoria`; ano sem propostas mostra estado vazio; vitest do agrupamento no backend e do modelo/card no front
- criterio de escalada: permanece `normal`; sobe para `spec` se pedirem receita por categoria, comparacao com o ano anterior ou filtro por categoria nas outras telas
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts` em `trafficCount`; `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx` em `LeadBars` e `ReportsChartCard`; `eventhub-vista-dashboard/src/components/reports/report-metrics.ts` em `TRAFFIC_SOURCES` e `buildReportModel`
- libs obrigatorias: `react`, `node`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/node/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/specs/2026-11-09-categoria-do-evento-na-proposta/00-overview.md#Objetivo rapido`
- caminhos candidatos: `art56_server_v3/src/use-cases/venue/get-traffic-count-venue/use-case-get-traffic-count-venue.ts`; `art56_server_v3/src/repositories/interface/proposal-repository-interface.ts`; `art56_server_v3/src/functions/event-category.ts`; `eventhub-vista-dashboard/src/components/reports/BudgetsReport.tsx`; `eventhub-vista-dashboard/src/components/reports/EventsReport.tsx`; `eventhub-vista-dashboard/src/store/venueReportsStore.ts`; `eventhub-vista-dashboard/src/types/venue.ts`; `eventhub-vista-dashboard/src/lib/event-category.ts`
- palavras-chave ou simbolos de busca: `trafficCount`, `TrafegoCountResponse`, `TrafficData`, `sortedSources`, `eventCategory`, `EVENT_CATEGORY_OPTIONS`, `EVENT_CATEGORIES`, `LeadBars`, `buildReportModel`
- testes provaveis: agrupamento devolve uma entrada por categoria, inclusive as com zero; `null` vira `Sem categoria`; `approved` filtra so aprovados; ano usa `[1/1 do ano, 1/1 do ano seguinte)`; percentuais somam 100 com arredondamento; total zero gera estado vazio; card renderiza fatias e legenda
- nao ler por padrao: `security`, `database`, `topics/`, schema Prisma alem do enum `EventCategory`

## Contexto informado na entrada

Pedido em chat depois da entrega da categoria do evento na proposta. O usuario quer, em relatorios, um grafico de rosca com a distribuicao de orcamentos e de eventos entre as categorias (empresarial / confraternização, aniversário, despedida etc.). Escolhas feitas na conversa: so quantidade, sem receita; nas duas abas, `Orçamentos` e `Evento`; formato rosca com legenda; propostas sem categoria aparecem como fatia `Sem categoria`.

## Problema atual

A categoria do evento ja e gravada em `proposal.eventCategory`, mas nenhum relatorio a usa. Nao da para saber que tipo de evento o espaco mais orca ou mais fecha.

## Objetivo da mudanca

Quem abre `Orçamentos` ou `Evento` nos relatorios ve, para o ano selecionado, quantos orcamentos ou eventos caem em cada categoria e o % de cada uma, numa rosca cuja soma bate com o total da aba.

## Escopo inicial percebido

O backend passa a devolver a contagem por `eventCategory` com o mesmo filtro de espaco, ano e `approved` que a origem dos leads ja usa; o caminho mais curto e um campo novo na resposta do traffic count, que as duas abas ja buscam. O front monta o modelo da rosca em `report-metrics.ts` e desenha um card novo no `ReportsChartCard`, ao lado da origem dos leads.

## Itens incluidos neste request

- contagem por categoria no backend, com `null` agrupado como `Sem categoria`
- filtro de ano correto (`lt` no 1/1 do ano seguinte) na consulta nova
- card `Categorias dos eventos` com rosca, total no centro, legenda com cor, nome, quantidade e %, ordenada da maior para a menor
- mesmo card nas abas `Orçamentos` (todas as propostas do ano) e `Evento` (so aprovadas)
- estado vazio quando o ano nao tem propostas

## Requisitos implicitos ja visiveis

- rotulos das categorias vem de `EVENT_CATEGORY_OPTIONS`, sem duplicar texto
- cores fixas por categoria; `Sem categoria` em cinza
- tooltip no formato `Aniversário: 31 (24%)`
- lista acessivel (`sr-only`) com os valores, como o grafico mensal ja faz
- seguir o desenho dos cards atuais (`rounded-2xl border bg-white p-5 shadow-sm`, icone a esquerda do titulo)
- `recharts` ja e dependencia; nao adicionar biblioteca

## Casos de erro e borda ja percebidos

- anos anteriores a 09/11/2026: quase tudo cai em `Sem categoria`, porque a coluna e nova
- propostas de tipo diferente de `EVENT` (pernoite, producao, permuta, outro) nao tem categoria e entram em `Sem categoria`
- categoria com zero no ano: fica fora da rosca e da legenda
- uma unica categoria com 100%: rosca cheia, sem quebrar o rotulo
- ano sem nenhuma proposta: estado vazio, sem rosca
- valor de categoria desconhecido vindo do banco: tratado como `Outro` ou ignorado, sem quebrar o card

## Dependencias

- coluna `eventCategory` ja no `main` (deploy request #44 da spec `2026-11-09-categoria-do-evento-na-proposta`)
- traffic count ja chamado com `approved` certo em `BudgetsReport` e `EventsReport`

## Restricoes e cuidados

- nao criar coluna nem migration
- nao mudar o significado dos campos atuais do traffic count; so acrescentar
- nao escrever no banco de producao para classificar propostas antigas
- nao mudar `LeadBars`, KPIs nem o grafico mensal

## Perguntas em aberto

- A rosca conta todas as propostas do ano ou so as do tipo `EVENT`? Premissa: todas, para a soma bater com o total da aba; tipos sem categoria vao para `Sem categoria`.
- Corrigir o mesmo bug de ano no `trafficCount` existente? Premissa: sim, na mesma entrega, porque a origem dos leads e a rosca precisam do mesmo recorte.
- Esconder `Sem categoria` quando ela passar de certo %? Premissa: nao; sempre aparece.

## Prioridade sugerida

Media. A categoria acabou de entrar e o relatorio e o primeiro lugar onde ela gera leitura de negocio.

## Faixa sugerida para task workflow

- `B` — dois repositorios, acrescimo pequeno de contrato, componente novo no front
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, contrato so ganha um campo, sem migration

## Sugestao de slug da spec

- `framework_core/specs/distribuicao-categorias-relatorios/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `distribuicao-categorias-relatorios-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar entrega`
- entrega: `trafficCount` devolve `categories` (todas as categorias e `null`, via `eventCategoryCounts`) no mesmo filtro da origem dos leads; `reportYearRange` corrige o fim do ano em `trafficCount` e tambem em `analysisByMonth` (o total da aba contava janeiro do ano seguinte e a rosca nao bateria); card `Categorias dos eventos` com rosca, total no centro e legenda no `ReportsChartCard`, nas abas `Orçamentos` e `Evento`; vitest back 346 e front 227; build do front ok; `prisma validate` ok; `tsc` sem erro nos arquivos tocados; browser parado no login
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:task`
- derivacao repo-local: pode ser dividido com `tasking/task-request-repo-split-prompt.md` em backend (contagem) e frontend (card), se a execucao for por repo
