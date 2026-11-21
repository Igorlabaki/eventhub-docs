# Framework Global Map — EventHub

Como o EventHub consome `eventhub-docs/framework_global/` (repo `edge-labs-br/framework_global`, observado em 2026-11-10, commit `09191bc`). O global nao recebe fatos do EventHub; este topic e o lado local do vinculo.

## Estrutura do global

| Pasta | Conteudo | Quando o EventHub usa |
|---|---|---|
| `framework-base/prompts/framework-router-prompt.md` | gatilhos `fw:*` | toda sessao que usar `fw:` |
| `framework-base/prompts/tasking/` | synthesizer, batch, workflow `smart`/`normal`, split e execucao por repo | `fw:intake`, `fw:run`, `fw:split` |
| `framework-base/prompts/spec-driven/` | bootstrap de spec, tasks smart/normal/complete, execucao, split por repo | `fw:spec`, `fw:run` em spec |
| `framework-base/prompts/review/` | review de task-request, spec e entrega | `fw:review` |
| `framework-base/prompts/discovery/` | produto, design, roadmap, solucao, task | `fw:discover`, `fw:roadmap` |
| `framework-base/prompts/bootstrap/` | projeto novo, projeto existente, arquitetura, link de libs, checklist | atualizar este core |
| `framework-base/prompts/management/` | charter, stakeholder, reuniao, decisao, RAID, capacidade, previsao, status, saude | `fw:manage` |
| `framework-base/prompts/security/` | review de seguranca e findings -> task-requests | `fw:review modo: seguranca` |
| `framework-base/prompts/ux-ui/` | request UX/UI, normalizador de design system, handoff para codigo | mudancas visuais amplas |
| `framework-base/prompts/documentation/` | topic e handoff produto -> core | atualizar `topics/` e `product/` |
| `framework-base/templates/` | 48 templates (task-request, spec 00-05, by-repo, board, ADR, plan, roadmap, maps, management) | criar qualquer artefato |
| `framework-base/agents/` | `task-triager`, `task-executor`, `code-reviewer` e quatro papeis AIOps | so em `fw:orchestrate` ou `fw:ops` |
| `framework-base/tools/` | `validate-framework.py`, `management-forecast.py` | `fw:doctor` |
| `framework-libs/<lib>/` | `index`, `default-stack`, `rules/`, `skills/`, `snippets/`, `templates/`, `variants/` | so libs ativas (`project/active-libs.md`) |
| `docs/` | COMO-USAR, COLA-FW, GUIA-DE-USO-NO-CHAT, OPERATING-MATRIX, TOOL-ROUTING, LOOP-ENGINEERING, ORCHESTRATION, METRICAS-E-EVALS, golden-core, setup por ferramenta | duvida de uso do framework |
| `.github/workflows/validate-framework.yml` | CI do proprio global | nao roda nos repos do EventHub |

## Libs ativas e o que ler

| Lib | Arquivos | Leitura dirigida no EventHub |
|---|---|---|
| `node` (77) | rules 00-31, 16 skills, variante fastify | `01_architecture`, `04_api`, `07_error_handling`, `09_validation`, `10_testing`, `17_pagination`, `23/24_authentication*`, `28_payments_integrations`, `31_files_and_document_processing`; skill `creating-core-api-endpoints` |
| `react` (44) | rules 00-11, 10 skills | `03_data_fetching_and_server_state`, `06_navigation_and_url_state`, `07_forms_and_user_interactions`, `04_react_performance`; skills `creating-frontend-pages`, `implementing-query-hooks-and-server-state` |
| `database` (27) | rules 01-11, 5 skills | `04_migrations_and_zero_downtime`, `05_transactions_and_locking`, `03_indexing_and_query_performance`, `09_read_models_and_reporting`; skill `writing-zero-downtime-migrations` |
| `design` (27) | rules 01-10, 5 skills | `01_design_tokens_and_theming`, `05_component_states_and_variants`, `07_data_display_and_dashboards`, `09_accessibility`; skill `designing-empty-loading-error-states` |
| `security` (36) | rules 01-13, 5 skills, checklist | `02_auth_and_access`, `03_secrets_and_keys`, `04_payments_and_financial_integrations`, `07_data_protection_and_privacy`, `09_web_vulnerabilities`; skill `securing-private-file-upload-and-storage` |
| `aws` (72) | rules 00-25, 19 skills | so S3: `04_storage_and_artifacts`, `15_private_s3_uploads_and_media`; skill `implementing-private-s3-uploads` |
| `architecture` (17) | rules 01-06, 3 skills | `02_communication_and_apis`, `05_adr_and_tradeoff_discipline`; skill `writing-architecture-decision-records` |
| `patterns` (17) | rules 01-06, 3 skills | `05_code_smells_and_refactoring` em refatoracao |
| `observability` (16) | rules 01-06, 4 skills | `02_structured_logging`, `05_alerting_and_slos` quando a fase 3 do roadmap abrir |

## Diferencas entre o default global e o EventHub

- `node`: default e Drizzle; o EventHub usa Prisma 5 com `relationMode = "prisma"` no PlanetScale. Skills `*-drizzle` valem pelo raciocinio, nao pelo codigo.
- `node`: o EventHub e Express 4 sem handler global de erro; nao migrar para Fastify como efeito lateral.
- `react`: o default favorece React Query como dono do server state; o EventHub tem 30 stores Zustand ativas. Seguir o padrao do dominio tocado ate decisao registrada.
- `aws`: so S3; compute e deploy estao na Vercel.
- `database`: backups, staging e deploy requests seguem `project/planetscale.md`, nao o default generico.

## Libs nao ativas

`java`, `python`, `k8s`, `react-native`, `llm`, `agents`, `mcp`, `ml`, `aiops` e `github` nao fazem parte do runtime. Ferramentas de agente do PlanetScale (CLI `pscale`, MCP e skills pessoais) sao apoio de operacao, nao runtime.

## Referencias de caminho

Artefatos citam `.cursor/framework_global/`; no disco o caminho e `eventhub-docs/framework_global/`. Ver `project/workspace-map.md`.
