# Tasks — Investimento em anuncios por canal

## Ordem macro

1. `T-01`: coluna, indice, migration e deploy request. Codigo primeiro; aplicar na `main` exige aprovacao.
2. `T-02`: helper de recorrencia, `WEEKLY` e recorte do ano das esporadicas na analise. Paralelo com `T-01`.
3. `T-03`: contrato de despesa com canal. Depende de `T-01` (codigo do schema) e `T-02` (`ADS_CHANNELS`, `resolveExpenseTrafficSource`).
4. `T-04`: funcao pura do relatorio. Depende de `T-02`. Paralelo com `T-01` e `T-03`.
5. `T-05`: endpoint `/venue/reports/ads`. Depende de `T-01` e `T-04`.
6. `T-06`: formulario e lista de despesa. Depende de `T-03`.
7. `T-07`: card na aba `Financeiro`. Pode comecar pelo contrato de `03-design.md`; prova real depois de `T-05`.
8. `T-08`: docs, backlog e browser. Depende de todas.

Deploy: `T-01` na `main`, depois a API (`T-02` a `T-05`), depois o front (`T-06` e `T-07`) logo em seguida.

## Tasks

### T-01 - Coluna trafficSource e indice em expense

- objetivo: `expense.trafficSource` (nullable) e `expense_venueId_category_idx` existem no schema, na migration versionada e na `main`
- cobre requisitos: `R-01`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`, `T-04`
- reusa: fluxo de branch e deploy request de `project/planetscale.md`
- prompt recomendado: `normal`
- estrategia de teste: `npx prisma validate`; leitura de volta na branch e na `main`
- cenarios obrigatorios:
  - `schema.prisma` com `trafficSource TrafficSource?` e `@@index([venueId, category])` em `Expense`
  - `migration.sql` com o `ALTER TABLE` e o `CREATE INDEX` de `03-design.md#Banco`
  - branch criada a partir da `main`, DDL aplicada nela e deploy request aberto
  - deploy request so aplicado com aprovacao nomeada
- definition of done:
  - validate verde; `npx prisma generate` atualiza o client
  - deploy request `complete`, numero em `05-state.md` e `project/planetscale.md`
  - `product/08-data-model.md` com o campo e o indice

#### Context Pack

- frente principal: banco
- superficie sensivel: sim — DDL em producao
- risco principal: API nova no ar sem a coluna, ou DDL direto na `main`
- repos tocados: `backend`, PlanetScale `ar756`
- fora de escopo desta task: validacao do canal, relatorio, tela
- prova minima desta task: `pscale sql ar756 main --org igorlabakig --format json --query "SHOW COLUMNS FROM expense LIKE 'trafficSource'"` devolve a coluna nullable e `SHOW INDEX FROM expense` lista `expense_venueId_category_idx`
- criterio de escalada: qualquer DDL alem de `ADD COLUMN` nullable e `CREATE INDEX`, ou falha do deploy request, faz parar e reportar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Banco`
- libs obrigatorias: `database`
- documentos obrigatorios:
  - `.cursor/framework_core/project/planetscale.md#Fluxo real de schema`
  - `.cursor/framework_core/project/planetscale.md#Permissoes do agente`
  - `.cursor/framework_global/framework-libs/database/index.md`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` (`model Expense`); `art56_server_v3/prisma/migrations/20261113120000_add_venue_amenity_image/migration.sql` (modelo)
- palavras-chave ou simbolos de busca: `model Expense`, `enum TrafficSource`, `@@map("expense")`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: use cases, frontend, topics alem do data model

### T-02 - Helper de recorrencia, WEEKLY e recorte do ano na analise de despesas

- objetivo: `functions/expense-recurrence.ts` com `ADS_CHANNELS`, `recurringAmounts` e `resolveExpenseTrafficSource`; `use-case-analysis-expense.ts` usa `recurringAmounts` e passa a somar `WEEKLY`; `analyze` recorta esporadicas com `reportYearRange(year)`
- cobre requisitos: `R-05`, `R-06`, `R-15`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-04` (que importa o helper)
- reusa: `HttpBadRequestError`, `reportYearRange`
- prompt recomendado: `smart`
- estrategia de teste: unitario puro, use case com repositorio fake e repositorio com `PrismaClient` fake (captura o `where` de `findMany`)
- cenarios obrigatorios:
  - `WEEKLY` 120: mensal 520, anual 6240
  - `BIWEEKLY` 100: 200 e 2400; `MONTHLY` 100: 100 e 1200; `ANNUAL` 1200: 100 e 1200; `SPORADIC`: 0 e 0
  - `resolveExpenseTrafficSource("ADVERTISING", undefined | null)` lanca 400 com "Informe o canal da despesa de Publicidade."; `("ADVERTISING", "TIKTOK")` -> `"TIKTOK"`; `("TAX", "INSTAGRAM")` -> `null`
  - analise com uma `WEEKLY` recorrente de 120 e uma `MONTHLY` de 100: `total.monthly` 620, `total.annual` 7440; esporadicas inalteradas
  - `analyze({ venueId, year: "2026" })` passa `paymentDate: { gte: 2026-01-01T00:00:00.000Z, lt: 2027-01-01T00:00:00.000Z }` e mantem o ramo `recurring: true`
  - com `TZ=America/Sao_Paulo` o intervalo continua em UTC (pagamento de 2026-01-01 entra; de 2027-01-15 nao entra em 2026)
