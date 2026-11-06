# Análise do frontend atual — EventHub

**Escopo:** aplicação frontend em `eventhub-vista-dashboard/`.  
**Data da análise:** fevereiro/2025.  
**Base:** apenas o que existe no repositório (sem suposições de features).

---

## 1. Visão geral do frontend

- **Stack:** Vite 5, React 18, TypeScript 5, React Router DOM 6.
- **UI e estilo:** Tailwind CSS 3, componentes baseados em Radix UI (shadcn/ui), `class-variance-authority`, `clsx`, `tailwind-merge`, `lucide-react`, `react-icons`.
- **Estado e dados:** Zustand (stores por entidade), TanStack React Query (hooks de queries/mutations em paralelo aos stores).
- **Formulários e validação:** React Hook Form, `@hookform/resolvers`, Zod.
- **HTTP:** Axios (instância em `src/lib/axios.ts`), serviços por domínio em `src/services/`.
- **Auth:** login/registro (email/senha e Google OAuth via `@react-oauth/google`), token e sessão em `localStorage`, `ProtectedRoute` com checagem de permissão por rota.
- **Outros:** FullCalendar, Recharts, date-fns, jspdf, sonner/toast, next-themes, Vitest (testes unitários).

### Horários de evento (wall-clock)

- Util central: `src/lib/wall-clock-datetime.ts` — extrair/formatar EventDateTime sem fuso local.
- Regra: não usar `format(date, "HH:mm")`, `toTimeString()` ou `toLocaleDateString()` para proposta/dateEvent/schedule.
- **Fase 1 (jul/2026):** util criado; migrados `VenueSchedule`, `ProposalEdit`, `ProposalView`, `ProposalServicesSummary`. Testes: `npm test`.
- Plano completo: [planos/horario-wall-clock/README.md](../../planos/horario-wall-clock/README.md).

**Padrão arquitetural:** SPA com rotas centralizadas em `App.tsx`, camada de serviços chamada por stores (Zustand) e por hooks (React Query). Componentes organizados por domínio (venue, organization, proposal, contract, etc.) e pasta `ui` com primitivos reutilizáveis (shadcn).

---

## 2. Estrutura de pastas

```
eventhub-vista-dashboard/
├── public/
├── src/
│   ├── components/          # Componentes por domínio + ui
│   │   ├── ui/              # ~64 componentes (shadcn + custom)
│   │   ├── contact/, contract/, dateEvent/, document/, email-config/,
│   │   ├── events/, expense/, goal/, image/, organization/, owner/,
│   │   ├── payment/, permissions/, person/, profile/, proposal/,
│   │   ├── question/, reports/, schedule/, service/, text/, venue/, website/
│   │   ├── DashboardLayout.tsx, Header.tsx, SidebarNav.tsx, ProtectedRoute.tsx, ...
│   ├── hooks/               # React Query (queries/mutations) por domínio
│   │   ├── attachment/, clause/, contract/, goal/, notification/,
│   │   ├── organization/, owner/, permissions/, user/, user-organization/, venue/
│   │   └── useBootstrapUser.ts, useMutationWithError.ts
│   ├── lib/                 # Axios, utils, error-handler, api
│   ├── pages/               # Páginas/rotas (~45+ arquivos)
│   │   └── website/         # Subpáginas de website (org/venue)
│   ├── services/            # ~30 services (um por entidade/API)
│   ├── store/               # ~25 stores Zustand
│   ├── styles/              # (referenciado na estrutura)
│   ├── types/               # DTOs e tipos (venue, user, organization, etc.)
│   ├── utils/
│   ├── App.tsx, main.tsx, index.css
│   └── vite-env.d.ts
├── eslint.config.js
├── tsconfig.json, tsconfig.app.json, tsconfig.node.json
├── vite.config.ts
├── tailwind.config.*, postcss.config.*
└── package.json
```

