# Atualizações em documentos externos

Checklist de documentação **fora** desta pasta que deve ser atualizada ao concluir cada fase. Seguir [GUIA_DE_IMPLEMENTACAO.md](../../processo/GUIA_DE_IMPLEMENTACAO.md).

---

## Ao criar esta pasta (documentação)

| Documento | Ação | Status |
|-----------|------|--------|
| [docs/INDEX.md](../../INDEX.md) | Adicionar entrada em **§14 Planos de feature** e **§4 Onde fica o quê** | Concluído |
| [README.md](./README.md) | Manter como índice da iniciativa | Concluído |

---

## Após Fase 1 — Util + P0 frontend

| Documento | Ação | Status |
|-----------|------|--------|
| [FRONTEND_ANALISE_ATUAL.md](../../estado/frontend/FRONTEND_ANALISE_ATUAL.md) | Nota: util `wall-clock-datetime.ts` criado; VenueSchedule e proposta P0 migrados | [x] jul/2026 |
| [KNOWN_LIMITATIONS.md](../../estado/integracao/KNOWN_LIMITATIONS.md) | Adicionar limitação “horário deslocado por UTC” se ainda não existir (parcialmente mitigada) | [x] jul/2026 |

---

## Após Fase 2 — Backend

| Documento | Ação | Status |
|-----------|------|--------|
| [BACKEND_ANALISE_ATUAL.md](../../estado/backend/BACKEND_ANALISE_ATUAL.md) | Nota: `transformDate` dual-format; helpers wall-clock; e-mails/notifications UTC | [ ] |
| [API_CONTRACTS.md](../../referencias/API_CONTRACTS.md) | Nota em Proposal/DateEvent/Schedule (ver texto sugerido abaixo) | [ ] |

---

## Após Fase 3 — Frontend completo

| Documento | Ação | Status |
|-----------|------|--------|
| [KNOWN_LIMITATIONS.md](../../estado/integracao/KNOWN_LIMITATIONS.md) | Marcar limitação de horário como **resolvida** | [ ] |
| [REGRAS_DE_NEGOCIO.md](../../referencias/REGRAS_DE_NEGOCIO.md) | Adicionar seção wall-clock (texto sugerido abaixo) | [ ] |
| [DATA_MODEL_EXPLAINED.md](../../referencias/DATA_MODEL_EXPLAINED.md) | Expandir linha “Datas” com semântica wall-clock | [ ] |
| [FRONTEND_ANALISE_ATUAL.md](../../estado/frontend/FRONTEND_ANALISE_ATUAL.md) | Varredura FE concluída; lista de exceções (timestamps) | [ ] |

---

## Após Fase 4 — Integrações

| Documento | Ação | Status |
|-----------|------|--------|
| [INTEGRATIONS_GOOGLE_CALENDAR.md](../../INTEGRATIONS_GOOGLE_CALENDAR.md) | Seção “Semântica de horário” no sync | [ ] |
| [DATA_MODEL_EXPLAINED.md](../../referencias/DATA_MODEL_EXPLAINED.md) | Nota em Expense/Payment paymentDate (date-only) | [ ] |

---

## Textos sugeridos — REGRAS_DE_NEGOCIO.md

```markdown
### Eventos — horário wall-clock (sem conversão de fuso)

- Horários de evento (proposta, dateEvent, cronograma) são **wall-clock**: o valor selecionado pelo usuário é o valor persistido e exibido.
- Exemplo: se o usuário escolhe `13:00`, o sistema salva e mostra `13:00`, independente do fuso do browser ou do servidor.
- Campos afetados: `Proposal.startDate`, `Proposal.endDate`, `DateEvent.startDate`, `DateEvent.endDate`, `Schedule.startHour`, `Schedule.endHour`.
- A API serializa esses campos como ISO 8601 UTC (`…T13:00:00.000Z`); os **componentes** de data/hora correspondem ao que o usuário digitou, não a um instante convertido para Brasil.
- Timestamps de auditoria (`createdAt`, `updatedAt`) não seguem esta regra.
- Implementação: util `wall-clock-datetime` (FE/BE); ver planos/horario-wall-clock/.
```

---

## Textos sugeridos — API_CONTRACTS.md

Adicionar nota nas seções **Proposal**, **DateEvent** e **Schedule**:

