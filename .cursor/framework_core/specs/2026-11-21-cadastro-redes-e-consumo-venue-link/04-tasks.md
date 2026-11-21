# Tasks — Cadastro das redes e consumo por venue_link

## Ordem macro

1. `T-01` firma a fonte no backend.
2. `T-02` entrega a lista resolvida nos pacotes. Pode seguir assim que `T-01` gravar sem apagar coluna.
3. `T-03` e `T-04` podem andar em paralelo depois de `T-01`.
4. `T-05` depende de `T-02`.
5. `T-06` depende de `T-04`, para o dono nao perder o unico lugar que liga o link.

## Tasks

### T-01 - Fonte no venue_link

- objetivo: copiar o legado sem sobrescrever, criar WhatsApp e tour ao salvar, e gravar o visivel pedido sem apagar as quatro colunas.
- cobre requisitos: R-05, R-06, R-07, R-08, R-11, R-13
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `venueLinkHref`, `checkVenueLinkUrl`, `createVenueLink`, unico `venueId` + `kind`
- prompt recomendado: normal
- estrategia de teste: vitest dos use cases de links e de update do espaco
- cenarios obrigatorios:
  - coluna verde sem linha vira linha visivel
  - coluna vazia nao cria linha
  - linha existente nao muda url nem visible na copia
  - repetir a copia nao duplica
  - `replace` e update do espaco nao escrevem nas quatro colunas
  - WhatsApp e tour nascem desligados e somem se o campo esvazia
  - mudar o numero nao muda o visible
  - create colado grava o visible recebido
- definition of done: testes verdes; sem migration; `PUT /venue/links/:venueId/visible` documentado no proprio teste

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — GET publico passa a inserir linha da propria casa
- risco principal: copia sobrescrever link ou update apagar coluna
- repos tocados: `art56_server_v3`
- fora de escopo desta task: telas, sidebar, Guaeca
- prova minima desta task: `npm test` cobre os oito cenarios e nenhum teste exige coluna nova
- criterio de escalada: se a copia precisar de DDL, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Fonte dos links`
- libs obrigatorias: `node`, `patterns`, `database`, `security`
- documentos obrigatorios:
  - `03-design.md#Fonte dos links`
  - `03-design.md#WhatsApp e tour`
  - `framework-libs/patterns/rules/06_senior_engineering_concepts.md`
  - `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- caminhos candidatos: `src/functions/venue-link.ts`, `src/use-cases/venue/venue-links/use-case-venue-links.ts`, `src/repositories/in-prisma/venue-link-in-prisma-repository.ts`, `src/use-cases/venue/update-venue/use-case-update-venue.ts`
- palavras-chave ou simbolos de busca: `venueLinkColumns`, `replace`, `defaultVenueLinks`, `CREATED_VENUE_LINK_MARK`, `whatsappNumber`, `tourVideoUrl`
- testes provaveis: `use-case-venue-links.spec.ts`, spec de update do espaco
- nao ler por padrao: `04-tasks.md`, `01-spec.md`, front, Guaeca

### T-02 - Pacotes publicos com a lista resolvida

- objetivo: apresentacao, orcamento, hub e web entregam os links visiveis resolvidos, sem mudar organizacao nem contato.
- cobre requisitos: R-09, R-10, R-12
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`, `T-04`
- reusa: `publicVenueLinks`
- prompt recomendado: normal
- estrategia de teste: vitest dos packs de apresentacao e de orcamento
- cenarios obrigatorios:
  - link visivel entra com kind, label e href
  - link oculto nao entra
  - WhatsApp usa wa.me do numero atual
  - tipos de apresentacao, orcamento, regras, e-mail, mapa e site da organizacao nao mudam de regra
  - payload de contato e de organizacao segue sem `venue_link`
