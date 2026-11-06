# Design — Trocar a foto do link de orcamento

## Visao geral da solucao

`Image` ganha `isShowOnProposal`. O link publico e a reordenacao passam a usar essa marca. Uma gravacao autenticada troca a foto de um lugar visivel por qualquer foto do mesmo espaco. Na pagina, um controle a parte abre o catalogo so quando `canReorder` e verdadeiro.

Passada transversal:

- architecture: sim. A leitura continua publica e a troca nasce autenticada no fluxo da proposta. Sem ADR; segue D-01 e D-02.
- database: sim. Coluna nullable em `image`, com backfill. Sem indice novo e sem FK.
- design: sim. Controle, seletor e estados de gravando, erro, selecionado e desabilitado.
- observability: nao. Sem sinal novo; o erro HTTP ja existente basta. Nao registrar token nem URL.
- security: sim. Autorizacao no espaco da proposta, teste negativo e corpo publico sem foto de fora do link.
- patterns/rules/06: sim, concorrencia e idempotencia. Transacao curta e ultima gravacao vence. A mesma foto nao grava de novo. Nao ha retry automatico: repetir uma troca ja feita e outro comando. Nao ha fila nem cache.

## Componentes e modulos impactados

- `art56_server_v3`: `Image` no Prisma, `GET /proposal/presentation/:proposalId`, o filtro de `PUT /proposal/presentation/:proposalId/image-order` e `PUT /proposal/presentation/:proposalId/image-choice`
- `eventhub-vista-dashboard`: `ProposalView`, o tipo `ProposalPresentation` e `proposal.service`
- fora: `PUT /image/update`, o formulario de imagens do site, o carrossel alem de continuar abrindo a foto clicada, e o gesto de arraste alem de passar a reordenar o conjunto do link

## Reuso previsto

- `ensureAuthenticate` so na gravacao, como em `image-order`
- permissao `EDIT_VENUE_SITE` em `UserVenuePermission` do `venueId` da proposta
- `canReorder` que a leitura ja calcula
- estado local ja usado em `ProposalView`; sem Zustand nem React Query novo
- `Dialog` ja usado na pagina

## Contratos e dados

### Coluna

`isShowOnProposal Boolean? @default(false)` em `Image`, ao lado de `isShowOnOrganization`.

Nullable de proposito: adicionar coluna nullable e migration direta (`database/skills/writing-zero-downtime-migrations.md`). Not null novo exigiria expand/contract.

A migration faz o backfill `UPDATE image SET isShowOnProposal = true WHERE isShowOnOrganization = true`. Nao altera `isShowOnOrganization`. Nao cria indice: a leitura ja filtra as fotos pelo `venueId` indexado.

So `true` entra no link. `null` e `false` ficam de fora.

Foto nova permanece fora do link ate entrar por uma troca. O fluxo que grava `isShowOnOrganization` nao passa a gravar `isShowOnProposal`.

### Leitura

`GET /proposal/presentation/:proposalId` continua publico.

`images` passa a filtrar `isShowOnProposal` verdadeiro, na ordem `position` ascendente e `id` ascendente. O filtro de `image-order` usa o mesmo conjunto; posicoes de fotos de fora do link continuam intocadas por essa gravacao.

`canReorder` permanece: verdadeiro so com Bearer valido e `EDIT_VENUE_SITE` no espaco daquela proposta. Token ausente ou invalido responde 200 e `canReorder: false`. Proposta inexistente continua 404.

O corpo ganha `catalog`. Sem permissao, `catalog` e `[]` e a consulta das fotos ocultas nao entra nessa resposta. Com permissao, `catalog` lista todas as fotos daquele espaco: `id`, `imageUrl`, `description`, `position`, `isShowOnProposal`. A montagem do catalogo so ocorre depois da checagem da permissao.

### Troca

`PUT /proposal/presentation/:proposalId/image-choice`

- exige `ensureAuthenticate`
- corpo: `{ "slotId": "id-visivel", "replacementId": "id-qualquer-do-espaco" }`
- 401 sem token ou com token invalido
- 403 autenticado sem `EDIT_VENUE_SITE` naquele espaco
- 404 proposta ou espaco ausente
- 400 se algum id nao for daquele espaco, ou se `slotId` nao estiver no link
- 200 sem escrita quando `slotId` e `replacementId` sao o mesmo
- 200 com escrita nos outros casos validos

Dentro de uma transacao curta, sem chamada externa, lendo as duas linhas de novo:

