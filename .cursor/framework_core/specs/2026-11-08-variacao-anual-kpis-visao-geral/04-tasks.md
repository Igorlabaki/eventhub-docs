# Tasks — Variacao anual dos KPIs da visao geral do espaco

## Ordem macro

`T-01` fecha o contrato no backend. `T-02` desenha o canto e depende do formato de `T-01`, nao do deploy. Cada task cabe num repositorio.

## Tasks

### T-01 - Calcular yearlyChange no analytics do espaco

- objetivo: `GET /venue/analytics/:venueId` devolve `yearlyChange` com o percentual inteiro de eventos, propostas, visitas e receita contra a mesma janela do ano anterior, ou `null` sem base.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-09`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`, se o formato de `03-design.md#Contratos e dados` for seguido
- reusa: os `filter` de `getVenueAnalytics`; o padrao de funcao pura de `same-month-revenue-by-year.ts`
- prompt recomendado: `normal`
- estrategia de teste: unitario das funcoes puras; suite do backend verde
- cenarios obrigatorios: 248 contra 175 responde 42; 3 contra 5 responde -40; iguais respondem 0; 0 contra 4 responde -100; 5 contra 0 responde `null`; -10,5 responde -10; novembro de 2026 da janela de novembro de 2025; janeiro da janela de janeiro do ano anterior; `null` (Anual) da janela de 1/1 a 31/12 do ano anterior
- definition of done: cenarios passam em `npm test -- --run`; `VenueAnalyticsResponse` declara `yearlyChange`; os `*Variation` e os numeros atuais seguem iguais; `docs/referencias/API_CONTRACTS.md#GET /venue/analytics/:venueId` descreve `yearlyChange`; sem migration e sem endpoint novo

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: a janela anterior usar outra construcao ou outro filtro que o numero do card, ou o formato dos `*Variation` mudar
- repos tocados: `backend` (`art56_server_v3/`) e o contrato em `eventhub-docs/docs/`
- fora de escopo desta task: o canto do card, os graficos, a borda da meia-noite e schema novo
- prova minima desta task: o vitest mostra 42 para 248 contra 175, `null` para anterior 0 e a janela de novembro de 2025 para novembro de 2026
- criterio de escalada: se a comparacao exigir coluna, indice ou endpoint novo, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_core/project/project-decisions.md#D-08`
  - `framework_global/framework-libs/node/references/node-express-coding-style.md`
- caminhos candidatos: `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts` (`getVenueAnalytics`), `art56_server_v3/src/repositories/interface/venue-repository-interface.ts`, `art56_server_v3/src/functions/same-month-revenue-by-year.ts` so como modelo, `eventhub-docs/docs/referencias/API_CONTRACTS.md`
- palavras-chave ou simbolos de busca: `getVenueAnalytics`, `firstDayOfLastMonth`, `proposalsVariation`, `VenueAnalyticsResponse`
- testes provaveis: `art56_server_v3/src/functions/yearly-change.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, `database`, frontend e `topics/`

### T-02 - Mostrar a variacao anual nos quatro cards

- objetivo: Eventos, Orcamentos, Visitas Agendadas e Receita mostram `yearlyChange` no canto superior direito com o `YearlyChange` compartilhado, e deixam o canto vazio durante o loading ou sem o campo.
- cobre requisitos: `R-06`, `R-07`, `R-08`
- depende de: formato de `T-01`
- pode rodar em paralelo com: `T-01`
- reusa: `YearlyChange` de `ProposalListSummaryCards.tsx`, movido para `components/ui/yearly-change.tsx`
- prompt recomendado: `smart`
- estrategia de teste: vitest do markup de `VenueStatsPanel`; vitest de `ProposalListSummaryCards` sem mudanca
- cenarios obrigatorios: `+42%` verde em Orcamentos; `-40%` vermelho em Visitas, com um sinal so; `0%` neutro; `—` em Eventos com `null`; os quatro cantos somem com `numbersLoading`; sem `yearlyChange` nenhum canto; o rotulo Receita Anual em `Anual` mantem o canto; os campos `*Variation` nao sao lidos
- definition of done: cenarios passam em `npm test`; `VenueDashboardData` declara `yearlyChange`; `MonthChange` saiu; lint sem erro novo nos arquivos tocados

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o canto mostrar traco durante o loading, ou a cor ser o unico sinal
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: formula, contrato, backend, graficos e seletor
- prova minima desta task: o markup do painel mostra `+42%`, `-40%`, `0%` e `—` nos cards certos, e nenhum canto com `numbersLoading`
- criterio de escalada: se o percentual precisar ser calculado no navegador, parar e voltar a `T-01`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Falhas, casos de borda e invariantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `03-design.md#Contratos e dados`
  - `framework_global/framework-libs/design/rules/07_data_display_and_dashboards.md#Numeros e KPIs`
  - `framework_global/framework-libs/react/references/react-coding-style.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.tsx`, `eventhub-vista-dashboard/src/components/proposal/ProposalListSummaryCards.tsx`, `eventhub-vista-dashboard/src/types/venue.ts`
- palavras-chave ou simbolos de busca: `MonthChange`, `YearlyChange`, `OverviewKpiCard`, `numbersLoading`, `VenueDashboardData`
- testes provaveis: `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.test.tsx`, `eventhub-vista-dashboard/src/components/proposal/ProposalListSummaryCards.test.tsx`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, backend, graficos e `topics/`
