# Design — URL publica pelo nome do espaco

## Visao geral da solucao

O endereco publico continua `/venue/{chave}/apresentacao` e `/venue/{chave}/form`. A chave nova e `encodeURIComponent(venue.name)`. A chave antiga, quando tem forma de UUID, segue sendo o id.

So duas leituras resolvem essa chave: a apresentacao e o `getById` sem `userId`. Servicos e criacao da proposta recebem `venue.id` depois que a casa carregou.

## Passada transversal

- architecture: nao. Nao ha fronteira nova; a resolucao fica nas duas leituras publicas que ja existem. Sem ADR.
- database: nao. `Venue.name` ja e unico. Sem migration e sem indice novo.
- design: nao. Nenhuma tela muda; so o texto do link.
- observability: nao. Sem servico novo. Casa ausente continua no 404 dessas leituras.
- security: sim. As rotas seguem publicas. A busca por nome sem `userId` nao adiciona campo. Com `userId`, a chave nao vira nome.
- patterns/rules/06: nao. Sem idempotencia, fila, cache ou retry.

## Componentes e modulos impactados

- `art56_server_v3`: `getPublicPresentation` e `getSelectedVenue` (caminho sem `userId`)
- `eventhub-vista-dashboard`: `public-venue-presentation.ts`, `VenueNav.tsx`, `VenueBudgets.tsx`, `VenuePresentation.tsx`, `ProposalForm.tsx`
- docs: `project/api-endpoints.md#Venue, precos e configuracao` e `#Endpoints publicos sensiveis`; `topics/public-pages-and-branding.md#Pedido de orcamento` e `#Demais paginas publicas`

## Reuso previsto

- DTO e rota de `GET /venue/presentation/:venueId`
- `GET /venue/getById` e o filtro de permissao quando ha `userId`
- `PUBLIC_ROUTES` ja casa `/venue/:id/apresentacao` e `/venue/:id/form`; o padrao do path nao muda
- `GET /service/list/:venueId` e os POST de proposta por pessoa e por dia, sempre com o id

## Contratos e dados

Resolucao da chave, pura, usada pelas duas leituras:

- se a chave casa UUID, `find` por `id` e para
- senao, `findUnique` por `name` com o texto ja decodificado
- nao achou: o 404 que a leitura ja lanca (`Espaco` na apresentacao, `Locacao` no getById)

`GET /venue/presentation/:venueId` sempre resolve. A resposta continua a de `toVenuePresentation`.

`GET /venue/getById?venueId&userId`:

- sem `userId`: resolve a chave e segue o `getSelectedVenue` atual, com os mesmos `include`
- com `userId`: `venueId` e so id; nome nao resolve

O formulario, depois do GET, usa `selectedVenue.id` em `fetchServices` e no body da proposta. A comparacao `selectedVenue.id === parametro` passa a aceitar o nome decodificado ou o id.

Links copiados:

- `https://event-hub-dashboard.vercel.app/venue/${encodeURIComponent(name)}/apresentacao`
- `https://event-hub-dashboard.vercel.app/venue/${encodeURIComponent(name)}/form`

## Falhas, casos de borda e invariantes

- nome desconhecido nao reaproveita outra casa
- UUID nao cai na busca por nome
- nome nao e gravado em `proposal.venueId` nem enviado a `/service/list`
- `getById` com `userId` nao aceita nome
- a apresentacao nao passa a devolver dono, contrato ou pagamento
- o `getById` publico nao ganha campo; `contracts` e `attachments` que ja saem hoje permanecem

## Decisoes arquiteturais importantes

- usaremos o `name` unico no path porque o pedido recusou slug e o campo ja identifica a casa
- UUID tem prioridade sobre nome para nao quebrar link enviado; alternativa descartada: so nome, que apagaria os links atuais
- a resolucao fica no repositorio das duas leituras, nao num endpoint novo; alternativa descartada: `GET /venue/by-name`, que somaria uma ida so para trocar a chave
- o formulario nao migra para o DTO da apresentacao; alternativa descartada: unificar o pacote, que mudaria o que o formulario ja le (cores, pernoite, logo) e esconderia a limpeza de `contracts`
- servicos e POST de proposta nao aprendem nome; alternativa descartada: resolver em cada escrita, que espalha a chave publica

## Riscos e mitigacoes

- nome adivinhavel expoe o mesmo pacote publico que o UUID ja expunha. Mitigacao: nao adicionar campo e nao resolver nome quando ha `userId`
- `getById` publico ja inclui `contracts` e `attachments`. Mitigacao: fora desta spec; a prova e o conjunto de chaves nao crescer
- nome com `/` quebra o path. Mitigacao: premissa aceita em `02-clarify.md`

## Rollout, observabilidade e rollback

- sem feature flag. Os links novos passam a sair da sidebar e do botao; os UUID antigos seguem nas rotas
- rollback: voltar a montar o link com `venue.id`. A resolucao por nome pode ficar, porque o UUID continua valendo
- publicar a API antes do frontend, senao o link com nome abre 404

## Estrategia de validacao

- `T-01`: vitest do repositorio/use case com nome, UUID, ausente, nome codificado ja decodificado, e `userId` ignorando nome. A apresentacao segue sem auth no router
- `T-02`: vitest dos dois links e do formulario usando `venue.id` quando o parametro e o nome. Allowlist nao precisa de rota nova
- browser, na execucao: abrir as duas URLs da AR756 sem sessao e conferir que o envio nao manda o nome como `venueId`

## Fontes determinantes

- `topics/public-pages-and-branding.md#Pedido de orcamento` e `#Demais paginas publicas`
- `project/api-endpoints.md#Venue, precos e configuracao` e `#Endpoints publicos sensiveis`
- `framework-libs/security/rules/02_auth_and_access.md`
- `framework-libs/security/skills/reviewing-security-sensitive-changes.md#1. Classificar a superficie`
- codigo: `venue.ts` rota `GET /presentation/:venueId` sem `ensureAuthenticate`; `getPublicPresentation` por id; `getSelectedVenue` por id e, com `userId`, por permissao; `ProposalForm` repassa o parametro da URL
