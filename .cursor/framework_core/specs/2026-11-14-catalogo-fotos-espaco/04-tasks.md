# Tasks — Biblioteca de fotos do espaco

## Ordem macro

`T-01` schema. `T-02` API da biblioteca + permissoes + upload unificado. `T-03` backfill (aprovacao). `T-04` consumidores aceitam `photoId` e escritas `/image/*` autenticadas. `T-05` pagina Fotos + sidebar. `T-06` `PhotoPicker`. `T-07` liga site, proposta e hub. `T-08` liga servicos, caracteristicas e e-mail e remove uploads diretos do painel.

`T-05` pode comecar depois de `T-02` (contra API real ou mock). `T-06` depende de `T-05` tipos/service. `T-07` e `T-08` dependem de `T-04` e `T-06`.

## Tasks

### T-01 - Schema `venue_photo` e colunas `photoId`

- objetivo: criar a tabela da biblioteca e as colunas opcionais nos usos, so com DDL aditiva
- cobre requisitos: `R-01`, `R-02`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: padrao de migration das specs recentes (`venue_amenity_image`)
- prompt recomendado: normal
- estrategia de teste: `npx prisma validate`
- cenarios obrigatorios: model `VenuePhoto` mapeado; `photoId`/`backgroundPhotoId` opcionais com indice; migration so `CREATE TABLE`/`ALTER TABLE ... ADD`; sem FK fisica; `Venue` ganha relacao `photos`
- definition of done: schema e pasta de migration no repo; `product/08-data-model.md` atualizado; deploy request na `main` so com aprovacao nomeada (pode ficar para o fim de `T-01` ou junto de `T-03`)

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — schema de producao
- risco principal: DDL nao aditiva ou FK fisica no PlanetScale
- repos tocados: `backend`
- fora de escopo desta task: API, backfill DML, front
- prova minima desta task: `npx prisma validate`
- criterio de escalada: se o Prisma exigir FK fisica, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`, `node`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `topics/data-and-migrations.md#Regras`, `project/planetscale.md#Fluxo real de schema`
- caminhos candidatos: `prisma/schema.prisma` (`Image`, `Service`, `VenueAmenityImage`, `EmailConfig`, `Venue`); `prisma/migrations/`
- palavras-chave ou simbolos de busca: `model Image`, `model VenueAmenityImage`, `model EmailConfig`, `@@map("image")`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: front, `04-tasks.md` inteiro, `security`

### T-02 - API `venue-photo`, upload WebP e permissoes

- objetivo: listar, enviar (varias), editar descricao, listar usos e excluir fotos; criar `VIEW_VENUE_PHOTOS` e `EDIT_VENUE_PHOTOS` com backfill SQL idempotente
- cobre requisitos: `R-04`, `R-05`, `R-06` (backend), `R-13`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `upload-config-sw.ts`, sharp do create-image, padrao router -> controller -> use case -> repository
- prompt recomendado: normal
- estrategia de teste: vitest dos use cases com fake de storage; teste de 409 com usos
- cenarios obrigatorios: upload 1 e N arquivos WebP com key `venues/{venueId}/photos/{uuid}.webp`; arquivo nao imagem ou >5 MB 400; sem permissao 403; delete sem uso apaga S3+linha; delete com uso 409 e lista; PUT so descricao; list por venue; backfill de permissao nao duplica string
- definition of done: router autenticado; servico unico de upload; permissoes no catalogo backend; script/SQL de backfill de permissao documentado; `project/api-endpoints.md` com as 5 rotas; testes verdes

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — upload S3 e permissoes
- risco principal: apagar do S3 foto ainda referenciada, ou upload sem auth
- repos tocados: `backend`
- fora de escopo desta task: backfill de fotos, front, auth de `/image/*`
- prova minima desta task: `npm test -- --run` nos specs de `venue-photo` (e permissao se houver)
- criterio de escalada: se precisar de fila/retry para upload multiplo, parar e registrar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `aws`, `security`, `database`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `03-design.md#Falhas, casos de borda e invariantes`, `topics/permissions-catalog.md`, `.cursor/framework_global/framework-libs/security/index.md`, `.cursor/framework_global/framework-libs/aws/index.md`
- caminhos candidatos: `src/router/image.ts`; `src/services/upload-config-sw.ts`; `src/use-cases/image/create-image/`; `src/middleware/ensureAuthenticate.ts`; `src/middleware/ensurePermission.ts`
- palavras-chave ou simbolos de busca: `S3Client`, `sharp`, `ensurePermission`, `VIEW_VENUE_SITES`, `EDIT_VENUE_SITE`
- testes provaveis: novo `venue-photo.spec.ts`
- nao ler por padrao: front, `guaeca-house-escapade`

