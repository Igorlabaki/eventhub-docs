# Solicitacao da Tarefa

## Nome sugerido da tarefa

Bolinha vermelha de nao lidas no item Notificacoes da sidebar

## Resumo da solicitacao

Quando o espaco tem notificacoes ainda nao lidas, o item Notificacoes da sidebar do espaco mostra uma bolinha vermelha com esse numero dentro. Sem nao lidas, a bolinha nao aparece.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: a bolinha acompanhar o filtro da pagina de notificacoes e zerar quando a pessoa filtra so as lidas, ou aparecer em sidebar de orcamento e de organizacao
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: marcar como lida so por abrir a pagina, mudar os cards de KPI, criar endpoint ou schema, e colocar badge em outro item da sidebar
- prova minima desta execucao: na sidebar do espaco, com nao lidas, o item Notificacoes mostra a bolinha vermelha com o mesmo numero do card Nao lidas sem filtro; com zero, a bolinha some; a sidebar recolhida continua mostrando a bolinha no sino; filtrar a lista por lidas nao zera a bolinha; vitest do item com 0, com N e recolhido
- criterio de escalada: permanece `smart`; sobe para `spec` se a contagem exigir endpoint novo, tempo real ou badge em mais de um nivel da sidebar
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenueNav.tsx`; `eventhub-vista-dashboard/src/components/sidebar/SectionedNav.tsx` em `NavItemLink`; `eventhub-vista-dashboard/src/hooks/notification/queries/list.ts`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/specs/2026-11-05-lista-notificacoes-painel/00-overview.md#Objetivo rapido`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/sidebar/sidebar-nav-model.ts` no item `Notificações`; `eventhub-vista-dashboard/src/types/notification.ts` em `NotificationListSummary.unread`; `eventhub-vista-dashboard/src/services/notification.service.ts`; `eventhub-vista-dashboard/src/pages/VenueNotifications.tsx` na invalidacao `["notifications", venueId]`
- palavras-chave ou simbolos de busca: `Notificações`, `summary.unread`, `useGetNotificationsList`, `NavItemLink`, `VIEW_VENUE_NOTIFICATIONS`, `markAllRead`
- testes provaveis: zero esconde a bolinha; N mostra o numero; sidebar recolhida mostra a bolinha no sino; a contagem nao usa busca, tipo nem filtro de leitura da pagina
- nao ler por padrao: `security`, `database`, `topics/`, schema Prisma, `art56_server_v3/`

## Contexto informado na entrada

Pedido em chat, com print de Notificacoes do Goncalos Hub: card Nao lidas em 0, Ultimos 7 dias em 48 e 4940 notificacoes no total. O usuario quer, na sidebar, uma bolinha vermelha com o numero de notificacoes que ainda nao foram lidas.

Na mesma conversa ficou confirmado no codigo que o item so existe na sidebar do espaco, que `summary.unread` ja e o total nao lido do espaco e que esse total, na listagem, respeita busca, tipo e filtro de leitura.

## Problema atual

A sidebar nao avisa que existem nao lidas. O numero so aparece depois de abrir Notificacoes, no card Nao lidas. Ultimos 7 dias e o total da lista sao outros numeros.

## Objetivo da mudanca

Quem esta em qualquer tela do espaco ve, no item Notificacoes da sidebar, quantas notificacoes ainda nao foram lidas, e deixa de ver a bolinha quando esse numero chega a zero.

## Escopo inicial percebido

Mudanca visual no item Notificacoes da sidebar do espaco, lendo o `summary.unread` que o `GET /notification/list/:venueId` ja devolve. Sem endpoint, schema ou regra nova de leitura.

## Itens incluidos neste request

- bolinha vermelha com o numero de nao lidas no item Notificacoes da sidebar do espaco
- o numero e o total nao lido do espaco, o mesmo do card Nao lidas quando a lista esta sem filtro
- a bolinha some quando o total e zero
- a bolinha aparece com a sidebar aberta e com a sidebar recolhida
- a contagem atualiza quando as nao lidas ja sao invalidadas hoje (marcar todas como lidas e abrir o orcamento da notificacao)

## Requisitos implicitos ja visiveis

- so para quem ja ve o item, permissao `VIEW_VENUE_NOTIFICATIONS`
- a contagem da bolinha nao segue busca, tipo nem filtro de leitura da pagina de notificacoes
- abrir a pagina de notificacoes nao marca nada como lida
- sidebar de orcamento e de organizacao ficam como estao

## Casos de erro e borda ja percebidos

- zero nao lidas: sem bolinha
- numero alto: a bolinha nao pode estourar a linha da sidebar
- lista filtrada em "lidas": a bolinha continua com o total nao lido do espaco
- consulta da contagem falha: o item Notificacoes continua clicavel, sem bolinha
- sidebar recolhida: o texto do item some e a bolinha fica no sino

## Dependencias

- spec [lista-notificacoes-painel](../specs/2026-11-05-lista-notificacoes-painel/00-overview.md): o `summary.unread` do `GET /notification/list/:venueId` ja existe
- request [kpis-notificacoes-acima-e-variacao](kpis-notificacoes-acima-e-variacao-request.md) mexe nos cards da pagina e nao bloqueia esta bolinha

## Restricoes e cuidados

- nao criar endpoint so para a contagem
- nao reaproveitar a consulta filtrada da pagina de notificacoes
- nao alterar o que marca uma notificacao como lida
- nao colocar badge em Visao Geral, Orcamentos nem nos outros itens

## Perguntas em aberto

- A partir de qual numero a bolinha abrevia? Premissa: ate 99 o numero inteiro; de 100 em diante, `99+`.
- A bolinha precisa de atualizacao propria alem da invalidacao que ja existe? Premissa: nao; sem polling novo.
- Onde a bolinha fica com a sidebar aberta? Premissa: a direita do texto Notificacoes; recolhida, sobre o sino.

## Prioridade sugerida

Media. A lista ja mostra o numero; o ganho e ver as nao lidas sem abrir a pagina.

## Faixa sugerida para task workflow

- `A` — um objetivo, so no frontend, contrato ja existente
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um item de interface, um numero que a API ja devolve, sem fluxo, schema nem contrato novo

## Sugestao de slug da spec

- `framework_core/specs/bolinha-nao-lidas-sidebar/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `bolinha-nao-lidas-sidebar-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- status: codigo escrito; vitest 18 na sidebar; browser parado no login
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
