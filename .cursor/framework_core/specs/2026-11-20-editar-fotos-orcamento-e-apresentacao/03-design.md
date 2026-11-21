# Design — Reordenar e trocar fotos no orcamento e na apresentacao

## Visao geral da solucao

A edicao continua sendo a das imagens do espaco, com a permissao Site que o orcamento ja consulta. A URL nova passa a achar o orcamento pelo codigo publico tambem no catalogo e na gravacao. A apresentacao do espaco ganha o mesmo recorte condicional e dois `PUT` proprios, porque essa pagina nao tem orcamento.

## Passada transversal

- architecture: nao. Mesmas paginas e a mesma tabela de imagem. Sem ADR.
- database: nao. Sem schema. A gravacao mexe em `position` e `isShowOnProposal`, que ja existem.
- design: sim. Alca e Trocar foto na apresentacao, nos mesmos estados do orcamento (arraste, botao desabilitado enquanto salva, dialogo, erro com a foto anterior de volta).
- observability: nao. Sem servico novo. A prova e o status HTTP. Nao logar url nem catalogo.
- security: sim. `GET` publico com usuario opcional; catalogo so com Site; `PUT` autenticado e autorizado no espaco da galeria.
- patterns/rules/06: sim, so concorrencia leve. A ultima gravacao vence. Ordem igual ou a mesma foto nao gravam de novo. Sem fila e sem lock novo.

## Orcamento com codigo publico

`getPresentation` ja resolve id ou codigo (`proposalPublicLookup`). `listVenueImageCatalog` e `listVenueImagesForReorder` ainda fazem `findUnique` por `id`. Com `natal-ceky7u9j` o catalogo volta vazio, `canReorder` continua verdadeiro pelas fotos visiveis, e o frontend esconde Trocar foto (`catalog.length > 1`). O arraste salva porque a tela manda `currentProposal.id`.

`listVenueImageCatalog` e `listVenueImagesForReorder` passam a resolver a chave com `proposalIdFromKey` e so entao buscam por id. Chave invalida devolve `null`, e o use case responde 404. O `GET` e os dois `PUT` do orcamento aceitam id antigo e codigo publico. O teste que prende essas duas leituras ao id, em `proposal-public-key.spec.ts`, muda para exigir a resolucao do codigo.

Nao criar caminho paralelo. `canEditVenueSite` permanece a unica autorizacao.

## Apresentacao do espaco

`GET /venue/presentation/:venueId` continua publico. O controller le `readOptionalUserId`, no mesmo formato do `GET` do orcamento. `canReorder` e `canEditVenueSite(userId, venue.id)` quando ha usuario; senao `false`.

O `select` publico de `getPublicPresentation` continua filtrando `isShowOnProposal: true`. O catalogo completo sai de uma segunda leitura, so quando `canReorder` e verdadeiro. Quem nao edita recebe `canReorder: false` e `catalog: []`. Foto oculta nao entra no objeto publico para ser filtrada depois.

Dois `PUT` novos, os dois com `ensureAuthenticate` e fora de qualquer allowlist publica:

- `PUT /venue/presentation/:venueId/image-order` com `{ imageIds }`
- `PUT /venue/presentation/:venueId/image-choice` com `{ slotId, replacementId }`

A chave do espaco continua nome ou UUID (`venuePublicKeyWhere`). A permissao usa o id real da linha, nao o texto da URL. Os use cases chamam `planVisibleImagePositions` e `planImageChoice` e gravam com `applyImagePositions` e `applyImageChoice`, que ja atualizam a imagem pelo id dela. Nao duplicar a transacao.

Respostas no formato do orcamento: 401 sem token, 403 sem Site, 404 espaco ausente, 400 lista ou foto invalida, 200 quando gravou ou quando nada mudou.

## Contrato

O catalogo tem o mesmo item do orcamento: `id`, `imageUrl`, `description`, `position`, `isShowOnProposal`. As fotos visiveis da apresentacao nao ganham campo novo.

