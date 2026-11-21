# Design — Foto, video e descricao na caracteristica

## Visao geral da solucao

`VenueAmenity` ganha `description`, `imageUrl` e `videoUrl`, todos nulos e independentes. Criar e editar passam a receber `multipart` com `payload` JSON e `file` opcional, no mesmo formato do servico. A apresentacao publica repassa os tres campos. No bloco "Conheça nosso espaço", o item com complemento ganha o botao "?" dos servicos, que abre um modal com nome, foto, descricao e player do YouTube.

Passada transversal:

- architecture: nao. Mesmo router, use case e repository. O contrato existente ganha campos. Sem ADR.
- database: sim. Tres colunas nulas em `venue_amenity`, que ja existem no main pelo deploy request 43. A migration do repo so registra essas colunas; sem backfill e sem indice novo.
- design: sim. Formulario com descricao, foto e link; no bloco publico, "?" e modal.
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
- `ProposalView.tsx`, no bloco "Conheça nosso espaço"; tipo `amenities` em `proposal.service.ts`
- `eventhub-vista-dashboard/src/components/proposal/forms/PublicServiceDetail.tsx`: prop opcional `videoUrl` no `PublicServiceDetailDialog`
- `eventhub-vista-dashboard/src/lib/`: helper novo do embed da caracteristica
- `product/08-data-model.md`: linha de `VenueAmenity` com os tres campos

## Reuso previsto

- Upload e delete: `uploadServiceImage` e `deleteServiceImage`. Mesmo WebP, mesmo bucket, mesma URL publica.
- Corpo `multipart`: `payload` JSON mais `file`, como `readServiceBody` e `serviceFormData`.
- Hosts do YouTube: a funcao de id que hoje e privada em `tour-video-url-schema.ts`. Exportar `isYoutubeUrl` (https, sem usuario e senha, id de 11 caracteres em `watch`, `youtu.be`, Shorts ou `embed`).
- Botao "?": o mesmo `HelpCircle` e as mesmas classes do item de servico em `ProposalView.tsx`.
- Modal: `PublicServiceDetailDialog`, que ja mostra nome, foto e descricao e aceita `surfaceStyle`.
- Nao reusar `isTourVideoUrl`: ele tambem aceita mp4, webm, ogg e mov.
- Nao reusar `resolveTourVideo`: o embed do tour e autoplay, mudo, em loop e sem controles.

## Contratos e dados

Colunas em `VenueAmenity`, todas opcionais:

- `description` `VarChar(500)`
- `imageUrl` `Text`
- `videoUrl` `VarChar(2048)`

Antes de escrever a migration, conferir os tipos reais dessas colunas no main. Se divergirem da lista acima, vale o que esta no banco.

Criar (`POST /venue-amenity/create`) e editar (`PUT /venue-amenity/update`) leem `payload`:

- criar: `venueId`, `name`, `description?`, `videoUrl?`
- editar: `amenityId`, `name`, `position?`, `description?`, `videoUrl?`, `removeImage?`
- `file` opcional no campo `file`
- `imageUrl` do cliente e ignorado. So entra a URL que `uploadServiceImage` devolve.

Descricao: trim; vazio ou ausente vira `null`; acima de 500 recusa.

Video: `""` vira `null` quando o campo vem no payload; ausente mantem o valor atual na edicao. Valor preenchido passa em `isYoutubeUrl`. Mensagem: "Use um link do YouTube."

Lista autenticada devolve a linha inteira, inclusive os tres campos.

`ProposalPresentationAmenity` passa a ser `name`, `position`, `description`, `imageUrl`, `videoUrl`. Os tres ultimos sao `string | null`. O select publico pede so esses campos.

`PublicServiceDetailDialog` ganha `videoUrl?: string | null`. Sem esse valor, o modal do servico continua igual.

## Falhas, casos de borda e invariantes

