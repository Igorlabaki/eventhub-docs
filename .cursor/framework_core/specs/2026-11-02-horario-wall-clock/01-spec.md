# Spec — Horario de evento sem fuso

## Problema

O usuario informa data e hora de evento e o sistema devolve outro valor. No Brasil, `11:00` gravado como componente UTC aparece `08:00` quando a tela, o e-mail ou o calendario externo formatam no fuso local. Remontar o dia com `toLocaleDateString` ou `new Date("YYYY-MM-DD")` tambem muda o dia civil.

## Objetivos

Toda data/hora de evento entra e sai com os mesmos componentes. O par `11:00` e `11:00` permanece `11:00` e `11:00` na edicao, no calendario, no detalhe, no texto enviado e no Google Calendar.

## Fora de escopo

- `createdAt`, `updatedAt`, expiracao de sessao e intervalo de analytics do site
- escolher um fuso de negocio por venue
- migration, coluna nova ou regravacao de linhas ja salvas
- redesenho da regra de sazonalidade alem da fonte do dia civil
- refazer `VenueSchedule`, `ProposalEdit`, `ProposalView` e `ProposalServicesSummary`, ja ligados ao util wall-clock

## User stories ou cenarios principais

- O operador informa inicio e fim `11:00` numa proposta e, ao reabrir, ve `11:00` e `11:00`.
- O calendario do espaco, o detalhe do orcamento e a lista de datas extras mostram essa mesma hora.
- O e-mail de presenca e a notificacao citam a mesma data e a mesma hora.
- Uma despesa ou pagamento no dia informado continua nesse dia.

## Criterios de aceite

- `R-01`: `transformDate` com data `2026-07-05` ou `05/07/2026` e horas `11:00`/`11:00` produz inicio e fim `2026-07-05T11:00:00.000Z`.
- `R-02`: reabrir a edicao da proposta mostra data e horas `11:00`/`11:00`.
- `R-03`: calendario do espaco, detalhe do orcamento, tabelas e datas extras exibem `11:00`, nao `08:00`.
- `R-04`: e-mail de presenca e notificacao de proposta ou date event usam a data e a hora literais.
- `R-05`: criar ou atualizar cronograma usa o dia civil da proposta, sem `toLocaleDateString`.
- `R-06`: fim anterior ao inicio cai no dia civil seguinte; fim igual ao inicio permanece no mesmo dia.
- `R-07`: o payload do Google Calendar leva `2026-07-05T11:00:00` sem `Z`, com `timeZone: America/Sao_Paulo`.
- `R-08`: pagamento e despesa gravados em `2026-07-05` exibem `05/07/2026`.
- `R-09`: `createdAt` continua instante real e nao passa a usar helper de evento.
- `R-10`: dia da semana e ano usados na sazonalidade da proposta nascem dos componentes UTC do `startDate`.
- `R-11`: data que nao e `YYYY-MM-DD` nem `dd/MM/yyyy` falha com erro explicito e nao grava horario deslocado.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: nenhum caminho novo; as rotas atuais permanecem
- erros e mensagens esperadas: data invalida retorna erro de validacao, sem persistir
- observabilidade minima: sem metrica nova; a prova e teste unitario e a tela `11:00`
- concorrencia, idempotencia ou retry: o sync do Google mantem o comportamento atual de create/update
- rollout, fallback ou degradacao: correcao de leitura e gravacao para a frente; linhas antigas nao sao reescritas

## Casos de erro e borda obrigatorios

- caso: inicio e fim iguais (`11:00`/`11:00`)
  impacto: tratar como virada de dia esconde o horario ou empurra o fim
  cobertura esperada: `T-01` unitario
- caso: fim `02:00` depois de inicio `22:00`
  impacto: o fim tem de cair no dia civil seguinte
  cobertura esperada: `T-01` unitario
- caso: `new Date("2026-07-05")` ou `toLocaleDateString` no dia do evento
  impacto: o dia vira 04/07 no Brasil
  cobertura esperada: `T-02`, `T-05`, `T-07`
- caso: payload Google com `Z` e `America/Sao_Paulo` juntos
  impacto: o calendario externo mostra `08:00`
  cobertura esperada: `T-06`
- caso: `createdAt` formatado com helper de evento
  impacto: a auditoria deixa de ser o instante real
  cobertura esperada: `T-04` nao altera `ProposalHistory` nem `VenueNotifications`

## Impacto esperado

O operador passa a ver e comunicar o horario que digitou. O contrato JSON da API nao muda de forma: segue ISO com `Z`, e o `Z` continua significando componente literal, nao instante a converter.

## Areas impactadas

- `backend`: `transform-date`, cronograma, e-mail, notificacao, sazonalidade na criacao de proposta, Google Calendar, despesa
- `frontend`: telas de evento que ainda formatam no fuso local e formularios que remontam `Date`
- docs de integracao do Google Calendar na task `T-06`

## Restricoes e cuidados

- uma so familia de helpers por repositorio
- variante HTTP do backend permanece Express
- nao instalar `date-fns-tz` no backend so para formatar componente UTC
- D-06 permanece a decisao; esta spec nao cria ADR

## Dependencias

- `eventhub-vista-dashboard/src/lib/wall-clock-datetime.ts` e o teste existente
- `art56_server_v3/src/functions/transform-date.ts` ja grava com `moment.utc`
- `docs/planos/horario-wall-clock/` como convencao de origem, nao como fila de execucao

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> fase 1 ja coberta em `ProposalEdit`; `T-04` nao regride -> manual
- `R-03` -> `T-04`, `T-05` -> unitario do util + manual da tela
- `R-04` -> `T-03` -> unitario
- `R-05` -> `T-02` -> unitario
- `R-06` -> `T-01` -> unitario
- `R-07` -> `T-06` -> unitario
- `R-08` -> `T-07`, `T-08` -> unitario + manual
- `R-09` -> todas -> inspecao dos arquivos de auditoria
- `R-10` -> `T-03` -> unitario
- `R-11` -> `T-01` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Base documental

- `project/project-decisions.md#D-06`
- `product/05-functional-flows.md` (agenda preserva wall-clock)
- `product/08-data-model.md` (sem politica global unica; agenda e wall-clock)
- `docs/planos/horario-wall-clock/03-convencao-wall-clock.md`
- `docs/planos/horario-wall-clock/05-fase-2-backend.md`
- `docs/planos/horario-wall-clock/07-fase-4-integracoes.md`
- `framework-libs/node/index.md#Implementacao backend Node` (variante Express em `active-libs.md`)
- `framework-libs/react/index.md#Implementacao frontend React`
- `framework-libs/database/index.md#Leitura minima por tipo de tarefa` (nao ha schema novo nem migration)

## Operacao

- tipo: `spec`
- proxima task: nenhuma (`T-01` a `T-08` executadas)
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
