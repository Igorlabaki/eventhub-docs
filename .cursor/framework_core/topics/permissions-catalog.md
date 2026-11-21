# Permissions Catalog — EventHub

Estado atual das permissoes, observado em 2026-11-10. Desejo de autorizacao por recurso fica em spec; aqui e fato.

## Modelo

- permissoes sao strings CSV em `UserVenuePermission.permissions` (por UserOrganization + Venue) e `UserOrganizationPermission.permissions` (por UserOrganization), colunas LongText;
- `role` e opcional e nao e usado para decidir acesso;
- criar venue concede ao criador todas as permissoes de venue (`venue-in-prisma-repository.create`); criar organizacao concede as de organizacao;
- migrations de backfill (`*_backfill_venue_rule_permissions`, `*_backfill_venue_amenity_permissions`) deram `VIEW/EDIT_VENUE_RULES` e `VIEW/EDIT_VENUE_AMENITIES` a quem ja tinha `VIEW/EDIT_VENUE_SERVICES` (via `FIND_IN_SET`). Permissao nova segue esse padrao de backfill.
- `VIEW_VENUE_PHOTOS` e `EDIT_VENUE_PHOTOS` entram na concessao de quem cria o espaco. O backfill a partir de `VIEW_VENUE_SITES` e `EDIT_VENUE_SITE` foi aplicado na `main` em 2026-11-14 (9 linhas de cada).

## Permissoes de venue (backend)

| Grupo | Permissoes |
|---|---|
| proposta, ver | `VIEW_PROPOSAL_INFO`, `VIEW_PROPOSAL_DATES`, `VIEW_PROPOSAL_HISTORY`, `VIEW_PROPOSAL_SCHEDULE`, `VIEW_PROPOSAL_PAYMENTS`, `VIEW_PROPOSAL_DOCUMENTS`, `VIEW_PROPOSAL_ATTENDANCE_LIST` |
| proposta, enviar | `SEND_PROPOSAL_INFO`, `SEND_PROPOSAL_TEXT`, `SEND_PROPOSAL_LINKS`, `SEND_PROPOSAL_DOCUMENTS` |
| proposta, editar | `EDIT_PROPOSAL_INFO`, `EDIT_PROPOSAL_DATES`, `EDIT_PROPOSAL_SCHEDULE`, `EDIT_PROPOSAL_PAYMENTS`, `EDIT_PROPOSAL_DOCUMENTS`, `EDIT_PROPOSAL_ATTENDANCE_LIST`, `CONFIRM_PROPOSAL_ATTENDANCE_LIST` |
| venue, ver | `VIEW_VENUE_INFO`, `VIEW_VENUE_SITES`, `VIEW_VENUE_PRICES`, `VIEW_VENUE_EVENTS`, `VIEW_VENUE_ANALYSIS`, `VIEW_VENUE_CALENDAR`, `VIEW_VENUE_CONTACTS`, `VIEW_VENUE_SERVICES`, `VIEW_VENUE_RULES`, `VIEW_VENUE_AMENITIES`, `VIEW_VENUE_EXPENSES`, `VIEW_VENUE_PROPOSALS`, `VIEW_VENUE_PERMISSIONS`, `VIEW_VENUE_NOTIFICATIONS`, `VIEW_VENUE_PHOTOS` |
| venue, editar | `EDIT_VENUE_INFO`, `EDIT_VENUE_SITE`, `EDIT_VENUE_EVENTS`, `EDIT_VENUE_PRICES`, `EDIT_VENUE_CALENDAR`, `EDIT_VENUE_EXPENSES`, `EDIT_VENUE_SERVICES`, `EDIT_VENUE_RULES`, `EDIT_VENUE_AMENITIES`, `EDIT_VENUE_CONTACTS`, `EDIT_VENUE_PROPOSALS`, `EDIT_VENUE_PHOTOS` |

## Permissoes de organizacao (backend)

