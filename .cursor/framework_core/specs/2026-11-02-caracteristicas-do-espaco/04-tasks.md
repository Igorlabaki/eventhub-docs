# Tasks — Caracteristicas do espaco

## Ordem macro

1. `T-01` cria a tabela
2. `T-02` e `T-03` podem seguir em paralelo
3. `T-04` espera o contrato da API e o catalogo de permissao

Nao executar o conjunto num unico passo. Depois do review, `fw:split` separa `backend` e `frontend`.

## Tasks

### T-01 - Criar a tabela venue_amenity

- objetivo: persistir caracteristica de venue com nome, posicao e vinculo ao venue
- cobre requisitos: `R-01`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: model `VenueRule` como referencia de id UUID, indice por `venueId` e `onDelete: Cascade`
- prompt recomendado: `normal`
- estrategia de teste: `npx prisma validate` e revisao do SQL gerado
- cenarios obrigatorios: tabela nova com indice em `venueId` e unicidade de `name` + `venueId`; `onDelete: Cascade` so no client Prisma; migration sem `UPDATE` de permissao
- definition of done: model no schema, relacao `amenities` em `Venue`, migration aditiva aplicada no ambiente local, SQL sem backfill; sem promocao de topic

#### Context Pack

- frente principal: banco
- superficie sensivel: nao
- risco principal: misturar backfill de permissao na mesma migration ou assumir FK fisica
- repos tocados: `backend`
- fora de escopo desta task: rotas, tela, strings de permissao, textos de amenities
- prova minima desta task: `npx prisma validate` ok e o SQL da migration so cria `venue_amenity`, o indice e a unicidade
- criterio de escalada: parar se a migration precisar reescrever `venue`, `text` ou `user_venue_permission`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_core/project/project-decisions.md#D-03`
  - `.cursor/framework_global/framework-libs/database/rules/01_schema_modeling.md`
  - `.cursor/framework_global/framework-libs/database/rules/04_migrations_and_zero_downtime.md`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` model `Venue` e model `VenueRule`
- palavras-chave ou simbolos de busca: `model VenueRule`, `model Venue`, `relationMode`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: `01-spec.md`, `security`, frontend

### T-02 - Publicar as permissoes de caracteristicas

- objetivo: o par `VIEW_VENUE_AMENITIES` e `EDIT_VENUE_AMENITIES` entra no catalogo, no conjunto padrao do venue novo e nos vinculos que ja operam servicos
- cobre requisitos: `R-11`
- depende de: nenhuma
- pode rodar em paralelo com: `T-03`
- reusa: listas `venueViewPermissions` e `venueEditPermissions`; array `permissionsData` na criacao do venue; backfill de regras como molde
- prompt recomendado: `normal`
- estrategia de teste: venue novo contem as duas strings; migration de backfill nao duplica string ja presente; vinculo sem permissao de servicos permanece igual
- cenarios obrigatorios: criacao de venue; backfill de view; backfill de edit; linha que ja tem a string de caracteristicas
- definition of done: catalogo do frontend com display "Caracteristicas"; conjunto padrao atualizado; migration de dados separada da tabela; sem alterar outra permissao

#### Context Pack

- frente principal: authz
- superficie sensivel: sim
- risco principal: conceder edicao a quem nao opera o venue, ou duplicar a string na lista
- repos tocados: `backend`, `frontend`
- fora de escopo desta task: tabela `venue_amenity`, rotas e tela de caracteristicas
- prova minima desta task: o SQL de backfill so acrescenta a string no par de servicos correspondente, e o catalogo exibe Caracteristicas em ver e editar
- criterio de escalada: parar se a permissao deixar de ser string unica por `UserVenuePermission`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/security/references/auth-and-access-control.md#Principios`
  - `.cursor/framework_core/product/02-business-rules.md#Acesso`
- caminhos candidatos: `venue-in-prisma-repository.ts` bloco `permissionsData`; `eventhub-vista-dashboard/src/types/permissions.ts`; migration de backfill de regras
- palavras-chave ou simbolos de busca: `VIEW_VENUE_SERVICES`, `EDIT_VENUE_SERVICES`, `permissionsData`, `venueViewPermissions`
- testes provaveis: leitura do conjunto padrao e do SQL de backfill
- nao ler por padrao: `01-spec.md`, site, orcamento

