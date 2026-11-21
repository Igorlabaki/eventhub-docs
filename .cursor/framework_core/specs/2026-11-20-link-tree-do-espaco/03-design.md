# Design — link tree do espaco

## Visao geral da solucao

Uma lista por espaco guarda tipo, URL quando for colada, visivel e posicao. A aba Redes edita essa lista. A pagina publica le so o que esta visivel e da para resolver. Enquanto o espaco nao tem linha, leitura publica e editor usam a mesma lista padrao, calculada das colunas e das paginas que ja existem.

Passada transversal:

- muda topologia, fronteira ou fluxo entre partes? nao — mesma API e o mesmo frontend; entra rota nova no router de venue
- toca dados persistidos? sim — tabela nova aditiva; as quatro colunas continuam
- toca interface? sim — aba Redes, estados da checagem e pagina publica
- vai para producao? sim — sem metrica nova; a prova e teste e a pagina sem token
- toca fluxo sensivel? sim — leitura publica; o pacote e logo, cores, slogan e os hrefs ligados
- tem gatilho de conceito senior? sim — idempotencia: gravar de novo nao duplica tipo (`patterns/rules/06_senior_engineering_concepts.md`)

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: modelo `VenueLink`, enum `VenueLinkKind`
- `art56_server_v3/src/router/venue.ts`: `GET /venue/links/:venueId` sem auth; `PUT /venue/links/:venueId` com `ensureAuthenticate`
- `eventhub-vista-dashboard`: `venue-settings-tabs.ts`, `VenueSettings.tsx`, pagina publica, `App.tsx`, `sidebar-nav-model.ts`, `VenueNav.tsx`, `axios.ts` e `useBootstrapUser.ts`

## Reuso previsto

- `GET /venue/presentation/:venueId` e o modelo de rota publica sem `ensureAuthenticate`
- helpers de apresentacao, formulario e regras para montar os hrefs automaticos
- `mapQuery` de `venue-presentation.ts` para o Google Maps, o mesmo recorte da apresentacao
- `isTourVideoUrl` continua so no video do tour
- arraste nativo, como as fotos da casa; sem biblioteca nova
- casca visual da apresentacao: logo, slogan e cores

## Contratos e dados

`VenueLink` (`@@map("venue_link")`): `id` uuid, `venueId`, `kind`, `url` opcional, `visible` boolean, `position` int. `@@unique([venueId, kind])`, `@@index([venueId])`, cascade no venue. `relationMode = "prisma"`: a unicidade tambem vale na aplicacao.

`VenueLinkKind`: `PRESENTATION`, `BUDGET_FORM`, `RULES`, `WHATSAPP`, `EMAIL`, `GOOGLE_MAPS`, `TOUR_VIDEO`, `ORGANIZATION_SITE`, `SITE`, `INSTAGRAM`, `FACEBOOK`, `TIKTOK`, `YOUTUBE`, `GOOGLE_BUSINESS`, `PINTEREST`, `LINKEDIN`, `TRIPADVISOR`, `AIRBNB`, `MENU`.

Lista padrao, nesta ordem, quando nao ha linha:

1. Apresentacao, Fazer orcamento e Regras, visiveis
2. WhatsApp, visivel se houver numero
3. Instagram, Facebook, TikTok e site, visiveis se a coluna tiver URL
4. E-mail, visivel se houver e-mail
5. Video do tour, visivel se houver `tourVideoUrl`
6. Google Maps, visivel se o `mapQuery` fechar
7. Site da organizacao so entra se `Organization.url` estiver preenchido, e nasce visivel

Tipo colado novo nao entra na lista padrao.

`GET /venue/links/:venueId/editor` autenticado, com `EDIT_VENUE_INFO`, devolve a lista inteira para a aba, inclusive o que esta oculto. `GET /venue/links/:venueId` publico, por nome ou id, como a apresentacao. Resposta: nome, logo, slogan, tres cores e `links: { kind, label, href }[]` so dos visiveis resolviveis, em ordem. Sem dono, preco, contrato ou pagamento.

`PUT /venue/links/:venueId` autenticado, mesma permissao de salvar o espaco. Corpo: a lista inteira do editor. Substitui o conjunto do espaco numa transacao. Tipo repetido volta erro. URL colada que nao esteja verde volta 400. Visivel sem href resolvido volta 400.

