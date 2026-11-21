# Tasks — Reordenar e trocar fotos no orcamento e na apresentacao

## Ordem macro

`T-01` e `T-02` nao dependem uma da outra. `T-03` depende de `T-02` para gravar na apresentacao. A URL nova mostra Trocar foto assim que `T-01` estiver no ar, porque `ProposalView` ja le o catalogo.

## Tasks

### T-01 - Catalogo e gravacao do orcamento aceitam o codigo publico

- objetivo: quem tem Site, na URL nova, recebe o catalogo e consegue trocar a foto; sem Site, o catalogo continua vazio.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-06`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`
- reusa: `proposalIdFromKey`, `canEditVenueSite`, `planImageChoice`, `planVisibleImagePositions`
- prompt recomendado: normal
- estrategia de teste: vitest nos specs de apresentacao, escolha e ordem, mais o spec que hoje prende as leituras ao id
- cenarios obrigatorios:
  - codigo publico e Site: `GET` devolve `canReorder: true` e o catalogo com a foto de fora
  - codigo publico sem token, e com token sem Site: `catalog` vazio e a url oculta ausente
  - `PUT image-choice` e `PUT image-order` com o codigo publico e Site gravam; sem token 401; sem Site 403
  - id antigo continua gravando ordem e troca
  - codigo inexistente responde 404
- definition of done:
  - `listVenueImageCatalog` e `listVenueImagesForReorder` resolvem a chave antes do `findUnique` por id
  - o teste que proibia `publicCode` nessas duas leituras passa a exigir a resolucao
  - `npm test -- --run` nos specs tocados verde
  - nada de schema, permissao nova ou mudanca em `ProposalView`

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — `GET` publico passa a devolver catalogo quando a chave e o codigo
- risco principal: foto oculta no corpo para quem nao tem Site
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: apresentacao do espaco, componente visual, `EDIT_VENUE_PHOTOS`
- prova minima desta task: `GET /proposal/presentation/{codigo}` com Site devolve catalogo; sem Site, `catalog: []` e sem a url oculta
- criterio de escalada: parar se a resolucao do codigo exigir coluna ou indice novo
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Orcamento com codigo publico`
- libs obrigatorias: `security`, `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Orcamento com codigo publico`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `framework-libs/security/references/auth-and-access-control.md#Principios`
  - `topics/permissions-catalog.md#Onde o backend verifica`
- caminhos candidatos: `proposal-in-prisma-repository.ts` (`listVenueImageCatalog`, `listVenueImagesForReorder`, `proposalIdFromKey`); `use-case-get-proposal-presentation.ts`; `proposal-public-key.spec.ts`
- palavras-chave ou simbolos de busca: `listVenueImageCatalog`, `proposalIdFromKey`, `canReorder`, `publicCode`
- testes provaveis: `use-case-get-proposal-presentation.spec.ts`, `use-case-choose-proposal-image.spec.ts`, `use-case-reorder-proposal-images.spec.ts`, `proposal-public-key.spec.ts`
- nao ler por padrao: `VenuePresentation`, specs de preco, `database`

### T-02 - Apresentacao do espaco devolve catalogo e grava ordem e troca

- objetivo: o `GET` da apresentacao so inclui o catalogo para quem tem Site, e os dois `PUT` gravam a galeria do espaco com a mesma autorizacao.
- cobre requisitos: `R-04`, `R-05`, `R-06`, `R-07`, `R-08`, `R-09`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`
- reusa: `readOptionalUserId`, `canEditVenueSite`, `venuePublicKeyWhere`, `planVisibleImagePositions`, `planImageChoice`, `applyImagePositions`, `applyImageChoice`
- prompt recomendado: normal
- estrategia de teste: vitest do use case e do controller da apresentacao, com o mesmo formato dos specs do orcamento (200, 401, 403, catalogo vazio, 400)
- cenarios obrigatorios:
  - sem token: `canReorder: false`, `catalog: []`, url oculta ausente do corpo
  - token sem Site: igual ao sem token; `PUT` 403 e nao grava
  - token com Site: catalogo inclui foto de fora; `PUT` de ordem e de troca gravam e a leitura seguinte mostra o resultado
  - lista de ids que nao bate, ou foto de outro espaco: 400 e estado anterior intacto
  - nome do espaco e UUID antigo abrem a mesma casa
  - espaco inexistente: 404
- definition of done:
  - `GET` nao amplia o `select` publico; a segunda leitura so roda com Site
  - `PUT /venue/presentation/:venueId/image-order` e `image-choice` com `ensureAuthenticate`, fora da allowlist
  - `project/api-endpoints.md` descreve o `GET` condicional e os dois `PUT`
  - `npm test -- --run` nos specs tocados verde
  - nenhuma permissao nova e nenhum campo alem de `canReorder` e `catalog`

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — rota publica da casa e gravacao da galeria
- risco principal: `PUT` ficar publico ou o `GET` levar foto oculta para o visitante
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: markup da apresentacao, URL do orcamento, biblioteca de fotos
- prova minima desta task: sem token o `GET` nao tem url oculta; com Site o `PUT image-choice` troca a foto visivel
- criterio de escalada: parar se a gravacao precisar de tabela nova ou de uma permissao diferente de Site
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Apresentacao do espaco`
- libs obrigatorias: `security`, `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Apresentacao do espaco`
  - `03-design.md#Contrato`
  - `framework-libs/security/references/auth-and-access-control.md#Principios`
  - `project/api-endpoints.md` (linha de `GET /venue/presentation/:venueId`)
