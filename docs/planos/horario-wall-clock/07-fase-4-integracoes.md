# Fase 4 — Integrações e casos especiais

**Objetivo:** corrigir sync externo (Google Calendar) e campos date-only (despesas/pagamentos) que sofrem shift de dia por `toISOString`.

**Esforço estimado:** ~0,5 dia  
**Dependências:** Fases 1–3 concluídas  
**Validação:** [09-checklist-testes.md](./09-checklist-testes.md) — seção Fase 4

---

## 1. Google Calendar sync

**Arquivo:** `art56_server_v3/src/services/google-calendar-sync-service.ts`

### Problema atual

```typescript
const startDateTime = new Date(dateEvent.startDate).toISOString();
// "2026-07-05T13:00:00.000Z"
start: { dateTime: startDateTime, timeZone: "America/Sao_Paulo" },
```

O Google Calendar API interpreta `dateTime` com `Z` como instante UTC absoluto. Combinado com `timeZone`, o evento pode aparecer deslocado em relação ao wall-clock do EventHub.

### Solução recomendada

Enviar datetime **sem offset Z**, com componentes wall-clock + timezone explícito:

```typescript
import { formatInTimeZone } from "date-fns-tz";

function toGoogleWallClockDateTime(date: Date): string {
  // "2026-07-05T13:00:00" — sem Z
  return formatInTimeZone(date, "UTC", "yyyy-MM-dd'T'HH:mm:ss");
}

const payload = {
  start: {
    dateTime: toGoogleWallClockDateTime(dateEvent.startDate),
    timeZone: "America/Sao_Paulo",
  },
  end: {
    dateTime: toGoogleWallClockDateTime(dateEvent.endDate),
    timeZone: "America/Sao_Paulo",
  },
};
```

**Nota:** `timeZone: "America/Sao_Paulo"` indica que os componentes de `dateTime` são “hora de parede” naquele fuso — alinhado à regra de produto (13:00 no app = 13:00 no Google Calendar em SP).

### Documentação

Atualizar [INTEGRATIONS_GOOGLE_CALENDAR.md](../../INTEGRATIONS_GOOGLE_CALENDAR.md) com seção “Semântica de horário” (ver [10-atualizacoes-docs-externos.md](./10-atualizacoes-docs-externos.md)).

### Critério

- [ ] TC-4.1 — evento criado às 13:00 aparece às 13:00 no Google Calendar (conta de teste em SP)

---

## 2. Despesas (Expense) — date-only

**Arquivos:**

- `art56_server_v3/src/use-cases/expense/create-expense/controller-create-expense.ts`
- `art56_server_v3/src/use-cases/expense/update-expense/use-case-update-expense.ts`

### Problema

```typescript
body.paymentDate = new Date(body.paymentDate).toISOString();
```

Input `"2026-07-05"` vira meia-noite **local** → ISO pode virar `2026-07-04T21:00:00.000Z` em BRT → dia errado no banco.

### Solução

Tratar como date-only wall-clock (meio-dia UTC ou parser explícito):

```typescript
function parseDateOnlyWallClock(dateStr: string): Date {
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
    return new Date(`${dateStr}T12:00:00.000Z`);
  }
  // fallback legado
  return moment.utc(dateStr, "DD/MM/YYYY").toDate();
}
```

Ou usar `wallClockDateIsoFromDate` inverso + `moment.utc`.

### Frontend

`payment-form.tsx` — default do input:

```typescript
paymentDate: payment?.paymentDate ? wallClockDateIso(payment.paymentDate) : ""
```

---

## 3. Pagamentos (Payment) — date-only

**Frontend:**

- `payment-list.tsx`, `payment-item.tsx` — exibir com `wallClockDateBr(payment.paymentDate)`

**Backend:** verificar se create/update payment usa conversão similar à expense; alinhar se necessário.

---

## 4. Fora de escopo (explicitamente)

| Arquivo / fluxo | Motivo |
|-----------------|--------|
| `VenueWebsite.tsx` — analytics `startDate`/`endDate` | Intervalo de consulta real (timestamps absolutos) |
| `VenueNotifications.tsx` — `createdAt` | Timestamp de auditoria |
| `createdAt` / `updatedAt` em geral | Instant real |
| Migração schema para `date` + `time` VARCHAR | Evolução futura opcional; não necessária para corrigir bug |

---

## Critérios de aceite Fase 4

- [ ] Google Calendar sync com wall-clock (TC-4.1)
- [ ] Despesa criada com data `05/07/2026` persiste e exibe mesmo dia
- [ ] Pagamento listado com data correta
- [ ] Docs de integração atualizados

---

## Referências

- [INTEGRATIONS_GOOGLE_CALENDAR.md](../../INTEGRATIONS_GOOGLE_CALENDAR.md)
- [10-atualizacoes-docs-externos.md](./10-atualizacoes-docs-externos.md)
- [09-checklist-testes.md](./09-checklist-testes.md)
