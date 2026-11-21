# Tasks — Ate tres fotos na caracteristica

## Ordem macro

`T-01` cria a tabela, o criar, o listar e o excluir com fotos. `T-02` (editar) e `T-03` (apresentacao publica) dependem de `T-01` e podem seguir em paralelo. `T-04` (formulario) depende de `T-02`. `T-05` (modal) depende de `T-03` e do commit da navegacao do modal. `T-06` (banco real) depende de `T-01` e precisa de aprovacao nomeada; roda antes de publicar a API.

## Tasks

### T-01 - Tabela de fotos, criar, listar e excluir com ate 3 fotos

- objetivo: a caracteristica passa a ter fotos na tabela `venue_amenity_image`; criar aceita ate 3 arquivos em `files`; listar devolve `images`; excluir remove todas do storage
- cobre requisitos: `R-01`, `R-02`, `R-03` (envio), `R-07` (excluir), `R-09`, `R-10` (leitura pela tabela)
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `amenityImageStorage`, `assertAmenityImageFile`, `readMultipartPayload`, `handleErrors`, fakes de `venue-amenity.spec.ts`
- prompt recomendado: normal
- estrategia de teste: unitario nos use cases com fakes; `npx prisma validate`
- cenarios obrigatorios: criar com 0, 1 e 3 fotos grava na ordem dos arquivos com `position` 0..2; 4 arquivos recusa sem upload; arquivo nao imagem ou acima de 5 MB recusa sem upload; `imageUrl` no payload e ignorado; sem permissao nao sobe nem grava; listar devolve `images` ordenadas; excluir remove a linha e todas as URLs; caracteristica sem foto lista e exclui sem tocar no storage
- definition of done: model e migration (so `CREATE TABLE` e indice) no repo; router com `upload.array("files", 3)` e erro do multer em 400; `removeImage` e `imageUrl` fora do codigo de criar, listar e excluir; testes do arquivo verdes; linha de `VenueAmenity` e `VenueAmenityImage` em `product/08-data-model.md`

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — upload multiplo
- risco principal: subir arquivo antes de autorizar, ou o 4o arquivo virar 500
- repos tocados: `backend`
- fora de escopo desta task: editar, apresentacao publica, front, banco real
- prova minima desta task: `npx prisma validate` e `npm test -- --run src/use-cases/venue-amenity/venue-amenity.spec.ts`
- criterio de escalada: se o Prisma exigir FK fisica ou a migration precisar de DML, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`, `node`, `patterns`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `03-design.md#Falhas, casos de borda e invariantes`, `topics/data-and-migrations.md#Regras`, `.cursor/framework_global/framework-libs/database/index.md`
- caminhos candidatos: `prisma/schema.prisma` (`VenueAmenity`); `prisma/migrations/20261112120000_add_venue_amenity_media/`; `src/router/venue-amenity.ts`; `src/functions/venue-amenity-image.ts`; `src/repositories/*/venue-amenity-*`; `src/use-cases/venue-amenity/create-*`, `list-*`, `delete-*`
- palavras-chave ou simbolos de busca: `VenueAmenity`, `upload.single`, `req.file`, `AmenityImageStorage`, `assertAmenityImageFile`
- testes provaveis: `src/use-cases/venue-amenity/venue-amenity.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, front, apresentacao publica

### T-02 - Editar com a lista final ordenada de fotos

- objetivo: editar recebe `payload.images` (`{ id }` e `{ newIndex }`) e `files`, e grava exatamente aquela lista e ordem; fotos que saem vao embora do storage depois do banco
- cobre requisitos: `R-03` (resultado), `R-04`, `R-05`, `R-06`, `R-07` (editar), `R-08`, `R-09`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: repository e fakes de `T-01`; ordem do use case em `03-design.md#Falhas, casos de borda e invariantes`
- prompt recomendado: normal
- estrategia de teste: unitario no use case e no schema
- cenarios obrigatorios: reordenar 3 salvas; remover 1 e adicionar 1 numa posicao do meio; remover todas; 2 salvas + 2 novas recusa; id de outra caracteristica, id repetido, `newIndex` fora e arquivo sem referencia recusam sem upload; segundo upload falhando remove o primeiro e nao grava; `images` ausente mantem as fotos e com arquivo recusa; sem permissao nao sobe
- definition of done: `updateVenueAmenitySchema` com `images` e sem `removeImage`; use case e repository em transacao; testes do arquivo verdes; `project/api-endpoints.md` com `files` e `images` em criar e editar

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — ids de foto vindos do cliente e upload
- risco principal: apagar foto de outra caracteristica, ou remover foto antiga do storage antes de gravar
- repos tocados: `backend`
- fora de escopo desta task: criar, apresentacao publica, front, banco real
- prova minima desta task: `npm test -- --run src/use-cases/venue-amenity/venue-amenity.spec.ts`
- criterio de escalada: se a transacao nao couber no repository atual, parar e registrar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Falhas, casos de borda e invariantes`
- libs obrigatorias: `node`, `patterns`, `database`
- documentos obrigatorios: `03-design.md#Falhas, casos de borda e invariantes`, `03-design.md#Contratos e dados`, `.cursor/framework_global/framework-libs/patterns/index.md`
- caminhos candidatos: `src/use-cases/venue-amenity/update-*`; `src/zod/venue-amenity/update-venue-amenity-schema.ts`; `src/repositories/*/venue-amenity-*`
- palavras-chave ou simbolos de busca: `UpdateVenueAmenityUseCase`, `removeImage`, `newIndex`, `$transaction`
- testes provaveis: `src/use-cases/venue-amenity/venue-amenity.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, front

### T-03 - Fotos na apresentacao publica

- objetivo: a apresentacao publica devolve `images: string[]` em ordem e `imageUrl` igual a primeira foto
- cobre requisitos: `R-11`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: `toProposalPresentation` e o select de `amenities`
- prompt recomendado: smart
- estrategia de teste: unitario do pacote publico
- cenarios obrigatorios: 3 fotos saem na ordem de `position`; sem foto sai `images: []` e `imageUrl: null`; id de foto, venueId e dono nao saem
- definition of done: select e tipo `ProposalPresentationAmenity` atualizados; teste do pacote publico verde

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — resposta publica
- risco principal: devolver id de foto ou dado interno do venue
- repos tocados: `backend`
- fora de escopo desta task: upload, editar, front
- prova minima desta task: `npm test -- --run src/use-cases/proposal/get-proposal-presentation/use-case-get-proposal-presentation.spec.ts`
- criterio de escalada: se o select precisar de campo alem da URL e da ordem, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`
- documentos obrigatorios: `03-design.md#Contratos e dados`
- caminhos candidatos: `src/functions/to-proposal-presentation.ts`; select de `amenities` em `src/repositories/in-prisma/proposal-in-prisma-repository.ts`; `src/repositories/interface/proposal-repository-interface.ts`
- palavras-chave ou simbolos de busca: `ProposalPresentationAmenity`, `amenities`
- testes provaveis: `src/use-cases/proposal/get-proposal-presentation/use-case-get-proposal-presentation.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`