**Pontos positivos:** Separação clara por domínio (components, hooks, services, store, types). Presença de `components/ui` com design system (shadcn). Hooks de dados organizados em queries/mutations.

**Problemas:** Dupla fonte de verdade (Zustand + React Query) para os mesmos dados (ex.: venue: `venueStore` + `useGetVenuesList` / `useGetVenueDashBoardData`). Inconsistência de nomenclatura (ex.: `OrganizationPermissionsv2`, `ContarctPjForm`). `App.tsx` concentra todas as rotas e muitos imports (arquivo pesado).

---

## 3. Rotas, páginas e fluxos

**Definição de rotas:** `src/App.tsx` — `BrowserRouter` + `Routes` + `Route`. Não há lazy loading de rotas.

**Rotas existentes (resumo):**

| Grupo | Exemplos |
|-------|----------|
| Públicas | `/`, `/index`, `/login`, `/register`, `/profile`, `/forgot-password`, `/reset-password` |
| Dashboard | `/dashboard` |
| Organization | `/organization/:id/venues`, `/organization/:id/owners`, `/organization/:id/website`, `/organization/:id/settings`, `/organization/:id/contracts`, `/organization/:id/permissions`, `/organization/:id/website/texts`, `/organization/:id/website/venues`, `/organization/:id/website/images` |
| Venue | `/venue/:id`, `/venue/:id/goals`, `/venue/:id/events`, `/venue/:id/budgets`, `/venue/:id/reports`, `/venue/:id/website`, `/venue/:id/expenses`, `/venue/:id/new-budget`, `/venue/:id/services`, `/venue/:id/contacts`, `/venue/:id/schedule`, `/venue/:id/settings`, `/venue/:id/notifications`, `/venue/:id/website/faq`, `/venue/:id/website/texts`, `/venue/:id/website/images` |
| Proposal | `/proposal/:id`, `/proposal/:id/view`, `/proposal/:id/edit`, `/proposal/:id/dates`, `/proposal/:id/history`, `/proposal/:id/guest-list`, `/proposal/:id/staff-list`, `/proposal/:id/schedule-list`, `/proposal/:id/payment`, `/proposal/:id/contract`, `/proposal/:id/documents`, `/proposal/:id/schedule`, `/proposal/:id/send-message`, `/proposal/:id/send-suppliers`, `/proposal/:id/send-proposal`, `/proposal/:id/attendance-list`, etc. |
| Formulários públicos (sem auth) | `/venue/:id/form`, `/venue/:id/partner-form`, `/venue/:id/crew-form`, `/proposal/:id/b2b-contract`, `/proposal/:id/person-contract` |
| Fallback | `*` → `NotFound` |

**Fluxos principais:**

1. **Auth:** `/` → redirect para `/login`. Após login, token/session em `localStorage`; `useBootstrapUser` carrega usuário e preenche `userStore`. Rotas protegidas envolvidas em `<ProtectedRoute>`.
2. **Organization → Venue → Proposal:** Dashboard lista organizações; ao escolher organização, navega para `/organization/:id/venues`; ao escolher venue, para `/venue/:id` (dashboard do espaço). De lá acessa eventos, orçamentos (proposals), relatórios, website, etc. Proposal tem subrotas (detalhes, edição, datas, pagamento, documentos, envio, etc.).
3. **Proposal público:** `/proposal/:id/view` e formulários (`/venue/:id/form`, listas de convidados/funcionários, contratos PJ/PF) não exigem autenticação.
4. **Permissões:** `ProtectedRoute` recebe `requiredPermission` (ex.: `VIEW_ORG_VENUES`, `VIEW_VENUE_EVENTS`). Carrega proposal/venue/organization conforme a URL e busca permissão do usuário (venue ou organization); se não tiver permissão, exibe `AccessDenied`.

---

## 4. Componentização e reutilização

