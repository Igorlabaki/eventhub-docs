# Tasks — Total estimado do orcamento no painel

## Ordem macro

`T-01` extrai a conta. `T-02` (rota) e `T-03` (create e update) dependem de `T-01` e podem rodar em paralelo. `T-04` depende do contrato de `T-02`. `T-05` depende de `T-04`.

## Tasks

### T-01 - Extrair a conta do recalculo publico para uma funcao compartilhada

- objetivo: a conta de valores do recalculo publico vive em `src/functions/proposal-amounts.ts` e o use case a importa, sem mudar nenhum valor.
- cobre requisitos: `R-07`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: funcoes privadas de `use-case-recalculate-public-proposal.ts` citadas em `03-design.md#Reuso previsto`
- prompt recomendado: `normal`
- estrategia de teste: specs atuais do recalculo publico sem mudar expectativa; spec novo da funcao
- cenarios obrigatorios:
  - `PER_PERSON` com hora extra acima da duracao padrao
  - `PER_PERSON_HOUR` com e sem receita no mes
  - temporada de dezembro a janeiro aplicada a evento em janeiro
  - meta com `increasePercent` so quando ha receita
  - total abaixo do minimo devolve `minimumApplied: true`, horas extras 0 e total = minimo + servicos
  - `TIERED` e preco ausente devolvem `null`
- definition of done: `npm test -- --run` verde; `use-case-recalculate-public-proposal.spec.ts` e o do controller sem expectativa alterada; o use case nao tem mais conta propria.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a conta serve uma gravacao publica de valor
- risco principal: mudar um valor do recalculo publico ao mover a conta
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: rota de cotacao, create, update, frontend, `adjustProposalUnitPrice`
- prova minima desta task: specs do recalculo publico e da funcao verdes
- criterio de escalada: parar se algum spec atual precisar de expectativa nova
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `art56_server_v3/src/use-cases/proposal/recalculate-public-proposal/use-case-recalculate-public-proposal.ts`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_core/specs/2026-11-04-recalcular-orcamento-proposta-publica/03-design.md#Contratos e dados`
  - `.cursor/framework_core/project/project-decisions.md#D-06 Datas de evento com semantica wall-clock`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/recalculate-public-proposal/use-case-recalculate-public-proposal.spec.ts`, `art56_server_v3/src/functions/resolve-minimum-price.ts`, `art56_server_v3/src/functions/wall-clock-datetime.ts`
- palavras-chave ou simbolos de busca: `calculateAmounts`, `perPersonAmounts`, `adjustUnitPrice`, `applyWallClockSeason`, `applyMinimum`, `catalogUnitPrice`
- testes provaveis: `npm test -- --run recalculate-public-proposal proposal-amounts`
- nao ler por padrao: frontend, create, update, `security`

### T-02 - Rota autenticada de cotacao

- objetivo: `POST /proposal/quote` autoriza o usuario no espaco e devolve os valores sem gravar.
- cobre requisitos: `R-01`, `R-02`, `R-04`, `R-05`, `R-06`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: funcao de `T-01`, `quote-service-lines.ts`, molde de `VenuePriceAuthorizer`, `handleErrors`, controller do recalculo publico (lista fixa de chaves)
- prompt recomendado: `normal`
- estrategia de teste: vitest do use case com repositorios falsos, do autorizador e do controller
- cenarios obrigatorios:
  - sem `userId` lanca token; sem link ou sem as duas permissoes lanca 403; com `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` passa
  - `PER_PERSON` com servico fixo, por pessoa e por hora soma `totalAmountService`
  - `BARTER` devolve zeros sem ler servicos nem meta
  - `PER_DAY`, `TIERED` e preco ausente recusam com a mensagem de `R-05`
  - servico por hora sem horas e servico de outro espaco recusam
  - nenhum repositorio de escrita, notificacao ou historico e chamado
  - controller devolve so as seis chaves de `03-design.md#Contratos e dados`
  - rota registrada com `ensureAuthenticate`
