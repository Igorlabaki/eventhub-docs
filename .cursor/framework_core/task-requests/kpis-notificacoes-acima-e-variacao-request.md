# Solicitacao da Tarefa

## Nome sugerido da tarefa

KPIs das notificacoes acima do filtro e com variacao sobre o periodo anterior

## Resumo da solicitacao

Na lista de notificacoes do espaco, os quatro cards de KPI sobem para cima do bloco de filtros. Os cards de periodo (`Últimos 7 dias`, `Últimos 30 dias` e `Orçamentos novos`) passam a mostrar a variacao em % contra a janela imediatamente anterior de mesmo tamanho.

## Context Pack

- frente principal: frontend, com um acrescimo pequeno no contrato do backend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: a janela anterior se sobrepor a atual (contar o mesmo dia duas vezes) ou ignorar os filtros ativos que os cards ja respeitam
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: renomear os cards, mudar a regra de `Não lidas`, a lista, a paginacao, o botao `Marcar todas como lidas`, schema e migration
- prova minima desta execucao: em `/venue/:id/notifications` os cards aparecem acima da busca; cada card de periodo mostra `+N%`, `-N%` ou `—`; com Tipo = Orçamento, `Últimos 30 dias` e `Orçamentos novos` mostram o mesmo numero e a mesma %; vitest do `summarize` com as janelas anteriores e do card com os tres estados
- criterio de escalada: permanece `normal`; sobe para `spec` se a variacao precisar de outra base (ex.: mesmo periodo do ano anterior) ou de indice novo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/repositories/in-prisma/notification-in-prisma-repository.ts` em `notificationSummaryWheres` e `summarize`; `eventhub-vista-dashboard/src/components/notification/notification-list-summary.tsx`; `eventhub-vista-dashboard/src/pages/VenueNotifications.tsx` no `return`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/specs/2026-11-05-lista-notificacoes-painel/00-overview.md#Objetivo rapido`
- caminhos candidatos: `art56_server_v3/src/repositories/interface/notification-repository-interface.ts`; `art56_server_v3/src/use-cases/notification/list-notification/use-case-list-notification.ts` e `.spec.ts`; `eventhub-vista-dashboard/src/types/notification.ts`; `eventhub-vista-dashboard/src/components/ui/yearly-change.tsx`; `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.tsx` como modelo de card com variacao
- palavras-chave ou simbolos de busca: `NotificationListSummary`, `notificationSummaryWheres`, `summarize`, `newProposals`, `last7Days`, `last30Days`, `YearlyChange`, `yearlyChange`, `NotificationListSummaryCards`
- testes provaveis: janela anterior de 7 dias = [agora-14d, agora-7d); de 30 dias = [agora-60d, agora-30d); anterior zero vira `null`; filtros ativos aplicados nas janelas anteriores; Tipo diferente de Orçamento zera atual e anterior de `Orçamentos novos`; card mostra `+`, `-`, `0%` e `—`; `Não lidas` sem variacao
- nao ler por padrao: `security`, `database`, `topics/`, schema Prisma

## Contexto informado na entrada

Pedido em chat, com print de Notificacoes do AR756: filtro (busca, Tipo, Leitura, Marcar todas como lidas) acima dos cards `Não lidas` 16, `Últimos 7 dias` 111, `Últimos 30 dias` 306 e `Orçamentos novos` 282. O usuario quer os KPIs em cima, o filtro embaixo, e a % de cada KPI em relacao ao periodo dele. Na mesma conversa ficou explicado que `Orçamentos novos` = notificacoes `PROPOSAL` dos ultimos 30 dias, por isso difere de `Últimos 30 dias` (todas as notificacoes).

## Problema atual

Os cards ficam abaixo do filtro, ao contrario das outras listas do painel. Os numeros de periodo nao dizem se o volume subiu ou caiu, e o resumo do backend nao conta nenhuma janela anterior.

## Objetivo da mudanca

Quem abre Notificacoes ve primeiro os KPIs e sabe, por card de periodo, quanto o volume variou em % contra a janela anterior de mesmo tamanho.

## Escopo inicial percebido

Troca de ordem na pagina e tres contagens a mais no `summarize`, com a % calculada no backend, como ja acontece com `yearlyChange` na visao geral. Sem endpoint, schema ou indice novo.

## Itens incluidos neste request

- `NotificationListSummaryCards` acima do bloco de filtros em `VenueNotifications.tsx`; contador `N notificações` continua acima da lista
- backend: janelas anteriores para `last7Days` (14 a 7 dias atras), `last30Days` (60 a 30 dias atras) e `newProposals` (`PROPOSAL`, 60 a 30 dias atras), na mesma base de filtros
- contrato: `summary.change = { last7Days, last30Days, newProposals }`, cada um `number | null` (% inteira arredondada; `null` quando a janela anterior e zero)
- frontend: tipo atualizado e a % no canto de cada card de periodo, no padrao visual de `YearlyChange`, com texto acessivel falando de periodo anterior (nao de ano anterior)

## Requisitos implicitos ja visiveis

- % = round((atual - anterior) / anterior * 100)
- janelas anteriores com limite inferior inclusivo e superior exclusivo, sem sobrepor a janela atual
- busca, Tipo e Leitura valem para as janelas anteriores como valem para as atuais
- `Não lidas` continua sem variacao
- carregamento e erro dos cards seguem como hoje

## Casos de erro e borda ja percebidos

- janela anterior zero e atual positiva: `—`, nunca `Infinity`
- atual e anterior zero: `—`
- atual igual a anterior: `0%` neutro
- Tipo diferente de Orçamento: `Orçamentos novos` com 0 e `—`
- backend antigo sem `change`: cards sem a %, sem quebrar
- espaco novo com menos de 14 ou 60 dias de historico: anterior zero, `—`

## Dependencias

- spec [lista-notificacoes-painel](../specs/2026-11-05-lista-notificacoes-painel/00-overview.md): o `summary` do `GET /notification/list/:venueId` ja existe
- `YearlyChange` em `components/ui/yearly-change.tsx`, hoje com texto fixo de ano anterior

## Restricoes e cuidados

- nao mudar a regra das contagens atuais
- nao alterar `YearlyChange` de um jeito que mude o texto da visao geral e dos orcamentos
- contagens em paralelo, como ja e feito no `summarize`
- reaproveitar o `where` base de `notificationListWhere`

## Perguntas em aberto

- A % e calculada no backend ou no front? Premissa: no backend, como `yearlyChange`.
- `Orçamentos novos` tambem ganha %? Premissa: sim, contra os 30 dias anteriores.
- Renomear `Orçamentos novos` para deixar claro que conta notificacoes de 30 dias? Premissa: nao nesta task; o pedido foi so entender o card.
- Como reaproveitar `YearlyChange` com outro texto? Premissa: prop opcional com o texto da base, default ano anterior.

## Prioridade sugerida

Media. A lista funciona; o ganho e ordem de leitura e contexto dos numeros.

## Faixa sugerida para task workflow

- `B` — dois repos e um campo novo no contrato, sem schema nem fluxo novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, contrato ja existente com acrescimo pequeno, ordem de execucao obvia (backend e depois front)

## Sugestao de slug da spec

- `framework_core/specs/kpis-notificacoes-acima-e-variacao/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `kpis-notificacoes-acima-e-variacao-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- status: codigo escrito em 2026-11-09; vitest dos dois repos e build do front verdes; prova no browser pendente
- proximo passo: `review` (L2) e prova em `/venue/:id/notifications` com o backend novo
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: opcional com `tasking/task-request-repo-split-prompt.md` (backend antes do frontend)
