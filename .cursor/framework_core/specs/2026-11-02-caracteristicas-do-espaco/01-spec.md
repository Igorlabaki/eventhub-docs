# Spec — Caracteristicas do espaco

## Problema

O operador do venue nao tem onde cadastrar a lista do que aquele espaco tem, como piscina aquecida, salao interno e telao. Os textos com `area: "amenities"` sao conteudo de site e de proposta, nao um cadastro do painel.

## Objetivos

No painel de um venue, um usuario autorizado cadastra, altera e remove as caracteristicas daquele espaco, e a lista permanece ao reabrir a tela.

## Fora de escopo

- substituir, migrar ou deixar de ler os `Text` com `area: "amenities"`
- publicar a lista nova no site, no orcamento, no contrato ou em mensagem
- caracteristicas no nivel da organizacao
- corrigir a autorizacao dos outros cadastros do venue

## User stories ou cenarios principais

- operador com permissao de edicao abre Caracteristicas no venue, cadastra "Piscina aquecida" e a ve de novo depois de recarregar
- operador sem permissao de edicao consulta a lista, quando pode ver, e o backend recusa gravacao
- venue novo abre a tela vazia e aceita a primeira caracteristica
- o site e a proposta continuam lendo os textos antigos de amenities

## Criterios de aceite

- `R-01`: cada caracteristica pertence a um unico venue e persiste nome obrigatorio e posicao
- `R-02`: usuario com `EDIT_VENUE_AMENITIES` naquele venue cria, altera e remove caracteristica; nova listagem devolve o resultado
- `R-03`: criar, alterar ou remover sem `EDIT_VENUE_AMENITIES` naquele venue responde 403 e nao grava
- `R-04`: listar sem `VIEW_VENUE_AMENITIES` naquele venue responde 403
- `R-05`: nome vazio, so com espacos, ou com mais de 120 caracteres responde 400 e nao grava
- `R-06`: alterar ou remover caracteristica de outro venue responde 403 ou 404 e nao muda o registro
- `R-07`: a lista volta ordenada por posicao; caracteristica nova entra no fim
- `R-08`: nome repetido no mesmo venue, depois do trim, responde 409 e nao grava a segunda linha
- `R-09`: venue sem caracteristicas mostra estado vazio; quem edita consegue cadastrar a primeira
- `R-10`: o item Caracteristicas e a rota `/venue/:id/amenities` so entram para quem tem `VIEW_VENUE_AMENITIES`
- `R-11`: venue recem-criado concede `VIEW_VENUE_AMENITIES` e `EDIT_VENUE_AMENITIES` no conjunto padrao; vinculo que ja tem a permissao de servicos correspondente recebe a de caracteristicas
- `R-12`: site, proposta, orcamento, contrato e organizacao seguem lendo os `Text` de amenities e nao leem a tabela nova

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: toda rota exige usuario autenticado; a checagem e no venue da caracteristica, no backend; a tela nao substitui isso
- erros e mensagens esperadas: 400 para nome invalido, 401 sem token, 403 sem permissao naquele venue, 404 quando a caracteristica ou o venue nao existe, 409 quando o nome ja existe naquele venue
- observabilidade minima: falha de permissao registra o id do usuario e do venue, sem o nome da caracteristica; sem dashboard novo
- concorrencia, idempotencia ou retry: duas criacoes simultaneas podem repetir posicao; a ordenacao desempata por data de criacao; o nome unico por venue impede a linha duplicada; nao ha chave de idempotencia
- rollout, fallback ou degradacao: tabela nova e aditiva; o backfill de permissao e migration separada; reverter o app deixa a tabela sem uso e os textos de amenities intactos

## Casos de erro e borda obrigatorios

- caso: nome vazio ou longo demais
  impacto: nao pode nascer caracteristica invalida
  cobertura esperada: validacao da API
- caso: nome duplicado no mesmo venue
  impacto: a lista nao ganha dois itens iguais
  cobertura esperada: validacao da API
- caso: caracteristica de outro venue
  impacto: nao vazar nem alterar item alheio
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
- caso: textos antigos de amenities
  impacto: site e proposta nao mudam de fonte
  cobertura esperada: nenhuma leitura nova desses fluxos na entrega

## Impacto esperado

Novo cadastro operacional do venue, no mesmo nivel de Servicos e de Regras. Quem ja opera servicos naquele espaco passa a poder operar caracteristicas. O conteudo publico atual de amenities permanece.

## Areas impactadas

- `backend`: schema, migration, rotas, use case, repositorio, permissao padrao do venue
- `frontend`: permissao, menu, rota, pagina, store e servico HTTP
- produto: jornada de administrar o venue e o modelo de dados, na task de tela

## Restricoes e cuidados

- `relationMode = "prisma"`: nao assumir FK fisica; a relacao declara `onDelete: Cascade` para o client Prisma
- nao reutilizar `ensurePermission`: ele aceita a permissao em qualquer venue da organizacao e a mensagem e de calendario
- nao deixar a listagem publica, ao contrario de `GET /service/list`
- nao criar terceira forma de estado no frontend; seguir Zustand, como Servicos e Regras
- nao gravar esta lista em `Text`
- migration de producao aditiva, via `prisma migrate`; schema e backfill de permissao em migrations separadas
- nao ler nem versionar `.env`

## Dependencias

- venue, `UserVenuePermission` e o painel ja existem
- o cadastro de regras e referencia de formato, sem dependencia de dados
- nenhuma integracao externa
- execucao repo-local depois do review, com `fw:split`

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> integracao (`prisma validate` e SQL so de tabela nova)
- `R-11` -> `T-02` -> integracao (conjunto padrao e backfill)
- `R-02`, `R-03`, `R-04`, `R-05`, `R-06`, `R-07`, `R-08` -> `T-03` -> unitario ou teste negativo da API
- `R-02`, `R-09`, `R-10`, `R-12` -> `T-04` -> e2e manual no painel

## Perguntas em aberto

Nenhuma bloqueante. Premissas e o que ainda pode mudar estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `nao feita; a execucao foi pedida em lote`
- proxima acao: `revisar entrega`, se o usuario pedir
- entrada publica recomendada: `fw:review`
