# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mover o filtro de dia para a direita do status e o botao de novo orcamento para o lugar do dia

## Resumo da solicitacao

Na lista de orcamentos do painel, o filtro de dia sai da linha da busca e fica imediatamente a direita do filtro de status. O botao Novo Orcamento sai de cima do card e ocupa o lugar que o filtro de dia deixa, ao lado de copiar o link.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — so reposiciona controles que ja existem na lista do espaco
- risco principal: o botao sumir para quem pode criar, ou o filtro de dia deixar de filtrar a lista
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: mudar o que status, dia e valor filtram; outras paginas que usam o botao de criar no topo; formulario de novo orcamento
- prova minima desta execucao: na lista de orcamentos, Dia fica a direita de Status; Novo Orcamento fica na linha da busca, no lugar antigo do Dia; escolher um dia continua filtrando a tabela; o botao abre o formulario
- criterio de escalada: se o pedido passar a mudar contrato da listagem ou o formulario, promover para spec
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: pagina de orcamentos do painel; cabecalho com o botao de criar
- palavras-chave ou simbolos de busca: `Novo Orçamento`, `aria-label="Dia"`, `PageHeader`
- testes provaveis: a lista de orcamentos no browser, com Dia ao lado de Status e Novo Orcamento no lugar antigo do Dia
- nao ler por padrao: `security`, `topics/`, backend, specs de outras frentes

## Contexto informado na entrada

Pedido em chat, com a lista de orcamentos aberta em novembro de 2026. O filtro de dia esta na linha da busca, a direita de copiar o link. O botao Novo Orcamento esta acima do card, a esquerda.

## Problema atual

Dia e Status ficam em faixas diferentes. Novo Orcamento ocupa o topo da pagina, fora da faixa de filtros.

## Objetivo da mudanca

Quem olha a lista ve o filtro de dia a direita do filtro de status, e o botao Novo Orcamento no lugar em que o filtro de dia estava.

## Escopo inicial percebido

So a pagina de orcamentos do painel. O botao de criar no celular, flutuante, permanece. As outras telas que usam o mesmo cabecalho nao mudam de lugar.

## Itens incluidos neste request

- filtro de dia imediatamente a direita do filtro de status
- botao Novo Orcamento no lugar atual do filtro de dia, na linha da busca
- o botao de cima do card sai dessa pagina

## Requisitos implicitos ja visiveis

- busca, copiar o link, status e o arraste de valor permanecem
- o filtro de dia continua valendo para a lista, os cards e a pagina
- quem nao pode criar orcamento nao ve o botao
- no celular, o botao flutuante de criar continua

## Casos de erro e borda ja percebidos

- sem permissao de editar: a linha da busca fica so com busca e copiar o link; Dia continua ao lado de Status
- formulario aberto: a lista, e portanto esses controles, sai da tela
- trocar o mes ainda zera o dia escolhido

## Dependencias

- a lista de orcamentos do painel com status, valor e dia ja na tela

## Restricoes e cuidados

- nao alterar o contrato da listagem
- nao mover o botao de criar nas outras paginas do painel

## Perguntas em aberto

- O botao flutuante do celular sai junto? Premissa default: nao. So o botao de cima, no desktop, muda de lugar.

## Prioridade sugerida

alta

## Faixa sugerida para task workflow

- `A` = executar com `tasking/task-workflow-prompt-smart.md`

## Candidato a spec

- `nao`
- motivo: reposiciona dois controles ja existentes numa unica pagina

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `botao-novo-orcamento-no-lugar-do-dia-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
