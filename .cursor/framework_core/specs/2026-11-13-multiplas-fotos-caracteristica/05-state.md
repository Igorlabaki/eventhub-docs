# State — Ate tres fotos na caracteristica

## Snapshot

- status: `T-01` a `T-06` executadas em 2026-11-13; codigo dos dois repos nao commitado (so a navegacao do modal foi commitada, `7fb4347`); browser nao exercitado
- ultima task concluida: `T-06`
- task em andamento: nenhuma
- proxima task exata: nenhuma; falta browser, commit, publicar API, rodar a copia de novo e publicar o front
- prova mais recente: backend `venue-amenity.spec.ts` (22) e `use-case-get-proposal-presentation.spec.ts` (11) verdes; `npx prisma validate` ok; frontend `amenity-form.test.ts` (11), `amenity-video.test.ts` (7) e `PublicServiceDetail.test.tsx` (10) verdes; eslint limpo nos arquivos tocados; `npm run build` ok
- banco: deploy request `#48` `complete_pending_revert`; `SHOW CREATE TABLE venue_amenity_image` bate com a migration; copia: 1 linha (`fotos=1`, `comImageUrl=1`, `batem=1`)
- `tsc`: nenhum erro novo nos arquivos da feature; segue o erro antigo de `Proposal` em `ProposalView.tsx:1239`

## Delta da ultima task

- mudou: `T-05` grid de 1, 2 ou 3 fotos no `PublicServiceDetailDialog` (prop `images`, sem `images` cai no `imageUrl`); `hasAmenityDetail` conta `images`; `ProposalView` passa `images` e `imageUrl`; `T-06` tabela na `main` e copia da foto atual
- ficou pendente: rodar a copia de novo depois de publicar a API (idempotente, `03-design.md#Rollout, observabilidade e rollback`); browser do painel e da proposta
- lacunas de prova: sem teste HTTP do multer (so a traducao do erro); transacao do Prisma nao exercitada contra banco; painel e proposta nao abertos no browser

## Decisoes recentes

- fotos removidas calculadas antes de gravar, sem depender do objeto devolvido pelo repository
- `ProposalView` passa `imageUrl` junto de `images` para o front novo funcionar contra a API antiga
- aviso de fotos descartadas inline no formulario (`role="status"`), sem toast
- `venue_amenity.imageUrl` segue no schema e na `main`, sem leitura nem escrita no codigo

## Riscos ou bloqueios

- painel sem compatibilidade com o contrato antigo: publicar API e front em sequencia curta
- foto gravada pela API antiga entre a copia e a publicacao da API nova so entra na tabela com a segunda copia
- janela de revert do `#48` aberta; branch `add-venue-amenity-image` segue aberta

## Memoria promovida

- `product/08-data-model.md`: `VenueAmenityImage` e `imageUrl` legado
- `project/api-endpoints.md`: `files` e `images` em criar e editar
- `project/planetscale.md`: deploy request `#48` e copia
- topics, project-decisions e ADRs: nenhum

## Veredito

- veredito: lote entregue em L2; nao marcar pronto para producao
- bloqueantes: browser, commit nos dois repos, segunda copia depois da API
- achados: nenhum
