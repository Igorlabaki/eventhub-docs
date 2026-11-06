# Tasks — KPIs, filtros, paginas e leitura na lista de notificacoes

## Ordem macro

`T-01` libera pagina, filtro e cards na listagem. `T-02` grava a leitura por orcamento e a leitura do espaco. As duas podem andar juntas. `T-03` consome a listagem e o botao. `T-04` chama a marcacao no detalhe do orcamento. `T-03` espera `T-01` e `T-02`. `T-04` espera `T-02` e pode andar junto com `T-03`.

## Tasks

### T-01 - Paginar, filtrar e resumir a listagem no backend

- objetivo: `GET /notification/list/:venueId` devolve no maximo 10 linhas quando `page` vem, filtra texto, tipo e lida/nao lida, e calcula os quatro cards do filtro inteiro
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`
- reusa: o use case `list-notification` e o contrato de pagina de contatos
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case com repositorio falso
- cenarios obrigatorios:
  - 25 linhas no filtro: pagina 1 com 10, `pagination.total` 25, pagina 3 com 5
  - `q` casa `content`; `type` fora do enum responde 400
  - `summary.unread` e o total nao lido do filtro e nao o tamanho da pagina
  - `type=VISIT` deixa `newProposals` em 0; `isRead=true` deixa `unread` em 0
  - `summary=true` sem `page` responde 400; sem `page`, vem no maximo 25 linhas, sem `pagination` e sem `summary`
  - ordem por `createdAt` desempata por `id`
  - sem coluna e sem indice novo
- definition of done:
  - query Zod aceita `page`, `q`, `type`, `isRead` e `summary` como em `03-design.md#Contratos e dados`
  - os counts usam o mesmo `where` da pagina, sem `skip` e sem `take`
  - `docs/referencias/API_CONTRACTS.md#GET /notification/list/:venueId` descreve pagina, filtro e summary
  - `npm test -- --run` do use case fica verde
  - nao promover topic nem ADR

#### Context Pack

- frente principal: backend
- superficie sensivel: nao — nao acrescenta auth nem campo; a query continua no `venueId` do path
- risco principal: o resumo contar so a pagina, ou a ausencia de `page` passar de 25 linhas ou passar a exigir `summary`
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: tela, JWT na listagem, gravacao de `isRead`, indice
- prova minima desta task: os sete cenarios do unitario verdes
- criterio de escalada: se a janela de 7 ou 30 dias exigir coluna ou fuso do espaco, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `database`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `project/project-decisions.md#D-02`
  - `framework-libs/node/skills/building-read-model-endpoints.md`
  - `specs/2026-11-05-kpis-filtros-lista-contatos/03-design.md#Contratos e dados`
- caminhos candidatos: `art56_server_v3/src/use-cases/notification/list-notification/`, `art56_server_v3/src/repositories/in-prisma/notification-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `listNotificationRequestQuerySchema`, `PAGE_SIZE`, `summary`, `take: 25`
- testes provaveis: `art56_server_v3/src/use-cases/notification/list-notification/use-case-list-notification.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, frontend

### T-02 - Marcar notificacoes como lidas no backend

- objetivo: o detalhe autenticado marca as nao lidas de um orcamento, e o botao marca as nao lidas do espaco, sem passar por `GET /proposal/byId`
- cobre requisitos: `R-06`, `R-07`, `R-08`, `R-09`, `R-10`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`
- reusa: `ensureAuthenticate` e `getUserVenuePermission` no formato de `use-case-create-proposal-per-day.ts`
- prompt recomendado: `normal`
- estrategia de teste: unitario dos dois use cases com repositorio falso
- cenarios obrigatorios:
  - read-by-proposal grava so as nao lidas daquele `proposalId` e daquele `venueId`
  - notificacao de outro orcamento e notificacao ja lida nao mudam
  - read-all grava so as nao lidas daquele `venueId` e ignora filtro
  - sem permissao no espaco responde 403 e nao escreve; orcamento ausente responde 404
  - a segunda chamada atualiza zero linhas
  - `GetProposalByIdUseCase` permanece sem repositorio de notificacao
- definition of done:
  - `PATCH /notification/read-by-proposal/:proposalId` e `PATCH /notification/read-all/:venueId` usam `ensureAuthenticate`
  - a checagem de permissao acontece antes do `updateMany`, como em `03-design.md#Marcacao de lida`
  - `docs/referencias/API_CONTRACTS.md` descreve as duas rotas, com 401, 403 e 404
  - `npm test -- --run` dos use cases fica verde
  - nao promover topic nem ADR

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — gravacao autenticada; a rota publica do orcamento nao pode escrever
- risco principal: marcar lida sem vinculo com o espaco, ou escrever dentro de `GET /proposal/byId`
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: tela, JWT na listagem, filtro e cards
- prova minima desta task: os seis cenarios do unitario verdes
- criterio de escalada: se a permissao exigir um enum que quem abre o orcamento nao tem, parar e registrar em `02-clarify.md`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Marcacao de lida`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Marcacao de lida`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `project/project-decisions.md#D-05`
  - `framework-libs/security/references/auth-and-access-control.md#Principios`
  - `framework-libs/patterns/rules/06_senior_engineering_concepts.md`
