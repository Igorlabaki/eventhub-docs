# Design — criar link na link tree

## Visao geral da solucao

O select da aba vira o botao "Cadastrar link". O modal escolhe o tipo e, se for rede colada, a URL. Na aba, confirmar so muda o estado local. Na pagina publica, o mesmo modal chama um write novo, autorizado com `EDIT_VENUE_SITE`, e a resposta substitui a lista. O `PUT` do editor nao muda de permissao.

## Modal da aba Redes

`VenueLinkEditor` tira o `<select>` "Escolher rede" da faixa. No lugar fica o botao "Cadastrar link". Sem kind restante (`remainingVenueLinkKinds` vazio), o botao fica desabilitado.

O modal reusa `Dialog`. Campos: um select com os kinds restantes e o label de `VENUE_LINK_LABEL`; o input URL so quando `isPastedVenueLink`. A mensagem ao vivo continua sendo `checkVenueLinkUrl`. Cancelar fecha sem mudar as linhas. "Cadastrar link" no modal fica desabilitado sem kind, e na rede colada enquanto o status nao for verde. Confirmar chama `createVenueLink` como o select faz hoje e fecha. Rede do sistema entra mesmo sem destino, com `visible` falso, porque a tabela da aba mostra a linha e o hint. O lapis de editar URL nao muda: o modal de `mode: "edit"` segue so com URL.

"Salvar Alteracoes" de `VenueSettings` continua sendo o unico `saveVenueLinks` da aba. Os textos "Nenhuma rede criada" e "Nenhuma rede encontrada" ficam.

## Write da pagina publica

Rota nova, no mesmo estilo de `order` e `hide`:

- `PUT /venue/links/:venueId/create`
- `ensureAuthenticate`
- body `{ kind, url? }`, `kind` no enum `VENUE_LINK_KINDS`, `url` string opcional
- controller, factory e zod ao lado dos de `hide` em `controller-venue-links.ts`, `factory-venue-links.ts` e `save-venue-links-schema.ts`
- permissao: `PrismaVenueSiteEditPermission` e `loadEditable`, nao `canEditVenueInfo`

`CreateVenueLinkUseCase` carrega as linhas criadas e aplica a mesma regra de `createVenueLink` do back (`src/functions/venue-link.ts`):

- sem usuario: 401, a de `loadEditable`
- sem `canEditVenueSite`: 403 "Sem permissao para editar o site deste espaco"
- espaco ausente: 404
- kind ja presente, inclusive oculto: 400 "Essa rede ja existe."; nao chama `replace`
- rede colada sem status verde: 400 com `check.message`; nao grava
- rede do sistema cujo `venueLinkHref` e nulo: 400 com `venueLinkSourceHint(kind)` ou, se o hint vier nulo, "Esse link ainda nao tem destino."; nao grava
- sucesso: `links.replace` com `venueLinkColumns`, como `persistLayout`

A resposta de sucesso e o mesmo envelope de `order` e `hide` (`publicData` + `canReorder: true`) mais `usedKinds` com os kinds criados depois da gravacao.

`GET /venue/links/:venueId` ganha `usedKinds` somente quando `canReorder` e true. Sem a permissao, o campo nao vai no JSON. `usedKinds` inclui oculto, porque `rowsOf` devolve a linha criada. `order` e `hide` nao precisam passar a devolver `usedKinds`: o front so troca `links` nesses dois.

Descartado: reusar `SaveVenueLinksUseCase` na publica. Ele exige `EDIT_VENUE_INFO`, e a pagina publica desta feature usa `EDIT_VENUE_SITE`.

## Pagina publica

`VenueLinksView` recebe `usedKinds` e `onCreate`.

- `canReorder` e zero links: no lugar da lista, um container na largura `max-w-md`, com o card ja usado na pagina (`cardClass` e `cardStyle`), o texto "Ainda nao ha link cadastrado na sua link tree" e o botao "Cadastrar link"
- `canReorder` e um ou mais links: o mesmo botao acima da `<ul>`; alca e lixeira ficam como `venueLinkChrome` define hoje
- `canReorder` falso: nenhum botao e nenhum container; zero links segue sem `<ul>`

O modal e o mesmo gesto da aba: select dos kinds de `VENUE_LINK_KINDS` que nao estao em `usedKinds`, URL so na rede colada, confirmar desabilitado ate a URL verde. Confirmar chama `venueService.createVenueLink`. Sucesso troca `links` e `usedKinds` pela resposta e fecha o modal. Falha nao altera a lista, deixa o modal aberto e mostra a `message` do body. Sem insercao otimista, porque o servidor pode recusar o destino.

`PublicVenueLinks` ganha `usedKinds?: string[]`. O cliente faz `PUT /venue/links/:id/create`.

