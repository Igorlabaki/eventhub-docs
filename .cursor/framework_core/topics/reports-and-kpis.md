# Reports and KPIs — EventHub

Paineis de numeros do venue, observados em 2026-11-10. Backend em `venue-in-prisma-repository`, `proposal-in-prisma-repository` e `functions/` de relatorio; frontend em `components/venue`, `components/reports`, `components/proposal` e `components/goal`. Graficos: somente recharts.

## Visao Geral (`/venue/:id`)

- endpoint: `GET /venue/analytics/:venueId?year&month` (`month=all` = anual), hook `useGetVenueDashBoardData`;
- devolve: `totalEventsInYear`, `eventsThisMonth`, `proposalsInMonth` + variacao, `totalVisits` (DateEvent `VISIT`) + variacao, `monthlyRevenue` + variacao, `yearlyChange` (eventos, propostas, visitas, receita contra a mesma janela do ano anterior ou `null`), `monthlyRevenueList` (anual), `nextEvent`, `nextVisit`, `proposalYears`, `sameMonthRevenueByYear`;
- receita = soma de `totalAmount` das propostas ligadas a DateEvent `EVENT` no periodo;
- tela: cards Proximo Evento e Proxima Visita; `VenueStatsPanel` com `MonthYearNavigator` (setas de ano, 12 meses, Anual) e 4 KPIs com `YearlyChange`; grafico `VenuePerformanceSeries` (mes ao longo dos anos com tendencia e media; ou Desempenho Anual com meta e media), so em `lg`;
- metas vem de `GET /goal/list`.

## Relatorios (`/venue/:id/reports`)

- abas ORCAMENTOS, EVENTO e FINANCEIRO + seletor de ano (`ReportsHeader`, `SlidingSelection`);
- endpoints: `GET /venue/analysisByMonth?venueId&year&approved&average` (por mes: quantidade, total e convidados; todas e aprovadas; `averageByMonth` = media mensal nos anos com receita e conversao agregada), `GET /venue/trafficCount` (origem por `trafficSource` e `categories` por `eventCategory` + sem categoria), `GET /expense/analysis?venueId&year`;
- cada ano e buscado junto com o anterior; cache por ano em `venueReportsStore`;
- Orcamentos/Evento (`ReportsChartCard`): KPIs total, conversao, ticket medio, pessoas em media com variacao e sparkline; "por mes" com barras, tendencia, ano anterior e media dos anos; origem dos leads; insights; rosca de categorias;
- Financeiro (`FinancialReportCard`): receita bruta, despesas, receita liquida, margem; receita x despesa; composicao das despesas; insights;
- regras de anos: `report-year-range`, `proposal-years`, `monthly-average-by-years` consideram so anos com receita (evita eixo com anos invalidos como 6, 1996, 2030).

### Blocos agregados (`/venue/reports/*`)

- seis `GET` autenticados (`venueId`, `year` 2000–2100, `month?` 1–12, `eventCategory?` enum + `NONE` = sem categoria); `ReportAuthorizer` exige `VIEW_VENUE_ANALYSIS` no espaco antes de qualquer leitura (401/404/403; 400 pelo zod); envelope `{ success, message, data, count: 1, type }`; so agregados, sem id de proposta, nome ou contato;
- calculo em funcoes puras `functions/report-{occupancy,lead-time,service-adherence,event-profile,event-origin}.ts`; taxas sao fracao 0–1 e o front formata (`components/reports/report-blocks.ts`);
- front: hooks React Query `hooks/venue/queries/venueReportBlocks.ts` (`staleTime` 5 min, chave com ano/mes/categoria); cards proprios com carregamento, erro com `Tentar de novo` e vazio; aba ORCAMENTOS: `LeadTimeCard`; aba EVENTO: `OccupancyCard`, `ServiceAdherenceCard`, `EventProfileCard`, `EventOriginCard`; aba FINANCEIRO: `AdsInvestmentCard`;
- ocupacao: `DateEvent` em componentes UTC (wall-clock); grupos `events` = EVENT/OVERNIGHT/PRODUCTION/BARTER, `visits` = VISIT, `blocks` = OTHER, `PROPOSAL` fora; uniao de intervalos por grupo e `total` = uniao dos tres; corte no periodo (ano ou mes) e na meia-noite; `endDate <= startDate` vai para `discarded`; `occupancyRate` sempre `null` (sem dias de funcionamento no schema);
- antecedencia: populacao = propostas com `createdAt` no ano em `America/Sao_Paulo` (fuso fixo; nao ha fuso por espaco); dias = dia do evento (UTC de `startDate`) menos dia local da criacao; negativos em `excluded`; mediana com media dos dois centrais;
- servicos: aprovadas com `startDate` no ano; adesao = propostas distintas com o servico / aprovadas; `amountSum` so de `ProposalService.amount` nao nulo (0 conta), `null` sem valor; servico excluido some do historico (`onDelete: Cascade`);
- porte: mesma populacao da aba EVENTO (aprovadas + `startDate` no ano), entao a soma das faixas de convidados = total de eventos do ano; capacidade so com `Venue.maxGuest` inteiro positivo (`>= 80%` e `> 100%`, sem float);
- origem (`GET /venue/reports/event-origin`, card `EventOriginCard` na aba EVENTO, abaixo de servicos e porte): mesma populacao do porte; so entra linha com cidade, estado e bairro preenchidos depois do `trim`; caixa diferente conta junto e acento diferente nao; a soma de cada ranking e `events`; `month` e `eventCategory` nao filtram; o `select` e so as tres colunas;
- anuncios (`GET /venue/reports/ads`, card `AdsInvestmentCard` na aba FINANCEIRO, abaixo do `FinancialReportCard`): por canal, investido, orcamentos, custo/orcamento, eventos, custo/evento e retorno (receita / investido, `8,0x`); cinco canais fixos + "Sem canal" so com gasto de Publicidade sem canal (sem custos nem retorno); total soma todo o gasto e os orcamentos dos cinco canais; orcamentos = propostas com `createdAt` no ano local (mesma janela da antecedencia), eventos e receita = as aprovadas entre elas, sem exigir `startDate` no ano; recorrente conta `mensal x meses ativos` (do mes local de cadastro, ou janeiro, ate dezembro em ano passado ou o mes local atual no ano corrente; 0 em ano futuro); esporadica pelo ano UTC do `paymentDate` (sem data, ano local do `createdAt`); calculo em `functions/report-ads.ts`; excluir uma recorrente apaga o custo passado;
- divida: os endpoints antigos (`analysisByMonth`, `trafficCount`, `expense/analysis`) seguem sem checar permissao; usuario sem `VIEW_VENUE_ANALYSIS` que abre a pagina por URL ve 403 so nos blocos novos.

