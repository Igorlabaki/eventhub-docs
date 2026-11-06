# Solicitacao da Tarefa

## Nome sugerido da tarefa

Containers da visao geral iguais aos de orcamentos

## Resumo da solicitacao

A visao geral do espaco deixa de ter uma caixa em volta da pagina. O seletor de ano e mes fica num container. Cada indicador fica no proprio card, com icone e arranjo iguais aos da lista de orcamentos.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o seletor ou um indicador continuar dentro da caixa da pagina, ou o icone dos KPIs permanecer no canto do card antigo
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: lista de orcamentos, API, schema, mini grafico diario e o loading da troca de mes
- prova minima desta execucao: na visao geral, ver o seletor num card branco separado; cada um dos quatro indicadores num card proprio, com icone a esquerda, rotulo acima e numero abaixo; proximo evento, proxima visita e grafico fora de uma caixa que envolva a pagina
- criterio de escalada: permanece `smart`; sobe para `normal` se o mesmo recorte de containers precisar nas outras paginas do espaco
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx` no `div` que envolve o painel
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.tsx`; `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`; `eventhub-vista-dashboard/src/components/proposal/ProposalListSummaryCards.tsx`; `eventhub-vista-dashboard/src/components/StatCard.tsx`
- palavras-chave ou simbolos de busca: `MonthYearNavigator`, `ProposalListSummaryCards`, `rounded-3xl`, `rounded-2xl`, `StatCard`
- testes provaveis: seletor fora do grupo de indicadores; quatro cards com icone a esquerda; numeros ainda somem no carregamento da troca de periodo; pagina sem um unico card em volta de tudo
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a visao geral ainda num bloco branco unico. A referencia e `/budgets`: cada parte tem o proprio container, sem uma caixa em volta da pagina. O filtro tem um container. Os indicadores seguem o icone e o arranjo dessa lista.

## Problema atual

Filtro, indicadores, proximo evento, proxima visita e grafico dividem o mesmo bloco. Os indicadores usam o card antigo, com o icone no canto, diferente da lista de orcamentos.

## Objetivo da mudanca

Quem abre a visao geral ve o seletor e cada indicador como pecas separadas, no mesmo desenho da lista de orcamentos.

## Escopo inicial percebido

Rearranjo visual da visao geral do espaco. Sem rota, contrato ou dado novo.

## Itens incluidos neste request

Tirar a caixa que envolve a pagina. Colocar o seletor de ano e mes num container proprio, no feitio do filtro de orcamentos. Cada indicador vira um card proprio: icone a esquerda, rotulo acima do numero. Eventos, Orcamentos, Visitas Agendadas e Receita Mensal continuam. Proximo evento, proxima visita e grafico ficam fora dessa caixa.

## Requisitos implicitos ja visiveis

- o modelo visual e o da lista de orcamentos, nao um card novo
- a variacao percentual continua no indicador de Orcamentos
- a troca de mes ou ano continua carregando so os numeros
- a lista de orcamentos nao muda

## Casos de erro e borda ja percebidos

- tela estreita: os quatro cards quebram a linha, sem voltar para dentro de uma caixa unica
- carregamento do periodo: o numero pulsa dentro do card novo; o card nao some
- primeira abertura: o esqueleto da pagina pode continuar ate o primeiro dado chegar

## Dependencias

- o seletor de ano e mes e o loading dos numeros ja estao na visao geral
- a lista de orcamentos ja tem o container do filtro e o card do indicador

## Restricoes e cuidados

- nao recolocar um container em volta da pagina
- nao alterar a lista de orcamentos
- nao inventar mini grafico diario na visao geral

## Perguntas em aberto

- Os quatro indicadores ficam dentro de uma segunda caixa? Premissa: nao; cada um e o proprio card, como em orcamentos.
- A visao geral ganha o tracinho diario de orcamentos? Premissa: nao; o pedido cobre icone e arranjo, e essa serie nao existe no painel.
- Proximo evento, visita e grafico mudam de conteudo? Premissa: nao; so saem da caixa da pagina.

## Prioridade sugerida

Media. A visao geral funciona; a diferenca e o recorte visual.

## Faixa sugerida para task workflow

- `A` — um rearranjo de uma tela, com o modelo ja visivel em orcamentos
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so a visao geral, sem dado novo. Vira `normal` se o mesmo recorte precisar nas outras paginas do espaco.

## Sugestao de slug da spec

- `framework_core/specs/containers-visao-geral-igual-orcamentos/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `containers-visao-geral-igual-orcamentos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: seletor num card proprio; quatro indicadores com icone a esquerda; pagina sem a caixa unica; vitest 4 em `VenueStatsPanel.test.tsx`; browser parado no login
- derivacao repo-local: `nao se aplica`
