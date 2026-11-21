# Design — Biblioteca de fotos do espaco

## Visao geral da solucao

A foto passa a existir uma vez em `venue_photo`. Os usos (`image`, `service`, `venue_amenity_image`, `emailConfig`) guardam `photoId` e mantem a URL antiga como copia para nao quebrar paginas publicas. O unico caminho de upload novo e `POST /venue-photo/upload` (WebP, S3 unico). O painel ganha a pagina "Fotos" e o `PhotoPicker`, usado em todos os consumidores; "enviar nova" sobe pela biblioteca e ja seleciona.

Passada transversal:

- architecture: sim, leve. Novo modulo `venue-photo` e referencia por `photoId` nos usos; sem mudanca de topologia HTTP geral. Sem ADR.
- database: sim. Tabela `venue_photo`, colunas `photoId`/`backgroundPhotoId`, indices, backfill DML com aprovacao.
- design: sim. Item na sidebar, pagina de biblioteca, dialogo `PhotoPicker`.
- observability: nao. Erro HTTP e toast atuais bastam.
- security: sim. Upload autenticado, permissoes novas, escritas `/image/*` deixam de ser PUB; leituras publicas intencionais permanecem.
- patterns/06: sim. Backfill e backfill de permissao idempotentes; exclusao checa usos antes de apagar S3; upload multiplo com compensacao se gravacao falhar apos o S3.

## Componentes e modulos impactados

Backend (`art56_server_v3/`):

- `prisma/schema.prisma`: `VenuePhoto`; `photoId` em `Image`, `Service`, `VenueAmenityImage`; `backgroundPhotoId` em `EmailConfig`
- `prisma/migrations/<data>_add_venue_photo/`
- `src/services/upload-config-sw.ts` (S3 unico) e novo helper de upload WebP compartilhado
- `src/router/venue-photo.ts` + use cases/zod/repository
- `src/router/image.ts`: auth nas escritas; create/update aceitam `photoId`
- `src/router/service.ts`, `venue-amenity.ts`, email-config, `proposal` (`image-choice`)
- enum/lista de permissoes + SQL de backfill de permissao

Frontend (`eventhub-vista-dashboard/`):

- `sidebar-nav-model.ts`, `VenueNav.tsx` (`Fotos: Images`), `App.tsx`, `types/permissions.ts`
- `pages/VenuePhotos.tsx` (ou `pages/photos/`)
- `components/photo/PhotoPicker.tsx` (+ service/store leves, reusando padrao Zustand/Query existente)
- consumidores: `image-form.tsx`, `ProposalView.tsx`, `SelectVenueImagesForm.tsx`, `service-form.tsx`, `venue-amenity-form.tsx`, `EmailTab.tsx`

Docs: `product/08-data-model.md`, `project/api-endpoints.md`, `topics/permissions-catalog.md`.

## Reuso previsto

- sharp + padrao WebP 1200/80 de `create-image`
- cliente S3 de `upload-config-sw.ts` (eliminar o segundo `S3Client` de `image.ts` nas escritas novas)
- `presentNavItems` / `venueSections` / `ProtectedRoute`
- seletor de catalogo ja existente na proposta (`ProposalView`) como referencia de UX, nao de dados
- nao reusar uploads de `service-image-storage` / `venue-amenity-image-storage` para arquivos novos; so leitura/delete legado durante a transicao

## Contratos e dados

```prisma
model VenuePhoto {
  id          String   @id @default(cuid())
  venueId     String
  url         String   @db.VarChar(1024)
  storageKey  String   @db.VarChar(512)
  width       Int?
  height      Int?
  sizeBytes   Int?
  description String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  venue       Venue    @relation(fields: [venueId], references: [id], onDelete: Cascade)

  @@index([venueId])
  @@index([venueId, url(length: 191)])
  @@map("venue_photo")
}
```

Colunas aditivas (sem FK fisica; `relationMode = prisma`):

- `Image.photoId String?` + indice
- `Service.photoId String?` + indice
- `VenueAmenityImage.photoId String?` + indice
- `EmailConfig.backgroundPhotoId String?` + indice

Backfill (aprovacao nomeada, idempotente):

1. para cada `(venueId, url)` distinto em `image` (com `venueId`), `service`, `venue_amenity_image` (via amenity->venue) e `emailConfig`, inserir `venue_photo` se ainda nao existir
2. `storageKey` derivado da URL (`...amazonaws.com/<key>`) quando o formato bater; senao gravar a URL completa em `storageKey` com prefixo `legacy:` e marcar no relatorio
3. atualizar `photoId`/`backgroundPhotoId` onde estiver null
4. relatorio: URLs orfas, URLs sem objeto no S3 (head opcional), fotos so de organizacao ignoradas

Script idempotente: `backfill-venue-photo.sql` nesta pasta. Executado na `main` em 2026-11-14 depois do deploy request `#50`: 46 fotos, nenhuma duplicada, URLs de uso iguais as da biblioteca.

API `venue-photo` (todas autenticadas):

