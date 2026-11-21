# Solicitacao da Tarefa

## Nome sugerido da tarefa

Donuts de origem na aba EVENTO

## Resumo da solicitacao

O card "De onde vem os eventos" deixa as tres listas e mostra cidade, estado e bairro em donut com legenda. So o frontend. A zona fica de fora.

## Context Pack

- frente principal: frontend (o card na aba EVENTO)
- superficie sensivel: nao — o payload agregado ja existe; esta task nao le endereco cru nem muda o endpoint
- risco principal: o donut omitir um lugar que a lista mostra hoje, ou a soma das fatias deixar de bater com a quantidade do payload
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: zona, tabela de distrito, fatia "Fora de SP e Rio", fatia "sem zona", qualquer mudanca em `buildEventOrigin` ou no `GET /venue/reports/event-origin`, coluna nova, mapa, valor
- prova minima desta execucao: na aba EVENTO, o card mostra tres donuts com legenda (cidades, estados, bairros), na ordem e com as quantidades que a API ja devolve; a soma de cada donut iguala a soma da lista atual; ano sem evento continua vazio; o teste do card nao espera zona
- criterio de escalada: permanece `smart`; sobe para `spec` se voltarem a pedir zona ou mudanca de contrato
- nivel de autonomia: `L2`
- flags transversais: `security` nao; `database` nao; `design` sim (donuts no card); `observability` nao; `patterns` nao (reusa o donut que ja existe)

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx` em `CategoryDonut`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md#Criacao de componente React`
  - `.cursor/framework_global/framework-libs/design/index.md#Tabelas, listas e dashboards`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/reports/EventOriginCard.tsx`; `eventhub-vista-dashboard/src/components/reports/EventOriginCard.test.tsx`; `eventhub-vista-dashboard/src/types/venue.ts`
- palavras-chave ou simbolos de busca: `EventOriginCard`, `EventOriginView`, `PlaceList`, `CategoryDonut`, `EventOriginData`
- testes provaveis: o card renderiza tres donuts e as legendas na ordem recebida; vazio esconde os donuts; erro continua com "Tentar de novo"
- nao ler por padrao: `security`, `database`, `art56_server_v3/`, `topics/`, a spec `specs/2026-11-20-origem-dos-eventos/`

## Contexto informado na entrada

Pedido em chat, em cima do card que ja lista cidade, estado e bairro. Exemplo de 2026, 37 eventos aprovados: cidades Sao Paulo 34, Queimados 1, Santo Andre 1, Sao Caetano do Sul 1; estados SP 36 e RJ 1; bairros Bras 2, Cambuci 2, Jardim Independencia 2, Moema 2, Parque Sao Lucas 2, Saude 2, Vila Ema 2, Vila Prudente 2, Aclimacao 1, Bela Vista 1.

A divisao por zona foi tirada desta task. Nao classificar Sao Paulo nem Rio.

## Problema atual

O card "De onde vem os eventos" mostra tres listas. O pedido e ver cidade, estado e bairro em donut com legenda.

## Objetivo da mudanca

Na aba EVENTO, cidades, estados e bairros aparecem em donut com legenda, com os mesmos itens e as mesmas quantidades que o card lista hoje.

## Escopo inicial percebido

Trocar `PlaceList` por donut no `EventOriginCard`, usando o payload que o front ja recebe (`cities`, `states`, `neighborhoods`).

## Itens incluidos neste request

- tres donuts com legenda: Cidades, Estados e Bairros
- legenda com cor, nome, quantidade e percentual, no desenho de `CategoryDonut`
- cada fatia e um item que a API ja devolve, na ordem recebida
- vazio, erro e "Tentar de novo" continuam como estao

## Requisitos implicitos ja visiveis

- `EventOriginData` nao ganha campo
- a soma das fatias de cada donut fecha com a soma das quantidades daquele ranking
- percentual na legenda, como em `CategoryDonut`
- o total no centro de cada donut e a soma daquele ranking

## Casos de erro e borda ja percebidos

- ano sem evento: estado vazio, sem donut
- erro de carga: "Tentar de novo", sem donut
- um ranking com um item so: o donut desenha uma fatia, sem emenda
- muitos bairros: a legenda lista todos; nao cortar nem juntar em "Outros"

## Dependencias

- o card e o `GET /venue/reports/event-origin` ja existem (`specs/2026-11-20-origem-dos-eventos/`, em review). Esta task so muda a apresentacao.

## Restricoes e cuidados

- nao alterar backend, schema, select nem o contrato do agregado
- nao introduzir zona, distrito, "Fora de SP e Rio" nem "sem zona"
- nao reabrir o request nem a spec de origem dos eventos

## Perguntas em aberto

- nenhuma. As perguntas de zona e de "Outros" sairam desta task.

## Prioridade sugerida

Media. Melhora a leitura do card que ja existe e nao desbloqueia outro fluxo.

## Faixa sugerida para task workflow

- `A` = executar com `tasking/task-workflow-prompt-smart.md`

## Candidato a spec

- `nao`
- motivo: um card, no frontend, com o donut que ja existe e o payload que ja chega. Nao ha contrato nem regra nova.

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `donut-origem-eventos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
