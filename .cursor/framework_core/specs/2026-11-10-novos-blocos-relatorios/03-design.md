# Design — Novos blocos nos relatorios

## Visao geral da solucao

Quatro endpoints GET em `/venue/reports/*`, cada um com controller -> zod -> use case -> repositorio. O use case chama um `ReportAuthorizer` antes de qualquer leitura, busca linhas com `select` minimo e entrega o calculo a funcoes puras em `src/functions/report-*.ts`. O front busca cada bloco com um hook React Query proprio e renderiza quatro cards novos abaixo do `ReportsChartCard`.

## Passada transversal

- topologia/fronteira: nao muda; quatro rotas novas no router `venue` existente
- dados persistidos: nao; so leitura, sem schema, migration ou indice (filtro por `venueId` + periodo; `dataEvent` ja tem `@@index([venueId])`)
- interface: sim; quatro cards, estados por bloco, acessibilidade do mapa de calor (tabela `sr-only`)
- producao: sim; sem sinal novo alem do `console.error` de permissao negada, igual a `venue-rule`
- fluxo sensivel: sim; autorizacao por espaco no servidor e payload so com agregados
- conceito senior: nao; sem fila, retry ou concorrencia; cache so do React Query no front

## Componentes e modulos impactados

Backend (`art56_server_v3/src`):

- `use-cases/venue/reports/report-authorizer.ts` (novo): `assert(userId, venueId)` exige `VIEW_VENUE_ANALYSIS`
- `zod/venue/report-params-schema.ts` (novo): `venueId`, `year`, `month?`, `eventCategory?`
- `functions/report-occupancy.ts`, `report-lead-time.ts`, `report-service-adherence.ts`, `report-event-profile.ts` (novos), cada um com `.spec.ts`
- `functions/local-date.ts` (novo): data civil em `America/Sao_Paulo` via `Intl.DateTimeFormat`
- `use-cases/venue/reports/{occupancy,lead-time,service-adherence,event-profile}/` (novos): factory e use case; `report-controller.ts` unico para os quatro; `report-query.ts` monta os `where` (folga de `createdAt`, `NONE` -> `null`, aprovadas no ano) e o envelope
- `repositories/interface/proposal-repository-interface.ts` + in-prisma: `leadTimeRows`, `serviceAdherenceRows`, `eventProfileRows`
- `repositories/interface/data-event-repository-interface.ts` + `in-prisma/date-event-in-prisma-repository.ts`: `occupancyRows`
- `router/venue.ts`: quatro rotas com `ensureAuthenticate`

Frontend (`eventhub-vista-dashboard/src`):

- `types/venue.ts`: tipos das quatro respostas
- `services/venue.service.ts`: `getReportOccupancy`, `getReportLeadTime`, `getReportServiceAdherence`, `getReportEventProfile`
- `hooks/venue/queries/venueReportBlocks.ts` (novo): quatro `useQuery` com `keepPreviousData`, `staleTime` 5 min
- `components/reports/report-blocks.ts` (novo) + `.test.ts`: formatadores e modelos puros
- `components/reports/ReportBlock.tsx` (novo): casca do card (icone, titulo, subtitulo, filtro, estados)
- `components/reports/OccupancyCard.tsx`, `LeadTimeCard.tsx`, `ServiceAdherenceCard.tsx`, `EventProfileCard.tsx` (novos)
- `BudgetsReport.tsx`, `EventsReport.tsx`: envolver o retorno em `space-y-4` e acrescentar os cards

## Reuso previsto

- `VenueRuleAuthorizer` como modelo do authorizer; `PrismaVenueRepository.getById` e `PrismaUserVenuePermissionRepository.getUserVenuePermission`
- `reportYearRange`, `yearStart`, `proposalListRange` (mes em UTC) de `functions/`
- `HttpTokenError`, `HttpForbiddenError`, `HttpResourceNotFoundError`, `handleErrors`
- envelope `{ success, message, data, count, type }` dos endpoints de relatorio
- `EVENT_CATEGORY_OPTIONS` (`lib/event-category.ts`), `ui/select`, `ui/skeleton`, recharts
- classes dos cards atuais: `rounded-2xl border bg-white p-5 shadow-sm`, icone `h-10 w-10 rounded-xl bg-violet-100 text-violet-600`

## Contratos e dados