### T-03 - Backfill das fotos existentes

- objetivo: popular `venue_photo` a partir das URLs atuais e preencher `photoId`/`backgroundPhotoId` sem reenviar arquivo
- cobre requisitos: `R-03`, `R-12`
- depende de: `T-01` (tabela na `main`); `T-02` opcional
- pode rodar em paralelo com: `T-05` (depois de `T-02`)
- reusa: SQL idempotente no estilo da copia de `venue_amenity_image`
- prompt recomendado: normal
- estrategia de teste: dry-run / contagens antes-depois na `main` com aprovacao; script local com fixtures se existir
- cenarios obrigatorios: URL repetida no mesmo venue vira 1 foto; segunda execucao nao duplica; `image` so com `organizationId` ignorada; relatorio lista URL legado sem key parseavel; amostragem de `getWebData` com mesmas URLs
- definition of done: script ou SQL documentado em `03-design`/pasta da spec; executado na `main` so com aprovacao nomeada; contagens registradas em `05-state.md`

#### Context Pack

- frente principal: backend / dados
- superficie sensivel: sim — escrita no banco real
- risco principal: duplicar fotos ou apontar `photoId` para venue errado
- repos tocados: `backend`
- fora de escopo desta task: front, auth `/image`
- prova minima desta task: contagem `venue_photo` = URLs distintas por venue; `photoId` preenchido nas tabelas alvo; URLs publicas inalteradas numa amostra
- criterio de escalada: qualquer DELETE/DROP ou duvida de ownership -> usuario
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `02-clarify.md#Premissas assumidas`, `project/planetscale.md#Permissoes do agente`
- caminhos candidatos: `prisma/schema.prisma`; script novo em `art56_server_v3/scripts/` ou SQL na pasta da spec
- palavras-chave ou simbolos de busca: `imageUrl`, `backgroundImageUrl`, `venue_amenity_image`
- testes provaveis: contagens via `pscale sql`
- nao ler por padrao: front, `security` runtime

### T-04 - Consumidores aceitam `photoId` e auth nas escritas `/image/*`

- objetivo: create/update de image (venue), service, venue-amenity e email-config gravam por `photoId` (copiando URL); escritas `/image/*` de venue exigem autenticacao
- cobre requisitos: `R-08` (API), `R-11`
- depende de: `T-02`; confirmar `VenueAmenityImage` no repo (`02-clarify.md#Itens bloqueantes`)
- pode rodar em paralelo com: `T-05`, `T-06`
- reusa: use cases atuais; validacao de ownership do photo
- prompt recomendado: normal
- estrategia de teste: vitest por use case; teste negativo sem token nas escritas `/image`
- cenarios obrigatorios: `photoId` do mesmo venue grava e copia URL; `photoId` de outro venue 400; arquivo legado ainda aceito ou rejeitado conforme contrato documentado em `03-design`; POST/PUT/DELETE `/image/*` sem token 401; GET list/getByTag sem token 200
- definition of done: contratos Zod atualizados; `api-endpoints.md` marca escritas como auth; testes verdes; allowlist `PUBLIC_ROUTES` do front alinhada se existir entrada de escrita

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — auth e upload legado
- risco principal: fechar leitura publica por engano; aceitar photo de outro venue
- repos tocados: `backend` (e `frontend` so se `PUBLIC_ROUTES`)
- fora de escopo desta task: PhotoPicker, pagina Fotos, org image routes
- prova minima desta task: vitest dos use cases tocados + caso 401 nas escritas image
- criterio de escalada: se alguma pagina publica depender de escrita `/image`, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `project/api-endpoints.md` (bloco image), `topics/auth-and-security.md`
- caminhos candidatos: `src/router/image.ts`; `src/use-cases/image/`; `src/use-cases/service/`; `src/use-cases/venue-amenity/`; `src/use-cases/email-config/`; `src/router/proposal.ts` (`image-choice`)
- palavras-chave ou simbolos de busca: `createImage`, `updateImage`, `ensureAuthenticate`, `imageUrl`, `backgroundImageUrl`
- testes provaveis: specs de image, service, venue-amenity, email-config
- nao ler por padrao: design visual do picker

