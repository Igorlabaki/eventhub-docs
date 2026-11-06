# Checklist de testes — ordenação de cláusulas

Casos de teste manuais e critérios de aceite por fase. Executar após cada implementação.

---

## Dados de teste sugeridos

Criar na organização de teste três cláusulas na biblioteca:

| Título | Texto (resumo) |
|--------|----------------|
| Cláusula A | "Primeira cláusula de teste." |
| Cláusula B | "Segunda cláusula de teste." |
| Cláusula C | "Terceira cláusula de teste." |

Contrato de teste: vincular a um venue usado em propostas de teste.

---

## Fase 1 — Correção imediata

### TC-1.1 — Ordem na criação e impressão

**Pré-condição:** Fase 1 implementada (backend `orderBy` + sort no PDF).

1. Acessar **Organização → Contratos → Contratos**
2. Criar contrato selecionando cláusulas na ordem **A → B → C** (ordem de clique)
3. Salvar contrato
4. Abrir proposta de teste vinculada ao mesmo venue
5. Selecionar o contrato criado
6. Clicar **Gerar Contrato** (PF ou PJ)
7. Abrir PDF gerado

**Resultado esperado:**

- [x] Cláusula A numerada **I**
- [x] Cláusula B numerada **II**
- [x] Cláusula C numerada **III**

---

### TC-1.2 — Ordem após edição

1. Editar contrato de teste
2. Alterar ordem para **C → A → B** (desmarcar/remarcar ou reordenar se Fase 2 parcial)
3. Salvar
4. Gerar PDF novamente

**Resultado esperado:**

- [x] PDF exibe **C (I), A (II), B (III)**

---

### TC-1.3 — API list retorna ordenado

1. Autenticar e chamar `GET /contract/list/{organizationId}/{venueId}` (ou rota equivalente documentada em API_CONTRACTS)
2. Localizar contrato de teste no JSON

**Resultado esperado:**

- [x] Array `clauses` com `position` em ordem ascendente (1, 2, 3…)

---

### TC-1.4 — API byId retorna ordenado

1. Chamar `GET /contract/byId/{contractId}`

**Resultado esperado:**

- [x] Array `clauses` ordenado por `position` ascendente

---

### TC-1.5 — Cláusula legada sem position

**Pré-condição:** Contrato antigo ou clause com `position: null` no banco (se existir).

1. Gerar PDF desse contrato

**Resultado esperado:**

- [x] PDF gera sem erro
- [x] Cláusulas sem `position` aparecem **por último**

---

## Fase 2 — UX e edição

### TC-2.1 — Lista ordenada visível

1. Abrir formulário de criar/editar contrato

**Resultado esperado:**

- [x] Seção **“Cláusulas selecionadas”** (ou equivalente) mostra ordem real
- [x] Ordem na UI coincide com ordem do PDF após save

---

### TC-2.2 — Reordenação via UI

1. Selecionar A, B, C
2. Usar botões ↑↓ (ou drag) para ordem **B, A, C**
3. Salvar e gerar PDF

**Resultado esperado:**

- [x] PDF: B (I), A (II), C (III)
- [x] Não foi necessário desmarcar/remarcar cláusulas

---

### TC-2.3 — Update não duplica cláusulas

1. Anotar quantidade de registros `clause` vinculados ao contrato (via API ou banco)
2. Editar contrato (alterar só título ou reordenar)
3. Salvar
4. Verificar quantidade novamente

**Resultado esperado:**

- [x] Mesma quantidade de cláusulas (ids estáveis), salvo adição/remoção explícita

---

### TC-2.4 — Adicionar cláusula em contrato existente

1. Editar contrato com A, B
2. Adicionar C pelo final
3. Salvar e gerar PDF

**Resultado esperado:**

- [x] PDF: A (I), B (II), C (III)

---

## Fase 3 — Modelo de dados (se aplicável)

### TC-3.1 — Mesma cláusula, ordens distintas

1. Criar contrato X com biblioteca-cláusula **Shared** na posição 1
2. Criar contrato Y com **Shared** na posição 3 (entre outras)
3. Gerar PDF de X e Y

**Resultado esperado:**

- [ ] X: Shared aparece como I
- [ ] Y: Shared aparece como III (ou posição correta)

---

### TC-3.2 — Migration em staging

1. Executar migration + backfill em ambiente de staging
2. Repetir TC-1.1 e TC-1.2 em contratos existentes

**Resultado esperado:**

- [ ] Ordens preservadas após backfill
- [ ] Nenhum contrato sem cláusulas

---

## Caminho no produto (referência)

| Passo | Tela / rota |
|-------|-------------|
| Gestão de contratos | `OrganizationContracts` — aba Contratos |
| Geração de PDF | Proposta → Contrato PF/PJ → **Gerar Contrato** |
| Arquivos | `pf-contract-form.tsx`, `pj-contract-form.tsx`, `ContractPdfGenerator.tsx` |

---

## Registro de execução

| Data | Fase | Executor | Ambiente | Pass/Fail | Observações |
|------|------|----------|----------|-----------|-------------|
| jul/2026 | 1 | implementação Fase 1 | código | Pass | `clausesOrderedInclude` + sort PDF; validar E2E local antes de deploy |
| jul/2026 | 2 | implementação Fase 2 | código | Pass | lista ordenada + ↑↓ + `clauses[].id` no update; validar E2E local antes de deploy |
| | 3 | | | | |
