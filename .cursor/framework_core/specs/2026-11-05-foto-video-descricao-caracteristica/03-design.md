# Design — Foto ou video e descricao na caracteristica

## Visao geral da solucao

`VenueAmenity` ganha `description`, `imageUrl` e `videoUrl`, todos nulos. Criar e editar passam a receber `multipart` com `payload` JSON e `file` opcional, no mesmo formato do servico. A apresentacao publica repassa os tres campos. O bloco "Conheça nosso espaço" desenha o complemento quando ele existe.

Passada transversal:

- architecture: nao. Mesmo router, use case e repository. O contrato existente ganha campos. Sem ADR.
- database: sim. Tres colunas nulas em `venue_amenity`. Migration aditiva, sem backfill e sem indice novo.
- design: sim. Formulario com descricao, foto e link; bloco publico com texto, imagem ou player.
- observability: nao. Erro HTTP e toast atuais. Sem dashboard.
- security: sim. Upload e URL na pagina publica. A rota de escrita ja exige auth. A foto nao vai para storage privado.
- patterns/06: nao. Sem retry, fila, cache ou webhook. O nome unico no venue ja conflita.

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: modelo `VenueAmenity`
- `art56_server_v3/src/router/venue-amenity.ts`: `multer` em criar e editar, limite de 5 MB
- controllers e use cases de criar, editar e excluir caracteristica
- `art56_server_v3/src/zod/venue-amenity/`
- `art56_server_v3/src/zod/venue/tour-video-url-schema.ts`: exportar a checagem so de YouTube
- `to-proposal-presentation.ts` e o select de `amenities` em `proposal-in-prisma-repository.ts`
- `eventhub-vista-dashboard/src/components/venue-amenity/venue-amenity-form.tsx` e a secao que envia o submit
- `venue-amenity.service.ts`, tipos e store
- `ProposalView.tsx`, no bloco "Conheça nosso espaço", de preferencia extraindo o item para um componente testavel
- `eventhub-vista-dashboard/src/lib/`: helper novo do embed da caracteristica
- `product/08-data-model.md`: uma linha em `VenueAmenity` quando as colunas existirem

## Reuso previsto

- Upload e delete: `uploadServiceImage` e `deleteServiceImage`. Mesmo WebP, mesmo bucket, mesma URL publica.
- Corpo `multipart`: `payload` JSON mais `file`, como `readServiceBody` e `serviceFormData`.
- Hosts do YouTube: a funcao de id que hoje e privada em `tour-video-url-schema.ts`. Exportar `isYoutubeUrl` (https, sem usuario e senha, id de 11 caracteres em `watch`, `youtu.be`, Shorts ou `embed`).
- Nao reusar `isTourVideoUrl`: ele tambem aceita mp4, webm, ogg e mov.
- Nao reusar `resolveTourVideo`: o embed do tour e autoplay, mudo, em loop e sem controles.

## Contratos e dados

Colunas em `VenueAmenity`, todas opcionais:

- `description` `VarChar(500)`
- `imageUrl` `Text`
- `videoUrl` `VarChar(2048)`

Criar (`POST /venue-amenity/create`) e editar (`PUT /venue-amenity/update`) leem `payload`:

- criar: `venueId`, `name`, `description?`, `videoUrl?`
- editar: `amenityId`, `name`, `position?`, `description?`, `videoUrl?`, `removeImage?`
- `file` opcional no campo `file`
- `imageUrl` do cliente e ignorado. So entra a URL que `uploadServiceImage` devolve.

Descricao: trim; vazio ou ausente vira `null`; acima de 500 recusa.

Video: `""` ou ausente vira `null` na gravacao quando o campo vem no payload. Valor preenchido passa em `isYoutubeUrl`. Mensagem: "Use um link do YouTube."

Lista autenticada devolve a linha inteira, inclusive os tres campos.

`ProposalPresentationAmenity` passa a ser `name`, `position`, `description`, `imageUrl`, `videoUrl`. Os tres ultimos sao `string | null`. O select publico pede so esses campos.

## Falhas, casos de borda e invariantes

