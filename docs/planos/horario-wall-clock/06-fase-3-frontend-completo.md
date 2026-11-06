# Fase 3 — Frontend completo

**Objetivo:** varredura de todos os arquivos frontend restantes que leem ou exibem EventDateTime com fuso local.

**Esforço estimado:** ~1 dia  
**Dependências:** Fase 1 (util central criado)  
**Validação:** [09-checklist-testes.md](./09-checklist-testes.md) — seção Fase 3

---

## Checklist por arquivo

Marque `[x]` ao concluir cada migração.

### Componentes de proposta / orçamento

| Status | Arquivo | Mudança |
|--------|---------|---------|
| [ ] | `src/components/BudgetDetails.tsx` | `format(..., "HH:mm")` → `wallClockTime`; data → `wallClockDateBr` |
| [ ] | `src/components/proposal/ProposalTable.tsx` | `format(proposal.startDate, "dd/MM/yyyy")` → `wallClockDateBr` |
| [ ] | `src/components/events/EventTable.tsx` | `format(new Date(event.startDate), ...)` → `wallClockDateBr` |

### DateEvent

| Status | Arquivo | Mudança |
|--------|---------|---------|
| [ ] | `src/components/dateEvent/dateEvent-form.tsx` | Remover `formatarDataIso` local; usar util; manter `split('T')` nos defaultValues ou migrar para `wallClockTime`/`wallClockDateIso` |
| [ ] | `src/components/dateEvent/dateEvent-list.tsx` | `formatDate` de `lib/utils` → `wallClockDateBr` (ou `wallClockDateTimeBr` se exibir hora) |
| [ ] | `src/components/dateEvent/dateEvent-item.tsx` | Idem — hoje `formatDate` só mostra dia local errado |

### Schedule (cronograma)

| Status | Arquivo | Mudança |
|--------|---------|---------|
| [ ] | `src/pages/ScheduleList.tsx` | `getHourString`/`extractHour` → `wallClockTime`; reescrever `combineDateAndTime` sem `setHours` |
| [ ] | `src/components/schedule/schedule-form.tsx` | `extractTime` → `wallClockTime` |
| [ ] | `src/components/schedule/schedule-list.tsx` | `formatTime` → `wallClockTime` (já similar; unificar) |

**`combineDateAndTime` sugerido:**

```typescript
function combineWallClockDateTime(proposalStart: string | Date, time: string): Date | null {
  if (!proposalStart || !/^\d{2}:\d{2}$/.test(time)) return null;
  const dateIso = wallClockDateIso(proposalStart);
  return wallClockToCalendarDate(`${dateIso}T${time}:00.000Z`);
}
```

Exibição: `wallClockDateTimeBr` ou `${wallClockDateBr} ${wallClockTime}`.

### Utilitários e duplicatas

| Status | Arquivo | Mudança |
|--------|---------|---------|
| [ ] | `src/lib/utils.ts` | Deprecar `formatDate` para eventos; adicionar comentário apontando para `wall-clock-datetime` |
| [ ] | `src/components/VenueCard.tsx` | Remover `formatarDataIso`; usar `wallClockDateTimeBr` |
| [ ] | `src/pages/VenueDashboard.tsx` | Idem |

### PDF

| Status | Arquivo | Mudança |
|--------|---------|---------|
| [ ] | `src/components/proposal/forms/ContractPdfGenerator.tsx` | Substituir bloco `getUTC*` por `wallClockDateTimeBr` (comportamento equivalente) |

### Pagamentos (date-only — parcial Fase 3)

| Status | Arquivo | Mudança |
|--------|---------|---------|
| [ ] | `src/components/payment/payment-form.tsx` | Avaliar `wallClockDateIso` para default do input date |
| [ ] | `src/components/payment/payment-list.tsx` | `toLocaleDateString` → helper date-only (Fase 4 se necessário) |
| [ ] | `src/components/payment/payment-item.tsx` | Idem |

---

## Arquivos explicitamente fora do escopo (timestamps reais)

Não alterar salvo revisão:

- `src/pages/VenueNotifications.tsx` — `notification.createdAt`
- `src/pages/ProposalDetails.tsx` — `createdAt`
- `src/components/document/document-item.tsx` — `document.createdAt`

---

## Comando de auditoria pós-Fase 3

Executar na raiz do repositório:

```bash
rg "toTimeString|toLocaleDateString|format\([^)]*HH:mm" eventhub-vista-dashboard/src
```

Classificar cada ocorrência restante:

- **Evento** → corrigir
- **Timestamp real** → documentar exceção em [08-inventario-arquivos.md](./08-inventario-arquivos.md)

---

## Critérios de aceite

- [ ] Todos os itens `[ ]` acima marcados `[x]`
- [ ] TC-3.1 — ProposalView, BudgetDetails, PDF com horários iguais
- [ ] TC-edge — evento às `02:00` mantém data consistente
- [ ] TC-edge — schedule (atração) lista horário salvo
- [ ] Grep de auditoria sem matches em arquivos de evento

---

## Referências

- [03-convencao-wall-clock.md](./03-convencao-wall-clock.md)
- [08-inventario-arquivos.md](./08-inventario-arquivos.md)
