# Frontend Map — EventHub

Repo `frontend` em `eventhub-vista-dashboard/`. Observado em 2026-11-10 no codigo da `main`.

## Estrutura

| Caminho | Papel |
|---|---|
| `src/main.tsx` | `createRoot` -> `<App/>` |
| `src/App.tsx` | providers (Google OAuth, React Query + devtools, Tooltip, Toaster, Sonner), `AppInitializer` (`useBootstrapUser`), `GoogleCalendarRedirectHandler` e as 63 rotas |
| `src/pages/` | 61 paginas; `pages/website/` tem o site de organizacao e venue |
| `src/components/` | 298 arquivos: `ui/` (65) e pastas por dominio |
| `src/services/` | 34 arquivos de chamada HTTP |
| `src/hooks/` | 55 arquivos: React Query por dominio e utilitarios |
| `src/store/` | 30 stores Zustand (+ 1 teste) |
| `src/types/` | 34 arquivos de tipos e DTOs, inclusive enum `Permissions` |
| `src/lib/` | `axios.ts` e helpers puros testados |
| `src/utils/currency.ts` | `parseCurrencyStringToNumber` |
| `src/index.css`, `App.css`, `styles/fullcalendar-google.css` | tokens, utilitarios e tema do calendario |
| raiz | `vite.config.ts`, `tailwind.config.ts`, `components.json`, `eslint.config.js`, `vercel.json`, `index.html`, tres lockfiles (`bun.lockb`, `package-lock.json`, `yarn.lock`), arquivo solto `Untitled` |

## Stack e scripts

- React `^18.3`, React Router `^6.26`, Vite `^5.4` (`plugin-react-swc`, `lovable-tagger` so em dev), TypeScript `^5.5`;
- dados: TanStack React Query `^5.56`, Zustand `^5`, Axios `^1.9`;
- formularios: react-hook-form + `@hookform/resolvers` + Zod;
- UI: Tailwind `^3.4`, shadcn/Radix (~25 pacotes), lucide-react, react-icons, sonner;
- graficos: recharts; calendario: react-big-calendar (FullCalendar instalado e nao importado); datas: date-fns + date-fns-tz, react-datepicker, react-day-picker;
- documentos: jspdf + extenso (contrato), `@e965/xlsx` (planilha de pessoas); jspdf-autotable, pdfjs-dist e swiper instalados sem uso;
- inputs: react-number-format, react-input-mask, react-phone-input-2, libphonenumber-js.

| Script | Comando |
|---|---|
| `dev` | `vite` (host `::`, porta 8080) |
| `build` / `build:dev` | `vite build` / `vite build --mode development` |
| `lint` | `eslint .` |
| `preview` | `vite preview` |
| `test` / `test:watch` | `vitest run` / `vitest` |

TypeScript frouxo: `strict: false`, `noImplicitAny: false`, `strictNullChecks: false`. ESLint flat com `no-unused-vars` desligado. Alias `@` -> `src`. `vercel.json` reescreve tudo para `/index.html`.

## Configuracao (somente nomes)

| Variavel | Uso | No `.env.example` |
|---|---|---|
| `VITE_API_URL` | `lib/axios.ts`, `services/document.service.ts` | nao |
| `VITE_GOOGLE_CLIENT_ID` | `App.tsx` | nao |
| `VITE_VERCEL_PROJECT_ID` | `services/analytics.service.ts` | sim |
| `VITE_VERCEL_API_TOKEN` | `services/analytics.service.ts` | sim; entra no bundle do navegador |

## HTTP e sessao

- `lib/axios.ts`: `baseURL = VITE_API_URL`; request injeta `Bearer` de `localStorage['@EventHub:token']`;
- 401 nao repetido: exige `@EventHub:session` (`{id, userId, refreshTokenId, expiresAt}`), chama `GET /auth/refresh` na mesma instancia, grava o novo token e refaz a chamada; falha limpa storage e manda para `/login`, exceto em `PUBLIC_ROUTES`;
- `PUBLIC_ROUTES` duplicada em `lib/axios.ts` e `hooks/useBootstrapUser.ts`: `/venue/:id/form`, `/venue/:id/rules/view`, `/proposal/:id/guest-list`, `/proposal/:id/worker-list`, `/proposal/:id/schedule-list`, `/proposal/:id/view`, `/proposal/:id/person-contract`, `/proposal/:id/b2b-contract`;
- erros: `services/error-handler.service.ts` converte `AxiosError` em `Http*Error`; `useErrorHandler` mostra toast; mutacoes usam `useMutationWithError`.

## Rotas

Sem layout no router: cada pagina renderiza `DashboardLayout`; publicas usam `PublicVenueListShell`. `ProtectedRoute` autentica, pre-carrega proposta/venue/organizacao/permissao e decide por `panel-route-gate` (`session`, `content`, `ready`, `denied`, `error`).

