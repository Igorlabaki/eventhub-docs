# Tasks — Variacao anual dos KPIs na lista de orcamentos

## Ordem macro

`T-01` fecha o contrato. `T-02` desenha o canto e depende de `T-01`. Nao ha paralelo. Cada task ja cabe num repositorio.

## Tasks

### T-01 - Calcular a variacao anual no summary

- objetivo: `summary.change` traz o percentual inteiro de total, valor no mes e conversao contra a mesma janela do ano anterior, ou `null` sem base.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-08`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `proposalListRange`, `summarize`, `summarizeWindow` e `buildSummary`
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case com repositorio falso; a janela anterior se distingue pela `range`, nao por uma segunda implementacao
- cenarios obrigatorios: 243 contra 200 responde 22; 12590 contra 14000 responde -10; conversao 1 contra 2 responde -50; iguais respondem 0; `Math.round` de -10,5 responde -10; anterior 0 num campo responde `null` sem anular o outro; dia selecionado consulta o mesmo dia do ano anterior; 29 de fevereiro sem par nao consulta e responde `null`; dia invalido responde `null`; busca e status nao mudam o `monthAmount` dos dois anos; sem `summary` nao ha `change` nem segunda leitura; sem JWT responde 401
- definition of done: os cenarios passam em `npm test -- --run`; `docs/referencias/API_CONTRACTS.md#GET /proposal/list` descreve `change`; sem migration e sem endpoint novo

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: a janela anterior usar outro filtro que o card, ou o percentual ser calculado fora do use case
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: o canto do card, a pagina de eventos e schema novo
- prova minima desta task: o teste da listagem mostra `change.total` 22 para 243 contra 200 e `null` quando o anterior daquele campo e 0
- criterio de escalada: se a comparacao exigir coluna, indice ou endpoint novo, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `database`, `architecture`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/node/references/node-express-coding-style.md`
  - `.cursor/framework_core/project/project-decisions.md#D-06`
  - `.cursor/framework_global/framework-libs/architecture/rules/02_communication_and_apis.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.ts`, `art56_server_v3/src/functions/wall-clock-datetime.ts`, `docs/referencias/API_CONTRACTS.md`
- palavras-chave ou simbolos de busca: `buildSummary`, `summarizeWindow`, `proposalListRange`, `monthAmount`, `conversionRate`
- testes provaveis: `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, tela, pagina de eventos e `topics/`

### T-02 - Mostrar a variacao no canto do card

- objetivo: os tres cards mostram `summary.change` no canto superior direito, com sinal, cor e icone, e deixam o canto vazio ate o campo chegar.
- cobre requisitos: `R-05`, `R-06`, `R-07`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `ProposalListSummaryCards`, o sparkline e os icones do `lucide-react`
- prompt recomendado: `normal`
- estrategia de teste: a pagina de orcamentos, com alta, queda, zero, traco e carregamento; a lista de eventos nao ganha o canto
- cenarios obrigatorios: `+22%` verde com icone de alta; percentual negativo vermelho com icone de queda; `0%` neutro; `—` sem seta; canto vazio enquanto `summary` e nulo; numero principal e sparkline permanecem; o nome acessivel diz o sentido da comparacao; a lista de eventos nao mostra o canto
- definition of done: os cenarios aparecem na pagina de orcamentos; `ProposalListSummary` declara `change`; a tela nao recalcula o percentual

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o canto mostrar traco durante o carregamento, ou a cor ser o unico sinal da alta e da queda
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: formula, contrato, backend e pagina de eventos
- prova minima desta task: na pagina de orcamentos, o canto distingue alta, queda e ausencia de base sem alterar o numero principal do card
- criterio de escalada: se o percentual precisar ser recalculado no navegador, parar e voltar a `T-01`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Falhas, casos de borda e invariantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/design/rules/07_data_display_and_dashboards.md#Numeros e KPIs`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md#Estados de tela com dados`
  - `.cursor/framework_global/framework-libs/react/references/react-coding-style.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/ProposalListSummaryCards.tsx`, `eventhub-vista-dashboard/src/types/proposal.ts`
- palavras-chave ou simbolos de busca: `ProposalListSummary`, `monthAmount`, `conversionRate`, `ProposalSparkline`
- testes provaveis: pagina de orcamentos no browser; `npm run lint` no frontend se o canto alterar tipo
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, backend, pagina de eventos e `topics/`