Todos `GET`, autenticados, envelope `{ success: true, message: "Sucesso", data, count: 1, type }`. Erros pelo `handleErrors` (400, 401, 403, 404). `eventCategory` aceita `CORPORATE | BIRTHDAY | BACHELOR_PARTY | WEDDING | COFFEE_BREAK | OTHER | NONE`; ausente = todas.

### `GET /venue/reports/occupancy?venueId&year&month?`

```ts
type OccupancyGroup = "events" | "visits" | "blocks";
type OccupancyData = {
  period: { kind: "year" | "month"; year: number; month: number | null };
  bandHours: 2;
  cells: { weekday: number; band: number; events: number; visits: number; blocks: number; total: number }[]; // 84, minutos; weekday 0 = domingo; band 0 = 00–02
  totals: Record<OccupancyGroup | "total", number>;          // minutos
  daysWithRecords: Record<OccupancyGroup | "total", number>;
  occupancyRate: null;
  availability: { defined: false; openingHour: string | null; closingHour: string | null };
  discarded: number;                                          // endDate <= startDate
};
```

### `GET /venue/reports/lead-time?venueId&year&eventCategory?`

```ts
type LeadTimeData = {
  year: number;
  eventCategory: EventCategoryFilter | null;
  created: number;        // criadas no ano (com filtro)
  considered: number;     // created - excluded
  excluded: number;       // data do evento antes da data de criacao
  approved: number;       // aprovadas entre as consideradas
  medianDays: number | null;
  buckets: { key: "0-7" | "8-30" | "31-90" | "90+"; minDays: number; maxDays: number | null; total: number; approved: number; approvalRate: number | null }[];
};
```

### `GET /venue/reports/service-adherence?venueId&year&eventCategory?`

```ts
type ServiceAdherenceData = {
  year: number;
  eventCategory: EventCategoryFilter | null;
  approvedProposals: number;
  services: { serviceId: string; name: string; proposals: number; adherence: number; amountSum: number | null; linesWithAmount: number; linesTotal: number }[];
  // ordem: proposals desc, amountSum desc (null por ultimo), name asc
};
```

### `GET /venue/reports/event-profile?venueId&year`

```ts
type EventProfileData = {
  year: number;
  events: number;
  guestBuckets: { key: "0-50" | "51-100" | "101-150" | "151+"; min: number; max: number | null; count: number }[];
  categories: { eventCategory: EventCategory | null; count: number }[]; // so as com count > 0, desc
  capacity: { maxGuest: number; atLeast80: number; above100: number; atLeast80Rate: number | null; above100Rate: number | null } | null;
};
```

### Leituras no banco

- ocupacao: `dateEvent.findMany({ where: { venueId, type: { in: tipos dos grupos }, startDate: { lt: fim }, endDate: { gt: inicio } }, select: { type, startDate, endDate } })`
- antecedencia: `proposal.findMany({ where: { venueId, createdAt: { gte: yearStart(y) - 1 dia, lt: yearStart(y+1) + 1 dia }, ...categoria }, select: { createdAt, startDate, approved } })`; ano local filtrado em memoria
- servicos: `proposal.findMany({ where: { venueId, approved: true, startDate: reportYearRange(y), ...categoria }, select: { id, proposalServices: { select: { serviceId, amount, service: { select: { name } } } } } })`; `id` fica no use case e nao sai na resposta
- porte: `proposal.findMany({ where: { venueId, approved: true, startDate: reportYearRange(y) }, select: { guestNumber, eventCategory } })` + `venue.maxGuest` do `getById` ja feito pelo authorizer

## Regras de calculo

- ocupacao: descartar `endDate <= startDate`; cortar em `[inicio, fim)` do periodo; uniao de intervalos por grupo; `total` = uniao dos tres grupos; quebrar cada segmento na meia-noite e nas fronteiras de 2 h; somar minutos em `(getUTCDay, floor(getUTCHours / 2))`; dia com registro = data UTC com minuto > 0
- periodo: sem `month` = `reportYearRange(year)`; com `month` = `proposalListRange({ year, month })`
- antecedencia: `created = localDate(createdAt, "America/Sao_Paulo")`; `event = componentes UTC de startDate`; `dias = (Date.UTC(event) - Date.UTC(created)) / 86_400_000`; `dias < 0` -> `excluded`; faixas `0–7`, `8–30`, `31–90`, `>= 91`; mediana das consideradas, media dos dois centrais quando par
- servicos: por `serviceId`, `Set` de propostas; `adherence = proposals / approvedProposals`; `amountSum` = soma de `amount != null`; `null` se `linesWithAmount = 0`
- porte: `guest = max(guestNumber, 0)`; faixas `<= 50`, `<= 100`, `<= 150`, resto; capacidade valida = `Number.isInteger(maxGuest) && maxGuest > 0`; `atLeast80` = `guest * 5 >= maxGuest * 4` (inteiro, sem float); `above100` = `guest > maxGuest`; taxas sobre `events` (`null` se 0)

