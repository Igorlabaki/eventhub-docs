# Design — Desempenho mensal do mesmo mes em todos os anos

## Visao geral da solucao

`getVenueAnalytics` passa a devolver `sameMonthRevenueByYear` quando a visao geral esta num mes. O Desempenho Mensal le esse campo e desenha uma barra por ano com a linha de tendencia da mesma receita. O anual nao le o campo.

Passada transversal:

- fronteira ou fluxo novo: nao — o mesmo `getVenueAnalytics` ganha um campo; sem ADR
- dados persistidos: nao — sem schema, indice ou migration; le `DateEvent` e `proposal` que ja existem
- interface: sim — so o grafico Desempenho Mensal muda de serie e de linha
- observabilidade de producao: nao — sem servico novo; a prova e o teste e a tela
- fluxo sensivel: nao — nao altera auth, pagamento, segredo ou PII
- gatilho de `patterns/rules/06`: nao — leitura agregada, sem retry, fila ou cache

## Componentes e modulos impactados

- `art56_server_v3/src/functions/same-month-revenue-by-year.ts`: funcao pura nova
- `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts`: `getVenueAnalytics` chama a funcao
- `art56_server_v3/src/repositories/interface/venue-repository-interface.ts`: campo no `VenueAnalyticsResponse`
- `eventhub-vista-dashboard/src/types/venue.ts`: o mesmo campo em `VenueDashboardData`
- `eventhub-vista-dashboard/src/components/venue/VenuePerformanceChart.tsx`: monta os pontos do mensal a partir do campo
- `eventhub-vista-dashboard/src/components/venue/VenuePerformanceSeries.tsx`: modo tendencia para o mensal; o anual permanece receita e meta

## Reuso previsto

- anos: `proposalYears`, ja calculado em `getVenueAnalytics`
- relogio: `wallClockYear` e `wallClockMonth` em `art56_server_v3/src/functions/wall-clock-datetime.ts`
- desenho: a barra, a linha, o rotulo e a legenda de `ReportsChartCard` no modo quantidade, com valor em real compacto como o grafico atual da visao geral

## Contratos e dados

Campo novo em `VenueAnalyticsResponse` e `VenueDashboardData`:

```ts
sameMonthRevenueByYear: { year: number; revenue: number }[] | null
```

- mes selecionado: uma entrada por item de `proposalYears`, mesma ordem, `revenue` em `number`
- `month=all`: `null`, e a consulta extra nao roda
- a consulta extra le so `startDate` e `proposal.totalAmount` dos `DateEvent` `EVENT` do espaco cujo `startDate` cai no mes de parede de algum ano de `proposalYears`
- a funcao pura recebe esses eventos e os anos, e devolve a lista; ano sem evento fica com `revenue: 0`
- um evento entra no ano `wallClockYear(startDate)` e no mes `wallClockMonth(startDate)`
- a soma ignora `totalAmount` ausente, como o `reduce` de `monthlyRevenue`

## Falhas, casos de borda e invariantes

- a ordem dos anos e a de `proposalYears`
- evento de outro mes, outro tipo, ou ano fora de `proposalYears` nao entra
- lista vazia nao vira coluna; o mensal mostra "Sem anos com registro"
- campo `null` ou ausente: o mensal usa a barra unica do ano filtrado, para um frontend novo nao apagar o grafico antes do backend
- campo presente manda, mesmo com zeros

## Decisoes arquiteturais importantes

- a serie usa relogio de parede, nao `new Date(ano, mes, 1)` — `D-06` e `proposalYears` ja usam `wallClockYear`; a janela local de `monthlyRevenue` fica de fora
- a conta nao entra na query grande de `DateEvent` da visao geral, para nao mudar contagem, KPI e proximos eventos
- sem endpoint novo e sem schema — `D-07` permanece; a soma segue `number`

Alternativa descartada: alargar o `where` de `DateEvent` ja carregado. Misturaria outros anos nas contas do periodo.

## Riscos e mitigacoes

- a barra do ano selecionado pode nao bater com o KPI `monthlyRevenue` na borda do mes. Mitigacao: fora de escopo; registrado na spec
- a consulta extra le os eventos `EVENT` daquele mes em todos os anos do espaco. Mitigacao: so `startDate` e `totalAmount`; se o volume do espaco pesar, a query fica para outra spec

## Rollout, observabilidade e rollback

- sem flag e sem sinal novo
- rollback: tirar o campo e voltar o mensal para a barra unica; o anual nao depende da serie

## Estrategia de validacao

- `T-01`: vitest da funcao pura, com dois anos, ano zerado, evento de outro mes, tipo ignorado pelo filtro do repositorio, e borda `2026-11-01T01:00:00.000Z` contando como novembro
- `T-02`: vitest do markup do mensal (anos, real, tendencia, vazio) e do anual ainda com meta
- browser: `/venue/:id` num mes e no ano inteiro; nesta spec o login segue como lacuna conhecida se a sessao nao estiver aberta

## Docs determinantes

- `project/project-decisions.md#D-06` para o relogio de parede
- `project/project-decisions.md#D-07` para nao migrar o Float
- `project/project-decisions.md#D-01` para o contrato nos dois repos
- `ReportsChartCard` como desenho da tendencia
- `getVenueAnalytics` como lugar da serie e da conta de receita que a serie repete
