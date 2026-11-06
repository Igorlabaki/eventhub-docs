# Design — Precos minimos por periodo

## Visao geral da solucao

Uma tabela nova guarda faixas de piso por venue. O piso padrao continua em `Venue.minimumPrice`. Uma funcao pura resolve o piso da data de inicio. Os use cases de orcamento que ja comparam `minimumPrice` passam a comparar esse resultado. A aba Minimos lista e grava as faixas e edita o padrao.

## Passada transversal

- architecture: nao. Segue router, controller, use case e repositorio no monolito; sem fronteira nova e sem ADR.
- database: sim. Tabela nova, indice em `venueId`, migration aditiva, Float por D-07, `onDelete: Cascade` so no client Prisma.
- design: sim. Aba, secao no painel, formulario e estados vazio, carregando e erro, reusando Metas e Precos.
- observability: nao. Nao e servico novo; erro segue `{ title, message }`; sem dashboard.
- security: sim nas rotas novas. Auth e permissao no venue da faixa; sem pagamento, segredo ou PII nova.
- patterns/rules/06: nao para fila, cache, retry ou idempotencia. Sobreposicao resolve na leitura pelo maior preco, sem lock. A lista do venue nao pagina, como a de adicional.

## Componentes e modulos impactados

- `backend`: `prisma/schema.prisma`, migration, `src/router`, use cases e repositorio de faixa, `src/functions/resolve-minimum-price.ts`, use cases de criar e editar orcamento por pessoa e por dia
- `frontend`: `VenueGoals.tsx`, `goal-header.tsx`, componentes em `components/goal/`, store e service no modelo de `seasonalFeeStore`
- produto: uma linha em `product/07-domain-model.md` e em `product/04-user-journeys.md`

## Reuso previsto

- periodo `dd/MM` e virada de ano: a mesma conta de `seasonalFee` em `create-proposal-per-person`, extraida para a funcao pura, sem gravar piso em `SeasonalFee`
- CRUD: o desenho de `seasonalFee` (zod, factory, repositorio Prisma), com autorizacao que aquele router nao tem
- permissao: `getUserVenuePermission({ userId, organizationId, venueId })`; a string e partida por virgula, como em `ensurePermission`, mas so no venue informado
- piso padrao na tela: `updateVenue` ja usado em `VenueSettings.tsx`, enviando o venue atual mais o `minimumPrice` novo, para nao apagar os outros campos
- tela: `FeesTab`, `GoalHeader` e o card de adicional no painel de `VenueGoals.tsx`
- estado: Zustand, como `seasonalFeeStore`

Nao reutilizar `ensurePermission`: ele aceita a permissao em qualquer venue da organizacao e a mensagem e de calendario.

## Contratos e dados

Model `MinimumPricePeriod`:

- `id` UUID, `title` String, `startDay` String, `endDay` String, `price` Float, `venueId` String, `createdAt`, `updatedAt`
- relacao com `Venue`, `onDelete: Cascade`, `@@index([venueId])`, `@@map("minimum_price_period")`
- `Venue` ganha a colecao; `minimumPrice` nao muda

`resolveMinimumPrice({ minimumPrice, periods, startDate })`:

- percorre periodos com `price` maior que zero
- monta o intervalo no ano de `startDate`; se `endDay` for anterior a `startDay`, o fim cai no ano seguinte
- entre os que contem `startDate`, devolve o maior `price`
- se nenhum contem, devolve `minimumPrice` quando for maior que zero; senao devolve `0`
- `0` significa que o `if` atual nao eleva o total

API, todas com `ensureAuthenticate`:

- `POST /minimumPricePeriod/create` body `{ venueId, title, startDay, endDay, price }` exige `EDIT_VENUE_PRICES` no venue
- `GET /minimumPricePeriod/list/:venueId` exige `VIEW_VENUE_PRICES` nesse venue
- `PUT /minimumPricePeriod/update` body `{ id, title, startDay, endDay, price }` carrega a faixa e exige `EDIT_VENUE_PRICES` no `venueId` persistido; o body nao troca o venue
- `DELETE /minimumPricePeriod/delete/:id` carrega a faixa e exige `EDIT_VENUE_PRICES` no `venueId` persistido