### Acesso e conta

| Path | Pagina | Protecao |
|---|---|---|
| `/` | redirect `/login` | — |
| `/index` | `Index` | — (redireciona por token) |
| `/login`, `/register`, `/forgot-password`, `/reset-password` | auth | — |
| `/profile` | `Profile` | nenhuma (fora do `ProtectedRoute`) |
| `*` | `NotFound` | — |

### Organizacao

| Path | Pagina | Permissao |
|---|---|---|
| `/dashboard` | `Dashboard` (lista de organizacoes) | so autenticacao |
| `/organization/:id/venues` | `OrganizationVenues` | `VIEW_ORG_VENUES` |
| `/organization/:id/owners` | `OrganizationOwners` | `VIEW_ORG_OWNERS` |
| `/organization/:id/website` (+ `/texts`, `/venues`, `/images`) | `OrganizationWebsite*` | `VIEW_ORG_SITE` |
| `/organization/:id/settings` | `OrganizationSettings` | `VIEW_ORG_INFO` |
| `/organization/:id/contracts` | `OrganizationContracts` | `VIEW_ORG_CONTRACTS` |
| `/organization/:id/permissions` | `OrganizationPermissionsv2` | `VIEW_ORG_PERMISSIONS` |

### Venue

| Path | Pagina | Permissao |
|---|---|---|
| `/venue/:id` | `VenueDashboard` (Visao Geral) | `VIEW_VENUE_INFO` |
| `/venue/:id/budgets` | `VenueBudgets` | `VIEW_VENUE_PROPOSALS` |
| `/venue/:id/events` | `VenueEvents` | `VIEW_VENUE_EVENTS` |
| `/venue/:id/new-budget` | `NewBudget` | `VIEW_VENUE_NEW_BUDGET` (fora do enum) |
| `/venue/:id/schedule` | `VenueSchedule` | `VIEW_VENUE_CALENDAR` |
| `/venue/:id/notifications` | `VenueNotifications` | `VIEW_VENUE_SITES` (sidebar usa `VIEW_VENUE_NOTIFICATIONS`) |
| `/venue/:id/goals` | `VenueGoals` (metas e precos) | `VIEW_VENUE_PRICES` |
| `/venue/:id/services` | `VenueServices` | `VIEW_VENUE_SERVICES` |
| `/venue/:id/expenses` | `VenueExpenses` | `VIEW_VENUE_EXPENSES` |
| `/venue/:id/reports` | `VenueReports` | `VIEW_VENUE_ANALYSIS` |
| `/venue/:id/contacts` | `VenueContacts` | `VIEW_VENUE_CONTACTS` |
| `/venue/:id/rules` | `VenueRules` | `VIEW_VENUE_RULES` |
| `/venue/:id/amenities` | `VenueAmenities` | `VIEW_VENUE_AMENITIES` |
| `/venue/:id/website` (+ `/faq`, `/texts`, `/images`) | `VenueWebsite*` | `VIEW_VENUE_SITES` |
| `/venue/:id/settings` | `VenueSettings` (1320 linhas; precos, cores, logo, tour, e-mail) | `EDIT_VENUE_INFO` (sidebar usa `VIEW_VENUE_CONFIG`) |

### Proposta no painel

| Path | Pagina | Permissao |
|---|---|---|
| `/proposal/:id` | `ProposalDetails` (marca notificacoes como lidas) | `VIEW_PROPOSAL_INFO` |
| `/proposal/:id/edit` | `ProposalEdit` | `EDIT_VENUE_INFO` (sidebar usa `EDIT_VENUE_PROPOSALS`) |
| `/proposal/:id/history` | `ProposalHistory` | `VIEW_PROPOSAL_HISTORY` |
| `/proposal/:id/dates` | `DateEventList` | `VIEW_PROPOSAL_DATES` |
| `/proposal/:id/payment` | `proposal-payment` | `VIEW_PROPOSAL_PAYMENT` (enum tem `..._PAYMENTS`) |
| `/proposal/:id/contract` | `ProposalContract` (PDF jsPDF) | `SEND_PROPOSAL_DOCUMENTS` (sidebar usa `SEND_PROPOSAL_INFO`) |
| `/proposal/:id/documents` | `ProposalDocuments` | `VIEW_PROPOSAL_DOCUMENTS` |
| `/proposal/:id/schedule` | `ProposalSchedule` | `VIEW_PROPOSAL_SCHEDULE` |
| `/proposal/:id/attendance-list` | `ProposalAttendanceList` | `VIEW_PROPOSAL_ATTENDANCE_LIST` |
| `/proposal/:id/send-message` | `SendMessagePage` (WhatsApp) | `SEND_PROPOSAL_TEXT` |
| `/proposal/:id/send-proposal` | `SendProposalPage` (e-mail/WhatsApp) | `SEND_PROPOSAL_INFO` |
| `/proposal/:id/send-suppliers` | `SendSuppliers` (indicar parceiros) | `SEND_PROPOSAL_INFO` |
| `/proposal/:id/event-link` | `ProposalEventLinkShare` | `SEND_PROPOSAL_INFO` |
| `/proposal/:id/send`, `/proposal/:id/contact` | placeholders inline | `VIEW_PROPOSAL_SEND` / `VIEW_PROPOSAL_CONTACT` (fora do enum) |

