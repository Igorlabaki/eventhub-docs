# Clarify — Investimento em anuncios por canal

## Perguntas criticas

- Qual janela de data cruza gasto e orcamento?
- Como a recorrente vira gasto no ano?
- Quantos canais por despesa e quais opcoes?
- Onde e como o resultado aparece?

## Respostas confirmadas

Fechadas no chat de origem (nao reabrir):

- um canal por despesa; campanha da Meta no Instagram e no Facebook vira duas despesas
- metricas de anuncio usam o `createdAt` do orcamento (chegada do lead), nao o `startDate`; o resto do relatorio fica igual
- recorrente de Publicidade conta do mes de cadastro ate o mes atual, sem projetar futuro
- card "Investimento em anuncios" com Canal | Investido | Orcamentos | Custo/orcamento | Eventos | Custo/evento | Retorno + linha de total
- opcoes de canal: Instagram, Facebook, TikTok, Google, Outros (sem Amigos); campo so aparece e so e obrigatorio em Publicidade
- valor mensal da recorrente: semanal x52/12, quinzenal x2, mensal x1, anual /12
- em 2026-11-14 o usuario pediu para corrigir nesta spec o recorte das esporadicas em `/expense/analysis` (antes registrado como fora de escopo)

Confirmadas no codigo:

- `Expense` tem `createdAt @default(now())`, `paymentDate DateTime?`, `recurring`, `type` e `category`; so `@@index([venueId])`
- `paymentDate` e gravado em wall-clock (`parseDateOnlyWallClock` nos controllers de create e update): o ano sai de componentes UTC
- `trafficCount` agrupa propostas por `trafficSource` sem filtro de `ProposalType`; o card novo tambem nao filtra tipo
- `TrafficSource` tem `AIRBNB` e `FRIEND` alem dos cinco canais do formulario
- `/expense/analysis` trata `recurring = true` como recorrente e o resto como esporadica, independente do `type`
- o controller de criar despesa valida com zod mas passa o `body` cru ao use case
- `PrismaExpenseRepository.analyze` filtra esporadicas com `gte: new Date(year, 0, 1)` e `lt: new Date(year, 12, 31)`: hora local do servidor e fim em 31/01 do ano seguinte; `reportYearRange(year)` ja da o ano em UTC (`functions/report-year-range.ts`)

## Requisitos implicitos confirmados

- datas reais (`createdAt`) no fuso `America/Sao_Paulo`, como `report-lead-time`
- divisor zero vira `null`, como nos blocos agregados

## Premissas assumidas

| Pergunta | Premissa default | Risco se estiver errada |
|---|---|---|
| caminho do endpoint | `GET /venue/reports/ads?venueId&year` (padrao dos blocos), nao `/venue/:venueId/ads-report` | so muda a rota e o service do front |
| aba do card | `Financeiro`, abaixo do `FinancialReportCard` | mover o componente de aba |
| linhas da tabela | cinco canais sempre, na ordem Instagram, Facebook, TikTok, Google, Outros; "Sem canal" so com gasto sem canal | ajuste na lista `ADS_CHANNELS` |
| linha de total | `spent` soma tudo; orcamentos, eventos e receita so dos cinco canais | custo do total diferente do esperado; ajuste em `buildAdsReport` |
| o que e evento | `approved = true` entre os criados no ano, sem exigir `startDate` no ano | numero diferente da aba `Evento`; documentado no subtitulo do card |
| canal em categoria nao Publicidade | ignorar e gravar `null` (nao 400) | nenhum dado perdido; frontend ja envia `null` |
| esporadica sem `paymentDate` | usa o `createdAt` local | so atinge dado antigo; o zod ja exige data na esporadica nova |
| formato do retorno | multiplo `receita / investido`, uma casa (`8,0x`) | trocar o formatador |
| recorrente com `type = SPORADIC` | vale 0, como hoje na analise | dado inconsistente segue fora |
| esporadica com `recurring = false` e `type` mensal | entra uma vez pelo `paymentDate` (vale o `recurring`) | igual a analise atual |
| canal na lista de despesas | rotulo do canal ao lado do nome nas despesas de Publicidade | so visual |
| estado vazio | vazio quando o investido total do ano e 0, com texto que pede para cadastrar despesa de Publicidade com canal | dono sem gasto nao ve orcamentos por canal (ja estao em "Canais de entrada") |
| "mes atual" | mes local de `now` em `America/Sao_Paulo`, injetado na funcao para teste | nenhum |

## Perguntas de erro e borda ainda abertas

- nenhuma bloqueante; as bordas estao em `01-spec.md#Casos de erro e borda obrigatorios`

## Itens bloqueantes

- aplicar a migration na `main` exige aprovacao nomeada (`T-01`)

## O que pode seguir mesmo com lacunas

- `T-02`, `T-04` e `T-07` (com o contrato de `03-design.md#Contratos e dados`) seguem sem a coluna aplicada
