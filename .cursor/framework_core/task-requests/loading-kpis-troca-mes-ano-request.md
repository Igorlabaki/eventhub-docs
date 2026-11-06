# Solicitacao da Tarefa

## Nome sugerido da tarefa

Carregar so os numeros dos KPIs ao trocar mes ou ano

## Resumo da solicitacao

Na visao geral do espaco, trocar o ano ou o mes mantem a pagina no lugar. So os numeros dos indicadores entram em carregamento.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: a pagina continuar trocando pelo esqueleto inteiro, ou os numeros novos aparecerem sem sinal de que a consulta ainda esta no ar
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: loading da troca de item da sidebar, lista de orcamentos, eventos, relatorios, API e schema
- prova minima desta execucao: na visao geral, trocar o mes e o ano e ver o seletor, os titulos dos cards, o proximo evento, a proxima visita e o grafico parados, com so os numeros dos quatro indicadores em carregamento ate os valores novos chegarem
- criterio de escalada: permanece `smart`; sobe para `normal` se a mesma troca tambem precisar de loading parcial em outra pagina
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx` no trecho que troca o conteudo por `VenueDashboardSkeleton`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/hooks/venue/queries/venueDashBoardData.ts`; `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.tsx`; `eventhub-vista-dashboard/src/components/StatCard.tsx`; `eventhub-vista-dashboard/src/components/venue/VenueDashboardSkeleton.tsx`
- palavras-chave ou simbolos de busca: `isLoadingDashBoardData`, `VenueDashboardSkeleton`, `useGetVenueDashBoardData`, `MonthYearNavigator`
- testes provaveis: primeira abertura da visao geral ainda pode usar o esqueleto da pagina; troca de mes ou ano nao troca a pagina inteira; os quatro numeros entram em carregamento e depois mostram o valor novo
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, logo depois de a visao geral passar a usar o mesmo seletor de ano e mes da lista de orcamentos. Ao mudar o ano ou o mes, a pagina toda entra em carregamento. O esperado e carregar apenas os numeros dos KPIs.

## Problema atual

Trocar mes ou ano na visao geral substitui o painel inteiro pelo esqueleto da pagina. O seletor, os cards e o restante somem juntos.

## Objetivo da mudanca

Quem troca o ano ou o mes continua na mesma tela, e so os numeros dos indicadores mostram que estao carregando.

## Escopo inicial percebido

Ajuste do carregamento da visao geral do espaco quando os filtros de mes e ano mudam. Sem rota, contrato ou tela nova.

## Itens incluidos neste request

Na visao geral, a troca de mes ou ano deixa de recolocar o esqueleto da pagina. Os numeros de Eventos, Orcamentos, Visitas Agendadas e Receita Mensal entram em carregamento ate a consulta daquele periodo terminar. O seletor permanece usavel.

## Requisitos implicitos ja visiveis

- a primeira abertura da visao geral pode continuar com o carregamento da pagina
- titulo, icone e variacao do card nao precisam de esqueleto proprio; o numero e que carrega
- proximo evento, proxima visita e grafico permanecem na tela durante essa troca
- o pedido de loading da sidebar continua em outro request

## Casos de erro e borda ja percebidos

- consulta do novo mes falha: a pagina nao fica presa no esqueleto inteiro; o numero deixa o carregamento
- troca rapida de mes: o numero que aparece e o do ultimo mes pedido
- mes ou ano sem movimento: o numero sai do carregamento e mostra o valor vazio ou zerado que a consulta devolver

## Dependencias

- o seletor de ano e mes da visao geral ja esta no codigo, no request do navegador igual ao de orcamentos
- a consulta do painel ja recebe mes e ano

## Restricoes e cuidados

- nao aplicar este loading na troca de item da sidebar
- nao criar um esqueleto novo para a pagina inteira
- nao mudar o contrato da consulta

## Perguntas em aberto

- O grafico, o proximo evento e a proxima visita tambem pulsam? Premissa: nao; so os numeros dos quatro indicadores.
- A primeira entrada na visao geral continua com o esqueleto da pagina? Premissa: sim; o loading parcial vale para a troca de mes ou ano.

## Prioridade sugerida

Media. O filtro ja troca o periodo; o incoveniente e a tela inteira piscar.

## Faixa sugerida para task workflow

- `A` — um comportamento de uma tela, sem contrato novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so a visao geral, sem API. Vira `normal` se o mesmo loading parcial precisar nas outras paginas com seletor de mes.

## Sugestao de slug da spec

- `framework_core/specs/loading-kpis-troca-mes-ano/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `loading-kpis-troca-mes-ano-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: troca de mes ou ano mantem a visao geral e pulsa so os quatro numeros; vitest 3 em `VenueStatsPanel.test.tsx`; browser parado no login
- derivacao repo-local: `nao se aplica`
