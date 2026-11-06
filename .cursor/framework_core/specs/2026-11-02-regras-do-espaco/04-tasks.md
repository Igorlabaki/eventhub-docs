# Tasks — Regras do espaco

## Ordem macro

1. `T-01` cria a tabela
2. `T-02` e `T-03` podem seguir em paralelo
3. `T-04` espera o contrato da API e o catalogo de permissao

Nao executar o conjunto num unico passo. Depois do review, `fw:split` separa `backend` e `frontend`.

## Tasks

### T-01 - Criar a tabela venue_rule

- objetivo: persistir regra de venue com titulo, texto, posicao e vinculo ao venue
- cobre requisitos: `R-01`, `R-07`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: model `Service` como referencia de id UUID e indice por `venueId`
- prompt recomendado: `normal`
- estrategia de teste: `npx prisma validate` e revisao do SQL gerado
- cenarios obrigatorios: tabela nova com indice em `venueId`; `onDelete: Cascade` so no client Prisma; migration sem `UPDATE` de permissao
- definition of done: model no schema, relacao `rules` em `Venue`, migration aditiva aplicada no ambiente local, SQL sem backfill; sem promocao de topic

#### Context Pack

- frente principal: banco
- superficie sensivel: nao
- risco principal: misturar backfill de permissao na mesma migration ou assumir FK fisica
- repos tocados: `backend`
- fora de escopo desta task: rotas, tela, strings de permissao
- prova minima desta task: `npx prisma validate` ok e o SQL da migration so cria `venue_rule` e o indice
- criterio de escalada: parar se a migration precisar reescrever `venue` ou `user_venue_permission`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_core/project/project-decisions.md#D-03`
  - `.cursor/framework_global/framework-libs/database/rules/01_schema_modeling.md`
  - `.cursor/framework_global/framework-libs/database/rules/04_migrations_and_zero_downtime.md`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` model `Venue` e model `Service`
- palavras-chave ou simbolos de busca: `model Service`, `model Venue`, `relationMode`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: `01-spec.md`, `security`, frontend

### T-02 - Publicar as permissoes de regras

- objetivo: o par `VIEW_VENUE_RULES` e `EDIT_VENUE_RULES` entra no catalogo, no conjunto padrao do venue novo e nos vinculos que ja operam servicos
- cobre requisitos: `R-10`
- depende de: nenhuma
- pode rodar em paralelo com: `T-03`
- reusa: listas `venueViewPermissions` e `venueEditPermissions`; array `permissionsData` na criacao do venue
- prompt recomendado: `normal`
- estrategia de teste: venue novo contem as duas strings; migration de backfill nao duplica string ja presente; vinculo sem permissao de servicos permanece igual
- cenarios obrigatorios: criacao de venue; backfill de view; backfill de edit; linha que ja tem a string de regras
- definition of done: catalogo do frontend com display "Regras"; conjunto padrao atualizado; migration de dados separada da tabela; sem alterar outra permissao

#### Context Pack

- frente principal: authz
- superficie sensivel: sim
- risco principal: conceder edicao a quem nao opera o venue, ou duplicar a string na lista
- repos tocados: `backend`, `frontend`
- fora de escopo desta task: tabela `venue_rule`, rotas e tela de regras
- prova minima desta task: o SQL de backfill so acrescenta a string no par de servicos correspondente, e o catalogo exibe Regras em ver e editar
- criterio de escalada: parar se a permissao deixar de ser string unica por `UserVenuePermission`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/security/references/auth-and-access-control.md#Principios`
  - `.cursor/framework_core/product/02-business-rules.md`
- caminhos candidatos: `venue-in-prisma-repository.ts` bloco `permissionsData`; `eventhub-vista-dashboard/src/types/permissions.ts`
- palavras-chave ou simbolos de busca: `VIEW_VENUE_SERVICES`, `EDIT_VENUE_SERVICES`, `permissionsData`, `venueViewPermissions`
- testes provaveis: leitura do conjunto padrao e do SQL de backfill
- nao ler por padrao: `01-spec.md`, site, orcamento

### T-03 - Expor o CRUD autorizado de regras