### Publicas (cliente, sem login)

| Path | Pagina | Dados principais |
|---|---|---|
| `/venue/:id/form` | `ProposalForm` (3 passos; por pessoa ou por dia se `hasOvernightStay`) | `GET /venue/getById`, `GET /service/list`, `POST /proposal/createPerPerson|createPerDay` |
| `/proposal/:id/view` | `ProposalView` (1363 linhas) | `GET /proposal/byId`, `GET /proposal/presentation/:id`, `.../services`, `.../recalculate`, `.../image-order`, `.../image-choice` |
| `/proposal/:id/links` | `ProposalEventLink` (contagem regressiva e atalhos) | `GET /proposal/byId` |
| `/proposal/:id/guest-list` | `GuestList` (planilha, limite de convidados) | `/person/list|createMany|delete` `type=GUEST` |
| `/proposal/:id/staff-list` | `WorkerList` | `/person/*` `type=WORKER` |
| `/proposal/:id/schedule-list` | `ScheduleList` | `/schedule/*` |
| `/proposal/:id/indications` | `ProposalIndications` | `GET /proposal/indications/:id` |
| `/proposal/:id/person-contract`, `/b2b-contract` | `ContarctPFForm`, `ContarctPjForm` | `PUT /proposal/updatePersonalInfo` |
| `/venue/:id/rules/view` | `PublicVenueRules` (accordion) | `GET /venue-rule/public/:venueId` |
| `/venue/:id/apresentacao` | `VenuePresentation` (casa, servicos e preco de tabela) | `GET /venue/presentation/:venueId` |
| `/venue/:id/partner-form` | `PartnerForm` (logo e preview do card) | `POST /contact/create` `SUPPLIER` |
| `/venue/:id/crew-form` | `CrewForm` | `POST /contact/create` `TEAM_MEMBER` |

Detalhe de marca e comportamento das paginas publicas: `topics/public-pages-and-branding.md`.

## Navegacao (sidebar)

`DashboardLayout` = `SidebarNav` propria (nao usa `ui/sidebar`) + `Header`. `sidebar-level.ts` escolhe o menu pela URL (`organization`, `venue`, `proposal`, `website`, `org-website`, `empty`) e segura o menu anterior enquanto o novo carrega. Itens e permissoes em `components/sidebar/sidebar-nav-model.ts`:

- organizacao: Operacao (Espacos), Marca (Site, Contratos), Acesso (Permissoes, Proprietarios), rodape Configuracoes;
- venue: Dia a dia, sempre aberta (Visao Geral, Orcamentos, Agenda, Eventos, Notificacoes), Comercial (Metas/Precos, Servicos, Despesas, Relatorios, Contatos), A casa (Site, Regras, Caracteristicas, Fotos, Apresentacao — link externo do espaco), rodape Configuracoes;
- proposta: Orcamento, sempre aberta (Visao Geral, Editar, Ver Historico), Falar com o cliente (Entrar em contato, Enviar Orcamento, Link do evento externo, Indicar parceiros), Fechar (Gerar Contrato, Agendar Data, Efetuar Pagamento), No dia (Lista de Presenca, Programacao, Documentos);
- site da venue: Visao Geral, Textos, Imagens, FAQ, Ver Site; site da organizacao: Visao Geral, Textos, Espacos, Imagens, Ver Site.

`VenueNav` e `ProposalNav` redirecionam para o primeiro item permitido quando a rota atual nao aparece no menu do usuario.

## Estado e dados

- React Query: hooks em `hooks/<dominio>/queries|mutations` para attachment, clause, contract, goal, notification, organization, owner, permissions, proposal (`useProposalQuote`, debounce 400 ms), user, user-organization e venue (`useGetVenueDashBoardData`); tambem `useQuery`/`useMutation` direto em `VenueNotifications`, `ProposalDetails` e `Register`;
- Zustand (30 stores, `create` puro, sem `persist`): user, organization, venue, proposal (propostas, eventos, paginacao, resumo), permissoes de venue e organizacao, userOrganization, owner, contact, contract, clause, attachment, dateEvent, schedule, person, payment, document, expense, goal, seasonalFee, minimumPricePeriod, service, image, text, question, emailConfig, venueRule, venueAmenity, analytics (Vercel), venueReports (cache por ano);
- regra: nao criar terceira abordagem; dominio novo segue o padrao dominante do dominio vizinho.

