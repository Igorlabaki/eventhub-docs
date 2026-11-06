# Design — Regras do espaco

## Visao geral da solucao

Nova entidade `VenueRule`, API autenticada no prefixo `/venue-rule` e tela `/venue/:id/rules` no menu do venue. A gravacao so ocorre se o usuario tem a permissao naquele venue.

## Passada transversal

- topologia: nao; continua no monolito Express e na SPA, sem servico novo nem ADR
- dados persistidos: sim; tabela `venue_rule` e backfill de strings de permissao
- interface: sim; pagina de lista e formulario, com vazio, loading e erro
- producao: sim; sem metrica nova; erro HTTP atual e log so de ids na falha de permissao
- fluxo sensivel: sim; autorizacao por venue, com teste negativo; o texto da regra nao e PII
- conceito senior (`patterns/rules/06`): nao; sem fila, cache, retry ou idempotencia propria

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: model e relacao em `Venue`
- `art56_server_v3/src/router/venue-rule.ts`, use cases, Zod e repositorio Prisma
- `art56_server_v3/src/server.ts`: `app.use('/venue-rule', venueRuleRoutes)`
- `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts`: strings padrao
- `eventhub-vista-dashboard/src/types/permissions.ts`, `App.tsx`, `VenueNav.tsx`
- pagina, componentes, `venueRuleStore` e client HTTP novos, no molde de Servicos

## Reuso previsto

- formato de resposta de Servicos: `success`, `message`, `data`, `count`, `type`
- `ensureAuthenticate` antes da checagem de permissao
- pagina `VenueServices`: cabecalho, lista, formulario, Zustand e botao condicionado a editar
- `ProtectedRoute` com `VIEW_VENUE_RULES`

Nao reutilizar `Text`, `Question` nem `ensurePermission`.

## Contratos e dados

Model:

- `id` UUID
- `title` String opcional, no maximo 120
- `text` String obrigatorio `@db.LongText`, 1 a 5000 depois do trim
- `position` Int, default 0
- `venueId` obrigatorio, indice, `onDelete: Cascade`
- `createdAt`, `updatedAt`
- `@@map("venue_rule")`

API, todas com `ensureAuthenticate` e checagem no venue da regra:

- `POST /venue-rule/create` body `{ venueId, title?, text }` exige `EDIT_VENUE_RULES`; posicao = maior posicao do venue + 1, ou 0 se nao houver regra
- `GET /venue-rule/list/:venueId` exige `VIEW_VENUE_RULES`; ordem `position` asc, `createdAt` asc
- `PUT /venue-rule/update` body `{ ruleId, title?, text, position? }` carrega a regra e exige `EDIT_VENUE_RULES` em `rule.venueId`
- `DELETE /venue-rule/delete/:ruleId` carrega a regra e exige `EDIT_VENUE_RULES` em `rule.venueId`

Resposta de sucesso no formato de Servicos, com `type: "VenueRule"`.

Permissoes, strings novas no catalogo do frontend (`venueViewPermissions` "Regras", `venueEditPermissions` "Regras") e no array padrao de criacao do venue. Backfill em migration separada: acrescentar a string so se ainda nao existir e o vinculo ja tiver `VIEW_VENUE_SERVICES` ou `EDIT_VENUE_SERVICES`, no par correspondente. A migration inicial criou `UserPermission` e o schema mapeia `userVenuePermission`; o backfill atualiza a tabela que existir.

## Falhas, casos de borda e invariantes

- a regra so e lida ou gravada por quem tem a permissao no `venueId` dela
- texto trimado vazio nao grava
- regra inexistente no update ou delete responde 404
- venue inexistente no create responde 404
- lista vazia e sucesso com `data: []`
- posicao negativa responde 400
- apagar o venue pelo client Prisma apaga as regras pela cascata declarada

## Decisoes arquiteturais importantes

- entidade propria, porque `Text` e `Question` sao conteudo de site
- lista de regras, porque o pedido e cadastrar as regras do espaco
- autorizacao por `venueId` da regra; `ensurePermission` fica de fora porque libera qualquer venue da organizacao
- listagem autenticada; `GET /service/list` publico nao e modelo
- Zustand, como `serviceStore`
- UUID, como `Service`

## Riscos e mitigacoes

- gravar no venue errado: use case le a regra e autoriza o `venueId` persistido, nao um id solto do body no update e no delete
- operador atual sem a permissao nova: backfill espelha quem ja tem servicos; os demais ganham o item na tela de permissao
- copiar o buraco de Servicos: esta spec nao abre rota de regra sem auth

## Rollout, observabilidade e rollback

- migration 1: criar `venue_rule`, sem backfill
- migration 2: atualizar as strings de permissao
- sem alerta novo
- rollback do app: reverter o deploy; a tabela pode ficar sem leitor; strings extras sao ignoradas pelo catalogo antigo

## Estrategia de validacao

- `npx prisma validate` e leitura do SQL: a primeira migration so cria tabela e indice
- teste negativo da API para 401, 400, 403 e venue cruzado
- no painel: criar, editar, remover, recarregar; usuario sem edicao nao grava; venue vazio mostra o estado vazio
- `npm run build` e `npm run lint` no frontend na task de tela

## Fontes que fecharam a solucao

- `project/project-decisions.md` D-02, D-03 e D-05
- `product/02-business-rules.md` e `product/08-data-model.md`
- `framework-libs/database/rules/04_migrations_and_zero_downtime.md`: schema e dado em passos separados
- `framework-libs/security/references/auth-and-access-control.md`: permissao no backend, por acao e por recurso
- `art56_server_v3/src/middleware/ensurePermission.ts`: motivo para nao reutilizar
- `art56_server_v3/src/router/service.ts` e `eventhub-vista-dashboard/src/pages/VenueServices.tsx`: molde de cadastro, nao de autorizacao
