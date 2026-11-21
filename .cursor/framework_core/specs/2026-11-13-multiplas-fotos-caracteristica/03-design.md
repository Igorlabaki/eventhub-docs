# Design — Ate tres fotos na caracteristica

## Visao geral da solucao

Tabela nova `venue_amenity_image` (uma linha por foto, com `position`). Criar recebe ate 3 arquivos no campo `files`. Editar recebe os arquivos novos em `files` e a lista final ordenada em `payload.images`, que mistura `{ id }` de fotos salvas e `{ newIndex }` de arquivos novos. O use case valida tudo, autoriza, sobe os arquivos e grava caracteristica e fotos numa transacao; so depois remove do storage as fotos que sairam. A apresentacao publica devolve `images: string[]`. O formulario guarda uma lista unica de fotos (salvas e novas) com mover e remover. O `PublicServiceDetailDialog` ganha `images` e desenha o grid.

Passada transversal:

- architecture: nao. Mesmo router, use case e repository; o contrato existente muda de forma. Sem ADR.
- database: sim. Tabela nova com indice em `amenityId`, DDL aditiva por deploy request; copia de 1 linha de `imageUrl` com aprovacao nomeada; coluna antiga fica sem uso.
- design: sim. Miniaturas com mover e remover no formulario; grid de 1, 2 ou 3 no modal.
- observability: nao. Erro HTTP e toast atuais.
- security: sim. Upload multiplo; ids de foto vindos do cliente sao checados contra a caracteristica; URL do cliente nunca e gravada.
- patterns/06: sim, so transacao. Caracteristica e fotos gravam em `prisma.$transaction`; storage fica fora da transacao, com limpeza de compensacao. Sem retry, fila ou cache.

## Componentes e modulos impactados

Backend (`art56_server_v3/`):

- `prisma/schema.prisma`: model `VenueAmenityImage`; relacao `images` em `VenueAmenity`
- `prisma/migrations/<data>_add_venue_amenity_image/migration.sql`: so `CREATE TABLE` e indice
- `src/router/venue-amenity.ts`: `upload.array("files", AMENITY_MAX_IMAGES)` com traducao do erro do multer
- `src/functions/venue-amenity-image.ts`: `AMENITY_MAX_IMAGES = 3`, mensagem de limite, `assertAmenityImageFiles`
- `src/zod/venue-amenity/`: `images` no editar; `removeImage` sai
- `src/repositories/interface/venue-amenity-repository-interface.ts` e `in-prisma/venue-amenity-in-prisma-repository.ts`
- `src/use-cases/venue-amenity/`: controllers leem `req.files`; use cases de criar, editar e excluir
- `src/repositories/in-prisma/proposal-in-prisma-repository.ts` (select de `amenities`) e `src/functions/to-proposal-presentation.ts`

Frontend (`eventhub-vista-dashboard/`):

- `src/types/venue-amenity.ts`, `src/services/venue-amenity.service.ts`, `src/store/venueAmenityStore.ts` (so tipos)
- `src/lib/amenity-form.ts`: lista de fotos, funcoes puras e `FormData`
- `src/components/venue-amenity/venue-amenity-form.tsx` e `venue-amenity-section.tsx`
- `src/services/proposal.service.ts` (tipo `amenities`), `src/lib/amenity-video.ts` (`hasAmenityDetail`)
- `src/components/proposal/forms/PublicServiceDetail.tsx` e `src/pages/ProposalView.tsx`

Docs: `product/08-data-model.md`, `project/api-endpoints.md`.

## Reuso previsto

- `amenityImageStorage` (`uploadServiceImage` + `deleteServiceImage`); `deleteServiceImage` ja ignora falha do S3.
- `assertAmenityImageFile` por arquivo.
- `readMultipartPayload` para o `payload` JSON.
- `handleErrors` e `HttpBadRequestError` para a resposta 400 do multer.
- Fakes de `venue-amenity.spec.ts` (`FakeVenueAmenityRepository`, `FakeImageStorage`, `photo`, `row`), estendidos com fotos.
- `PublicServiceDetailDialog`: mesma prop `surfaceStyle`, mesma navegacao; servicos continuam passando `imageUrl`.
- Nao reusar o carrossel de `components/ui/carousel.tsx`.

## Contratos e dados

Tabela:

```prisma
model VenueAmenityImage {
  id        String       @id @default(uuid())
  amenityId String
  imageUrl  String       @db.Text
  position  Int          @default(0)
  createdAt DateTime     @default(now())
  amenity   VenueAmenity @relation(fields: [amenityId], references: [id], onDelete: Cascade)

  @@index([amenityId])
  @@map("venue_amenity_image")
}
```