`VIEW_ORG_INFO`, `VIEW_ORG_SITE`, `VIEW_ORG_VENUES`, `VIEW_ORG_OWNERS`, `VIEW_ORG_CONTRACTS`, `VIEW_ORG_PERMISSIONS`, `EDIT_ORG_INFO`, `EDIT_ORG_SITE`, `EDIT_ORG_VENUES`, `EDIT_ORG_OWNERS`, `EDIT_ORG_CONTRACTS`, `EDIT_ORG_PERMISSIONS`.

## Onde o backend verifica

| Mecanismo | Permissao | Escopo |
|---|---|---|
| `ensurePermission` (middleware) | `VIEW_VENUE_CALENDAR`, `EDIT_VENUE_CALENDAR` | so Google Calendar; passa se o usuario tiver a permissao em qualquer venue da organizacao |
| `venue-price-authorizer` | `VIEW/EDIT_VENUE_PRICES` | preco minimo por periodo |
| `venue-rule-authorizer` | `VIEW/EDIT_VENUE_RULES` | regras do espaco |
| `venue-amenity-authorizer` | `VIEW/EDIT_VENUE_AMENITIES` | caracteristicas |
| `venue-photo-authorizer` | `VIEW/EDIT_VENUE_PHOTOS` | biblioteca de fotos do espaco |
| `service-authorizer` | `EDIT_VENUE_SERVICES` | criar, editar, apagar servico |
| `proposal-quote-authorizer` | `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` | `POST /proposal/quote` |
| `replace-proposal-indications` | `SEND_PROPOSAL_INFO` | `PUT /proposal/indications/:id` |
| `venue-site-edit-permission` | `EDIT_VENUE_SITE` | edicao de site do venue |
| sync Google em `data-event` | `EDIT_VENUE_CALENDAR` | so dispara sync se o usuario tiver |

Todo o resto e so `ensureAuthenticate` ou publico (ver `project/api-endpoints.md`). Permissao nao checada no backend nao e garantia, mesmo que a UI esconda.

## Onde o frontend verifica

- enum `Permissions` em `src/types/permissions.ts` inclui `VIEW_VENUE_PHOTOS` e `EDIT_VENUE_PHOTOS`; o item "Fotos" da sidebar usa a permissao de ver;
- `ProtectedRoute` + `panel-route-gate` por rota (`App.tsx`);
- sidebar em `components/sidebar/sidebar-nav-model.ts` esconde itens sem permissao;
- `VenueNav`/`ProposalNav` redirecionam para o primeiro item permitido.

## Divergencias conhecidas

| Ponto | Sidebar | Rota (`App.tsx`) | Backend |
|---|---|---|---|
| Notificacoes | `VIEW_VENUE_NOTIFICATIONS` | `VIEW_VENUE_SITES` | `GET /notification/list` publico |
| Configuracoes do venue | `VIEW_VENUE_CONFIG` (nao existe no backend) | `EDIT_VENUE_INFO` | so auth |
| Editar orcamento | `EDIT_VENUE_PROPOSALS` | `EDIT_VENUE_INFO` | so auth |
| Gerar contrato | `SEND_PROPOSAL_INFO` | `SEND_PROPOSAL_DOCUMENTS` | contrato publico |
| Pagamento | `VIEW_PROPOSAL_PAYMENTS` | `VIEW_PROPOSAL_PAYMENT` (singular, fora do enum) | payment publico |
| Novo orcamento | — | `VIEW_VENUE_NEW_BUDGET` (fora do enum) | criacao publica |
| `/proposal/:id/send`, `/contact` | — | `VIEW_PROPOSAL_SEND`, `VIEW_PROPOSAL_CONTACT` (fora do enum) | — |

Permissao fora do enum nunca existe no CSV gravado, entao a rota tende a negar sempre. Corrigir alinhando sidebar, rota e backend na mesma spec, com backfill quando criar permissao nova.

## Regra para mudancas

Nova capacidade protegida: definir a permissao no backend (lista de concessao do criador + backfill), no enum do frontend, na rota e na sidebar, e provar 401, 403 e acesso permitido. Usa a lib `security`.
