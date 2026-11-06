# TODO Frontend EventHub — Ordem de prioridade

**Base:** [FRONTEND_ANALISE_ATUAL.md](./FRONTEND_ANALISE_ATUAL.md)  
**Escopo:** `eventhub-vista-dashboard/`  
**Objetivo:** Lista de tarefas ordenada por prioridade para correções e melhorias.

---

## Prioridade 1 — Crítico (fazer primeiro)

| # | Tarefa | Onde | Ação |
|---|--------|------|------|
| 1 | Corrigir typo `organizattionId` | `store/userOrganizationPermissionStore.ts`, `components/ProtectedRoute.tsx` | Renomear para `organizationId` em ambos; garantir que o service continue recebendo `organizationId`. |
| 2 | Corrigir assinatura do hook `useGetVenuesList` | `hooks/venue/queries/list.ts` | Ajustar para receber `organizationId` e `userId` e chamar `venueService.getAllVenues({ organizationId, userId })`. |
| 3 | Centralizar rotas públicas | Novo: `src/constants/publicRoutes.ts`; usar em `lib/axios.ts` e `hooks/useBootstrapUser.ts` | Criar constante única; importar nos dois arquivos para evitar inconsistência (redirect vs token). |

---

## Prioridade 2 — Importante (próximas sprints)

| # | Tarefa | Onde | Ação |
|---|--------|------|------|
| 4 | Unificar fonte de verdade (Zustand vs React Query) | Stores (ex.: venueStore) e hooks (useGetVenuesList, useGetVenueDashBoardData) | Definir convenção: React Query como fonte por recurso; store só para selectedVenue quando necessário; migrar um fluxo piloto (ex.: lista de venues). |
| 5 | Simplificar `ProtectedRoute` | `components/ProtectedRoute.tsx` | Extrair lógica de preload para hook (ex.: `usePreloadRouteContext`); deixar ProtectedRoute só com auth + permissão + loading/erro/children. |
| 6 | Reduzir bundle e complexidade do App | `App.tsx` | Lazy load de páginas com `React.lazy` + `Suspense`; opcionalmente dividir rotas em arquivos (ex.: `routes/organization.tsx`, `routes/venue.tsx`). |
| 7 | Reforçar TypeScript | `tsconfig.app.json` | Habilitar `strict: true` (ou no mínimo `strictNullChecks` e `noImplicitAny`) em etapas; corrigir lib, store e services primeiro. |
| 8 | Documentar variáveis de ambiente | Raiz do app | Criar `.env.example` com `VITE_API_URL`, `VITE_GOOGLE_CLIENT_ID`, etc., sem valores sensíveis. |

---

## Prioridade 3 — Melhorias (quando der)

| # | Tarefa | Onde | Ação |
|---|--------|------|------|
| 9 | Corrigir nomes com typo | Componentes e imports | Renomear `OrganizationPermissionsv2`, `ContarctPjForm`, `ContarctPFForm` → `ContractPjForm`, `ContractPFForm` (e equivalente); ajustar imports. |
| 10 | Resolver placeholders em rotas | `App.tsx` (ProposalContact, ProposalSend) | Implementar telas reais ou remover rotas até existir implementação. |
| 11 | Revisar dependências de `useEffect` | Vários (ProtectedRoute, SidebarNav, SearchFilterListByQueries, pf-contract-form, etc.) | Incluir deps corretas; remover `eslint-disable-next-line react-hooks/exhaustive-deps` onde possível. |
| 12 | Adicionar Prettier | Projeto | Instalar Prettier, config e script `format`; opcionalmente format on save. |
| 13 | Unificar tratamento de erro da API | Services e possivelmente interceptor em `lib/axios.ts` | Interceptor de response que normaliza erro; opcionalmente toast/estado global; serviços lançando erro tipado único. |

---

## Prioridade 4 — Testes e qualidade (recomendado após P2)

| # | Tarefa | Onde | Ação |
|---|--------|------|------|
| 14 | Configurar testes | Projeto | Vitest ou Jest; script `test` no `package.json`. |
| 15 | Testes unitários mínimos | `ProtectedRoute`, `useBootstrapUser`, `lib/utils.ts`, `lib/error-handler.ts` | Testar: redirect sem auth, AccessDenied sem permissão; bootstrap com/sem token; `handleBackendError`, `cn()`. |
| 16 | E2E (opcional, depois) | Fluxos críticos | Playwright: login, dashboard → venue → proposal. |

---

## Resumo por prioridade

- **P1 (Crítico):** 3 itens — typo, hook, rotas públicas.  
- **P2 (Importante):** 5 itens — dados, ProtectedRoute, App/rotas, TypeScript, .env.example.  
- **P3 (Melhorias):** 5 itens — nomes, placeholders, deps, Prettier, erros API.  
- **P4 (Testes):** 3 itens — setup, unitários, E2E.

Sugestão de ordem de execução: fazer **P1** em 1–2 dias; em seguida **P2** (convenção de dados + ProtectedRoute + .env na primeira semana; lazy + TypeScript na segunda); **P3** e **P4** conforme capacidade.
