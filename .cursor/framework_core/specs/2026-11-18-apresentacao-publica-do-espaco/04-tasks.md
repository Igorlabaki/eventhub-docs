# Tasks — Apresentacao publica do espaco

## Ordem macro

1. `T-01` abre `GET /venue/presentation/:venueId` com o recorte fechado.
2. `T-02` desenha `/venue/:id/apresentacao` e registra a rota nas duas allowlists. Depende de `T-01`.
3. `R-12` nao tem task: o item Apresentação ja abre o endereco em outra aba.

## Tasks

### T-01 - Leitura publica da casa

- objetivo: `GET /venue/presentation/:venueId` devolve o recorte da casa, dos servicos e do preco ativo, e as rotas atuais do venue continuam exigindo login.
- cobre requisitos: `R-01`, `R-02`, `R-03`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `HttpResourceNotFoundError`, o formato de caracteristica de `toProposalPresentation`, o filtro `isShowOnProposal`
- prompt recomendado: `normal`
- estrategia de teste: vitest do mapper e do use case; o router prova que a rota nova nao usa `ensureAuthenticate` e que `/update` continua usando
- cenarios obrigatorios:
  - venue completo volta so as chaves de `03-design.md#Contratos e dados`
  - foto com `isShowOnProposal` falso fica de fora; a ordem e `position`
  - servico volta sem `price` e em ordem alfabetica de `name`
  - `pricing.amount` e o campo do `pricingModel`; os outros tres precos nao saem
  - `minimumPrice` 0 vira `null`
  - venue inexistente responde 404
  - a resposta nao tem e-mail, CEP, complemento, dono nem preco de servico
- definition of done:
  - o teste cobre o recorte, a foto filtrada, o servico sem preco, o minimo zero e o 404
  - `GET /presentation/:venueId` nao recebe `ensureAuthenticate`
  - nenhuma coluna nova
  - uma linha em `project/api-endpoints.md` marca o GET como publico
  - `npx vitest run` do arquivo novo verde

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — leitura publica de preco de tabela, endereco para o mapa e catalogo
- risco principal: devolver preco de servico, dono, CEP ou total de orcamento
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: pagina, allowlist do frontend, sidebar, migration
- prova minima desta task: vitest verde com 200 filtrado e 404; a rota nova fica sem `ensureAuthenticate`
- criterio de escalada: parar se o recorte precisar de coluna ou de token
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_global/framework-libs/security/rules/02_auth_and_access.md`
  - `.cursor/framework_global/framework-libs/node/skills/creating-core-api-endpoints.md`
  - `.cursor/framework_core/project/project-decisions.md#D-05`
- caminhos candidatos: `art56_server_v3/src/router/venue.ts`, `art56_server_v3/src/router/venue-rule.ts`, `art56_server_v3/src/functions/to-proposal-presentation.ts`, `art56_server_v3/src/use-cases/venue-rule/list-public-venue-rule/`
- palavras-chave ou simbolos de busca: `ensureAuthenticate`, `isShowOnProposal`, `HttpResourceNotFoundError`, `pricingModel`
- testes provaveis: vitest do use case novo
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `ProposalView.tsx`

### T-02 - Pagina publica do espaco

- objetivo: sem login, `/venue/:id/apresentacao` mostra os blocos na ordem fechada e omite secao vazia.
- cobre requisitos: `R-04`, `R-05`, `R-06`, `R-07`, `R-08`, `R-09`, `R-10`, `R-11`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `ProposalTourVideo`, `PublicServiceDetailDialog`, `venueTabTitle`, cores e mapa de `ProposalView`
- prompt recomendado: `normal`
- estrategia de teste: funcao pura dos blocos e do preco; as duas allowlists contem o path; `ProposalView` segue com "Seu investimento" e "Sua experiência inclui"
- cenarios obrigatorios:
  - a rota nova nao usa `ProtectedRoute`
  - com video, a primeira foto fica no terceiro bloco e o grid leva o resto
  - sem video, a capa e o hero e a foto seguinte fica no terceiro bloco
  - sem foto, os tres blocos de imagem saem
  - servico nao mostra preco nem Alterar servicos
  - investimento mostra o rotulo do modelo, o minimo so quando maior que zero, e nao mostra total
  - o texto do mapa e bairro e cidade
  - as duas `PUBLIC_ROUTES` contem `/venue/:id/apresentacao`
- definition of done:
  - vitest da funcao pura e das allowlists verde
  - `npm test` do frontend verde
  - `topics/public-pages-and-branding.md` ganha o endereco na lista de paginas que aplicam a marca
  - `project/frontend-map.md` ganha a rota
  - a aba usa `venueTabTitle` e volta ao titulo EventHub ao sair
  - no browser, com sessao, o clique em Apresentação abre a pagina noutra aba; sem sessao, registrar que o login impediu o clique

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a pagina e publica e mostra preco de tabela
- risco principal: a pagina nova alterar o orcamento, ou mostrar total e preco de servico
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: backend, sidebar, migration, modo novo dentro de `ProposalView`
- prova minima desta task: vitest da ordem dos blocos verde; a rota publica sem `ProtectedRoute`; no browser, a sequencia visivel quando houver login
- criterio de escalada: parar se a pagina precisar mudar o contrato de `T-01` ou o JSX de `ProposalView`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Falhas, casos de borda e invariantes`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Reuso previsto`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/react/skills/creating-frontend-pages.md`
  - `.cursor/framework_global/framework-libs/design/rules/03_layout_grid_and_hierarchy.md`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Orcamento publico`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalView.tsx`, `eventhub-vista-dashboard/src/App.tsx`, `eventhub-vista-dashboard/src/lib/axios.ts`, `eventhub-vista-dashboard/src/hooks/useBootstrapUser.ts`, `eventhub-vista-dashboard/src/lib/venue-tab-title.ts`
- palavras-chave ou simbolos de busca: `PUBLIC_ROUTES`, `venueTabTitle`, `ProposalTourVideo`, `isShowOnProposal`, `Seu investimento`
- testes provaveis: vitest da funcao pura; `npm test` no frontend
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, backend alem do contrato em `03-design.md#Contratos e dados`
