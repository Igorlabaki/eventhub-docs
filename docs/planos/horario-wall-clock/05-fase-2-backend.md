# Fase 2 — Backend

**Objetivo:** corrigir persistência e formatação server-side para wall-clock consistente.

**Esforço estimado:** 0,5–1 dia  
**Dependências:** Fase 1 (convencão definida); pode ser paralela ao FE se convencão já lida  
**Validação:** [09-checklist-testes.md](./09-checklist-testes.md) — seção Fase 2

---

## Entregas

1. `art56_server_v3/src/functions/wall-clock-datetime.ts`
2. `transform-date.ts` com parser dual-format
3. Schedule use-cases sem `toLocaleDateString`
4. E-mails e notificações com formatação UTC explícita

---

## 1. Criar `wall-clock-datetime.ts` (backend)

Espelhar helpers de formatação:

```typescript
import { formatInTimeZone } from "date-fns-tz";

export function formatWallClockTime(date: Date): string {
  return formatInTimeZone(date, "UTC", "HH:mm");
}

export function formatWallClockDateBr(date: Date): string {
  return formatInTimeZone(date, "UTC", "dd/MM/yyyy");
}

export function wallClockDateIsoFromDate(date: Date): string {
  return formatInTimeZone(date, "UTC", "yyyy-MM-dd");
}
```

Instalar `date-fns-tz` no backend se ainda não existir (verificar `package.json`).

---

## 2. Corrigir `transform-date.ts`

### Antes (fragil)

```typescript
const [dayInicio, monthInicio, yearInicio] = date.split(divisor || '/');
const startDate = moment.utc(
  `${yearInicio}-${monthInicio}-${dayInicio} ${hourInicio}:${minutesInicio}`,
  'YYYY-MM-DD HH:mm',
).toDate();
```

Falha quando `date === "2026-07-05"` (formato ISO do frontend).

### Depois (dual-format)

```typescript
function parseDateParts(date: string, divisor = "/") {
  if (/^\d{4}-\d{2}-\d{2}$/.test(date.trim())) {
    const [year, month, day] = date.split("-");
    return { year, month, day };
  }
  const [day, month, year] = date.split(divisor);
  if (!day || !month || !year) {
    throw new Error(`Formato de data inválido: ${date}`);
  }
  return { year, month, day };
}
```

Manter lógica de overnight (endDate no dia seguinte se `endHour < startHour`).

### Testes sugeridos

| Entrada date | startHour | Esperado ISO (UTC) |
|--------------|-----------|-------------------|
| `2026-07-05` | `13:00` | `2026-07-05T13:00:00.000Z` |
| `05/07/2026` | `13:00` | `2026-07-05T13:00:00.000Z` |
| `05/07/2026` | `22:00` / end `02:00` | end no dia `2026-07-06T02:00:00.000Z` |

---

## 3. Schedule use-cases

**Arquivos:**

- `art56_server_v3/src/use-cases/schedule/create-schedule/use-case-create-schedule.ts`
- `art56_server_v3/src/use-cases/schedule/update-schedule/use-case-update-schedule.ts`

### Antes

```typescript
transformDate({
  date: proposal.startDate.toLocaleDateString('pt-BR'),
  endHour: params.endHour,
  startHour: params.startHour,
  divisor: "/",
});
```

### Depois

```typescript
import { wallClockDateIsoFromDate } from "../../../functions/wall-clock-datetime";

transformDate({
  date: wallClockDateIsoFromDate(proposal.startDate),
  endHour: params.endHour,
  startHour: params.startHour,
  divisor: "-", // ou omitir e deixar parser detectar ISO
});
```

---

## 4. E-mail de confirmação de presença

**Arquivo:** `art56_server_v3/src/use-cases/email/send-attendence-confirmation-to-email/use-case-send-attendence-confirmation-to-email.ts`

### Antes

```typescript
const startTime = format(proposal.startDate, "HH:mm");
const endTime = format(proposal.endDate, "HH:mm");
const startDay = format(proposal.startDate, "dd/MM/yyyy");
```

### Depois

```typescript
import { formatWallClockTime, formatWallClockDateBr } from "../../../functions/wall-clock-datetime";

const startTime = formatWallClockTime(proposal.startDate);
const endTime = formatWallClockTime(proposal.endDate);
const startDay = formatWallClockDateBr(proposal.startDate);
const endDay = formatWallClockDateBr(proposal.endDate);
```

---

## 5. Notificações in-app

Substituir `format(startDate, "dd/MM/yyyy")` por `formatWallClockDateBr(startDate)` nos use-cases:

| Arquivo |
|---------|
| `create-data-event/use-case-create-date-event.ts` |
| `create-overnight-data-event/use-case-create-overnigth-date-event.ts` |
| `update-same-day-event/use-case-update-same-day-date-event.ts` |
| `update-overnigth-day-event/use-case-update-overnigth-date-event.ts` |
| `create-proposal-per-person/use-case-create-proposal-per-person.ts` (mensagens de notification) |
| `create-proposal-per-day/use-case-create-proposal-per-day.ts` (idem) |

Para mensagens que incluem horário, usar também `formatWallClockTime`.

---

## Critérios de aceite

- [ ] `transformDate` aceita `YYYY-MM-DD` e `dd/MM/yyyy`
- [ ] Testes unitários passam para ambos formatos
- [ ] Schedule create/update não usa `toLocaleDateString`
- [ ] E-mail de presença exibe horário igual ao formulário (TC-2.1)
- [ ] Notificações de novo orçamento/evento com data correta

---

## Referências

- [03-convencao-wall-clock.md](./03-convencao-wall-clock.md)
- [05-fase-2-backend.md](./05-fase-2-backend.md) *(este documento)*
- [09-checklist-testes.md](./09-checklist-testes.md)
