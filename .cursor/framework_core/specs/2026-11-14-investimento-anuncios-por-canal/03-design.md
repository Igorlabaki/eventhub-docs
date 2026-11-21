# Design — Investimento em anuncios por canal

## Visao geral da solucao

Uma coluna opcional `trafficSource` em `expense`, validada no use case pela categoria final. A regra de valor da recorrente sai da analise de despesas para uma funcao pura (`functions/expense-recurrence.ts`), usada pela analise (que passa a somar `WEEKLY`) e pelo relatorio novo; a analise tambem passa a recortar as esporadicas pelo ano wall-clock (`reportYearRange`). O relatorio segue o padrao dos blocos: `GET /venue/reports/ads` -> `ReportController` -> use case com `ReportAuthorizer` -> dois repositorios com `select` minimo -> `functions/report-ads.ts`. No front, o formulario de despesa ganha o select Canal e a aba `Financeiro` ganha o `AdsInvestmentCard` com hook React Query.

## Passada transversal

- topologia/fronteira: nao muda; uma rota nova no router `venue` e campo novo no contrato de despesa
- dados persistidos: sim; `ADD COLUMN trafficSource` nullable e indice `[venueId, category]`, aditivos, por deploy request; sem backfill
- interface: sim; select condicional no formulario, rotulo na lista, card com tabela (estados carregando/erro/vazio, `<table>` semantica com `<th scope>`)
- producao: sim; sem sinal novo (blocos atuais tambem nao tem); o 403 sai pelo `ReportAuthorizer`
- fluxo sensivel: nao; leitura agregada autenticada com `VIEW_VENUE_ANALYSIS`, sem PII nem id de proposta no payload
- conceito senior: nao; sem fila, retry, concorrencia ou cache alem do React Query

## Componentes e modulos impactados

Backend (`art56_server_v3/`):

- `prisma/schema.prisma`: `trafficSource TrafficSource?` e `@@index([venueId, category])` em `Expense`; migration `prisma/migrations/20261114120000_add_expense_traffic_source/`
- `src/functions/expense-recurrence.ts` (novo): `ADS_CHANNELS`, `recurringAmounts(type, amount)`, `resolveExpenseTrafficSource(category, trafficSource)`
- `src/use-cases/expense/analysis-expense/use-case-analysis-expense.ts`: troca o `if/else` por `recurringAmounts`
- `src/repositories/in-prisma/expense-in-prisma-repository.ts#analyze`: esporadicas com `paymentDate: reportYearRange(Number(year))` no lugar de `new Date(year, 0, 1)` / `new Date(year, 12, 31)`
- `src/zod/expense/create-expense-params-schema.ts` e `update-expense-params-schema.ts`: `trafficSource: z.enum(ADS_CHANNELS).nullable().optional()`
- `src/use-cases/expense/create-expense/`: controller passa o resultado do `parse` ao use case; use case grava `resolveExpenseTrafficSource(params.category, params.trafficSource)`
- `src/use-cases/expense/update-expense/use-case-update-expense.ts`: categoria final = `data.category ?? expense.category`; canal final = `data.trafficSource !== undefined ? data.trafficSource : expense.trafficSource`; grava o resultado de `resolveExpenseTrafficSource`
- `src/repositories/{interface,in-prisma}/expense-*`: `advertisingRows(venueId)` (`category = ADVERTISING`, `select` amount, type, recurring, paymentDate, createdAt, trafficSource)
- `src/repositories/{interface,in-prisma}/proposal-*`: `adsReportRows(where)` (`select` createdAt, trafficSource, approved, totalAmount)
- `src/functions/report-ads.ts` (novo) + spec
- `src/use-cases/venue/reports/ads/` (novo): use case e factory; `report-query.ts` reaproveita `leadTimeWhere(venueId, year)` para a populacao por `createdAt`
- `src/router/venue.ts`: `GET /reports/ads` com `ensureAuthenticate`, junto das outras `/reports/*`

Frontend (`eventhub-vista-dashboard/src`):