- definition of done:
  - specs verdes em `npm test -- --run`
  - `PRICE-05` e o recorte marcados para registrar como resolvidos na `T-08`

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: mudar o valor de `MONTHLY`, `BIWEEKLY` ou `ANNUAL` sem querer ao trocar o `if/else`, ou perder o ramo das recorrentes ao trocar o `where`
- repos tocados: `backend`
- fora de escopo desta task: recorte das recorrentes (continuam todas, sem olhar cadastro), schema, relatorio novo
- prova minima desta task: `npx vitest run src/functions/expense-recurrence.spec.ts src/use-cases/expense/analysis-expense src/repositories/in-prisma/expense-in-prisma-repository.spec.ts` verde com os cenarios acima
- criterio de escalada: se algum teste existente do Financeiro no front depender do valor antigo, reportar antes de ajustar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Recorrencia (recurringAmounts)`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `.cursor/framework_core/topics/improvement-backlog.md#PRICE-05 — Despesa recorrente WEEKLY ignorada na analise`
  - `.cursor/framework_global/framework-libs/node/index.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/expense/analysis-expense/use-case-analysis-expense.ts`; `src/repositories/in-prisma/expense-in-prisma-repository.ts#analyze`; `src/repositories/interface/expense-repository-interface.ts`; `src/functions/report-year-range.ts`; `src/errors/errors-type/htttp-bad-request-error.ts`
- palavras-chave ou simbolos de busca: `recorringMap`, `mensalValue`, `anualValue`, `ExpenseType`, `analyze`, `reportYearRange`
- testes provaveis: `src/functions/expense-recurrence.spec.ts` (novo); `src/use-cases/expense/analysis-expense/use-case-analysis-expense.spec.ts` (novo); `src/repositories/in-prisma/expense-in-prisma-repository.spec.ts` (novo)
- nao ler por padrao: frontend, rotas de relatorio

### T-03 - Canal no contrato de criar e editar despesa

- objetivo: create e update aceitam `trafficSource`, gravam o canal so em Publicidade e recusam Publicidade sem canal
- cobre requisitos: `R-02`, `R-03`, `R-04`
- depende de: `T-01` (client Prisma com o campo), `T-02`
- pode rodar em paralelo com: `T-04`
- reusa: `resolveExpenseTrafficSource`, `ADS_CHANNELS`
- prompt recomendado: `normal`
- estrategia de teste: use cases com repositorio fake; schemas zod
- cenarios obrigatorios:
  - criar Publicidade com `INSTAGRAM`: grava `INSTAGRAM`
  - criar Publicidade sem canal: 400 com a mensagem
  - criar Publicidade com `FRIEND`: 400 do zod
  - criar Manutencao com `GOOGLE`: grava `null`
  - editar Publicidade -> Imposto sem enviar canal: grava `null`
  - editar so o valor de uma Publicidade com `TIKTOK`: canal preservado
  - editar so o valor de uma Publicidade antiga sem canal: 400
  - controller de criar passa ao use case o resultado do `parse`
