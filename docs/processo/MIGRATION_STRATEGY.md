# Estratégia de migração — EventHub

**Objetivo:** Regras de ouro para evolução do sistema em produção (migrations aditivas, backfill em batches, compatibilidade); versionamento de endpoints; mudanças de contrato (envelope v1/v2, headers/query); mudanças no banco; checklists de rollback e observabilidade mínima.

**Fontes no repositório:** `art56_server_v3/prisma/`, `art56_server_v3/src/router/`, [DATA_MODEL_EXPLAINED.md](./DATA_MODEL_EXPLAINED.md), [BACKEND_ANALISE_ATUAL.md](./BACKEND_ANALISE_ATUAL.md), [INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md](./INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md).

---

## 1. Regras de ouro

- **Migrations aditivas primeiro:** Novas colunas como nullable ou com default; nunca remover coluna nem alterar tipo em uma única migração que quebre leitura/escrita atual.
- **Backfill em batches:** Se nova coluna obrigatória for necessária, em fases: (1) adicionar coluna nullable; (2) backfill em batches (job ou script com LIMIT); (3) tornar NOT NULL e/ou remover default se aplicável; (4) remover código que escreve no campo antigo só após FE/BE desligados do antigo.
- **Compatibilidade:** Manter antigo comportamento até o novo estar em uso (ex.: manter rota antiga ou mesmo path com comportamento novo controlado por header/query).
- **Não perder dados:** Nunca DROP TABLE ou DROP COLUMN sem backup e sem período de depreciação; não alterar PK/FK em produção sem plano de migração de dados.

---

## 2. Versionamento de endpoints (sem big bang)

- **Opção A — Prefixo de path:** Introduzir `/v1/` (ex.: `/v1/venue/list`) e manter rotas atuais como legado; novo código consome `/v1/`; após período, deprecar sem prefixo.
- **Opção B — Header:** `X-Api-Version: 2` para opt-in ao novo contrato; sem header = v1. Permite mesma URL com comportamentos diferentes.
- **Recomendação:** Para EventHub, sem versionamento hoje; ao introduzir, preferir **header** para não duplicar todas as rotas de uma vez. Documentar em [API_VERSIONING_STRATEGY.md](./API_VERSIONING_STRATEGY.md).

---

## 3. Mudanças de contrato (envelope v1 vs v2, headers/query)

- **Resposta de sucesso:** Hoje mista (direto, `{ data }`, `{ success, message, data, count, type }`). Padronizar em uma única forma (ex.: sempre `{ data }`) em **novos** endpoints; nos antigos, manter e opcionalmente duplicar resposta com header `X-Api-Version: 2` ou query `?envelope=2`.
- **Erro:** Manter `{ title, message }`; adicionar `code` opcional sem quebrar clientes.
- **Query/body:** Novos parâmetros opcionais são seguros; remover ou tornar obrigatório parâmetro existente = breaking. Fazer em nova versão (header/query) ou em novo path.
- **Depreciação:** Header `Deprecation: true` ou `X-Deprecated: 2025-06-01`; logar uso de rotas depreciadas para métrica.

---

## 4. Mudanças no banco

| Tipo de mudança | Estratégia |
|-----------------|------------|
| Nova coluna nullable | Migration direta; código passa a preencher quando disponível. |
| Nova coluna obrigatória | Coluna nullable + default → backfill → NOT NULL em migração posterior (se necessário). |
| Renomear coluna | Nova coluna + backfill + código lê/grava na nova → migração que remove antiga (após deploy sem uso da antiga). |
| Remover coluna | Marcar como não usada no código; após período, migração que remove (com backup). |
| Índice novo | Criar em horário de baixo tráfego; monitorar lentidão em writes. |
| relationMode / FKs | Alterar relationMode e adicionar FKs exige migração cuidadosa e possível downtime; planejamento separado. |

**Shadow traffic:** Não confirmado no repositório; opcionalmente, em mudanças críticas, duplicar escrita em novo formato em paralelo e comparar antes de trocar leitura.

---

## 5. Checklist de rollback

- [ ] Migrations: ter script ou passo a passo para reverter última migration (ex.: migration down ou restore de backup).
- [ ] Deploy BE: possibilidade de reverter para commit anterior no Vercel; variáveis de ambiente não alteradas em rollback.
- [ ] Deploy FE: reverter build anterior; garantir que FE antigo continua funcionando com BE atual (não introduzir breaking no BE antes do FE estar pronto).
- [ ] Banco: backup antes de migrate deploy; testar restore em ambiente de staging.
- [ ] Feature flag: se houver, desligar feature problemática sem novo deploy.

---

## 6. Observabilidade mínima para migrações

- [ ] Log ou métrica de uso de rotas depreciadas (path ou header).
- [ ] Após backfill, query de verificação (COUNT onde nova coluna preenchida vs total).
- [ ] Health check e latência pós-deploy (ver [OBSERVABILITY_PLAN.md](./OBSERVABILITY_PLAN.md)).

---

## Decisões e recomendações

- Todas as mudanças de contrato ou banco que quebrem cliente devem ter fase de compatibilidade (nova versão ou período de convivência).
- Documentar no próprio repositório o plano de depreciação quando uma rota ou campo for descontinuado.
- Revisar este documento ao introduzir versionamento explícito de API (ex.: /v1).
