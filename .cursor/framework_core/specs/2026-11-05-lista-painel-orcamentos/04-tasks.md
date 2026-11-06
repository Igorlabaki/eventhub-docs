# Tasks — Lista paginada de orcamentos no painel

## Ordem macro

`T-01` libera a pagina e os filtros. `T-02` acrescenta os KPIs no mesmo use case. `T-03` consome isso na pagina de orcamentos. `T-04` consome a pagina na lista de eventos. `T-03` e `T-04` nao rodam juntas: as duas editam o servico e a store.

## Tasks

### T-01 - Paginar e filtrar a listagem no backend

- objetivo: `GET /proposal/list` devolve no maximo 10 linhas quando `page` vem, filtra data wall-clock, nome e status, e ordena de forma estavel
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-09`, `R-11`, `R-12`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `wall-clock-datetime`, `ensureAuthenticate`, o use case `list-proposal`
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case com repositorio falso e unitario do intervalo wall-clock
- cenarios obrigatorios:
  - 25 linhas no filtro: pagina 1 com 10, `pagination.total` 25, pagina 3 com 5
  - mes wall-clock inclui o dia 1 e exclui o primeiro instante do mes seguinte, inclusive uma data `23:00Z`
  - `day` devolve so aquele dia civil
  - dia 31 num mes de 30 devolve vazio e nao inclui o mes seguinte
  - `approved` ausente devolve Aberto e Fechado; `true` so Fechado
  - `sortBy=totalAmount&sortDir=desc` desempata por `id`
  - sem JWT responde 401; espaco ausente responde 404; sem `page` devolve a lista inteira, sem `pagination`
- definition of done:
  - query Zod aceita `page`, `day`, `sortBy` e `sortDir` como em `03-design.md#Contratos e dados`
  - `approved` ausente nao vira `false`
  - `Proposal` ganha `@@index([venueId, startDate])` e `npx prisma validate` passa
  - cada item traz `status` `ABERTO` ou `FECHADO`
  - `docs/referencias/API_CONTRACTS.md#GET /proposal/list` descreve pagina, filtro e status
  - `npm test -- --run` do use case e do intervalo fica verde
  - nao promover topic: a regra wall-clock ja esta em `D-06`

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — nome e valor continuam atras do JWT, no `venueId` pedido
- risco principal: o intervalo local atual puxar o dia de mes, ou `approved` ausente continuar escondendo Fechado
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: `summary`, tela, pagina de eventos, ownership do espaco
- prova minima desta task: os sete cenarios do unitario verdes e `npx prisma validate` limpo
- criterio de escalada: se `startDate` nao puder ser filtrado por componentes UTC sem migration de dados, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `database`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `project/project-decisions.md#D-06`
  - `framework-libs/node/skills/building-read-model-endpoints.md`
  - `framework-libs/security/references/auth-and-access-control.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/list-proposal/`, `art56_server_v3/src/functions/wall-clock-datetime.ts`, `art56_server_v3/prisma/schema.prisma` model `Proposal`