- **Organização:** Componentes por domínio em pastas (ex.: `components/venue/`, `components/organization/`, `components/proposal/`). Padrão recorrente: `*-form`, `*-list`, `*-section`, `*-skeleton`, `*-header`.
- **Design system:** `src/components/ui/` — grande conjunto de componentes estilo shadcn (button, card, dialog, form, input, select, table, tabs, etc.) + alguns custom (ex.: `VenueDashboardSkeleton`, `AppLoadingScreen`, `data-table`, `confirm-delete-dialog`). Tokens de estilo em `index.css` (variáveis CSS `--primary`, `--sidebar-*`, etc.) e Tailwind.
- **Reutilização:** Layout comum via `DashboardLayout` (SidebarNav + Header + main). Componentes de lista/form reutilizados entre páginas do mesmo domínio.
- **Problemas:** Algumas páginas (ex.: `VenueDashboard`, `ProposalEdit`) são longas e misturam layout, lógica e UI. Placeholders como `ProposalContact` e `ProposalSend` retornam apenas `<div>Entrar em contato</div>` / `<div>Enviar Orçamento</div>` em `App.tsx`. Componentes de domínio às vezes acoplados aos stores (ex.: várias páginas dependem diretamente de `useVenueStore` para `selectedVenue` e `fetchVenueById`).

---

## 5. Estado, cache e dados

- **Zustand:** Usado para estado global por entidade: `userStore`, `venueStore`, `organizationStore`, `proposalStore`, `userVenuePermissionStore`, `userOrganizationPermissionStore`, além de stores para goal, contract, clause, attachment, expense, etc. Stores guardam listas, “selected” (ex.: `selectedVenue`, `currentProposal`), loading/error e funções que chamam services e atualizam o estado.
- **React Query:** Hooks em `src/hooks/*/queries/` e `*/mutations/` usam `useQuery`/`useMutation` para os mesmos (ou sobrepostos) recursos (ex.: `useGetVenuesList`, `useGetVenueDashBoardData`, `useGetGoals`). Usado em paralelo aos stores — por exemplo, `VenueDashboard` usa tanto `useVenueStore` (selectedVenue, fetchVenueById) quanto `useGetVenueDashBoardData` e `useGetVenuesList`.
- **Problemas:** Duplicação de fonte de verdade (dados de venue/organization/proposal tanto em Zustand quanto em React Query), risco de inconsistência e de refetch desnecessário. `ProtectedRoute` preload usa apenas stores (`fetchProposalById`, `fetchVenueById`, `fetchOrganizationById`), enquanto páginas podem usar hooks React Query; não há convenção clara de “única fonte” por recurso. Hook `useGetVenuesList` chama `venueService.getAllVenues(organizationId)` com um único argumento, mas o service espera `({ organizationId, userId })` — inconsistência de assinatura.

---

## 6. Integração com API / Camada de serviços

- **Cliente HTTP:** `src/lib/axios.ts` — instância com `baseURL` de `import.meta.env.VITE_API_URL`, header `Authorization: Bearer` com token em `localStorage.getItem('@EventHub:token')`, interceptor de response para 401 (refresh com `/auth/refresh`, depois reenvio; em falha, limpa storage e redireciona para `/login` exceto em rotas públicas).
- **Serviços:** Um arquivo por domínio em `src/services/` (ex.: `auth.service.ts`, `venue.service.ts`, `organization.service.ts`, `proposal.service.ts`, `user.service.ts`, etc.). Chamam `api.get/post/put/delete` e retornam `response.data` ou lançam. Tipagem com DTOs em `src/types/`.
- **DTOs e tipos:** `src/types/` contém interfaces de resposta e parâmetros (ex.: `venue.ts`, `user.ts`, `organization.ts`). Em `venue.ts` há comentários com `any[]` para relações não tipadas; em outros pontos do código há uso de `any` ou `as any` e `@ts-expect-error` (ex.: `lib/error-handler.ts`).
- **Tratamento de erro:** `lib/error-handler.ts` com `handleBackendError` e `BackendResponse<T>`. Serviços às vezes repassam erros ou convertem com `axios.isAxiosError`. Não há interceptor global que normalize erros para um formato único na UI.
- **Inconsistências e riscos:** Token e sessão em `localStorage` (risco XSS; refresh depende de cookie/session no backend se houver). Lista de rotas públicas duplicada em `axios.ts` e `useBootstrapUser.ts`. Typo no parâmetro `organizattionId` (dois “t”) em `userOrganizationPermissionStore` e em `ProtectedRoute` — o service usa `organizationId`; o store repassa `organizattionId`, o que funciona apenas porque o valor é o mesmo, mas o nome está errado. Alguns services usam `import.meta.env` diretamente (ex.: `document.service.ts`, `analytics.service.ts`).

