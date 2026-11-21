# Spec — Investimento em anuncios por canal

## Problema

O dono registra anuncio e patrocinio como despesa da categoria Publicidade (`ADVERTISING`), mas a despesa nao diz em que rede o dinheiro foi gasto. O relatorio ja mostra de onde os orcamentos vieram (`Proposal.trafficSource`, card "Canais de entrada"), mas nao quanto cada canal custou. Sem isso nao da para comparar canais nem saber se o anuncio se paga.

Junto, a analise de despesas (`/expense/analysis`) tem dois erros que distorcem o Financeiro: ignora a recorrencia `WEEKLY` (a despesa semanal entra com valor zero, `PRICE-05`) e fecha o intervalo das esporadicas em `new Date(year, 12, 31)`, ou seja, 31 de janeiro do ano seguinte, contando no ano as despesas pagas em janeiro do ano seguinte. O inicio `new Date(year, 0, 1)` tambem e hora local do servidor; com `paymentDate` gravado em meia-noite UTC, um servidor fora de UTC deixa de fora o pagamento de 1/1.

## Objetivos

- registrar o canal em toda despesa de Publicidade nova ou editada
- mostrar, para o ano escolhido e por canal, investido, orcamentos, custo por orcamento, eventos, custo por evento e retorno, com linha de total
- corrigir o `WEEKLY` na analise de despesas com a mesma regra de valor mensal usada no card
- corrigir o recorte do ano das esporadicas na analise de despesas para 1/1 ate 31/12 do ano pedido

## Fora de escopo

- separar orcamento organico de pago no mesmo canal (sem UTM ou atribuicao por campanha)
- mais de um canal por despesa (campanha em duas redes vira duas despesas)
- projetar gasto recorrente futuro
- mudar a janela de data dos outros blocos (continuam em `startDate`) ou aplicar "conta a partir do cadastro" na analise do Financeiro
- backfill de canal nas despesas antigas
- guardar historico de despesa recorrente excluida
- permissao dos endpoints `/expense/*` e `/expense/analysis` (divida existente)

## Cenarios

- O dono cadastra "Meta Instagram novembro", Publicidade, Mensal, R$ 1.000, canal Instagram. Em dezembro, o card de 2026 mostra Instagram com R$ 2.000 investidos (novembro e dezembro).
- O dono abre uma despesa de Publicidade antiga sem canal para editar: o formulario pede o canal antes de salvar.
- O dono troca uma despesa de Publicidade para Manutencao: o canal some e a despesa deixa de entrar no card.
- Em 2026 o Instagram recebeu R$ 3.000, trouxe 30 orcamentos criados no ano e 6 deles foram aprovados somando R$ 24.000: custo/orcamento R$ 100, custo/evento R$ 500, retorno 8,0x.

## Criterios de aceite

- `R-01`: `Expense.trafficSource` existe como `TrafficSource?` com indice `[venueId, category]`; despesas existentes ficam com `null` e nenhum total atual muda por causa da coluna.
- `R-02`: criar ou editar despesa cuja categoria final seja `ADVERTISING` sem canal devolve 400 "Informe o canal da despesa de Publicidade."; canal fora de `INSTAGRAM`, `FACEBOOK`, `TIKTOK`, `GOOGLE`, `OTHER` devolve 400 pelo zod.
- `R-03`: despesa cuja categoria final nao seja `ADVERTISING` grava `trafficSource = null`, inclusive quando o payload traz canal ou quando a edicao troca Publicidade por outra categoria.
- `R-04`: edicao parcial sem `category` e sem `trafficSource` preserva os valores gravados; editar uma despesa de Publicidade antiga sem canal e sem enviar canal devolve 400.
- `R-05`: valor da recorrente: `WEEKLY` x52/12 por mes e x52 no ano; `BIWEEKLY` x2 e x24; `MONTHLY` x1 e x12; `ANNUAL` /12 e x1; recorrente com tipo `SPORADIC` vale 0.
- `R-06`: `/expense/analysis` soma `WEEKLY` recorrente pela regra de `R-05` (fecha `PRICE-05`); os demais calculos de recorrente ficam iguais.
- `R-15`: `/expense/analysis` conta a esporadica no ano quando `paymentDate` esta em `reportYearRange(year)` (de `year-01-01T00:00Z` ate antes de `(year+1)-01-01T00:00Z`): pagamento de 1/1 do ano entra, de 31/12 entra, de 1/1 do ano seguinte nao entra, independente do fuso do servidor.
- `R-07`: recorrente de Publicidade conta `valor mensal x meses ativos`, do mes de cadastro (`createdAt` em `America/Sao_Paulo`) ate o mes atual no ano corrente ou ate dezembro em ano passado; ano futuro e cadastro depois do ultimo mes contam 0.
- `R-08`: esporadica de Publicidade entra no ano pelo `paymentDate` (componentes UTC, wall-clock); sem `paymentDate`, pelo `createdAt` local.
- `R-09`: orcamentos de um canal = propostas do espaco com `createdAt` no ano local e `trafficSource` igual ao canal; eventos = as aprovadas (`approved = true`) desse conjunto; receita = soma de `totalAmount` dessas aprovadas.
- `R-10`: `GET /venue/reports/ads?venueId&year` exige `VIEW_VENUE_ANALYSIS` (401/404/403; 400 pelo zod) e devolve as linhas dos cinco canais em ordem fixa, mais "Sem canal" so quando houver gasto de Publicidade sem canal; `costPerProposal`, `costPerEvent` e `roas` sao `null` quando o divisor e zero; `roas = revenue / spent`.
- `R-11`: no total, `spent` soma todas as linhas (inclusive "Sem canal"); `proposals`, `events` e `revenue` somam os cinco canais; custos e retorno do total sao recalculados sobre essas somas.
- `R-12`: no formulario de despesa, o select Canal (Instagram, Facebook, TikTok, Google, Outros) so aparece e so e obrigatorio em Publicidade; trocar a categoria limpa o canal; a edicao vem preenchida; fora de Publicidade o payload envia `trafficSource: null`.
- `R-13`: a aba `Financeiro` mostra o card "Investimento em anuncios" abaixo do card financeiro, com Canal | Investido | Orcamentos | Custo/orcamento | Eventos | Custo/evento | Retorno, linha de total, `—` para `null`, retorno como `8,0x`, e estados de carregando, erro com `Tentar de novo` e vazio quando nao ha gasto de Publicidade no ano.
- `R-14`: `topics/reports-and-kpis.md`, `project/api-endpoints.md`, `product/08-data-model.md` e `topics/improvement-backlog.md` descrevem o comportamento novo.

