# Atualizações em documentos externos

Checklist de documentação **fora** desta pasta que deve ser atualizada ao concluir cada fase. Seguir [GUIA_DE_IMPLEMENTACAO.md](../../processo/GUIA_DE_IMPLEMENTACAO.md).

---

## Ao criar esta pasta (documentação)

| Documento | Ação |
|-----------|------|
| [docs/INDEX.md](../../INDEX.md) | Adicionar entrada em **§14 Planos de feature / integração** |
| Este README | Manter como índice da iniciativa |

---

## Após Fase 1 — Correção imediata

| Documento | Ação | Status |
|-----------|------|--------|
| [KNOWN_LIMITATIONS.md](../../estado/integracao/KNOWN_LIMITATIONS.md) | Remover ou marcar como resolvida a limitação “cláusulas em ordem aleatória no PDF” (adicionar entrada se ainda não existir) | Concluído |
| [API_CONTRACTS.md](../../referencias/API_CONTRACTS.md) | Nas seções Contract (list, byId, update, create): indicar que `clauses` retorna ordenado por `position` ascendente | Concluído |
| [REGRAS_DE_NEGOCIO.md](../../referencias/REGRAS_DE_NEGOCIO.md) | Adicionar regra: *A ordem das cláusulas no contrato impresso segue o campo `position` em ordem crescente.* | Concluído |
| [BACKEND_ANALISE_ATUAL.md](../../estado/backend/BACKEND_ANALISE_ATUAL.md) | Nota breve: repository de contrato ordena cláusulas em todas as leituras | Concluído |

### Texto sugerido — REGRAS_DE_NEGOCIO.md

```markdown
### Contratos — ordem das cláusulas

- Ao montar um contrato, a ordem de seleção das cláusulas define `position` (1, 2, 3…).
- A API deve retornar `clauses` ordenadas por `position` ascendente.
- O PDF do contrato numera cláusulas (I, II, III…) nessa mesma ordem.
- Cláusulas sem `position` aparecem por último.
```

### Texto sugerido — API_CONTRACTS.md (nota em Contract)

```markdown
**Ordenação:** o array `clauses` nas respostas de create, update, list e byId
é ordenado por `position` ascendente. Cláusulas com `position` nulo aparecem por último.
```

---

## Após Fase 2 — UX e edição

| Documento | Ação | Status |
|-----------|------|--------|
| [FRONTEND_ANALISE_ATUAL.md](../../estado/frontend/FRONTEND_ANALISE_ATUAL.md) | Descrever nova UX: lista ordenada + reordenação em `contract-form` | Concluído |
| [FRONTEND_TODO_PRIORIDADE.md](../../estado/frontend/FRONTEND_TODO_PRIORIDADE.md) | Remover item relacionado se existir | N/A (sem item específico) |
| [KNOWN_LIMITATIONS.md](../../estado/integracao/KNOWN_LIMITATIONS.md) | Remover limitações de update duplicando cláusulas / UI confusa | Concluído |
| [API_CONTRACTS.md](../../referencias/API_CONTRACTS.md) | Confirmar que update aceita `clauses[].id` para cláusulas existentes do contrato | Concluído |

---

## Após Fase 3 — Modelo de dados (se implementada)

| Documento | Ação |
|-----------|------|
| [database.dbml](../../referencias/database.dbml) | Adicionar tabela `contract_clause` (ou equivalente); atualizar relações |
| [DATA_MODEL_EXPLAINED.md](../../referencias/DATA_MODEL_EXPLAINED.md) | Explicar ordem por par contrato↔cláusula |
| [DOMAIN_MODEL.md](../../referencias/DOMAIN_MODEL.md) | Atualizar glossário `Clause`, `Contract`, possível `ContractClause` |
| [MIGRATION_STRATEGY.md](../../processo/MIGRATION_STRATEGY.md) | Referenciar migration desta iniciativa se servir de exemplo |
| [API_CONTRACTS.md](../../referencias/API_CONTRACTS.md) | Atualizar payloads create/update de Contract |
| [BACKEND_ANALISE_ATUAL.md](../../estado/backend/BACKEND_ANALISE_ATUAL.md) | Refletir novo repository / model |

---

## Checklist rápido por PR

Antes de mergear cada PR de implementação:

- [x] Código implementado conforme doc da fase (Fase 1)
- [x] [06-checklist-testes.md](./06-checklist-testes.md) executado (seção Fase 1)
- [x] Documentos externos da fase atualizados (Fase 1)
- [x] [INDEX.md](../../INDEX.md) continua apontando para esta pasta (status Fase 1)
- [x] Código implementado conforme doc da fase (Fase 2)
- [x] [06-checklist-testes.md](./06-checklist-testes.md) executado (seção Fase 2)
- [x] Documentos externos da fase atualizados (Fase 2)

---

## Não duplicar

- Detalhes de endpoints permanecem em [API_CONTRACTS.md](../../referencias/API_CONTRACTS.md) — aqui só o **delta** (ex.: garantia de ordenação)
- Esquema completo permanece em [database.dbml](../../referencias/database.dbml)
- Protocolo geral permanece em [GUIA_DE_IMPLEMENTACAO.md](../../processo/GUIA_DE_IMPLEMENTACAO.md)
