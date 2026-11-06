# Checklist de testes — horário wall-clock

Casos de teste manuais e critérios de aceite por fase. Executar com browser/OS configurado em **`America/Sao_Paulo` (UTC−3)**.

---

## Dados de teste sugeridos

| Campo | Valor |
|-------|-------|
| Data principal | `05/07/2026` (`2026-07-05` no input date) |
| Hora início | `13:00` |
| Hora fim | `18:00` |
| Hora edge (meia-noite) | `02:00` |
| Venue | Espaço de teste com permissão `EDIT_VENUE_CALENDAR` |
| Usuário | Admin ou com permissões de proposta + calendário |

---

## Fase 1 — Util + P0 frontend

### TC-1.1 — Proposta per-person: criar e reeditar

**Pré-condição:** Fase 1 implementada (jul/2026). Testes unitários Vitest passando; validação manual no browser recomendada.

1. Criar orçamento per-person com data `05/07/2026`, horário `13:00` – `18:00`
2. Salvar e abrir tela de **edição** da proposta
3. Verificar campos de data e hora no formulário
4. Abrir **ProposalView** (link público) e **ProposalServicesSummary**

**Resultado esperado:**

- [ ] Form de edição mostra `13:00` e `18:00`
- [ ] Data do input date = `2026-07-05`
- [ ] ProposalView exibe `13:00` – `18:00`
- [ ] Resumo de serviços exibe mesmas horas

---

### TC-1.2 — VenueSchedule: calendário + edição

1. Acessar **Calendário do venue** (`VenueSchedule`)
2. Criar evento (ou usar existente) com `13:00` – `18:00` em `05/07/2026`
3. Verificar posição do bloco no grid mensal
4. Clicar no evento → painel de detalhe
5. Clicar **Editar** → verificar form

**Resultado esperado:**

- [ ] Bloco no calendário aparece na faixa das **13h**, não 10h
- [ ] Detalhe do evento: `13:00/18:00`
- [ ] Form de edição: `startHour=13:00`, `endHour=18:00`
- [ ] Após salvar sem alterar, valores permanecem iguais

---

### TC-1.3 — Regressão ProposalEdit

1. Editar proposta existente apenas o nome do cliente
2. Salvar sem mudar data/hora

**Resultado esperado:**

- [ ] Horários não alteram após save

---

## Fase 2 — Backend

### TC-2.1 — E-mail confirmação de presença

**Pré-condição:** SMTP configurado ou mock/log de e-mail; proposta com convidado.

1. Disparar e-mail de confirmação de presença para convidado de teste
2. Inspecionar corpo do e-mail

**Resultado esperado:**

- [ ] Data `05/07/2026` (ou equivalente)
- [ ] Horário `13:00` – `18:00` no texto

---

### TC-2.2 — Notificação in-app de novo evento

1. Criar dateEvent no calendário
2. Verificar notificação gerada no venue

**Resultado esperado:**

- [ ] Data na mensagem = data selecionada (sem dia anterior/posterior)

---

### TC-2.3 — Schedule (backend): data da proposta

1. Proposta com evento em `05/07/2026`
2. Criar atração no cronograma `14:00` – `15:00`
3. Inspecionar registro no banco ou resposta API

**Resultado esperado:**

- [ ] `startHour` ISO contém `T14:00:00.000Z` (componente 14, não 11)

---

### TC-2.4 — transformDate com ISO date

1. Criar proposta via API ou form com `<input type="date">` = `2026-07-05`

**Resultado esperado:**

- [ ] `startDate` persistido como `2026-07-05T13:00:00.000Z` (não Invalid Date)

---

## Fase 3 — Frontend completo

### TC-3.1 — Telas secundárias consistentes

1. Abrir **BudgetDetails** (se disponível)
2. Listar propostas em **ProposalTable** / **EventTable**
3. Listar dateEvents na proposta (**dateEvent-list**)
4. Gerar **PDF de contrato** com placeholder de data/hora de evento

**Resultado esperado:**

- [ ] Todas exibem `13:00` – `18:00` e data `05/07/2026`
- [ ] Nenhuma tela mostra `10:00`

---

### TC-3.2 — Cronograma de atrações (ScheduleList)

1. Abrir cronograma da proposta
2. Adicionar atração `14:00` – `15:00`
3. Verificar listagem

**Resultado esperado:**

- [ ] Texto exibido: `05/07/2026 14:00 - 15:00` (ou formato equivalente correto)
- [ ] Ao reabrir, horários mantidos

---

### TC-edge-1 — Horário perto da meia-noite

1. Criar evento `05/07/2026` `02:00` – `06:00`
2. Verificar em VenueSchedule, ProposalView e edição

**Resultado esperado:**

- [ ] Data permanece `05/07/2026` em todas as telas (não `04/07/2026`)

---

### TC-edge-2 — Evento overnight (pernoite)

1. Venue com `hasOvernightStay`
2. Check-in `05/07/2026 14:00`, check-out `06/07/2026 12:00`

**Resultado esperado:**

- [ ] Datas e horas corretas em ProposalView e resumo

---

## Fase 4 — Integrações

### TC-4.1 — Google Calendar sync

**Pré-condição:** Integração Google conectada; permissão `EDIT_VENUE_CALENDAR`.

1. Criar dateEvent `05/07/2026` `13:00` – `18:00`
2. Aguardar sync (ou forçar create)
3. Abrir Google Calendar na conta conectada (timezone São Paulo)

**Resultado esperado:**

- [ ] Evento aparece das **13:00** às **18:00** (horário de SP)
- [ ] Data **5 de julho de 2026**

---

### TC-4.2 — Despesa date-only

1. Criar despesa com data pagamento `05/07/2026`
2. Reabrir formulário / listagem

**Resultado esperado:**

- [ ] Data exibida e persistida = `05/07/2026` (não `04/07/2026`)

---

## Critérios globais de aceite (todas as fases)

- [ ] Nenhum fluxo de **evento** exibe deslocamento de 3h em BRT
- [ ] Grep de auditoria (ver [08-inventario-arquivos.md](./08-inventario-arquivos.md)) sem matches não justificados em arquivos EVENTO
- [ ] Docs externos atualizados ([10-atualizacoes-docs-externos.md](./10-atualizacoes-docs-externos.md))
- [ ] Entrada em KNOWN_LIMITATIONS marcada como resolvida

---

## Referências

- [04-fase-1-util-e-p0-frontend.md](./04-fase-1-util-e-p0-frontend.md)
- [05-fase-2-backend.md](./05-fase-2-backend.md)
- [06-fase-3-frontend-completo.md](./06-fase-3-frontend-completo.md)
- [07-fase-4-integracoes.md](./07-fase-4-integracoes.md)
