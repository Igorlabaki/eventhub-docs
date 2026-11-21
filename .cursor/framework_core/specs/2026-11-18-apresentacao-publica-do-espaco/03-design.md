# Design — Apresentacao publica do espaco

## Visao geral da solucao

Uma leitura publica nova monta o recorte da casa. Uma pagina nova desenha os blocos na ordem fechada. `ProposalView` nao ganha modo. A sidebar ja abre o endereco e nao entra de novo nesta feature.

Passada transversal:

- fronteira: nao muda; um GET a mais na API que ja existe. Sem ADR.
- dados persistidos: nao; le venue, foto, caracteristica e servico. Sem migration.
- interface: sim; pagina publica nova na marca do espaco.
- producao: sim, sem dashboard novo; 404 e secao omitida bastam.
- fluxo sensivel: sim; GET publico por id, com lista fechada de campos e teste negativo.
- conceito senior (`patterns/rules/06`): nao; leitura unica, sem fila, retry, cache ou idempotencia.

## Componentes e modulos impactados

- `art56_server_v3/src/router/venue.ts`: `GET /presentation/:venueId` sem `ensureAuthenticate`. O router esta montado em `/venue`. As rotas atuais de gravacao e relatorio continuam com o middleware em cada uma.
- use case novo `get-venue-presentation`, no formato controller, use case e factory de `list-public-venue-rule`.
- mapper `toVenuePresentation`, ao lado de `to-proposal-presentation.ts`, sem reutiliza-lo: aquele mapper nao tem servico nem preco e ainda carrega `canReorder` e catalogo.
- `eventhub-vista-dashboard/src/pages/VenuePresentation.tsx`: pagina nova.
- `src/lib/venue-presentation.ts`: funcao pura da ordem dos blocos e do recorte de preco.
- `App.tsx`: rota ao lado de `/venue/:id/rules/view`, sem `ProtectedRoute`.
- `src/lib/axios.ts` e `src/hooks/useBootstrapUser.ts`: as duas `PUBLIC_ROUTES`.

## Reuso previsto

- `ProposalTourVideo`, `resolveTourVideo`, `PublicServiceDetailDialog`, `venueTabTitle` e as classes de cor ja usadas em `ProposalView`.
- Formato de caracteristica igual ao de `toProposalPresentation`: `name`, `position`, `description`, `images`, `imageUrl`, `videoUrl`.
- Mapa: mesmos campos e o mesmo iframe de `ProposalView` (`neighborhood — city` no texto).
- Nao extrair um shell compartilhado de `ProposalView` nesta feature. O risco e alterar o orcamento para ganhar a pagina nova.

## Contratos e dados

`GET /venue/presentation/:venueId`

Sucesso `200`:

- casa: `name`, `description`, `logoUrl`, `proposalPrimaryColor`, `proposalSecondaryColor`, `proposalTextColor`, `url`, `instagramUrl`, `facebookUrl`, `tiktokUrl`, `tourVideoUrl`, `whatsappNumber`, `neighborhood`, `city`, `state`, `street`, `streetNumber`, `maxGuest`, `hasOvernightStay`, `checkIn`, `checkOut`, `minimumNights`, `openingHour`, `closingHour`
- `images`: so `isShowOnProposal === true`, por `position`; cada item `id`, `imageUrl`, `description`, `position`
- `amenities`: formato da proposta, por `position`
- `services`: `{ id, name, description, imageUrl }`, ordem alfabetica de `name`; sem `price`, `pricingType`, `rpaRequired`, `rpaMinPeople`
- `pricing`: `{ model, amount, minimumPrice }`. `model` e o `pricingModel` do venue. `amount` e so o campo daquele modelo (`pricePerPerson`, `pricePerDay`, `pricePerPersonDay` ou `pricePerPersonHour`). `TIERED` nao tem preco unico, entao `amount` fica `null` e a tabela de faixas nao sai. `minimumPrice` vai `null` quando for `null` ou `0`

Ausencia: e-mail, CEP, complemento, donos, organizacao, contrato, pagamento, os outros tres precos, preco de servico, `canReorder`, catalogo.

Venue inexistente: `404` com o erro de recurso nao encontrado que o projeto ja usa. Nao devolve venue parcial.

## Falhas, casos de borda e invariantes

- A pagina escolhe os blocos por uma funcao pura, nao por condicional espalhada no JSX.
- Com video: hero video; terceira posicao e `images[0]`; grid e `images` a partir do indice 1.
- Sem video e com fotos: hero e `images[0]`; terceira posicao e `images[1]` se existir; grid e o restante.
- Sem foto: hero, foto solta e grid saem.
- Caracteristica sem complemento nao ganha `?`. Servico sem descricao e sem imagem tambem nao.
- Seu investimento sai inteiro quando nao ha `amount`, nao ha minimo e nao ha WhatsApp.
- Troca de venue na mesma aba zera o estado antes da resposta nova.
- Antes da resposta, nenhum logo EventHub.

## Decisoes arquiteturais importantes

- Endpoint proprio em vez de reaproveitar `GET /proposal/presentation/:proposalId`. Aquele contrato e de um orcamento e nao leva catalogo nem preco de tabela.
- Pagina propria em vez de um modo em `ProposalView`. O orcamento continua com proposta e total.
- Fotos de `isShowOnProposal`, nao as do site da organizacao. A pagina fica alinhada ao que o orcamento ja mostra.
- Sem schema. Preco e servico ja estao no venue.
- Alternativa descartada: colocar o preco de cada servico em Seu investimento. O chat deixou o preco do servico fora.

## Riscos e mitigacoes

- Vazar campo interno: o teste do mapper lista as chaves permitidas e falha se `price`, `email`, `cep` ou dono aparecerem.
- ID publico do venue: o mesmo aceite de regras e da proposta (`D-05`). Nao ha token novo.
- Link da sidebar abre 404 ate `T-02`. Aceito: o item ja foi pedido antes da pagina.

## Rollout, observabilidade e rollback

- Sem migration e sem flag. Publicar a API antes do frontend, senao o clique da sidebar continua em pagina vazia.
- Rollback: tirar a rota publica e a pagina. A sidebar volta a abrir um endereco sem tela. Nao ha dado novo para desfazer.
- Sem alerta novo.

## Estrategia de validacao

- `T-01`: vitest do use case e do mapper, mais a ausencia de `ensureAuthenticate` nessa rota.
- `T-02`: vitest da funcao pura de blocos e das duas allowlists; a pagina no browser quando houver sessao. Sem sessao, o teste de rota prova que nao ha `ProtectedRoute`.

## Fontes que fecharam a solucao

- `topics/public-pages-and-branding.md#Orcamento publico` para a ordem e a marca que esta pagina reaproveita
- `project-decisions.md#D-05` para a leitura publica por id
- `project-decisions.md#D-07` para nao migrar `Float` aqui
- `router/venue-rule.ts` para a rota publica antes da area autenticada
- `to-proposal-presentation.ts` e o filtro `isShowOnProposal` para o recorte de foto e caracteristica