```markdown
**Semântica de data/hora (wall-clock):** campos `startDate`, `endDate` (e `startHour`/`endHour` em Schedule)
representam data e hora **literais** escolhidas pelo usuário. A serialização JSON usa sufixo `Z` (UTC), mas
clientes devem extrair componentes via UTC (ex.: hora = substring após `T` ou `formatInTimeZone(..., "UTC", ...)`),
**sem** converter para fuso local do browser. Entrada na criação/atualização: strings `date` (`YYYY-MM-DD` ou `dd/MM/yyyy`)
e `startHour`/`endHour` (`HH:mm`).
```

---

## Textos sugeridos — DATA_MODEL_EXPLAINED.md

Substituir/expandir linha na tabela “Campos sensíveis”:

```markdown
| **Datas de evento** | startDate, endDate (Proposal, DateEvent); startHour, endHour (Schedule) | **Wall-clock:** componentes UTC = hora digitada. Não converter fuso na leitura. Ver planos/horario-wall-clock/. |
| **Datas de pagamento** | paymentDate (Payment, Expense) | Date-only; tratar sem shift de dia (Fase 4). |
| **Timestamps** | createdAt, updatedAt, expiresAt | Instant real; exibição em fuso local OK. |
```

---

## Textos sugeridos — KNOWN_LIMITATIONS.md

### Entrada a adicionar (antes da correção)

```markdown
| Horário de evento deslocado (UTC) | FE/BE | Várias telas usam `format()`, `toTimeString()` ou calendário local; backend e-mails usam TZ do servidor. Usuário seleciona 13:00 e vê 10:00 (BRT). | Ver planos/horario-wall-clock/; workaround: nenhum confiável. |
```

### Entrada após Fase 3 (substituir)

```markdown
| ~~Horário de evento deslocado (UTC)~~ | FE/BE | **Resolvido (jul/2026)** — util wall-clock; ver planos/horario-wall-clock/. |
```

---

## Textos sugeridos — INTEGRATIONS_GOOGLE_CALENDAR.md

```markdown
## Semântica de horário no sync

Eventos sincronizados do EventHub usam **wall-clock**: `13:00` no app = `13:00` no Google Calendar (timezone `America/Sao_Paulo`).

O payload envia `dateTime` sem sufixo `Z`, com componentes literais, e `timeZone: "America/Sao_Paulo"`.
Não usar `toISOString()` com `Z` combinado com timeZone — isso deslocava o evento em 3h no Brasil.

Detalhes: [planos/horario-wall-clock/07-fase-4-integracoes.md](../planos/horario-wall-clock/07-fase-4-integracoes.md).
```

---

## Textos sugeridos — FRONTEND_ANALISE_ATUAL.md

```markdown
### Horários de evento (wall-clock)

- Util central: `src/lib/wall-clock-datetime.ts` — extrair/formatar EventDateTime sem fuso local.
- Regra: não usar `format(date, "HH:mm")`, `toTimeString()` ou `toLocaleDateString()` para proposta/dateEvent/schedule.
- Plano completo: [planos/horario-wall-clock/README.md](../planos/horario-wall-clock/README.md).
```

---

## Textos sugeridos — BACKEND_ANALISE_ATUAL.md

```markdown
### Horários de evento (wall-clock)

- Persistência: `src/functions/transform-date.ts` (`moment.utc`) + parser dual-format `YYYY-MM-DD` / `dd/MM/yyyy`.
- Formatação: `src/functions/wall-clock-datetime.ts` (`formatInTimeZone(..., "UTC", ...)`).
- Plano: [planos/horario-wall-clock/README.md](../planos/horario-wall-clock/README.md).
```

---

## Textos sugeridos — INDEX.md §14

```markdown
| planos/horario-wall-clock/ | Padronizar horários de evento (wall-clock): escolheu 13:00 → salva e exibe 13:00; plano faseado FE/BE/integrações. | horário, UTC, wall-clock, timezone, proposta, dateEvent | referencias/DATA_MODEL_EXPLAINED, referencias/REGRAS_DE_NEGOCIO, processo/GUIA_DE_IMPLEMENTACAO | Pendente |
```

---

## Textos sugeridos — INDEX.md §4 (Onde fica o quê)

```markdown
| **Horários / datas de evento** | planos/horario-wall-clock/README.md, referencias/REGRAS_DE_NEGOCIO.md, referencias/DATA_MODEL_EXPLAINED.md, referencias/API_CONTRACTS.md |
```

---

## Referências

- [README.md](./README.md)
- [GUIA_DE_IMPLEMENTACAO.md](../../processo/GUIA_DE_IMPLEMENTACAO.md)
