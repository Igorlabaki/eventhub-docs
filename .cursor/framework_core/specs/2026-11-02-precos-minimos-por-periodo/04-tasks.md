# Tasks — Precos minimos por periodo

## Ordem macro

1. `T-01` cria a tabela
2. `T-02` e `T-03` podem seguir em paralelo
3. `T-04` espera o contrato da API

Nao executar o conjunto num unico passo. Depois do review, `fw:split` separa `backend` e `frontend`.

## Tasks

### T-01 - Criar a tabela minimum_price_period

- objetivo: persistir faixa de piso com titulo, periodo, valor e vinculo ao venue
- cobre requisitos: `R-01`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: model `SeasonalFee` so como referencia de id UUID, `venueId` e indice
- prompt recomendado: `smart`
- estrategia de teste: `npx prisma validate` e revisao do SQL gerado
- cenarios obrigatorios: tabela nova com indice em `venueId`; `price` Float; `onDelete: Cascade` so no client Prisma; migration sem `UPDATE` em `venue`
- definition of done: model no schema, colecao em `Venue`, migration aditiva aplicada no ambiente local, SQL sem backfill; sem promocao de topic

#### Context Pack

- frente principal: banco
- superficie sensivel: nao
- risco principal: reutilizar `SeasonalFee` ou assumir FK fisica
- repos tocados: `backend`
- fora de escopo desta task: rotas, calculo do orcamento, tela
- prova minima desta task: `npx prisma validate` ok e o SQL da migration so cria `minimum_price_period` e o indice
- criterio de escalada: parar se a migration precisar reescrever `venue` ou converter Float para Decimal
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`
- documentos obrigatorios:
  - `.cursor/framework_global/framework-libs/database/index.md#Modelar schema novo ou dominio novo`
  - `.cursor/framework_global/framework-libs/database/skills/designing-relational-schemas.md`
  - `.cursor/framework_core/project/project-decisions.md#D-03 MySQL com integridade gerida pelo Prisma`
  - `.cursor/framework_core/project/project-decisions.md#D-07 Dinheiro em Float no legado`
- caminhos candidatos: model `SeasonalFee` e model `Venue` em `art56_server_v3/prisma/schema.prisma`
- palavras-chave ou simbolos de busca: `minimumPrice`, `SeasonalFee`, `relationMode`
- testes provaveis: `npx prisma validate` em `art56_server_v3/`
- nao ler por padrao: `security`, `04-tasks.md` inteiro, `01-spec.md`

### T-02 - Expor o CRUD da faixa com permissao no venue

- objetivo: criar, listar, alterar e remover faixa so de quem tem a permissao de precos naquele venue
- cobre requisitos: `R-02`, `R-03`, `R-04`, `R-05`, `R-06`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: factory, zod e repositorio de `seasonal-fee`; `getUserVenuePermission`
- prompt recomendado: `normal`
- estrategia de teste: Vitest do use case com repositorio falso
- cenarios obrigatorios: criar e listar no venue certo; 403 sem a permissao daquele venue; 400 com preco zero ou data invalida; 401 sem usuario; update e delete de faixa de outro venue nao gravam
- definition of done: rotas montadas em `server.ts`, use cases autorizam o venue persistido, testes negativos passando; sem promocao de topic

#### Context Pack

- frente principal: API do backend
- superficie sensivel: sim
- risco principal: liberar faixa de outro venue ou copiar `ensurePermission`
- repos tocados: `backend`
- fora de escopo desta task: calculo do orcamento, tela, permissao nova
- prova minima desta task: os testes do use case cobrem 403, 400 e a gravacao no venue autorizado
- criterio de escalada: parar se a checagem exigir permissao nova ou backfill
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `.cursor/framework_global/framework-libs/node/index.md#Criacao de endpoint Core API`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `art56_server_v3/src/middleware/ensurePermission.ts`
  - `art56_server_v3/src/repositories/in-prisma/user-venue-permission-in-prisma-repository.ts` metodo `getUserVenuePermission`
  - `.cursor/framework_core/project/project-decisions.md#D-05 Autorizacao parcialmente client-side`
- caminhos candidatos: `art56_server_v3/src/router/seasonal-fee.ts` e `art56_server_v3/src/use-cases/seasonal-fee/create-seasonal-fee/`
- palavras-chave ou simbolos de busca: `EDIT_VENUE_PRICES`, `VIEW_VENUE_PRICES`, `ensureAuthenticate`, `getUserVenuePermission`
- testes provaveis: `npm test -- --run` em `art56_server_v3/`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, tela de Metas e Precos

### T-03 - Resolver o piso na data do orcamento

