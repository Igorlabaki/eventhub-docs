# State — Novos blocos nos relatorios

## Snapshot

- status: `T-01` a `T-08` implementadas (L2); aguardando prova no browser e review humana
- ultima task concluida: `T-08` (docs); prova de browser da `T-07`/`T-08` pendente
- task em andamento: nenhuma
- proxima task exata: prova no browser (abas `Orçamentos` e `Evento`, ano com e sem dados, filtros, API parada) e, se o humano quiser, `fw:review` + `entrega`
- prova mais recente: backend `npx vitest run` 56 arquivos / 387 testes verdes; `npx prisma validate` ok; `tsc` 60 erros, todos anteriores (nenhum nos arquivos tocados); frontend `npx vitest run` 42 / 234 verdes, `npm run build` ok, eslint nos arquivos tocados sem erro (1 aviso anterior em `SlidingSelection.tsx`), `tsc -p tsconfig.app.json` 52 erros anteriores

## Delta da ultima task

- mudou (backend): `ReportAuthorizer` + `report-params-schema`; funcoes `report-occupancy`, `report-lead-time`, `report-service-adherence`, `report-event-profile`, `local-date`; repositorios `occupancyRows`, `leadTimeRows`, `serviceAdherenceRows`, `eventProfileRows`; use cases com `ReportController` unico e quatro rotas `/venue/reports/*`
- mudou (frontend): tipos em `types/venue.ts`, quatro metodos em `venue.service.ts`, hooks `venueReportBlocks.ts`, `report-blocks.ts` (+ teste), `ReportBlock`, `OccupancyCard`, `LeadTimeCard`, `ServiceAdherenceCard`, `EventProfileCard`; abas envolvidas em `space-y-4`; `ReportsChartCard` intocado
- mudou (docs): quatro linhas e totais em `project/api-endpoints.md`; secao `Blocos agregados` em `topics/reports-and-kpis.md`
- ficou pendente: browser; validador do framework

## Lacunas de prova

- browser nao exercitado: sem servidores locais, sem login e sem banco de dev; usar o banco de producao pelo tunel exige aprovacao nomeada
- conferir no browser: soma das faixas de convidados = KPI de eventos da aba `Evento` no mesmo ano; 403 visivel so nos blocos novos
- validador `validate-framework.py` nao rodou: Python nao instalado (so o alias da Microsoft Store)
- `Intl` com `America/Sao_Paulo` provado no Node 22 local; runtime da Vercel nao conferido

## Decisoes recentes

- `where` dos relatorios montado no use case (`report-query.ts`) e repassado ao Prisma: filtros testaveis com repositorio fake
- um `ReportController` compartilhado em vez de quatro controllers iguais; factories por bloco
- rotas literais `/reports/*` registradas no fim do router `venue`; spec prova que sao as primeiras a casar (sem colisao com `/list?:x?`)
- taxas como fracao 0–1 no backend; front formata (`25%`, `indisponível`)

## Riscos ou bloqueios

- endpoints antigos de relatorio seguem sem checar permissao (fora de escopo, registrado no topic)
- outra sessao mexe em paralelo no backend (`schema.prisma` e migration de cortesia); nao tocados aqui

## Memoria promovida

- topics atualizados: `topics/reports-and-kpis.md` (blocos agregados)
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum
