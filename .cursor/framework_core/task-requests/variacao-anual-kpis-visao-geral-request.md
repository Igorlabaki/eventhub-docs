# Solicitacao da Tarefa

## Nome sugerido da tarefa

Variacao anual dos KPIs da visao geral do espaco

## Resumo da solicitacao

Os quatro cards de KPI da visao geral do espaco (Eventos, Orcamentos, Visitas Agendadas e Receita Mensal) passam a mostrar, no canto superior direito, o percentual de alta ou queda contra o mesmo mes do ano anterior. Hoje so Orcamentos mostra um percentual, e ele compara com o mes anterior.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: nao — nao muda auth, pagamento, segredo nem dado novo; o analytics continua restrito ao espaco
- risco principal: o percentual comparar com outra janela que nao a do numero do card, ou nascer de conta feita no navegador
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: comparar com o mes anterior; comparar so ate o dia de hoje; tooltip com o valor absoluto do ano anterior; graficos de Desempenho Mensal e Anual; proximo evento e proxima visita; seletor de mes e ano; pagina de orcamentos e relatorios
- prova minima desta execucao: em `/venue/:id` com novembro de 2026 selecionado, os quatro cards mostram o percentual inteiro contra novembro de 2025; em `Anual`, contra o ano anterior inteiro; alta, queda, zero e ausencia de base ficam distinguiveis; vitest do backend cobre a janela do ano anterior e o do painel cobre o canto dos quatro cards
- criterio de escalada: a spec e o caminho, porque muda o significado de tres campos do contrato e cria um quarto, atravessando backend e frontend
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts` no calculo de `firstDayOfLastMonth` e das variacoes; `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.tsx` em `MonthChange` e `OverviewKpiCard`
- libs obrigatorias: `node`, `patterns`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
- caminhos candidatos: `art56_server_v3/src/repositories/interface/venue-repository-interface.ts` (`VenueAnalyticsResponse`); `eventhub-vista-dashboard/src/types/venue.ts` (`VenueDashboardData`); `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.test.tsx`; `eventhub-vista-dashboard/src/components/reports/report-metrics.ts` so para leitura do padrao `percentDelta` e `vs. <ano>`
- palavras-chave ou simbolos de busca: `getVenueAnalytics`, `proposalsVariation`, `visitsVariation`, `revenueVariation`, `eventsThisMonth`, `firstDayOfLastMonth`, `MonthChange`, `percentDelta`
- testes provaveis: janela de comparacao para um mes e para `all`; base zero no ano anterior; queda com o sinal certo; quatro cards com o canto; texto acessivel citando o ano anterior
- nao ler por padrao: `security`, `database`, `topics/`, schema Prisma, specs de outras frentes

## Contexto informado na entrada

Pedido em chat, com print dos quatro cards da visao geral (Eventos 2, Orcamentos 248 com `+42%`, Visitas Agendadas 3, Receita Mensal R$ 9.089,00): todos os KPIs devem ter o percentual comparando com esse mes, so que no ano passado.

## Problema atual

So o card de Orcamentos mostra variacao, e contra o mes anterior. O backend ja calcula `visitsVariation` e `revenueVariation` (tambem contra o mes anterior), mas os cards nao exibem. Eventos nao tem variacao. Com o mes selecionado nao da para saber se o resultado esta acima ou abaixo do mesmo mes no ano passado.

## Objetivo da mudanca

Quem abre a visao geral le, no canto superior direito de cada um dos quatro cards, o percentual inteiro de alta ou queda contra o mesmo mes do ano anterior (ou contra o ano anterior, em `Anual`).

## Escopo inicial percebido

A janela de comparacao do analytics do espaco passa de mes anterior para mesmo mes do ano anterior; `all` ja compara com o ano anterior e fica como esta. Nasce `eventsVariation`. O painel passa a mostrar a variacao nos quatro cards. Sem schema novo nem endpoint novo.

## Itens incluidos neste request

- janela de comparacao: mesmo mes do ano anterior com mes selecionado; ano anterior inteiro em `Anual`
- `eventsVariation` no analytics, contando so `type = EVENT`, como `eventsThisMonth`
- `proposalsVariation`, `visitsVariation` e `revenueVariation` recalculadas na nova janela
- canto com percentual em Eventos, Orcamentos, Visitas Agendadas e Receita (Mensal ou Anual)
- texto acessivel do canto dizendo contra qual periodo compara (ex.: `em relacao a novembro de 2025`)

## Requisitos implicitos ja visiveis

- variacao relativa `(atual - anterior) / anterior`, exibida como inteiro
- subir e melhor nos quatro cards: positivo em verde, negativo em vermelho, zero neutro
- o numero principal de cada card nao muda
- o percentual vem do backend, nao de soma no navegador
- os tipos `VenueAnalyticsResponse` e `VenueDashboardData` acompanham o campo novo
- durante o loading dos numeros, o canto some junto com o numero, como hoje

## Casos de erro e borda ja percebidos

- ano anterior com zero no KPI: o backend hoje devolve `100`; premissa: sem base, o canto mostra um traco, como na lista de orcamentos
- queda: `MonthChange` ja prefixa `-` e o backend manda `value` negativo, entao a queda apareceria como `--40%`; o canto deve mostrar um sinal so
- ano atual e anterior em zero: traco, nao `0%` nem `+100%`
- mes corrente ainda em andamento: compara o mes inteiro, nao so ate hoje
- fevereiro em ano bissexto contra ano comum: mes inteiro contra mes inteiro
- `lastDayOfMonth` cai a meia-noite do ultimo dia, entao eventos mais tarde nesse dia ficam fora da contagem nas duas janelas; ver pergunta em aberto

## Dependencias

- endpoint de analytics do espaco que ja alimenta a visao geral
- request [Carregar so os numeros dos KPIs ao trocar mes ou ano](loading-kpis-troca-mes-ano-request.md), que define o `numbersLoading` dos cards
- nenhum schema novo

## Restricoes e cuidados

- nao alterar os graficos de Desempenho Mensal e Anual nem `sameMonthRevenueByYear`
- nao recalcular percentual no navegador
- manter a data do evento em wall-clock
- reaproveitar o padrao de texto `vs. <ano>` de `report-metrics.ts` se couber, sem acoplar o card aos relatorios
- derivar por repositorio antes de executar: `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Sem base no ano anterior, traco ou `+100%`? Premissa default: traco, igual a lista de orcamentos.
- Em `Anual`, compara com o ano anterior inteiro? Premissa default: sim, como o backend ja faz.
- Corrigir o fim do mes a meia-noite junto? Premissa default: nao; muda o numero principal do card e fica para outro request. Registrar o achado.
- O canto mostra o ano comparado (ex.: `+42% vs. 2025`) ou so o percentual? Premissa default: so o percentual visivel, com o periodo no texto acessivel, para caber no card.

## Prioridade sugerida

media

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: muda o significado de tres campos do contrato do analytics e cria um quarto, atravessando backend e frontend, com calculo e canto do card que se separam em tasks

## Sugestao de slug da spec

- `framework_core/specs/2026-11-08-variacao-anual-kpis-visao-geral/`

## Sugestao de nome do arquivo

- `variacao-anual-kpis-visao-geral-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-08-variacao-anual-kpis-visao-geral/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