- Invariante: `imageUrl` e `videoUrl` nao ficam os dois preenchidos. O use case recusa com 400 se os dois vierem nesta gravacao.
- Arquivo e `videoUrl` preenchido no mesmo envio: 400 antes de subir a foto.
- Arquivo presente: sobe a foto, grava `imageUrl`, zera `videoUrl`, apaga o objeto anterior se a URL mudou.
- `videoUrl` preenchido e sem arquivo: grava o video, zera `imageUrl`, apaga o objeto anterior.
- `removeImage` sem arquivo e sem video novo: zera `imageUrl` e apaga o objeto.
- `videoUrl` `""` sem arquivo novo: zera so o video.
- Campo de video ausente e sem arquivo: mantem a midia atual.
- Excluir: apaga a linha e, se havia `imageUrl`, chama `deleteServiceImage`. A funcao ja ignora falha do S3.
- Se o upload ocorrer e o use case falhar, o objeto novo pode ficar orfao. E o mesmo risco do servico. Nao inventar transacao com o S3 nesta feature.
- Nome duplicado no venue continua 409.
- Usuario sem permissao continua barrado pelo authorizer, antes de gravar.
- Na pagina, se os dois vierem preenchidos, mostra a foto e nao monta player.
- `iframe.src` e `https://www.youtube.com/embed/${id}?rel=0`. Sem autoplay, sem mute forcado, sem loop. Id invalido: nao renderiza iframe.

## Decisoes arquiteturais importantes

- A foto fica publica no mesmo bucket do servico, porque ela existe para a proposta publica. Skills de upload privado da lib `aws` e da lib `security` nao se aplicam.
- O id do YouTube e validado no backend. O frontend repete a regra para o formulario e para o embed, mas a gravacao nao depende dessa repeticao.
- A mensagem de arquivo invalido fala de caracteristica, nao de servico. Validar tipo e tamanho no controller da caracteristica antes de chamar o upload, com o limite de 5 MB e `image/*` que `assertServiceImageFile` ja usa. Se o upload lancar a frase do servico, o controller troca pela frase da caracteristica.
- O item publico com complemento fica no mesmo grid. Sem complemento: a linha atual, check e nome. Com complemento: nome, descricao se houver, e `img` ou `iframe`.
- No formulario, selecionar arquivo zera o link; digitar link zera o arquivo e, se ja havia foto, marca remocao. A posicao continua so na edicao. A tabela do painel nao muda.

## Riscos e mitigacoes

- Link arbitrario na pagina: so o id validado entra no embed.
- Foto e video juntos: 400 no use case e erro no formulario antes do envio.
- Objeto orfao se a gravacao falhar depois do upload: aceito, igual ao servico.
- Client antigo ignora os campos novos: as colunas nascem nulas e a lista antiga continua valida.

## Rollout, observabilidade e rollback

- Migration no repositorio. Nao aplicar em producao nesta spec. Producao segue `prisma migrate deploy` quando o time promover.
- Sem metrica nova.
- Rollback: parar de enviar os campos e, se nenhum client ler as colunas, remove-las numa migration posterior. Nao ha backfill para desfazer.

## Estrategia de validacao

- Backend: casos novos em `venue-amenity.spec.ts` e um spec curto de `isYoutubeUrl`. Apresentacao publica no spec que ja cobre `amenities`.
- Frontend: funcao pura da regra do formulario (os dois preenchidos recusam; descricao em branco vira nulo) e funcao pura do embed.
- `npx prisma validate` no backend.
- Browser do painel e da proposta fica para a revisao da entrega; o login tem bloqueado as specs recentes.

## Docs determinantes

- `product/08-data-model.md`: `VenueAmenity` hoje e nome unico e posicao
- `project-decisions.md` D-01, D-02, D-03, D-05
- `topics/data-and-migrations.md#Regras`: migration aditiva e `migrate deploy`
- `topics/backend-api.md#Cuidados`: upload sincrono
- `topics/frontend-application.md#Cuidados`: permissao da tela nao autoriza a API
- codigo: `service-image-storage.ts`, `controller-create-service.ts`, `tour-video-url-schema.ts`, `venue-amenity-form.tsx`, select de `amenities` na apresentacao
