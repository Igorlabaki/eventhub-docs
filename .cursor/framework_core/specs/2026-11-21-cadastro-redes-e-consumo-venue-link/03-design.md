# Design — Cadastro das redes e consumo por venue_link

## Visao geral da solucao

`venue_link` e a unica fonte de quem mostra rede do espaco. Configuracoes cria a linha. A sidebar muda `visible`. A pagina publica e as outras telas leem o href dessa linha.

As quatro colunas `url`, `instagramUrl`, `facebookUrl` e `tiktokUrl` ficam na tabela e ninguem mais desenha icone a partir delas. `whatsappNumber` e `tourVideoUrl` continuam a origem do telefone e do video.

## Passada transversal

- Topologia: sim. A sidebar deixa de abrir a pagina publica. Cadastro e visibilidade ficam em telas diferentes. Sem ADR: a fronteira esta neste arquivo.
- Dados: sim. Escreve e apaga linha em `venue_link`. Sem DDL, sem coluna e sem enum novo.
- Interface: sim. Tela interna nova no molde de Indicar parceiros. A pagina publica perde os controles de dono e conserva o card.
- Producao: nao pede `observability`. Nao ha servico novo. A prova e teste e tela.
- Fluxo sensivel: sim. A leitura publica continua publica. O GET que copia coluna so insere URL ja gravada daquela casa. Ligar e esconder exige `EDIT_VENUE_SITE`.
- Conceito senior: sim, idempotencia. Copia e gravacao do visivel podem repetir. O unico `venueId` + `kind` segura a corrida. Sem fila, cache ou retry externo.

## Fonte dos links

`ensureLegacyVenueLinks` roda no inicio de `GetVenueLinks` e de `GetVenueLinkEditor`, antes de montar a resposta.

Para `SITE`, `INSTAGRAM`, `FACEBOOK` e `TIKTOK`: se a coluna tem URL verde e nao existe linha daquele tipo, insere uma linha visivel com essa URL na proxima `position`. Se a coluna esta vazia ou a checagem nao e verde, nao insere. Se a linha existe, nao altera `url` nem `visible`.

A insercao e idempotente. Conflito no unico `venueId` + `kind` nao vira erro para o cliente. O GET publico escreve so esse insert. O corpo do GET nao traz URL para gravar.

`replace` em `venue-link-in-prisma-repository.ts` deixa de atualizar as quatro colunas. `UpdateVenue` ignora `url`, `instagramUrl`, `facebookUrl` e `tiktokUrl` se vierem no payload. Assim `MinimumPricesTab` e `EditVenueForm` nao apagam o legado. `CreateVenue` pode continuar gravando as colunas; a leitura seguinte copia.

## WhatsApp e tour

No fim de `UpdateVenueUseCase`, com o espaco ja salvo:

- `whatsappNumber` com digitos e sem linha `WHATSAPP`: cria a linha desligada, `url` com a marca `created`.
- `whatsappNumber` vazio e linha existente: apaga a linha.
- O mesmo para `tourVideoUrl` e `TOUR_VIDEO`, exigindo URL de tour ja aceita por `isTourVideoUrl`.
- Linha que ja existe nao muda `visible` quando o numero ou o video mudam.

`venueLinkHref` continua montando `https://wa.me/{digitos}` e devolvendo `tourVideoUrl`. A linha nao guarda uma segunda copia.

O create de link colado passa a receber `visible` booleano. Hoje `createVenueLink` grava visivel. O formulario de Configuracoes envia a resposta da pergunta.

## Tela da sidebar

`sidebar-nav-model.ts` tira `opensExternalUrl` do item Link tree. O caminho interno e `/venue/:id/link-tree`, no painel, sob a permissao `VIEW_VENUE_SITES` que o item ja usa. `/venue/:id/links` continua a pagina publica.

A tela segue `SendSuppliers.tsx`: busca, resumo e linha clicavel. So entram links ja criados. Nao ha seletor de rede nova nem arraste.

O clique manda o visivel desejado, nao um "inverter" cego. `PUT /venue/links/:venueId/visible` com `{ kind, visible }` grava esse valor. Repetir o mesmo valor nao muda nada. Quem nao tem `EDIT_VENUE_SITE` recebe a lista e nao grava.

A ordem nao muda nesta tela.

## Leitores

Os pacotes que hoje copiam as quatro colunas para o cliente passam a incluir a lista visivel ja resolvida: `kind`, `label`, `href`. A montagem e `publicVenueLinks`. As telas trocam o array feito na mao por essa lista.