---

## 7. Qualidade do código

- **TypeScript:** `tsconfig.app.json` com `strict: false`, `noImplicitAny: false`, `noUnusedLocals: false`, `noUnusedParameters: false`. Tipagem é usada em DTOs, stores e serviços, mas fica fraca por essas opções e por escapes pontuais (`any`, `as any`, `@ts-expect-error`). Tipos de domínio existem e são importados de `@/types/*`.
- **ESLint:** `eslint.config.js` com `@eslint/js`, `typescript-eslint`, `react-hooks`, `react-refresh`. Regra `@typescript-eslint/no-unused-vars` desligada. Vários `// eslint-disable-next-line react-hooks/exhaustive-deps` (ex.: `ProtectedRoute.tsx`, `SidebarNav.tsx`, `SearchFilterListByQueries.tsx`, `pf-contract-form.tsx`).
- **Prettier:** Não encontrado no `package.json`; não há script de formatação nem config explícita.
- **Complexidade e duplicação:** `ProtectedRoute` e fluxo de preload são complexos (vários useEffects, getState() dentro de async). Lista de rotas públicas e lógica “is public route” duplicadas. Padrão de “fetch no store + loading/error” repetido em vários stores. Nomes inconsistentes: `OrganizationPermissionsv2`, `ContarctPjForm` / `ContarctPFForm` (typo “Contract”).
- **Contratos — cláusulas (jul/2026):** `contract-form.tsx` exibe seção **“Cláusulas selecionadas (ordem do contrato)”** com badge de posição, botões ↑/↓ e remover; biblioteca separada para adicionar cláusulas. Em edição, o submit envia `clauses[].id` das cópias existentes (evita duplicação no banco); cláusulas novas da biblioteca omitem `id`. Ver [planos/contrato-clausulas](../../planos/contrato-clausulas/README.md).

---

## 8. UI/UX e consistência visual

- **Libs e padrões:** Tailwind + componentes em `components/ui` (shadcn/Radix). Uso de `cn()` (`lib/utils.ts`) para classes. Cores e temas via variáveis CSS (`:root`, `.dark`). Toasts: `Toaster` (shadcn) e `Sonner`.
- **Consistência:** Layout padrão com `DashboardLayout`, `PageHeader`, `SidebarNav`, `Header`. Botões e cards vêm do UI. Há skeletons (ex.: `VenueDashboardSkeleton`, `contact-list-skeleton`, `OrganizationCardSkeleton`).
- **Dívida de UI:** Placeholders em rotas (ProposalContact, ProposalSend). Possível mistura de padrões de loading/erro (stores vs React Query). Falta de documentação de quando usar qual componente de feedback.

---

## 9. Performance