### T-04 - Formulario com ate 3 fotos, mover e remover

- objetivo: criar e editar caracteristica mostram as fotos em miniaturas com mover para a esquerda, mover para a direita e remover; o envio segue o contrato de `T-02`
- cobre requisitos: `R-12`
- depende de: `T-02`
- pode rodar em paralelo com: `T-05`
- reusa: `amenityFormData`, toast da secao, Zustand atual
- prompt recomendado: normal
- estrategia de teste: unitario das funcoes puras de `lib/amenity-form.ts`; build
- cenarios obrigatorios: `initialPhotos` usa `images` em ordem; `addPhotos` com 1 na lista e 4 arquivos aceita 2 e devolve 2 descartados; `movePhoto` nas pontas nao muda; `removePhoto` de nova e de salva; `amenityPhotoPayload` com salva, nova, salva gera `[{id},{newIndex:0},{id}]` e um arquivo; criar nao leva `images`; editar sem fotos leva `images: []`
- definition of done: tipos, service, store e secao sem `file` e `removeImage`; formulario com grid de miniaturas e input `multiple` que some com 3; `previewUrl` revogado; `npm test -- --run src/lib/amenity-form.test.ts` e `npm run build` verdes

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — envio de arquivos
- risco principal: ordem dos `newIndex` nao bater com a ordem dos arquivos no `FormData`
- repos tocados: `frontend`
- fora de escopo desta task: modal publico, arrastar e soltar, miniatura na tabela
- prova minima desta task: `npm test -- --run src/lib/amenity-form.test.ts` e `npm run build`
- criterio de escalada: se a reordenacao exigir biblioteca nova, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Decisoes arquiteturais importantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Decisoes arquiteturais importantes`, `03-design.md#Contratos e dados`, `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `src/lib/amenity-form.ts`; `src/components/venue-amenity/venue-amenity-form.tsx`; `venue-amenity-section.tsx`; `src/services/venue-amenity.service.ts`; `src/types/venue-amenity.ts`
- palavras-chave ou simbolos de busca: `AmenityFormSubmit`, `amenityFormData`, `removeImage`, `setFile`
- testes provaveis: `src/lib/amenity-form.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, backend

### T-05 - Grid de fotos no modal publico da caracteristica

- objetivo: o modal do "?" mostra 1, 2 ou 3 fotos em grid; o "?" aparece com pelo menos uma foto; a navegacao entre caracteristicas segue igual
- cobre requisitos: `R-13`
- depende de: `T-03`; commit da navegacao do modal (`02-clarify.md#Itens bloqueantes`)
- pode rodar em paralelo com: `T-04`
- reusa: `PublicServiceDetailDialog`, `hasAmenityDetail`
- prompt recomendado: smart
- estrategia de teste: unitario do modal e de `hasAmenityDetail`
- cenarios obrigatorios: 1 foto com `col-span-2`; 2 fotos lado a lado; 3 com a primeira em `col-span-2`; string vazia em `images` ignorada; modal de servico so com `imageUrl` continua igual; item so com fotos mostra "?"; setas e contador continuam com `images`
- definition of done: prop `images` no modal; tipo `amenities` com `images` em `proposal.service.ts`; `ProposalView` passa `images`; `npm test -- --run src/lib/amenity-video.test.ts src/components/proposal/forms/PublicServiceDetail.test.tsx` e `npm run build` verdes

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: mudar o modal dos servicos ou quebrar a navegacao nao commitada
- repos tocados: `frontend`
- fora de escopo desta task: formulario, ampliar foto, carrossel
- prova minima desta task: `npm test -- --run src/lib/amenity-video.test.ts src/components/proposal/forms/PublicServiceDetail.test.tsx`
- criterio de escalada: se a navegacao ainda nao estiver commitada, parar e pedir o commit
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Decisoes arquiteturais importantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Decisoes arquiteturais importantes`, `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `src/components/proposal/forms/PublicServiceDetail.tsx`; `src/lib/amenity-video.ts`; bloco "Conheça nosso espaço" em `src/pages/ProposalView.tsx`; `src/services/proposal.service.ts`
- palavras-chave ou simbolos de busca: `PublicServiceDetailDialog`, `hasAmenityDetail`, `amenityDetail`, `detailedAmenities`
- testes provaveis: `src/lib/amenity-video.test.ts`, `src/components/proposal/forms/PublicServiceDetail.test.tsx`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, backend