| Metodo | Rota | Permissao | Corpo / notas |
|---|---|---|---|
| GET | `/venue-photo/list?venueId=` | VIEW | lista por `createdAt desc` |
| POST | `/venue-photo/upload` | EDIT | multipart `files` (1..20), `venueId`; WebP; key `venues/{venueId}/photos/{uuid}.webp` |
| PUT | `/venue-photo/:id` | EDIT | `{ description }` |
| GET | `/venue-photo/:id/usages` | VIEW | `{ siteImages, services, amenities, emailConfigs }` com ids/nomes |
| DELETE | `/venue-photo/:id` | EDIT | 409 se usos > 0; senao apaga S3 + linha |

Consumidores (aceitar `photoId` no lugar de arquivo):

- criar/atualizar `image` (venue): se `photoId`, copia `url` para `imageUrl` e nao sobe arquivo; se arquivo, primeiro cria `venue_photo` (exige `EDIT_VENUE_PHOTOS`) ou rejeita e manda usar o upload da biblioteca — **decisao:** telas do painel so enviam `photoId`; API ainda pode aceitar arquivo legado ate `T-08`, mas o caminho canônico e `photoId`
- `service` / `venue-amenity` / `emailConfig`: idem
- `image-choice` da proposta: continua escolhendo linhas `image` com `isShowOnProposal`; o catalogo visual do dono passa a vir do `PhotoPicker` ao criar/atualizar a linha `image` ligada

Auth `/image/*`:

- escritas venue (`POST /upload`, `PUT /update`, `DELETE /delete/:id`): `ensureAuthenticate` + permissao de site (`EDIT_VENUE_SITE`) ou fotos (`EDIT_VENUE_PHOTOS`) conforme a operacao; preferencia: delete/update de uso de site = `EDIT_VENUE_SITE`; criar via biblioteca = `EDIT_VENUE_PHOTOS`
- leituras `GET /list`, `GET /getByTag`: permanecem PUB
- variantes organization: fora desta entrega (premissa)

Permissoes:

- strings novas no catalogo backend e no enum front
- backfill SQL: se `permissions` contem `VIEW_VENUE_SITES` e nao contem `VIEW_VENUE_PHOTOS`, concatena; idem `EDIT_VENUE_SITE` -> `EDIT_VENUE_PHOTOS`

## Falhas, casos de borda e invariantes

- invariante: nenhum uso grava `photoId` de outro `venueId`
- invariante: `imageUrl`/`backgroundImageUrl` do uso = `venue_photo.url` quando `photoId` esta preenchido
- invariante: `DELETE venue_photo` so com zero usos
- upload multiplo: sobe para S3, grava linhas; se a gravacao falhar apos N uploads, remove do S3 as keys novas daquele request
- "enviar nova" sem `EDIT_VENUE_PHOTOS`: 403; UI esconde o botao
- foto enviada e cadastro cancelado: linha em `venue_photo` permanece
- nao apagar `venue_photo` automaticamente quando um uso troca de foto

## Decisoes arquiteturais importantes

- biblioteca dedicada (`venue_photo`) em vez de reusar `image`, porque `image` carrega semantica de uso (tag/group/flags)
- URL duplicada no uso durante a transicao, para nao forcar join em `getWebData` nem mudar o site avulso
- um unico servico de upload WebP; consumidores nao recebem mais `multipart` de imagem no fluxo novo do painel
- `PhotoPicker` e o unico UI de escolha; atalho "enviar nova" e obrigatorio
- logo fica fora (identidade, nao foto do espaco)

Alternativas descartadas:

- reusar `image` como catalogo: mistura uso e asset
- apagar colunas de URL na v1: quebra publicos
- biblioteca da organizacao na v1: fora do pedido

## Riscos, rollout, observabilidade e rollback

- risco: backfill incompleto deixa `photoId` null; painel novo exige foto da biblioteca — mitiga: backfill antes do front, e UI ainda mostra URL legada se `photoId` null na primeira iteracao dos formularios
- risco: fechar escrita `/image/*` sem o front novo: mitiga ordem API biblioteca -> page -> wire; auth nas escritas junto de `T-04` depois que o painel ja pode usar `photoId`
- rollout: (1) schema+API+backfill+permissoes (2) pagina Fotos (3) PhotoPicker e consumidores (4) remover inputs de arquivo
- rollback schema: revert do deploy request na janela; backfill so adiciona dados
- observability: logs/erros HTTP existentes; sem dashboard novo

## Estrategia de validacao

- backend: `npx prisma validate`; vitest dos use cases `venue-photo`, image/service/amenity/email com `photoId`, auth negativa nas escritas `/image`
- banco: `pscale` leitura apos deploy; contagem de `venue_photo` vs URLs distintas
- frontend: vitest do picker/helpers; `npm run build`; browser: subir em Fotos, escolher em caracteristica com "enviar nova", bloquear delete em uso, proposta e site com URLs iguais

## Fontes determinantes

- `task-requests/catalogo-fotos-espaco-request.md`
- `project/api-endpoints.md` (bloco `/image/*` PUB)
- `topics/permissions-catalog.md`
- `project/planetscale.md`
- `topics/public-pages-and-branding.md`
- `topics/data-and-migrations.md`
- schema Prisma e specs de midia da caracteristica/servico/proposta
