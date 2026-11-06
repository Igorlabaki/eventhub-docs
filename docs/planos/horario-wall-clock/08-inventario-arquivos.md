# Inventário de arquivos — horário wall-clock

Tabela mestre para acompanhar migração. Atualizar status ao concluir cada fase.

**Legenda estratégia:** A = wall-clock correto | B = fuso local (bug) | C = calendário/local mix | — = N/A  
**Legenda escopo:** EVENTO = EventDateTime | DATE-ONLY = só dia | TIMESTAMP = auditoria | FORA = não alterar

---

## Comandos de auditoria

Executar após cada fase:

```bash
# Frontend — candidatos a correção
rg "toTimeString|toLocaleDateString|format\([^)]*HH:mm|setHours\(|getHours\(" eventhub-vista-dashboard/src

# Backend — formatação de evento
rg "format\([^)]*HH:mm|toLocaleDateString" art56_server_v3/src

# Duplicatas formatarDataIso
rg "formatarDataIso|function formatDate" eventhub-vista-dashboard/src
```

Classificar cada match: **corrigir** (EVENTO) vs **ignorar** (TIMESTAMP).

---

## Backend

| Camada | Arquivo | Campo / uso | Estratégia | Escopo | Ação | Fase | Status |
|--------|---------|-------------|------------|--------|------|------|--------|
| BE | `src/functions/transform-date.ts` | startDate, endDate | A (save) | EVENTO | Parser dual-format | 2 | [ ] |
| BE | `src/functions/wall-clock-datetime.ts` | — | — | EVENTO | Criar util | 2 | [ ] |
| BE | `src/use-cases/schedule/create-schedule/use-case-create-schedule.ts` | data da proposta | B | EVENTO | `wallClockDateIsoFromDate` | 2 | [ ] |
| BE | `src/use-cases/schedule/update-schedule/use-case-update-schedule.ts` | data da proposta | B | EVENTO | Idem | 2 | [ ] |
| BE | `src/use-cases/email/send-attendence-confirmation-to-email/use-case-send-attendence-confirmation-to-email.ts` | start/end time | B | EVENTO | `formatWallClockTime` | 2 | [ ] |
| BE | `src/use-cases/data-event/create-data-event/use-case-create-date-event.ts` | notification text | B | EVENTO | `formatWallClockDateBr` | 2 | [ ] |
| BE | `src/use-cases/data-event/create-overnight-data-event/use-case-create-overnigth-date-event.ts` | notification text | B | EVENTO | Idem | 2 | [ ] |
| BE | `src/use-cases/data-event/update-same-day-event/use-case-update-same-day-date-event.ts` | notification text | B | EVENTO | Idem | 2 | [ ] |
| BE | `src/use-cases/data-event/update-overnigth-day-event/use-case-update-overnigth-date-event.ts` | notification text | B | EVENTO | Idem | 2 | [ ] |
| BE | `src/use-cases/proposal/create-proposal-per-person/use-case-create-proposal-per-person.ts` | notifications | B | EVENTO | Idem | 2 | [ ] |
| BE | `src/use-cases/proposal/create-proposal-per-day/use-case-create-proposal-per-day.ts` | notifications | B | EVENTO | Idem | 2 | [ ] |
| BE | `src/services/google-calendar-sync-service.ts` | sync payload | C | EVENTO | dateTime sem Z | 4 | [ ] |
| BE | `src/use-cases/expense/create-expense/controller-create-expense.ts` | paymentDate | B | DATE-ONLY | parse date-only | 4 | [ ] |
| BE | `src/use-cases/expense/update-expense/use-case-update-expense.ts` | paymentDate | B | DATE-ONLY | Idem | 4 | [ ] |
| BE | `src/functions/format-date.ts` | formatação genérica | B | — | Revisar uso; não usar para evento | 2 | [ ] |
| BE | `src/use-cases/venue/get-analysis-by-month-venue/use-case-get-analysis-by-month-venue.ts` | month label | B | — | Baixa prioridade (agrupamento) | — | [ ] |

---

## Frontend — P0 (Fase 1)