- caminhos candidatos: `controller-get-venue-presentation.ts`; `use-case-get-venue-presentation.ts`; `to-venue-presentation.ts`; `router/venue.ts`; `use-case-reorder-proposal-images.ts`; `use-case-choose-proposal-image.ts`
- palavras-chave ou simbolos de busca: `readOptionalUserId`, `getPublicPresentation`, `isShowOnProposal`, `ensureAuthenticate`, `applyImageChoice`
- testes provaveis: `use-case-get-venue-presentation.spec.ts`; specs de ordem e escolha do orcamento, como modelo de 401 e 403
- nao ler por padrao: `ProposalView.tsx`, `database`, specs de preco

### T-03 - Alca e Trocar foto na apresentacao

- objetivo: a apresentacao mostra e usa os mesmos controles do orcamento, so quando o `GET` traz `canReorder` e catalogo suficiente.
- cobre requisitos: `R-04`, `R-05`, `R-08`, `R-10`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: alca, botao e dialogo de `ProposalView`; `moveImageBefore`, `imageOrderAfterSave`, `replaceProposalImage`; `planVenuePhotos`
- prompt recomendado: normal
- estrategia de teste: vitest do componente compartilhado e da apresentacao; a URL antiga permanece com alca e Trocar foto sob as mesmas condicoes
- cenarios obrigatorios:
  - `canReorder` com duas ou mais visiveis: alca no hero, na foto solta e no grid
  - catalogo com duas ou mais: Trocar foto; escolher outra chama o `PUT` do espaco e a foto muda
  - uma visivel e catalogo maior: Trocar foto, sem alca
  - `canReorder: false` ou catalogo vazio: nenhum controle
  - falha do `PUT`: a foto anterior volta e a mensagem de erro aparece
  - `ProposalView` nao perde alca nem Trocar foto
- definition of done:
  - botao, alca e dialogo extraidos e usados por `ProposalView` e `VenuePresentation`
  - `topics/public-pages-and-branding.md` diz que as tres paginas editam com Site
  - `npm test` nos testes tocados verde
  - se houver sessao de Site no browser: arrastar e trocar na apresentacao e na URL nova; sem sessao, conferir a ausencia dos controles

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a pagina publica passa a exibir e gravar a galeria quando o contrato autoriza
- risco principal: mostrar Trocar foto, ou o catalogo, quando `canReorder` e falso
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: regra de permissao no backend, layout dos blocos, biblioteca de fotos
- prova minima desta task: apresentacao com `canReorder: true` e catalogo de duas fotos mostra Trocar foto e a alca; com `canReorder: false`, nao mostra nenhum dos dois
- criterio de escalada: parar se a extracao mudar a ordem dos blocos da apresentacao ou do orcamento
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Frontend`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Frontend`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `framework-libs/design/index.md#Criar ou evoluir componente`
  - `topics/public-pages-and-branding.md#Demais paginas publicas`
- caminhos candidatos: `VenuePresentation.tsx`; `ProposalView.tsx` (`PhotoChoiceButton`, dialogo Escolher foto); `lib/venue-presentation.ts` (`planVenuePhotos`); `lib/reorder-proposal-images.ts`; `lib/choose-proposal-image.ts`; `services/venue.service.ts`
- palavras-chave ou simbolos de busca: `Trocar foto`, `canReorder`, `planVenuePhotos`, `replaceProposalImage`, `heroPhoto`
- testes provaveis: teste novo da apresentacao com e sem `canReorder`; teste existente de `ProposalView` ou do componente extraido
- nao ler por padrao: `04-tasks.md` inteiro, specs de preco, `database`
