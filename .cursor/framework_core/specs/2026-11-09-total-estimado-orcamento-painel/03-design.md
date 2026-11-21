# Design — Total estimado do orcamento no painel

## Visao geral da solucao

A conta do recalculo publico sai das funcoes privadas do use case e vira funcao em `src/functions/`. Uma rota autenticada nova monta datas e servicos como a gravacao, chama essa conta e devolve so os valores. Create e update por pessoa passam a chamar a mesma conta nos ramos de tabela. No dashboard, um hook com debounce pede a cotacao e um componente mostra o detalhamento nos dois formularios.

Passada transversal:

- architecture: nao. Rota nova no router de proposal; sem fronteira nova nem ADR.
- database: nao. Leitura de venue, servicos, faturamento e meta que a gravacao ja faz; sem schema, indice ou migration.
- design: sim. Bloco com estados vazio, carregando, valor, minimo e erro; `aria-live="polite"`; botao secundario (`design/rules/06_forms_and_input_ux.md`).
- observability: sim, vai para producao. Sem metrica; `console.error` na negacao do autorizador. Cada cotacao faz ate 6 leituras; o debounce limita a carga.
- security: sim. Rota que expoe valor derivado de meta e faturamento. `ensureAuthenticate`, autorizador por espaco com teste negativo, resposta estreita.
- patterns `rules/06`: sim, concorrencia de respostas no front (chave do `useQuery`). Backend sem estado, idempotente por natureza.

## Componentes e modulos impactados

Backend (`art56_server_v3/`):

- `src/functions/proposal-amounts.ts` (novo): `adjustVenueUnitPrice`, `calcProposalAmounts`, `applyMinimum`, `catalogUnitPrice`, `applyWallClockSeason`.
- `use-cases/proposal/recalculate-public-proposal/use-case-recalculate-public-proposal.ts`: passa a importar as funcoes; mensagens e recusas ficam no use case.
- `use-cases/proposal/quote-proposal/` (novo): `use-case-quote-proposal.ts`, `controller-quote-proposal.ts`, `factory-quote-proposal.ts` e specs.
- `use-cases/proposal/proposal-quote-authorizer.ts` (novo), no molde de `minimum-price-period/venue-price-authorizer.ts`.
- `zod/proposal/quote-proposal-schema.ts` (novo).
- `router/proposal.ts`: `POST /quote` com `ensureAuthenticate`.
- `create-proposal-per-person` e `update-proposal-per-person`: ramos `PER_PERSON` e `PER_PERSON_HOUR` chamam `adjustVenueUnitPrice` + `calcProposalAmounts`. Notificacao, historico, servicos e ramo de Total digitado ficam como estao.

Frontend (`eventhub-vista-dashboard/`):

- `src/types/proposal.ts`: `ProposalQuoteInput`, `ProposalQuote`.
- `src/services/proposal.service.ts`: `quoteProposal`.
- `src/lib/proposal-quote-input.ts` (novo): `buildQuoteInput` puro, devolve `null` com campos incompletos.
- `src/hooks/proposal/queries/quote.ts` (novo): `useProposalQuote`.
- `src/components/proposal/ProposalQuoteSummary.tsx` (novo).
- `PerPersonProposalForm.tsx` e `ProposalEdit.tsx`: bloco abaixo de Serviços.
- `src/lib/per-person-amount.ts`: rotulo com sufixo `(estimado)`.

## Reuso previsto

- Conta: corpo de `calculateAmounts`, `perPersonAmounts`, `adjustUnitPrice`, `applyWallClockSeason`, `applyMinimum` e `catalogUnitPrice` do recalculo publico, movidos sem mudar logica. `applyMinimum` ganha `minimumApplied`.
- Servicos: `listForQuote`, `serviceHoursMap`, `assertChosenServiceHours`, `quoteServiceLines`, `sumServiceQuote`, na mesma ordem do create.
- Datas: `transformDate` sem `divisor` (aceita `YYYY-MM-DD`) e `calcEventDuration`.
- Autorizacao: molde do `VenuePriceAuthorizer` e `getUserVenuePermission`.
- Front: `useDebounce` de `use-debounce` (ja usado em `SearchFilterListByQueries`), `useQuery` no padrao de `hooks/notification/queries/list.ts`, `handleBackendError` para a mensagem.
- Descartado: `adjustProposalUnitPrice` (fuso local, temporada nao vira o ano).

## Contratos e dados

`POST /proposal/quote` (autenticada)

Corpo:

```json
{
  "venueId": "<id>",
  "date": "2026-12-12",
  "startHour": "19:00",
  "endHour": "23:00",
  "guestNumber": 100,
  "serviceIds": ["<id>"],
  "serviceHours": [{ "serviceId": "<id>", "hours": 3 }],
  "type": "EVENT"
}
```

Zod: `date` `YYYY-MM-DD`; horas `HH:mm`; `guestNumber` inteiro >= 1; `serviceIds` default `[]`; `serviceHours` default `[]`; `type` `ProposalType`.

