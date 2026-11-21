# Tasks — Novos blocos nos relatorios

## Ordem macro

`T-01`, `T-02`, `T-03`, `T-04` e `T-06` nao dependem entre si e podem correr em paralelo (`T-06` so precisa do contrato em `03-design.md#Contratos e dados`). `T-05` junta authorizer, funcoes e repositorios nos endpoints. `T-07` depende de `T-06`. `T-08` fecha docs e browser depois de `T-05` e `T-07`. Deploy: API antes do front.

## Tasks

### T-01 - Authorizer de relatorio e schema de parametros

- objetivo: `ReportAuthorizer.assert(userId, venueId)` exige `VIEW_VENUE_ANALYSIS` e devolve o espaco; schema zod dos parametros dos quatro endpoints
- cobre requisitos: `R-01`, `R-02`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`, `T-03`, `T-04`, `T-06`
- reusa: forma de `VenueRuleAuthorizer`; `HttpTokenError`, `HttpForbiddenError`, `HttpResourceNotFoundError`
- prompt recomendado: `smart`
- estrategia de teste: spec com repositorios fake
- cenarios obrigatorios:
  - sem `userId`: `HttpTokenError`
  - espaco inexistente: `HttpResourceNotFoundError`, sem chamar permissao
  - permissao sem `VIEW_VENUE_ANALYSIS` ou link nulo: `HttpForbiddenError`
  - permissao com espacos extras na string (`" VIEW_VENUE_ANALYSIS "`): aceita e devolve o espaco
  - schema: `year` 1999, `month` 13 e `eventCategory` `FESTA` rejeitados; `NONE` aceito; `month` ausente aceito
- definition of done:
  - `use-cases/venue/reports/report-authorizer.ts` e `zod/venue/report-params-schema.ts` existem
  - spec verde em `npm test -- --run`

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — autorizacao por espaco
- risco principal: liberar espaco de outra organizacao por consultar permissao sem `organizationId` do espaco
- repos tocados: `backend`
- fora de escopo desta task: rotas, consultas de dados, endpoints antigos
- prova minima desta task: `report-authorizer.spec.ts` e `report-params-schema.spec.ts` cobrem os cinco cenarios e passam
- criterio de escalada: `normal` se `getUserVenuePermission` nao filtrar por organizacao do espaco
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `security`
- documentos obrigatorios:
  - `03-design.md#Componentes e modulos impactados`
  - `.cursor/framework_core/topics/permissions-catalog.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/venue-rule/venue-rule-authorizer.ts`; `src/use-cases/venue-rule/venue-rule.spec.ts` (fakes); `src/repositories/in-prisma/user-venue-permission-in-prisma-repository.ts` (`getUserVenuePermission`); `src/zod/venue/get-venue-analysis-by-month-params-schema.ts`
- palavras-chave ou simbolos de busca: `VenueRuleAuthorizer`, `getUserVenuePermission`, `HttpForbiddenError`, `EventCategory`
- testes provaveis: `art56_server_v3/src/use-cases/venue/reports/report-authorizer.spec.ts`; `src/zod/venue/report-params-schema.spec.ts`
- nao ler por padrao: frontend, funcoes de calculo, `01-spec.md` inteiro

### T-02 - Funcoes de ocupacao da agenda

- objetivo: `buildOccupancy(rows, period)` devolve celulas, totais, dias com registro e descartados conforme o contrato
- cobre requisitos: `R-03`, `R-04`, `R-05`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-03`, `T-04`, `T-06`
- reusa: componentes UTC de `wall-clock-datetime.ts`; `reportYearRange`; `proposalListRange`
- prompt recomendado: `normal`
- estrategia de teste: unitario puro
- cenarios obrigatorios:
  - duas `EVENT` 10:00–14:00 e 12:00–16:00 no mesmo dia: 360 min em `events`
  - `EVENT` 10:00–12:00 e `VISIT` 11:00–13:00: `events` 120, `visits` 120, `total` 180
  - 22:00–02:00 de sabado: 120 min em sabado faixa 11 e 120 min em domingo faixa 0; dois dias com registro
  - fim exatamente 00:00: nada no dia seguinte
  - `endDate <= startDate`: fora e `discarded` = 1
  - evento 31/12 22:00 -> 01/01 02:00 no ano: so 120 min contados; com mes, corte na borda do mes
  - `PROPOSAL` ignorado; `OTHER` vai para `blocks`
  - sempre 84 celulas; `occupancyRate` `null`
- definition of done:
  - `src/functions/report-occupancy.ts` com `OCCUPANCY_GROUPS` e `BAND_HOURS` exportados
  - spec verde

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: usar `getHours`/`getDay` locais em vez de UTC e deslocar 3 h
- repos tocados: `backend`
- fora de escopo desta task: consulta Prisma, rota, front
- prova minima desta task: `report-occupancy.spec.ts` cobre os oito cenarios e passa
- criterio de escalada: `complete` se a uniao de intervalos exigir estrutura alem de ordenar e fundir
- nivel de autonomia: `L3`

#### Minimal Read Set

- ler primeiro: `03-design.md#Regras de calculo`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `03-design.md#Regras de calculo`
  - `03-design.md#Contratos e dados`
  - `02-clarify.md#Premissas assumidas`