## Componentes e modulos impactados

- `art56_server_v3/src/use-cases/venue/venue-links/` (use case, controller, factory)
- `art56_server_v3/src/router/venue.ts`
- `art56_server_v3/src/zod/venue/save-venue-links-schema.ts`
- `art56_server_v3/src/functions/venue-link.ts` so se faltar um helper; a regra de criar ja esta em `createVenueLink`
- `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx`
- `eventhub-vista-dashboard/src/pages/VenueLinks.tsx`
- `eventhub-vista-dashboard/src/services/venue.service.ts`
- `project/api-endpoints.md#Venue, precos e configuracao` em `T-01`
- `topics/public-pages-and-branding.md#Demais paginas publicas` em `T-03`

## Reuso previsto

- `Dialog`, `createVenueLink`, `checkVenueLinkUrl`, `remainingVenueLinkKinds`, `isPastedVenueLink`, `loadEditable`, `persistLayout`, `publicData`, `venueLinkChrome`
- nao ha componente novo de pagina; o container vazio usa o card que a lista ja usa

## Contratos e dados

Sem schema. A linha nova usa o `replace` que order e hide ja usam. Colunas de URL do espaco continuam saindo de `venueLinkColumns`.

`GET` publico, com permissao, acrescenta `usedKinds: string[]`. `PUT /venue/links/:venueId/create` body `{ kind: VenueLinkKind, url?: string }` e resposta `{ data: PublicVenueLinks & { usedKinds: string[] } }` no mesmo envelope `{ success, message, data, count, type }`.

## Falhas, casos de borda e invariantes

- kind repetido nao gera segunda linha
- URL nao verde nao gera linha
- rede do sistema sem href nao gera linha na publica; na aba, gera oculta, como hoje
- `usedKinds` do visitante nao vaza a lista de ocultos
- falha de rede na publica nao mexe na lista desenhada
- Apresentacao, orcamento e regras seguem com href proprio e podem ser criados na publica

## Decisoes arquiteturais importantes

- um write curto na publica, nao o save da lista inteira
- `usedKinds` so no `GET` de quem ja pode reordenar, para o modal nao oferecer tipo oculto
- a aba nao ganha chamada nova

## Riscos e mitigacoes

- visitante enxergar o botao: o markup depende de `canReorder`, e o use case testa 401 e 403
- `PUBLIC_ROUTES` nao lista `links`; um 401 nesta pagina pode mandar para `/login`, como ja ocorre em order e hide. Fora desta feature
- as duas copias de `venue-link` divergirem: o write usa a copia do back; o modal usa a do front so para habilitar o botao

## Rollout, observabilidade e rollback

Sem migration e sem sinal novo. Publicar a API antes do frontend. Rollback: remover a rota e o botao; linhas ja criadas permanecem.

## Estrategia de validacao

- `T-01`: vitest do use case, com rota autenticada e `GET` sem `usedKinds` para o visitante
- `T-02`: vitest do markup do editor, sem browser obrigatorio
- `T-03`: vitest do markup da pagina, inclusive o teste que hoje exige lista ausente para quem nao reordena
- browser das duas telas fica para a review da entrega, no mesmo limite das specs vizinhas

## Passada transversal

- architecture: nao. A rota entra no router de venue que ja serve order e hide; sem ADR
- database: nao. Nenhuma coluna ou tabela; `replace` ja persiste a linha
- design: sim. Botao, modal e container vazio; estados desabilitado, URL vermelha e lista vazia ficam no markup
- observability: nao. Nao ha servico novo; 401, 403 e 400 provam a recusa
- security: sim. O `PUT` nasce autenticado com `EDIT_VENUE_SITE`; o `GET` continua publico e nao revela `usedKinds` ao visitante
- patterns/rules/06: nao. Um request cria uma linha; tipo repetido responde 400; sem fila, cache ou retry

## Docs determinantes

- `project/agent-entrypoint.md#Regras de ouro`: rota publica intencional e permissao no front nao substitui o backend
- `project/api-endpoints.md#Venue, precos e configuracao`: `GET` publico, `PUT` order e hide com `EDIT_VENUE_SITE`, `PUT` do editor separado
- `topics/public-pages-and-branding.md#Demais paginas publicas`: a pagina ja arrasta e remove so com `EDIT_VENUE_SITE`
- `topics/permissions-catalog.md`: `EDIT_VENUE_SITE` e edicao de site, distinta de `EDIT_VENUE_INFO`
- `framework-libs/security/index.md#Implementacao com auth, segredos ou permissoes`
- `framework-libs/node/index.md#Criacao de endpoint Core API`
- `framework-libs/design/index.md#Formularios e fluxos de entrada` e `#Estados vazios, loading e erro`
