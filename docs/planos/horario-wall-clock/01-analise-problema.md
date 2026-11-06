# Análise do problema — horário wall-clock

> **Status (jul/2026):** problema identificado; correção pendente. Ver fases em [04-fase-1-util-e-p0-frontend.md](./04-fase-1-util-e-p0-frontend.md) em diante.

## Sintoma reportado

O usuário seleciona um horário de evento (ex.: `13:00`) em formulários do dashboard. Após salvar, ao reabrir a tela, visualizar o calendário do venue, gerar PDF ou receber e-mail, o horário exibido **não corresponde** ao selecionado — em geral **3 horas a menos** no fuso `America/Sao_Paulo` (UTC−3).

## Impacto

- **Propostas:** edição, visualização pública, resumo de serviços, tabelas de orçamento
- **Calendário do venue (`VenueSchedule`):** grid do `react-big-calendar` e formulário de edição
- **DateEvents:** datas adicionais na proposta
- **Cronograma (Schedule):** horários de atrações
- **E-mails:** confirmação de presença
- **PDF de contrato:** placeholders com data/hora de evento
- **Google Calendar:** sync pode exibir horário errado no calendário externo
- Perda de confiança operacional; risco de contrato/evento com horário incorreto

---

## Comportamento por etapa do fluxo

| Etapa | Comportamento esperado | Comportamento atual | Status |
|-------|------------------------|---------------------|--------|
| Usuário seleciona `13:00` no form | Valor `13:00` enviado à API | Strings `startHour`/`endHour` corretas | OK |
| Backend persiste | `2026-07-05T13:00:00.000Z` (wall-clock em UTC) | `transformDate` usa `moment.utc` | OK (intenção) |
| API retorna ISO | JSON com `Z` preservando componentes 13:00 | Prisma serializa `DateTime` como ISO UTC | OK |
| Frontend exibe (telas corretas) | `13:00` | `toISOString().substring(11,16)`, `split('T')`, `formatInTimeZone(..., "UTC")` | OK parcial |
| Frontend exibe (telas incorretas) | `13:00` | `format()`, `toTimeString()`, `toLocaleDateString()`, `setHours()` | **Bug** |
| Calendário visual | Bloco às 13:00 | `new Date(iso)` + `react-big-calendar` em fuso local | **Bug** |
| E-mail / notificação BE | `13:00` no corpo | `format(date, "HH:mm")` no TZ do servidor | **Bug** |
| Google Calendar | Evento às 13:00 em SP | `toISOString()` + `timeZone: America/Sao_Paulo` | **Bug provável** |

---

## Causa raiz

O backend **intencionalmente** trata data+hora do usuário como wall-clock via `moment.utc` em `transform-date.ts`. O valor no banco é um instante UTC cujos **componentes de data/hora coincidem com o que o usuário digitou** (ex.: 13:00 → `T13:00:00.000Z`).

O frontend (e partes do backend na **leitura/formatação**) aplica **três estratégias diferentes**:

### Estratégia A — correta para wall-clock

- `toISOString().substring(11, 16)` ou `split('T')[1].slice(0, 5)`
- `formatInTimeZone(iso, "UTC", "HH:mm")`
- `toZonedTime(d, "UTC")` + `format(..., { timeZone: "UTC" })`
- `getUTCHours()`, `getUTCMinutes()`, etc.

### Estratégia B — incorreta (fuso local)

- `format(date, "HH:mm")` sem timezone explícito
- `toTimeString().slice(0, 5)`
- `toLocaleDateString('pt-BR')`
- `setHours(h, m)` em `Date` local para combinar data+hora de evento

### Estratégia C — incorreta (calendário)

- Passar `new Date(isoString)` direto ao `react-big-calendar`, que renderiza no fuso do browser

**Resultado:** o mesmo registro `2026-07-05T13:00:00.000Z` aparece como `13:00` em uma tela e `10:00` em outra.

---

## Evidências no código

### 1. VenueSchedule — leitura inconsistente no mesmo formulário

Arquivo: `eventhub-vista-dashboard/src/pages/VenueSchedule.tsx`

```typescript
// fillFormWithEventData — linhas ~146-155
startDay: startDate.toISOString().split("T")[0],   // ✅ extrai data da ISO (UTC)
startHour: startDate.toTimeString().slice(0, 5),   // ❌ fuso local → 10:00 em BRT
endHour: endDate.toTimeString().slice(0, 5),       // ❌ idem
```