## Falhas, casos de borda e invariantes

- invariante: soma de `guestBuckets.count` = `events` = total de eventos da aba `Evento` no mesmo ano
- invariante: soma de `buckets.total` = `considered`; `considered + excluded = created`
- invariante: `totals.total <= events + visits + blocks` e `>= max(events, visits, blocks)`
- invariante: cada celula tem `total <= 120` vezes os dias daquele dia da semana no periodo
- 403 antes de qualquer consulta de dados; 404 se o espaco nao existe
- falha de um bloco no front nao derruba os outros

## Decisoes arquiteturais importantes

- quatro endpoints em vez de um: estados, filtros e cache independentes por bloco; o custo de quatro requests e baixo
- calculo em funcoes puras com entrada simples (`Date`, numeros): testavel sem Prisma e reaproveitavel
- `ReportAuthorizer` proprio em vez de generalizar `VenueRuleAuthorizer`: mesma forma, sem mexer em codigo de regras ja entregue
- `Intl.DateTimeFormat` com `timeZone` para a data local de `createdAt`, sem ampliar o uso de `moment-timezone`
- React Query no front em vez de estender `venueReportsStore`: o store tem um `isLoading`/`error` unico; React Query ja e usado na visao geral
- cards novos em arquivos proprios, sem refatorar `ReportsChartCard`, para nao mexer nos relatorios atuais
- descartado: agregacao em SQL bruto (uniao de intervalos e corte na meia-noite sao mais claros e testaveis em TypeScript; volume por espaco/ano e pequeno)
- descartado: percentual de ocupacao por `openingHour`/`closingHour` (sem dias de funcionamento a disponibilidade nao e definida)

## Riscos e mitigacoes

- usuario sem `VIEW_VENUE_ANALYSIS` hoje ve a pagina por URL: passa a ver erro so nos blocos novos; mensagem de 403 clara no card
- fuso fixo `America/Sao_Paulo`: documentado no topic; sem fuso por espaco no schema
- ano com muitas `DateEvent` longas (pernoites): corte por periodo limita o processamento

## Rollout, observabilidade e rollback

- deploy na ordem API -> front; front antigo ignora rotas novas
- rollback: reverter o front (cards somem) e depois a API; sem dado para desfazer
- observabilidade: `console.error("[reports] permissao negada", { userId, venueId })`

## Estrategia de validacao

- backend: specs das quatro funcoes puras, do `local-date`, do authorizer e dos use cases com repositorio fake; `npm test -- --run`; `npx prisma validate`
- frontend: `report-blocks.test.ts`; `npm test`; `npm run lint` sem erro novo; `npm run build`
- browser: abas `Orçamentos` e `Evento` com ano com dados e sem dados, filtro de categoria e mes; conferir soma das faixas de convidados contra o KPI de eventos

## Fontes

- `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts` (`analysisByMonth`, `trafficCount`)
- `art56_server_v3/src/use-cases/venue-rule/venue-rule-authorizer.ts` e `list-venue-rule/factory-list-venue-rule.ts`
- `art56_server_v3/src/functions/wall-clock-datetime.ts`, `report-year-range.ts`, `monthly-average-by-years.ts`
- `art56_server_v3/prisma/schema.prisma` (`Proposal`, `ProposalService`, `DateEvent`, `DateEventType`, `Venue`)
- `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx`, `EventsReport.tsx`, `BudgetsReport.tsx`; `src/hooks/venue/queries/venueDashBoardData.ts`
- `topics/reports-and-kpis.md`; `project/agent-entrypoint.md#Regras de ouro`; `docs/planos/horario-wall-clock/01-analise-problema.md#Causa raiz`
