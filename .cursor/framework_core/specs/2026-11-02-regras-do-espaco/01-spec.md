# Spec — Regras do espaco

## Problema

O operador do venue nao tem onde cadastrar as regras daquele espaco. Texto de site e FAQ nao sao esse cadastro.

## Objetivos

No painel de um venue, um usuario autorizado cadastra, altera e remove as regras daquele espaco, e a lista permanece ao reabrir a tela.

## Fora de escopo

- publicar regras no site
- mostrar ou gravar regras em orcamento, contrato ou mensagem
- regras no nivel da organizacao
- corrigir a autorizacao dos outros cadastros do venue

## User stories ou cenarios principais

- operador com permissao de edicao abre Regras no venue, cadastra uma regra e a ve de novo depois de recarregar
- operador sem permissao de edicao consulta a lista, quando pode ver, e o backend recusa gravacao
- venue novo abre a tela vazia e aceita a primeira regra

## Criterios de aceite

- `R-01`: cada regra pertence a um unico venue e persiste titulo opcional, texto obrigatorio e posicao
- `R-02`: usuario com `EDIT_VENUE_RULES` naquele venue cria, altera e remove regra; nova listagem devolve o resultado
- `R-03`: criar, alterar ou remover sem `EDIT_VENUE_RULES` naquele venue responde 403 e nao grava
- `R-04`: listar sem `VIEW_VENUE_RULES` naquele venue responde 403
- `R-05`: texto vazio ou so com espacos responde 400 e nao grava
- `R-06`: alterar ou remover regra de outro venue responde 403 ou 404 e nao muda o registro
- `R-07`: a lista volta ordenada por posicao; regra nova entra no fim
- `R-08`: venue sem regras mostra estado vazio; quem edita consegue cadastrar a primeira
- `R-09`: o item Regras e a rota `/venue/:id/rules` so entram para quem tem `VIEW_VENUE_RULES`
- `R-10`: venue recem-criado concede `VIEW_VENUE_RULES` e `EDIT_VENUE_RULES` no conjunto padrao; vinculo que ja tem a permissao de servicos correspondente recebe a de regras
- `R-11`: site, orcamento, contrato e organizacao seguem sem ler nem gravar regras

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: toda rota exige usuario autenticado; a checagem e no venue da regra, no backend; a tela nao substitui isso
- erros e mensagens esperadas: 400 para texto invalido, 401 sem token, 403 sem permissao naquele venue, 404 quando a regra nao existe
- observabilidade minima: falha de permissao registra o id do usuario e do venue, sem o texto da regra; sem dashboard novo
- concorrencia, idempotencia ou retry: duas criacoes simultaneas podem repetir posicao; a ordenacao desempata por data de criacao; nao ha chave de idempotencia
- rollout, fallback ou degradacao: tabela nova e aditiva; o backfill de permissao e migration separada; reverter o app deixa a tabela sem uso

## Casos de erro e borda obrigatorios

- caso: texto vazio
  impacto: nao pode nascer regra em branco
  cobertura esperada: validacao da API
- caso: regra de outro venue
  impacto: nao vazar nem alterar regra alheia
  cobertura esperada: teste negativo da API
- caso: usuario autenticado sem a permissao naquele venue
  impacto: 403 na gravacao e na listagem
  cobertura esperada: teste negativo da API
- caso: lista vazia
  impacto: a tela abre e oferece o primeiro cadastro a quem edita
  cobertura esperada: tela no painel
- caso: token ausente
  impacto: 401
  cobertura esperada: teste negativo da API

## Impacto esperado

Novo cadastro operacional do venue, no mesmo nivel de Servicos. Quem ja opera servicos naquele espaco passa a poder operar regras.

## Areas impactadas

- `backend`: schema, migration, rotas, use case, repositorio, permissao padrao do venue
- `frontend`: permissao, menu, rota, pagina, store e servico HTTP
- produto: jornada de administrar o venue e o modelo de dados, na task de tela

## Restricoes e cuidados

- `relationMode = "prisma"`: nao assumir FK fisica; a relacao declara `onDelete: Cascade` para o client Prisma
- nao reutilizar `ensurePermission`: ele aceita a permissao em qualquer venue da organizacao e a mensagem e de calendario
- nao deixar a listagem publica, ao contrario de `GET /service/list`
- nao criar terceira forma de estado no frontend; seguir Zustand, como Servicos
- migration de producao aditiva, via `prisma migrate`; schema e backfill de permissao em migrations separadas
- nao ler nem versionar `.env`

## Dependencias

- venue, `UserVenuePermission` e o painel ja existem
- nenhuma integracao externa
- execucao repo-local depois do review, com `fw:split`

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-07` -> `T-01` -> integracao (`prisma validate` e SQL so de tabela nova)
- `R-10` -> `T-02` -> integracao (conjunto padrao e backfill)
- `R-02`, `R-03`, `R-04`, `R-05`, `R-06` -> `T-03` -> unitario ou teste negativo da API
- `R-02`, `R-08`, `R-09`, `R-11` -> `T-04` -> e2e manual no painel

## Perguntas em aberto

Nenhuma bloqueante. Premissas e o que ainda pode mudar estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `nao feita; a execucao foi pedida em lote`
- proxima acao: `revisar entrega`, se o usuario pedir
- entrada publica recomendada: `fw:review` + `entrega`
