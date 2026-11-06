# Tasks — Horario de evento sem fuso

## Ordem macro

1. `T-01` trava o contrato de gravacao no backend.
2. Depois dela, em paralelo: `T-02`, `T-03`, `T-06`, `T-07`.
3. Em paralelo desde o inicio, porque so leem ISO ja existente: `T-04`, `T-05`, `T-08`.
4. Cada task mexe num repositorio so. Nao ha task mista.

## Tasks

### T-01 - Parser wall-clock e util UTC no backend

- objetivo: gravar `11:00`/`11:00` como `2026-07-05T11:00:00.000Z` nos dois formatos de data e expor a leitura UTC.
- cobre requisitos: `R-01`, `R-06`, `R-11`
- depende de: nenhuma
- pode rodar em paralelo com: `T-04`, `T-05`, `T-08`
- reusa: `transform-date.ts` e `moment.utc`
- prompt recomendado: normal
- estrategia de teste: unitario do parser e do util, sem banco
- cenarios obrigatorios:
  - `2026-07-05` + `11:00`/`11:00` gera os dois instantes no mesmo dia
  - `05/07/2026` + `11:00`/`11:00` gera o mesmo ISO
  - `22:00`/`02:00` joga o fim para o dia seguinte
  - string fora dos dois formatos lanca erro
  - `formatWallClockTime` de `2026-07-05T11:00:00.000Z` devolve `11:00`
- definition of done:
  - util criado com as quatro funcoes de `03-design.md#Persistencia`
  - `transformDate` usa o parser dual-format
  - testes novos passam em `npm test -- --run`
  - `schema.prisma` intocado
  - sem promover topic; D-06 ja cobre a decisao

#### Context Pack

- frente principal: persistencia de data/hora de evento
- superficie sensivel: nao
- risco principal: hora igual virar o dia seguinte, ou ISO do input ser lido como `dd/MM/yyyy`
- repos tocados: `backend`
- fora de escopo desta task: cronograma, e-mail, Google, despesa, frontend
- prova minima desta task: teste com `11:00`/`11:00` nos dois formatos de data
- criterio de escalada: parar se a correcao parecer exigir migration
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Persistencia`
- libs obrigatorias: `node` (`framework-libs/node/index.md#Implementacao backend Node`; variante Express)
- documentos obrigatorios:
  - `03-design.md#Persistencia`
  - `03-design.md#Invariantes`
  - `docs/planos/horario-wall-clock/05-fase-2-backend.md#2. Corrigir transform-date.ts`
- caminhos candidatos: `art56_server_v3/src/functions/transform-date.ts`, `art56_server_v3/src/functions/wall-clock-datetime.ts`
- palavras-chave ou simbolos de busca: `transformDate`, `moment.utc`, `parseDateParts`
- testes provaveis: novo teste ao lado de `transform-date.ts`
- nao ler por padrao: `security`, frontend, `01-spec.md`, `04-tasks.md` inteiro

### T-02 - Dia civil do cronograma

- objetivo: criar e atualizar cronograma no dia civil da proposta, sem fuso do servidor.
- cobre requisitos: `R-05`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`, `T-06`, `T-07`
- reusa: `wallClockDateIsoFromDate` e `transformDate`
- prompt recomendado: smart
- estrategia de teste: unitario ou teste do use case com `startDate` `2026-07-05T01:00:00.000Z`, esperando dia `2026-07-05`
- cenarios obrigatorios:
  - create nao chama `toLocaleDateString`
  - update nao chama `toLocaleDateString`
  - hora da atracao `11:00` grava `T11:00:00.000Z` nesse dia
- definition of done:
  - os dois use cases de schedule usam `wallClockDateIsoFromDate`
  - teste cobre o dia `01:00Z` sem cair em 04/07
  - sem mudanca de schema

#### Context Pack

- frente principal: cronograma da proposta
- superficie sensivel: nao
- risco principal: `toLocaleDateString` mudar o dia no Brasil
- repos tocados: `backend`
- fora de escopo desta task: texto de e-mail, tela `ScheduleList`, Google
- prova minima desta task: dia gravado igual a `wallClockDateIsoFromDate(proposal.startDate)`
- criterio de escalada: parar se o use case precisar regravar cronogramas antigos
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Textos no backend`
- libs obrigatorias: `node` (`framework-libs/node/index.md#Implementacao backend Node`)
- documentos obrigatorios:
  - `03-design.md#Textos no backend`
  - `docs/planos/horario-wall-clock/05-fase-2-backend.md#3. Schedule use-cases`
