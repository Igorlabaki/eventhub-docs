# Fase 1 — Correção imediata

**Status:** Implementado (jul/2026)

**Objetivo:** PDF e API sempre devolvem cláusulas em ordem crescente de `position`.

**Escopo:** backend + defesa no frontend. Sem migration, sem mudança de schema.

**Esforço estimado:** 1–2 horas.

**Dependências:** nenhuma.

---

## Problema que esta fase resolve

O campo `position` já é gravado; falta ordenar na **leitura** (API) e na **impressão** (PDF). Ver [01-analise-problema.md](./01-analise-problema.md).

---

## Escopo backend

**Arquivo:** `art56_server_v3/src/repositories/in-prisma/contract-in-prisma-repository.ts`

Adicionar `orderBy: { position: 'asc' }` em todos os `include: { clauses }`:

| Método | Linha aprox. | Situação atual |
|--------|--------------|----------------|
| `create` | ~32–37 | Usa `clausesOrderedInclude` |
| `getById` | ~55–57 | Corrigido |
| `update` (retorno) | ~146–149 | Corrigido |
| `list` | ~171–172 | Corrigido |

### Recomendação: constante reutilizável

Extrair para evitar regressão em futuros métodos:

```typescript
const clausesOrderedInclude = {
  orderBy: [
    { position: "asc" as const },
    { createdAt: "asc" as const },
  ],
};

// Uso:
include: { clauses: clausesOrderedInclude }
```

### Comportamento com `position: null`

Cláusulas legadas sem `position` devem aparecer **por último**. O Prisma/MySQL trata `NULL` como menor ou maior dependendo do SGBD; documentar e validar:

- MySQL: `ORDER BY position ASC` coloca `NULL` primeiro por padrão
- Se necessário, usar ordenação secundária: `orderBy: [{ position: 'asc' }, { createdAt: 'asc' }]`

Validar em ambiente local e ajustar se cláusulas nulas aparecerem no início do PDF.

---

## Escopo frontend (defesa em profundidade)

**Arquivo:** `eventhub-vista-dashboard/src/components/proposal/forms/ContractPdfGenerator.tsx`

Antes do `forEach` das cláusulas (~linha 143):

```typescript
const sortedClauses = [...contract.clauses].sort(
  (a, b) => (a.position ?? Number.MAX_SAFE_INTEGER) - (b.position ?? Number.MAX_SAFE_INTEGER)
);

sortedClauses.forEach((clause, idx) => {
  const romanNum = toRoman(idx + 1);
  // ... resto inalterado
});
```

Usar `Number.MAX_SAFE_INTEGER` para `null`/`undefined` garante que cláusulas sem posição fiquem por último no PDF.

**Opcional (consistência):** aplicar o mesmo sort ao exibir contratos em outros componentes que iteram `contract.clauses`. Não é obrigatório se a API já ordenar.

---

## Fora de escopo (Fase 1)

- Alteração de schema ou migration
- UI de reordenação
- Envio de `id` no update
- Testes automatizados (apenas checklist manual em [06-checklist-testes.md](./06-checklist-testes.md))

---

## Critérios de aceite

- [x] Contrato com 3+ cláusulas em posições 1, 2, 3 imprime **I, II, III** na ordem definida pelo usuário
- [x] Após editar ordem para C→A→B e salvar, o PDF reflete a nova ordem
- [x] `GET /contract/list` retorna `clauses[]` com `position` em ordem ascendente
- [x] `GET /contract/byId/:id` idem
- [x] Resposta de `PUT /contract/update` idem
- [x] Cláusulas com `position: null` não quebram o PDF (aparecem por último)

---

## Riscos

| Risco | Mitigação |
|-------|-----------|
| Breaking change na API | Nenhum — apenas ordem estável do array; mesmos dados |
| Regressão em novo método do repository | Usar constante `clausesOrderedInclude` |
| NULLS FIRST no MySQL | Validar com checklist; ajustar `orderBy` se necessário |

---

## Documentação a atualizar após implementação

Ver [07-atualizacoes-docs-externos.md](./07-atualizacoes-docs-externos.md) — seção Fase 1.

---

## Próximo passo

Validar com [06-checklist-testes.md](./06-checklist-testes.md) (Fase 1), depois [04-fase-2-ux-edicao.md](./04-fase-2-ux-edicao.md).