- objetivo: o calculo automatico usar a faixa da data de inicio, ou o piso padrao, sem alterar adicional e desconto
- cobre requisitos: `R-07`, `R-08`, `R-09`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: comparacao de intervalo ja feita com `seasonalFee` na criacao por pessoa; `if` de piso da criacao por dia
- prompt recomendado: `normal`
- estrategia de teste: Vitest da funcao pura, sem banco
- cenarios obrigatorios: dia dentro da faixa; dia fora usa o padrao; duas faixas no mesmo dia usam a maior; 20/12 a 05/01 cobre 02/01 e nao cobre 15/01; inicio em 30/11 com faixa de dezembro usa o padrao; piso zero nao eleva
- definition of done: `resolve-minimum-price.ts` coberta pelos cenarios; os tres use cases que ja leem `minimumPrice` leem o retorno; a edicao por dia aplica o piso so no ramo que recalcula sozinho; nenhum update ganha `seasonalFee`; sem promocao de topic

#### Context Pack

- frente principal: calculo de valor do orcamento
- superficie sensivel: nao
- risco principal: elevar total digitado a mao ou apagar o ponto em que adicional e desconto ja entram na criacao
- repos tocados: `backend`
- fora de escopo desta task: CRUD, tela, paridade de adicional na edicao, unificar servicos e hora extra entre criar e editar
- prova minima desta task: o Vitest da funcao passa nos cenarios obrigatorios e a edicao por dia deixa de ignorar o piso no ramo automatico
- criterio de escalada: parar se a mudanca exigir alterar a formula de `seasonalFee` ou de meta
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `art56_server_v3/src/use-cases/proposal/create-proposal-per-person/use-case-create-proposal-per-person.ts` trecho de `seasonalFee` e de `minimumPrice`
  - `art56_server_v3/src/use-cases/proposal/create-proposal-per-day/use-case-create-proposal-per-day.ts` trecho de `minimumPrice`
  - `art56_server_v3/src/use-cases/proposal/update-proposal-per-person/use-case-update-proposal-per-person.ts` trecho de `minimumPrice`
  - `art56_server_v3/src/use-cases/proposal/update-proposal-per-day/use-case-update-proposal-per-day.ts` ramos de `totalAmountInput`
  - `.cursor/framework_core/specs/2026-11-02-precos-minimos-por-periodo/02-clarify.md#Perguntas de erro e borda ainda abertas`
- caminhos candidatos: `art56_server_v3/src/functions/transform-date.ts`
- palavras-chave ou simbolos de busca: `minimumPrice`, `isWithinInterval`, `totalAmountInput`, `seasonalFee`
- testes provaveis: `npm test -- --run` em `art56_server_v3/`
- nao ler por padrao: `security`, `design`, `04-tasks.md` inteiro, `01-spec.md`

### T-04 - Mostrar Minimos em Metas e Precos

- objetivo: a aba e o painel exibem o piso padrao e as faixas, e quem edita precos grava os dois
- cobre requisitos: `R-11`, `R-12`, `R-13`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: `FeesTab`, `GoalHeader`, `seasonalFeeStore`, `hasEditPermission` e `updateVenue` de `VenueSettings.tsx`
- prompt recomendado: `normal`
- estrategia de teste: exercitar a aba no browser, com recarga
- cenarios obrigatorios: editar o piso padrao e ver o valor ao recarregar; criar faixa 01/12 a 31/12 e ve-la na aba e no painel; lista vazia oferece Nova faixa a quem edita; quem nao tem `EDIT_VENUE_PRICES` nao ve controle de gravar; site, contrato e pagamento nao ganham leitura de faixa
- definition of done: aba Minimos no mesmo grupo das outras, secao no painel, store Zustand e servico HTTP; `product/07-domain-model.md` cita a faixa no venue e `product/04-user-journeys.md` cita piso por periodo na configuracao de precos; sem topic novo

#### Context Pack

- frente principal: tela Metas e Precos
- superficie sensivel: nao
- risco principal: salvar o piso padrao apagando os outros campos do venue
- repos tocados: `frontend`
- fora de escopo desta task: schema, rotas, calculo do orcamento, permissao nova
- prova minima desta task: na aba, editar o padrao, criar dezembro, recarregar e ver os dois; o painel mostra o resumo
- criterio de escalada: parar se a gravacao do padrao exigir endpoint novo ou se a tela precisar de outra lib de estado
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Reuso previsto`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_global/framework-libs/react/index.md#Criacao de pagina React`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
  - `eventhub-vista-dashboard/src/pages/VenueGoals.tsx` abas e `hasEditPermission`
  - `eventhub-vista-dashboard/src/components/goal/FeesTab.tsx`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/goal/goal-header.tsx`, `eventhub-vista-dashboard/src/store/seasonalFeeStore.ts`, `eventhub-vista-dashboard/src/pages/VenueSettings.tsx` campo `minimumPrice`
- palavras-chave ou simbolos de busca: `EDIT_VENUE_PRICES`, `GoalHeader`, `updateVenue`, `minimumPrice`
- testes provaveis: `npm run build` e `npm run lint` em `eventhub-vista-dashboard/`; fluxo manual na aba
- nao ler por padrao: `security`, `04-tasks.md` inteiro, `01-spec.md`, use cases de orcamento