- caminhos candidatos: `art56_server_v3/src/use-cases/schedule/create-schedule/use-case-create-schedule.ts`, `art56_server_v3/src/use-cases/schedule/update-schedule/use-case-update-schedule.ts`
- palavras-chave ou simbolos de busca: `toLocaleDateString`, `transformDate`
- testes provaveis: teste dos dois use cases ou do trecho que monta a data
- nao ler por padrao: `security`, frontend, `01-spec.md`

### T-03 - E-mail, notificacao e dia da sazonalidade

- objetivo: textos de evento e o dia da taxa sazonal usarem o dia e a hora literais.
- cobre requisitos: `R-04`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`, `T-06`, `T-07`
- reusa: `formatWallClockTime`, `formatWallClockDateBr`, `wallClockDateIsoFromDate`
- prompt recomendado: normal
- estrategia de teste: unitario com `Date` `2026-07-05T11:00:00.000Z` e outro as `01:00Z` para o dia da semana
- cenarios obrigatorios:
  - e-mail de presenca mostra `11:00` e `05/07/2026`
  - notificacao de date event e de proposta usa `formatWallClockDateBr`
  - `2026-07-05T01:00:00.000Z` cai no dia 5, nao no dia 4, na sazonalidade
  - a formula da taxa nao e reescrita
- definition of done:
  - e-mail e os use cases de notificacao listados no plano da fase 2 usam o util
  - `getFullYear()` e `format(..., "EEEE")` saem dos dois creates de proposta quando o assunto e o dia do evento
  - testes passam
  - sem promover ADR

#### Context Pack

- frente principal: comunicacao e preco por dia do evento
- superficie sensivel: nao
- risco principal: e-mail ou taxa usar o dia do servidor
- repos tocados: `backend`
- fora de escopo desta task: template visual de e-mail, regra nova de fee, Google
- prova minima desta task: `11:00` no corpo do e-mail e dia 5 para `T01:00:00.000Z`
- criterio de escalada: parar se a sazonalidade exigir modelo novo de fee
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Textos no backend`
- libs obrigatorias: `node` (`framework-libs/node/index.md#Implementacao backend Node`)
- documentos obrigatorios:
  - `03-design.md#Textos no backend`
  - `docs/planos/horario-wall-clock/05-fase-2-backend.md#4. E-mail de confirmacao de presenca`
  - `docs/planos/horario-wall-clock/05-fase-2-backend.md#5. Notificacoes in-app`
- caminhos candidatos: `use-case-send-attendence-confirmation-to-email.ts`, `use-case-create-proposal-per-person.ts`, `use-case-create-proposal-per-day.ts`, use cases em `src/use-cases/data-event/`
- palavras-chave ou simbolos de busca: `format(`, `EEEE`, `getFullYear`, `notificationContent`
- testes provaveis: teste do formatador no e-mail e um caso de dia da semana
- nao ler por padrao: `security`, `schema.prisma`, frontend

### T-04 - Telas que ainda formatam evento no fuso local

- objetivo: listas, detalhe, card e PDF de evento mostrarem `11:00` e `05/07/2026`.
- cobre requisitos: `R-03`, `R-09`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-05`, `T-08`
- reusa: `src/lib/wall-clock-datetime.ts`
- prompt recomendado: normal
- estrategia de teste: `wall-clock-datetime.test.ts` segue verde; busca estatica sem `format(..., "HH:mm")` nos arquivos desta task
- cenarios obrigatorios:
  - `BudgetDetails` mostra `11:00` para `T11:00:00.000Z`
  - `formatDate` de `utils.ts` devolve `05/07/2026` para essa ISO
  - card e dashboard nao passam `new Date(iso).toISOString()` so para formatar
  - `ProposalHistory` e `VenueNotifications` continuam com `createdAt` local
- definition of done:
  - arquivos da secao `03-design.md#Leitura no frontend` desta leva trocados
  - duplicata `formatarDataIso` removida de `VenueCard` e `VenueDashboard`
  - `npm test` do frontend verde no util
  - PDF de evento usa o helper; a data "hoje" do documento nao

#### Context Pack

- frente principal: exibicao de evento no dashboard
- superficie sensivel: nao
- risco principal: trocar formatter de `createdAt` junto com o de evento
- repos tocados: `frontend`
- fora de escopo desta task: `dateEvent-form`, `ScheduleList`, pagamento, telas P0 ja migradas
- prova minima desta task: `BudgetDetails` e `formatDate` renderizam `11:00` / `05/07/2026` a partir de `2026-07-05T11:00:00.000Z`
- criterio de escalada: parar se a tela exigir componente visual novo
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Leitura no frontend`
- libs obrigatorias: `react` (`framework-libs/react/index.md#Implementacao frontend React`)
- documentos obrigatorios:
  - `03-design.md#Leitura no frontend`
  - `03-design.md#Fora da regra`
  - `eventhub-vista-dashboard/src/lib/wall-clock-datetime.ts`
