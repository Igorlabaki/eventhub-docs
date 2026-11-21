# Getting Started

## Antes de alterar codigo

1. leia `project/agent-entrypoint.md`;
2. identifique o `repo-id` afetado em `project/project-catalog-entry.md`;
3. abra o map da frente (`project/backend-map.md`, `project/api-endpoints.md`, `project/frontend-map.md`), o topic da area e somente as libs ativas necessarias;
4. confirme se existe task-request ou spec no `BOARD.md`;
5. para auth, permissao, PII, pagamento, upload ou segredo, inclua `security`;
6. para mudanca multi-repo, use `fw:split` depois de criar o artefato canonico.

## Comandos basicos

Backend (`art56_server_v3/`): `npm install`, `npx prisma generate`, `npm run dev`, `npm test -- --run`.

Frontend (`eventhub-vista-dashboard/`): `npm install`, `npm run dev`, `npm run build`, `npm run lint`, `npm test`.

O backend local usa porta 3000 por padrao; o frontend Vite usa 8080. Os comandos dependem de `.env` local valido. Nao copie valores de ambiente para artefatos do framework.

## Validacao do framework

```powershell
py -3 framework_global/framework-base/tools/validate-framework.py --core .cursor/framework_core --global-root framework_global --strict
```