Atualizar `project/api-endpoints.md` na linha do `GET` da apresentacao e com as duas linhas de `PUT`. Atualizar `topics/public-pages-and-branding.md#Orcamento publico` e `#Demais paginas publicas`: as tres paginas editam com Site, nao "o dono" generico.

## Frontend

`ProposalView` ja mostra alca e Trocar foto a partir de `canReorder` e do catalogo. Com `T-01`, a URL nova passa a mostrar Trocar foto sem mudanca de regra. O salvamento pode continuar com `currentProposal.id`.

`VenuePresentation` hoje so desenha `img`. Passa a guardar a ordem local, a alca e o botao nas fotos de `heroPhoto`, `soloPhoto` e `grid`. Arrastar reordena essa lista e `planVenuePhotos` recalcula os lugares. O dialogo e o de `ProposalView`: grade do catalogo, marca "No link", erro com a foto anterior de volta.

Extrair o botao, a alca e o dialogo para um componente usado pelas duas paginas, para o texto e o estado desabilitado nao divergirem. As funcoes `moveImageBefore`, `imageOrderAfterSave` e `replaceProposalImage` continuam as de `reorder-proposal-images` e `choose-proposal-image`.

Chamadas novas em `venue.service`: ordem e troca no `venueId` da rota. O `GET` da apresentacao passa a ler `canReorder` e `catalog`.

## Falhas, casos de borda e invariantes

- Sem sessao ou sem Site: sem url de foto oculta, em qualquer `GET`.
- Foto e posicao so mudam se o plano existente aceitar a lista.
- Uma visivel e varias no catalogo: troca, sem alca. Uma no catalogo: sem troca.
- Nenhuma marcada: sem controles.
- Falha de rede no cliente: restaura a lista anterior. O orcamento ja faz isso; a apresentacao repete.

## Decisoes arquiteturais importantes

- Resolver o codigo dentro das duas leituras do repositorio do orcamento, porque o use case ja recebe a chave crua da URL.
- Catalogo da apresentacao em query separada, so para quem tem Site. Alternativa descartada: ampliar o `select` publico e filtrar no mapper.
- `PUT` no espaco, nao reutilizar o `PUT` do orcamento. A apresentacao nao tem proposta. Alternativa descartada: exigir um orcamento qualquer da casa para editar a apresentacao.
- Manter `EDIT_VENUE_SITE`. Alternativa descartada: passar a `EDIT_VENUE_PHOTOS`, que mudaria quem ja edita o orcamento.

## Riscos e mitigacoes

- Vazar o catalogo no `GET` publico. Mitigacao: segunda query so com `canReorder`, e teste de que a url oculta nao aparece sem Site.
- `PUT` publico por engano. Mitigacao: `ensureAuthenticate` na rota e teste 401.
- Regressao da URL antiga ao extrair o componente. Mitigacao: a regra de exibir alca e botao fica coberta no teste do componente, e `ProposalView` continua com as mesmas condicoes.

## Rollout, observabilidade e rollback

Sem flag e sem migration. O backend novo e compativel com o frontend atual: catalogo preenchido so faz o botao existente aparecer. A apresentacao antiga ignora campo que nao le. Rollback e reverter o deploy. Nao ha dado novo para desfazer alem da ordem que o usuario gravou, que e o efeito pedido.

## Estrategia de validacao

Vitest no backend para codigo publico, catalogo vazio, 401 e 403. Vitest no frontend para alca, Trocar foto e ausencia dos dois. `npm test -- --run` no backend nos specs tocados; `npm test` no frontend nos testes tocados. Browser, se a sessao de Site estiver disponivel: URL nova e apresentacao, arrastar e trocar; sem sessao, ausencia dos controles.

## Fontes

- `topics/public-pages-and-branding.md#Orcamento publico` e `#Demais paginas publicas`
- `topics/permissions-catalog.md#Onde o backend verifica`
- `project/api-endpoints.md` nas linhas de `GET /venue/presentation/:venueId` e `PUT /proposal/presentation/:proposalId/image-order`
- `framework-libs/security/references/auth-and-access-control.md#Principios`
- `framework-libs/patterns/index.md#Aplicar conceito distribuido`
- `framework-libs/design/index.md#Criar ou evoluir componente`
