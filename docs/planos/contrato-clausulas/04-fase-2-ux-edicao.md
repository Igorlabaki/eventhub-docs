# Fase 2 — UX e edição

**Status:** Implementado (jul/2026)

**Objetivo:** tornar a ordem das cláusulas **visível**, **editável** e **persistente** sem recriar registros a cada save.

**Esforço estimado:** 0,5–1 dia.

**Dependências:** Fase 1 concluída ([03-fase-1-correcao-imediata.md](./03-fase-1-correcao-imediata.md)).

---

## Problemas que esta fase resolve

| Problema | Impacto |
|----------|---------|
| UI lista cláusulas da biblioteca, não na ordem selecionada | Usuário não vê a ordem real antes de imprimir |
| Sem reordenação após seleção | Só dá para mudar ordem desmarcando e clicando de novo |
| Update não envia `id` das cláusulas do contrato | Backend desconecta todas e **cria cópias novas** a cada save |
| Reset ao editar usa `title + text` | Match frágil se houver cláusulas com texto igual |

---

## Tarefa 1 — Lista de cláusulas selecionadas (ordem real)

**Arquivo:** `eventhub-vista-dashboard/src/components/contract/contracts/contract-form.tsx`

Adicionar seção **“Cláusulas selecionadas (ordem do contrato)”** acima ou abaixo da biblioteca:

- Renderizar apenas `selectedClauseIds` **na ordem do array**
- Para cada item: título, badge com posição (1, 2, 3…), botão remover
- Biblioteca (`filteredClauses`) permanece para adicionar novas cláusulas

Exemplo de derivação:

```typescript
const selectedClausesInOrder = selectedClauseIds
  .map((id) => clauses.find((c) => c.id === id))
  .filter(Boolean) as Clause[];
```

Em modo edição, mapear a partir de `initialData.clauses` ordenadas por `position`, usando **ids das cláusulas do contrato** quando disponíveis.

---

## Tarefa 2 — Reordenação

Permitir alterar `selectedClauseIds` sem desmarcar/remarcar.

**Opção MVP (recomendada):** botões ↑ / ↓ por item na lista ordenada.

```typescript
const moveClause = (index: number, direction: "up" | "down") => {
  setSelectedClauseIds((prev) => {
    const next = [...prev];
    const target = direction === "up" ? index - 1 : index + 1;
    if (target < 0 || target >= next.length) return prev;
    [next[index], next[target]] = [next[target], next[index]];
    return next;
  });
};
```

**Opção avançada:** drag-and-drop — verificar se o projeto já usa `@dnd-kit` ou similar; se não, botões são suficientes.

Ao reordenar, o `handleSubmit` continua derivando `position: idx + 1` do array — comportamento correto.

---

## Tarefa 3 — Persistência correta no update

### Frontend

**Arquivo:** `contract-form.tsx` — `handleSubmit`

Em modo edição (`isEditing && initialData?.clauses`):

- Manter mapa `contractClauseIdByLibraryId` ou usar diretamente ids das cláusulas **do contrato** (`initialData.clauses`)
- Payload de update deve incluir `id` da cláusula vinculada ao contrato:

```typescript
type ContractClausePayload = {
  text: string;
  title: string;
  position: number;
  id?: string;  // id da Clause do contrato, não da biblioteca
};
```

**Arquivo:** `contract-form.tsx` — `useEffect` de reset

Substituir match por `title + text`:

```typescript
// Antes (frágil):
const found = clauses.find(c => c.title === clause.title && c.text === clause.text);

// Depois (edição):
setSelectedClauseIds(
  (initialData?.clauses || [])
    .sort((a, b) => (a.position ?? 0) - (b.position ?? 0))
    .map((clause) => clause.id)
    .filter(Boolean)
);
```

Nota: em edição, `selectedClauseIds` pode passar a referenciar ids das **cópias do contrato**, não da biblioteca. Ajustar `handleClauseClick` e a lista da biblioteca para refletir isso (ex.: cláusula da biblioteca adicionada cria nova entrada no submit sem `id`).

### Backend

**Arquivo:** `contract-in-prisma-repository.ts` — `update`

A lógica já suporta `clause.id` opcional no schema Zod. Com ids corretos:

- Cláusulas existentes são **atualizadas** (`position`, `text`, `title`)
- Apenas cláusulas removidas são `disconnect`
- Novas cláusulas (sem `id`) são `create` + `connect`

Validar que `position` é sempre atualizado no branch `update` existente.

---

## Tarefa 4 — Limpeza de órfãos (opcional)

Hoje, cláusulas `disconnect`adas permanecem no banco sem contrato.

**Opções:**

| Estratégia | Prós | Contras |
|----------|------|---------|
| Manter como está | Sem risco de apagar dado errado | Acúmulo de linhas órfãs |
| `delete` em vez de `disconnect` | Banco limpo | Risco se cláusula compartilhada (raro hoje) |
| Job periódico | Seguro, assíncrono | Mais infra |

Documentar decisão; implementação pode ficar fora desta fase.

---

## Fora de escopo (Fase 2)

- Migration de schema (Fase 3)
- Reutilização da mesma cláusula da biblioteca com ordens distintas em contratos diferentes
- Testes E2E automatizados

---

## Critérios de aceite

- [x] Usuário vê lista **“Cláusulas selecionadas”** na ordem exata que será impressa
- [x] Botões subir/descer (ou DnD) alteram ordem e refletem no PDF após save
- [x] Editar contrato existente **não duplica** cláusulas no banco (mesmo count de ids por contrato)
- [x] Badge numérico na lista ordenada corresponde à posição no PDF (I, II, III…)
- [x] Adicionar cláusula da biblioteca ao contrato existente funciona e recebe próxima `position`

---

## Riscos

| Risco | Mitigação |
|-------|-----------|
| Confusão entre id da biblioteca vs id da cópia do contrato | Separar visualmente “biblioteca” vs “selecionadas”; documentar no código |
| Contratos antigos com cláusulas órfãs | Fase 1 já ordena leitura; Fase 2 melhora edições futuras |

---

## Documentação a atualizar após implementação

Ver [07-atualizacoes-docs-externos.md](./07-atualizacoes-docs-externos.md) — seção Fase 2.

---

## Próximo passo

Validar com [06-checklist-testes.md](./06-checklist-testes.md) (Fase 2). Avaliar [05-fase-3-modelo-dados.md](./05-fase-3-modelo-dados.md) se houver demanda de reutilização.
