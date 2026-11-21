# Clarify — Biblioteca de fotos do espaco

## Perguntas criticas

Nenhuma bloqueante. As decisoes de produto e as premissas abaixo bastam para `T-01`.

## Respostas confirmadas

- tabela nova `venue_photo`; `image` nao vira o catalogo
- catalogo so por espaco (`venueId`); sem biblioteca da organizacao
- item "Fotos" na secao "A casa"
- permissoes novas `VIEW_VENUE_PHOTOS` e `EDIT_VENUE_PHOTOS` com backfill
- consumidores da v1: site, orcamento, hub, servicos, caracteristicas, fundo do e-mail
- "enviar nova" em qualquer seletor: sobe para a biblioteca e ja seleciona
- `guaeca-house-escapade` nao muda
- `tag`/`group`/`position`/`isShowOnProposal`/`isShowOnOrganization` ficam em `image`

## Requisitos implicitos confirmados

- gravacao autenticada; permissao no front nao substitui a API
- `photoId` sempre do mesmo `venueId` do uso
- paginas publicas continuam recebendo URL nos campos atuais
- migration aditiva + deploy request; backfill com aprovacao nomeada
- contrato FE/BE atualiza `api-endpoints.md` e `permissions-catalog.md`
- sem terceira abordagem de estado no front

## Premissas assumidas

| Pergunta | Premissa | Risco se estiver errada |
|---|---|---|
| Logo do espaco entra no catalogo? | Nao | logo continua upload proprio; se quiser depois, vira `photoId` em `Venue` |
| Excluir foto em uso? | Bloquear com 409 e listar usos | se quiser "desvincular e apagar", muda `T-02` e a pagina |
| Auth em `/image/*`? | Sim nas escritas; leituras publicas de list/getByTag permanecem | site avulso e consumidores publicos quebram se fechar leitura cedo demais |
| Colunas de URL antigas? | Continuam preenchidas como copia | remover cedo quebra `getWebData` e o site da Guaeca |
| Backfill de permissao? | `VIEW` de `VIEW_VENUE_SITES`; `EDIT` de `EDIT_VENUE_SITE` | quem so edita amenities/services pode ver a biblioteca mas nao enviar nova (combinado com a linha abaixo) |
| Sem `EDIT_VENUE_PHOTOS`, ve "enviar nova"? | Nao; so escolhe existentes | operador sem permissao de fotos nao consegue cadastrar amenity com foto nova ate receber a permissao |
| Cadastro cancelado apos "enviar nova"? | Foto fica na biblioteca | acumulo de fotos orfas; limpeza manual em "Fotos" |
| Limite de tamanho do upload da biblioteca? | 5 MB por arquivo, alinhado a servicos/amenities; WebP largura 1200 qualidade 80 | formulario do site hoje aceita 2,5 MB; arquivos entre 2,5 e 5 MB passam a ser aceitos |
| Limite de arquivos por `POST /venue-photo/upload`? | Ate 20 por request | lote maior precisa de varios envios |
| Como detectar usos? | Contar `image.photoId`, `service.photoId`, `venue_amenity_image.photoId`, `emailConfig.backgroundPhotoId` | uso futuro sem coluna nova nao aparece ate atualizar `usages` |

## Perguntas de erro e borda ainda abertas

- backfill deve falhar o lote inteiro se uma URL estiver quebrada, ou so reportar?
  - default: reportar e seguir; risco: foto quebrada aparece na biblioteca ate limpeza manual
- ao trocar a foto de um `image` (galeria), o arquivo antigo no S3 e apagado se nenhum outro uso apontar para o mesmo `venue_photo`?
  - default: nao apagar o `venue_photo` nem o S3 so porque um uso saiu; exclusao so pela pagina "Fotos" / `DELETE`
- variantes de organizacao (`/image/upload/image-organization` etc.) entram nesta entrega?
  - default: nao; so escritas de venue; risco: rotas de org continuam publicas

## Itens bloqueantes

- nenhum para `T-01`/`T-02`
- antes de `T-04` tocar `VenueAmenityImage.photoId`: confirmar no repo que a tabela e o codigo da spec `multiplas-fotos-caracteristica` existem (deploy request `#48` ja na `main`)

## O que pode seguir mesmo com lacunas

- `T-01` a `T-03` e a pagina `T-05` seguem com as premissas
- ligar consumidores (`T-07`/`T-08`) pode ir um a um se algum formulario ainda estiver em outra spec
