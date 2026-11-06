# Análise do problema — ordenação de cláusulas

> **Status (jul/2026):** causa raiz corrigida na **Fase 1** — `orderBy` em todas as leituras do repository de contrato e sort defensivo no PDF. Ver [03-fase-1-correcao-imediata.md](./03-fase-1-correcao-imediata.md).

## Sintoma reportado

O usuário monta um contrato selecionando cláusulas em uma ordem específica (a sequência de cliques define a numeração I, II, III… no PDF). Ao **gerar/imprimir** o contrato a partir de uma proposta, as cláusulas aparecem em ordem diferente da definida — frequentemente percebida como “aleatória”.

## Impacto

- Contratos legais com **numeração romana incorreta** em relação ao conteúdo esperado
- Perda de confiança no sistema de contratos
- Retrabalho manual (reordenar cláusulas no documento fora do sistema)

---

## Comportamento por etapa do fluxo

| Etapa | Comportamento esperado | Comportamento atual | Status |
|-------|------------------------|---------------------|--------|
| Usuário define ordem (cliques em `selectedClauseIds`) | Ordem = sequência de seleção | `position: idx + 1` no submit | OK |
| Backend persiste `position` | Grava 1, 2, 3… na tabela `clause` | `create` e `update` em `contract-in-prisma-repository.ts` | OK |
| Backend retorna cláusulas ordenadas | Array `clauses` sempre por `position ASC` | `clausesOrderedInclude` em create, getById, list e update | **Corrigido (Fase 1)** |
| PDF imprime na ordem correta | I, II, III conforme `position` | Sort por `position` antes do `forEach` em `ContractPdfGenerator.tsx` | **Corrigido (Fase 1)** |

---

## Causa raiz

O campo `position` **é salvo corretamente**, mas **não é aplicado na leitura**:

1. **Backend:** consultas `getById`, `list` e o retorno de `update` usam `include: { clauses: true }` sem `orderBy`. O MySQL devolve linhas em ordem indefinida quando não há `ORDER BY`.

2. **Frontend (PDF):** `generateContractPdf` usa `contract.clauses` na ordem recebida da API, sem ordenar por `position` antes do `forEach`.

O único ponto que ordena hoje é o retorno imediato de `create`:

```typescript
// art56_server_v3/src/repositories/in-prisma/contract-in-prisma-repository.ts (create)
include: {
  clauses: {
    orderBy: { position: "asc" }
  }
}
```

Na impressão, o contrato vem de `venueContracts` (cache do store), carregado via `fetchVenueContracts` → `listContracts` → API **sem ordenação**.

---

## Evidências no código

### Frontend — ordem definida no formulário

```typescript
// eventhub-vista-dashboard/src/components/contract/contracts/contract-form.tsx
const selectedClauses = selectedClauseIds.map((id, idx) => ({
  text: clause.text,
  title: clause.title,
  position: idx + 1,
}));
```

### Backend — leitura sem ordenação

```typescript
// art56_server_v3/src/repositories/in-prisma/contract-in-prisma-repository.ts (getById)
include: { clauses: true }  // sem orderBy
```

### PDF — iteração sem sort

```typescript
// eventhub-vista-dashboard/src/components/proposal/forms/ContractPdfGenerator.tsx
(contract.clauses as Clause[]).forEach((clause, idx) => {
  const romanNum = toRoman(idx + 1);  // numeração segue índice do array, não position
  // ...
});
```

---

## Dívidas secundárias (não bloqueiam Fase 1)

Estes problemas **não causam** a ordem aleatória na impressão, mas agravam manutenção e UX:

| Dívida | Descrição | Onde |
|--------|-----------|------|
| Update sem `id` | Form envia só `text`, `title`, `position` da biblioteca global; backend recria cláusulas a cada save | `contract-form.tsx` → `update` |
| UI não reflete ordem | Lista exibe cláusulas da biblioteca (`filteredClauses`), não na ordem selecionada | `contract-form.tsx` |
| Mapeamento frágil ao editar | Reset usa match por `title + text` em vez de `id` | `contract-form.tsx` `useEffect` |
| `position` na entidade `Clause` | Relação N:N com contrato; mesma cláusula não pode ter ordens distintas em contratos diferentes sem cópia | `schema.prisma`, `_ContractClauses` |

Tratamento previsto nas Fases 2 e 3.

---

## Próximos passos

- Entender o fluxo completo: [02-arquitetura-atual.md](./02-arquitetura-atual.md)
- Corrigir o bug crítico: [03-fase-1-correcao-imediata.md](./03-fase-1-correcao-imediata.md)