### T-06 - Levar a tabela para a main e copiar a foto atual

- objetivo: a tabela `venue_amenity_image` chega na `main` por deploy request e a foto que existe em `imageUrl` vira a primeira foto da caracteristica
- cobre requisitos: `R-10` (dado real)
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`, `T-03`, `T-04`, `T-05`
- reusa: fluxo de branch e deploy request de `project/planetscale.md#Fluxo real de schema`; query de copia em `03-design.md#Contratos e dados`
- prompt recomendado: smart
- estrategia de teste: leitura na `main` com `--role reader`
- cenarios obrigatorios: `pscale deploy-request diff` so com `CREATE TABLE` e indice; depois da copia, `venue_amenity_image` tem 1 linha por caracteristica com `imageUrl`; rodar a copia de novo nao duplica
- definition of done: deploy request aplicado com aprovacao nomeada; copia rodada com aprovacao nomeada da query exata; contagens registradas em `05-state.md`; `project/planetscale.md` com o numero do deploy request

#### Context Pack

- frente principal: banco
- superficie sensivel: sim — escrita em producao
- risco principal: aplicar DDL ou copia sem aprovacao, ou duplicar a foto
- repos tocados: nenhum (banco `ar756`)
- fora de escopo desta task: apagar a coluna `imageUrl`, publicar API ou front
- prova minima desta task: `SELECT COUNT(*) FROM venue_amenity_image` igual a `SELECT COUNT(*) FROM venue_amenity WHERE imageUrl IS NOT NULL` na `main`
- criterio de escalada: qualquer diff alem da tabela nova, ou contagem diferente, parar
- nivel de autonomia: `L1`

#### Minimal Read Set

- ler primeiro: `project/planetscale.md#Permissoes do agente`
- libs obrigatorias: `database`
- documentos obrigatorios: `project/planetscale.md#Fluxo real de schema`, `project/planetscale.md#Convencoes da CLI`, `03-design.md#Rollout, observabilidade e rollback`
- caminhos candidatos: `prisma/migrations/<data>_add_venue_amenity_image/migration.sql`
- palavras-chave ou simbolos de busca: `venue_amenity_image`, `deploy-request`
- testes provaveis: leitura com `pscale sql ... --role reader`
- nao ler por padrao: `04-tasks.md` inteiro, codigo do front
