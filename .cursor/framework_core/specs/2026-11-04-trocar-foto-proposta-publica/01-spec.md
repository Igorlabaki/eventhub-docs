# Spec — Trocar a foto do link de orcamento

## Problema

No link publico do orcamento, as fotos sao as marcadas para o site da organizacao. O dono consegue arrastar a ordem dessas fotos, mas nao consegue colocar no lugar uma foto do espaco que esteja de fora do link.

## Objetivos

Cada foto do espaco ganha uma marca propria de aparecer no link de orcamento. O dono logado, com permissao de editar o site daquele espaco, troca uma foto visivel por qualquer foto daquele espaco. A proxima abertura mostra o conjunto novo para qualquer visitante.

## Fora de escopo

- mudar quais fotos aparecem no site da organizacao
- remover o arraste nem o carrossel
- upload de foto nova a partir do link
- conjunto de fotos diferente por orcamento
- checkbox desta marca no painel do espaco
- arraste por teclado

## User stories ou cenarios principais

- Dono com `EDIT_VENUE_SITE` naquele espaco abre o link, troca a foto da capa ou da grade por outra foto do espaco e, depois de recarregar, ve a foto nova no lugar.
- Cliente com o link ve so as fotos marcadas para o orcamento, sem seletor e sem as demais fotos do espaco.

## Criterios de aceite

- `R-01`: o link lista so fotos com `isShowOnProposal` verdadeiro, na ordem `position` ascendente e `id` ascendente
- `R-02`: a migration marca `isShowOnProposal` nas fotos que ja tem `isShowOnOrganization` verdadeiro e nao altera essa marca do site
- `R-03`: foto so com a marca do site, e sem `isShowOnProposal` verdadeiro, nao entra no link
- `R-04`: reordenar as fotos visiveis usa o conjunto do link; foto de fora desse conjunto conserva a posicao
- `R-05`: GET publico sem token valido responde 200, com `canReorder` falso, e o corpo nao traz URL de foto de fora do link
- `R-06`: dono com `EDIT_VENUE_SITE` naquele espaco recebe `canReorder` verdadeiro e o catalogo de todas as fotos daquele espaco
- `R-07`: gravar a troca sem token responde 401; autenticado sem `EDIT_VENUE_SITE` naquele espaco responde 403; nenhum dos dois grava
- `R-08`: escolher uma foto de fora do link coloca essa foto na posicao da escolhida e tira a anterior do link; as outras fotos visiveis permanecem na ordem
- `R-09`: escolher uma foto que ja esta no link troca as duas de lugar e as duas continuam no link
- `R-10`: escolher a mesma foto nao grava
- `R-11`: foto de origem fora do link, ou foto de outro espaco, responde 400 e nao grava
- `R-12`: falha ao gravar devolve a foto anterior na pagina
- `R-13`: o clique na grade continua abrindo o carrossel; o arraste continua reordenando; a troca e um controle a parte, so para quem pode gravar e quando ha pelo menos duas fotos
- `R-14`: marcar ou desmarcar foto para o site da organizacao nao grava `isShowOnProposal`

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a permissao vale no backend, no espaco da proposta (`project-decisions.md` D-05). A permissao e `EDIT_VENUE_SITE`, a mesma da gravacao da ordem. A leitura publica continua sem exigir token (`topics/auth-and-security.md#Regras de execucao`)
- erros e mensagens esperadas: 401 sem token na gravacao, 403 sem a permissao daquele espaco, 400 quando a foto nao pertence ao conjunto permitido, 404 quando a proposta nao existe
- observabilidade minima: sem metrica nova; erro no JSON ja usado; nao registrar token nem URL de imagem em log novo
- concorrencia, idempotencia ou retry: a troca roda numa transacao curta; repetir a mesma foto nao grava; nao ha retry automatico, porque repetir uma troca ja aplicada e outro comando; duas gravacoes ao mesmo tempo ficam com a ultima transacao commitada
- rollout, fallback ou degradacao: a coluna nova nasce nullable, com default falso; as fotos que o link mostra hoje entram marcadas; se a gravacao falha, a pagina volta a foto anterior

## Casos de erro e borda obrigatorios

- caso: token invalido na leitura publica
  impacto: o cliente deixaria de ver a proposta, ou receberia as fotos de fora
  cobertura esperada: `T-02` prova 200, `canReorder` falso e ausencia da URL oculta
- caso: foto de outro espaco ou de fora do link na origem
  impacto: a troca gravaria foto alheia ou desmarcaria a foto errada
  cobertura esperada: `T-02` prova 400 sem escrita
- caso: uma unica foto no espaco
  impacto: nao ha substituta
  cobertura esperada: `T-03` nao oferece o controle de troca
- caso: clique no controle de troca
  impacto: o carrossel abriria no lugar da escolha
  cobertura esperada: `T-03` abre o seletor e o clique na foto da grade, fora do controle, continua abrindo o carrossel
- caso: gravacao falha depois da troca visual
  impacto: o dono veria uma foto que nao ficou gravada
  cobertura esperada: `T-03` restaura a lista anterior

## Impacto esperado

O conjunto gravado passa a valer em todo link de orcamento daquele espaco. O site da organizacao continua lendo `isShowOnOrganization`.

## Areas impactadas

- backend: coluna em `Image`, leitura publica da apresentacao, filtro da reordenacao e uma gravacao nova autenticada
- frontend: `ProposalView`, no controle de troca ao lado da capa e da grade
- banco: coluna nullable e backfill; sem indice novo e sem FK

## Restricoes e cuidados

- D-01: contrato nos dois repositorios
- D-02: router, controller, use case e repository
- D-03: integridade no Prisma, sem FK fisica nova
- D-05: teste negativo de auth e de outro espaco
- nao reaproveitar `PUT /image/update`, que hoje nao exige autenticacao
- a migration e aditiva: coluna nullable, sem rename e sem drop

## Dependencias

- a apresentacao publica, o carrossel e a gravacao da ordem ja existem
- `UserVenuePermission` ja guarda `EDIT_VENUE_SITE` por espaco
- `isShowOnOrganization` continua sendo a marca do site

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-02`, `R-03`, `R-04`, `R-14` -> `T-01` -> unitario e migration
- `R-05`, `R-06`, `R-07`, `R-08`, `R-09`, `R-10`, `R-11` -> `T-02` -> unitario
- `R-08`, `R-12`, `R-13` -> `T-03` -> browser

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