- caminhos candidatos: `art56_server_v3/src/functions/wall-clock-datetime.ts`; `src/functions/report-year-range.ts`
- palavras-chave ou simbolos de busca: `getUTCDay`, `getUTCHours`, `reportYearRange`, `proposalListRange`
- testes provaveis: `art56_server_v3/src/functions/report-occupancy.spec.ts`
- nao ler por padrao: `security`, repositorios, frontend

### T-03 - Funcoes de antecedencia e de porte

- objetivo: `buildLeadTime(rows, year)` e `buildEventProfile(rows, maxGuest)` conforme o contrato; `localDateParts(date, timeZone)`
- cobre requisitos: `R-06`, `R-07`, `R-10`, `R-11`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-02`, `T-04`, `T-06`
- reusa: componentes UTC de `wall-clock-datetime.ts`
- prompt recomendado: `normal`
- estrategia de teste: unitario puro
- cenarios obrigatorios:
  - `createdAt` 2025-12-31T23:30-03:00 entra em 2025, nao em 2026
  - 0, 7, 8, 30, 31, 90 e 91 dias caem nas faixas certas
  - evento antes da criacao: `excluded` 1, fora da mediana
  - mediana de 3 e de 4 valores; nenhum considerado -> `null`
  - faixa vazia: `approvalRate` `null`
  - convidados 50/51, 100/101, 150/151 e 0 nas faixas certas
  - `maxGuest` 100: 80 conta em `atLeast80`, 100 nao conta em `above100`, 101 conta nos dois
  - `maxGuest` 0, -1 e 10.5: `capacity` `null` e faixas mantidas
- definition of done:
  - `src/functions/local-date.ts`, `report-lead-time.ts`, `report-event-profile.ts` com spec verde

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: comparar `createdAt` em UTC e errar um dia nas criacoes depois das 21:00
- repos tocados: `backend`
- fora de escopo desta task: consultas, rota, filtro por categoria (feito no banco em `T-05`)
- prova minima desta task: specs das tres funcoes cobrem os oito cenarios e passam
- criterio de escalada: `normal` -> `complete` se `Intl` nao devolver `America/Sao_Paulo` no runtime da Vercel
- nivel de autonomia: `L3`

#### Minimal Read Set

- ler primeiro: `03-design.md#Regras de calculo`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `03-design.md#Regras de calculo`
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_core/topics/reports-and-kpis.md#Cuidados`
- caminhos candidatos: `art56_server_v3/src/functions/wall-clock-datetime.ts`
- palavras-chave ou simbolos de busca: `Intl.DateTimeFormat`, `formatToParts`, `getUTCFullYear`
- testes provaveis: `art56_server_v3/src/functions/{local-date,report-lead-time,report-event-profile}.spec.ts`
- nao ler por padrao: `security`, repositorios, frontend

### T-04 - Funcao de aderencia dos servicos