### T-05 - Pagina "Fotos", sidebar e permissoes no front

- objetivo: item "Fotos" na secao "A casa", rota protegida e pagina de biblioteca (grade, upload multiplo, descricao, exclusao com usos)
- cobre requisitos: `R-06` (front), `R-07`
- depende de: `T-02`
- pode rodar em paralelo com: `T-04`, `T-03`
- reusa: `venueSections`, `venueIcons`, `ProtectedRoute`, padrao de pages/services/stores
- prompt recomendado: normal
- estrategia de teste: build; teste do model da sidebar se existir; browser manual
- cenarios obrigatorios: item so com `VIEW_VENUE_PHOTOS`; icone `Images` presente (senao `presentNavItems` quebra); upload multiplo chama a API; delete em uso mostra usos e nao remove; sem `EDIT` esconde acoes de escrita
- definition of done: enum de permissoes no front; rota em `App.tsx`; pagina usable contra API; `topics/permissions-catalog.md` atualizado

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — upload
- risco principal: faltar icone na sidebar e derrubar a nav
- repos tocados: `frontend`
- fora de escopo desta task: PhotoPicker nos outros formularios
- prova minima desta task: `npm run build`; abrir `/venue/:id/photos` com usuario permitido
- criterio de escalada: se a pagina exigir design system novo, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Componentes e modulos impactados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Componentes e modulos impactados`, `topics/permissions-catalog.md`, `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `src/components/sidebar/sidebar-nav-model.ts`; `src/components/venue/VenueNav.tsx`; `src/App.tsx`; `src/types/permissions.ts`; `src/pages/website/VenueWebsiteImages.tsx` (referencia de UX de midia)
- palavras-chave ou simbolos de busca: `venueSections`, `venueIcons`, `VIEW_VENUE_SITES`, `presentNavItems`
- testes provaveis: build; teste de nav model se houver
- nao ler por padrao: backend use cases alem do contrato HTTP

### T-06 - Componente `PhotoPicker`

- objetivo: dialogo reutilizavel que lista a biblioteca, seleciona uma ou varias fotos e oferece "enviar nova" (sobe e ja seleciona)
- cobre requisitos: `R-09`, `R-10`
- depende de: `T-05` (service/tipos da biblioteca) ou service minimo criado aqui
- pode rodar em paralelo com: `T-04`
- reusa: dialog shadcn; service de `venue-photo` da `T-05`
- prompt recomendado: normal
- estrategia de teste: teste do helper de selecao / componente; build
- cenarios obrigatorios: selecao unica e multipla; "enviar nova" exige `EDIT_VENUE_PHOTOS` e devolve a foto na selecao; sem permissao de editar fotos o botao nao renderiza; limiar de 5 MB espelhado na UI
- definition of done: `PhotoPicker` exportado; props claras (`venueId`, `mode`, `max`, `value`, `onChange`); documentado em comentario curto de uso

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — upload
- risco principal: selecionar foto de outro venue por cache errado
- repos tocados: `frontend`
- fora de escopo desta task: plugar nos formularios (isso e `T-07`/`T-08`)
- prova minima desta task: `npm test` do helper/componente e `npm run build`
- criterio de escalada: se precisar de lib de galeria nova, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Decisoes arquiteturais importantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Decisoes arquiteturais importantes`, `02-clarify.md#Premissas assumidas`, `.cursor/framework_global/framework-libs/react/index.md`
- caminhos candidatos: `src/components/ui/dialog.tsx`; service/store criados em `T-05`; `src/pages/ProposalView.tsx` (catalogo atual como referencia visual)
- palavras-chave ou simbolos de busca: `Dialog`, `EDIT_VENUE_PHOTOS`, `venue-photo`
- testes provaveis: `PhotoPicker.test.tsx` ou helper puro
- nao ler por padrao: schema Prisma