No detalhe do evento na mesma página, `formatInTimeZone(..., "UTC", "HH:mm")` está **correto** — inconsistência intra-arquivo.

Eventos do calendário:

```typescript
start: new Date(event.startDate),  // ❌ react-big-calendar interpreta em fuso local
```

### 2. BudgetDetails — format local

Arquivo: `eventhub-vista-dashboard/src/components/BudgetDetails.tsx`

```typescript
{format(proposal.startDate, "HH:mm")} - {format(proposal.endDate, "HH:mm")}
```

`date-fns` `format` usa componentes locais do `Date` → deslocamento de 3h no Brasil.

### 3. Backend — persistência correta

Arquivo: `art56_server_v3/src/functions/transform-date.ts`

```typescript
const startDate = moment.utc(
  `${yearInicio}-${monthInicio}-${dayInicio} ${hourInicio}:${minutesInicio}`,
  'YYYY-MM-DD HH:mm',
).toDate();
```

Salvar `13:00` como `T13:00:00.000Z` está alinhado com wall-clock.

### 4. ScheduleList — combinação com setHours local

Arquivo: `eventhub-vista-dashboard/src/pages/ScheduleList.tsx`

```typescript
const result = new Date(d);
result.setHours(h, m, 0, 0);  // ❌ aplica hora no fuso local
// ...
dateHourStr = `${format(startDateTime, "dd/MM/yyyy HH:mm")} - ...`;  // ❌ format local
```

### 5. Google Calendar — dupla semântica

Arquivo: `art56_server_v3/src/services/google-calendar-sync-service.ts`

```typescript
const startDateTime = new Date(dateEvent.startDate).toISOString();  // "…T13:00:00.000Z"
start: { dateTime: startDateTime, timeZone: "America/Sao_Paulo" },
```

Instante UTC absoluto + timezone SP pode fazer o Google exibir horário diferente do wall-clock esperado.

### 6. E-mail de confirmação — format no servidor

Arquivo: `art56_server_v3/src/use-cases/email/send-attendence-confirmation-to-email/use-case-send-attendence-confirmation-to-email.ts`

```typescript
const startTime = format(proposal.startDate, "HH:mm");
const endTime = format(proposal.endDate, "HH:mm");
```

Depende do timezone do processo Node (UTC em produção vs BRT local → resultados distintos).

---

## Bug secundário — formato de data no `transformDate`

O frontend envia datas de `<input type="date">` como **`YYYY-MM-DD`** (ex.: `2026-07-05`).

`transformDate` faz:

```typescript
const [dayInicio, monthInicio, yearInicio] = date.split(divisor || '/');
```

Com `divisor: "/"` e date `"2026-07-05"`, o split retorna um único segmento → `monthInicio` e `yearInicio` ficam `undefined` → string inválida para `moment.utc`.

**Exceção parcial:** use-cases de schedule usam `proposal.startDate.toLocaleDateString('pt-BR')` no backend, gerando `dd/MM/yyyy` — funciona, mas depende do fuso do **servidor**.

**Correção necessária:** parser dual-format em `transform-date.ts` (Fase 2).

---

## Telas já parcialmente corretas (referência)

| Arquivo | Padrão usado |
|---------|--------------|
| `ProposalEdit.tsx` | `toISOString().substring(11, 16)` |
| `ProposalView.tsx` | `toZonedTime` + `format` com `timeZone: "UTC"` |
| `ProposalServicesSummary.tsx` | Horas via `toISOString().substring` (datas ainda com `toLocaleDateString`) |
| `dateEvent-form.tsx` | `split('T')` na string ISO |
| `ContractPdfGenerator.tsx` | `getUTCHours()`, `getUTCMinutes()` |
| `VenueCard.tsx`, `VenueDashboard.tsx` | `formatarDataIso` via split na ISO |

Esses padrões devem convergir para o util central descrito em [03-convencao-wall-clock.md](./03-convencao-wall-clock.md).

---

## Próximos passos

1. [02-arquitetura-atual.md](./02-arquitetura-atual.md) — mapa técnico completo
2. [03-convencao-wall-clock.md](./03-convencao-wall-clock.md) — regras normativas
3. Implementação faseada: [04](./04-fase-1-util-e-p0-frontend.md) → [07](./07-fase-4-integracoes.md)
