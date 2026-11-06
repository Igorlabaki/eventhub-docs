# Tasks — Desempenho mensal do mesmo mes em todos os anos

## Ordem macro

1. `T-01` entrega o campo no backend
2. `T-02` desenha o mensal com esse campo

`T-02` nao roda em paralelo: o grafico depende do nome e da forma do campo fechados em `T-01`.

## Tasks

### T-01 - Serie do mesmo mes por ano na visao geral

- objetivo: `getVenueAnalytics` devolve `sameMonthRevenueByYear` para o mes selecionado
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `proposalYears`, `wallClockYear`, `wallClockMonth`, a soma de `EVENT` com `totalAmount`
- prompt recomendado: `normal`
- estrategia de teste: vitest da funcao pura, sem Prisma
- cenarios obrigatorios: dois anos com receita; ano da lista sem evento; evento de outro mes fora da soma; instante `2026-11-01T01:00:00.000Z` em novembro; lista de anos vazia; `month=all` nao chama a conta
- definition of done: campo no tipo da resposta; `month=all` grava `null`; mes selecionado grava uma entrada por ano de `proposalYears`; a query extra nao altera o `where` dos eventos ja usados pelos KPIs; sem schema e sem topic

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: somar com a janela local de `monthlyRevenue`, ou enfiar a serie na query que alimenta os KPIs
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: grafico, Desempenho Anual, cards e schema
- prova minima desta task: `npx vitest run src/functions/same-month-revenue-by-year.spec.ts` verde, com os cenarios obrigatorios
- criterio de escalada: sobe se a serie exigir coluna, endpoint novo ou mudanca do KPI
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `.cursor/framework_core/specs/2026-11-05-desempenho-mensal-mesmo-mes-nos-anos/03-design.md#Contratos e dados`
  - `.cursor/framework_core/project/project-decisions.md#D-06`
  - `.cursor/framework_global/framework-libs/node/index.md`
- caminhos candidatos: `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts`; `art56_server_v3/src/functions/wall-clock-datetime.ts`; `art56_server_v3/src/functions/proposal-years.ts`; `art56_server_v3/src/repositories/interface/venue-repository-interface.ts`
- palavras-chave ou simbolos de busca: `getVenueAnalytics`, `proposalYears`, `wallClockMonth`, `monthlyRevenue`
- testes provaveis: `art56_server_v3/src/functions/same-month-revenue-by-year.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, frontend

### T-02 - Grafico mensal com a tendencia por ano

- objetivo: o Desempenho Mensal mostra a serie por ano no desenho de tendencia dos relatorios
- cobre requisitos: `R-05`, `R-06`, `R-07`, `R-08`, `R-09`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `VenuePerformanceSeries`, o desenho de barra e linha de `ReportsChartCard`
- prompt recomendado: `smart`
- estrategia de teste: vitest com `renderToStaticMarkup` no mensal e no anual
- cenarios obrigatorios: tres anos no markup com o valor em real; receita zero sem rotulo; lista vazia com "Sem anos com registro"; campo ausente cai na barra unica; anual ainda mostra a meta
- definition of done: tipo `sameMonthRevenueByYear` no frontend; mensal usa o campo quando ele vem; anual, cards, seletor e relatorios intactos; sem topic

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: trocar a serie do Desempenho Anual ou voltar a linha da meta no mensal
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: calculo da receita, API, schema, cards e relatorios
- prova minima desta task: `npx vitest run src/components/venue/VenuePerformanceSeries.test.tsx` verde; no browser, `/venue/:id` no mes e no ano inteiro, se a sessao passar do login
- criterio de escalada: sobe se o campo vier com outro nome ou outra forma
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Reuso previsto`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/specs/2026-11-05-desempenho-mensal-mesmo-mes-nos-anos/03-design.md#Reuso previsto`
  - `.cursor/framework_core/specs/2026-11-05-desempenho-mensal-mesmo-mes-nos-anos/03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenuePerformanceSeries.tsx`; `eventhub-vista-dashboard/src/components/venue/VenuePerformanceChart.tsx`; `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx`; `eventhub-vista-dashboard/src/types/venue.ts`
- palavras-chave ou simbolos de busca: `sameMonthRevenueByYear`, `Desempenho Mensal`, `Tendência`, `performanceLabel`
- testes provaveis: `eventhub-vista-dashboard/src/components/venue/VenuePerformanceSeries.test.tsx`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, backend
