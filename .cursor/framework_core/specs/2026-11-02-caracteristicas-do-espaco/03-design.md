# Design — Caracteristicas do espaco

## Visao geral da solucao

Nova entidade `VenueAmenity`, API autenticada no prefixo `/venue-amenity` e tela `/venue/:id/amenities` no menu do venue. A gravacao so ocorre se o usuario tem a permissao naquele venue. Os `Text` com `area: "amenities"` continuam sendo a fonte do site e da proposta.

## Passada transversal

- topologia: nao; continua no monolito Express e na SPA, sem servico novo nem ADR
- dados persistidos: sim; tabela `venue_amenity` e backfill de strings de permissao
- interface: sim; pagina de lista e formulario, com vazio, loading e erro
- producao: sim; sem metrica nova; erro HTTP atual e log so de ids na falha de permissao
- fluxo sensivel: sim; autorizacao por venue, com teste negativo; o nome da caracteristica nao e PII
- conceito senior (`patterns/rules/06`): nao; sem fila, cache, retry ou idempotencia propria; a unicidade do nome cobre o duplicado

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: model e relacao `amenities` em `Venue`
- `art56_server_v3/src/router/venue-amenity.ts`, use cases, Zod e repositorio Prisma
- `art56_server_v3/src/server.ts`: `app.use('/venue-amenity', venueAmenityRoutes)`
- `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts`: strings padrao
- `eventhub-vista-dashboard/src/types/permissions.ts`, `App.tsx`, `VenueNav.tsx`
- pagina, componentes, `venueAmenityStore` e client HTTP novos, no molde de Regras

## Reuso previsto

- formato de resposta de Servicos: `success`, `message`, `data`, `count`, `type`
- `ensureAuthenticate` antes da checagem de permissao
- pagina `VenueRules`: cabecalho, lista, formulario, Zustand e botao condicionado a editar
- `ProtectedRoute` com `VIEW_VENUE_AMENITIES`
- authorizer no molde de `VenueRuleAuthorizer`, com as permissoes novas

Nao reutilizar `Text`, `Question` nem `ensurePermission`.

## Contratos e dados

Model:

- `id` UUID
- `name` String obrigatorio `@db.VarChar(120)`, 1 a 120 depois do trim
- `position` Int, default 0
- `venueId` obrigatorio, indice, `onDelete: Cascade`
- `createdAt`, `updatedAt`
- `@@unique([name, venueId])`
- `@@map("venue_amenity")`

API, todas com `ensureAuthenticate` e checagem no venue da caracteristica:

- `POST /venue-amenity/create` body `{ venueId, name }` exige `EDIT_VENUE_AMENITIES`; posicao = maior posicao do venue + 1, ou 0 se nao houver item
- `GET /venue-amenity/list/:venueId` exige `VIEW_VENUE_AMENITIES`; ordem `position` asc, `createdAt` asc
- `PUT /venue-amenity/update` body `{ amenityId, name, position? }` carrega o item e exige `EDIT_VENUE_AMENITIES` em `amenity.venueId`
- `DELETE /venue-amenity/delete/:amenityId` carrega o item e exige `EDIT_VENUE_AMENITIES` em `amenity.venueId`

Resposta de sucesso no formato de Servicos, com `type: "VenueAmenity"`.

Permissoes, strings novas no catalogo do frontend (`venueViewPermissions` "Caracteristicas", `venueEditPermissions` "Caracteristicas") e no array padrao de criacao do venue. Backfill em migration separada: acrescentar a string so se ainda nao existir e o vinculo ja tiver `VIEW_VENUE_SERVICES` ou `EDIT_VENUE_SERVICES`, no par correspondente. A migration inicial de regras encontrou `UserPermission` no historico e o schema mapeia `userVenuePermission`; o backfill atualiza a tabela que existir.

## Falhas, casos de borda e invariantes

- a caracteristica so e lida ou gravada por quem tem a permissao no `venueId` dela
- nome trimado vazio, ou maior que 120, nao grava
- nome ja existente naquele venue responde 409
- item inexistente no update ou delete responde 404
- venue inexistente no create responde 404
- lista vazia e sucesso com `data: []`
- posicao negativa responde 400
- apagar o venue pelo client Prisma apaga as caracteristicas pela cascata declarada
- nenhum use case desta feature le nem grava `Text`

## Decisoes arquiteturais importantes

- entidade propria, porque `Text` com `area: "amenities"` e conteudo de site e de proposta
- um campo `name`, porque cada item da lista e o proprio rotulo; titulo mais texto longo fica com Regras
- nome unico por venue, porque a lista e um catalogo de itens distintos, como `Service`
- autorizacao por `venueId` do item; `ensurePermission` fica de fora porque libera qualquer venue da organizacao
- listagem autenticada; `GET /service/list` publico nao e modelo
- Zustand, como `venueRuleStore`
- UUID, como `Service` e `VenueRule`
- alternativa descartada: reaproveitar `Text` — misturaria o cadastro do painel com o texto publico
- alternativa descartada: permitir nome duplicado — a lista perderia o sentido de catalogo

## Riscos e mitigacoes

- gravar no venue errado: use case le o item e autoriza o `venueId` persistido, nao um id solto do body no update e no delete
- operador atual sem a permissao nova: backfill espelha quem ja tem servicos; os demais ganham o item na tela de permissao
- copiar o buraco de Servicos: esta spec nao abre rota de caracteristica sem auth
- site e proposta mudarem de fonte sem pedido: nenhum leitor novo aponta para `venue_amenity`

## Rollout, observabilidade e rollback

- migration 1: criar `venue_amenity`, sem backfill
- migration 2: atualizar as strings de permissao
- sem alerta novo
- rollback do app: reverter o deploy; a tabela pode ficar sem leitor; strings extras sao ignoradas pelo catalogo antigo; os `Text` de amenities nao sao apagados

## Estrategia de validacao

- `npx prisma validate` e leitura do SQL: a primeira migration so cria tabela, indice e unicidade
- teste negativo da API para 401, 400, 403, 409 e venue cruzado
- no painel: criar, editar, remover, recarregar; usuario sem edicao nao grava; venue vazio mostra o estado vazio
- `npm run build` e `npm run lint` no frontend na task de tela

## Fontes que fecharam a solucao

- `project/project-decisions.md` D-02, D-03 e D-05
- `product/02-business-rules.md`: nome unico de `Service` no venue e permissao desejada no recurso
- `product/08-data-model.md`: `relationMode = "prisma"` e o registro de `VenueRule` como lista por venue
- `framework-libs/database/rules/04_migrations_and_zero_downtime.md`: schema e dado em passos separados
- `framework-libs/security/references/auth-and-access-control.md`: permissao no backend, por acao e por recurso
- `art56_server_v3/src/middleware/ensurePermission.ts`: motivo para nao reutilizar
- `specs/2026-11-02-regras-do-espaco/03-design.md` e a pagina `VenueRules`: molde de cadastro e de autorizacao