- palavras-chave ou simbolos de busca: `approved: approved ? true : false`, `listProposalRequestQuerySchema`, `startDate`
- testes provaveis: `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, relatorio anual, frontend

### T-02 - Calcular os KPIs no backend

- objetivo: com `summary=true`, a mesma listagem devolve total, valor, conversao e a serie diaria do filtro inteiro
- cobre requisitos: `R-05`, `R-06`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: o `where` da `T-01`; nao reusa `analysisByMonth`
- prompt recomendado: `smart`
- estrategia de teste: unitario do use case com agregados falsos
- cenarios obrigatorios:
  - `summary.total` e o total do filtro, nao o tamanho da pagina
  - `monthAmount` e a soma de `totalAmount`
  - `conversionRate` arredonda e vale 0 quando o total e 0
  - `daily` tem um ponto por dia da janela, com zero nos dias sem linha e `conversionRate` ja inteiro
  - `day` reduz o resumo e a janela a esse dia
  - nome reduz o resumo junto com a tabela
  - `summary=true` sem `page` responde 400; sem `summary`, a chave nao vem
- definition of done:
  - a serie sai de agregacao por `DATE_FORMAT(startDate, '%Y-%m-%d')`, nao de `findMany` do mes
  - a coluna foi conferida: DATETIME segue `DATE()`; TIMESTAMP para a task e usa extracao UTC
  - dias faltantes sao preenchidos no use case
  - `docs/referencias/API_CONTRACTS.md#GET /proposal/list` ganha `summary`
  - unitario verde
  - nao promover topic

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — o resumo revela contagem e valor do mesmo `venueId`
- risco principal: somar so a pagina de 10, ou agrupar o dia no fuso do servidor
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: desenho dos cards, pagina de eventos, indice
- prova minima desta task: os sete cenarios do unitario verdes, com `summary.total` diferente do tamanho da pagina
- criterio de escalada: se a serie so existir carregando todas as linhas, parar e manter a agregacao
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `database`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `02-clarify.md#Premissas assumidas`
  - `project/project-decisions.md#D-06`
  - `project/project-decisions.md#D-07`
  - `framework-libs/database/references/indexing-and-query-optimization.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.ts`, `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `summary`, `conversionRate`, `DATE(startDate)`, `totalAmount`
- testes provaveis: `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.spec.ts`
- nao ler por padrao: `01-spec.md`, `security`, frontend, `analysisByMonth`

### T-03 - Montar a pagina de orcamentos em cima da resposta

- objetivo: a pagina de orcamentos fica parecida com a referencia e so exibe a pagina, os selos e o `summary`
- cobre requisitos: `R-07`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: `MonthYearNavigator`, `PageHeader`, Recharts, o copiar link ja existente
- prompt recomendado: `normal`
- estrategia de teste: exercitar a pagina no browser: mes, dia, busca, pagina e cards
- cenarios obrigatorios:
  - trocar o mes pede a API e a tabela mostra no maximo 10 linhas
  - a busca espera um pouco, manda `completeClientName` e volta para a pagina 1
  - o dia sai num select e vai na query
  - os tres cards e o texto "N orcamentos" repetem `summary` e `pagination.total`, sem somar a pagina
  - os graficos plotam `summary.daily` e nao calculam conversao
  - Aberto fica ambar e Fechado fica verde
  - ordenar Data, Valor ou Status muda `sortBy` e `sortDir`
  - filtro vazio mostra tabela vazia e cards em zero; erro da API aparece na tela
- definition of done:
  - a hierarquia da referencia esta na pagina: ano, meses, busca, copiar link, dia, tres cards, tabela e pager
  - Novo Orcamento permanece; o clique na linha abre o orcamento; nao ha menu de tres pontos
  - `FilterList` deixa de filtrar esta pagina
  - a store de orcamentos tem loading e metadados proprios, separados dos eventos
  - a prova no browser cobre os oito cenarios
  - nao promover topic

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a tela mostra nome e valor que a API ja devolveu
- risco principal: a tela somar as 10 linhas e o card divergir do filtro
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: pagina de eventos, contrato novo, status Enviado
- prova minima desta task: no browser, pagina de 10, busca e dia na API, cards iguais ao `summary`
- criterio de escalada: se o `summary` nao vier na resposta, parar em vez de calcular no front
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Visao geral da solucao`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Visao geral da solucao`
  - `03-design.md#Reuso previsto`
  - `framework-libs/design/rules/07_data_display_and_dashboards.md`
  - `framework-libs/design/rules/05_component_states_and_variants.md`
  - `framework-libs/react/skills/creating-frontend-pages.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`, `eventhub-vista-dashboard/src/components/proposal/ProposalTable.tsx`, `eventhub-vista-dashboard/src/store/proposalStore.ts`
- palavras-chave ou simbolos de busca: `fetchProposals`, `FilterList`, `summary`, `pagination`
- testes provaveis: fluxo manual na pagina de orcamentos do painel
- nao ler por padrao: `01-spec.md`, `security`, `analysisByMonth`, pagina de eventos

### T-04 - Paginar a lista de eventos

- objetivo: a pagina de eventos pede so os aprovados, de 10 em 10, com busca e mes no backend
- cobre requisitos: `R-08`
- depende de: `T-03`
- pode rodar em paralelo com: nenhuma
- reusa: o cliente HTTP e a store preparados na `T-03`; `EventMonthYearNavigator` e `EventTable`
- prompt recomendado: `smart`
- estrategia de teste: exercitar a pagina de eventos no browser
- cenarios obrigatorios:
  - a request leva `approved=true`, `page` e `pageSize` ignorado pelo servidor
  - a tabela mostra no maximo 10 eventos
  - a busca vai em `completeClientName` e nao filtra a lista local
  - trocar o mes volta para a pagina 1
  - o texto "N eventos" usa `pagination.total`
  - a pagina nao mostra os tres cards
  - o clique no evento continua abrindo o orcamento
- definition of done:
  - `EventFilterList` deixa de ser o filtro da lista
  - loading e metadados de eventos nao apagam a lista de orcamentos
  - a prova no browser cobre os sete cenarios
  - nao promover topic

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a tela lista nome e valor de evento aprovado
- risco principal: a request esquecer `approved=true` e misturar orcamento Aberto
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: visual da referencia, cards, KPI, backend
- prova minima desta task: no browser, eventos aprovados em paginas de 10 e busca saindo na API
- criterio de escalada: se a store ainda tiver um unico `isLoading` para as duas listas, separar antes de seguir
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Visao geral da solucao`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Visao geral da solucao`
  - `03-design.md#Riscos e mitigacoes`
  - `framework-libs/react/rules/03_data_fetching_and_server_state.md`
  - `framework-libs/design/rules/07_data_display_and_dashboards.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueEvents.tsx`, `eventhub-vista-dashboard/src/store/proposalStore.ts`, `eventhub-vista-dashboard/src/services/proposal.service.ts`
- palavras-chave ou simbolos de busca: `fetchEvents`, `approved: true`, `EventFilterList`
- testes provaveis: fluxo manual na pagina de eventos do painel
- nao ler por padrao: `01-spec.md`, `security`, pagina de orcamentos, `summary`