- `types/expense.ts`: `ExpenseTrafficSource` (cinco valores) e `trafficSource?: ExpenseTrafficSource | null` em `Expense`, `CreateExpenseParams`, `CreateExpenseDTO`
- `components/expense/expense-form.tsx`: campo `trafficSource` com `superRefine`; `useEffect` no `watch("category")` limpa o canal fora de Publicidade; `handleSubmit` envia `trafficSource: null` fora de Publicidade
- `components/expense/expense-list.tsx`: rotulo do canal ao lado do nome em Publicidade
- `types/venue.ts`, `services/venue.service.ts#getReportAds`, `hooks/venue/queries/venueReportBlocks.ts#useReportAds`
- `components/reports/report-blocks.ts`: `formatRoas`, `adsChannelLabel` + testes
- `components/reports/AdsInvestmentCard.tsx` (novo); `FinancialBalanceReport.tsx` envolve o retorno em `space-y-4` e acrescenta o card; `ReportBlock.tsx` ganha `emptyLabel?` opcional

## Reuso previsto

- `ReportAuthorizer`, `ReportController`, `reportParamsSchema`, `reportEnvelope`, `leadTimeWhere` (folga de um dia e filtro do ano local em memoria)
- `reportYearRange` para o ano wall-clock das esporadicas da analise
- `localDateParts`, `REPORT_TIME_ZONE` (`functions/local-date.ts`); `HttpBadRequestError`
- `TRAFFIC_SOURCES` (nome e cor por canal, chave comparada em minusculas como em `report-metrics.ts`); `formatCurrency` de `@/lib/utils`; `ReportBlock`
- fluxo de migration e deploy request de `project/planetscale.md` (modelo `20261113120000_add_venue_amenity_image`)

## Contratos e dados

### Despesa

```ts
type AdsChannel = "INSTAGRAM" | "FACEBOOK" | "TIKTOK" | "GOOGLE" | "OTHER";
// POST /expense/create: CreateExpense + { trafficSource?: AdsChannel | null }
// PUT /expense/update: { expenseId, data: Partial<CreateExpense> & { trafficSource?: AdsChannel | null } }
// resposta e listagem: Expense + { trafficSource: TrafficSource | null }
```

Regra unica (`resolveExpenseTrafficSource`): categoria final `ADVERTISING` sem canal -> `HttpBadRequestError("Informe o canal da despesa de Publicidade.")`; categoria final `ADVERTISING` com canal -> canal; outra categoria -> `null`.

### `GET /venue/reports/ads?venueId&year`

Mesmo schema e erros dos blocos (`month` e `eventCategory` ignorados). Envelope `{ success: true, message: "Sucesso", data, count: 1, type: "AdsReport" }`.

```ts
type AdsReportRow = {
  channel: AdsChannel | null;   // null = "Sem canal"
  spent: number;
  proposals: number;
  events: number;
  revenue: number;
  costPerProposal: number | null; // spent / proposals
  costPerEvent: number | null;    // spent / events
  roas: number | null;            // revenue / spent
};
type AdsReportData = {
  year: number;
  rows: AdsReportRow[];           // cinco canais em ordem fixa + "Sem canal" se spent > 0
  total: Omit<AdsReportRow, "channel">;
};
```

### Calculo (`buildAdsReport(expenses, proposals, year, now, timeZone)`)

- recorrente (`recurring = true`): `recurringAmounts(type, amount).monthly x activeMonths`; `activeMonths` = de `max(1, mes local do createdAt se for do ano)` ate `12` (ano passado) ou mes local de `now` (ano corrente); `0` se o ano for futuro ou se o `createdAt` for de ano posterior
- esporadica: soma `amount` quando o ano UTC do `paymentDate` (ou o ano local do `createdAt`, sem data) e o ano pedido
- proposta: so as de ano local do `createdAt` igual ao ano; canal fora dos cinco e ignorado; `events` e `revenue` so das aprovadas (`totalAmount` nulo conta 0)
- "Sem canal": custos e `roas` sempre `null`

### Recorrencia (`recurringAmounts`)

| Tipo | Mensal | Anual |
|---|---|---|
| `WEEKLY` | `amount x 52 / 12` | `amount x 52` |
| `BIWEEKLY` | `amount x 2` | `amount x 24` |
| `MONTHLY` | `amount` | `amount x 12` |
| `ANNUAL` | `amount / 12` | `amount` |
| `SPORADIC` | `0` | `0` |