## Requisitos implicitos

- frontend antigo continua criando e editando despesas das outras categorias
- dinheiro em `Float` (D-07); o backend calcula custos e retorno, o front so formata
- o card reaproveita nomes e cores de `TRAFFIC_SOURCES`
- a correcao do `WEEKLY` muda total de despesas e margem do Financeiro de quem tem despesa semanal; e esperado
- a correcao do recorte tira do ano as esporadicas pagas em janeiro do ano seguinte; o total do ano e o comparativo com o ano anterior podem cair; e esperado

## Casos de erro e borda obrigatorios

- canal com gasto e sem orcamento: custos `null`, retorno `0`
- canal com orcamentos e sem gasto: custos e retorno `null`
- linha "Sem canal": orcamentos, eventos e receita `0`; custos e retorno `null`
- recorrente cadastrada em dezembro de 2025 vista em 2026: conta de janeiro ate o mes atual
- ano sem gasto de Publicidade: card vazio, sem erro
- usuario sem `VIEW_VENUE_ANALYSIS`: 403 so no card novo
- `FRIEND` e `AIRBNB` nao aparecem no card nem sao aceitos como canal de despesa

## Impacto esperado

O dono compara canais por custo e retorno, e o Financeiro deixa de subestimar despesas semanais e de somar no ano as esporadicas de janeiro do ano seguinte.

## Areas impactadas

- banco: `expense` (coluna e indice)
- backend: `zod/expense`, `use-cases/expense/{create,update,analysis}-expense`, `repositories/*expense*`, `repositories/*proposal*`, `functions/` (recorrencia e relatorio), `use-cases/venue/reports/ads/`, `router/venue.ts`
- frontend: `types/expense.ts`, `components/expense/expense-form.tsx`, `expense-list.tsx`, `types/venue.ts`, `services/venue.service.ts`, `hooks/venue/queries/venueReportBlocks.ts`, `components/reports/` (card, formatadores, `FinancialBalanceReport.tsx`)

## Restricoes e dependencias

- migration aditiva na `main` por deploy request, com aprovacao nomeada
- deploy: banco, API, front logo em seguida (entre a API e o front, o front antigo nao salva despesa de Publicidade)
- padrao dos blocos de `specs/2026-11-10-novos-blocos-relatorios/` (`ReportAuthorizer`, `report-query.ts`, `ReportController`, `ReportBlock`)

## Mapeamento requisito -> task -> prova

| Requisito | Task | Prova |
|---|---|---|
| `R-01` | `T-01` | `npx prisma validate`; `SHOW COLUMNS` e `SHOW INDEX` na `main` |
| `R-05`, `R-06`, `R-15` | `T-02` | `expense-recurrence.spec.ts`; spec da analise com `WEEKLY`; spec do `analyze` com o intervalo do ano |
| `R-02`, `R-03`, `R-04` | `T-03` | specs de create e update de despesa |
| `R-07`, `R-08`, `R-09`, `R-11` | `T-04` | `report-ads.spec.ts` |
| `R-10` | `T-05` | spec do use case com fakes (401/403/404, envelope, linhas) |
| `R-12` | `T-06` | teste do helper do formulario; build |
| `R-13` | `T-07` | `report-blocks.test.ts`; build |
| `R-14` | `T-08` | docs atualizados; browser |

## Base documental consultada

- `task-requests/investimento-anuncios-por-canal-request.md`
- `project/agent-entrypoint.md`, `project/active-libs.md`
- `topics/reports-and-kpis.md`, `topics/improvement-backlog.md#PRICE-05`
- `specs/2026-11-10-novos-blocos-relatorios/` (`03-design.md`, `04-tasks.md`, `05-state.md`)
- codigo lido: `prisma/schema.prisma` (`Expense`, enums), `zod/expense/*`, `use-cases/expense/*`, `expense-in-prisma-repository.ts`, `use-cases/venue/reports/*`, `functions/report-lead-time.ts`, `local-date.ts`, `report-year-range.ts`, `proposal-in-prisma-repository.ts#trafficCount`; front `expense-form.tsx`, `types/expense.ts`, `VenueExpenses.tsx`, `VenueReports.tsx`, `FinancialBalanceReport.tsx`, `ReportBlock.tsx`, `LeadTimeCard.tsx`, `venueReportBlocks.ts`, `report-metrics.ts#TRAFFIC_SOURCES`

## Operacao

- tipo: `spec`
- proxima task: `T-01` (em paralelo com `T-02`)
- execucao recomendada: `spec-task-execution` task a task
- proxima acao: executar `T-01` e `T-02`
- entrada publica recomendada: `fw:run`
