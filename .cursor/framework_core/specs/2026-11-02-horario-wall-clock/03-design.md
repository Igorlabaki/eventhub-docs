# Design — Horario de evento sem fuso

## Visao geral da solucao

O banco continua `DateTime` cujo relogio UTC e o relogio de parede. `2026-07-05T11:00:00.000Z` significa 5 de julho as 11:00. Ninguem converte esses campos para o fuso do browser ou do servidor. Cada repositorio tem um util unico e os call sites de evento passam a usa-lo.

## Passada transversal

- architecture: nao. A fronteira FE/BE e o fluxo de sync permanecem; so o significado dos digitos fica explicito. Sem ADR.
- database: nao ha schema, indice nem migration. Colunas `DateTime` existentes continuam. A lib `database` nao entra na execucao.
- design: nao. Nao ha tela, estado visual nem token novo; muda o texto da hora.
- observability: nao. Nao ha servico novo. A prova e teste e a conferencia de `11:00` na tela e no texto.
- security: nao. Nao ha auth, segredo, PII nova nem webhook novo. O token Google existente nao muda.
- patterns/rules/06: nao. Sem fila, cache, retry ou idempotencia nova. O sync atual permanece.

## Persistencia

`transformDate` continua em `moment.utc` e passa a separar o dia assim:

- `YYYY-MM-DD` entra inteiro
- `dd/MM/yyyy` entra com o divisor `/`
- qualquer outro formato lanca erro e nao grava

Horas iguais ficam no mesmo dia. Hora fim menor que a hora inicio soma um dia civil em UTC. O retorno segue `Date` cujo `toISOString()` comeca com esses componentes.

O util novo `art56_server_v3/src/functions/wall-clock-datetime.ts` le com `getUTCHours`, `getUTCMinutes`, `getUTCFullYear`, `getUTCMonth` e `getUTCDate`. Funcoes: `formatWallClockTime` (`HH:mm`), `formatWallClockDateBr` (`dd/MM/yyyy`), `wallClockDateIsoFromDate` (`YYYY-MM-DD`), `formatWallClockGoogleDateTime` (`YYYY-MM-DDTHH:mm:ss`, sem `Z`).

Descartado instalar `date-fns-tz` no backend: a dependencia nao existe e o componente UTC ja e o wall-clock.

## Leitura no frontend

Call sites de evento usam `wallClockTime`, `wallClockDateIso`, `wallClockDateBr`, `wallClockDateTimeBr` e `wallClockToCalendarDate`. Nao criar outro formatter.

`formatDate` em `src/lib/utils.ts` so e usado por date event. Passa a delegar para `wallClockDateBr`. `ProposalHistory` tem outra funcao local para `createdAt` e fica como esta.

`formatarDataIso` duplicado em `VenueCard.tsx`, `VenueDashboard.tsx` e `dateEvent-form.tsx` sai. No card, nao converter com `new Date(iso).toISOString()` antes de formatar: se o valor ja for string ISO, ler a string; se for `Date`, o util existente ja chama `toISOString`.

`BudgetDetails`, `ProposalTable`, `EventTable`, `dateEvent-list` e `dateEvent-item` trocam `format` / `toLocaleDateString` pelos helpers.

`dateEvent-form.tsx` deixa de usar `getHours` / `getFullYear` locais para preencher o formulario. Usa `wallClockDateIso` e `wallClockTime`.

`ScheduleList.tsx` deixa de combinar com `setHours`. A linha da atracao mostra o dia civil da proposta via `wallClockDateBr` e as horas que ja sao string `HH:mm`.

`ContractPdfGenerator.tsx` formata data/hora de evento pelos helpers. A linha "Sao Paulo, hoje" do PDF usa a data real de geracao e nao entra na regra.

Telas P0 ja corretas nao sao reescritas.

## Textos no backend

E-mail de presenca e notificacoes de proposta e date event trocam `format(date, "dd/MM/yyyy")` e `format(date, "HH:mm")` pelos helpers UTC.

Criar e atualizar cronograma deixam de passar `proposal.startDate.toLocaleDateString('pt-BR')`. Passam `wallClockDateIsoFromDate(proposal.startDate)`.