- caminhos candidatos: `BudgetDetails.tsx`, `ProposalTable.tsx`, `EventTable.tsx`, `dateEvent-list.tsx`, `dateEvent-item.tsx`, `VenueCard.tsx`, `VenueDashboard.tsx`, `ContractPdfGenerator.tsx`, `src/lib/utils.ts`
- palavras-chave ou simbolos de busca: `formatDate`, `formatarDataIso`, `toLocaleDateString`, `HH:mm`
- testes provaveis: `src/lib/wall-clock-datetime.test.ts`
- nao ler por padrao: `security`, backend, `01-spec.md`

### T-05 - Formularios que remontam data e hora

- objetivo: preencher date event e a lista de atracoes com os componentes literais, sem `getHours` nem `setHours`.
- cobre requisitos: `R-03`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-04`, `T-08`
- reusa: `wallClockDateIso`, `wallClockTime`, `wallClockDateBr`
- prompt recomendado: normal
- estrategia de teste: unitario do util mais conferencia de que o form recebe `11:00` quando a ISO e `T11:00:00.000Z`
- cenarios obrigatorios:
  - tipo evento no `dateEvent-form` preenche dia e hora iguais aos da proposta
  - `ScheduleList` mostra `11:00` da string da atracao e o dia civil da proposta
  - fim igual ao inicio nao desloca a hora exibida
- definition of done:
  - `getHours`/`setHours` saem desses dois arquivos para evento
  - `formatarDataIso` local do form sai
  - teste do util continua passando

#### Context Pack

- frente principal: formulario de data extra e lista de atracoes
- superficie sensivel: nao
- risco principal: `setHours` aplicar `11:00` em cima de um `Date` ja deslocado
- repos tocados: `frontend`
- fora de escopo desta task: gravacao do cronograma no backend (`T-02`), tabelas de `T-04`
- prova minima desta task: ISO `T11:00:00.000Z` preenche input `11:00` e a lista mostra `11:00`
- criterio de escalada: parar se o formulario precisar de outro modelo de estado alem de React Query/Zustand
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Leitura no frontend`
- libs obrigatorias: `react` (`framework-libs/react/index.md#Implementacao frontend React`)
- documentos obrigatorios:
  - `03-design.md#Leitura no frontend`
  - `eventhub-vista-dashboard/src/lib/wall-clock-datetime.ts`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/dateEvent/dateEvent-form.tsx`, `eventhub-vista-dashboard/src/pages/ScheduleList.tsx`
- palavras-chave ou simbolos de busca: `getHours`, `setHours`, `formatarDataIso`, `combineDateAndTime`
- testes provaveis: `src/lib/wall-clock-datetime.test.ts`
- nao ler por padrao: `security`, backend, `BudgetDetails.tsx`

### T-06 - Google Calendar sem segundo deslocamento

- objetivo: o evento das `11:00` seguir `11:00` no Google, com os digitos sem `Z`.
- cobre requisitos: `R-07`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`, `T-03`, `T-07`
- reusa: `formatWallClockGoogleDateTime`
- prompt recomendado: smart
- estrategia de teste: unitario do payload a partir de `2026-07-05T11:00:00.000Z`
- cenarios obrigatorios:
  - `dateTime` igual a `2026-07-05T11:00:00`
  - ausencia de sufixo `Z`
  - `timeZone` permanece `America/Sao_Paulo`
- definition of done:
  - sync create/update usa o helper
  - `docs/INTEGRATIONS_GOOGLE_CALENDAR.md` ganha a semantica de horario
  - OAuth e token criptografado intocados
  - sem ADR novo

#### Context Pack

- frente principal: sync DateEvent para Google Calendar
- superficie sensivel: nao
- risco principal: mandar instante UTC com rotulo de Sao Paulo e exibir `08:00`
- repos tocados: `backend`
- fora de escopo desta task: fluxo OAuth, escolha de calendario, fuso por venue
- prova minima desta task: payload de teste com `11:00` sem `Z`
- criterio de escalada: parar se a API do Google exigir o `Z` para o tipo de evento atual
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Google Calendar`
- libs obrigatorias: `node` (`framework-libs/node/index.md#Implementacao backend Node`)
- documentos obrigatorios:
  - `03-design.md#Google Calendar`
  - `docs/planos/horario-wall-clock/07-fase-4-integracoes.md#1. Google Calendar sync`
