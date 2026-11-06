# Tasks — Filtros de status e valor na lista de orcamentos

## Ordem macro

`T-01` fecha o contrato. `T-02` consome esse contrato na pagina de orcamentos e depende de `T-01`. Nao ha paralelo.

## Tasks

### T-01 - Cortar a lista por valor e somar so o que virou evento

- objetivo: `GET /proposal/list` aceita `minAmount` e devolve `monthAmount` e `daily.amount` so do aprovado na janela, com `amountMax` do maior valor dessa janela.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-11`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: a listagem paginada, o `approved` opcional e a janela wall-clock
- prompt recomendado: `normal`
- estrategia de teste: unitario do schema e do use case, com repositorio falso; o teste que hoje espera `monthAmount` como soma de todos os orcamentos muda para a soma dos aprovados
- cenarios obrigatorios: `minAmount` ausente nao corta; presente corta a lista e o `total` alem da pagina; vazio e ignorado; negativo ou nao numerico responde 400; `monthAmount` ignora busca, status e `minAmount`; dia sem evento fica com amount 0; `amountMax` ignora esses filtros e e 0 sem linha; sem JWT responde 401
- definition of done: os cenarios acima passam em `npm test -- --run`; `docs/referencias/API_CONTRACTS.md#GET /proposal/list` descreve `minAmount`, `amountMax` e o `monthAmount` so de aprovado; sem migration

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: `monthAmount` continuar na mesma query do filtro da tabela e zerar quando o status for Aberto
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: tela, slider, pagina de eventos e schema novo
- prova minima desta task: o teste da listagem mostra `monthAmount` igual a soma dos aprovados mesmo com `approved=false` na query, e `minAmount` reduz `pagination.total`
- criterio de escalada: se a soma do evento exigir coluna ou estado novo, parar; Fechado continua `approved`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `database`, `architecture`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/node/references/node-express-coding-style.md`
  - `.cursor/framework_core/project/project-decisions.md#D-07`
  - `docs/referencias/API_CONTRACTS.md#GET /proposal/list`
- caminhos candidatos: `art56_server_v3/src/zod/proposal/list-proposal-query-schema.ts`, `art56_server_v3/src/use-cases/proposal/list-proposal/`, `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `monthAmount`, `summarize`, `minAmount`, `amountMax`, `approved`
- testes provaveis: `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.spec.ts`
- nao ler por padrao: `security`, tela de orcamentos, pagina de eventos, preco minimo por periodo

### T-02 - Mostrar status e arraste abaixo dos filtros

- objetivo: a pagina de orcamentos ganha status e arraste numa faixa abaixo dos filtros atuais, corta a lista pelo contrato de `T-01` e exibe o Valor no mes sem somar a pagina.
- cobre requisitos: `R-06`, `R-07`, `R-08`, `R-09`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `VenueBudgets.tsx`, o `Slider` de um ponto, `fetchProposals` e `minimumPrice` do espaco ja selecionado
- prompt recomendado: `normal`
- estrategia de teste: a tela de orcamentos, exercitando status, soltar o arraste e a altura dos cards; a chamada de eventos permanece sem `minAmount`
- cenarios obrigatorios: a segunda faixa fica acima dos cards e os cards nao ficam achatados; no piso a request nao leva `minAmount`; soltar acima do piso leva `minAmount` e volta a pagina 1; Todos, Aberto e Fechado mandam `approved` ausente, `false` e `true`; trocar o mes devolve o arraste ao piso; `amountMax` no piso deixa o controle desabilitado; o Valor no mes e o texto de `summary.monthAmount`; a lista de eventos nao ganha `minAmount`
- definition of done: os cenarios acima observados na pagina de orcamentos; a store continua a mesma abordagem, sem cliente novo de estado; se o browser travar no login, registrar o que ficou sem prova

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: filtrar valor so nas linhas ja renderizadas, ou somar o Valor no mes no navegador
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: backend, pagina de eventos alem de nao mexer na chamada, preco minimo por periodo e segundo ponto no slider
- prova minima desta task: na pagina de orcamentos, soltar o arraste acima do piso muda a tabela por um `GET` com `minAmount`, e o Valor no mes continua o numero de `summary.monthAmount` com a tabela em Aberto
- criterio de escalada: se `amountMax` nao vier na resposta, parar e voltar a `T-01`; nao inventar o teto com as 10 linhas
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Visao geral da solucao`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Visao geral da solucao`
  - `03-design.md#Componentes e modulos impactados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`, `eventhub-vista-dashboard/src/services/proposal.service.ts`, `eventhub-vista-dashboard/src/types/proposal.ts`, `eventhub-vista-dashboard/src/components/ui/slider.tsx`
- palavras-chave ou simbolos de busca: `fetchProposals`, `minimumPrice`, `monthAmount`, `amountMax`, `onValueCommit`
- testes provaveis: pagina de orcamentos no browser; conferencia de que a chamada de eventos nao leva `minAmount`
- nao ler por padrao: `security`, skill de React Query, preco minimo por periodo, paginas publicas