- **Bundle:** Vite + React (SWC). Não há `React.lazy` / `Suspense` para rotas; todas as páginas são importadas estáticas em `App.tsx`, o que aumenta o bundle inicial.
- **Re-renders:** Uso de Zustand com seletores (ex.: `useUserStore((state) => state.user)`), o que é adequado; em alguns lugares o store inteiro é usado (ex.: `useVenueStore()`), o que pode causar re-renders desnecessários.
- **Imagens:** Uso de URLs de API (ex.: logos, avatares); não há componente de imagem otimizada (ex.: lazy load, srcset) documentado de forma central.
- **Listagens:** Tabelas e listas sem virtualização explícita; em listas grandes pode haver impacto.
- **Oportunidades:** Lazy de rotas; padronizar seletores de store; revisar dependências de useEffect (evitar deps amplas e eslint-disable).

---

## 10. Segurança (frontend)

- **Env:** Uso de `import.meta.env.VITE_API_URL`, `VITE_GOOGLE_CLIENT_ID`; em serviços, `VITE_VERCEL_PROJECT_ID`, `VITE_VERCEL_API_TOKEN`. Não há `.env.example` no repositório.
- **Tokens:** Access token em `localStorage` (`@EventHub:token`); sessão em `localStorage` (`@EventHub:session`). Refresh via GET `/auth/refresh` e novo token gravado em `localStorage`. Em caso de XSS, o token pode ser lido; não há menção a httpOnly cookies no frontend.
- **Dados sensíveis:** Não foi encontrada gravação de senha em storage. Formulários de senha existem (login, reset, perfil).
- **Rotas públicas:** Lista fixa em código; rotas de proposal/venue form e view acessíveis sem auth, o que é intencional para fluxo de cliente/parceiro.

---

## 11. Testes

- **O que existe:** Nenhum arquivo `*.test.*` ou `*.spec.*` encontrado em `eventhub-vista-dashboard`. Nenhum script de teste no `package.json` (apenas `lint`, `dev`, `build`, `preview`).
- **Recomendação mínima:** Introduzir testes unitários para: (1) `ProtectedRoute` (redirecionamento sem auth, exibição de AccessDenied sem permissão); (2) `useBootstrapUser` (comportamento com/sem token); (3) funções puras em `lib/utils.ts` e `lib/error-handler.ts`. Configurar Vitest ou Jest e um script `test` no `package.json`. E2E (ex.: Playwright) em um segundo momento para fluxos críticos (login, navegação dashboard → venue → proposal).

---

## 12. Dívidas técnicas priorizadas

### Crítico (precisa corrigir já)

| Problema | Onde | Impacto | Sugestão |
|----------|------|---------|----------|
| Typo `organizattionId` | `store/userOrganizationPermissionStore.ts`, `components/ProtectedRoute.tsx` | Nome errado propagado; risco de bug se alguém “corrigir” só em um lugar | Renomear para `organizationId` em store e ProtectedRoute e garantir que o service continue recebendo `organizationId`. |
| Hook `useGetVenuesList` com assinatura errada | `hooks/venue/queries/list.ts` | `venueService.getAllVenues(organizationId)` recebe 1 arg; service espera `{ organizationId, userId }` | Ajustar hook para receber `organizationId` e `userId` e chamar `venueService.getAllVenues({ organizationId, userId })`. |
| Rotas públicas duplicadas | `lib/axios.ts`, `hooks/useBootstrapUser.ts` | Alteração em uma lista e não na outra gera comportamento inconsistente (redirect vs não enviar token) | Centralizar em uma constante (ex.: `src/constants/publicRoutes.ts`) e importar nos dois arquivos. |

### Importante (próximas sprints)