- definition of done: testes verdes; as colunas podem continuar no JSON, mas o clique novo tem campo proprio

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — pacote publico
- risco principal: misturar link de contato ou de organizacao no pacote do espaco
- repos tocados: `art56_server_v3`
- fora de escopo desta task: trocar as telas, sidebar
- prova minima desta task: spec do pack mostra href vindo da linha e esconde o link oculto
- criterio de escalada: se o pacote precisar de campo que vaze dono ou contrato, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Leitores`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Leitores`
  - `03-design.md#Contratos e dados`
  - `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- caminhos candidatos: `src/functions/to-venue-presentation.ts`, `src/functions/to-proposal-presentation.ts`, `src/repositories/in-prisma/venue-in-prisma-repository.ts`, `src/repositories/in-prisma/proposal-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `instagramUrl`, `publicVenueLinks`, `getPublicPresentation`, `getHubData`
- testes provaveis: `use-case-get-venue-presentation.spec.ts`, `use-case-get-proposal-presentation.spec.ts`
- nao ler por padrao: `04-tasks.md`, `01-spec.md`, formularios de contato

### T-03 - Pergunta de visivel no cadastro

- objetivo: o formulario de URL em Configuracoes pergunta se o link nasce visivel e envia essa resposta. O olho sai da lista.
- cobre requisitos: R-01
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`, `T-04`
- reusa: `VenueLinkEditor.tsx`, `create` em `venue.service.ts`
- prompt recomendado: smart
- estrategia de teste: vitest do editor
- cenarios obrigatorios:
  - confirmar com visivel marcado envia `visible: true`
  - confirmar desmarcado envia `visible: false`
  - a lista de Configuracoes nao tem controle que altera visible
  - filtros, KPIs e o botao de cadastrar continuam
- definition of done: teste do editor verde; build do front nao e obrigatorio nesta task se o teste cobre o payload

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — tela autenticada de cadastro
- risco principal: dois controles de visible, na aba e na sidebar
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: sidebar, pagina publica, Guaeca
- prova minima desta task: teste do formulario envia o booleano e a lista nao renderiza o olho
- criterio de escalada: se o cadastro precisar de coluna nova, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Aba Redes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Aba Redes`
  - `03-design.md#WhatsApp e tour`
  - `framework-libs/react/index.md`
- caminhos candidatos: `src/components/venue/VenueLinkEditor.tsx`, `src/pages/VenueSettings.tsx`, `src/services/venue.service.ts`
- palavras-chave ou simbolos de busca: `createVenueLink`, `visible`, `saveVenueLinks`
- testes provaveis: `VenueLinkEditor.test.tsx`
- nao ler por padrao: `04-tasks.md`, `01-spec.md`, `security`

### T-04 - Link tree interno na sidebar

