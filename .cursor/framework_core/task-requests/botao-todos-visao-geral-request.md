# Solicitacao da Tarefa

## Nome sugerido da tarefa

Botao Anual na visao geral para o relatorio anual

## Resumo da solicitacao

A visao geral do espaco volta a oferecer o periodo do ano inteiro, com um botao Anual na mesma fileira e no mesmo formato dos meses.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o botao Anual aparecer na lista de orcamentos, ou janeiro ficar marcado quando o periodo for o ano
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: API, schema, lista de orcamentos, eventos e o calculo do relatorio anual
- prova minima desta execucao: na visao geral, ver Anual na fileira dos meses, com o mesmo botao; ao escolher Anual, nenhum mes marcado, o card de receita como Receita Anual e a consulta com `month=all`; a lista de orcamentos segue sem Anual
- criterio de escalada: `spec` se o ano inteiro precisar de indicador ou grafico novo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.tsx` no `MonthYearNavigator`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/MonthYearNavigator.tsx`; `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx`; `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`
- palavras-chave ou simbolos de busca: `MonthYearNavigator`, `selectedMonth === "all"`, `onSelectAll`
- testes provaveis: Anual visivel e marcado no ano inteiro; nenhum mes marcado nesse estado; navegador sem o callback nao mostra Anual
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, depois do seletor da visao geral ficar igual ao de orcamentos. A versao anterior tinha a opcao do relatorio anual. O botao fica igual aos meses, com o texto Anual.

## Problema atual

O filtro da visao geral so oferece os doze meses. O codigo do ano inteiro continua: a API aceita `month=all`, o card troca para Receita Anual e o grafico anual existe, mas nao ha controle na tela.

## Objetivo da mudanca

Quem abre a visao geral escolhe o ano inteiro por um botao Anual igual aos meses, e indicadores e grafico seguem esse periodo.

## Escopo inicial percebido

Um botao a mais no navegador da visao geral. A consulta do ano inteiro ja existe.

## Itens incluidos neste request

Mostrar Anual somente quando a visao geral pedir, no mesmo botao dos meses. O clique envia `all`. Com o ano inteiro ativo, nenhum mes fica marcado e o titulo do grafico deixa de dizer que e so o mes.

## Requisitos implicitos ja visiveis

- a lista de orcamentos usa o mesmo navegador e nao ganha Anual
- novembro continua sendo o mes 11 na consulta
- Anual usa o mesmo botao arredondado dos meses e fica depois de Dez
- o rotulo do botao e Anual

## Casos de erro e borda ja percebidos

- janeiro nao pode herdar a marcacao quando o valor interno do ano inteiro cair no indice 0
- ano sem movimento: o painel mostra o que a API ja devolve para `all`
- trocar de Anual para um mes volta a consulta daquele mes

## Dependencias

- `getVenueAnalytics` ja trata `month=all` como o ano inteiro
- `VenueDashboard` ja troca o grafico quando `selectedMonth === "all"`

## Restricoes e cuidados

- nao alterar a lista de orcamentos
- nao mudar o contrato da API
- nao recolocar o menu nativo

## Perguntas em aberto

- O botao fica na fileira dos meses? Premissa: sim; o mesmo botao, depois de Dez.
- O rotulo e Todos ou Anual? Premissa: Anual, como pedido nesta conversa.

## Prioridade sugerida

Media. O mes a mes funciona; falta so a entrada do ano inteiro.

## Faixa sugerida para task workflow

- `A` — um controle opcional num componente ja usado
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so frontend, a consulta anual ja existe

## Sugestao de slug da spec

- `framework_core/specs/botao-todos-visao-geral/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `botao-todos-visao-geral-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- entrega: visao geral ganha o botao Anual na fileira dos meses, mesmo formato, consulta `month=all`; orcamentos sem Anual; vitest 6; browser parado no login
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