- objetivo: `buildServiceAdherence(proposals)` devolve ranking, adesao, soma e cobertura conforme o contrato
- cobre requisitos: `R-08`, `R-09`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-02`, `T-03`, `T-06`
- reusa: nada especifico
- prompt recomendado: `smart`
- estrategia de teste: unitario puro
- cenarios obrigatorios:
  - 4 aprovadas, servico em 2: `proposals` 2, `adherence` 0.5
  - mesmo servico duas vezes na mesma proposta: `proposals` 1, `linesTotal` 2, soma das duas linhas
  - linhas 100, `null`, 0: `amountSum` 100, `linesWithAmount` 2, `linesTotal` 3
  - todas `null`: `amountSum` `null`
  - proposta sem servico conta em `approvedProposals`
  - zero aprovadas: `services` vazio
  - ordem por `proposals`, depois `amountSum`, depois nome
- definition of done:
  - `src/functions/report-service-adherence.ts` com spec verde

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: contar linhas em vez de propostas distintas
- repos tocados: `backend`
- fora de escopo desta task: consulta, rota, `Service.price`
- prova minima desta task: `report-service-adherence.spec.ts` cobre os sete cenarios e passa
- criterio de escalada: nenhum previsto
- nivel de autonomia: `L3`

#### Minimal Read Set

- ler primeiro: `03-design.md#Regras de calculo`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `03-design.md#Regras de calculo`
  - `03-design.md#Contratos e dados`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` em `model ProposalService`
- palavras-chave ou simbolos de busca: `ProposalService`, `amount`
- testes provaveis: `art56_server_v3/src/functions/report-service-adherence.spec.ts`
- nao ler por padrao: `security`, repositorios, frontend

### T-05 - Endpoints dos quatro blocos

- objetivo: quatro rotas em `/venue/reports/*` com controller, use case, repositorio e factory, ligando authorizer e funcoes
- cobre requisitos: `R-01`, `R-02`, `R-04`, `R-06`, `R-08`, `R-10`, `R-12`
- depende de: `T-01`, `T-02`, `T-03`, `T-04`
- pode rodar em paralelo com: `T-07`
- reusa: estrutura de `list-venue-rule` (controller com `AuthenticatedRequest`, factory); envelope de `get-analysis-by-month-venue`; `reportYearRange`, `proposalListRange`, `yearStart`
- prompt recomendado: `normal`
- estrategia de teste: spec dos use cases com repositorios fake
- cenarios obrigatorios:
  - 403 nao chama o repositorio de dados
  - ocupacao com `month` monta periodo do mes no ano ativo; sem `month`, o ano
  - antecedencia busca `createdAt` com folga de um dia e filtra pelo ano local
  - `eventCategory=NONE` vira `eventCategory: null` no `where`; ausente nao filtra
  - servicos e porte usam `approved: true` e `startDate: reportYearRange(year)`
  - nenhuma resposta tem `id` de proposta, nome ou contato
- definition of done:
  - metodos novos nas interfaces e nos repositorios Prisma, com `select` minimo
  - rotas com `ensureAuthenticate` em `router/venue.ts`
  - `npm test -- --run` verde; `npx prisma validate` ok; `tsc` sem erro novo nos arquivos tocados

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — endpoints autenticados com dado por espaco
- risco principal: populacao do porte divergir de `analysisByMonth` (aprovadas + `startDate` no ano)
- repos tocados: `backend`
- fora de escopo desta task: endpoints antigos, front, docs
- prova minima desta task: specs dos quatro use cases cobrem os seis cenarios; `npm test -- --run` passa
- criterio de escalada: `complete` se a rota literal colidir com as rotas opcionais existentes do router `venue`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Componentes e modulos impactados`
  - `.cursor/framework_global/framework-libs/database/rules/09_read_models_and_reporting.md`
- caminhos candidatos: `art56_server_v3/src/router/venue.ts`; `src/use-cases/venue-rule/list-venue-rule/*`; `src/use-cases/venue/get-analysis-by-month-venue/*`; `src/repositories/interface/proposal-repository-interface.ts`; `src/repositories/in-prisma/proposal-in-prisma-repository.ts` (`analysisByMonth`); `src/repositories/interface/data-event-repository-interface.ts`; `src/repositories/in-prisma/date-event-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `analysisByMonth`, `reportYearRange`, `AuthenticatedRequest`, `ensureAuthenticate`, `handleErrors`
- testes provaveis: `art56_server_v3/src/use-cases/venue/reports/reports.spec.ts`
- nao ler por padrao: frontend, `01-spec.md` inteiro

### T-06 - Contrato e modelos no frontend

- objetivo: tipos, metodos de servico, quatro hooks React Query e formatadores puros dos blocos
- cobre requisitos: `R-13`, `R-14`
- depende de: nenhuma (usa o contrato do design)
- pode rodar em paralelo com: `T-01`..`T-05`
- reusa: `useGetVenueDashBoardData` como modelo de hook; `EVENT_CATEGORY_OPTIONS`
- prompt recomendado: `normal`
- estrategia de teste: unitario de `report-blocks.ts` (ambiente `node`)
- cenarios obrigatorios:
  - minutos -> `12,5 h`; 0 -> `0 h`
  - celulas reordenadas de segunda a domingo; intensidade 0 a 1 pelo maior valor do grupo escolhido
  - `approvalRate` `null` -> `indisponível`; 0.25 -> `25%`
  - cobertura `valor registrado em 12 de 15 linhas`; zero com valor -> `sem valor registrado`
  - `capacity` `null` -> indicador indisponivel
  - rotulo do periodo: `Ano inteiro` ou `Março de 2026`
- definition of done:
  - `types/venue.ts`, `services/venue.service.ts`, `hooks/venue/queries/venueReportBlocks.ts`, `components/reports/report-blocks.ts` e teste
  - `npm test` verde

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: query key sem filtro e cache misturando categorias ou meses
- repos tocados: `frontend`
- fora de escopo desta task: componentes visuais, `venueReportsStore`
- prova minima desta task: `report-blocks.test.ts` cobre os seis cenarios e passa
- criterio de escalada: nenhum previsto
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `01-spec.md#Criterios de aceite`
- caminhos candidatos: `eventhub-vista-dashboard/src/hooks/venue/queries/venueDashBoardData.ts`; `src/services/venue.service.ts` (`getVenueTrafficCount`); `src/types/venue.ts`; `src/lib/event-category.ts`; `src/components/reports/report-metrics.ts`
- palavras-chave ou simbolos de busca: `useQuery`, `keepPreviousData`, `queryKey`, `EVENT_CATEGORY_OPTIONS`
- testes provaveis: `eventhub-vista-dashboard/src/components/reports/report-blocks.test.ts`
- nao ler por padrao: backend, `security`, `ReportsChartCard.tsx` alem das classes

### T-07 - Cards dos quatro blocos nas abas

- objetivo: `ReportBlock` e os quatro cards, inseridos em `BudgetsReport` e `EventsReport`
- cobre requisitos: `R-13`, `R-14`
- depende de: `T-06`
- pode rodar em paralelo com: `T-05`
- reusa: classes de card de `ReportsChartCard`; `ui/skeleton`, `ui/select`; recharts para barras
- prompt recomendado: `normal`
- estrategia de teste: lint, build e browser
- cenarios obrigatorios:
  - ocupacao: grade 7 x 12 com legenda, alternancia `Todos`/`Eventos`/`Visitas`/`Bloqueios`, seletor `Ano inteiro` + meses, total de horas e dias com registro, tabela `sr-only`
  - antecedencia: mediana, barras por faixa com total, aprovados e taxa, excluidos, filtro de categoria
  - servicos: ranking com barra de adesao, `valor em orçamentos aprovados` e cobertura, filtro de categoria
  - porte: faixas de convidados, categorias, indicador de capacidade ou `indisponível`
  - cada card: skeleton, erro com `Tentar de novo`, vazio `Nenhum registro neste periodo.`
  - `ReportsChartCard` sem mudanca
- definition of done:
  - cards nas abas certas, abaixo do conteudo atual
  - `npm run lint` sem erro novo; `npm run build` ok

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: um bloco com erro esconder os outros ou o conteudo atual da aba
- repos tocados: `frontend`
- fora de escopo desta task: header da pagina, aba `Financeiro`, refatorar `ReportsChartCard`
- prova minima desta task: `npm run build` ok e, no browser, as duas abas mostram os cards com dado, vazio e erro (API parada)
- criterio de escalada: `complete` se o mapa de calor precisar de biblioteca nova
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Componentes e modulos impactados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Componentes e modulos impactados`
  - `.cursor/framework_global/framework-libs/design/rules/07_data_display_and_dashboards.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx` (`LeadBars`, `CategoryDonut`); `src/components/reports/BudgetsReport.tsx`; `src/components/reports/EventsReport.tsx`; `src/components/ui/select.tsx`; `src/components/ui/skeleton.tsx`
- palavras-chave ou simbolos de busca: `rounded-2xl border bg-white p-5 shadow-sm`, `bg-violet-100`, `sr-only`, `ResponsiveContainer`
- testes provaveis: `report-blocks.test.ts` (de `T-06`)
- nao ler por padrao: backend, `security`, `venueReportsStore.ts`

### T-08 - Documentacao e prova no browser

- objetivo: registrar contrato e regras nos docs e provar os quatro blocos no browser
- cobre requisitos: `R-15`
- depende de: `T-05`, `T-07`
- pode rodar em paralelo com: nenhuma
- reusa: formato da tabela de `api-endpoints.md`
- prompt recomendado: `smart`
- estrategia de teste: leitura dos docs e browser
- cenarios obrigatorios:
  - quatro linhas novas em `api-endpoints.md` (auth, permissao)
  - secao dos blocos em `topics/reports-and-kpis.md` com regras, fuso fixo e divida de permissao dos endpoints antigos
  - browser: soma das faixas de convidados = KPI de eventos do ano
- definition of done:
  - docs atualizados; `05-state.md` com a prova; validador do framework sem erro novo

#### Context Pack

- frente principal: docs
- superficie sensivel: nao
- risco principal: topic divergir do contrato implementado
- repos tocados: `eventhub-docs`
- fora de escopo desta task: codigo
- prova minima desta task: `py -3 framework_global/framework-base/tools/validate-framework.py --core .cursor/framework_core --global-root framework_global --strict` sem erro novo e prova de browser registrada
- criterio de escalada: nenhum previsto
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: nenhuma
- documentos obrigatorios:
  - `.cursor/framework_core/project/api-endpoints.md`
  - `.cursor/framework_core/topics/reports-and-kpis.md#Relatorios (/venue/:id/reports)`
- caminhos candidatos: os dois documentos acima
- palavras-chave ou simbolos de busca: `analysisByMonth`, `trafficCount`
- testes provaveis: nenhum
- nao ler por padrao: codigo alem da rota final
