# State — Desempenho mensal do mesmo mes em todos os anos

## Snapshot

- status: `T-01` e `T-02` escritas; review pendente
- ultima task concluida: `T-02`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest 5 em `same-month-revenue-by-year.spec.ts` e 5 em `VenuePerformanceSeries.test.tsx`

## Delta da ultima task

- mudou: a visao geral devolve `sameMonthRevenueByYear`; o mensal desenha a tendencia por ano
- ficou pendente: review de entrega
- lacunas de prova: browser parado no login

## Decisoes recentes

- `month=all` devolve `null` e nao consulta os eventos do mes
- campo ausente no frontend mantem a barra unica
- lista vazia mostra "Sem anos com registro"

## Riscos ou bloqueios

- a barra do ano selecionado pode divergir do KPI na borda do mes
- a tela ainda nao foi vista logada

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote executado; nao esta pronta para producao
- bloqueantes: nenhum
- achados: nenhum