- caminhos candidatos: `art56_server_v3/src/router/notification.ts`, `art56_server_v3/src/middleware/ensureAuthenticate.ts`, `art56_server_v3/src/use-cases/proposal/create-proposal-per-day/use-case-create-proposal-per-day.ts`
- palavras-chave ou simbolos de busca: `ensureAuthenticate`, `getUserVenuePermission`, `isRead`, `updateMany`
- testes provaveis: `art56_server_v3/src/use-cases/notification/read-by-proposal/`, `art56_server_v3/src/use-cases/notification/read-all/`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, frontend, pagamento

### T-03 - Mostrar filtros, cards, paginas e marcar todas na tela

- objetivo: Notificacoes envia busca, tipo, lida/nao lida, pagina e `summary=true`, desenha os quatro cards e o pager, e o botao marca todas as nao lidas do espaco
- cobre requisitos: `R-11`, `R-12`
- depende de: `T-01`, `T-02`
- pode rodar em paralelo com: `T-04`
- reusa: `ProposalListPager`, a faixa e o debounce de `VenueBudgets.tsx`
- prompt recomendado: `normal`
- estrategia de teste: a pagina de notificacoes no browser
- cenarios obrigatorios:
  - busca, tipo e lida/nao lida mudam a lista pela API e voltam para a pagina 1
  - a lista mostra no maximo 10 linhas e o pager usa `totalPages`
  - os quatro cards mostram `summary`, nao a soma das linhas visiveis
  - filtro vazio mostra o empty state e cards zerados; o pager some com uma pagina so
  - o selo Novo so aparece com `isRead` falso
  - Marcar todas como lidas refaz a lista e o selo some nas linhas do espaco
- definition of done:
  - `FilterList` sai de `VenueNotifications.tsx`; a busca nao filtra `notifications` no cliente
  - o botao nao se desliga pelo card filtrado
  - a tela mostra erro da lista e Tentar de novo
  - nao promover topic

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — a tela so chama a gravacao ja protegida em `T-02`
- risco principal: filtrar ou somar os cards no navegador, ou o botao obedecer o filtro da pagina
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: `ProposalDetails`, link publico, contrato novo da API
- prova minima desta task: os seis cenarios no browser
- criterio de escalada: se a lista ainda depender de `FilterList` para achar texto, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Tela`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Tela`
  - `03-design.md#Contratos e dados`
  - `framework-libs/design/rules/05_component_states_and_variants.md#Estados de tela com dados`
  - `project/project-decisions.md#D-02`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueNotifications.tsx`, `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`, `eventhub-vista-dashboard/src/components/proposal/ProposalListPager.tsx`
- palavras-chave ou simbolos de busca: `useGetNotificationsList`, `FilterList`, `summary`, `ProposalListPager`
- testes provaveis: browser em `/venue/:id/notifications`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, `GetProposalByIdUseCase`

### T-04 - Marcar como lida ao abrir o orcamento no painel

- objetivo: `ProposalDetails` marca as notificacoes do orcamento depois de carregar, e as paginas publicas nao chamam essa rota
- cobre requisitos: `R-06`, `R-13`
- depende de: `T-02`
- pode rodar em paralelo com: `T-03`
- reusa: `fetchProposalById` e a query `notifications`
- prompt recomendado: `normal`
- estrategia de teste: abrir o orcamento no painel e confirmar que o link publico nao dispara a marcacao
- cenarios obrigatorios:
  - com o orcamento carregado, a tela chama read-by-proposal uma vez
  - falha dessa chamada deixa o orcamento na tela
  - sucesso invalida a query `notifications` do `venueId`
  - `ProposalEventLink` nao chama o servico
  - abrir de novo um orcamento ja lido nao depende de erro: a API responde zero linhas
- definition of done:
  - a chamada fica em `ProposalDetails`, depois de `fetchProposalById` resolver
  - nenhuma pagina publica importa a marcacao
  - nao promover topic

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a chamada nao pode nascer no link publico
- risco principal: marcar lida na pagina publica, ou esconder o orcamento quando a marcacao falha
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: filtros, cards, botao de marcar todas, mudanca em `GET /proposal/byId`
- prova minima desta task: o detalhe do painel chama a rota e `ProposalEventLink` nao chama
- criterio de escalada: se a unica forma de marcar for alterar `GET /proposal/byId`, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Tela`
- libs obrigatorias: `react`, `security`
- documentos obrigatorios:
  - `03-design.md#Tela`
  - `03-design.md#Marcacao de lida`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `project/project-decisions.md#D-05`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalDetails.tsx`, `eventhub-vista-dashboard/src/pages/ProposalEventLink.tsx`, `eventhub-vista-dashboard/src/services/notification.service.ts`
- palavras-chave ou simbolos de busca: `fetchProposalById`, `read-by-proposal`, `ProposalEventLink`
- testes provaveis: browser em `/proposal/:id` e ausencia da chamada em `/` publico do evento
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, listagem de contatos, pagamento