| Problema | Onde | Impacto | Sugestão |
|----------|------|---------|----------|
| Dupla fonte de verdade (Zustand + React Query) | Stores (ex.: venueStore) e hooks (useGetVenuesList, useGetVenueDashBoardData); páginas que usam ambos | Dados dessincronizados, refetch e estado redundante | Definir convenção: por recurso, usar só React Query (cache + loading) ou só store; migrar gradualmente (ex.: venue: React Query como fonte, store só para selectedVenue se necessário). |
| `ProtectedRoute` muito complexo | `components/ProtectedRoute.tsx` | Difícil de testar e manter; uso de getState() dentro de async | Extrair lógica de “preload por rota” para um hook (ex.: usePreloadRouteContext) e deixar ProtectedRoute só com checagem de auth + permissão + render de loading/erro/children. |
| App.tsx com muitas rotas e imports | `App.tsx` | Bundle grande, difícil leitura | Lazy load de páginas com `React.lazy` + `Suspense` e/ou dividir rotas em arquivos (ex.: `routes/organization.tsx`, `routes/venue.tsx`) e compor em App. |
| TypeScript com strict desligado | `tsconfig.app.json` | Erros de tipo passam despercebidos | Habilitar `strict: true` (ou no mínimo `strictNullChecks` e `noImplicitAny`) em etapas e corrigir arquivos críticos (lib, store, services). |
| Falta de .env.example | Raiz do app | Onboarding e deploy sem saber variáveis necessárias | Criar `.env.example` com `VITE_API_URL`, `VITE_GOOGLE_CLIENT_ID`, etc., sem valores sensíveis. |

### Melhorias (quando der)

| Problema | Onde | Impacto | Sugestão |
|----------|------|---------|----------|
| Nomes com typo | `OrganizationPermissionsv2`, `ContarctPjForm`, `ContarctPFForm` | Legibilidade e consistência | Renomear para `OrganizationPermissions` (ou v2 em comentário) e `ContractPjForm`, `ContractPFForm` (ou similar), ajustando imports e rotas. |
| Placeholders em rotas | `App.tsx` (ProposalContact, ProposalSend) | Páginas vazias ou sem função | Implementar telas reais ou remover rotas até existir implementação. |
| ESLint: react-hooks/exhaustive-deps desligado várias vezes | Vários componentes | Possíveis bugs de efeito (stale closure, falta de dep) | Revisar cada useEffect e incluir deps corretas; remover disable onde possível. |
| Prettier ausente | Projeto | Formatação inconsistente | Adicionar Prettier e script `format`; opcionalmente format on save no editor. |
| Tratamento de erro da API não unificado | Services e componentes | Mensagens e comportamento diferentes por tela | Interceptor de response que normaliza erro e, se desejado, dispara toast/estado global; serviços lançando erro tipado único. |

---

## 13. Próximos passos sugeridos (plano de 2 semanas)

**Semana 1**

1. **Correções críticas (1–2 dias):** Corrigir typo `organizattionId` → `organizationId`; ajustar `useGetVenuesList` para passar `{ organizationId, userId }`; extrair rotas públicas para `constants/publicRoutes.ts` e usar em `axios.ts` e `useBootstrapUser`.
2. **Convenção de dados (2–3 dias):** Documentar em um ADR ou README interno: “venue list/detail: React Query como fonte; store só para selectedVenue quando necessário”. Ajustar uma fluxo piloto (ex.: lista de venues em uma página) para usar só React Query e remover uso duplicado do store para essa lista.
3. **Ambiente (meio dia):** Criar `.env.example` com todas as `VITE_*` usadas no projeto.

**Semana 2**

4. **ProtectedRoute (1–2 dias):** Extrair `usePreloadRouteContext` (ou equivalente) com a lógica de preload; simplificar `ProtectedRoute` e adicionar testes unitários mínimos (auth sim/não, permissão sim/não).
5. **Rotas e bundle (1 dia):** Introduzir `React.lazy` para 2–3 páginas mais pesadas (ex.: Dashboard, VenueDashboard, ProposalEdit) e `Suspense` no App; medir impacto no bundle.
6. **Qualidade (restante):** Habilitar `noImplicitAny: true` ou `strictNullChecks: true` em um módulo piloto (ex.: `lib/`) e corrigir erros; adicionar script `test` com Vitest e um teste para `handleBackendError` / `cn()`.

---

**Fim do documento.**  
Para detalhes de implementação, usar os arquivos e pastas citados neste documento.