## Services (arquivo -> prefixo backend)

`auth`, `user`, `organization`, `venue`, `proposal`, `dateEvent`, `schedule`, `person`, `payment`, `document`, `contract`, `clause`, `attachments`, `owner`, `user-organization`, `userOrganizationPermission`, `userVenuePermissions`, `service`, `goal`, `seasonalFee`, `minimumPricePeriod`, `expenseService`, `contactService`, `question`, `text`, `image`, `emailConfig`, `emailService`, `notification`, `google-calendar-integration`, `venue-amenity`, `venue-rule` chamam o prefixo de mesmo nome (ver `project/api-endpoints.md`). `analytics.service` usa `fetch` direto na API da Vercel. Chamadas fora de `services/`: `ForgotPassword`, `ResetPassword` e hooks de user.

## Helpers em `src/lib/`

`wall-clock-datetime` (le ISO literal sem fuso), `event-duration`, `event-category`, `event-link`, `indication-links`, `partner-category`, `per-person-amount`, `proposal-quote-input`, `service-price-label`, `required-service-ids`, `person-spreadsheet` e `read-person-spreadsheet` (1 MB, 1000 nomes, magic bytes), `reorder-proposal-images`, `choose-proposal-image`, `tour-video`, `public-venue-rules`, `contact-body`, `supplier-contact-write`, `venue-create-form-key`, `venue-tab-title`, `utils` (`cn`, `formatCurrency`, `formatDate`), `error-handler`.

## UI e design

- `components/ui/`: 49 primitives shadcn + 16 componentes proprios (`form-layout`, `data-table`, `confirm-delete-dialog`, `yearly-change`, `AppLoadingScreen`, `dynamic-field-selector` etc.);
- duplicados a nao multiplicar: `EmptyState`, `PageHeader`, `SubmitButton`, `VenueDashboardSkeleton`, `use-toast`;
- tokens: `index.css` (HSL shadcn, primaria indigo `244 75% 67%`, `--radius 0.5rem`, classes `.eventhub-*`, `.scrollbar-eventhub`, `.scrollbar-house`) e `tailwind.config.ts` (paleta `eventhub.*`, animacoes `logo-in`, `cover-in`, `rise-in`); `bg-eventhub-primary-dark` usado e nao definido;
- fontes: Inter no painel, Manrope nas paginas publicas (Google Fonts no `index.html`);
- dark mode: variaveis `.dark` existem, nada liga a classe; o app e so claro;
- detalhe de componentes por dominio, dashboards e graficos: `topics/frontend-application.md` e `topics/reports-and-kpis.md`.

## Testes

Vitest em ambiente `node`, sem jsdom nem Testing Library; componentes testados com `renderToStaticMarkup`. 41 arquivos: `lib/*` (19), `components/reports` (5), `components/goal` (3), `components/proposal` (5), `components/sidebar` (3), `components/venue` (2), `panel-route-gate`, `notification-list-summary`, `pages/notification-read.contract.test.ts`, `store/proposalStore.test.ts`. Provas: `npm run build`, `npm run lint`, `npm test`.

## Divergencias e dividas a nao copiar

- `PUBLIC_ROUTES` diz `worker-list`, a rota e `staff-list`; faltam `links`, `indications`, `partner-form` e `crew-form`: um 401 nessas paginas manda o cliente para `/login`;
- quatro permissoes de rota fora do enum (`VIEW_VENUE_NEW_BUDGET`, `VIEW_PROPOSAL_SEND`, `VIEW_PROPOSAL_CONTACT`, `VIEW_PROPOSAL_PAYMENT`) e cinco itens com permissao diferente entre sidebar e rota;
- `/profile` sem `ProtectedRoute`;
- `VITE_VERCEL_API_TOKEN` exposto no bundle;
- dominio `event-hub-dashboard.vercel.app` fixo em links publicos, sidebar e copia de link;
- token e sessao em `localStorage`; refresh `GET /auth/refresh` sem `withCredentials`;
- codigo morto: `ProposalDateEvent.tsx`, `website/OrganizationWebsiteFaq.tsx`, `VenueStatsChart.tsx`, `PermissionsManager.tsx`, import `ScheduleSection` em `App.tsx`;
- `PartnerForm` e `CrewForm` ignoram as cores da casa e usam `ProposalFooter` roxo fixo;
- `App.tsx` sem lazy loading; varias paginas acima de 1000 linhas.
