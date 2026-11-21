# Legacy Docs Map — EventHub

Mapa de `eventhub-docs/docs/` (43 arquivos). Escritos a partir de marco/2025; varios fatos ja mudaram. Usar como fonte detalhada e historica, sempre confirmando no codigo antes de agir. O core resume e roteia; nao apagar nem duplicar estes docs.

## Indices

| Arquivo | Conteudo | Confiabilidade |
|---|---|---|
| `docs/README.md` | indice curto, por onde comecar, mapa de pastas do codigo | estrutural, estavel |
| `docs/INDEX.md` | regras de ouro, onde fica o que por feature, politica de atualizacao obrigatoria, gaps | politica ainda valida; mapa por feature anterior a 2026-11 |

## `referencias/` — consulta

| Arquivo | Conteudo | Quando ler |
|---|---|---|
| `API_CONTRACTS.md` (81 KB) | request/response por recurso, gerado do codigo | antes de mudar payload; conferir com `project/api-endpoints.md` |
| `API_VERSIONING_STRATEGY.md` | opcoes `/v1` e header, depreciacao | so se versionamento entrar em spec |
| `ARCHITECTURE_OVERVIEW.md` | componentes, diagrama, fluxos, modulos | onboarding |
| `AUTHORIZATION_MODEL.md` | JWT/refresh/session, permissoes, tabela acao -> quem pode, lacunas | qualquer mudanca de auth |
| `DATA_MODEL_EXPLAINED.md` | dominio do banco, ER, campos sensiveis, integridade, indices | schema; nao cobre modelos de 2026-11 |
| `database.dbml` | DBML derivado do Prisma | visualizar relacoes; desatualizado frente a `schema.prisma` |
| `DOMAIN_MODEL.md` | glossario, ciclo implicito de Proposal, invariantes, dependencias | regra de dominio |
| `REGRAS_DE_NEGOCIO.md` | regras por organizacao, usuario, venue, proposal | regra de negocio antiga; core em `product/02-business-rules.md` |

## `estado/` — diagnosticos

| Arquivo | Conteudo |
|---|---|
| `backend/BACKEND_ANALISE_ATUAL.md` | estrutura, rotas, regras, dados, riscos do backend |
| `frontend/FRONTEND_ANALISE_ATUAL.md` | rotas, componentizacao, estado, cache do frontend |
| `frontend/FRONTEND_TODO_PRIORIDADE.md` | TODO do frontend em prioridades P1 a P4 |
| `integracao/INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md` | env, base URL, chamada FE -> BE, auth ponta a ponta, DTOs |
| `integracao/KNOWN_LIMITATIONS.md` | limitacoes por camada, bugs provaveis, workarounds |
| `integracao/TODO_MASTER.md` | backlog consolidado Now/Next/Later |

Os mapas atuais em `project/backend-map.md`, `project/frontend-map.md` e `project/api-endpoints.md` substituem estes diagnosticos como primeira leitura.

## `planos/` — propostas e planos de feature

| Arquivo ou pasta | Conteudo | Situacao |
|---|---|---|
| `PRODUCTION_SETUP.md` | rodar local, envs, deploy Vercel, migrations, smoke test | runbook mais proximo do real; migrations agora por deploy request (`project/planetscale.md`) |
| `ROADMAP_TECHNICAL.md` | roadmap 30/60/90 dias | historico; direcao atual em `roadmaps/eventhub-evolucao-tecnica.md` |
| `OBSERVABILITY_PLAN.md` | logs, metricas, alertas, health, pontos de instrumentacao | nao executado |
| `PERFORMANCE_PLAN.md` | paginacao, indices, transacoes, upload/Sharp/S3 | parcial (listas de proposta, contato e notificacao ja paginam) |
| `PLANO_INTEGRACAO_DOCUSIGN.md` | fluxo, modelo, endpoints e design DocuSign | spec `2026-11-05-assinatura-contrato-docusign` existe, codigo ausente nos repos |
| `contrato-clausulas/` (8) | ordenacao de clausulas no contrato em 3 fases, checklist de testes | confirmar no codigo o que foi aplicado |
| `horario-wall-clock/` (11) | convencao wall-clock normativa, 4 fases, inventario e testes | executado pela spec `2026-11-02-horario-wall-clock`; `03-convencao-wall-clock.md` e a norma |

## `processo/`

| Arquivo | Conteudo |
|---|---|
| `GUIA_DE_IMPLEMENTACAO.md` | guia oficial de implementacao do time |
| `MIGRATION_STRATEGY.md` | regras de ouro, versionamento, envelope v1/v2, banco, rollback |
| `SECURITY_HARDENING.md` | threat model, riscos priorizados, mitigacoes, plano de 2 sprints |

## Raiz

`INTEGRATIONS_GOOGLE_CALENDAR.md`: setup no Google Cloud, variaveis, scopes, fluxo do usuario e permissoes internas. Fonte viva da integracao.

## Regra de uso

- topic ou map do core cita o doc legado quando ele aprofunda o assunto;
- mudanca que torna um doc legado falso atualiza o doc ou registra a divergencia no topic da area (`docs/INDEX.md` exige isso);
- item de backlog legado so vira trabalho depois de confirmado no codigo e convertido por `fw:intake` ou `fw:spec`.
