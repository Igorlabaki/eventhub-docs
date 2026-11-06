# Plano de performance — EventHub

**Objetivo:** Onde falta paginação e impacto; sugestões de índices; onde usar transaction; upload/Sharp/S3: recomendações (fila/job se aplicável). Baseado no repositório.

**Fontes no repositório:** `art56_server_v3/src/repositories/in-prisma/`, `art56_server_v3/src/use-cases/`, `art56_server_v3/prisma/schema.prisma`, [BACKEND_ANALISE_ATUAL.md](./BACKEND_ANALISE_ATUAL.md), [DATA_MODEL_EXPLAINED.md](./DATA_MODEL_EXPLAINED.md).

---

## 1. Paginação

### Onde falta e impacto

| Recurso | Onde | Impacto |
|---------|------|---------|
| Venue | list-venue, list-permitted-venues | Listas grandes por organização podem travar ou consumir muita memória |
| Proposal | list-proposal | Idem por venue |
| User | list-user | Idem por organização |
| Organization | list-organization | Idem para usuário com muitas orgs |
| Payment, Document, DateEvent, Notification, etc. | list em cada repositório | Idem conforme volume |

**Padrão sugerido:** Parâmetros opcionais `page` e `limit` (ou `take` e `skip`); default sem paginação = comportamento atual (retornar todos) para compatibilidade. Resposta: array + opcionalmente `total` ou `hasMore` quando paginação for solicitada.

**Arquivos a alterar:** Repositórios em `repositories/in-prisma/` (list-venue, list-proposal, etc.); schemas Zod para query (page, limit); controllers que repassam parâmetros.

---

## 2. Índices

- **Já existentes (Prisma):** venueId, organizationId, proposalId, userId, etc. conforme [database.dbml](./database.dbml) e schema.prisma.
- **Sugestões (apenas se houver gargalo medido):**
  - Proposal: filtros por período (startDate, endDate) em listagens → índice composto (venueId, startDate) ou (venueId, endDate).
  - DateEvent: (venueId, startDate) se listagens por calendário forem pesadas.
  - Nenhuma alteração de índice sem medição em produção (explain, slow query log).

---

## 3. Onde usar transaction

| Fluxo | Situação atual | Recomendação |
|-------|----------------|--------------|
| Create venue | Já usa `$transaction` no repositório | Manter |
| Create proposal (per person/day) | Múltiplas escritas (proposal, persons, dateEvents, proposalServices, etc.) sem transaction | Envolver em `prisma.$transaction([...])`; ordem: proposta → pessoas e demais dependentes |
| Create payment + document | Possível criação em sequência | Avaliar se mesmo use case; se sim, transaction |
| Update proposal + dateEvents | Várias escritas | Idem, transaction quando várias tabelas forem alteradas em um único caso de uso |

**Arquivos:** Use cases em `use-cases/proposal/create-proposal-per-person` e `create-proposal-per-day` (e equivalentes); injetar prisma e chamar `prisma.$transaction` em torno das chamadas de repositório.

---

## 4. Upload / Sharp / S3

### Situação atual

- Multer em memória (`memoryStorage`); arquivo processado no controller/use case (Sharp para imagens, PutObjectCommand para S3); resposta só após conclusão.
- Body limit 50mb; sem limite por arquivo documentado.

### Recomendações

- **Limite por arquivo:** Configurar Multer `limits: { fileSize: X }` (ex.: 10mb por arquivo) para evitar uploads gigantes na mesma request.
- **Sharp:** Já em uso; processamento síncrono na request. Para muitos uploads concorrentes, considerar fila (BullMQ, Cloud Tasks) que processe e envie ao S3 em background; resposta imediata com “processando” e webhook ou polling para status. **Não confirmado no repositório** se há fila; implementação seria nova.
- **S3:** Upload direto na request é aceitável para volumes moderados; em alta escala, presigned URL (cliente sobe direto no S3) reduz carga no BE. Não alterar sem necessidade.
- **Fila/job:** Opcional para envio de e-mail e notificações (retry, desacoplamento); não confirmado no repositório.

---

## 5. Resumo de ações priorizadas

1. **Paginação:** Introduzir em list de venue, proposal, organization (parâmetros opcionais; manter comportamento atual quando não informados).
2. **Transação:** Envolver criação de proposta (e fluxos relacionados com múltiplas escritas) em `prisma.$transaction`.
3. **Upload:** Limite de tamanho por arquivo no Multer; manter Sharp/S3 na request até haver métrica de lentidão.
4. **Índices:** Só após medir queries lentas em produção.

---

## Decisões e recomendações

- Não fazer otimização prematura; medir (logs de latência, slow query) antes de adicionar índices ou mover upload para fila.
- Paginação e transações são melhorias de consistência e escalabilidade que podem ser feitas de forma incremental (ver [MIGRATION_STRATEGY.md](./MIGRATION_STRATEGY.md) e [ROADMAP_TECHNICAL.md](./ROADMAP_TECHNICAL.md)).
