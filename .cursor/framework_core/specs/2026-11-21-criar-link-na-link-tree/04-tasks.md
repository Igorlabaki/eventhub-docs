# Tasks — criar link na link tree

## Ordem macro

`T-01` abre o write e o `usedKinds`. `T-02` troca o select da aba e pode correr junto de `T-01`. `T-03` liga a pagina publica e espera `T-01`.

## Tasks

### T-01 - Write de criar link na pagina publica

- objetivo: `PUT /venue/links/:venueId/create` grava uma rede para quem tem `EDIT_VENUE_SITE`, recusa visitante, URL ruim, tipo repetido e rede sem destino, e o `GET` so devolve `usedKinds` com essa permissao.
- cobre requisitos: `R-08`, `R-09`, `R-10`, `R-11`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`
- reusa: `loadEditable`, `createVenueLink`, `checkVenueLinkUrl`, `venueLinkSourceHint`, `persistLayout`, `publicData`
- prompt recomendado: `normal`
- estrategia de teste: vitest no spec do use case, no mesmo arquivo que ja cobre order e hide
- cenarios obrigatorios:
  - sem token, 401 e `replace` nao roda
  - token sem `EDIT_VENUE_SITE`, 403 e `replace` nao roda
  - Instagram com URL verde grava, volta no `GET` e entra em `usedKinds`
  - a mesma rede de novo, ainda que oculta, responde 400 e nao grava
  - URL que nao fica verde responde 400 com a mensagem do check e nao grava
  - WhatsApp sem numero responde 400 e nao grava
  - `GET` sem usuario nao tem `usedKinds`; com a permissao tem, inclusive o kind oculto
  - a rota usa `ensureAuthenticate`
- definition of done: os cenarios verdes; `project/api-endpoints.md#Venue, precos e configuracao` ganha a linha do `PUT` create e o `usedKinds` no `GET`; nenhuma migration

#### Context Pack

- frente principal: backend (`art56_server_v3`), rota de links do espaco
- superficie sensivel: sim
- risco principal: o write aceitar quem nao tem `EDIT_VENUE_SITE`, ou o `GET` entregar `usedKinds` ao visitante
- repos tocados: `backend`
- fora de escopo desta task: aba Redes, markup da pagina publica, schema, permissao nova
- prova minima desta task: o spec do use case cobre 401, 403, URL verde, tipo repetido, URL ruim, WhatsApp sem numero e `usedKinds` ausente no visitante
- criterio de escalada: se o create precisar de coluna ou de permissao nova, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Write da pagina publica`
- libs obrigatorias: `node`, `security`
- documentos obrigatorios:
  - `03-design.md#Write da pagina publica`
  - `framework-libs/security/references/auth-and-access-control.md`
  - `framework-libs/node/skills/creating-core-api-endpoints.md`
  - `project/api-endpoints.md#Venue, precos e configuracao`
  - `project/agent-entrypoint.md#Regras de ouro`
- caminhos candidatos: `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.ts`; `controller-venue-links.ts`; `factory-venue-links.ts`; `src/router/venue.ts`; `src/zod/venue/save-venue-links-schema.ts`; `src/functions/venue-link.ts`
- palavras-chave ou simbolos de busca: `loadEditable`, `HideVenueLinkUseCase`, `createVenueLink`, `canEditVenueSite`, `usedKinds`
- testes provaveis: `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `database`, a aba Redes

### T-02 - Botao e modal na aba Redes

- objetivo: a faixa da aba perde o select "Escolher rede" e ganha "Cadastrar link"; o modal escolhe a rede e a URL, e a linha so vai para a API no salvamento que ja existe.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`
- reusa: `Dialog`, `VenueLinkUrlForm`, `createVenueLink`, `remainingVenueLinkKinds`, `checkVenueLinkUrl`
- prompt recomendado: `smart`
- estrategia de teste: vitest com `renderToStaticMarkup` no teste do editor
- cenarios obrigatorios:
  - o markup tem "Cadastrar link" e nao tem "Escolher rede"
  - rede colada mostra o campo URL; rede do sistema nao mostra
  - confirmar Instagram com URL verde acrescenta a linha e nao chama a API
  - tipo ja usado nao aparece nas opcoes
  - sem kind restante, o botao fica desabilitado
  - "Nenhuma rede criada" continua na lista vazia
