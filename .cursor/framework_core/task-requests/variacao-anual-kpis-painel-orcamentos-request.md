# Solicitacao da Tarefa

## Nome sugerido da tarefa

Variacao anual dos KPIs na lista de orcamentos

## Resumo da solicitacao

Nos tres cards da pagina de orcamentos (Total de orcamentos, Valor no mes e Conversao), o canto superior direito mostra em percentual quanto aquele KPI esta melhor ou pior que o mesmo periodo do ano anterior.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: nao — nao muda auth, pagamento, segredo nem dado novo; a lista continua restrita ao espaco autorizado
- risco principal: o percentual divergir do numero do card, ou nascer de soma feita no navegador com as linhas da pagina
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: comparar com o mes anterior; comparar so ate o dia de hoje; tooltip com o valor absoluto; tirar o sparkline; mudar a formula de total, valor no mes ou conversao; pagina de eventos
- prova minima desta execucao: na pagina de orcamentos, cada card mostra no canto superior direito a variacao inteira contra o mesmo periodo do ano anterior; positivo, negativo, zero e ausencia de base ficam distinguiveis; o teste da listagem cobre a variacao
- criterio de escalada: a spec e o caminho, porque a comparacao entra no contrato do `summary` e atravessa backend e frontend
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-06`
  - `.cursor/framework_core/project/project-decisions.md#D-08`
- caminhos candidatos: cards de KPI da pagina de orcamentos; `summary` da listagem de propostas
- palavras-chave ou simbolos de busca: `Total de orçamentos`, `monthAmount`, `conversionRate`, `ProposalListSummary`, `summary`
- testes provaveis: `npm test -- --run` no backend da listagem; no painel, o canto de cada card com alta, queda e sem base no ano anterior
- nao ler por padrao: `security`, `topics/`, specs de outras frentes, pagamento, lista de eventos e paginas publicas

## Contexto informado na entrada

Pedido em chat, com a pagina de orcamentos aberta. Os tres cards mostram total, valor no mes e conversao, com o sparkline a direita. O pedido pede, no canto superior direito de cada card, o percentual de quanto aquele KPI esta melhor ou pior que o mesmo mes do ano anterior.

## Problema atual

Os cards mostram o periodo selecionado e nao dizem se aquele resultado esta acima ou abaixo do mesmo periodo no ano anterior.

## Objetivo da mudanca

Quem olha os tres cards le, no canto superior direito de cada um, o percentual inteiro de alta ou queda contra o mesmo periodo do ano anterior.

## Escopo inicial percebido

Os tres cards da pagina de orcamentos e o `summary` da listagem que ja os alimenta. Toca `frontend` e `backend`. O percentual segue o significado que cada card ja tem e nao e recalculado no navegador.

## Itens incluidos neste request

- percentual no canto superior direito de Total de orcamentos, Valor no mes e Conversao
- comparacao com o mesmo periodo do ano anterior
- sinal que distingue melhor, pior, igual e ausencia de base
- calculo no backend, no `summary` ja pedido pela pagina

## Requisitos implicitos ja visiveis

- subir o numero e melhor nos tres cards: positivo em verde, negativo em vermelho, zero neutro
- a variacao e relativa, `(atual - ano anterior) / ano anterior`, arredondada para inteiro; na conversao, 1% contra 2% aparece como -50%
- sem base no ano anterior (valor anterior 0), o canto mostra um traco, nao um percentual
- a janela e a do card, um ano para tras: mes inteiro com mes inteiro
- total e conversao continuam no filtro da tabela; Valor no mes continua so o que virou evento, fora de busca, status e valor minimo
- o sparkline permanece
- a data do evento continua em wall-clock
- o contrato descrito em docs acompanha o campo novo do `summary`

## Casos de erro e borda ja percebidos

- ano anterior sem orcamento: traco nos tres cantos, com os valores atuais intactos
- dia 29 de fevereiro sem o mesmo dia no ano anterior: traco
- dia selecionado: a premissa default compara esse dia com o mesmo dia do ano anterior
- mes corrente ainda em andamento: compara o mes inteiro, nao so ate hoje
- filtro de busca, status ou valor muda total e conversao dos dois anos juntos; nao muda o Valor no mes
- a lista de eventos nao passa a pedir nem a exibir essa variacao

## Dependencias

- os tres cards e o `summary` da listagem paginada (`specs/2026-11-05-lista-painel-orcamentos/`)
- o Valor no mes so do que virou evento (`specs/2026-11-05-filtros-status-valor-orcamentos/`)
- nenhum schema novo na premissa default

## Restricoes e cuidados

- nao recalcular o percentual no navegador a partir das linhas da pagina
- nao criar endpoint de KPI; a comparacao entra no `summary` existente
- nao alterar o numero principal de nenhum card
- a query continua limitada ao espaco autorizado
- derivar por repositorio antes de executar: `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Com um dia selecionado, a comparacao e esse dia ou o mes inteiro? Premissa default: o mesmo dia do ano anterior, porque o numero do card ja e esse dia. Se esse dia nao existir, o canto fica em traco.
- O percentual leva casa decimal? Premissa default: inteiro, no mesmo arredondamento da conversao.

## Prioridade sugerida

media

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: muda o contrato do `summary` da listagem e atravessa backend e frontend, com calculo e canto do card que se separam em tasks

## Sugestao de slug da spec

- `framework_core/specs/2026-11-05-variacao-anual-kpis-orcamentos/`

## Sugestao de nome do arquivo

- `variacao-anual-kpis-painel-orcamentos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-variacao-anual-kpis-orcamentos/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
