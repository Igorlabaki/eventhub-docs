# Pricing and Proposal Calculation — EventHub

Como o backend calcula o valor de um orcamento hoje (2026-11-10). Fonte: `art56_server_v3/src/functions/` e `src/use-cases/proposal/`. Mudanca aqui e sensivel (dinheiro) e exige spec ou task-request com testes de `functions/`.

## Entradas no Venue

- `pricingModel`: `PER_PERSON`, `PER_DAY`, `PER_PERSON_DAY`, `PER_PERSON_HOUR`, `TIERED`;
- precos de catalogo: `pricePerPerson`, `pricePerDay`, `pricePerPersonDay`, `pricePerPersonHour`;
- `standardEventDuration` (horas), `maxGuest`, `minimumPrice` (padrao 0), `hasOvernightStay`, `minimumNights`, `checkIn`/`checkOut`, `openingHour`/`closingHour`;
- `SeasonalFee` (adicional `SURCHARGE` ou desconto `DISCOUNT`, `fee` inteiro em %, intervalo `dd/MM` ou `affectedDays` CSV de dias em ingles ou `all`);
- `Goal` (faixa `minValue`..`maxValue` de receita mensal, `increasePercent`, `months` CSV `1..12`);
- `MinimumPricePeriod` (piso por intervalo `dd/MM`, `price`);
- `Service` (`price`, `pricingType` `FIXED`/`PER_HOUR`/`PER_PERSON`, `rpaRequired`, `rpaMinPeople` = obrigatorio a partir de N pessoas).

## Pipeline atual (`proposal-amounts.ts`)

1. `catalogUnitPrice`: escolhe o preco pelo modelo; `TIERED` devolve `null` (tabelas `TieredPrice`/`Tier` existem sem calculo).
2. `applyWallClockSeason`: soma os % de todas as `SeasonalFee` que valem para a data (intervalo com virada de ano ou dia da semana); `unit += unit * soma / 100`.
3. `adjustVenueUnitPrice`: le a receita do mes (`monthlyRevenueAnalysis` = soma de `totalAmount` das propostas aprovadas); se houver, aplica o `increasePercent` da `Goal` cuja faixa contem a receita e cujo `months` inclui o mes.
4. `calcProposalAmounts`:
   - `PER_PERSON`: base = convidados x unitario; horas extras = duracao - `standardEventDuration`; preco da hora extra = `round(base / 6)`;
   - `PER_PERSON_HOUR`: base = duracao x convidados x unitario (se o mes ja tem receita, cai na formula de `PER_PERSON`);
   - `PER_DAY`: base = unitario; `PER_PERSON_DAY`: base = unitario x convidados.
5. `applyMinimum` + `resolveMinimumPrice`: piso = maior `MinimumPricePeriod` que contem a data, senao `venue.minimumPrice`; se total < piso, `basePrice = piso`, horas extras zeradas, `totalAmount = piso + servicos`, `minimumApplied = true`.

## Servicos (`quote-service-lines.ts`)

- quantidade: `FIXED` = 1, `PER_PERSON` = convidados, `PER_HOUR` = horas escolhidas (padrao = duracao do evento);
- horas inteiras, no maximo a duracao do evento e 8760;
- `amount = price x (quantity - courtesyQuantity)`; cada linha vira snapshot em `ProposalService` (`pricingType`, `unitPrice`, `quantity`, `courtesyQuantity`, `amount`), que nao muda se o servico mudar depois;
- cortesia: inteiro de 0 ate `quantity` (`FIXED` = 0 ou 1); no painel o modo `strict` recusa acima da quantidade com 400; recalculo publico usa `clamp` e reduz a cortesia gravada ate a quantidade nova; o `PUT` publico de servicos faz o mesmo com `min` por linha por hora;
- dar cortesia exige `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` no Venue (`assertCourtesyAllowed`); sem authorizer injetado falha fechado com 403; rotas publicas nunca leem cortesia do corpo;
- total manual (`totalAmountInput`) e `BARTER` continuam vencendo; a cortesia so muda a linha;
- exibicao: painel e link mostram `unitario x quantidade`, a linha "Cortesia" com o desconto e o valor final; o unitario por hora no link vem do `unitPrice` gravado, nunca de `amount / horas`;
- obrigatorios: servico com `rpaRequired` a partir de `rpaMinPeople` fica marcado e travado nos formularios e no link publico.