## Orcamentos e Eventos (`/venue/:id/budgets`, `/events`)

- endpoint: `GET /proposal/list?venueId&month&year&day&completeClientName&page&sortBy&sortDir&summary=true&approved&minAmount` (pagina de 10);
- `summary`: total, `monthAmount` (aprovadas por dia), `amountMax`, `conversionRate`, serie diaria e `change` contra o mesmo periodo do ano anterior (SQL bruto com `DATE_FORMAT`);
- tela: `MonthYearNavigator`, busca com debounce 300 ms, status Aberto/Fechado (`approved`), dia, slider de valor minimo (`venue.minimumPrice` ate `amountMax`), `ProposalListSummaryCards` com sparkline, `ProposalTable` ordenavel, `ProposalListPager`, botao Novo Orcamento e copiar link do formulario publico.

## Notificacoes (`/venue/:id/notifications`)

- endpoints: `GET /notification/list/:venueId?page&summary&q&type&isRead`, `PATCH read-all/:venueId`, `PATCH read-by-proposal/:proposalId` (chamado ao abrir `/proposal/:id`);
- KPIs: nao lidas, ultimos 7 dias, ultimos 30 dias, orcamentos novos, com variacao sobre o periodo anterior;
- notificacao e criada no banco ao criar orcamento; nao ha push.

## Metas e precos (`/venue/:id/goals`)

- sem graficos; `GoalsPanelSummary` (preco atual, meta anual, adicionais ativos, descontos ativos, minimo padrao) e `GoalsPanelSections` (modelo de precificacao editavel, metas, adicionais, precos minimos, descontos);
- abas `GoalsTab`, `FeesTab`, `MinimumPricesTab`, `DiscountsTab`;
- endpoints `/goal/*`, `/seasonalFee/*`, `/minimumPricePeriod/*`, `PUT /venue/update/payment-info`.

## Despesas

`expense/analysis`: recorrentes viram total mensal e anual por `functions/expense-recurrence.ts#recurringAmounts` (`WEEKLY` x52/12 e x52, `BIWEEKLY` x2/x24, `MONTHLY` x1/x12, `ANNUAL` /12 e x1, `SPORADIC` 0), sempre todas, sem olhar o cadastro; esporadicas somadas por nome, so as com `paymentDate` no ano UTC (`reportYearRange`: 1/1 a 1/1 do ano seguinte). Ate 2026-11-14 `WEEKLY` era ignorado e as esporadicas iam ate 31/01 do ano seguinte (`PRICE-05`, `PRICE-06`).

Despesa de Publicidade (`ADVERTISING`) exige `trafficSource` (Instagram, Facebook, TikTok, Google, Outros); outras categorias gravam `null`. A regra mora no use case (`resolveExpenseTrafficSource`) pela categoria final, porque a edicao e parcial; Publicidade antiga sem canal so salva depois de escolher o canal.

## Cuidados

- receita e metas misturam horario local e wall-clock;
- KPIs dependem de `approved` e de DateEvent `EVENT`, nao de pagamento;
- mudar formula de KPI exige atualizar backend, `report-metrics.ts`/`finance-metrics.ts` e testes dos dois lados.
