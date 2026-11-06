# Spec — Reordenar fotos da proposta publica

## Problema

No link publico do orcamento as fotos seguem o numero Posicao. O dono nao consegue arrastar essa ordem na propria pagina.

## Objetivos

O dono logado, com permissao de editar o site daquele espaco, arrasta capa e fotos de "A casa". Ao soltar, a ordem fica gravada e a proxima abertura mostra essa ordem para qualquer visitante.

## Fora de escopo

- carrossel, cores, textos, mapa, rodape e o campo numerico de Posicao no painel
- upload, coluna nova e fotos da organizacao que nao sao do espaco
- arraste por teclado; o campo do painel continua sendo o fallback
- tornar autenticada a leitura publica que ja existe

## User stories ou cenarios principais

- Dono com `EDIT_VENUE_SITE` naquele espaco abre o link, arrasta uma foto e, depois de recarregar, ve a ordem nova.
- Cliente com o link ve as fotos fixas, na ordem gravada, e o clique na galeria continua abrindo o carrossel.

## Criterios de aceite

- `R-01`: dono com `EDIT_VENUE_SITE` naquele espaco recebe `canReorder: true` e cada foto visivel traz `id`
- `R-02`: visitante sem sessao valida nao arrasta e a gravacao sem token responde 401
- `R-03`: usuario autenticado sem `EDIT_VENUE_SITE` naquele espaco recebe `canReorder: false` e a gravacao responde 403
- `R-04`: ao soltar numa posicao diferente, a ordem fica gravada e a proxima leitura segue essa ordem
- `R-05`: a primeira foto da sequencia e a capa; as seguintes ficam em "A casa"
- `R-06`: soltar na mesma ordem nao altera posicoes
- `R-07`: falha ao gravar devolve a ordem visual para a ultima ordem salva
- `R-08`: lista de ids diferente do conjunto visivel responde 400 e nao grava
- `R-09`: foto com `isShowOnOrganization` falso permanece com a posicao anterior
- `R-10`: token ausente ou invalido no GET publico responde 200 com `canReorder: false`
- `R-11`: o carrossel de "A casa" continua so com as fotos depois da capa e abre a foto clicada
- `R-12`: a grade segue em duas colunas e a ultima foto da galeria ocupa a linha inteira quando a quantidade e impar

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a permissao vale no backend, no espaco da proposta, nao so na tela (`project-decisions.md` D-05). A permissao e `EDIT_VENUE_SITE`, a mesma de `VenueWebsiteImages`. `ensurePermission` atual nao serve: ele aceita a permissao em qualquer espaco da organizacao e a mensagem fala de calendario
- erros e mensagens esperadas: 401 sem token na gravacao, 403 sem a permissao daquele espaco, 400 quando o conjunto de ids nao e o das fotos visiveis, 404 quando a proposta nao existe
- observabilidade minima: sem metrica nova; erro no formato JSON ja usado; nao registrar token nem URL de imagem em log novo
- concorrencia, idempotencia ou retry: a gravacao roda numa transacao curta; repetir a mesma ordem produz as mesmas posicoes; dois donos ao mesmo tempo ficam com a ultima transacao commitada
- rollout, fallback ou degradacao: sem migration; se a gravacao falha, a pagina volta a ordem anterior e o painel numerico continua valendo

## Casos de erro e borda obrigatorios

- caso: token invalido na leitura publica
  impacto: o cliente deixaria de ver a proposta
  cobertura esperada: `T-01` prova 200 e `canReorder: false`
- caso: ids a mais, a menos ou repetidos
  impacto: ordem parcial ou foto de outro espaco
  cobertura esperada: `T-02` prova 400 sem escrita
- caso: uma unica foto visivel
  impacto: nao ha destino para arrastar
  cobertura esperada: `T-03` nao oferece arraste
- caso: galeria vazia
  impacto: a secao "A casa" continua oculta
  cobertura esperada: `T-03` nao renderiza a grade
- caso: clique durante o modo de arraste
  impacto: o carrossel deixaria de abrir
  cobertura esperada: `T-03` abre o carrossel num clique sem movimento

## Impacto esperado

A ordem gravada passa a valer em toda leitura que ordena essas fotos por `position`, inclusive a proxima proposta publica do mesmo espaco.

## Areas impactadas

- backend: leitura publica da apresentacao e uma gravacao nova autenticada
- frontend: `ProposalView`, capa, grade e carrossel ja existente
- banco: atualizacao de `image.position` das fotos visiveis; sem schema novo

## Restricoes e cuidados

- D-01: contrato nos dois repositorios
- D-02: router, controller, use case e repository
- D-03: integridade no Prisma, sem FK fisica nova
- D-05: teste negativo de auth e de outro espaco
- nao reaproveitar `PUT /image/update`, que hoje nao exige autenticacao

## Dependencias

- a apresentacao publica e o carrossel de "A casa" ja existem
- `UserVenuePermission` ja guarda `EDIT_VENUE_SITE` por espaco

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-03`, `R-10` -> `T-01` -> unitario
- `R-02`, `R-04`, `R-06`, `R-08`, `R-09` -> `T-02` -> unitario
- `R-02`, `R-05`, `R-07`, `R-11`, `R-12` -> `T-03` -> browser

## Perguntas em aberto

Registradas com premissa em `02-clarify.md`. Nenhuma bloqueia `T-01`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