- definition of done: os cenarios verdes; `npm test` do arquivo do editor verde; o lapis de editar URL continua

#### Context Pack

- frente principal: frontend, `VenueLinkEditor` na aba `redes`
- superficie sensivel: nao
- risco principal: o select sair e o modal nao cobrir rede colada e rede do sistema, ou o confirmar passar a gravar sozinho
- repos tocados: `frontend`
- fora de escopo desta task: pagina publica, rota nova, texto do vazio da aba
- prova minima desta task: o teste do editor mostra o botao, esconde o select e acrescenta a linha sem chamada HTTP
- criterio de escalada: se a aba precisar do write de `T-01`, parar; a premissa e estado local ate "Salvar Alteracoes"
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Modal da aba Redes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Modal da aba Redes`
  - `framework-libs/design/rules/06_forms_and_input_ux.md`
  - `framework-libs/react/rules/main_index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx`; `src/lib/venue-link.ts`; `src/pages/VenueSettings.tsx`
- palavras-chave ou simbolos de busca: `Escolher rede`, `VenueLinkUrlForm`, `remainingVenueLinkKinds`, `createVenueLink`, `isPastedVenueLink`
- testes provaveis: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.test.tsx`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, backend

### T-03 - Criar, vazio e gestao na pagina publica

- objetivo: quem tem `canReorder` cadastra pelo modal na propria pagina, ve o container quando nao ha link, e quem visita nao ve gestao.
- cobre requisitos: `R-05`, `R-06`, `R-07`, `R-12`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `VenueLinksView`, `venueLinkChrome`, `Dialog`, `cardClass`, `cardStyle`, o cliente de `order` e `hide`
- prompt recomendado: `normal`
- estrategia de teste: vitest com `renderToStaticMarkup` em `VenueLinks.test.tsx`, mais o cliente no service se o teste de falha ficar no helper da pagina
- cenarios obrigatorios:
  - `canReorder` e zero links mostram o texto "Ainda nao ha link cadastrado na sua link tree" e "Cadastrar link"
  - `canReorder` falso e zero links nao mostram container, botao nem `<ul>`
  - com links e `canReorder`, o botao fica acima da lista; alca e remover continuam
  - visitante nao ve "Cadastrar link", alca nem remover
  - sucesso do create troca a lista pela resposta
  - falha do create mantem a lista e a mensagem no modal
- definition of done: os cenarios verdes; `venue.service` tem `createVenueLink`; `topics/public-pages-and-branding.md#Demais paginas publicas` registra o botao e o container; arrastar e remover nao regridem

#### Context Pack

- frente principal: frontend, pagina `/espaco/:id/links`
- superficie sensivel: sim
- risco principal: o botao ou o container aparecerem para o visitante, ou o create otimista deixar um card que o servidor recusou
- repos tocados: `frontend`
- fora de escopo desta task: aba Redes, mudar a rota, `PUBLIC_ROUTES`
- prova minima desta task: o teste da pagina cobre o container com permissao, a ausencia sem permissao, o botao com lista cheia e a lista intacta quando o create falha
- criterio de escalada: se o `GET` nao trouxer `usedKinds`, parar e voltar a `T-01`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Pagina publica`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Pagina publica`
  - `03-design.md#Write da pagina publica`
  - `framework-libs/design/skills/designing-empty-loading-error-states.md`
  - `framework-libs/security/references/auth-and-access-control.md`
  - `topics/public-pages-and-branding.md#Demais paginas publicas`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueLinks.tsx`; `src/services/venue.service.ts`; `src/lib/venue-link.ts`
- palavras-chave ou simbolos de busca: `canReorder`, `venueLinkChrome`, `usedKinds`, `createVenueLink`, `orderVenueLinks`, `hideVenueLink`
- testes provaveis: `eventhub-vista-dashboard/src/pages/VenueLinks.test.tsx`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `database`, a aba Redes
