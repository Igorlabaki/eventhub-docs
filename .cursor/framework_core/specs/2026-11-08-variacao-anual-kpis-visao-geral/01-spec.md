# Spec — Variacao anual dos KPIs da visao geral do espaco

## Problema

Na visao geral do espaco (`/venue/:id`), os cards Eventos, Orcamentos, Visitas Agendadas e Receita mostram o periodo selecionado. So Orcamentos tem percentual no canto, e ele compara com o mes anterior. O backend calcula variacao de visitas e receita contra o mes anterior, mas a tela nao mostra. Eventos nao tem variacao. Uma queda no canto atual sairia como `--40%`, e ano anterior zerado sai como `+100%`.

## Objetivos

Quem abre a visao geral le, no canto superior direito dos quatro cards, o percentual inteiro de alta ou queda contra o mesmo mes do ano anterior; em `Anual`, contra o ano anterior inteiro. O numero principal de cada card nao muda.

## Fora de escopo

- comparar com o mes anterior, ou so ate o dia de hoje dentro do mes corrente
- tooltip ou texto com o valor absoluto do ano anterior
- corrigir a janela local que termina a meia-noite do ultimo dia do mes (muda o numero principal; ver `02-clarify.md`)
- graficos Desempenho Mensal e Anual, `sameMonthRevenueByYear`, proximo evento e proxima visita
- seletor de mes e ano, pagina de orcamentos e relatorios
- remover os campos `proposalsVariation`, `visitsVariation` e `revenueVariation` (limpeza posterior)
- endpoint novo, coluna nova ou migration

## User stories ou cenarios principais

- Quem abre novembro de 2026 ve, em cada card, quanto o numero esta acima ou abaixo de novembro de 2025.
- Quem escolhe `Anual` em 2026 ve cada card contra 2025 inteiro.
- Quem nao teve movimento no ano anterior ve um traco, e o numero atual do card continua visivel.

## Criterios de aceite

- `R-01`: `GET /venue/analytics/:venueId` devolve sempre `yearlyChange: { events, proposals, visits, revenue }`, cada um `Math.round(((atual - anterior) / anterior) * 100)` ou `null` quando o anterior e 0
- `R-02`: com mes selecionado, o anterior e o mesmo mes do ano selecionado menos um; com `month=all`, o ano anterior inteiro; a janela anterior usa a mesma construcao de data da janela do card
- `R-03`: cada campo usa o mesmo filtro do numero do card: `events` conta `DateEvent` `EVENT`; `proposals` conta propostas por `startDate`; `visits` conta `DateEvent` `VISIT`; `revenue` soma `proposal.totalAmount` dos `DateEvent` `EVENT`
- `R-04`: os numeros atuais (`eventsThisMonth`, `proposalsInMonth`, `totalVisits`, `monthlyRevenue`, `monthlyRevenueList`) e `sameMonthRevenueByYear` nao mudam
- `R-05`: `proposalsVariation`, `visitsVariation` e `revenueVariation` continuam no formato e no calculo de hoje, para o bundle antigo do painel nao quebrar; nao ha schema novo nem endpoint novo
- `R-06`: os quatro cards mostram o percentual no canto superior direito com sinal unico, cor e icone; positivo verde, negativo vermelho, zero neutro; `null` vira traco sem seta
- `R-07`: enquanto os numeros carregam, ou se `yearlyChange` nao veio, o canto fica vazio; a tela nao calcula o percentual nem le os campos `*Variation`
- `R-08`: o nome acessivel do canto diz acima, abaixo, igual ou sem comparacao com o mesmo periodo do ano anterior
- `R-09`: sem JWT a rota continua 401

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a rota segue com `ensureAuthenticate` e `venueId`; nada alem do percentual entra na resposta
- erros e mensagens esperadas: espaco inexistente continua como hoje; traco nao e mensagem de erro
- observabilidade minima: sem metrica nova; a prova e o vitest e a tela
- concorrencia, idempotencia ou retry: leitura; cada campo e independente
- rollout, fallback ou degradacao: backend antes da tela; a tela antiga ignora `yearlyChange`; a tela nova sem o campo deixa o canto vazio

## Casos de erro e borda obrigatorios

- caso: 248 contra 175, 3 contra 5, 9089 contra 9089
  impacto: 42, -40 e 0; a queda aparece como `-40%`, nunca `--40%`
  cobertura esperada: unitario em `T-01` e markup em `T-02`
- caso: anterior 0 num KPI e positivo nos outros
  impacto: so aquele campo e `null`
  cobertura esperada: unitario em `T-01`
- caso: atual 0 e anterior positivo
  impacto: -100
  cobertura esperada: unitario em `T-01`
- caso: `Math.round(-10.5)`
  impacto: -10, como na spec irma
  cobertura esperada: unitario em `T-01`
- caso: janeiro selecionado
  impacto: compara com janeiro do ano anterior, nao com dezembro
  cobertura esperada: unitario em `T-01`
- caso: `numbersLoading` ou `yearlyChange` ausente
  impacto: canto vazio, sem 0% nem traco
  cobertura esperada: markup em `T-02`

## Impacto esperado

O analytics do espaco ganha `yearlyChange`. A visao geral desenha esse campo no canto dos quatro cards com o mesmo componente da lista de orcamentos.

## Areas impactadas

- `backend`: `getVenueAnalytics`, `VenueAnalyticsResponse`, funcao pura nova e `docs/referencias/API_CONTRACTS.md#GET /venue/analytics/:venueId`
- `frontend`: `VenueDashboardData`, `VenueStatsPanel` e o canto hoje dentro de `ProposalListSummaryCards`

## Restricoes e cuidados

- nao recalcular o percentual no navegador
- nao trocar o formato dos campos `*Variation` existentes
- a janela anterior repete a construcao da janela do card (`project-decisions.md#D-06` registra o wall-clock; a janela local do card e legado conhecido)
- atualizar o contrato em `docs/` na mesma entrega do backend (`project-decisions.md#D-08`)

## Dependencias

- analytics que ja alimenta a visao geral
- canto `YearlyChange` da spec `2026-11-05-variacao-anual-kpis-orcamentos`
- `numbersLoading` do request `loading-kpis-troca-mes-ano-request.md`
- nenhum schema novo

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-01` -> unitario
- `R-03` -> `T-01` -> unitario e leitura do repositorio
- `R-04` -> `T-01` -> unitario e suite verde
- `R-05` -> `T-01` -> tipo e suite verde
- `R-09` -> `T-01` -> rota inalterada
- `R-06` -> `T-02` -> markup e tela
- `R-07` -> `T-02` -> markup
- `R-08` -> `T-02` -> markup

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md#Premissas assumidas`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `executar task`
- entrada publica recomendada: `fw:run`