Entram: `to-venue-presentation.ts`, `to-proposal-presentation.ts`, `getPublicPresentation`, `getWebData`, `getHubData`, `listPermitted` e a copia em `proposal-in-prisma-repository.ts`. No front: `VenuePresentation.tsx`, `ProposalView.tsx`, `ProposalForm.tsx`, `PublicVenueListShell.tsx`, `proposalFooter.tsx`, `EmailTab.tsx`, `VenuesList.tsx`. No site da Guaeca: `Footer.tsx`, lendo o mesmo pacote publico da casa.

`whatsappNumber` e `tourVideoUrl` podem continuar no pacote para o campo e para o player. O icone de rede nao usa a coluna.

Fora: `Organization`, `indication-links.ts`, `PartnerPublicCard.tsx`, `PartnerForm.tsx`.

## Pagina publica

`VenueLinks.tsx` continua o card com icone, seta, titulo e subtitulo. Saem, para todo mundo, Cadastrar link, alca de arraste e Remover. Visitante e dono veem a mesma lista: o que esta cadastrado e visivel.

O topico `topics/public-pages-and-branding.md` descreve o contrario hoje. `T-06` atualiza esse trecho. Nao atualizar antes da tela mudar.

## Aba Redes

A lista, os filtros, os KPIs e o botao de cadastrar ficam. O formulario de URL pergunta se o link nasce visivel e envia esse booleano. O olho sai dessa lista para nao haver dois lugares alterando `visible`. Editar a URL e remover rede continuam no cadastro.

## Contratos e dados

- Sem migration.
- Create: alem de `kind` e `url`, `visible: boolean`.
- Novo `PUT /venue/links/:venueId/visible` com `{ kind, visible }`. O hide atual pode ficar; a sidebar nao depende de inverter no servidor.
- Leitura publica segue `GET /venue/links/:venueId`. Os outros pacotes publicos ganham a lista resolvida e podem manter as colunas no JSON ate as telas trocarem. `T-05` para de ler as colunas. `T-02` ja entrega a lista.

## Falhas, casos de borda e invariantes

- Unico por espaco e tipo.
- Copia nao sobrescreve linha.
- Copia nao cria linha de coluna vazia.
- Update do espaco nao escreve nas quatro colunas.
- `replace` nao escreve nas quatro colunas.
- Pagina publica sem link visivel nao inventa lista.
- Espaco de outra casa nao vaza.

## Decisoes arquiteturais

- Uma fonte de leitura: `venue_link`. As colunas de URL sao legado congelado.
- Copia na leitura, nao num script SQL. O primeiro GET materializa a linha. Repetir nao duplica.
- Visivel desejado no body, para o clique ser idempotente.
- WhatsApp e tour nascem desligados. O legado das quatro colunas nasce visivel so na copia, porque o pedido e o link antigo voltar.
- Controles de dono saem da pagina publica.

Alternativa descartada: coluna `airbnbUrl` e semelhantes. O enum ja cobre o tipo.
Alternativa descartada: a sidebar continuar abrindo a pagina publica. O pedido separa as telas.
Alternativa descartada: script manual no PlanetScale. A aplicacao copia so o que ainda esta na coluna, sem DDL.

## Riscos e mitigacoes

- GET publico passa a escrever. Mitigacao: insert apenas de coluna propria ja gravada, idempotente, sem URL vinda do cliente.
- Tela antiga ainda le a coluna enquanto `T-05` nao fecha. Mitigacao: `T-01` nao apaga a coluna. A ordem das tasks impede zerar antes da troca.
- `EditVenueForm` deixa de mudar Instagram. Mitigacao: o cadastro oficial e a aba Redes. O update ignora os quatro campos.

## Rollout, observabilidade e rollback

Sem flag e sem alerta novo. Publicar a API (`T-01` e `T-02`) antes do front (`T-03` a `T-06`). O site da Guaeca vai com `T-05`.

Rollback: reverter o deploy. As linhas copiadas podem ficar. As colunas nao foram apagadas.

## Estrategia de validacao

- Backend: `npm test` nos specs de links, update do espaco, apresentacao e orcamento.
- Front: `npm test` da sidebar, do editor e da pagina publica; `npm run build`.
- Guaeca: teste do rodape com a lista, se o pacote ja tiver teste; senao, teste novo do mapeamento.
- Browser, na execucao das tasks de tela: Configuracoes, sidebar e `/espaco/AR756/links`.

## Documentos determinantes

- `topics/public-pages-and-branding.md` (controles de dono ainda na pagina publica)
- `framework-libs/patterns/rules/06_senior_engineering_concepts.md`
- `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- `project/active-libs.md#Leituras por frente`