- objetivo: o item da sidebar abre a tela de ligar e esconder, salvando o visivel desejado.
- cobre requisitos: R-02, R-03, R-14
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`, `T-03`
- reusa: `SendSuppliers.tsx`, `proposal-indication-sync.ts`, permissao `VIEW_VENUE_SITES` e `EDIT_VENUE_SITE`
- prompt recomendado: normal
- estrategia de teste: vitest da sidebar e da tela
- cenarios obrigatorios:
  - o item nao tem `opensExternalUrl`
  - a rota abre dentro do painel
  - a lista so mostra link ja criado
  - o clique manda `{ kind, visible }` e o segundo manda o oposto
  - repetir o mesmo valor nao dispara outro efeito na UI alem do estado ja salvo
  - quem nao edita o site nao chama o PUT
  - nao ha arraste
- definition of done: testes verdes; rota registrada no painel autenticado

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o PUT grava o que a pagina publica expoe
- risco principal: a sidebar continuar abrindo a URL publica
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: cadastro de URL, cards publicos, Guaeca
- prova minima desta task: teste da sidebar sem link externo e teste do clique mandando o visivel desejado
- criterio de escalada: se precisar de permissao nova, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Tela da sidebar`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Tela da sidebar`
  - `03-design.md#Contratos e dados`
  - `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- caminhos candidatos: `src/components/sidebar/sidebar-nav-model.ts`, `src/pages/SendSuppliers.tsx`, `src/lib/proposal-indication-sync.ts`, `src/services/venue.service.ts`, `src/App.tsx`
- palavras-chave ou simbolos de busca: `opensExternalUrl`, `Link tree`, `EDIT_VENUE_SITE`, `toggleIndication`
- testes provaveis: `sidebar-nav-model.test.ts`
- nao ler por padrao: `04-tasks.md`, `01-spec.md`, pagina publica

### T-05 - Telas leem venue_link

- objetivo: os icones de rede do espaco usam a lista resolvida, no painel publico e no rodape da Guaeca.
- cobre requisitos: R-09
- depende de: `T-02`
- pode rodar em paralelo com: `T-06`
- reusa: o campo de links do pacote de `T-02`
- prompt recomendado: normal
- estrategia de teste: vitest dos mapeamentos de icone no front e na Guaeca
- cenarios obrigatorios:
  - Instagram, Facebook, TikTok e site saem da lista, nao da coluna
  - link ausente nao renderiza icone
  - WhatsApp do icone usa o href da lista
  - player do tour continua podendo usar `tourVideoUrl`
  - contato e organizacao nao entram no diff
- definition of done: testes verdes nos dois repos de UI; `npm run build` do dashboard

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — paginas publicas
- risco principal: deixar uma tela na coluna e o icone sumir
- repos tocados: `eventhub-vista-dashboard`, `guaeca-house-escapade`
- fora de escopo desta task: sidebar, cadastro, pagina `/links`
- prova minima desta task: teste de cada superficie listada no design nao referencia `instagramUrl` para montar o href
- criterio de escalada: se a Guaeca nao receber o pacote novo, parar nessa superficie e nao inventar leitura da coluna
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Leitores`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Leitores`
  - `topics/public-pages-and-branding.md` no trecho das paginas da casa
  - `framework-libs/react/index.md`
- caminhos candidatos: `VenuePresentation.tsx`, `ProposalView.tsx`, `ProposalForm.tsx`, `PublicVenueListShell.tsx`, `proposalFooter.tsx`, `EmailTab.tsx`, `VenuesList.tsx`, `guaeca-house-escapade/src/components/layout/Footer.tsx`
- palavras-chave ou simbolos de busca: `instagramUrl`, `facebookUrl`, `tiktokUrl`, `house.url`
- testes provaveis: testes de apresentacao e de rodape, se existirem; criar o mapeamento onde nao houver
- nao ler por padrao: `04-tasks.md`, `01-spec.md`, `PartnerForm.tsx`

### T-06 - Pagina publica so de leitura

- objetivo: `/espaco/{nome}/links` mostra os cards e nao oferece cadastro, arraste nem remocao.
- cobre requisitos: R-04
- depende de: `T-04`
- pode rodar em paralelo com: `T-05`
- reusa: `VenueLinksView` e o card atual
- prompt recomendado: smart
- estrategia de teste: vitest de `VenueLinks`
- cenarios obrigatorios:
  - visitante ve so link visivel
  - dono tambem nao ve Cadastrar, alca nem Remover
  - lista vazia abre sem lista e sem chamada para cadastrar
  - card conserva icone, seta, titulo e subtitulo
- definition of done: testes verdes; `topics/public-pages-and-branding.md` no trecho de `/espaco/{casa}/links` deixa de descrever cadastro, arraste e remocao na pagina

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — pagina publica
- risco principal: tirar o controle antes da sidebar existir
- repos tocados: `eventhub-vista-dashboard`, `eventhub-docs`
- fora de escopo desta task: redesenho do card, sidebar
- prova minima desta task: render da pagina com `canReorder` nao mostra Cadastrar nem Remover
- criterio de escalada: se a sidebar de `T-04` nao estiver no codigo, nao remover os controles
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Pagina publica`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Pagina publica`
  - `topics/public-pages-and-branding.md` no trecho `/espaco/{casa}/links`
  - `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- caminhos candidatos: `src/pages/VenueLinks.tsx`, `src/pages/VenueLinks.test.tsx`
- palavras-chave ou simbolos de busca: `canReorder`, `Cadastrar`, `RemoveLinkPrompt`, `GripVertical`
- testes provaveis: `VenueLinks.test.tsx`
- nao ler por padrao: `04-tasks.md`, `01-spec.md`, aba Redes
