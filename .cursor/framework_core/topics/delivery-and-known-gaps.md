# Delivery and Known Gaps

## Entrega atual

- backend e frontend possuem `vercel.json` (API serverless em `src/server.ts`; SPA com rewrite para `index.html`);
- nao ha CI/CD de produto, gate de PR, cobertura minima nem e2e;
- backend: 48 specs Vitest, focados em `functions/` e use cases de proposal; nenhum teste HTTP de router;
- frontend: 41 testes Vitest em ambiente `node` (sem jsdom), focados em `lib/` e componentes de relatorio, metas, sidebar e proposta;
- `vercel-build` do backend e `prisma generate echo hello`; `main` aponta para `dist/app.js` inexistente;
- observabilidade: console + `GET /`;
- schema chega a producao por deploy request do PlanetScale, sem staging e sem aprovacao obrigatoria (`project/planetscale.md`);
- prova no browser costuma parar no login (BOARD): falta conta de teste e ambiente local com dados.

## Divergencias entre artefatos e codigo (2026-11-10)

| Artefato | Diz | Codigo nos repos |
|---|---|---|
| spec `2026-11-05-assinatura-contrato-docusign` (`05-state`) | `T-01` a `T-03` no codigo, migration `20261105230000_add_docusign_envelope` no repo, `DOCUSIGN_CONNECT_SECRET` no `.env.example` | nenhuma referencia a DocuSign, `contractSignedAt` nem a migration em `backend` ou `frontend` |
| varios task-requests "revisar entrega" | entregues | nao verificados um a um neste mapeamento |

Antes de retomar essas specs, confirmar se o codigo foi perdido, revertido ou ficou em outra maquina, e ler o schema real da `main` com `pscale` somente leitura. Nao recriar migration sem essa confirmacao.

## Lacunas prioritarias observadas

Cada lacuna abaixo esta detalhada, com evidencia e criterios de aceite, em `topics/improvement-backlog.md`.

1. auth e autorizacao de rotas sensiveis (88 publicas);
2. refresh token, `PUBLIC_ROUTES` e contrato FE/BE;
3. segredos/configuracao, CORS, helmet e rate limit;
4. testes de auth, Proposal, Payment e rotas HTTP;
5. transacoes em fluxos multi-escrita;
6. paginacao restante e performance medida;
7. logging estruturado, correlation id, metricas e alertas;
8. consolidacao React Query/Zustand;
9. maquina de estados de Proposal, dinheiro (Float) e timezone;
10. owners, ambientes, rollback e SLOs;
11. alinhamento de permissoes entre sidebar, rotas e backend;
12. dominio `event-hub-dashboard.vercel.app` e remetentes de e-mail fixos no codigo.

## Higiene do repositorio

- backend: dependencias sem uso (pdf-lib, canvas, socket.io, axios, jwt-decode, moment-timezone), tipos em `dependencies`, dois lockfiles, `debug-upload-*.bin`, `yarn-error.log`, schemas `* copy.ts`, `calc-price-per-day.ts` vazio;
- frontend: tres lockfiles, arquivo `Untitled`, FullCalendar/swiper/jspdf-autotable/pdfjs-dist sem uso, paginas sem rota, componentes duplicados em `ui/`.

## Backlog legado

`docs/estado/integracao/TODO_MASTER.md`, `KNOWN_LIMITATIONS.md`, `docs/planos/ROADMAP_TECHNICAL.md`, `PERFORMANCE_PLAN.md` e `OBSERVABILITY_PLAN.md` contem propostas historicas (`topics/legacy-docs-map.md`). Antes de executar qualquer item, confirmar no codigo se ainda existe e converte-lo por `fw:intake` ou `fw:spec`.

## Configuracao divergente

- backend: `FRONTEND_URL` usada e ausente do `.env.example`; `CORS_ORIGIN` no exemplo e ignorada; exemplo contem valor com aparencia de credencial;
- frontend: `.env.example` nao lista `VITE_API_URL` nem `VITE_GOOGLE_CLIENT_ID`.