- caminhos candidatos: `art56_server_v3/src/services/google-calendar-sync-service.ts`, `docs/INTEGRATIONS_GOOGLE_CALENDAR.md`
- palavras-chave ou simbolos de busca: `toISOString`, `America/Sao_Paulo`, `dateTime`
- testes provaveis: teste do payload no sync service
- nao ler por padrao: `security` alem do que o arquivo de sync ja importa, frontend, schema

### T-07 - Dia civil de despesa e pagamento no backend

- objetivo: a data informada de despesa e pagamento permanecer o mesmo dia civil.
- cobre requisitos: `R-08`, `R-11`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`, `T-03`, `T-06`, `T-08`
- reusa: parser de dia do util backend
- prompt recomendado: normal
- estrategia de teste: unitario do parser `2026-07-05` -> `2026-07-05T12:00:00.000Z`
- cenarios obrigatorios:
  - `YYYY-MM-DD` grava meio-dia UTC desse dia
  - `dd/MM/yyyy` grava o mesmo instante
  - formato invalido falha
  - create e update de despesa nao usam `new Date(paymentDate).toISOString()`
- definition of done:
  - parser unico usado na despesa
  - pagamento alinhado se o controller converter com `new Date`
  - teste do meio-dia UTC passa
  - sem migration

#### Context Pack

- frente principal: data de pagamento e despesa
- superficie sensivel: nao
- risco principal: meia-noite local gravar o dia anterior
- repos tocados: `backend`
- fora de escopo desta task: tela de pagamento (`T-08`), valor monetario, comprovante alem da data no titulo se ela vier do mesmo parser
- prova minima desta task: `2026-07-05` persiste `T12:00:00.000Z`
- criterio de escalada: parar se o campo deixar de ser `DateTime` e pedir coluna `date`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Data so de dia`
- libs obrigatorias: `node` (`framework-libs/node/index.md#Implementacao backend Node`)
- documentos obrigatorios:
  - `03-design.md#Data so de dia`
  - `docs/planos/horario-wall-clock/07-fase-4-integracoes.md#2. Despesas (Expense)`
- caminhos candidatos: `controller-create-expense.ts`, `use-case-update-expense.ts`, controllers de payment que atribuem `paymentDate`
- palavras-chave ou simbolos de busca: `paymentDate`, `toISOString`, `new Date`
- testes provaveis: teste do parser de dia
- nao ler por padrao: `security`, frontend, schema

### T-08 - Dia civil de pagamento na tela

- objetivo: o input e a lista de pagamento mostrarem o dia gravado, sem `toLocaleDateString`.
- cobre requisitos: `R-08`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-04`, `T-05`, `T-07`
- reusa: `wallClockDateIso`, `wallClockDateBr`
- prompt recomendado: smart
- estrategia de teste: helper com `2026-07-05T12:00:00.000Z` devolve `2026-07-05` e `05/07/2026`
- cenarios obrigatorios:
  - form carrega o input `type="date"` com `2026-07-05`
  - lista e item mostram `05/07/2026`
  - `createdAt` de documento nao e alterado
- definition of done:
  - `payment-form.tsx`, `payment-list.tsx` e `payment-item.tsx` usam o util
  - teste do util verde
  - nenhuma tela de auditoria incluída

#### Context Pack

- frente principal: tela de pagamento
- superficie sensivel: nao
- risco principal: lista mostrar 04/07 para um pagamento do dia 05
- repos tocados: `frontend`
- fora de escopo desta task: parser do backend (`T-07`), despesa na UI se nao repetir o mesmo `toLocaleDateString` de pagamento
- prova minima desta task: `T12:00:00.000Z` vira `05/07/2026` na lista e `2026-07-05` no input
- criterio de escalada: parar se o form de pagamento exigir fluxo de comprovante ou permissao nova
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Data so de dia`
- libs obrigatorias: `react` (`framework-libs/react/index.md#Implementacao frontend React`)
- documentos obrigatorios:
  - `03-design.md#Data so de dia`
  - `eventhub-vista-dashboard/src/lib/wall-clock-datetime.ts`
- caminhos candidatos: `payment-form.tsx`, `payment-list.tsx`, `payment-item.tsx`
- palavras-chave ou simbolos de busca: `paymentDate`, `toLocaleDateString`, `wallClockDateIso`
- testes provaveis: `src/lib/wall-clock-datetime.test.ts`
- nao ler por padrao: `security`, backend, `document-item.tsx`