Nos dois use cases de criar proposta, ano, dia da semana e o intervalo da sazonalidade usam o dia civil UTC (`wallClockDateIsoFromDate`), nao `getFullYear()` nem `format(startDate, "EEEE")`. A formula da taxa nao muda.

`format-date.ts` nao passa a ser usado para evento. Se algum call site de evento o usar, o call site migra para o util novo.

## Google Calendar

`google-calendar-sync-service.ts` envia `formatWallClockGoogleDateTime` sem `Z` e mantem `timeZone: "America/Sao_Paulo"`. O rotulo diz ao Google que aqueles digitos ja sao a hora de parede; o `Z` fazia o Google trata-los como instante UTC e mostrar `08:00` em SP.

Atualizar a secao de semantica em `docs/INTEGRATIONS_GOOGLE_CALENDAR.md` nesse mesmo passo. Nao mudar OAuth nem criptografia de token.

## Data so de dia

Despesa, em `controller-create-expense.ts` e `use-case-update-expense.ts`, deixa de fazer `new Date(paymentDate).toISOString()`.

Parser unico no util do backend:

- `YYYY-MM-DD` vira `YYYY-MM-DDT12:00:00.000Z`
- `dd/MM/yyyy` vira o mesmo meio-dia UTC
- outro formato falha

Meio-dia UTC, e nao meia-noite local, evita o dia anterior no Brasil. Pagamento no backend usa o mesmo parser se o create/update converter a data com `new Date`.

No frontend, `payment-form.tsx` inicializa o input com `wallClockDateIso`. `payment-list.tsx` e `payment-item.tsx` exibem com `wallClockDateBr`.

## Fora da regra

Permanecem instante real: `VenueNotifications.createdAt`, `ProposalDetails.createdAt`, `ProposalHistory`, `document-item.createdAt`, analytics de `VenueWebsite`, agrupamento mensal de venue em `getFullYear()` de "hoje".

## Invariantes

- Digito gravado igual a digito exibido para evento e para dia civil de pagamento/despesa.
- `11:00`/`11:00` nao avanca o dia.
- Fim menor que inicio avanca exatamente um dia civil.
- Auditoria nao usa helper de evento.
- Nenhuma task altera `schema.prisma`.

## Decisoes

- Usar componentes UTC como wall-clock, porque D-06 e a gravacao atual ja sao esse contrato.
- Descartado coluna `date` + `time` em texto: corrigiria o bug sem migration.
- Descartado fuso por venue: a entrada pede ausencia de fuso, nao um fuso configuravel.
- Descartado `date-fns-tz` no backend: getters UTC bastam.
- Google mantem o rotulo `America/Sao_Paulo` so para o payload externo nao deslocar os digitos.

## Riscos e mitigacoes

- Linha antiga gravada pelo caminho quebrado continua errada. Mitigacao: fora do escopo; escalar se a operacao pedir backfill.
- Sazonalidade perto da meia-noite muda de dia em relacao ao servidor. Mitigacao: esse e o resultado certo; cobrir com teste de `2026-07-05T01:00:00.000Z` caindo em 5 de julho, nao em 4.
- PDF e e-mail sao os lugares em que o horario errado vira compromisso. Entram em `T-03` e `T-04`.

## Rollout, observabilidade e rollback

Sem feature flag. Rollback e reverter o commit. Sem dashboard novo.

## Estrategia de validacao

- Unitario de `transformDate`, do util backend, do parser de dia e do payload Google.
- Unitario ja existente de `wall-clock-datetime.test.ts` no frontend, mais os call sites que deixarem de usar fuso local.
- Prova manual unica depois das tasks de tela: proposta `11:00`–`11:00` na edicao, no calendario e no detalhe do orcamento.

## Fontes da solucao

- `project/project-decisions.md#D-06`
- `product/08-data-model.md` e `product/05-functional-flows.md`
- `docs/planos/horario-wall-clock/03-convencao-wall-clock.md#Definicoes`
- `docs/planos/horario-wall-clock/05-fase-2-backend.md`
- `docs/planos/horario-wall-clock/07-fase-4-integracoes.md`
- codigo atual: `transform-date.ts`, `wall-clock-datetime.ts`, `google-calendar-sync-service.ts`, `lib/utils.ts`