`VenueAmenity` ganha `images VenueAmenityImage[]`. `imageUrl` continua no model, sem leitura nem escrita no codigo.

Copia da foto atual (`T-06`, aprovacao nomeada, idempotente):

```sql
INSERT INTO venue_amenity_image (id, amenityId, imageUrl, position, createdAt)
SELECT UUID(), a.id, a.imageUrl, 0, NOW(3)
FROM venue_amenity a
WHERE a.imageUrl IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM venue_amenity_image i WHERE i.amenityId = a.id);
```

Criar (`POST /venue-amenity/create`, multipart):

- `payload`: `venueId`, `name`, `description?`, `videoUrl?`
- `files`: 0 a 3 arquivos; a ordem dos arquivos e a ordem das fotos

Editar (`PUT /venue-amenity/update`, multipart):

- `payload`: `amenityId`, `name`, `position?`, `description?`, `videoUrl?`, `images?`
- `images`: `Array<{ id: string } | { newIndex: number }>`, maximo 3
- `files`: arquivos novos; `newIndex` aponta para o indice em `files`
- `images` ausente: fotos ficam como estao; `files` com algo nesse caso e 400

Resposta de criar, editar e listar: a linha da caracteristica com `images: { id, imageUrl, position }[]` em ordem de `position`, sem `imageUrl` legado no tipo do front.

Apresentacao publica: `ProposalPresentationAmenity` vira `name`, `position`, `description`, `videoUrl`, `images: string[]` e `imageUrl: string | null` (= `images[0] ?? null`, compatibilidade). O select pede `images: { select: { imageUrl: true }, orderBy: [{ position: "asc" }, { createdAt: "asc" }] }`.

Repository:

- `create(data, imageUrls: string[])`: cria a caracteristica e as fotos com `position` = indice, numa transacao; devolve com `images`
- `update(data, images?: { id?: string; imageUrl: string }[])`: com `images`, apaga as fotos da caracteristica fora da lista, cria as sem `id`, regrava `position` de todas, tudo na mesma transacao da atualizacao da caracteristica; sem `images`, nao toca nas fotos
- `getById` e `listByVenue` incluem `images` ordenadas
- `delete` apaga fotos e caracteristica numa transacao e devolve a linha com `images`

## Falhas, casos de borda e invariantes

Ordem no editar:

1. `assertAmenityImageFiles(files)`: maximo 3 e cada um `image/*` ate 5 MB
2. busca a caracteristica com fotos; 404 se nao existe
3. autoriza `EDIT_VENUE_AMENITIES` no venue dela
4. nome duplicado: 409
5. valida `images` contra as fotos atuais e os arquivos (regras abaixo)
6. sobe os arquivos novos, um por vez; se um falhar, remove os ja enviados e repassa o erro
7. grava caracteristica e fotos numa transacao; se falhar, remove os enviados e repassa o erro
8. remove do storage as URLs que sairam

Regras de `images`:

- tamanho maximo 3: senao "A caracteristica aceita no maximo 3 fotos"
- cada `id` existe nas fotos desta caracteristica e aparece uma vez
- cada `newIndex` e inteiro entre 0 e `files.length - 1` e aparece uma vez
- todo arquivo enviado e referenciado por um `newIndex`
- violacao: 400 "Foto da caracteristica invalida", antes de qualquer upload

Criar: passos 1, 3, 4, 6 e 7. Excluir: busca com fotos, autoriza, apaga, remove cada URL do storage.

Multer: `upload.array("files", 3)` dentro de um wrapper no router. `MulterError` `LIMIT_UNEXPECTED_FILE` ou `LIMIT_FILE_COUNT` vira 400 com a mensagem de limite; `LIMIT_FILE_SIZE` vira 400 "A foto da caracteristica passa de 5 MB". Hoje nao ha handler de erro no `server.ts`, entao sem o wrapper o erro vira 500.

Invariantes:

- `position` das fotos e 0, 1, 2 contiguo depois de cada gravacao
- nenhuma foto antiga sai do storage antes do banco gravar
- `imageUrl` vindo no payload e ignorado (zod nao declara o campo)
- foto e video seguem independentes

## Decisoes arquiteturais importantes

