# Tasks — Link publico das regras do espaco

## Ordem macro

1. `T-01` abre a leitura publica e prova que a gravacao continua fechada.
2. `T-02` faz a pagina, a copia no painel e as allowlists. Depende de `T-01`.
3. `T-03` acrescenta o botao no Link do evento. Pode correr em paralelo com `T-01` e `T-02`: o href ja esta fechado em `03-design.md#Tela Regras e Link do evento`.

## Tasks

### T-01 - Leitura publica das regras

- objetivo: `GET /venue-rule/public/:venueId` devolve so as regras daquele espaco, e as rotas antigas seguem exigindo login.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`
- depende de: nenhuma
- pode rodar em paralelo com: `T-03`
- reusa: `listByVenue`, `HttpResourceNotFoundError`, schema de `venueId`, formato de resposta de `VenueRule`
- prompt recomendado: `normal`
- estrategia de teste: casos novos em `venue-rule.spec.ts` para o use case publico; as rotas de gravacao e a listagem autenticada permanecem atras de `ensureAuthenticate`
- cenarios obrigatorios:
  - venue com duas regras volta na ordem do repositorio e so com `id`, `title`, `text`, `position`
  - titulo nulo permanece nulo
  - venue sem regras responde sucesso com `data: []`
  - venue inexistente responde 404
  - o use case publico nao chama o authorizer
  - `GET /public/:venueId` esta registrado antes de `ensureAuthenticate`; list, create, update e delete continuam depois
- definition of done:
  - o teste do use case cobre ordem, campos, lista vazia e 404
  - a rota publica nao exige usuario
  - nenhuma coluna nova
  - `npx vitest run src/use-cases/venue-rule/venue-rule.spec.ts` verde

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — leitura que hoje exige login passa a ser publica
- risco principal: devolver regra de outro venue ou campo alem de id, titulo, texto e posicao
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: pagina, copia, Link do evento, migration
- prova minima desta task: o vitest do use case verde, com 200 filtrado, 200 vazio e 404; no router, `GET /public/:venueId` fica antes de `ensureAuthenticate`
- criterio de escalada: parar se a leitura publica precisar de coluna ou de mudar a permissao de gravacao
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_global/framework-libs/security/rules/02_auth_and_access.md`
  - `.cursor/framework_global/framework-libs/node/skills/creating-core-api-endpoints.md`
  - `.cursor/framework_core/project/project-decisions.md#D-02`
- caminhos candidatos: `art56_server_v3/src/router/venue-rule.ts`, `art56_server_v3/src/use-cases/venue-rule/list-venue-rule/`, `art56_server_v3/src/use-cases/venue-rule/venue-rule.spec.ts`
- palavras-chave ou simbolos de busca: `ensureAuthenticate`, `listByVenue`, `ListVenueRuleUseCase`, `HttpResourceNotFoundError`
- testes provaveis: `npx vitest run src/use-cases/venue-rule/venue-rule.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, pagina publica, Link do evento

### T-02 - Pagina publica e copia no painel

- objetivo: sem login, `/venue/:id/rules/view` mostra as regras na marca do espaco, e a tela Regras copia esse endereco.
- cobre requisitos: `R-06`, `R-07`, `R-08`, `R-09`, `R-10`, `R-12`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: `PublicVenueListShell`, `usePublicListVenue`, gesto de copia de `ProposalEventLinkShare`
- prompt recomendado: `normal`
- estrategia de teste: funcao pura da ordem, do titulo ausente e do endereco, mais a presenca do path nas duas allowlists
- cenarios obrigatorios:
  - a rota nova nao usa `ProtectedRoute`
  - item sem titulo ainda expoe o texto
  - lista vazia usa a frase "Ainda não há regras deste espaço."
  - falha nao mantem regra do venue anterior
  - o texto nao e renderizado como HTML
  - Copiar fica visivel sem `EDIT_VENUE_RULES`
  - as duas allowlists contem `/venue/:id/rules/view`
- definition of done:
  - vitest da funcao pura verde
  - uma frase em `product/04-user-journeys.md#Captar e fechar um evento` diz que o cliente le as regras do espaco em `/venue/:id/rules/view` sem login
  - `npm test` do frontend verde
  - a aba volta ao titulo EventHub pela casca, sem titulo proprio esquecido na pagina

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a pagina e publica e um 401 nao pode mandar o visitante ao login
- risco principal: mostrar regra ou marca de outro espaco, ou interpretar o texto como HTML
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: contrato da API, botao do Link do evento, cadastro
- prova minima desta task: vitest cobre ordem, titulo ausente, frase vazia e path; as allowlists de `axios.ts` e `useBootstrapUser.ts` incluem `/venue/:id/rules/view`
- criterio de escalada: parar se a pagina precisar de campo que `GET /venue-rule/public/:venueId` nao devolve
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Pagina publica`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Pagina publica`
  - `03-design.md#Tela Regras e Link do evento`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
  - `.cursor/framework_global/framework-libs/security/rules/02_auth_and_access.md`
  - `.cursor/framework_core/product/04-user-journeys.md#Captar e fechar um evento`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/PublicVenueListShell.tsx`, `eventhub-vista-dashboard/src/pages/VenueRules.tsx`, `eventhub-vista-dashboard/src/pages/ProposalEventLinkShare.tsx`, `eventhub-vista-dashboard/src/lib/axios.ts`, `eventhub-vista-dashboard/src/hooks/useBootstrapUser.ts`
- palavras-chave ou simbolos de busca: `PUBLIC_ROUTES`, `usePublicListVenue`, `ProtectedRoute`, `rules/view`
- testes provaveis: `npm test` no frontend
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, use cases de gravacao

### T-03 - Botao no Link do evento

- objetivo: o Link do evento abre as regras do espaco daquele orcamento.
- cobre requisitos: `R-11`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-02`
- reusa: `eventLinkDestinations` e o card que a pagina ja desenha
- prompt recomendado: `smart`
- estrategia de teste: estender `event-link.test.ts`
- cenarios obrigatorios:
  - sem `venueId`, os cinco hrefs atuais permanecem e nao surge regras
  - com `venueId`, o sexto href e `/venue/${venueId}/rules/view`
  - o conjunto continua sem pagamento, contrato, documento ou edicao
- definition of done:
  - `eventLinkDestinations` recebe o venue e a pagina passa `clock?.venueId`
  - o teste de `event-link.test.ts` verde
  - nenhum destino antigo muda de href

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o botao publica o endereco das regras numa pagina sem login
- risco principal: apontar para `/venue/:id/rules` do painel, ou omitir o botao quando o venue ja veio no orcamento
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: API, pagina de regras, tela de copiar, casca
- prova minima desta task: `npm test` cobre os cinco hrefs sem venue e o sexto `/venue/venue-1/rules/view` com venue
- criterio de escalada: parar se o botao exigir dado que a proposta publica ainda nao devolve
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Tela Regras e Link do evento`
- libs obrigatorias: `react`
- documentos obrigatorios:
  - `03-design.md#Tela Regras e Link do evento`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
- caminhos candidatos: `eventhub-vista-dashboard/src/lib/event-link.ts`, `eventhub-vista-dashboard/src/lib/event-link.test.ts`, `eventhub-vista-dashboard/src/pages/ProposalEventLink.tsx`
- palavras-chave ou simbolos de busca: `eventLinkDestinations`, `EventLinkIcon`, `clock?.venueId`
- testes provaveis: `npm test -- src/lib/event-link.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, backend
