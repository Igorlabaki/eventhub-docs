# Solicitacao da Tarefa

## Nome sugerido da tarefa

Seletor de ano e mes da visao geral igual ao de orcamentos

## Resumo da solicitacao

A visao geral do espaco troca os dois menus nativos de mes e ano pelo mesmo navegador da lista de orcamentos: setas no ano e um botao por mes.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o painel passar a pedir um mes ou ano que a API nao entende, ou o grafico deixar de marcar o mes escolhido
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: API, schema, lista de orcamentos, eventos, relatorios e a opcao anual "Todas"
- prova minima desta execucao: na visao geral, ver o ano com setas e os doze meses; o mes atual marcado; trocar o mes e o ano e ver indicadores e grafico acompanharem
- criterio de escalada: `spec` se a visao anual "Todas" precisar voltar como parte do mesmo controle
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.tsx` nos dois `select`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx`; `eventhub-vista-dashboard/src/components/proposal/MonthYearNavigator.tsx`; `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`
- palavras-chave ou simbolos de busca: `MonthYearNavigator`, `selectedMonth`, `proposalYears`, `getVenueDashBoardData`
- testes provaveis: mes atual marcado; outro mes atualiza a consulta; ano anterior e seguinte atualizam a consulta; grafico continua com o nome do mes
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com o navegador de orcamentos (ano com setas e Jan–Dez) e a visao geral do espaco, que ainda abre "Novembro" e "2026" em menus nativos.

## Problema atual

A visao geral filtra o painel com dois `select` nativos. A lista de orcamentos ja usa o navegador de ano e mes.

## Objetivo da mudanca

Quem abre a visao geral escolhe ano e mes do mesmo jeito que na lista de orcamentos, e os indicadores e o grafico seguem essa escolha.

## Escopo inicial percebido

Troca visual do filtro que ja existe na visao geral. A consulta continua enviando mes e ano.

## Itens incluidos neste request

Substituir os dois menus da visao geral pelo `MonthYearNavigator` da lista de orcamentos. O mes enviado a API continua de 1 a 12. As setas de ano deixam de ficar presas a lista de anos que ja tem orcamento.

## Requisitos implicitos ja visiveis

- o componente visual e o mesmo da lista de orcamentos
- novembro continua sendo o mes 11 na consulta
- o grafico de desempenho mensal continua mostrando o mes escolhido
- a opcao "Todas" sai do filtro, porque o navegador de orcamentos nao a tem

## Casos de erro e borda ja percebidos

- ano sem movimento: o painel mostra os indicadores zerados ou vazios que a API ja devolve
- mes inicial: o mes corrente, como hoje
- "Todas" deixa de ser alcancavel por este filtro; o grafico anual permanece no codigo, sem entrada na tela

## Dependencias

- `MonthYearNavigator` ja existe e ja e usado na lista de orcamentos
- a consulta do painel ja aceita `month` e `year`

## Restricoes e cuidados

- nao alterar a lista de orcamentos
- nao mudar o contrato da API
- nao recolocar o menu nativo ao lado do navegador

## Perguntas em aberto

- A visao "Todas" continua no filtro? Premissa: nao; o navegador fica igual ao de orcamentos, so com os doze meses.
- O ano pode ir alem dos anos que ja tem orcamento? Premissa: sim; as setas funcionam como em orcamentos.

## Prioridade sugerida

Media. O filtro funciona; a diferenca e so o controle.

## Faixa sugerida para task workflow

- `A` — um componente de um repo, controle ja existente
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so frontend, componente ja usado em orcamentos. Vira spec somente se a visao anual precisar voltar no mesmo controle.

## Sugestao de slug da spec

- `framework_core/specs/seletor-ano-mes-visao-geral/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `seletor-ano-mes-visao-geral-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: visao geral usa o `MonthYearNavigator` de orcamentos; mes segue 1–12 na consulta; setas de ano livres; vitest 2 em `VenueStatsPanel.test.tsx`; browser parado no login
- derivacao repo-local: `nao se aplica`
