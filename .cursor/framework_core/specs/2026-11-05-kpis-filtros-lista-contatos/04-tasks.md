# Tasks — KPIs, filtros e paginas de dez na lista de contatos

## Ordem macro

`T-01` libera pagina, filtro e cards no `GET /contact/list`. `T-02` consome isso na pagina de contatos. `T-02` nao comeca antes de `T-01`.

## Tasks

### T-01 - Paginar, filtrar e resumir a listagem no backend

- objetivo: `GET /contact/list` devolve no maximo 10 linhas quando `page` vem, filtra busca, tipo e categoria, e calcula os tres cards do filtro inteiro
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-06`, `R-09`, `R-10`, `R-12`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: o use case `list-contact` e o contrato de pagina de `GET /proposal/list`
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case com repositorio falso
- cenarios obrigatorios:
  - 25 linhas no filtro: pagina 1 com 10, `pagination.total` 25, pagina 3 com 5
  - `q` casa funcao, WhatsApp ou e-mail, nao so o nome
  - `category=OUTROS` nao inclui contato com categoria nula
  - `summary.total` e o total do filtro e igual a `pagination.total`; logo em branco nao entra em `withLogo`
  - `summary=true` sem `page` responde 400; sem `page`, a lista inteira vem sem `pagination` e sem `summary`
  - ordem por `name` desempata por `id`
  - sem coluna e sem indice novo
- definition of done:
  - query Zod aceita `page`, `q`, `category` e `summary` como em `03-design.md#Contratos e dados`
  - os counts usam o mesmo `where` da pagina, sem `skip` e sem `take`
  - `docs/referencias/API_CONTRACTS.md#GET /contact/list` descreve pagina, filtro e summary
  - `npm test -- --run` do use case fica verde
  - nao promover topic nem ADR

#### Context Pack

- frente principal: backend
- superficie sensivel: nao — nao acrescenta auth nem campo; a query continua no `venueId` pedido
- risco principal: o resumo contar so a pagina, ou a ausencia de `page` deixar de devolver a lista inteira
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: tela, JWT na rota, indice, Indicar parceiros
- prova minima desta task: os sete cenarios do unitario verdes
- criterio de escalada: se o count do logo ou da descricao exigir coluna nova, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `database`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `project/project-decisions.md#D-02`
  - `framework-libs/node/skills/building-read-model-endpoints.md`
  - `specs/2026-11-05-lista-painel-orcamentos/03-design.md#Contratos e dados`
- caminhos candidatos: `art56_server_v3/src/use-cases/contact/list-contact/`, `art56_server_v3/src/repositories/in-prisma/contact-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `listContactRequestQuerySchema`, `PAGE_SIZE`, `summary`
- testes provaveis: `art56_server_v3/src/use-cases/contact/list-contact/use-case-list-contact.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, frontend

### T-02 - Mostrar filtros, cards e paginas na tela de contatos

- objetivo: Contatos envia busca, categoria, pagina e `summary=true`, e desenha cards, tabela e pager sem filtrar no navegador
- cobre requisitos: `R-07`, `R-08`, `R-09`, `R-11`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `ProposalListPager`, a faixa e o debounce de `VenueBudgets.tsx`, `ContactHeader`
- prompt recomendado: `normal`
- estrategia de teste: a pagina de contatos no browser, mais a lista de Indicar parceiros sem pagina
- cenarios obrigatorios:
  - busca e categoria mudam a tabela pela API e voltam para a pagina 1
  - a tabela mostra no maximo 10 linhas e o pager usa `totalPages`
  - os tres cards mostram `summary`, nao a soma das linhas visiveis
  - aba Equipe esconde a categoria e nao envia `category`
  - filtro vazio mostra o empty state e cards zerados; o pager some com uma pagina so
  - apagar a ultima linha da pagina pede a pagina anterior
  - Indicar parceiros continua recebendo a lista inteira
- definition of done:
  - `FilterList` sai de `contact-list.tsx`; a busca nao filtra `contacts` no cliente
  - criar, editar e apagar repetem `venueId`, `type`, `q`, `category`, `page` e `summary`
  - a tela mostra erro da lista e Tentar de novo
  - nao promover topic

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — a tela continua atras da permissao de ver contatos do espaco
- risco principal: a busca do `FilterList` continuar valendo so para as dez linhas, ou Indicar parceiros passar a pedir pagina
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: contrato do backend, formularios publicos, apagar o componente `FilterList`
- prova minima desta task: em Contatos, busca, categoria, cards do conjunto filtrado e pagina de dez; Indicar parceiros lista todos
- criterio de escalada: se a tela precisar de uma segunda rota para os cards, parar e voltar ao contrato
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Tela`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Tela`
  - `03-design.md#Contratos e dados`
  - `framework-libs/design/rules/07_data_display_and_dashboards.md`
  - `framework-libs/react/skills/creating-frontend-pages.md`
  - `framework-libs/react/rules/03_data_fetching_and_server_state.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueContacts.tsx`, `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`, `eventhub-vista-dashboard/src/components/proposal/ProposalListPager.tsx`
- palavras-chave ou simbolos de busca: `FilterList`, `fetchContacts`, `ProposalListPager`, `summary`
- testes provaveis: a pagina `/contacts` no browser e a tela Indicar parceiros
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, formularios publicos