| Camada | Arquivo | Campo / uso | Estratégia | Escopo | Ação | Fase | Status |
|--------|---------|-------------|------------|--------|------|------|--------|
| FE | `src/lib/wall-clock-datetime.ts` | — | — | EVENTO | Criar util | 1 | [x] jul/2026 |
| FE | `src/pages/VenueSchedule.tsx` | form + calendar | A | EVENTO | `wallClockTime`, `wallClockToCalendarDate` | 1 | [x] jul/2026 |
| FE | `src/pages/ProposalEdit.tsx` | startHour, endHour, date | A | EVENTO | Migrar para util | 1 | [x] jul/2026 |
| FE | `src/pages/ProposalView.tsx` | formatDate, formatHour | A | EVENTO | Migrar para util | 1 | [x] jul/2026 |
| FE | `src/components/proposal/ProposalServicesSummary.tsx` | hora + data | A | EVENTO | Util completo | 1 | [x] jul/2026 |

---

## Frontend — Fase 3

| Camada | Arquivo | Campo / uso | Estratégia | Escopo | Ação | Fase | Status |
|--------|---------|-------------|------------|--------|------|------|--------|
| FE | `src/components/BudgetDetails.tsx` | HH:mm | B | EVENTO | `wallClockTime` | 3 | [ ] |
| FE | `src/components/proposal/ProposalTable.tsx` | startDate | B | EVENTO | `wallClockDateBr` | 3 | [ ] |
| FE | `src/components/events/EventTable.tsx` | startDate | B | EVENTO | Idem | 3 | [ ] |
| FE | `src/components/dateEvent/dateEvent-form.tsx` | form defaults | A | EVENTO | Unificar util | 3 | [ ] |
| FE | `src/components/dateEvent/dateEvent-list.tsx` | startDate | B | EVENTO | `wallClockDateBr` | 3 | [ ] |
| FE | `src/components/dateEvent/dateEvent-item.tsx` | start/end | B | EVENTO | Idem | 3 | [ ] |
| FE | `src/pages/ScheduleList.tsx` | combine + display | A/B mix | EVENTO | Reescrever combine | 3 | [ ] |
| FE | `src/components/schedule/schedule-form.tsx` | extractTime | A | EVENTO | `wallClockTime` | 3 | [ ] |
| FE | `src/components/schedule/schedule-list.tsx` | formatTime | A | EVENTO | Unificar | 3 | [ ] |
| FE | `src/lib/utils.ts` | formatDate | B | EVENTO | Deprecar / redirect | 3 | [ ] |
| FE | `src/components/VenueCard.tsx` | formatarDataIso | A | EVENTO | Remover duplicata | 3 | [ ] |
| FE | `src/pages/VenueDashboard.tsx` | formatarDataIso | A | EVENTO | Idem | 3 | [ ] |
| FE | `src/components/proposal/forms/ContractPdfGenerator.tsx` | placeholders ISO | A | EVENTO | Usar util | 3 | [ ] |
| FE | `src/components/payment/payment-form.tsx` | paymentDate input | B | DATE-ONLY | `wallClockDateIso` | 4 | [ ] |
| FE | `src/components/payment/payment-list.tsx` | paymentDate display | B | DATE-ONLY | `wallClockDateBr` | 4 | [ ] |
| FE | `src/components/payment/payment-item.tsx` | paymentDate display | B | DATE-ONLY | Idem | 4 | [ ] |

---

## Frontend — já correto ou parcial (migrar para util na Fase 1/3)

| Arquivo | Observação | Status |
|---------|------------|--------|
| `ProposalEdit.tsx` | ISO substring — padronizar | [ ] |
| `dateEvent-form.tsx` | split T — padronizar | [ ] |
| `schedule-list.tsx` | regex T — padronizar | [ ] |
| `ContractPdfGenerator.tsx` | getUTC* — padronizar | [ ] |
| `VenueSchedule.tsx` (detalhe) | formatInTimeZone UTC — padronizar | [ ] |

---

## Explicitamente fora do escopo

| Arquivo | Motivo |
|---------|--------|
| `VenueNotifications.tsx` | `createdAt` — TIMESTAMP |
| `ProposalDetails.tsx` | `createdAt` — TIMESTAMP |
| `document-item.tsx` | `createdAt` — TIMESTAMP |
| `VenueWebsite.tsx` | analytics range — instant real |
| `VenueGoals.tsx`, `Login.tsx`, etc. | ícone Calendar apenas — sem EventDateTime |

---

## Contagem de progresso

| Fase | Total itens | Concluídos |
|------|-------------|------------|
| 1 | 5 | 0 |
| 2 | 12 | 0 |
| 3 | 14 | 0 |
| 4 | 5 | 0 |

Atualizar esta tabela ao fechar cada fase.

---

## Referências

- [06-fase-3-frontend-completo.md](./06-fase-3-frontend-completo.md)
- [03-convencao-wall-clock.md](./03-convencao-wall-clock.md)
