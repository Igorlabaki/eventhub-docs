# Fase 1 — Util central + P0 frontend

**Objetivo:** criar o util `wall-clock-datetime.ts` e corrigir as telas de maior impacto visível (calendário do venue e fluxo principal de proposta).

**Esforço estimado:** 0,5–1 dia  
**Dependências:** ler [03-convencao-wall-clock.md](./03-convencao-wall-clock.md)  
**Validação:** [09-checklist-testes.md](./09-checklist-testes.md) — seção Fase 1

---

## Entregas

1. Arquivo `eventhub-vista-dashboard/src/lib/wall-clock-datetime.ts` com API definida em [03-convencao-wall-clock.md](./03-convencao-wall-clock.md)
2. Testes unitários Vitest para `wallClockTime`, `wallClockDateIso`, `wallClockToCalendarDate` (`src/lib/wall-clock-datetime.test.ts`)
3. Migração dos arquivos P0 listados abaixo

---

## Tarefas por arquivo

### Criar — `src/lib/wall-clock-datetime.ts`

Implementar funções:

- `wallClockTime`
- `wallClockDateIso`
- `wallClockDateBr`
- `wallClockDateTimeBr`
- `wallClockToCalendarDate`
- `toIsoString` (interno)

Exportar tudo; adicionar JSDoc com exemplo `13:00 → 13:00`.

---

### `src/pages/VenueSchedule.tsx` — prioridade máxima

| Local | Antes | Depois |
|-------|-------|--------|
| `fillFormWithEventData` — `startHour`/`endHour` | `toTimeString().slice(0, 5)` | `wallClockTime(startDate)` |
| `fillFormWithEventData` — `startDay`/`endDay` | `toISOString().split("T")[0]` | `wallClockDateIso(startDate)` (equivalente, padronizar) |
| `events` useMemo — `start`/`end` | `new Date(event.startDate)` | `wallClockToCalendarDate(event.startDate)` |
| Detalhe do evento | `formatInTimeZone(..., "UTC", ...)` | Pode migrar para `wallClockDateBr` / `wallClockTime` (opcional na Fase 1) |

**Remover** import de `formatInTimeZone` se não restar uso após migração.

---

### `src/pages/ProposalEdit.tsx`

Substituir:

```typescript
// Antes
startHour: new Date(currentProposal.startDate).toISOString().substring(11, 16)

// Depois
startHour: wallClockTime(currentProposal.startDate)
```

Idem para `endHour`, `date` → `wallClockDateIso`.

---

### `src/pages/ProposalView.tsx`

Remover funções locais `formatDate` / `formatHour` com `toZonedTime`.

Substituir por:

```typescript
import { wallClockDateBr, wallClockTime } from "@/lib/wall-clock-datetime";
```

---

### `src/components/proposal/ProposalServicesSummary.tsx`

| Campo | Antes | Depois |
|-------|-------|--------|
| Horas | `toISOString().substring(11, 16)` | `wallClockTime` |
| Datas (pernoite e evento) | `toLocaleDateString("pt-BR")` | `wallClockDateBr` |

---

## Critérios de aceite

- [x] Util exportado e importado nos 4 arquivos acima
- [x] Nenhum `toTimeString` restante em `VenueSchedule.tsx`
- [x] Calendário do venue mostra evento no horário selecionado (TC-1.2) — lógica via `wallClockToCalendarDate`; validar manualmente no browser
- [x] Edição de proposta reabre com mesmas horas (TC-1.1) — migrado para util; validar manualmente no browser
- [x] `ProposalView` público exibe horário igual ao salvo — migrado para util; validar manualmente no browser

**Implementado em:** jul/2026. Testes unitários: `npm test` (12 passed).

---

## Não fazer nesta fase

- Backend (`transformDate`) — Fase 2
- `BudgetDetails`, `ScheduleList`, demais telas — Fase 3
- Google Calendar — Fase 4

---

## Referências

- [03-convencao-wall-clock.md](./03-convencao-wall-clock.md)
- [09-checklist-testes.md](./09-checklist-testes.md)