### Banco

```sql
ALTER TABLE `expense` ADD COLUMN `trafficSource` ENUM('AIRBNB','GOOGLE','INSTAGRAM','TIKTOK','OTHER','FRIEND','FACEBOOK') NULL;
CREATE INDEX `expense_venueId_category_idx` ON `expense`(`venueId`, `category`);
```

A coluna usa o enum inteiro do Prisma; a restricao aos cinco canais fica no zod.

## Falhas, bordas e invariantes

- invariante: `trafficSource` nao nulo so com `category = ADVERTISING` em escrita nova; dado antigo pode ter Publicidade com `null`
- invariante: soma de `spent` das linhas = `total.spent`
- o controller de criar hoje passa o `body` cru; passar o resultado do `parse` evita gravar campo nao validado
- recorte das esporadicas da analise: hoje `analyze` usa `gte: new Date(year, 0, 1)` e `lt: new Date(year, 12, 31)` (hora local; fim em 31 de janeiro do ano seguinte), entao esporadicas de janeiro do ano seguinte entram no Financeiro e, com servidor fora de UTC, o pagamento de 1/1 fica de fora; corrigido na `T-02` com `reportYearRange(year)`, porque `paymentDate` e meia-noite UTC (wall-clock)
- invariante: uma esporadica entra em exatamente um ano da analise, o do ano UTC do `paymentDate`, igual ao relatorio de anuncios
- excluir uma recorrente apaga o custo passado (limitacao aceita)

## Decisoes arquiteturais importantes

- usaremos a rota `/venue/reports/ads` porque reaproveita `ReportAuthorizer`, zod e envelope; `/venue/:venueId/ads-report` descartado por fugir do padrao
- calculo em funcao pura com `now` injetado porque "mes atual" precisa de teste deterministico
- filtro do ano das despesas em memoria (todas as `ADVERTISING` do espaco) porque o volume e pequeno e a recorrente nao tem data no ano; o indice `[venueId, category]` cobre a leitura
- a validacao do canal mora no use case, nao no `refine` do zod, porque a edicao e parcial e precisa da categoria gravada
- recorrencia em um helper unico para analise e relatorio nao divergirem; descartado copiar o `if/else`
- usaremos `reportYearRange` no `analyze` porque ja e o recorte wall-clock dos relatorios; descartado `new Date(year + 1, 0, 1)` (continuaria em hora local)

## Riscos, rollout, observabilidade e rollback

- rollout: `T-01` na `main` -> API (`T-02` a `T-05`) -> front (`T-06` e `T-07`) logo em seguida; entre API e front, o front antigo recebe 400 ao salvar Publicidade
- risco: `WEEKLY` muda o Financeiro de quem tem despesa semanal; registrar no topic e avisar na entrega
- risco: o recorte corrigido tira do ano as esporadicas de janeiro do ano seguinte; total do ano e comparativo com o ano anterior podem cair; avisar na entrega
- observabilidade: nenhum sinal novo; erros pelo `handleErrors`
- rollback: front e API revertem por deploy anterior; a coluna nullable pode ficar (aditiva)

## Estrategia de validacao

- unitario puro: `expense-recurrence.spec.ts`, `report-ads.spec.ts`
- use cases com fakes: create/update de despesa, analise com `WEEKLY`, relatorio (authorizer e envelope)
- repositorio com `PrismaClient` fake: `analyze` monta o `where` com `reportYearRange(year)`
- front: `report-blocks.test.ts` (formatadores), helper do formulario se extraido; `npm run build`
- banco: `npx prisma validate`; `SHOW COLUMNS`/`SHOW INDEX` na `main`
- browser: cadastrar despesa de Publicidade, ver o card na aba `Financeiro`

## Docs determinantes

- `topics/reports-and-kpis.md#Blocos agregados (/venue/reports/*)` e `#Despesas`
- `specs/2026-11-10-novos-blocos-relatorios/03-design.md` (padrao dos blocos)
- `project/planetscale.md` (deploy request)
- `topics/improvement-backlog.md#PRICE-05`
