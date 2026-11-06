# Convenção wall-clock — contrato normativo

Documento **obrigatório** para qualquer alteração que leia, exiba ou persista horários de **evento** no EventHub.

---

## Definições

| Termo | Significado |
|-------|-------------|
| **Wall-clock** | Data e hora exatamente como o usuário digitou/selecionou, sem conversão de fuso |
| **EventDateTime** | Campo de domínio: `Proposal.startDate/endDate`, `DateEvent.startDate/endDate`, `Schedule.startHour/endHour` |
| **Date-only** | Campo só com dia (ex.: `Payment.paymentDate`) — sem componente de hora de evento |
| **Real timestamp** | `createdAt`, `updatedAt`, expiração de token — instante real; pode usar fuso local na UI |

**Exemplo:** usuário escolhe `05/07/2026` às `13:00`.

- **Salvar:** `2026-07-05T13:00:00.000Z` no MySQL
- **Exibir:** `05/07/2026` e `13:00` em qualquer tela
- **Nunca exibir:** `10:00` por estar no Brasil (UTC−3)

---

## Regras DO / DON'T

| Situação | DO | DON'T |
|----------|-----|-------|
| Extrair hora de EventDateTime | `wallClockTime(iso)` ou `split('T')[1].slice(0,5)` | `format(d, "HH:mm")`, `toTimeString()` |
| Extrair data para `<input type="date">` | `wallClockDateIso(iso)` | `toLocaleDateString`, `format(d, "yyyy-MM-dd")` sem UTC |
| Exibir data BR | `wallClockDateBr(iso)` | `new Date(iso).toLocaleDateString('pt-BR')` |
| Exibir data+hora BR | `wallClockDateTimeBr(iso)` | Combinar format local + ISO substring |
| Calendário (`react-big-calendar`) | `wallClockToCalendarDate(iso)` | `new Date(iso)` direto |
| Combinar data proposta + hora string | Montar ISO wall-clock ou usar helper | `setHours(h, m)` em `Date` local |
| Persistir no backend | `transformDate` / `moment.utc` com componentes literais | `new Date(iso).toLocaleDateString` para extrair dia |
| E-mail / notificação BE | `formatInTimeZone(d, 'UTC', 'HH:mm')` | `format(d, 'HH:mm')` |
| PDF / contrato | `wallClockDateTimeBr` ou getters UTC | `format` local |
| Timestamps de auditoria | `format(new Date(createdAt), ...)` com locale | Aplicar regra wall-clock |

---

## API proposta — Frontend

**Arquivo a criar:** `eventhub-vista-dashboard/src/lib/wall-clock-datetime.ts`

```typescript
/**
 * Normaliza entrada para string ISO (com Z).
 */
function toIsoString(value: string | Date): string;

/**
 * Extrai hora literal "HH:mm" da ISO wall-clock.
 * Ex.: "2026-07-05T13:00:00.000Z" → "13:00"
 */
export function wallClockTime(value: string | Date): string;

/**
 * Extrai data "YYYY-MM-DD" para input type="date".
 */
export function wallClockDateIso(value: string | Date): string;

/**
 * Formata data "dd/MM/yyyy".
 */
export function wallClockDateBr(value: string | Date): string;

/**
 * Formata "dd/MM/yyyy às HH:mm".
 */
export function wallClockDateTimeBr(value: string | Date): string;

/**
 * Cria Date cujo getHours()/getDate() refletem componentes wall-clock.
 * Uso exclusivo: react-big-calendar e libs que exigem Date local.
 */
export function wallClockToCalendarDate(value: string | Date): Date;

/**
 * Valida par date (YYYY-MM-DD) + time (HH:mm) antes de enviar à API.
 */
export function assertWallClockFormFields(date: string, time: string): void;
```

### Implementação de referência (extrair hora)

```typescript
export function wallClockTime(value: string | Date): string {
  const iso = typeof value === "string" ? value : value.toISOString();
  const t = iso.includes("T") ? iso.split("T")[1] : "";
  return t.slice(0, 5);
}
```

### Implementação de referência (calendário)

```typescript
export function wallClockToCalendarDate(value: string | Date): Date {
  const iso = typeof value === "string" ? value : value.toISOString();
  const [datePart, timePart = "00:00:00.000Z"] = iso.split("T");
  const [y, m, d] = datePart.split("-").map(Number);
  const [hh, mm] = timePart.slice(0, 5).split(":").map(Number);
  return new Date(y, m - 1, d, hh, mm, 0, 0);
}
```

---

## API proposta — Backend

**Arquivo a criar:** `art56_server_v3/src/functions/wall-clock-datetime.ts`

```typescript
/** Formata EventDateTime para exibição em e-mail/notificação */
export function formatWallClockTime(date: Date): string;
export function formatWallClockDateBr(date: Date): string;

/** Extrai YYYY-MM-DD UTC (componentes wall-clock) */
export function wallClockDateIsoFromDate(date: Date): string;
```

Usar `date-fns-tz`:

```typescript
import { formatInTimeZone } from "date-fns-tz";

export function formatWallClockTime(date: Date): string {
  return formatInTimeZone(date, "UTC", "HH:mm");
}
```

---

## Regras backend — `transformDate`

1. Aceitar **`YYYY-MM-DD`** (frontend `<input type="date">`) **e** **`dd/MM/yyyy`** (legado / `toLocaleDateString`)
2. Manter **`moment.utc(...).toDate()`** — não trocar para timezone local do servidor
3. Não usar `proposal.startDate.toLocaleDateString('pt-BR')` — usar `wallClockDateIsoFromDate` ou equivalente

### Parser dual-format (pseudo-código)

```typescript
function parseDateParts(date: string, divisor = "/"): { year: string; month: string; day: string } {
  if (/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    const [year, month, day] = date.split("-");
    return { year, month, day };
  }
  const [day, month, year] = date.split(divisor);
  return { year, month, day };
}
```

---

## Funções proibidas para EventDateTime

Não usar diretamente (grep de auditoria):

- `toTimeString()`
- `toLocaleDateString()` / `toLocaleTimeString()`
- `date-fns` `format(date, "HH:mm")` ou `format(date, "dd/MM/yyyy")` sem `timeZone: "UTC"`
- `setHours()` / `getHours()` para montar ou ler hora de evento
- `new Date(iso)` passado a calendários sem `wallClockToCalendarDate`

---

## Duplicatas a eliminar

Função `formatarDataIso` copiada em:

- `eventhub-vista-dashboard/src/components/VenueCard.tsx`
- `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx`
- `eventhub-vista-dashboard/src/components/dateEvent/dateEvent-form.tsx`

Substituir todas por `wallClockDateTimeBr` do util central.

---

## Escopo de campos por entidade

| Entidade | Campos wall-clock | Campos date-only | Ignorar (timestamp real) |
|----------|-------------------|------------------|----------------------------|
| Proposal | startDate, endDate | — | createdAt, updatedAt |
| DateEvent | startDate, endDate | — | createdAt, updatedAt |
| Schedule | startHour, endHour (DateTime) | — | createdAt, updatedAt |
| Payment | — | paymentDate | createdAt |
| Expense | — | paymentDate | createdAt |
| Notification | — | — | createdAt |

---

## Referências

- [02-arquitetura-atual.md](./02-arquitetura-atual.md)
- [04-fase-1-util-e-p0-frontend.md](./04-fase-1-util-e-p0-frontend.md) — implementação do util FE
- [05-fase-2-backend.md](./05-fase-2-backend.md) — implementação do util BE + transformDate
