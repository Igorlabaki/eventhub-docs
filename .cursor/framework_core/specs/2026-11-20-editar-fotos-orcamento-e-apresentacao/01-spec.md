# Spec — Reordenar e trocar fotos no orcamento e na apresentacao

## Problema

A galeria publica do espaco nao se comporta igual nos tres enderecos. Em `/proposal/:id/view`, quem tem Site move a foto e troca. Em `/espaco/{casa}/orcamento/{nome}-{codigo}`, a alca aparece e Trocar foto nao. Em `/espaco/{casa}/apresentacao` (e no `/venue/{id}/apresentacao` antigo), ninguem edita.

## Objetivos

Quem tem `EDIT_VENUE_SITE` naquele espaco reordena as fotos visiveis e troca uma delas por outra do catalogo do espaco, nas tres paginas. Quem nao tem essa permissao ve a galeria parada, sem as fotos que ficaram de fora.

## Fora de escopo

- criar ou alterar permissao, inclusive trocar Site por `EDIT_VENUE_PHOTOS`
- upload, exclusao e a tela Fotos
- fotos de caracteristica, servico ou e-mail
- formato da URL e a ordem dos blocos de cada pagina
- schema, migration ou backfill

## User stories ou cenarios principais

- Quem tem Site abre a URL antiga, a URL nova e a apresentacao e, em cada uma, arrasta a ordem e troca uma foto.
- O cliente do orcamento e o visitante da apresentacao veem as mesmas fotos visiveis, sem alca e sem Trocar foto.
- Uma troca ou uma ordem nova feita numa pagina aparece nas outras, porque e a galeria do espaco.

## Criterios de aceite

- `R-01`: na URL antiga, quem tem Site continua vendo a alca quando ha mais de uma foto visivel e Trocar foto quando o catalogo tem mais de uma; a gravacao persiste.
- `R-02`: na URL nova, o mesmo usuario recebe o catalogo e ve Trocar foto; a troca persiste.
- `R-03`: `GET /proposal/presentation/{codigo-publico}` sem sessao, ou com sessao sem Site, devolve `canReorder: false` e `catalog: []`, sem url de foto que nao esta no link.
- `R-04`: na apresentacao do espaco, quem tem Site ve alca e Trocar foto nas fotos que a pagina ja mostra; ordem e troca persistem.
- `R-05`: a apresentacao sem sessao, ou com sessao sem Site, fica sem controles e a resposta nao traz foto oculta.
- `R-06`: `PUT` de ordem e de troca, no orcamento e na apresentacao, sem token responde 401; com token e sem Site naquele espaco responde 403 e nao grava.
- `R-07`: ordem e troca alteram as imagens do espaco (`position` e `isShowOnProposal`); a pagina seguinte, em qualquer dos tres enderecos, le o resultado.
- `R-08`: lista de fotos que nao corresponde as visiveis, ou foto que nao e do espaco, responde 400 e nao grava; falha no cliente devolve a foto que estava na tela.
- `R-09`: nenhuma permissao nova; a checagem continua `canEditVenueSite` / `EDIT_VENUE_SITE`.
- `R-10`: uma foto visivel e outras no catalogo libera so a troca; uma unica foto no catalogo nao mostra Trocar foto; uma unica visivel nao mostra a alca.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: o botao no frontend nao autoriza; o backend confere sessao e Site no espaco daquela galeria. O token que o axios ja manda na pagina publica basta para o `GET` opcional.
- erros e mensagens esperadas: 401, 403 e 400 com as mensagens que o orcamento ja usa; no cliente, "Nao foi possivel trocar a foto. A foto anterior voltou."
- observabilidade minima: o status HTTP da prova; nao logar url de foto nem o catalogo.
- concorrencia, idempotencia ou retry: duas gravacoes seguidas, a ultima vence. Ordem igual ou a mesma foto escolhida nao grava de novo.
- rollout, fallback ou degradacao: campos `canReorder` e `catalog` na apresentacao sao aditivos. Sem eles, a pagina continua estatica. Nao ha migration.

## Casos de erro e borda obrigatorios

- caso: codigo publico inexistente ou espaco inexistente
  impacto: nao devolver galeria de outra casa
  cobertura esperada: `T-01` e `T-02`, resposta 404
- caso: sessao valida sem `EDIT_VENUE_SITE` nesse espaco
  impacto: mesmo recorte do visitante; `PUT` recusado
  cobertura esperada: `T-01` e `T-02`, 200 no `GET` sem catalogo e 403 no `PUT`
- caso: `PUT` com ids a mais, a menos ou de outro espaco
  impacto: nao alterar `position` nem `isShowOnProposal`
  cobertura esperada: `T-02`, 400, reusando o plano que o orcamento ja tem
- caso: uma foto so visivel, com outras fora do link
  impacto: troca sem alca
  cobertura esperada: `T-03`
- caso: nenhuma foto marcada para o link
  impacto: pagina sem controles
  cobertura esperada: `T-03`

## Impacto esperado

A URL nova passa a trocar foto. A apresentacao passa a editar com a mesma regra do orcamento. Visitante e cliente nao percebem controle novo.

## Areas impactadas

- `backend`: leitura do catalogo e da ordem pelo codigo publico; apresentacao do espaco com usuario opcional; dois `PUT` do espaco
- `frontend`: controles na apresentacao; a URL nova passa a mostrar Trocar foto porque o catalogo deixa de vir vazio
- `project/api-endpoints.md` e `topics/public-pages-and-branding.md` quando o contrato e o comportamento existirem

## Restricoes e cuidados

- nao alargar o `select` publico da apresentacao para trazer foto oculta e filtrar depois
- rota publica continua publica; `PUT` nao entra na allowlist
- nao ler nem versionar `.env`
- `EDIT_VENUE_PHOTOS` governa a biblioteca; esta edicao nao migra para ela

## Dependencias

- `canEditVenueSite` e os planos `planVisibleImagePositions` e `planImageChoice` ja existem
- `proposalIdFromKey` ja resolve o codigo de 8 caracteres
- `getPublicPresentation` ja aceita nome ou UUID do espaco
- a URL antiga ja grava ordem e troca com Site

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-01` -> unitario
- `R-03` -> `T-01` -> unitario
- `R-04` -> `T-02`, `T-03` -> unitario
- `R-05` -> `T-02`, `T-03` -> unitario
- `R-06` -> `T-01`, `T-02` -> unitario
- `R-07` -> `T-02` -> unitario
- `R-08` -> `T-02`, `T-03` -> unitario
- `R-09` -> `T-02` -> unitario
- `R-10` -> `T-03` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao` — `T-01` e `T-02` sao backend, `T-03` e frontend; o split e opcional
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