- definition of done:
  - specs verdes; listagem devolve `trafficSource`
  - nenhum campo nao validado chega ao Prisma no create

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: edicao parcial apagar o canal gravado ou aceitar Publicidade sem canal
- repos tocados: `backend`
- fora de escopo desta task: permissao das rotas `/expense/*`, `getByName` duplicado, analise, front
- prova minima desta task: `npx vitest run src/use-cases/expense src/zod/expense` verde com os oito cenarios
- criterio de escalada: se o front atual enviar campos fora do schema no create (o `parse` passaria a descartar), reportar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Despesa`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_global/framework-libs/node/index.md`
- caminhos candidatos: `art56_server_v3/src/zod/expense/create-expense-params-schema.ts`, `update-expense-params-schema.ts`; `src/use-cases/expense/create-expense/{controller,use-case}-create-expense.ts`; `src/use-cases/expense/update-expense/use-case-update-expense.ts`; `src/repositories/in-prisma/expense-in-prisma-repository.ts` (`create`, `update`)
- palavras-chave ou simbolos de busca: `createExpenseRequestParams`, `updateExpenseSchema`, `parseDateOnlyWallClock`, `getById`
- testes provaveis: `src/use-cases/expense/create-expense/use-case-create-expense.spec.ts`, `update-expense/use-case-update-expense.spec.ts` (novos)
- nao ler por padrao: relatorios, frontend

### T-04 - Funcao pura do relatorio de anuncios

- objetivo: `buildAdsReport(expenses, proposals, year, now, timeZone)` devolve `AdsReportData` conforme o contrato
- cobre requisitos: `R-07`, `R-08`, `R-09`, `R-11`
- depende de: `T-02`
- pode rodar em paralelo com: `T-01`, `T-03`
- reusa: `recurringAmounts`, `ADS_CHANNELS`, `localDateParts`, `REPORT_TIME_ZONE`
- prompt recomendado: `normal`
- estrategia de teste: unitario puro com `now` fixo
- cenarios obrigatorios:
  - `now` 2026-12-10: mensal 1.000 cadastrada em 2026-11-05 vale 2.000 em 2026; cadastrada em 2025-12-20 vale 12.000 em 2026 e 1.000 em 2025
  - mesma despesa vista em 2027: 0; `WEEKLY` 120 cadastrada em janeiro, `now` em marco: 1.560
  - esporadica com `paymentDate` 2026-01-01T00:00Z conta em 2026; sem `paymentDate`, usa o `createdAt` local (2026-01-01T01:00Z = 31/12/2025 em SP, conta em 2025)
  - proposta criada 2026-01-01T02:00Z (31/12 em SP) fica fora de 2026
  - Instagram 3.000, 30 orcamentos, 6 aprovados somando 24.000: 100, 500, `roas` 8
  - canal so com gasto: custos `null`, `roas` 0; canal so com orcamentos: custos e `roas` `null`
  - Publicidade sem canal 500: linha `channel: null`, custos e `roas` `null`; total soma os 500 no `spent`
  - propostas `FRIEND` e `AIRBNB` fora das linhas e do total; cinco canais sempre presentes na ordem fixa
- definition of done:
  - `report-ads.spec.ts` verde
  - soma dos `spent` das linhas = `total.spent`

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: contar meses alem do mes atual ou antes do cadastro, ou usar fuso errado em `paymentDate` (UTC) e `createdAt` (SP)
- repos tocados: `backend`
- fora de escopo desta task: repositorios, rota, autorizacao
- prova minima desta task: `npx vitest run src/functions/report-ads.spec.ts` verde com os oito cenarios
- criterio de escalada: se a regra de meses ativos gerar ambiguidade nao coberta em `02-clarify.md`, parar e registrar
- nivel de autonomia: `L3`

#### Minimal Read Set

- ler primeiro: `03-design.md#Calculo (buildAdsReport(expenses, proposals, year, now, timeZone))`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `03-design.md#GET /venue/reports/ads?venueId&year`
  - `02-clarify.md#Premissas assumidas`
- caminhos candidatos: `art56_server_v3/src/functions/report-lead-time.ts` (modelo); `src/functions/local-date.ts`; `src/functions/expense-recurrence.ts`
- palavras-chave ou simbolos de busca: `localDateParts`, `REPORT_TIME_ZONE`, `buildLeadTime`
- testes provaveis: `src/functions/report-ads.spec.ts` (novo)
- nao ler por padrao: use cases, Prisma, frontend

### T-05 - Endpoint GET /venue/reports/ads

- objetivo: rota autenticada que autoriza, le despesas de Publicidade e propostas do ano e devolve `buildAdsReport` no envelope dos blocos
- cobre requisitos: `R-10`
- depende de: `T-01`, `T-04`
- pode rodar em paralelo com: `T-06`, `T-07`
- reusa: `ReportAuthorizer`, `reportAuthorizerFactory`, `ReportController`, `reportParamsSchema`, `reportEnvelope`, `leadTimeWhere`
- prompt recomendado: `normal`
- estrategia de teste: use case com fakes, no estilo de `reports.spec.ts`
- cenarios obrigatorios:
  - authorizer recusa: repositorios nao sao chamados
  - `adsReportRows` recebe `leadTimeWhere(venueId, year)` sem categoria
  - `advertisingRows` recebe o `venueId`
  - resposta `{ success: true, message: "Sucesso", count: 1, type: "AdsReport" }` com `data.year` e cinco linhas
  - rota `/reports/ads` registrada junto das outras `/reports/*`
