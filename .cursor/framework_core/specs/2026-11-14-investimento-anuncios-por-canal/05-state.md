# State — Investimento em anuncios por canal

## Snapshot

- status: `T-01` a `T-08` executadas em 2026-11-14; aguardando review de entrega (L2) e deploy
- ultima task concluida: `T-08` (docs; browser parado no login)
- task em andamento: nenhuma
- proxima task exata: `fw:review` + `entrega` (opcional); depois commit, publicar a API e logo em seguida o front
- prova mais recente: vitest back 68 arquivos / 563 testes e front 54 / 332 verdes; `npm run build` ok; `GET /venue/reports/ads` sem token = 401 no localhost; deploy request `#49` na `main` com coluna e indice lidos de volta

## Delta da ultima task

- mudou: `T-06` (form com select Canal controlado por `value`, `superRefine` "Selecione o canal", limpa fora de Publicidade; rotulo na lista; helper `expense-traffic-source.ts` + teste) feita em sessao paralela e conferida; `T-07` `AdsInvestmentCard` + `useReportAds` + `formatRoas`/`adsChannelLabel` + `ReportBlock.emptyLabel`; `VenueExpenses` recebe `CreateExpenseDTO` (tira 2 erros de tipo antigos); docs de `T-08`
- ficou pendente: browser (login) e deploy

## Lacunas de prova

- browser: `/venue/:id/reports` redireciona para `/login`; card e formulario nao vistos na tela; criar despesa no localhost grava em producao (exige aprovacao)
- leitura agregada da `main`: AR756 tem 1 despesa de Publicidade esporadica, ja com canal; nenhuma recorrente `WEEKLY` no banco (correcao do `PRICE-05` nao muda numero hoje)
- `tsc` back: 74 erros pre-existentes fora dos arquivos tocados; front: erros antigos em `FinancialReportCard`, `OccupancyCard`, `ReportsChartCard` (fora do escopo)
- validador do framework nao roda (Python nao instalado)

## Decisoes recentes

- deploy do `#49` na `main` a pedido do usuario em 2026-11-14, diff conferido (so coluna e indice), aprovado no cartao
- `resolveExpenseTrafficSource` generico sobre `TrafficSource`; `GetAdsReportUseCase` com `now` injetavel
- controller de criar passa o resultado do `parse`; o front envia so campos do schema
- recorte das esporadicas registrado como `PRICE-06` (encontrado e resolvido nesta spec)

## Riscos ou bloqueios

- publicar API e front juntos: front antigo recebe 400 ao salvar Publicidade sem canal
- recorte corrigido tira do ano as esporadicas de janeiro do ano seguinte
- janela de revert do `#49` aberta (`complete_pending_revert`)

## Memoria promovida

- topics: `reports-and-kpis.md` (card, janelas, meses ativos, `WEEKLY`, recorte), `improvement-backlog.md` (`PRICE-05` resolvido, `PRICE-06` novo e resolvido)
- project: `api-endpoints.md` (`/venue/reports/ads`, `trafficSource`), `planetscale.md` (`#49`); product: `08-data-model.md`
- project-decisions e ADRs: nenhum