Zod: titulo com texto, datas no formato `dd/MM`, preco numero maior que zero. O use case confirma que a data parseia.

O venue carregado pelo orcamento passa a incluir `minimumPricePeriod` junto de `seasonalFee`.

Pontos que ja leem `venue.minimumPrice` passam a ler o retorno da funcao, sem mexer na aritmetica em volta:

- `create-proposal-per-person`
- `create-proposal-per-day`
- `update-proposal-per-person`

`update-proposal-per-day` nao tem esse `if`. Nos ramos em que `totalAmountInput` igual ao total atual dispara o recalculo, entra o mesmo `if` de `create-proposal-per-day`: se o total calculado for menor que o piso, a base vira o piso e o total final e o piso mais os servicos. O ramo que grava `totalAmountInput` como total nao chama a funcao.

## Falhas, casos de borda e invariantes

- faixa so e lida ou gravada por quem tem a permissao no venue dela
- update e delete autorizam o `venueId` persistido, nao um id solto do body
- sobreposicao nao e erro; o maior preco vence
- data de inicio fora da faixa usa o padrao
- pernoite usa a data de inicio, nao o fim
- piso zero nao eleva
- total manual nao e elevado
- adicional, desconto e meta continuam nos pontos em que ja estao; o piso continua depois deles, onde o `if` atual ja esta

## Decisoes arquiteturais importantes

- tabela propria, porque `SeasonalFee.fee` e percentual e o piso e valor em reais
- Float, porque D-07 exige spec propria para sair de Float
- permissao existente de precos, checada no venue, porque a tela ja usa esse par e o pedido nao pediu permissao nova
- funcao pura para o piso, porque a comparacao esta repetida em varios ramos e a edicao por dia ainda nao a tem
- nao unificar a formula entre criar e editar: a criacao por pessoa e a edicao por pessoa ja tratam servicos de jeitos diferentes; esta feature nao corrige isso

Alternativa descartada: campo de ano na faixa. O pedido e dezembro todo ano, como o adicional de fim de ano.

Alternativa descartada: impedir sobreposicao no banco. O reveillon dentro de dezembro e um caso esperado, e o maior preco resolve.

## Riscos e mitigacoes

- gravar no venue errado: update e delete leem a faixa e autorizam o venue persistido
- esquecer um ramo de calculo: `T-03` lista os quatro use cases e testa a funcao a parte
- conflito com o request de adicionais na edicao: esta feature nao adiciona `seasonalFee` nos updates; aquele request nao remove a chamada do piso
- `updateVenue` apagar outros campos do espaco: a tela envia o payload atual do venue, como Configuracoes

## Rollout, observabilidade e rollback

- uma migration aditiva cria `minimum_price_period` e o indice; nao altera linha de `venue`
- espaco antigo fica com a colecao vazia e o piso padrao de sempre
- reverter o app deixa a tabela sem leitor
- sem feature flag, metrica ou alerta novo

## Estrategia de validacao

- `npx prisma validate` e leitura do SQL: so tabela nova e indice
- Vitest da funcao de piso: dentro da faixa, fora, sobreposicao, virada de ano, inicio em novembro com fim em dezembro, piso padrao zero
- Vitest dos use cases de faixa com repositorio falso: 201/200 no venue certo, 403 sem permissao, 400 com preco zero, 404 ou 403 em faixa de outro venue
- tela: editar o padrao, criar dezembro, recarregar, ver no painel e na aba; sem `EDIT_VENUE_PRICES`, os controles de gravar nao aparecem e a API recusa

## Fontes determinantes

- `project-decisions.md` D-02, D-03, D-05 e D-07
- `topics/backend-api.md`: fluxo router, use case, repositorio e erro `{ title, message }`
- `product/02-business-rules.md`: permissao desejada no recurso; o comportamento inseguro das rotas antigas nao e regra
- `product/08-data-model.md`: dinheiro em Float e `relationMode = "prisma"`
- `framework-libs/database/index.md` secao de schema novo
- `framework-libs/patterns/rules/06_senior_engineering_concepts.md`: sem gatilho de fila, cache ou idempotencia
- `framework-libs/node/index.md` secao de endpoint
- codigo: `Venue.minimumPrice`, `SeasonalFee`, `ensurePermission.ts`, `getUserVenuePermission`, `VenueGoals.tsx`
