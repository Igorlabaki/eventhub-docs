# Design — Reordenar fotos da proposta publica

## Visao geral da solucao

A leitura publica passa a dizer se o usuario atual pode reordenar e a identificar cada foto visivel. Uma gravacao autenticada, separada, reescreve `position` so dessas fotos. A pagina arrasta capa e galeria como uma lista quando `canReorder` e verdadeiro e grava ao soltar.

Passada transversal:

- architecture: sim. A leitura continua publica e a escrita nasce autenticada no fluxo da proposta. Sem ADR; segue D-01 e D-02.
- database: sim, nas linhas de `image.position`. Nao ha coluna, indice nem migration.
- design: sim. O arraste so aparece para quem pode gravar e tem estado de salvando e de erro.
- observability: nao. Sem sinal novo; o erro HTTP ja existente basta.
- security: sim. Autorizacao no espaco da proposta e teste negativo. A leitura publica nao passa a exigir token.
- patterns/rules/06: sim, concorrencia. Transacao curta e ultima gravacao vence. Nao ha fila, cache nem retry automatico.

## Componentes e modulos impactados

- `art56_server_v3`: `GET /proposal/presentation/:proposalId` e `PUT /proposal/presentation/:proposalId/image-order`
- `eventhub-vista-dashboard`: `ProposalView` e o tipo `ProposalPresentation`
- fora: `PUT /image/update`, formulario de Posicao e carrossel alem de continuar abrindo a foto clicada

## Reuso previsto

- `ensureAuthenticate` so na gravacao
- permissao `EDIT_VENUE_SITE` em `UserVenuePermission` do `venueId` da proposta
- ordenacao `position asc` que a apresentacao ja faz
- estado local ja usado em `ProposalView`; sem Zustand nem React Query novo
- arraste nativo do browser; sem dependencia nova

## Contratos e dados

### Contrato de leitura

`GET /proposal/presentation/:proposalId` continua publico.

Cada item de `images` ganha `id`. O corpo ganha `canReorder: boolean`.

`canReorder` e verdadeiro somente com Bearer valido e `EDIT_VENUE_SITE` no espaco daquela proposta. Token ausente ou invalido nao muda o status: 200 e `canReorder: false`. Proposta inexistente continua 404.

O `id` identifica a foto que a pagina ja mostra. Nao incluir foto oculta.

### Gravacao da ordem

`PUT /proposal/presentation/:proposalId/image-order`

- exige `ensureAuthenticate`
- corpo: `{ "imageIds": ["id-1", "id-2"] }`
- 401 sem token ou com token invalido
- 403 autenticado sem `EDIT_VENUE_SITE` naquele espaco
- 404 proposta ou espaco ausente
- 400 se `imageIds` tiver repeticao ou nao for exatamente o conjunto das fotos do espaco com `isShowOnOrganization` verdadeiro
- 200 com a lista visivel ja na ordem nova quando a ordem enviada e diferente
- 200 sem escrita quando a ordem enviada ja e a ordem atual

Algoritmo da escrita, dentro de uma transacao curta e sem chamada externa:

1. carregar as fotos visiveis do espaco, desempate `position asc`, depois `id asc`
2. rejeitar conjunto diferente
3. se a ordem enviada for a atual, encerrar sem update
4. montar uma sequencia estritamente crescente com o mesmo tamanho, evitando as posicoes das fotos do espaco que nao estao no conjunto, partindo da menor posicao visivel
5. gravar essa sequencia na ordem de `imageIds`, atualizando as linhas por `id` ascendente para as duas gravacoes concorrentes pegarem as linhas na mesma ordem

Fotos ocultas nao sao atualizadas. A ordem relativa das visiveis fica sendo a ordem solta, porque a leitura ordena por `position`.

### Arraste na pagina

`canReorder` falso: capa, grade e carrossel ficam como estao.

`canReorder` verdadeiro e ha duas ou mais fotos: capa e grade sao uma lista arrastavel. A primeira posicao renderiza a capa; o restante renderiza "A casa". Ao soltar em outra posicao, a pagina aplica a ordem na hora, chama o PUT e, se a chamada falha, restaura a lista anterior. Enquanto a gravacao nao volta, outro arraste fica desabilitado.

Clique sem movimento numa foto de "A casa" continua abrindo o carrossel dessa foto. A capa nao entra no carrossel. Uma unica foto nao mostra arraste.

## Falhas, casos de borda e invariantes

- o conjunto gravado e so o das fotos visiveis daquele espaco
- posicao de foto oculta e invariante
- a mesma lista enviada de novo e idempotente
- duas gravacoes concorrentes: a ultima transacao commitada define a ordem; nao ha merge
- grade de duas colunas e a ultima foto larga, quando a galeria tem quantidade impar, continuam derivadas do tamanho da galeria, nao de um flag

## Decisoes arquiteturais importantes

- Gravacao nova no router da proposta, nao no router de imagem. Alternativa descartada: `PUT /image/update`, porque essa rota nao autentica e atualiza uma foto por vez.
- `canReorder` na leitura que a pagina ja faz. Alternativa descartada: ler a permissao do painel no browser, porque essa permissao pode ser de outro espaco.
- Reusar os numeros de posicao, sem coluna de ordem da proposta. Alternativa descartada: ordem por orcamento, porque o pedido grava a ordem do espaco.
- Arraste nativo. Alternativa descartada: pacote novo, porque o projeto nao tem biblioteca de arraste e o gesto e uma lista curta.

## Riscos e mitigacoes

- Visitante gravar a ordem: PUT autenticado e checagem da permissao no espaco, com 401 e 403.
- GET publico passar a exigir login: token ausente ou invalido permanece 200.
- Posicoes ocultas serem sobrescritas: a sequencia nova evita essas posicoes e o teste cobre uma foto oculta.
- Arraste abrir ou quebrar o carrossel: clique sem movimento segue abrindo; o carrossel nao inclui a capa.

## Rollout, observabilidade e rollback

Sem migration e sem flag. Rollback e reverter o codigo; as posicoes ja gravadas permanecem e o painel numerico ainda as edita. Sem dashboard novo.

## Estrategia de validacao

- `T-01` e `T-02`: vitest no use case, com repositorio falso, inclusive 401, 403 e 400
- `T-03`: arraste no browser com dono logado, recarga, e abertura do link sem sessao de dono
- prova de frontend que o browser nao substitui: funcao pura que move um item da lista e devolve a ordem anterior quando a gravacao falha

## Fontes determinantes

- `topics/auth-and-security.md#Regras de execucao`
- `project/project-decisions.md#D-05`
- `framework-libs/security/references/auth-and-access-control.md#Principios`
- `framework-libs/database/rules/05_transactions_and_locking.md#Regras`
- `framework-libs/patterns/rules/06_senior_engineering_concepts.md`
- `eventhub-vista-dashboard/src/pages/website/VenueWebsiteImages.tsx` para o nome `EDIT_VENUE_SITE`
- `eventhub-vista-dashboard/src/pages/ProposalView.tsx` para capa, galeria e carrossel
