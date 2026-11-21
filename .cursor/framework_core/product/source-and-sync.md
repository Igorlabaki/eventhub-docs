# Product Source and Sync

## Fonte canonica operacional

- codigo: `art56_server_v3/` e `eventhub-vista-dashboard/`;
- documentacao detalhada: `eventhub-docs/docs/`;
- slug: `eventhub`;
- owner de produto e owner tecnico: nao documentados, exigem confirmacao.

## Papel do snapshot

`product/` oferece contexto curto para tarefas e specs. Nao duplica contratos extensos, backlog historico nem analises de implementacao existentes em `docs/`. Inventarios tecnicos completos ficam em `project/` (backend, frontend, endpoints, workspace).

## Triggers de sincronizacao

Atualizar este snapshot quando mudar regra de negocio, perfil/permissao, jornada, fluxo, design system, dominio, schema ou integracao. Atualizar tambem o doc detalhado citado pelo topic afetado e o map de `project/` correspondente.

## Historico de sincronizacao

| Data | Nome | Origem | Arquivos |
|---|---|---|---|
| 2026-11-02 | bootstrap de projeto existente | codigo, manifests, Prisma schema e `docs/` | `product/`, `project/`, `topics/`, `flows/`, roadmap inicial |
| 2026-11-10 | mapeamento completo do workspace | leitura integral dos routers, use cases, schema, rotas, paginas, services, stores, componentes, `docs/` e `framework_global/` | novos `project/workspace-map.md`, `backend-map.md`, `api-endpoints.md`; `frontend-map.md` reescrito; novos topics de permissoes, precificacao, relatorios, paginas publicas, docs legados e framework global; novos flows de pedido publico e operacao do evento; `product/02`, `05`, `06`, `07`, `08`, `09` atualizados |

## Pontos em aberto

- confirmar owners, fonte de produto fora do repositorio e prioridades atuais;
- confirmar quais itens do backlog legado ja foram resolvidos;
- esclarecer as divergencias entre specs e codigo registradas em `topics/delivery-and-known-gaps.md` (DocuSign, midia de caracteristica).