### T-03 - Expor o CRUD autorizado de caracteristicas

- objetivo: criar, listar, alterar e remover caracteristica somente com a permissao no venue do item
- cobre requisitos: `R-02`, `R-03`, `R-04`, `R-05`, `R-06`, `R-07`, `R-08`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: factory, controller e formato de resposta de Servicos; `ensureAuthenticate`; `VenueRuleAuthorizer`
- prompt recomendado: `normal`
- estrategia de teste: testes do use case ou da rota para sucesso, nome vazio, nome duplicado, 401, 403 e item de outro venue
- cenarios obrigatorios: create no fim da lista; list ordenada; update e delete pelo `venueId` gravado; nome so com espacos; nome duplicado; sem token
- definition of done: rotas montadas em `/venue-amenity`; Zod nos limites do design; nenhuma rota sem auth; teste negativo cobrindo 403 de outro venue e 409 de nome repetido

#### Context Pack

- frente principal: backend
- superficie sensivel: sim
- risco principal: autorizar por qualquer venue da organizacao ou confiar no `venueId` do body no update e no delete
- repos tocados: `backend`
- fora de escopo desta task: tela, menu, backfill, site e proposta
- prova minima desta task: criar e listar com permissao no venue; update de item de outro venue nao altera a linha e responde 403 ou 404; segundo nome igual no mesmo venue responde 409
- criterio de escalada: parar se a unica forma de autorizar for reutilizar `ensurePermission` sem filtrar o venue do item
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
- caminhos candidatos: `src/router/venue-rule.ts`, `src/use-cases/venue-rule/`, `src/middleware/ensureAuthenticate.ts`, `src/middleware/ensurePermission.ts`
- palavras-chave ou simbolos de busca: `ensureAuthenticate`, `VenueRuleAuthorizer`, `HttpConflictError`, `venueId`
- testes provaveis: Vitest no estilo de `src/use-cases/venue-rule/venue-rule.spec.ts`
- nao ler por padrao: `01-spec.md`, frontend, `GET /service/list` como modelo de auth

### T-04 - Cadastrar caracteristicas na tela do venue

- objetivo: o operador abre Caracteristicas no venue e cadastra, altera e remove itens daquele espaco
- cobre requisitos: `R-02`, `R-09`, `R-10`, `R-12`
- depende de: `T-02`, `T-03`
- pode rodar em paralelo com: nenhuma
- reusa: `VenueRules`, `venueRuleStore`, `PageHeader`, `DashboardLayout`, `ProtectedRoute`
- prompt recomendado: `normal`
- estrategia de teste: fluxo manual no painel e `npm run build` mais `npm run lint`
- cenarios obrigatorios: lista vazia; criar, editar e remover com recarga; nome duplicado mostra o erro; sem `EDIT_VENUE_AMENITIES` o botao de gravar nao aparece e a API recusa se for chamada; item de menu some sem `VIEW_VENUE_AMENITIES`; site e proposta continuam com os textos antigos
- definition of done: rota `/venue/:id/amenities`, item Caracteristicas no `VenueNav`, store Zustand e client HTTP; a jornada em `product/04-user-journeys.md#Administrar um venue` cita caracteristicas; `product/08-data-model.md` ganha uma linha do model; sem topic novo

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: tratar a permissao da tela como autorizacao suficiente, ou gravar estado fora do Zustand ja usado nos cadastros
- repos tocados: `frontend`; docs de produto no core
- fora de escopo desta task: schema, backfill, migrar `Text`, site publico, orcamento e contrato
- prova minima desta task: no painel, criar, editar e remover uma caracteristica e ve-la apos recarregar; venue sem itens mostra estado vazio; usuario sem ver nao entra na rota
- criterio de escalada: parar se o contrato de `/venue-amenity` divergir do `03-design.md#Contratos e dados`
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
- caminhos candidatos: `src/pages/VenueRules.tsx`, `src/store/venueRuleStore.ts`, `src/components/venue/VenueNav.tsx`, `src/App.tsx` rotas de venue
- palavras-chave ou simbolos de busca: `VenueRules`, `EDIT_VENUE_RULES`, `ProtectedRoute`, `venueRuleStore`
- testes provaveis: fluxo manual no painel; `npm run build`; `npm run lint`
- nao ler por padrao: `01-spec.md`, `security`, schema Prisma
