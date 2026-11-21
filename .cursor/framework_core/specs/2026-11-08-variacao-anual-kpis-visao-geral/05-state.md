# State — Variacao anual dos KPIs da visao geral do espaco

## Snapshot

- status: `T-01` e `T-02` escritas; o painel logado ainda nao foi visto
- ultima task concluida: `T-02`
- task em andamento: nenhuma
- proxima task exata: nenhuma no `04-tasks.md`; falta ver os cantos no painel com sessao
- prova mais recente: vitest 8 de `yearly-change.spec.ts` e suite backend 285 verdes; vitest 9 do painel + 3 da lista de orcamentos, suite frontend 187 verdes; eslint limpo nos arquivos tocados; `getVenueAnalytics` real (leitura pelo tunel) do AR756

## Delta da ultima task

- mudou: `yearlyChange` no analytics (funcoes puras em `functions/yearly-change.ts`); `YearlyChange` em `components/ui/yearly-change.tsx`; quatro cantos no `VenueStatsPanel`; `MonthChange` saiu; contrato em `API_CONTRACTS.md`
- leitura real nov/2026 do AR756: eventos 2 vs 5 = -60; orcamentos 248 vs 301 = -18; visitas 3 vs 2 = 50; receita 9089 vs 19721 = -54; `proposalsVariation` antigo segue 41,7 (mes anterior)
- leitura real nov/2025: os quatro `null` (sem base em nov/2024); `Anual` 2026: 32, 19, 100, 26
- ficou pendente: ver os cantos em `/venue/:id` com sessao
- lacunas de prova: o browser local parou em `/login`

## Decisoes recentes

- `yearlyChange` opcional no tipo do painel, para o canto ficar vazio com backend antigo

## Riscos ou bloqueios

- sem sessao no painel, os cantos nao foram vistos na tela
- borda da meia-noite no ultimo dia do mes segue fora; achado em `02-clarify.md`
- limpeza posterior: tirar `proposalsVariation`, `visitsVariation` e `revenueVariation` quando o bundle novo estiver no ar

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo das duas tasks pronto; nao esta pronto para producao
- bloqueantes: sessao do painel para a prova visual
- achados: nenhum