- objetivo: criar, listar, alterar e remover regra somente com a permissao no venue da regra
- cobre requisitos: `R-02`, `R-03`, `R-04`, `R-05`, `R-06`, `R-07`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: factory, controller e formato de resposta de Servicos; `ensureAuthenticate`
- prompt recomendado: `normal`
- estrategia de teste: testes do use case ou da rota para sucesso, texto vazio, 401, 403 e regra de outro venue
- cenarios obrigatorios: create no fim da lista; list ordenada; update e delete pelo `venueId` gravado; texto so com espacos; sem token
- definition of done: rotas montadas em `/venue-rule`; Zod nos limites do design; nenhuma rota sem auth; teste negativo cobrindo 403 de outro venue

#### Context Pack

- frente principal: backend
- superficie sensivel: sim
- risco principal: autorizar por qualquer venue da organizacao ou confiar no `venueId` do body no update e no delete
- repos tocados: `backend`
- fora de escopo desta task: tela, menu, backfill e site
- prova minima desta task: criar e listar com permissao no venue; update de regra de outro venue nao altera a linha e responde 403 ou 404
- criterio de escalada: parar se a unica forma de autorizar for reutilizar `ensurePermission` sem filtrar o venue da regra
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_core/project/project-decisions.md#D-02`
  - `.cursor/framework_global/framework-libs/security/references/auth-and-access-control.md#Principios`
  - `.cursor/framework_global/framework-libs/patterns/index.md#Quando esta lib e obrigatoria`
- caminhos candidatos: `src/router/service.ts`, `src/use-cases/service/create-service/`, `src/middleware/ensureAuthenticate.ts`, `src/middleware/ensurePermission.ts`
- palavras-chave ou simbolos de busca: `ensureAuthenticate`, `UserVenuePermission`, `HttpConflictError`, `venueId`
- testes provaveis: Vitest do use case de regra, no mesmo estilo dos use cases que ja tiverem teste
- nao ler por padrao: `01-spec.md`, frontend, `GET /service/list` como modelo de auth

### T-04 - Cadastrar regras na tela do venue

- objetivo: o operador abre Regras no venue e cadastra, altera e remove regras daquele espaco
- cobre requisitos: `R-02`, `R-08`, `R-09`, `R-11`
- depende de: `T-02`, `T-03`
- pode rodar em paralelo com: nenhuma
- reusa: `VenueServices`, `serviceStore`, `PageHeader`, `DashboardLayout`, `ProtectedRoute`
- prompt recomendado: `normal`
- estrategia de teste: fluxo manual no painel e `npm run build` mais `npm run lint`
- cenarios obrigatorios: lista vazia; criar, editar e remover com recarga; sem `EDIT_VENUE_RULES` o botao de gravar nao aparece e a API recusa se for chamada; item de menu some sem `VIEW_VENUE_RULES`; site e orcamento sem regras
- definition of done: rota `/venue/:id/rules`, item Regras no `VenueNav`, store Zustand e client HTTP; jornada em `product/04-user-journeys.md` e uma linha do model em `product/08-data-model.md` atualizadas; sem topic novo

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: tratar a permissao da tela como autorizacao suficiente, ou gravar estado fora do Zustand ja usado nos cadastros
- repos tocados: `frontend`; docs de produto no core
- fora de escopo desta task: schema, backfill, site publico, orcamento e contrato
- prova minima desta task: no painel, criar, editar e remover uma regra e ve-la apos recarregar; venue sem regras mostra estado vazio; usuario sem ver nao entra na rota
- criterio de escalada: parar se o contrato de `/venue-rule` divergir do `03-design.md#Contratos e dados`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Reuso previsto`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Reuso previsto`
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
  - `.cursor/framework_core/project/active-libs.md#Variantes locais`
- caminhos candidatos: `src/pages/VenueServices.tsx`, `src/store/serviceStore.ts`, `src/components/venue/VenueNav.tsx`, `src/App.tsx` rotas de venue
- palavras-chave ou simbolos de busca: `VenueServices`, `EDIT_VENUE_SERVICES`, `ProtectedRoute`, `serviceStore`
- testes provaveis: fluxo manual no painel; `npm run build`; `npm run lint`
- nao ler por padrao: `01-spec.md`, `security`, schema Prisma
