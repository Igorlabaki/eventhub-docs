# Frontend Map — EventHub

## Aplicacao e design

- repo: `frontend` em `eventhub-vista-dashboard/`;
- rotas: `src/App.tsx`; entrada: `src/main.tsx`;
- areas: organizacao, venue, proposal, website, auth e formularios publicos;
- UI: Tailwind, shadcn/Radix e Lucide;
- tokens: `src/index.css` e `tailwind.config.ts`;
- base components: `src/components/ui/`;
- Storybook: inexistente; temas/dark mode nao possuem politica documentada.

## Componentes e dados

- navegacao: `src/components/layout/`, `organization/OrganizationNav.tsx`, `venue/VenueNav.tsx`;
- dashboards: `pages/Dashboard.tsx`, `pages/VenueDashboard.tsx`, `components/venue/`;
- feedback: skeletons, `toaster.tsx`, `sonner.tsx`, `alert-dialog.tsx`;
- guard: `components/ProtectedRoute.tsx`;
- HTTP: `lib/axios.ts` e `services/`;
- server state: hooks TanStack React Query em parte dos dominios;
- legado: 27 stores Zustand em `store/`.

## Auth e dividas a nao copiar

- token e sessao em `localStorage`;
- refresh do Axios diverge do contrato alternativo do backend;
- rotas publicas estao duplicadas entre `App.tsx` e `lib/axios.ts`;
- App sem lazy loading, React Query/Zustand sobrepostos, typos historicos, placeholders e um unico teste mapeado;
- `.env.example` nao lista `VITE_API_URL` nem `VITE_GOOGLE_CLIENT_ID`.

## Fontes

`docs/estado/frontend/FRONTEND_ANALISE_ATUAL.md`, `FRONTEND_TODO_PRIORIDADE.md` e `docs/estado/integracao/INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md`.