No mesmo PUT, a URL verde de `SITE`, `INSTAGRAM`, `FACEBOOK` e `TIKTOK` copia para `url`, `instagramUrl`, `facebookUrl` e `tiktokUrl`. Tipo ausente limpa a coluna. O olho nao entra nessa copia. O salvamento geral de Configuracoes deixa de enviar esses quatro campos.

Checagem da URL colada, nos dois lados, depois de completar `https://`:

- Instagram: `instagram.com/usuario`. Ambar em `/p/`, reel, story e explore
- Facebook: `facebook.com/…` e `profile.php?id=`. O id `100085832906065` e verde
- TikTok: `tiktok.com/@usuario`. Ambar em `/video/`
- Site: `https://` fora de Instagram, Facebook e TikTok
- YouTube: `youtube.com/@`, `/channel/`, `/c/` ou `/user/`. Ambar em `watch?v=` e `youtu.be`, com o texto de que o tour fica em Apresentacao
- Google Meu Negocio: `g.page`, `maps.app.goo.gl` ou `google.com/maps`
- Pinterest: `pinterest.com` ou `br.pinterest.com`
- LinkedIn: `linkedin.com/company/` ou `/in/`
- TripAdvisor: `tripadvisor.com` ou `tripadvisor.com.br`
- Airbnb: `airbnb.com` ou `airbnb.com.br`
- Cardapio ou PDF: qualquer `https://`
- outro dominio: vermelho

Href automatico: apresentacao, formulario e regras pelos helpers existentes; WhatsApp em `wa.me`; e-mail em `mailto:`; mapa pela busca do `mapQuery`; video por `tourVideoUrl`; site da organizacao por `Organization.url`.

## Falhas, casos de borda e invariantes

- uma linha por tipo
- linha oculta permanece na posicao
- origem vazia: `visible` nao grava como verdadeiro; o editor diz a aba de origem
- casa sem linha ligada: pagina com logo e lista vazia
- casa inexistente: nao ha dado de outra casa
- repetir o PUT com o mesmo corpo nao cria segunda linha

## Decisoes arquiteturais importantes

- Tabela, nao JSON na venue. Motivo: posicao, unico por tipo e o mesmo desenho das listas que ja tem `position`.
- Sem backfill. Motivo: a lista padrao ja abre a pagina dos espacos atuais; a `main` nao recebe escrita nesta spec.
- As quatro colunas continuam sendo a fonte da apresentacao e do rodape. Motivo: o olho foi pedido para o link tree, e esses leitores nao podem perder a URL.
- Salvar bloqueia ambar e vermelho nos dois lados. Motivo: URL invalida nao pode ser copiada para a coluna.
- Subir e Descer junto do arraste. Motivo: o arraste nativo nao atende teclado.
- Descartado: biblioteca de drag-and-drop. As fotos ja arrastam sem isso.
- Descartado: esconder a rede na apresentacao junto com o olho. Nao foi o pedido.

## Riscos e mitigacoes

- O PUT geral do espaco zerar as quatro colunas. Mitigacao: Configuracoes para de envia-las; teste cobre o salvamento sem esses campos.
- Pacote publico grande demais. Mitigacao: o DTO do link tree lista so os campos nomeados; teste negativo para dono, preco e contrato.
- `EditVenueForm` da organizacao mudar a coluna sem mudar a lista. Aceito nesta entrega. A lista gravada prevalece no link tree.

## Rollout, observabilidade e rollback

- A migration nasce no repositorio e nao entra na `main` aqui.
- Sem dashboard novo.
- Rollback de codigo: a rota some; as colunas seguem validas. A tabela pode ficar vazia.

## Estrategia de validacao

- `T-01`: unitario da checagem e da lista padrao; `npx prisma validate`
- `T-02`: unitario do GET publico, do PUT e da copia das colunas; a rota publica nao leva `ensureAuthenticate`
- `T-03`: unitario da aba, do bloqueio de Salvar e de Subir/Descer
- `T-04`: unitario da rota, das allowlists e do item da sidebar

## Base documental

- `topics/public-pages-and-branding.md#Demais paginas publicas` e `#Riscos`
- `topics/data-and-migrations.md#Regras`
- `framework-libs/patterns/rules/06_senior_engineering_concepts.md`
- `framework-libs/database/index.md#Modelar schema novo ou dominio novo`
- `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- `framework-libs/design/index.md#Formularios e fluxos de entrada`