### T-07 - Ligar seletor no site, proposta e hub

- objetivo: formularios de imagem do site, troca de foto da proposta e selecao do hub usam `PhotoPicker` e gravam `photoId` / flags existentes
- cobre requisitos: `R-08` (site, proposta, hub), `R-12`
- depende de: `T-04`, `T-06`
- pode rodar em paralelo com: inicio de `T-08` se os forms forem independentes
- reusa: `PhotoPicker`; fluxos de `isShowOnProposal` / `isShowOnOrganization`
- prompt recomendado: normal
- estrategia de teste: build; browser nos tres fluxos
- cenarios obrigatorios: criar item de galeria escolhendo foto existente; "enviar nova" na galeria aparece em Fotos; troca de capa na proposta sem upload proprio; hub marca `isShowOnOrganization` em `image` existente
- definition of done: inputs de arquivo removidos desses tres fluxos; `image-form` fala `photoId`; proposta e hub usam o picker

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — midia publica
- risco principal: perder tag/group/flags ao trocar para photoId
- repos tocados: `frontend`
- fora de escopo desta task: servicos, amenities, e-mail
- prova minima desta task: `npm run build`; browser site + proposta + hub
- criterio de escalada: se `image-choice` exigir contrato novo alem de photoId, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Componentes e modulos impactados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `topics/public-pages-and-branding.md`
- caminhos candidatos: `src/components/image/image-form.tsx`; `src/pages/ProposalView.tsx`; `src/components/organization/venue-web/SelectVenueImagesForm.tsx`; `src/services/image.service.ts`
- palavras-chave ou simbolos de busca: `isShowOnProposal`, `isShowOnOrganization`, `image-form`, `image-choice`
- testes provaveis: build; testes locais se o form tiver helper puro
- nao ler por padrao: email-config, service-form

### T-08 - Ligar seletor em servicos, caracteristicas e e-mail

- objetivo: os tres formularios restantes usam `PhotoPicker` (ate 3 fotos na caracteristica); remove uploads diretos do painel nesses fluxos
- cobre requisitos: `R-08` (servicos, amenities, e-mail), `R-09` (enviar nova no fluxo real)
- depende de: `T-04`, `T-06`; codigo de multiplas fotos da caracteristica presente
- pode rodar em paralelo com: `T-07`
- reusa: `PhotoPicker`, `amenity-form` (lista de ate 3)
- prompt recomendado: normal
- estrategia de teste: build; browser criar/editar servico, amenity com "enviar nova", fundo de e-mail
- cenarios obrigatorios: servico grava `photoId`; amenity ate 3 photoIds ordenados; e-mail grava `backgroundPhotoId`; "enviar nova" sem `EDIT_VENUE_PHOTOS` oculto; cancelar form apos upload deixa foto em Fotos
- definition of done: sem `<input type="file">` de imagem nesses forms; docs de endpoints/consumidores alinhados; `05-state` atualizado

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — upload via picker
- risco principal: regressao do limite de 3 fotos da caracteristica
- repos tocados: `frontend`
- fora de escopo desta task: limpar colunas de URL no banco; org uploads
- prova minima desta task: `npm test` de `amenity-form` se aplicavel + `npm run build` + browser dos tres forms
- criterio de escalada: se `VenueAmenityImage.photoId` nao existir no codigo, parar e voltar a `T-04`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Componentes e modulos impactados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `02-clarify.md#Itens bloqueantes`, specs `2026-11-13-multiplas-fotos-caracteristica/03-design.md#Contratos e dados`
- caminhos candidatos: `src/components/service/service-form.tsx`; `src/components/venue-amenity/venue-amenity-form.tsx`; `src/lib/amenity-form.ts`; `src/components/email-config/EmailTab.tsx`
- palavras-chave ou simbolos de busca: `imageUrl`, `backgroundImageUrl`, `files`, `removeImage`, `PhotoPicker`
- testes provaveis: `amenity-form.test.ts`; build
- nao ler por padrao: `guaeca-house-escapade`