- definition of done:
  - spec verde; `npm test -- --run` sem regressao
  - `GET /venue/reports/ads` sem token devolve 401 no localhost

#### Context Pack

- frente principal: backend
- superficie sensivel: nao — reaproveita o authorizer existente, sem mudar runtime de auth
- risco principal: rota sem `ensureAuthenticate` ou sem o `assert` antes da leitura
- repos tocados: `backend`
- fora de escopo desta task: endpoints antigos de relatorio, filtros de mes e categoria
- prova minima desta task: spec do use case verde e `curl` sem token em `/venue/reports/ads?venueId=x&year=2026` devolve 401
- criterio de escalada: se o router precisar mudar a ordem de rotas existentes, reportar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Componentes e modulos impactados`
- libs obrigatorias: `node`, `database`
- documentos obrigatorios:
  - `.cursor/framework_core/topics/reports-and-kpis.md#Blocos agregados (/venue/reports/*)`
  - `.cursor/framework_global/framework-libs/node/index.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/venue/reports/lead-time/` (modelo de use case e factory); `report-query.ts`; `reports.spec.ts`; `src/router/venue.ts` (rotas `/reports/*`); `src/repositories/in-prisma/proposal-in-prisma-repository.ts#leadTimeRows`; `src/repositories/interface/proposal-repository-interface.ts#ReportProposalWhere`; `src/repositories/in-prisma/expense-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `GetLeadTimeReportUseCase`, `leadTimeRows`, `leadTimeWhere`, `reportEnvelope`, `getLeadTimeReportFactory`
- testes provaveis: `src/use-cases/venue/reports/reports.spec.ts` (novo bloco) ou `ads/use-case-get-ads-report.spec.ts`
- nao ler por padrao: `security` (sem mudanca de auth), funcoes dos outros blocos

### T-06 - Canal no formulario e na lista de despesas

- objetivo: o formulario mostra e exige o Canal so em Publicidade e envia `trafficSource` coerente; a lista mostra o canal
- cobre requisitos: `R-12`
- depende de: `T-03`
- pode rodar em paralelo com: `T-05`, `T-07`
- reusa: `ui/select`, `FormField`, nomes de `TRAFFIC_SOURCES`
- prompt recomendado: `normal`
- estrategia de teste: helper puro testado (`expenseTrafficSourcePayload(category, trafficSource)`), build
- cenarios obrigatorios:
  - categoria Publicidade: select com Instagram, Facebook, TikTok, Google, Outros; sem canal o submit mostra "Selecione o canal"
  - trocar para Manutencao esconde e limpa o canal; payload com `trafficSource: null`
  - editar despesa com canal: select preenchido
  - editar Publicidade antiga sem canal: submit bloqueado ate escolher
  - lista: "Instagram" ao lado do nome em despesa de Publicidade com canal
- definition of done:
  - `npm test` e `npm run build` verdes; lint sem erro novo nos arquivos tocados

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: select controlado por `defaultValue` nao refletir o `reset` da edicao
- repos tocados: `frontend`
- fora de escopo desta task: card do relatorio, outros campos do formulario
- prova minima desta task: teste do helper verde, `npm run build` ok e, no browser, criar Publicidade sem canal e ver a mensagem
- criterio de escalada: se o store de despesa transformar o payload (perdendo `null`), reportar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Despesa`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/expense/expense-form.tsx`, `expense-list.tsx`; `src/types/expense.ts`; `src/pages/VenueExpenses.tsx` (`handleExpenseFormSubmit`); `src/store/expenseStore.ts`; `src/components/reports/report-metrics.ts#TRAFFIC_SOURCES`
- palavras-chave ou simbolos de busca: `expenseCategoryOptions`, `superRefine`, `form.watch`, `ExpenseCategory.ADVERTISING`
- testes provaveis: `src/components/expense/expense-traffic-source.test.ts` (novo)
- nao ler por padrao: backend, relatorios

### T-07 - Card Investimento em anuncios na aba Financeiro