- Foto e video sao independentes. Nenhuma operacao em um mexe no outro.
- Arquivo e `videoUrl` no mesmo envio: grava os dois.
- Arquivo presente: sobe a foto, grava `imageUrl` e apaga o objeto anterior se a URL mudou. `videoUrl` segue a regra do proprio campo.
- `removeImage` sem arquivo: zera `imageUrl` e apaga o objeto. `videoUrl` nao muda.
- `videoUrl` `""`: zera so o video.
- `videoUrl` ausente: mantem o video atual.
- `videoUrl` invalido: 400 antes de subir a foto, nada e gravado.
- Excluir: apaga a linha e, se havia `imageUrl`, chama `deleteServiceImage`. A funcao ja ignora falha do S3.
- Se o upload ocorrer e o use case falhar, o objeto novo pode ficar orfao. E o mesmo risco do servico. Nao inventar transacao com o S3 nesta feature.
- Nome duplicado no venue continua 409.
- Usuario sem permissao continua barrado pelo authorizer, antes de gravar.
- Na pagina, o "?" aparece se houver descricao nao vazia, foto ou video com id valido. Video invalido nao conta.
- No modal, a ordem e: nome, foto, descricao, player.
- `iframe.src` e `https://www.youtube.com/embed/${id}?rel=0`. Sem autoplay, sem mute forcado, sem loop, com `allowFullScreen`. Id invalido: nao renderiza iframe.
- Ao fechar o modal o iframe sai da arvore, entao o video para.

## Decisoes arquiteturais importantes

- A foto fica publica no mesmo bucket do servico, porque ela existe para a proposta publica. Skills de upload privado da lib `aws` e da lib `security` nao se aplicam.
- O id do YouTube e validado no backend. O frontend repete a regra para o formulario e para o embed, mas a gravacao nao depende dessa repeticao.
- A mensagem de arquivo invalido fala de caracteristica, nao de servico. `assertAmenityImageFile` (`functions/venue-amenity-image.ts`) valida `image/*` e 5 MB no inicio do use case. O upload acontece no use case, depois da autorizacao e do nome unico, por um `AmenityImageStorage` injetado (`amenityImageStorage` reusa `uploadServiceImage` e `deleteServiceImage` e troca a frase do servico pela da caracteristica). Assim usuario sem permissao nao sobe arquivo.
- O card publico nao mostra descricao, foto nem player. O item continua check e nome, mais o "?" quando ha complemento. O conteudo so aparece no modal.
- Um unico modal por bloco, com estado `amenityDetail` e `amenityDetailOpen`, como `serviceDetail` faz nos servicos.
- No formulario, foto e link sao campos independentes. Apagar a foto marca `removeImage`. A posicao continua so na edicao. A tabela do painel nao muda.

## Riscos e mitigacoes

- Link arbitrario na pagina: so o id validado entra no embed.
- Modal do servico mudar sem querer: a prop de video e opcional e o teste atual de `PublicServiceDetail.test.tsx` continua verde.
- Migration divergir do main: conferir os tipos no banco antes e nao reaplicar a migration em producao.
- Objeto orfao se a gravacao falhar depois do upload: aceito, igual ao servico.
- Client antigo ignora os campos novos: as colunas sao nulas e a lista antiga continua valida.

## Rollout, observabilidade e rollback

- As colunas ja estao no main. A migration do repo existe para o historico e para ambientes novos; em producao, marcar como aplicada em vez de reaplicar.
- Sem metrica nova.
- Rollback: parar de enviar e ler os campos. Remover as colunas so numa migration posterior, se nenhum client depender delas.

## Estrategia de validacao

- Backend: casos novos em `venue-amenity.spec.ts` e um spec curto de `isYoutubeUrl`. Apresentacao publica no spec que ja cobre `amenities`.
- Frontend: funcao pura da regra do formulario (descricao em branco vira nulo; link que nao e YouTube recusa; foto e link juntos passam) e funcao pura do embed. Teste do modal com e sem `videoUrl`.
- `npx prisma validate` no backend.
- Browser do painel e da proposta fica para a revisao da entrega; o login tem bloqueado as specs recentes.

## Docs determinantes

- `product/08-data-model.md`: `VenueAmenity` hoje e nome unico e posicao
- `project-decisions.md` D-01, D-02, D-03, D-05
- `topics/data-and-migrations.md#Regras`: migration aditiva e `migrate deploy`
- `topics/backend-api.md#Cuidados`: upload sincrono
- `topics/frontend-application.md#Cuidados`: permissao da tela nao autoriza a API
- codigo: `service-image-storage.ts`, `controller-create-service.ts`, `tour-video-url-schema.ts`, `venue-amenity-form.tsx`, select de `amenities` na apresentacao, `PublicServiceDetail.tsx`, item de servico em `ProposalView.tsx`