- definition of done: specs verdes em `npm test -- --run`; rota em `router/proposal.ts`; `npx tsc --noEmit` sem erro novo nos arquivos tocados.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — rota nova que expoe valor derivado de meta e faturamento
- risco principal: rota sem autorizacao por espaco ou resposta com preco unitario
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: create, update, frontend, rota publica
- prova minima desta task: os oito cenarios verdes
- criterio de escalada: parar se a permissao precisar de valor novo no cadastro de permissoes
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md#2. Revisar autenticacao e autorizacao`
  - `.cursor/framework_global/framework-libs/node/references/node-express-coding-style.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/minimum-price-period/venue-price-authorizer.ts`, `art56_server_v3/src/use-cases/minimum-price-period/list-minimum-price-period/factory-list-minimum-price-period.ts`, `art56_server_v3/src/use-cases/proposal/recalculate-public-proposal/controller-recalculate-public-proposal.ts`, `art56_server_v3/src/router/proposal.ts`, `art56_server_v3/src/types/authenticated-request.ts`
- palavras-chave ou simbolos de busca: `getUserVenuePermission`, `HttpForbiddenError`, `PUBLIC_DATA_KEYS`, `listForQuote`, `assertChosenServiceHours`
- testes provaveis: `npm test -- --run quote-proposal`
- nao ler por padrao: create e update por pessoa, frontend, `database`

### T-03 - Create e update por pessoa usam a conta compartilhada

- objetivo: os ramos de tabela (`PER_PERSON`, `PER_PERSON_HOUR`) de criar e editar por pessoa chamam `adjustVenueUnitPrice` e `calcProposalAmounts`.
- cobre requisitos: `R-03`, `R-08`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: funcao de `T-01`; notificacao, historico, `updateServices` e ramo de Total digitado ficam como estao
- prompt recomendado: `normal`
- estrategia de teste: specs atuais de create e update; casos novos comparando o `totalAmount` gravado com `calcProposalAmounts` para a mesma entrada
- cenarios obrigatorios:
  - create `PER_PERSON` com e sem meta grava o mesmo total da funcao
  - create `PER_PERSON_HOUR` com e sem receita grava o mesmo total da funcao
  - create com total abaixo do minimo
  - update com Total igual ao salvo grava o total da funcao
  - update com temporada dezembro-janeiro e evento em janeiro aplica a taxa (mudanca intencional)
  - update com Total diferente continua em `calcCustomTotalAmount`
- definition of done: `npm test -- --run` verde; create e update por dia intactos; `adjustProposalUnitPrice` so continua usado por `update-proposal-per-day`; mudanca do update registrada em `05-state.md`.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — valor gravado em orcamento; `createPerPerson` e rota publica
- risco principal: mudar total gravado fora do caso de temporada que vira o ano
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: rota de cotacao, ramo de Total digitado, per-day, notificacao e historico
- prova minima desta task: os seis cenarios verdes e os specs atuais de create e update sem expectativa alterada, exceto o caso de temporada
- criterio de escalada: parar se outro spec atual exigir expectativa nova
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `art56_server_v3/src/use-cases/proposal/create-proposal-per-person/use-case-create-proposal-per-person.ts` nos ramos `PER_PERSON` e `PER_PERSON_HOUR`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Componentes e modulos impactados`
  - `02-clarify.md#Premissas assumidas`
  - `.cursor/framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/update-proposal-per-person/use-case-update-proposal-per-person.ts`, specs de create e update por pessoa, `art56_server_v3/src/functions/adjust-proposal-unit-price.ts`
- palavras-chave ou simbolos de busca: `totalAmountInputFormated`, `monthlyRevenueAnalysis`, `adjustProposalUnitPrice`, `hasMonthlyRevenue`, `resolveVenueMinimumPrice`
- testes provaveis: `npm test -- --run create-proposal-per-person update-proposal-per-person`
- nao ler por padrao: frontend, rota de cotacao, per-day

### T-04 - Bloco de total estimado na criacao

