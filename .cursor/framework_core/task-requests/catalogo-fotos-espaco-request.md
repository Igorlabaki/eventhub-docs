# Solicitacao da Tarefa

## Nome sugerido da tarefa

Biblioteca de fotos do espaco, com item "Fotos" na sidebar, usada por todo lugar que mostra foto

## Resumo da solicitacao

Cada espaco ganha uma biblioteca de fotos propria, aberta por um item "Fotos" na sidebar (secao "A casa"). O dono sobe as fotos uma vez. Site, orcamento, hub da organizacao, servicos/pacotes, caracteristicas e fundo do e-mail deixam de subir arquivo proprio e passam a escolher uma foto dessa biblioteca por um seletor.

Exemplo: o dono sobe 30 fotos da casa em "Fotos". Depois, ao montar a galeria do site, trocar a capa do orcamento, escolher a foto de um servico, as 3 fotos de uma caracteristica ou o fundo do e-mail, ele abre o seletor e escolhe entre as fotos ja enviadas, sem novo upload.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — upload para o S3, rotas `/image/*` hoje sem autenticacao, permissoes novas com backfill e fotos expostas em paginas publicas (`getWebData`, `getHubData`, proposta publica)
- risco principal: quebrar as paginas publicas (site avulso `guaeca-house-escapade`, proposta e hub), que leem a URL direto de `image.imageUrl`, `service.imageUrl` e `venue_amenity_image.imageUrl`, ou apagar do S3 um arquivo que ainda e usado em outro lugar depois que varios usos passam a apontar para a mesma foto
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`); `guaeca-house-escapade/` so como consumidor que nao pode quebrar
- fora de escopo operacional: biblioteca de fotos da organizacao; mudar o `guaeca-house-escapade`; mover `tag`, `group`, `position`, `isShowOnProposal` e `isShowOnOrganization` para fora de `image`; apagar as colunas de URL antigas; logo do espaco e da organizacao (salvo se a pergunta em aberto for respondida ao contrario); avatar, contato, pagamento e documentos
- prova minima desta execucao: no painel, o item "Fotos" aparece so para quem tem `VIEW_VENUE_PHOTOS`; subir varias fotos de uma vez em "Fotos"; escolher uma foto da biblioteca na galeria do site, na troca da capa do orcamento, no hub, em um servico, nas 3 fotos de uma caracteristica e no fundo do e-mail, sem upload novo; ao cadastrar uma caracteristica, enviar uma foto nova pelo seletor, ver que ela ja vem selecionada e que aparece em "Fotos"; tentar excluir uma foto em uso e ver onde ela e usada; `getWebData` devolve as mesmas URLs de antes depois do backfill; usuario sem `EDIT_VENUE_PHOTOS` nao grava e foto de outro espaco e recusada; `npx prisma validate` e `npm test -- --run` no backend, `npm test`, `npm run lint` e `npm run build` no frontend
- criterio de escalada: a spec e o caminho; fechar leitura publica de `/image/*` usada pelo site avulso ou mexer em schema de forma destrutiva volta para o usuario antes de executar
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `database`, `node`, `patterns`, `react`, `design`, `aws`, `security`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/api-endpoints.md` (rotas `/image/*` e risco de rotas sem auth)
  - `.cursor/framework_core/topics/permissions-catalog.md`
  - `.cursor/framework_core/project/planetscale.md`
  - `.cursor/framework_core/topics/public-pages-and-branding.md`
- caminhos candidatos:
  - `art56_server_v3/prisma/schema.prisma` (`Image`, `Service`, `VenueAmenityImage`, `EmailConfig`, `Venue`)
  - `art56_server_v3/src/router/image.ts`, `src/use-cases/image/`, `src/zod/image/`
  - `art56_server_v3/src/services/upload-config-sw.ts`
  - `art56_server_v3/src/functions/service-image-storage.ts`, `venue-amenity-upload.ts`, `venue-amenity-image.ts`, `venue-amenity-image-storage.ts`
  - `art56_server_v3/src/router/service.ts`, `src/router/venue-amenity.ts`, `src/router/proposal.ts`
  - `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts` (catalogo e `applyImageChoice`) e `venue-in-prisma-repository.ts` (`getWebData`, `getHubData`)
  - `eventhub-vista-dashboard/src/components/sidebar/sidebar-nav-model.ts`, `src/components/venue/VenueNav.tsx`, `src/App.tsx`, `src/types/permissions.ts`
  - `eventhub-vista-dashboard/src/components/image/`, `src/pages/website/VenueWebsiteImages.tsx`, `src/services/image.service.ts`, `src/store/imageStore.ts`, `src/types/image.ts`
  - `eventhub-vista-dashboard/src/pages/ProposalView.tsx`
  - `eventhub-vista-dashboard/src/components/organization/venue-web/SelectVenueImagesForm.tsx`
  - `eventhub-vista-dashboard/src/components/service/service-form.tsx`, `src/components/venue-amenity/venue-amenity-form.tsx`, `src/lib/amenity-form.ts`, `src/components/email-config/EmailTab.tsx`
- palavras-chave ou simbolos de busca: `imageUrl`, `backgroundImageUrl`, `isShowOnProposal`, `isShowOnOrganization`, `applyImageChoice`, `uploadServiceImage`, `S3Client`, `venueSections`, `venueIcons`, `VIEW_VENUE_SITES`, `EDIT_VENUE_SITE`
- testes provaveis: specs de `image`, `service`, `venue-amenity` e `use-case-choose-proposal-image` no backend; testes de `sidebar-nav-model`, `amenity-form` e `image-form` no frontend
- nao ler por padrao: `topics/` fora dos listados, specs de outras frentes, `guaeca-house-escapade/` alem de `src/context/VenueContext.tsx`

## Contexto informado na entrada

Pedido em chat: centralizar as fotos do espaco num item "Fotos" da sidebar e fazer tudo que usa foto puxar desse catalogo.

Ja verificado no codigo durante o chat:

- backend `art56_server_v3`: Express, Prisma, MySQL no PlanetScale com `relationMode = "prisma"` e upload para o AWS S3
- `prisma/schema.prisma`, model `Image` (~linhas 653-673): `imageUrl`, `group`, `description`, `position`, `responsiveMode`, `tag`, `isShowOnOrganization`, `isShowOnProposal`, `venueId?`, `organizationId?`; e hoje a galeria do site, do orcamento e do hub
- imagens fora de `image`, cada uma com upload proprio:
  - `Service.imageUrl` (`src/functions/service-image-storage.ts`, WebP, 5 MB)
  - `VenueAmenityImage.imageUrl`, no maximo 3 por caracteristica (`src/functions/venue-amenity-upload.ts`, `venue-amenity-image.ts`, `venue-amenity-image-storage.ts`)
  - `EmailConfig.backgroundImageUrl` (model `EmailConfig`, `venueId` obrigatorio, ~linha 768)
  - `Venue.logoUrl` e `Organization.logoUrl`
- `src/router/image.ts`: `POST /image/upload`, `GET /image/list`, `GET /image/getByTag`, `PUT /image/update`, `DELETE /image/delete/:imageId` e variantes de organizacao; nenhuma usa `ensureAuthenticate` (risco ja registrado em `api-endpoints.md`)
- `use-cases/image/create-image/controller-create-image.ts` converte para WebP (sharp, largura 1200, qualidade 80); `update-image/controller-update-image.ts` nao converte
- cliente S3 em `src/services/upload-config-sw.ts`; `src/router/image.ts` cria um segundo `S3Client`, duplicado
- orcamento: `PUT /proposal/presentation/:proposalId/image-order` e `image-choice` (`src/router/proposal.ts`); catalogo e `applyImageChoice` em `proposal-in-prisma-repository.ts`; a apresentacao filtra `isShowOnProposal: true`
- dados publicos: `GET /venue/getWebData` devolve `images`, `texts`, `logoUrl` e `services`; `GET /organization/getHubData` devolve as fotos com `isShowOnOrganization`
- frontend `eventhub-vista-dashboard`: sidebar declarativa em `sidebar-nav-model.ts` (`venueSections`, secao `a-casa` com Site, Regras e Caracteristicas); icones em `VenueNav.tsx` (`venueIcons`), e `presentNavItems` lanca erro se faltar icone; rotas em `App.tsx` com `ProtectedRoute`; permissoes em `src/types/permissions.ts`
- consumidores de foto no painel: site (`components/image/*`, `VenueWebsiteImages.tsx`, `image.service.ts`, `imageStore.ts`, `types/image.ts`), orcamento (`ProposalView.tsx`: capa, galeria, lightbox, reordenar e trocar pelo catalogo), hub (`SelectVenueImagesForm.tsx`, `VenuesList.tsx`, `VenueImageItem.tsx`), servicos (`service-form.tsx`, `service-list.tsx`), caracteristicas (`venue-amenity-form.tsx`, `lib/amenity-form.ts`) e e-mail (`EmailTab.tsx`)
- site avulso `guaeca-house-escapade`: consome `getWebData` com `venueId` fixo e filtra por `tag` (`hero-section`, `about-section`, `amenities-section`) e por `group`

Decisoes fechadas pelo usuario (nao reabrir):

- tabela nova para a biblioteca (`venue_photo`); os outros lugares referenciam a foto por `photoId`; a tabela `image` nao vira o catalogo
- catalogo so por espaco (`venueId`); nao ha biblioteca no nivel de organizacao
- item "Fotos" na sidebar do espaco, secao "A casa"
- permissoes novas `VIEW_VENUE_PHOTOS` e `EDIT_VENUE_PHOTOS`, com backfill para os usuarios existentes
- escopo da v1, todos escolhendo do catalogo: site (galeria, hero, sobre), orcamento (capa, galeria, troca de foto), hub da organizacao, servicos/pacotes, caracteristicas e fundo do e-mail
- em qualquer seletor de foto da para enviar uma foto nova; ela entra na biblioteca do espaco e ja volta selecionada no campo (exemplo: ao cadastrar uma caracteristica, subir a foto pelo seletor e salvar sem passar pela pagina "Fotos")

Limitacoes aceitas na v1:

- sem biblioteca de fotos da organizacao; o hub continua escolhendo fotos dos espacos
- `tag`, `group`, `position`, `isShowOnProposal` e `isShowOnOrganization` continuam em `image`, como dados de uso da foto
- o `guaeca-house-escapade` nao e alterado e continua funcionando sem mudanca

## Problema atual

Cada lugar que mostra foto do espaco sobe o proprio arquivo para o S3, com regras diferentes (WebP so na criacao da galeria, 5 MB em servicos e caracteristicas, 2,5 MB no formulario do site). A mesma foto da casa e enviada varias vezes, nao ha lugar para ver todas as fotos do espaco e trocar uma foto exige novo upload em cada tela. As rotas `/image/*` aceitam escrita sem autenticacao.

## Objetivo da mudanca

Um usuario com `EDIT_VENUE_PHOTOS` sobe as fotos do espaco uma vez, na pagina "Fotos" ou pelo seletor de qualquer tela, e os seis consumidores da v1 (site, orcamento, hub, servicos, caracteristicas e fundo do e-mail) passam a gravar a escolha como `photoId` de uma foto do mesmo espaco. Nenhuma tela mantem upload proprio: todo envio passa pela biblioteca, e o que as paginas publicas recebem nao muda.

## Escopo inicial percebido

Schema novo com backfill a partir das URLs atuais, rotas autenticadas da biblioteca, servico unico de upload, adaptacao das rotas consumidoras para aceitar `photoId`, permissoes novas com backfill, pagina "Fotos" e item na sidebar, seletor reutilizavel e troca do upload em seis telas do painel. Toca `backend` e `frontend`, com migration em producao.

## Itens incluidos neste request

- tabela `venue_photo` por espaco e `photoId` opcional nos usos (`image`, `service`, `venue_amenity_image` e `emailConfig`)
- backfill das fotos ja existentes para a biblioteca, sem reenviar arquivo
- upload de varias fotos de uma vez na biblioteca, listagem, edicao da descricao, consulta de onde a foto e usada e exclusao
- permissoes `VIEW_VENUE_PHOTOS` e `EDIT_VENUE_PHOTOS` no backend, no enum, nas rotas e na sidebar, com backfill
- item "Fotos" na secao "A casa" da sidebar, com icone e rota protegida
- pagina de biblioteca no painel
- seletor de foto reutilizavel nas telas de site, orcamento, hub, servicos, caracteristicas e e-mail, com atalho "enviar nova" que sobe a foto para a biblioteca e ja a deixa selecionada

## Requisitos implicitos ja visiveis

- a gravacao passa pelo backend autenticado; permissao no frontend nao substitui autorizacao no backend
- toda escolha valida que a foto pertence ao mesmo `venueId` do uso
- as paginas publicas continuam recebendo a URL da foto no mesmo campo de hoje
- migration de producao aditiva, pela `main` do PlanetScale via deploy request; o backfill grava no banco real e exige aprovacao nomeada
- contrato FE/BE muda nos dois repos e atualiza `project/api-endpoints.md` e `topics/permissions-catalog.md`
- o frontend nao cria uma terceira forma de estado

## Casos de erro e borda ja percebidos

- a mesma URL usada em `image` e em `service` do mesmo espaco vira uma foto so no backfill
- URL antiga que aponta para arquivo ja apagado do S3
- `image` com `organizationId` e sem `venueId` (fotos da organizacao) nao cabe no catalogo por espaco
- foto escolhida de outro espaco: recusada
- excluir foto usada em varios lugares
- falha no upload de uma das varias fotos enviadas de uma vez
- backfill rodado duas vezes nao duplica fotos
- foto enviada pelo seletor e cadastro cancelado em seguida (a foto ja esta na biblioteca)
- usuario que edita a tela (por exemplo `EDIT_VENUE_AMENITIES`) mas nao tem `EDIT_VENUE_PHOTOS` e tenta enviar foto nova pelo seletor
- usuario com `VIEW_VENUE_SITES` mas sem a permissao nova depois do deploy, se o backfill nao rodar antes do front

## Dependencias

- [spec de ate tres fotos na caracteristica](../specs/2026-11-13-multiplas-fotos-caracteristica/00-overview.md): criou `VenueAmenityImage` e esta em revisao, sem commit; confirmar que o codigo existe nos repos antes de desenhar o `photoId` nela
- specs que mexem nas fotos da proposta publica e devem ser preservadas: [trocar a foto do link de orcamento](../specs/2026-11-04-trocar-foto-proposta-publica/00-overview.md) e [reordenar as fotos da proposta publica](../specs/2026-11-04-reordenar-fotos-proposta-publica/00-overview.md)
- [spec de preco, foto e descricao do servico](../specs/2026-11-04-preco-foto-descricao-servico/00-overview.md): criou o upload da foto do servico
- mudanca multi-repo: pode ser derivada depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao alterar o `guaeca-house-escapade`
- nao apagar colunas de URL nesta entrega
- nao fechar leitura publica de `/image/*` que o site avulso ou as paginas publicas consomem sem teste negativo e confirmacao
- nao ler nem versionar valores de `.env`
- escrita no banco real, backfill e deploy request na `main` exigem aprovacao nomeada

## Perguntas em aberto

- O logo do espaco (`Venue.logoUrl`) entra no catalogo? Premissa: nao, fica fora, por ser identidade visual e nao foto do espaco.
- O que acontece ao excluir uma foto em uso? Premissa: bloquear a exclusao e mostrar onde ela e usada.
- As rotas `/image/*` passam a exigir autenticacao nesta entrega? Premissa: sim, `ensureAuthenticate` nas rotas de escrita, mantendo as leituras que o site publico consome.
- As colunas de URL antigas (`image.imageUrl`, `service.imageUrl`, `venue_amenity_image.imageUrl`, `emailConfig.backgroundImageUrl`) continuam preenchidas? Premissa: sim, como copia da URL da foto durante a transicao, sem remover coluna.
- Quem recebe as permissoes novas no backfill? Premissa: `VIEW_VENUE_PHOTOS` para quem tem `VIEW_VENUE_SITES`; `EDIT_VENUE_PHOTOS` para quem tem `EDIT_VENUE_SITE`.
- Quem edita a tela mas nao tem `EDIT_VENUE_PHOTOS` ve o "enviar nova" no seletor? Premissa: nao; so escolhe fotos que ja estao na biblioteca, e o backend recusa o envio.
- Se a foto foi enviada pelo seletor e o cadastro foi cancelado, ela fica na biblioteca? Premissa: sim, fica disponivel para uso futuro e pode ser apagada em "Fotos".

## Notas tecnicas para a spec

Insumo levantado no chat para o bootstrap; nao e decisao de design fechada.

- `VenuePhoto` (`@@map("venue_photo")`): `id` (cuid), `venueId`, `url`, `storageKey`, `width?`, `height?`, `sizeBytes?`, `description?`, `createdAt`, `updatedAt`; relacao com `Venue` com `onDelete: Cascade`; `@@index([venueId])`
- `photoId` opcional e aditivo em `Image`, `Service` e `VenueAmenityImage`; em `EmailConfig`, como `backgroundPhotoId`
- backfill: para cada URL distinta por espaco em `image`, `service`, `venue_amenity_image` e `emailConfig`, criar um `venue_photo` reaproveitando o arquivo ja existente no S3 e preencher o `photoId`; idempotente
- endpoints novos, todos autenticados:
  - `GET /venue-photo/list?venueId=` (`VIEW_VENUE_PHOTOS`)
  - `POST /venue-photo/upload`, varias fotos de uma vez, WebP, chave `venues/{venueId}/photos/{uuid}.webp` (`EDIT_VENUE_PHOTOS`)
  - `PUT /venue-photo/:id`, editar descricao (`EDIT_VENUE_PHOTOS`)
  - `GET /venue-photo/:id/usages` (`VIEW_VENUE_PHOTOS`)
  - `DELETE /venue-photo/:id` (`EDIT_VENUE_PHOTOS`)
- servico unico de upload: converte sempre para WebP e usa um unico `S3Client`
- consumidores (`/image/upload`, `/service/*`, `/venue-amenity/*`, email-config, `image-choice` do orcamento) passam a aceitar `photoId` e validam o mesmo `venueId`
- frontend:
  - `{ title: "Fotos", path: "/photos", permission: Permissions.VIEW_VENUE_PHOTOS }` em `venueSections`, secao `a-casa`
  - `Fotos: Images` em `venueIcons`
  - rota `/venue/:id/photos` em `App.tsx`
  - pagina `VenuePhotos.tsx`: grade, upload multiplo arrastando, descricao, exclusao mostrando os usos
  - componente `PhotoPicker` (dialogo, selecao unica ou multipla, atalho "enviar nova") em `image-form.tsx`, `ProposalView.tsx`, `SelectVenueImagesForm.tsx`, `service-form.tsx`, `venue-amenity-form.tsx` e `EmailTab.tsx`
- ordem sugerida de entrega:
  1. backend: tabela, endpoints, permissoes e backfill
  2. pagina Fotos e item na sidebar
  3. `PhotoPicker`, ligado a um consumidor por vez
  4. remover os uploads diretos antigos

## Prioridade sugerida

Media. E reorganizacao do fluxo de fotos com ganho de uso e de seguranca; nenhum fluxo esta quebrado hoje.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: tabela nova com backfill em producao, permissoes novas com backfill, novo contrato de upload, mudanca em seis consumidores e em rotas hoje sem autenticacao. Toca `backend` e `frontend` e se quebra em varias tasks com ordem (schema e backfill, API, permissoes, pagina, seletor, consumidores).

## Sugestao de slug da spec

- `framework_core/specs/2026-11-14-catalogo-fotos-espaco/`

## Sugestao de nome do arquivo

- `catalogo-fotos-espaco-request.md`

## Flags transversais

- `security`: upload, rotas `/image/*` sem auth e permissoes novas
- `database`: tabela nova, migration em producao e backfill
- `design`: pagina nova e seletor reutilizavel
- `patterns`: servico unico de upload e referencia por `photoId`
- `observability`: nao necessaria

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-14-catalogo-fotos-espaco/`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `necessaria`