1. as duas fotos pertencem ao espaco da proposta
2. `slotId` esta no link
3. se os ids forem iguais, encerrar sem update
4. se `replacementId` ja esta no link, trocar os valores de `position` e manter as duas marcas verdadeiras
5. se `replacementId` esta fora do link, trocar os valores de `position` e inverter as marcas: a nova entra no link, a do lugar sai
6. atualizar as linhas por `id` ascendente

As demais fotos nao mudam. A foto que entra conserva o lugar visual porque herda a `position` do lugar.

A resposta 200 devolve `images`, o conjunto visivel ja na ordem nova, e `catalog` atualizado. O cliente nao repete o PUT depois de 200. Enquanto a chamada nao volta, outro clique fica desabilitado.

### Pagina

`canReorder` falso, ou catalogo com menos de duas fotos: nenhum controle de troca.

`canReorder` verdadeiro e duas ou mais fotos: cada foto visivel, capa inclusive, mostra um botao "Trocar foto", separado da alca de arraste. O botao tem `focus-visible`, fica `disabled` enquanto grava e nao dispara o arraste nem o carrossel.

O dialogo lista o catalogo. A foto do lugar aparece selecionada. Escolher a mesma fecha sem gravar. Escolher outra aplica a troca na hora, chama o PUT e, se a chamada falha, restaura a lista anterior. Foto que ja esta no link pode ser escolhida: as duas trocam de lugar.

O clique na foto da grade, fora do botao, continua abrindo o carrossel. A capa continua fora do carrossel.

## Falhas, casos de borda e invariantes

- o link e a reordenacao enxergam o mesmo conjunto
- a marca do site nao e escrita pela troca, nem a marca do link e escrita pelo formulario do site
- a mesma foto escolhida de novo e idempotente
- duas trocas concorrentes: a ultima transacao commitada define o par; nao ha merge
- o corpo publico sem permissao nao contem URL de foto fora do link

## Decisoes arquiteturais importantes

- Coluna nova, em vez de reusar `isShowOnOrganization`. Alternativa descartada: a marca do site, porque o pedido separa o link do site.
- Marca na foto do espaco, nao uma lista por orcamento. Alternativa descartada: conjunto por proposta, porque a ordem do arraste ja e do espaco e o pedido fala da foto do espaco.
- Gravacao nova no router da proposta. Alternativa descartada: `PUT /image/update`, porque essa rota nao autentica.
- Catalogo so depois da permissao, na leitura que a pagina ja faz. Alternativa descartada: um GET publico com todas as fotos, porque o visitante veria o que ficou de fora.
- Sem retry automatico. Alternativa descartada: repetir o mesmo corpo, porque a segunda vez desfaz ou responde 400 com a origem ja fora do link.

## Riscos e mitigacoes

- Visitante gravar ou ver foto oculta: PUT autenticado, catalogo so apos a permissao, teste do corpo sem a URL oculta.
- GET publico passar a exigir login: token ausente ou invalido permanece 200.
- Arraste e link divergirem: os dois filtram `isShowOnProposal` na mesma entrega da coluna.
- Troca abrir o carrossel: o controle e um botao a parte; o clique na grade segue abrindo.

## Rollout, observabilidade e rollback

Uma migration aditiva. O codigo novo so le a coluna depois que ela existe. Rollback de codigo volta a filtrar `isShowOnOrganization`; a coluna pode ficar, e o backfill deixa os links iguais ao conjunto do site ate alguem ter trocado fotos. Sem dashboard novo.

## Estrategia de validacao

- `T-01`: vitest do filtro da apresentacao e da reordenacao; migration com a coluna nullable e o `UPDATE`; `npx prisma validate`
- `T-02`: vitest do use case, com repositorio falso, inclusive 401, 403, 400, troca, substituicao e corpo publico sem URL oculta
- `T-03`: troca no browser com dono logado, recarga, link sem sessao de dono, carrossel ainda abrindo
- prova de frontend que o browser nao substitui: funcao pura que aplica a troca na lista e devolve a lista anterior quando a gravacao falha

## Fontes determinantes

- `topics/auth-and-security.md#Regras de execucao`
- `project/project-decisions.md#D-03` e `#D-05`
- `framework-libs/security/references/auth-and-access-control.md#Principios`
- `framework-libs/database/skills/writing-zero-downtime-migrations.md`
- `framework-libs/design/rules/05_component_states_and_variants.md`
- `framework-libs/patterns/rules/06_senior_engineering_concepts.md`
- `specs/2026-11-04-reordenar-fotos-proposta-publica/03-design.md#Gravacao da ordem`
- `art56_server_v3/prisma/schema.prisma` modelo `Image`
- `art56_server_v3/src/router/proposal.ts` rotas `presentation` e `image-order`
