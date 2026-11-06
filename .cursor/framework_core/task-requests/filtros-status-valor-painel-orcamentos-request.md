# Solicitacao da Tarefa

## Nome sugerido da tarefa

Filtros de status e valor na lista de orcamentos, com o valor do mes so do que virou evento

## Resumo da solicitacao

Na pagina de orcamentos do painel, os cards e a tabela ficam numa faixa inteira abaixo de todos os filtros. Entram um filtro de status e um controle arrastavel de valor, que comeca no preco minimo do espaco. O card Valor no mes passa a mostrar so o que virou evento naquele mes, e nao a soma de todos os orcamentos.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: nao — nao muda auth, pagamento, segredo nem dado novo; a lista continua restrita ao espaco autorizado
- risco principal: o valor do mes continuar somando orcamento Aberto, ou o arraste filtrar so as linhas da pagina atual
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: redesenhar a pagina de eventos; mudar a formula de conversao; criar status novo; usar preco minimo por periodo; paginas publicas do orcamento
- prova minima desta execucao: na pagina de orcamentos, status e o arraste ficam abaixo dos filtros atuais e os tres cards mantem altura; o arraste, a partir do minimo do espaco, muda a tabela pela API; Valor no mes soma so o que virou evento no mes, e nao todos os orcamentos
- criterio de escalada: a spec e o caminho, porque o filtro de valor e o novo significado do card mudam o contrato da listagem nos dois repositorios
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/specs/2026-11-05-lista-painel-orcamentos/00-overview.md`
  - `.cursor/framework_global/framework-libs/database/index.md`
- caminhos candidatos: pagina de orcamentos do painel; listagem de propostas; preco minimo padrao do espaco
- palavras-chave ou simbolos de busca: `Valor no mês`, `monthAmount`, `approved`, `minimumPrice`, `fetchProposals`
- testes provaveis: `npm test -- --run` no backend da listagem; no painel, status, arraste a partir do minimo do espaco e o card Valor no mes so com o que virou evento
- nao ler por padrao: `security`, `topics/`, specs de outras frentes, pagamento, lista de eventos e paginas publicas

## Contexto informado na entrada

Pedido em chat, com a pagina de orcamentos aberta em novembro de 2026. O bloco de baixo dos filtros ficou achatado. O pedido pede filtro por status e um filtro que se arrasta pelo valor, comecando no minimo da casa. O Valor no mes deve ser o do mes que virou evento, e nao a soma de todos os orcamentos.

## Problema atual

Busca, copiar o link e dia dividem a mesma faixa, e os cards entram logo em seguida, sem uma faixa propria. Nao ha filtro de status nem filtro por valor. O Valor no mes soma o valor de todos os orcamentos do intervalo, inclusive os que nao viraram evento.

## Objetivo da mudanca

Quem filtra orcamentos escolhe status e arrasta o valor a partir do minimo do espaco, com os cards e a tabela inteiros abaixo dos filtros, e le no Valor no mes so a soma do que virou evento naquele mes.

## Escopo inicial percebido

A pagina de orcamentos do painel e o contrato da listagem que alimenta a tabela e os cards. Toca `frontend` e `backend`. O filtro de valor nao pode valer so para as linhas ja carregadas. O card de valor muda de significado; total e conversao permanecem.

## Itens incluidos neste request

- faixa dos cards e da tabela abaixo de todos os filtros, com altura normal
- filtro de status na lista de orcamentos
- controle arrastavel de valor, com o inicio no preco minimo padrao do espaco
- Valor no mes igual a soma do que virou evento no mes, nao a soma de todos os orcamentos
- o grafico desse card no mesmo criterio

## Requisitos implicitos ja visiveis

- ano, meses, busca, copiar o link e dia permanecem
- status continua Aberto e Fechado; Fechado e o que virou evento
- o arraste filtra a lista no backend, junto com a pagina de 10
- trocar status ou valor volta para a primeira pagina
- o minimo usado e o preco minimo padrao do espaco, nao o minimo por periodo
- total de orcamentos e conversao nao passam a contar so o que virou evento
- a data do evento continua em wall-clock

## Casos de erro e borda ja percebidos

- espaco sem preco minimo: o arraste comeca em zero
- mes sem orcamento que virou evento: Valor no mes zero, mesmo com orcamentos Aberto na tabela
- status Aberto nao pode zerar o Valor no mes
- arraste no valor mais alto do mes: a tabela pode ficar vazia e a paginacao nao mostra pagina extra
- dia selecionado: o Valor no mes considera esse dia, nao o mes inteiro
- a lista de eventos nao pode passar a incluir orcamento que nao virou evento

## Dependencias

- a listagem paginada de orcamentos ja no painel (`specs/2026-11-05-lista-painel-orcamentos/`)
- o preco minimo padrao do espaco
- nenhum schema novo na premissa default

## Restricoes e cuidados

- nao recalcular o Valor no mes no navegador a partir das linhas da pagina
- nao filtrar valor so nas 10 linhas visiveis
- nao criar status alem de Aberto e Fechado
- nao usar o preco minimo por periodo como piso do arraste
- a query continua limitada ao espaco autorizado
- derivar por repositorio antes de executar: `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- O arraste e um ponto solo (a partir deste valor) ou uma faixa com dois pontos? Premissa default: um ponto, que comeca no minimo do espaco e, ao subir, mostra so orcamento com valor maior ou igual.
- Ate onde vai o trilho? Premissa default: ate o maior valor do mes selecionado; se nao houver orcamento, o trilho fica no minimo do espaco.
- Valor no mes acompanha busca, status e arraste? Premissa default: nao. Acompanha mes, ano e dia, e soma so o que virou evento.
- Total e conversao acompanham status e arraste? Premissa default: acompanham o filtro da tabela, exceto a pagina. So o Valor no mes fica fora desses dois filtros.

## Prioridade sugerida

media

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: muda o contrato da listagem (filtro de valor e o significado do Valor no mes) e atravessa backend e frontend, com layout, filtro e KPI que se separam em tasks

## Sugestao de slug da spec

- `framework_core/specs/2026-11-05-filtros-status-valor-orcamentos/`

## Sugestao de nome do arquivo

- `filtros-status-valor-painel-orcamentos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-filtros-status-valor-orcamentos/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