- Tabela propria, e nao JSON em `imageUrl`: ordenar, remover por id e validar dono ficam simples, e o indice em `amenityId` atende o select publico.
- A lista final ordenada no editar (e nao operacoes add/remove/move): um pedido descreve o estado inteiro; o backend so compara com o atual.
- Storage fora da transacao com compensacao: S3 nao participa de transacao; foto orfa so sobra se a propria limpeza falhar, igual ao servico.
- No formulario, uma lista unica `AmenityPhoto[]`:

  ```ts
  type AmenityPhoto =
    | { kind: "existing"; id: string; url: string }
    | { kind: "new"; key: string; file: File; previewUrl: string };
  ```

  Funcoes puras em `lib/amenity-form.ts`: `initialPhotos(amenity)`, `addPhotos(list, files)` (devolve `{ list, skipped }`, respeitando 3), `movePhoto(list, index, delta)`, `removePhoto(list, index)`, `amenityPhotoPayload(list)` (devolve `{ images, files }` com `newIndex` na ordem de `files`). `amenityFormData(payload, files)` faz um `append("files", ...)` por arquivo. `previewUrl` vem de `URL.createObjectURL` e e revogado ao remover e ao desmontar.
- Miniaturas em `grid grid-cols-3 gap-2`, `aspect-square object-cover`; botoes com `aria-label` "Mover foto para a esquerda", "Mover foto para a direita" e "Remover foto"; o primeiro nao move para a esquerda e o ultimo nao move para a direita. O input `type="file" multiple accept="image/*"` some com 3 fotos e limpa o `value` depois de cada escolha.
- No criar, o payload nao leva `images`; os arquivos vao na ordem da tela. No editar, sempre leva `images` (mesmo vazio, para remover todas).
- Modal: `PublicServiceDetailDialog` recebe `images?: string[] | null`. Fotos = `images` filtradas por string nao vazia; sem `images`, cai em `imageUrl` (servicos). Grid `grid grid-cols-2 gap-2`:
  - 1 foto: `col-span-2`, `h-auto w-full`
  - 2 fotos: cada uma `aspect-square object-cover`
  - 3 fotos: a primeira `col-span-2 aspect-video object-cover`, as outras `aspect-square object-cover`
  - `rounded-md`, `alt=""`, `key` pela URL
- `hasAmenityDetail` passa a olhar `images?.some(...)` alem de descricao e video; `ProposalView` passa `images={amenityDetail?.images}`.

## Riscos e mitigacoes

- Foto atual sumir: copia unica em `T-06`, conferida por leitura na `main`; a apresentacao publica continua com `imageUrl` para a pagina antiga.
- Janela entre API e front do painel: publicar os dois em sequencia; quem salvar nesse intervalo recebe 400 e tenta de novo.
- Conflito com a navegacao nao commitada: `T-05` comeca depois do commit dela.
- Foto orfa no S3: compensacao no use case; falha da propria limpeza e aceita.

## Rollout, observabilidade e rollback

Ordem:

1. branch do PlanetScale a partir da `main`, DDL da tabela, deploy request (aprovacao nomeada para aplicar)
2. copia da foto atual (aprovacao nomeada da query exata)
3. publicar a API
4. rodar a copia de novo (idempotente) para pegar foto gravada pela API antiga entre 2 e 3
5. publicar o front

- Sem metrica nova.
- Rollback: revert do deploy request enquanto a janela existir e voltar a versao anterior da API e do front; a coluna `imageUrl` nunca deixou de ter a foto antiga.

## Estrategia de validacao

- Backend: `venue-amenity.spec.ts` com fakes que guardam fotos; `use-case-get-proposal-presentation.spec.ts` com `images`; `npx prisma validate`.
- Frontend: `amenity-form.test.ts` para as funcoes puras; `amenity-video.test.ts` para `hasAmenityDetail`; `PublicServiceDetail.test.tsx` para o grid de 1, 2 e 3 e para o modal de servico sem `images`; `npm run build`.
- Banco: `pscale deploy-request diff` conferido; contagem lida na `main` depois da copia.
- Browser: criar com 3, reordenar, remover e abrir o modal publico; o login tem bloqueado as specs recentes.

## Docs determinantes

- `project/planetscale.md#Fluxo real de schema` e `#Permissoes do agente`: deploy request so leva DDL; SQL de escrita exige aprovacao
- `topics/data-and-migrations.md#Regras`: fases aditivas e `$transaction`
- `specs/2026-11-05-foto-video-descricao-caracteristica/03-design.md`: upload no use case depois da autorizacao
- codigo: `venue-amenity.ts` (router), use cases de `venue-amenity`, `venue-amenity.spec.ts`, `amenity-form.ts`, `venue-amenity-form.tsx`, `PublicServiceDetail.tsx`, select de `amenities` em `proposal-in-prisma-repository.ts`