- objetivo: `PerPersonProposalForm` mostra o total estimado com detalhamento, atualizado com debounce, e `Usar este valor`.
- cobre requisitos: `R-09`, `R-10`, `R-11`, `R-12`, `R-13`, `R-15`
- depende de: `T-02` (contrato)
- pode rodar em paralelo com: `T-03`
- reusa: `useDebounce`, `useQuery`, `handleBackendError`, `perPersonLabel`, padrao de `hooks/notification/queries/list.ts`
- prompt recomendado: `normal`
- estrategia de teste: vitest de `buildQuoteInput` e do rotulo `(estimado)`; browser em `/venue/:id/budgets`
- cenarios obrigatorios:
  - `buildQuoteInput` devolve `null` sem data, inicio, fim ou com convidados < 1
  - preencher os quatro campos mostra Espaço, Serviços e Total; Horas extras so se > 0
  - mudar convidados atualiza uma vez depois de parar de digitar
  - espaco com minimo mostra "Preço mínimo do espaço aplicado"
  - `Usar este valor` preenche o Total; `/ pessoa` acompanha
  - Total vazio mostra `R$ X / pessoa (estimado)`
  - erro 400 mostra a mensagem no bloco e Criar Orçamento continua habilitado
  - tipo Troca mostra `R$ 0,00` sem chamar a rota
- definition of done: vitest verde; `npm run lint` sem erro novo nos arquivos tocados; fluxos vistos no browser; payload de criacao igual ao de hoje.

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — so consome rota autenticada; regra fica no backend
- risco principal: conta no front ou resposta velha sobrescrevendo a nova
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: edicao, formularios publicos, per-day, backend
- prova minima desta task: vitest do montador e do rotulo; oito fluxos no browser
- criterio de escalada: parar se precisar de estado novo fora de React Query e react-hook-form
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/proposal/forms/PerPersonProposalForm.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `01-spec.md#Criterios de aceite`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
  - `.cursor/framework_global/framework-libs/react/references/react-coding-style.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/services/proposal.service.ts`, `eventhub-vista-dashboard/src/types/proposal.ts`, `eventhub-vista-dashboard/src/hooks/notification/queries/list.ts`, `eventhub-vista-dashboard/src/lib/per-person-amount.ts`, `eventhub-vista-dashboard/src/components/SearchFilterListByQueries.tsx`
- palavras-chave ou simbolos de busca: `useDebounce`, `useQuery`, `keepPreviousData`, `perPersonLabel`, `handleBackendError`, `DashboardServiceChoices`
- testes provaveis: `npm test -- proposal-quote-input per-person-amount`
- nao ler por padrao: backend alem do contrato, `security`, `ProposalEdit.tsx`

### T-05 - Bloco de total estimado na edicao

- objetivo: `ProposalEdit` mostra o mesmo bloco e avisa o valor que sera gravado ao salvar sem mudar o Total.
- cobre requisitos: `R-14` (e `R-09` a `R-13` na edicao)
- depende de: `T-04`
- pode rodar em paralelo com: nenhuma
- reusa: `ProposalQuoteSummary`, `useProposalQuote`, `buildQuoteInput` de `T-04`
- prompt recomendado: `smart`
- estrategia de teste: browser em `/proposal/:id/edit`
- cenarios obrigatorios:
  - abrir a edicao mostra a estimativa dos valores salvos
  - mudar convidados sem mexer no Total mostra "Ao salvar sem mudar o Total, o valor passa para R$ X."
  - Total diferente do salvo esconde o aviso
  - `Usar este valor` preenche o Total
  - salvar sem mudar o Total grava o valor do aviso
- definition of done: fluxos vistos no browser; lint sem erro novo; payload de `updatePerPerson` igual ao de hoje.

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: aviso aparecer quando o backend nao vai recalcular
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: backend, criacao, `tr-01` do lote
- prova minima desta task: cinco fluxos no browser
- criterio de escalada: parar se a comparacao do Total precisar de arredondamento novo (D-07)
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalEdit.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `01-spec.md#Criterios de aceite`
  - `02-clarify.md#Premissas assumidas`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/ProposalQuoteSummary.tsx`, `eventhub-vista-dashboard/src/hooks/proposal/queries/quote.ts`
- palavras-chave ou simbolos de busca: `currentProposal.totalAmount`, `totalAmountInput`, `ProposalQuoteSummary`
- testes provaveis: browser
- nao ler por padrao: backend, `security`, `PerPersonProposalForm.tsx` alem do uso do bloco
