# Frontend Application

## Mapa

- repo: `frontend` (`eventhub-vista-dashboard/`);
- React 18 + Vite 5 + TypeScript (nao estrito) + Tailwind + shadcn/Radix;
- 63 rotas em `src/App.tsx`, 61 paginas, 34 services, 55 hooks, 30 stores, 298 componentes, 41 testes;
- mapa completo (rotas, permissoes, services, estado, divergencias) em `project/frontend-map.md`.

## Areas

- auth e perfil;
- organizacao: espacos, proprietarios, contratos/clausulas/anexos, site, configuracoes, permissoes;
- venue: visao geral, orcamentos, eventos, agenda (react-big-calendar + Google), notificacoes, metas/precos, servicos, despesas, relatorios, contatos, regras, caracteristicas, site, configuracoes;
- proposta no painel: visao geral, editar, historico, contato WhatsApp, envio por e-mail/WhatsApp, link do evento, indicar parceiros, contrato PDF, datas, pagamento, presenca, programacao, documentos;
- publicas: formulario de orcamento, apresentacao do orcamento, link do evento, listas, indicacoes, regras, cadastro de parceiro e equipe, contratos PF/PJ (`topics/public-pages-and-branding.md`).

## Componentes por dominio

| Pasta | Destaques |
|---|---|
| raiz | `DashboardLayout`, `SidebarNav`, `Header`, `ProtectedRoute`, `panel-route-gate`, `ProposalNav`, `AsyncActionButton`, `GoogleCalendarRedirectHandler` |
| `sidebar/` | `SectionedNav`, `sidebar-nav-model`, `sidebar-level` |
| `proposal/` (42) | `ProposalTable`, `ProposalListPager`, `ProposalListSummaryCards`, `MonthYearNavigator`, `ProposalContractForm`, `PublicVenueListShell`, `ProposalTourVideo`, `RecalculateProposalDialog`, `UpdateProposalServicesDialog`, `PartnerPublicCard`, importacao de planilha |
| `proposal/forms/` | formularios publicos e internos por pessoa/por dia, `PublicBudgetFormSteps`, `PublicServiceDetail`, contrato PF/PJ, `ContractPdfGenerator` |
| `reports/` (16) | `ReportsHeader`, `ReportsChartCard`, `FinancialReportCard`, `SlidingSelection`, `report-metrics`, `finance-metrics` |
| `goal/` (22) | painel de metas e precos, abas de metas, adicionais, descontos e minimos |
| `venue/` (12) | `VenueStatsPanel`, `VenuePerformanceSeries`, `CreateVenueForm` (1065 linhas), `VenueNav` |
| `permissions/` (10) | gestao de permissoes de organizacao e venue |
| CRUD | contact, contract, dateEvent, document, expense, image, payment, person, question, schedule, service, text, venue-rule, venue-amenity, owner, organization, profile, email-config, notification |
| `ui/` (65) | 49 primitives shadcn + 16 proprios (`form-layout`, `data-table`, `yearly-change`, `confirm-delete-dialog`) |

## Cuidados

- `ProtectedRoute` nao substitui autorizacao no servidor;
- token e sessao em localStorage elevam impacto de XSS;
- `PUBLIC_ROUTES` divergem das rotas publicas reais;
- permissoes de rota, sidebar e backend divergem em sete pontos (`topics/permissions-catalog.md`);
- React Query e Zustand coexistem; seguir o padrao do dominio tocado;
- reutilizar componente de `ui/` ou do dominio; nao criar mais um `EmptyState`/`PageHeader`;
- datas de evento so por `lib/wall-clock-datetime.ts`;
- `App.tsx` sem lazy loading; paginas grandes (`ProposalView`, `VenueSettings`, `CreateVenueForm`).

## Leitura minima

`project/frontend-map.md`, pagina/rota, componente de dominio, service, hook/store e tipos. Para API, ler o router e o Zod do backend correspondente em `project/api-endpoints.md`.
