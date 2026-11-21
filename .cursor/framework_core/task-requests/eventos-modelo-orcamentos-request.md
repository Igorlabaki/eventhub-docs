# Solicitacao da Tarefa

## Nome sugerido da tarefa

Lista de eventos no modelo da lista de orcamentos

## Resumo da solicitacao

A tela `/venue/events` passa a ter o mesmo desenho e os mesmos recursos da tela de orcamentos: bloco unico de filtros com seletor de mes e ano, busca, filtro de dia e slider de valor minimo, cards de resumo com variacao anual, tabela ordenavel e botao de tentar de novo no erro. Sem filtro de status, link do formulario ou botao de novo orcamento, que so fazem sentido em orcamentos.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`, `patterns` (reaproveitar ou generalizar componentes de `components/proposal/` sem quebrar orcamentos)
- risco principal: generalizar `ProposalTable` ou `ProposalListSummaryCards` e mudar a tela de orcamentos; perder a regra `VIEW_AMOUNTS` que hoje esconde o valor em eventos
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: backend e contrato de `listProposals`; tela de orcamentos (so pode mudar por props com default igual ao atual); detalhe do evento (`EventDetails`, `EventSidebar`); criacao de evento ou orcamento
- prova minima desta execucao: em `/venue/events` com novembro de 2026 no AR756, a tela tem o mesmo bloco de filtros de orcamentos (sem Status e sem os botoes de orcamento), cards de resumo com total de eventos e valor no mes, tabela com ordenacao por data e valor; trocar dia ou slider muda a lista e a contagem; `/venue/budgets` continua igual; vitest e eslint verdes nos arquivos tocados
- criterio de escalada: permanece `normal`; sobe para `spec` se o resumo de eventos precisar de numero novo vindo do backend
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx` em `renderProposalList` e `proposalQuery`; `eventhub-vista-dashboard/src/pages/VenueEvents.tsx` inteiro; `eventhub-vista-dashboard/src/store/proposalStore.ts` em `fetchEvents` e `fetchProposals`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/ProposalTable.tsx`; `eventhub-vista-dashboard/src/components/proposal/ProposalListSummaryCards.tsx`; `eventhub-vista-dashboard/src/components/proposal/MonthYearNavigator.tsx`; `eventhub-vista-dashboard/src/components/events/EventTable.tsx`; `eventhub-vista-dashboard/src/components/events/EventMonthYearNavigator.tsx`; `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.ts` so para leitura
- palavras-chave ou simbolos de busca: `fetchEvents`, `eventListPagination`, `proposalListSummary`, `approved: true`, `VIEW_AMOUNTS`, `summarizeWindow`, `amountMax`, `conversionRate`, `ProposalListPager`
- testes provaveis: eventos pede `summary`, `day`, `sortBy`, `sortDir` e `minAmount`; store guarda e limpa o resumo de eventos; tabela sem `VIEW_AMOUNTS` sem coluna Valor; cards de eventos sem Conversao; orcamentos com os mesmos textos e colunas de antes
- nao ler por padrao: `security`, `database`, `topics/`, schema e repositorios do backend

## Contexto informado na entrada

Pedido em chat, com print de `/venue/events` em novembro de 2026: seletor de mes solto, busca, contagem `2 eventos` e tabela simples com Cliente, Data e Valor. Pedido: "Eventos deve seguir o modelo de orcamentos".

## Problema atual

A lista de eventos ficou para tras da lista de orcamentos: nao tem o bloco de filtros, filtro de dia, filtro de valor, resumo do mes, ordenacao nem como tentar de novo quando a busca falha. As duas telas listam a mesma entidade com desenhos diferentes.

## Objetivo da mudanca

Quem abre Eventos encontra o mesmo desenho e os mesmos filtros de Orcamentos, aplicados so a propostas fechadas.

## Escopo inicial percebido

So frontend. `fetchEvents` ja chama `listProposals` com `approved: true`, e o endpoint ja aceita `day`, `sortBy`, `sortDir`, `minAmount` e `summary`. A mudanca e montar `VenueEvents` no molde de `VenueBudgets`, guardar o resumo no store e adaptar tabela e cards para eventos.

## Itens incluidos neste request

- bloco de filtros em card unico, como em orcamentos: `MonthYearNavigator`, busca `Buscar eventos...`, filtro de dia e slider de valor minimo
- sem filtro de Status, sem `Copiar link do formulario de orcamento` e sem `Novo Orcamento`
- `fetchEvents` guarda `summary` em estado proprio de eventos (ex.: `eventListSummary`) e limpa no erro
- cards de resumo: `Total de eventos`, `Valor no mes` e `Ticket medio` (valor no mes / total), com variacao anual onde o backend ja manda
- tabela com o visual da `ProposalTable`, ordenacao por data e valor, textos de evento (`Nenhum evento encontrado para ...`), sem coluna Status
- coluna Valor, slider e card de valor so com `VIEW_AMOUNTS`, como a `EventTable` faz hoje com a coluna
- erro com botao `Tentar de novo`
- carregamento enquanto `selectedVenue` nao chegou, como em orcamentos
- remover `EventMonthYearNavigator` e `EventTable` se ficarem sem uso

## Requisitos implicitos ja visiveis

- a consulta de eventos continua forcando `approved: true`
- trocar mes ou ano zera dia, valor minimo e pagina, como em orcamentos
- contagem acima da tabela usa `pagination.total`
- clique na linha abre `/proposal/:id` em nova aba, como em orcamentos
- orcamentos nao muda: qualquer prop nova em componente compartilhado tem default igual ao comportamento atual

## Casos de erro e borda ja percebidos

- `conversionRate` vem sempre 100% com `approved: true`; nao pode aparecer em eventos
- `amountMax` vem de `summarizeWindow`, que olha todas as propostas do periodo (abertas e fechadas); o teto do slider pode passar do maior evento, e o filtro pode zerar a lista
- `monthAmount` ja soma so propostas aprovadas, entao vale para eventos sem ajuste
- total zero: ticket medio em zero, sem divisao por zero
- mes sem evento: tabela vazia com texto de evento, cards em zero
- dia invalido no backend devolve lista vazia; o select so oferece dias do mes
- usuario sem `VIEW_AMOUNTS`: sem coluna Valor, sem slider, sem card de valor nem ticket medio

## Dependencias

- endpoint de lista com `summary`, `day`, `minAmount`, `sortBy` e `sortDir` (specs [lista paginada](../specs/2026-11-05-lista-painel-orcamentos/00-overview.md), [filtros de status e valor](../specs/2026-11-05-filtros-status-valor-orcamentos/00-overview.md) e [variacao anual](../specs/2026-11-05-variacao-anual-kpis-orcamentos/00-overview.md))
- layout atual de `VenueBudgets` (request [mover o filtro de dia e o botao de novo orcamento](botao-novo-orcamento-no-lugar-do-dia-request.md))

## Restricoes e cuidados

- nao mudar backend nem contrato
- nao mudar textos, colunas ou comportamento de orcamentos
- nao criar terceira abordagem de estado; manter tudo no `proposalStore`
- nao copiar valores do print como dado fixo

## Perguntas em aberto

- Clique no evento abre em nova aba ou na mesma aba? Premissa: nova aba, como orcamentos, ja que o pedido e seguir o modelo de orcamentos.
- O terceiro card vira `Ticket medio` ou some? Premissa: `Ticket medio`, calculado no front a partir de `monthAmount` e `total`, sem variacao anual.
- Generalizar `ProposalTable`/`ProposalListSummaryCards` ou manter componentes proprios de eventos? Premissa: generalizar por props com default de orcamentos; se ficar complexo, componentes de evento com o mesmo visual.

## Prioridade sugerida

Media. A tela funciona; o ganho e consistencia com orcamentos e filtros que ja existem na API.

## Faixa sugerida para task workflow

- `B` — um objetivo e so frontend, mas mexe em componentes e store compartilhados com orcamentos
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: uma tela, so frontend, sem contrato novo; os dados ja vem do endpoint

## Sugestao de slug da spec

- `framework_core/specs/eventos-modelo-orcamentos/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `eventos-modelo-orcamentos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: `VenueEvents.tsx` no molde de `VenueBudgets` (card de filtros com `MonthYearNavigator`, busca, dia e slider; resumo; tabela ordenavel; `Tentar de novo`; carregamento sem `selectedVenue`); `eventListSummary` em `proposalStore`; `kind` e `showAmount` em `ProposalTable` e `ProposalListSummaryCards`, com default de orcamentos; `EventTable` e `EventMonthYearNavigator` removidos; vitest 197 na suite (novos: `ProposalTable.test.tsx`, `proposalStore.test.ts`, 3 casos em `ProposalListSummaryCards.test.tsx`); eslint sem erro (2 avisos de deps de `useEffect`, mesmo padrao de `VenueBudgets`); `tsc` limpo nos arquivos tocados; browser parado no login
- desvio da premissa: sem `Ticket medio`; eventos fica com `Total de eventos` e `Valor no mes`. `summary.total` respeita busca e valor minimo, mas `monthAmount` vem de `summarizeWindow` (so espaco e periodo), entao a divisao sairia errada com filtro ativo
- derivacao repo-local: `nao se aplica`
