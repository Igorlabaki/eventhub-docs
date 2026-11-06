# Design — Limite de horas do servico

## Visao geral da solucao

O teto entra em dois pontos que ja decidem se as horas escolhidas podem ser gravadas: `assertChosenServiceHours` na criacao e `resolvePublicHours` no ajuste publico. Os dois lancam a mesma frase quando o inteiro valido e maior que `calcEventDuration`. `quantityFor` nao muda, para o recalculo continuar gravando a quantidade antiga.

No frontend, um helper unico devolve a frase ou a frase de inteiro. O `onChange` do campo chama esse helper. Confirmar e enviar usam o mesmo helper. O modal recebe a duracao calculada com `eventDurationHours`, nao o `Math.round` que a pagina usa so para o rotulo.

## Passada transversal

- architecture: nao. A fronteira continua formulario publico e API publica; so a regra de aceitacao aperta.
- database: nao. Sem coluna, indice ou migration.
- design: sim. O campo que ja existe ganha erro imediato, sem componente novo.
- observability: nao. Sem metrica nova; a recusa continua resposta HTTP.
- security: sim. A rota publica altera o valor do orcamento; a checagem mora no servidor.
- patterns/rules/06: nao. Sem retry, fila, cache ou idempotencia nova.

## Componentes e modulos impactados

- `art56_server_v3/src/functions/quote-service-lines.ts`: frase e checagem dentro de `assertChosenServiceHours`
- `art56_server_v3/src/use-cases/proposal/create-proposal-per-person/` e `create-proposal-per-day/`: passam a duracao para o assert
- `art56_server_v3/src/use-cases/proposal/update-public-proposal-services/`: a checagem em `resolvePublicHours`
- `eventhub-vista-dashboard/src/lib/event-duration.ts`: helper da frase e do erro do campo
- `ClientPerPersonProposalForm.tsx`, `ClientPerDayProposalForm.tsx` e `UpdateProposalServicesDialog.tsx`: erro no `onChange` e no envio
- `ProposalView.tsx`: entrega ao modal a duracao de `eventDurationHours`
- `product/02-business-rules.md#Proposal` e `product/03-user-profiles.md#Cliente proponente`

## Reuso previsto

- `calcEventDuration` no servidor e `eventDurationHours` mais `wallClockDate` no cliente
- `SERVICE_HOURS_MESSAGE` permanece para inteiro invalido
- o paragrafo `role="alert"` que ja fica embaixo do campo
- Zod permanece em inteiro de 0 a 8760; o teto da duracao nao cabe no schema porque a duracao so existe depois das datas

## Contratos e dados

Frase, duplicada nos dois repositorios como ja acontece com a frase de inteiro:

- N igual a 1: `O serviço não pode ter mais horas do que o evento (1 hora).`
- qualquer outro N: `O serviço não pode ter mais horas do que o evento (N horas).`

`assertChosenServiceHours` passa a receber `eventHours`. Para cada servico `PER_HOUR` com inteiro presente, se esse inteiro for maior que `eventHours`, lanca `HttpBadRequestError` com a frase. Nao altera a checagem de ausencia.

`resolvePublicHours` so compara depois das checagens que ja devolvem a frase de inteiro. `candidate > eventHours` lanca a frase nova.

`quantityFor` continua aceitando o inteiro do mapa mesmo acima da duracao. O recalculo publico segue chamando `quoteServiceLines` com a quantidade gravada.

No cliente, `serviceHourFieldError(raw, eventHours: number | null)`:

- vazio: sem erro ao vivo
- nao e inteiro de 1 a 8760: `SERVICE_HOURS_MESSAGE`
- `eventHours` numerico e inteiro maior que ele: a frase nova
- caso contrario: sem erro

`chosenServiceHours` usa esse helper. `eventHours` null nao aplica o teto.

Duracao por superficie:

- por pessoa: so quando inicio e fim existem e o fim e posterior no mesmo dia; senao `eventHours` fica null
- por dia: `eventDurationHours(wallClockDate(startDay, checkIn || "14:00"), wallClockDate(endDay, checkOut || "12:00"))`
- modal: `eventDurationHours(new Date(startDate), new Date(endDate))`

O `onChange` grava o texto e chama o helper naquele id. Ao abrir o modal, o valor semeado tambem passa pelo helper.

## Falhas, casos de borda e invariantes

- igual a duracao grava; uma hora acima nao grava
- 0 com evento de duracao 0 continua valido no painel; inteiro positivo com duracao 0 cai na frase nova
- zero, fracao, negativo, ausencia e acima de 8760 continuam na frase de inteiro
- quantidade gravada acima de uma duracao nova sobrevive ao recalculo
- fim anterior ao inicio no formulario por pessoa nao dispara a frase de duracao
- orcamento aprovado ou pago nao chega na checagem de horas

## Decisoes arquiteturais importantes

- O teto fica fora de `quantityFor`. Colocar la rejeitaria o recalculo que a spec de horas escolhidas mandou conservar.
- A frase e constante duplicada, sem pacote compartilhado. Alternativa de um unico modulo entre repos foi descartada: os repos nao compartilham codigo.
- O rotulo arredondado da pagina publica nao e o teto. Alternativa de reusar `durationHours` do `ProposalView` foi descartada porque `Math.round` pode divergir de `calcEventDuration`.

## Riscos e mitigacoes

- Criacao esquecer de passar `eventHours` e o assert nao limitar. A prova de `T-01` cobre horas acima da duracao na criacao por pessoa e por dia.
- O formulario por dia medir outro intervalo que a API. A duracao do cliente usa o mesmo check-in, check-out e fallback que o envio ja usa.

## Rollout, observabilidade e rollback

Sem migration e sem flag. Rollback e reverter a checagem e o helper. Orcamento ja salvo nao precisa de script.

## Estrategia de validacao

- `T-01`: unitario do assert, de `resolvePublicHours` e de `quantityFor` com mapa acima da duracao
- `T-02`: unitario do helper e, no browser, digitar acima da duracao no modal e num formulario de criacao, ver a frase antes de confirmar, voltar para a duracao e seguir

## Docs determinantes

- `product/02-business-rules.md#Proposal`: a quantidade permanece no recalculo; esta feature so impede a digitacao nova
- `project/project-decisions.md#D-05`, `#D-06`, `#D-07`
- `framework-libs/design/index.md#Formularios e fluxos de entrada`
- `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