Sucesso 200:

```json
{
  "success": true,
  "message": "Cotação calculada",
  "data": {
    "basePrice": 0,
    "extraHoursQty": 0,
    "extraHourPrice": 0,
    "totalAmountService": 0,
    "totalAmount": 0,
    "minimumApplied": false
  }
}
```

So esses campos em `data`; o controller monta a resposta por lista fixa de chaves, como o recalculo publico.

Ordem no use case: autorizar; carregar venue; `BARTER` devolve zeros; `transformDate`; servicos (`listForQuote`, `assertChosenServiceHours`, `quoteServiceLines`); modelo fora de `PER_PERSON`/`PER_PERSON_HOUR` ou preco ausente recusa; `adjustVenueUnitPrice`; `calcProposalAmounts`.

Funcao compartilhada:

- `adjustVenueUnitPrice(venue, startDate, { proposalRepository, goalRepository })` -> `{ unitPrice, hasMonthlyRevenue }` ou `null` sem preco do modelo.
- `calcProposalAmounts({ venue, unitPrice, hasMonthlyRevenue, startDate, endDate, guestNumber, services })` -> `{ basePrice, extraHoursQty, extraHourPrice, totalAmount, minimumApplied }` ou `null` sem conta. Formulas as de `specs/2026-11-04-recalcular-orcamento-proposta-publica/03-design.md#Contratos e dados`.

## Falhas, casos de borda e invariantes

- sem token: 401 do `ensureAuthenticate`.
- sem permissao: 403 "Voce nao tem permissao de orcamentos neste espaco."
- venue inexistente: 404 do projeto.
- modelo sem conta: 400 "Este espaço não calcula o orçamento sozinho. Informe o Total."
- servico invalido ou horas: 400 com as mensagens de `quote-service-lines.ts`.
- corpo invalido: 400 do Zod via `handleErrors`.
- Invariante: a cotacao nunca chama `create`, `update`, `updateServices`, notificacao nem historico.
- Invariante: o recalculo publico mantem mensagens, recusas e valores.
- Front: entrada incompleta nao chama; erro nao bloqueia salvar; resposta antiga nao sobrescreve a nova.

## Decisoes arquiteturais importantes

- Cotacao no backend, porque meta depende de faturamento do mes e a regra ja diverge entre tres lugares. Descartado: conta no front.
- Rota nova autenticada, em vez de reusar `createPerPerson` (publica e grava) ou o recalculo publico (grava).
- Funcao compartilhada nasce do recalculo publico, a versao wall-clock e testada. Descartado: partir do create (inline e repetido) ou do `adjustProposalUnitPrice`.
- Autorizador proprio com duas permissoes aceitas, porque as telas usam `VIEW_VENUE_PROPOSALS` e `EDIT_VENUE_INFO`. Descartado: `VIEW_VENUE_PRICES`, que bloquearia quem monta orcamento.
- `POST` e nao `GET`: corpo com listas de servicos e horas.
- `useQuery` com chave serializada e debounce, porque React Query ja resolve cache e ordem. Descartado: `useEffect` com `AbortController` ou store Zustand.

## Riscos e mitigacoes

- Extracao mudar o recalculo publico. Mitigacao: `T-01` move sem mudar logica e os specs atuais precisam passar sem edicao de expectativa.
- Update mudar valor em temporada que vira o ano. Mitigacao: teste explicito em `T-03` e registro em `05-state.md`.
- Carga de leituras por digitacao. Mitigacao: debounce de 400 ms e `staleTime` de 30 s.
- Exposicao do efeito da meta. Mitigacao: rota autenticada, autorizacao por espaco, resposta so com valores finais.

## Rollout, observabilidade e rollback

Sem migration e sem flag. Deploy do backend antes do frontend; front antigo nao chama a rota. Rollback: remover o bloco no front; a rota pode ficar. Reverter `T-03` volta create e update ao codigo inline.

## Estrategia de validacao

- `T-01`: vitest da funcao e specs do recalculo publico sem mudar expectativa.
- `T-02`: vitest de use case, autorizador (401/403) e controller (lista de chaves).
- `T-03`: vitest de create e update comparando com `calcProposalAmounts`, incluindo temporada dezembro-janeiro.
- `T-04`: vitest de `buildQuoteInput` e do rotulo `/ pessoa`; browser na criacao.
- `T-05`: browser na edicao.

## Fontes que fecharam a solucao

- `specs/2026-11-04-recalcular-orcamento-proposta-publica/03-design.md#Contratos e dados`
- `project-decisions.md` D-02, D-05, D-06, D-07
- `product/02-business-rules.md#Proposal`
- `security/skills/reviewing-security-sensitive-changes.md#2. Revisar autenticacao e autorizacao`
- codigo: create, update e recalculo por pessoa; `adjust-proposal-unit-price.ts`; `wall-clock-datetime.ts#isWallClockDayInRange`; `venue-price-authorizer.ts`; `quote-service-lines.ts`