- objetivo: `AdsInvestmentCard` busca `/venue/reports/ads` e mostra a tabela com linha de total abaixo do card financeiro
- cobre requisitos: `R-13`
- depende de: contrato de `03-design.md`; prova real depois de `T-05`
- pode rodar em paralelo com: `T-05`, `T-06`
- reusa: `ReportBlock` (com `emptyLabel?` novo), `useQuery` de `venueReportBlocks.ts`, `formatCurrency`, `TRAFFIC_SOURCES`
- prompt recomendado: `normal`
- estrategia de teste: formatadores puros em `report-blocks.test.ts`; build
- cenarios obrigatorios:
  - `formatRoas(8)` = `8,0x`; `formatRoas(null)` = `—`; `adsChannelLabel(null)` = `Sem canal`; `adsChannelLabel("TIKTOK")` = `TikTok`
  - tabela com colunas na ordem do `R-13` e linha de total em destaque
  - `null` exibido como `—`; moeda em BRL
  - vazio quando `total.spent === 0`, com texto pedindo despesa de Publicidade com canal
  - erro com `Tentar de novo`; ano do seletor da pagina
  - tabela rola na horizontal em tela estreita
- definition of done:
  - `npm test` e `npm run build` verdes; subtitulo explica "orcamentos criados em {ano}"

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: card bloquear a aba quando a API falha (deve falhar so no card)
- repos tocados: `frontend`
- fora de escopo desta task: grafico, filtro de categoria, mudar `FinancialReportCard`
- prova minima desta task: `report-blocks.test.ts` verde, `npm run build` ok e card visivel na aba `Financeiro` com dados ou vazio
- criterio de escalada: se `ReportBlock` precisar de mudanca alem do `emptyLabel?`, reportar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#GET /venue/reports/ads?venueId&year`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/topics/reports-and-kpis.md#Blocos agregados (/venue/reports/*)`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/reports/LeadTimeCard.tsx` (modelo); `ReportBlock.tsx`; `report-blocks.ts`; `FinancialBalanceReport.tsx`; `src/hooks/venue/queries/venueReportBlocks.ts`; `src/services/venue.service.ts#getReportLeadTime`; `src/types/venue.ts`
- palavras-chave ou simbolos de busca: `useReportLeadTime`, `ReportBlockResponse`, `EMPTY_BLOCK_LABEL`, `formatCurrency`, `TRAFFIC_SOURCES`
- testes provaveis: `src/components/reports/report-blocks.test.ts`
- nao ler por padrao: backend, `FinancialReportCard.tsx` alem do ponto de insercao

### T-08 - Docs, backlog e prova no browser

- objetivo: memoria do core atualizada e fluxo provado no painel
- cobre requisitos: `R-14`
- depende de: `T-01` a `T-07`
- pode rodar em paralelo com: nenhuma
- reusa: formato das secoes atuais dos docs
- prompt recomendado: `smart`
- estrategia de teste: leitura dos docs; browser
- cenarios obrigatorios:
  - `topics/reports-and-kpis.md`: card novo, janela por `createdAt`, regra de meses ativos, `WEEKLY` corrigido, esporadicas da analise pelo ano UTC do `paymentDate`
  - `project/api-endpoints.md`: `/venue/reports/ads` e `trafficSource` no contrato de despesa
  - `product/08-data-model.md`: coluna e indice (se a `T-01` nao fez)
  - `topics/improvement-backlog.md`: `PRICE-05` resolvido (criterio x52/12); recorte das esporadicas em `/expense/analysis` registrado como encontrado e resolvido nesta spec
  - browser: despesa de Publicidade com canal aparece no card do ano
- definition of done:
  - docs atualizados; `05-state.md` com a prova; linha do `BOARD.md` atualizada

#### Context Pack

- frente principal: documentacao
- superficie sensivel: nao
- risco principal: usar o banco de producao no browser sem aprovacao (criar despesa grava em producao)
- repos tocados: `eventhub-docs`
- fora de escopo desta task: codigo
- prova minima desta task: docs com as mudancas acima e browser com o card renderizado (ou bloqueio registrado)
- criterio de escalada: gravar despesa no banco real exige aprovacao nomeada
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `05-state.md`
- libs obrigatorias: nenhuma
- documentos obrigatorios:
  - `.cursor/framework_core/topics/reports-and-kpis.md#Despesas`
  - `.cursor/framework_core/project/api-endpoints.md`
  - `.cursor/framework_core/topics/improvement-backlog.md#PRICE-05 — Despesa recorrente WEEKLY ignorada na analise`
- caminhos candidatos: os quatro docs acima e `product/08-data-model.md`
- palavras-chave ou simbolos de busca: `expense/analysis`, `PRICE-05`, `/venue/reports/`
- testes provaveis: nenhum
- nao ler por padrao: codigo alem do necessario para confirmar nomes