## Desconto em % (`proposal-discount.ts`)

- `proposal.discountPercent` (0..100, ate 2 casas) e `proposal.discountAmount` (R$); `totalAmount` gravado e o liquido; subtotal = `totalAmount + discountAmount` (sem divisao, vale em 100%);
- conta: `discountAmount = round2(subtotal x % / 100)`, `totalAmount = round2(subtotal - discountAmount)`; a mesma formula existe em `lib/proposal-discount.ts` no frontend;
- so `createPerPerson` e `updatePerPerson` recebem `discountPercent`; com % > 0 o backend calcula pelo pipeline e ignora `totalAmountInput`; espaco sem preco de catalogo responde 400 (`NO_QUOTE_MESSAGE`);
- dar desconto exige `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` (`assertDiscountAllowed`, falha fechado); `BARTER`, total manual e `updatePerDay` gravam desconto 0; `/quote` nunca aplica desconto;
- link publico: `PUT .../services` sem mudanca mantem; com mudanca reconstroi o subtotal e zera o desconto; `PUT .../recalculate` com mesma data, convidados e horas reaplica a % sobre o subtotal novo, senao zera; o historico ganha " (desconto de X% removido)";
- painel: o campo `Desconto (%)` no bloco `Total estimado` substitui `Usar este valor` e preenche o `Total` com o total com desconto; digitar no `Total` limpa a %.

## Onde cada caminho roda

| Fluxo | Calculo |
|---|---|
| `create-proposal-per-person` | `BARTER` grava zero; modelo por pessoa/hora com catalogo e sem total manual usa o pipeline; com `totalAmountInput` manual usa `calcCustomTotalAmount` (rateia total por horas e separa extras) |
| `create-proposal-per-day` | copia inline de sazonal + meta; `PER_DAY` = dias x preco/dia; `PER_PERSON_DAY` = dias x preco x convidados; aplica piso; total manual: base = total - servicos |
| `update-proposal-per-day` | `adjustProposalUnitPrice` antigo (date-fns em horario local) |
| `POST /proposal/quote` | so `PER_PERSON` e `PER_PERSON_HOUR`; nao grava; usado pelo total estimado no painel |
| `PUT /proposal/presentation/:id/recalculate` (publico) | bloqueado se aprovado, pago, mais de um dia, `BARTER` ou `TIERED` |
| `PUT /proposal/presentation/:id/services` (publico) | so soma ou remove servicos; obrigatorios permanecem |
| legado `calc-base-price`, `calc-standart-total-amount` | valores fixos antigos; nao usados nos fluxos atuais |

## Estado da proposta derivado de dinheiro e agenda

- `approved = true` ao criar `DateEvent` `EVENT`, `PRODUCTION` ou `BARTER` ligado a proposta; volta a `false` ao apagar esse DateEvent;
- `amountPaid` atualizado em create/update/delete de Payment e em delete de Document; `create-payment` recusa valor acima do saldo;
- `paid` nunca e gravado como `true` por nenhum fluxo; so e lido no recalculo publico;
- `eventCategory` obrigatoria quando `type = EVENT`.

## Riscos registrados

- dinheiro em `Float`, sem regra central de arredondamento (D-07);
- regra sazonal + meta em tres implementacoes com fusos diferentes;
- meta usa receita do mes em horario local; listagens usam wall-clock;
- `TIERED` selecionavel no schema sem calculo;
- `WEEKLY` em despesas recorrentes ignorado na analise.

## Testes que provam

`functions/*.spec.ts` (proposal-amounts, quote-service-lines, proposal-discount, resolve-minimum-price, adjust-proposal-unit-price, people-within-guest-cap) e specs de `use-cases/proposal/*`. No frontend: `lib/per-person-amount`, `lib/proposal-quote-input`, `lib/service-price-label`, `lib/service-courtesy`, `lib/proposal-discount`, `lib/event-duration`.
