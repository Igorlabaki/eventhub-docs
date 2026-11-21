# Clarify — Novos blocos nos relatorios

## Perguntas criticas

- Como agrupar `DateEventType` em eventos, visitas e bloqueios?
- Ocupacao usa todas as `DateEvent` do espaco ou so as ligadas a propostas aprovadas?
- `Tipo de evento` nos filtros e `eventCategory` ou `Proposal.type`?
- Qual permissao exigir nos endpoints novos?
- Que faixas horarias usar no mapa de calor?

## Respostas confirmadas

- a aba `Evento` conta `Proposal` aprovadas com `startDate` em `reportYearRange(year)` (`analysisByMonth`), nao `DateEvent`
- `DateEventType`: `VISIT`, `EVENT`, `OTHER`, `BARTER`, `PROPOSAL`, `OVERNIGHT`, `PRODUCTION`; nao ha tipo "bloqueio"
- `Venue` so tem `openingHour` e `closingHour`; nao ha dias de funcionamento -> `occupancyRate` fica `null`
- a pagina de relatorios so tem seletor de ano
- o front libera a pagina com `VIEW_VENUE_ANALYSIS`; o backend dos relatorios atuais nao checa permissao
- `startDate`/`endDate` sao wall-clock em componentes UTC (`functions/wall-clock-datetime.ts`); `createdAt` e `@default(now())`

## Requisitos implicitos confirmados

- relatorio nao recalcula preco: usa `ProposalService.amount` gravado
- percentuais e taxas nulos quando o denominador e zero

## Premissas assumidas

| Pergunta | Premissa default | Risco se estiver errada |
|---|---|---|
| grupos de `DateEventType` | `events` = `EVENT`, `OVERNIGHT`, `PRODUCTION`, `BARTER`; `visits` = `VISIT`; `blocks` = `OTHER`; `PROPOSAL` (reserva provisoria) fora | mapa mostra bloqueios a mais ou a menos; ajuste e so a tabela `OCCUPANCY_GROUPS` |
| populacao da ocupacao | todas as `DateEvent` do espaco no periodo, filtradas pelo grupo, sem olhar aprovacao | ocupacao inclui evento de proposta nao aprovada; ajuste = filtro extra no repositorio |
| tipo de evento nos filtros | `eventCategory`, com `NONE` para sem categoria, igual a rosca dos relatorios | filtro diferente do esperado; ajuste no schema de parametros |
| permissao | `VIEW_VENUE_ANALYSIS`, a mesma que libera a pagina | usuario hoje sem a permissao, mas com acesso via URL, passa a receber 403 nos blocos novos (os antigos seguem abertos) |
| faixas horarias | 12 faixas de 2 h (00–02 ... 22–24) | granularidade diferente; ajuste e a constante `BAND_HOURS` |
| fuso do `createdAt` | `America/Sao_Paulo` fixo | espaco em outro fuso teria data local errada; nao ha fuso por espaco no schema |
| recorte mensal | seletor local no card de ocupacao, padrao `Ano inteiro` | se pedirem mes global, vira outra task |
| linha com `amount` 0 | conta como valor registrado | cobertura aparece maior; ajuste = tratar 0 como ausente |
| mediana com quantidade par | media dos dois do meio (pode dar `,5`) | exibicao com uma casa decimal |
| dia sem registro de agenda | nao conta em `daysWithRecords` | nenhum |

## Perguntas de erro e borda ainda abertas

- servico excluido some com suas linhas (`onDelete: Cascade`): a adesao historica dele desaparece; fora de escopo, registrar no topic
- `guestNumber` negativo: tratado como 0 na faixa ate 50

## Itens bloqueantes

- nenhum

## O que pode seguir mesmo com lacunas

- todas as tasks seguem pelas premissas acima
