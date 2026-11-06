# Spec — Precos minimos por periodo

## Problema

Cada espaco tem um unico `minimumPrice`. Nao da para ter um piso padrao e outro so em dezembro. O piso atual entra na criacao do orcamento; a edicao por dia nao aplica piso nenhum.

## Objetivos

Na aba Minimos de Metas e Precos, o piso padrao fica visivel e editavel, e as faixas por periodo podem ser criadas, alteradas e removidas. O orcamento automatico usa a faixa da data de inicio do evento e, sem faixa, o piso padrao.

## Fora de escopo

- mudar a formula de adicional, desconto ou meta
- fazer a edicao passar a aplicar adicional e desconto; isso e `task-requests/edicao-orcamento-adicionais-descontos-request.md`
- unificar a conta do piso entre criacao e edicao alem de trocar o numero usado
- piso por dia da semana ou faixa valida so num ano
- publicar piso no site, contrato ou pagamento
- converter dinheiro de Float para Decimal
- corrigir a autorizacao das rotas antigas de meta e adicional

## User stories ou cenarios principais

- operador com permissao de precos abre Minimos, ajusta o piso padrao, cadastra dezembro e ve os dois de novo ao recarregar
- orcamento automatico em 20/12 usa o piso de dezembro; em 12/03 usa o padrao
- operador sem permissao de edicao ve a aba e o backend recusa gravar
- total digitado a mao permanece o numero informado

## Criterios de aceite

- `R-01`: cada faixa pertence a um unico venue e persiste titulo, `startDay`, `endDay` e `price` em Float
- `R-02`: usuario com `EDIT_VENUE_PRICES` naquele venue cria, altera e remove faixa; nova listagem devolve o resultado
- `R-03`: criar, alterar ou remover sem `EDIT_VENUE_PRICES` naquele venue responde 403 e nao grava
- `R-04`: listar sem `VIEW_VENUE_PRICES` naquele venue responde 403
- `R-05`: titulo vazio, data fora de `dd/MM` ou preco menor ou igual a zero responde 400 e nao grava
- `R-06`: alterar ou remover faixa de outro venue responde 403 ou 404 e nao muda o registro
- `R-07`: no calculo automatico, a data de inicio escolhe a faixa; se varias cobrirem o dia, vale a de maior `price`; se nenhuma cobrir, vale `Venue.minimumPrice`
- `R-08`: piso resolvido ausente ou zero nao eleva o total; faixa com fim anterior ao inicio cobre a virada do ano
- `R-09`: o ramo que hoje grava total informado a mao continua gravando esse numero, sem elevar ao piso
- `R-10`: editar a data reavalia a faixa; a edicao por dia, no ramo que ja recalcula sozinho, passa a aplicar o piso
- `R-11`: a aba Minimos em `/venue/:id/goals` mostra o piso padrao e a lista; quem tem `EDIT_VENUE_PRICES` edita o padrao pelo update de venue ja existente e grava faixas
- `R-12`: o painel da mesma tela mostra o piso padrao e ate tres faixas; Ver todos abre a aba
- `R-13`: adicional, desconto, meta, site, contrato e pagamento seguem sem ler faixa de minimo

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: rotas novas exigem usuario autenticado; a checagem e no venue da faixa, no backend; a tela nao substitui isso
- erros e mensagens esperadas: 400 para dado invalido, 401 sem token, 403 sem permissao naquele venue, 404 quando a faixa nao existe
- observabilidade minima: falha inesperada segue o `{ title, message }` ja usado; sem dashboard nem metrica nova
- concorrencia, idempotencia ou retry: duas faixas no mesmo dia nao bloqueiam a gravacao; a leitura usa o maior preco; nao ha chave de idempotencia
- rollout, fallback ou degradacao: tabela nova e aditiva; espaco sem faixa continua no `minimumPrice` atual; reverter o app deixa a tabela sem uso

## Casos de erro e borda obrigatorios

- caso: data de inicio fora de qualquer faixa
  impacto: vale o piso padrao, inclusive zero
  cobertura esperada: teste da funcao de piso
- caso: dezembro e reveillon no mesmo dia
  impacto: vale o maior preco
  cobertura esperada: teste da funcao de piso
- caso: faixa de 20/12 a 05/01
  impacto: 31/12 e 02/01 entram; 15/01 nao entra
  cobertura esperada: teste da funcao de piso
- caso: evento comeca em 30/11 e termina em 02/12
  impacto: vale novembro, porque a data de inicio decide
  cobertura esperada: teste da funcao de piso
- caso: usuario autenticado sem a permissao naquele venue
  impacto: 403 na listagem e na gravacao
  cobertura esperada: teste negativo do use case
- caso: faixa de outro venue
  impacto: nao vazar nem alterar
  cobertura esperada: teste negativo do use case
- caso: total digitado a mao
  impacto: o numero informado e gravado
  cobertura esperada: o ramo manual dos use cases de orcamento nao chama o piso
- caso: lista vazia
  impacto: a aba abre e oferece a primeira faixa a quem edita
  cobertura esperada: tela em Metas e Precos

## Impacto esperado

O espaco passa a ter piso por periodo alem do piso padrao. Orcamento criado ou recalculado automaticamente respeita a data de inicio.

## Areas impactadas

- `backend`: schema, migration, rotas, use case, repositorio e calculo do orcamento
- `frontend`: aba e painel de Metas e Precos, store e servico HTTP
- produto: agregado do venue e a jornada de configurar precos, na task de tela

## Restricoes e cuidados

- `relationMode = "prisma"`: nao assumir FK fisica; a relacao declara `onDelete: Cascade` para o client Prisma
- dinheiro continua Float, por D-07
- nao reutilizar `SeasonalFee` nem `ensurePermission`
- nao deixar a listagem sem permissao, ao contrario de `GET /seasonalFee/list`
- nao criar terceira forma de estado no frontend; seguir Zustand, como adicional
- migration de producao aditiva
- nao ler nem versionar `.env`
- ao editar os use cases de orcamento, nao implementar adicional e desconto na edicao

## Dependencias

- `Venue.minimumPrice`, Metas e Precos e `EDIT_VENUE_PRICES` / `VIEW_VENUE_PRICES` ja existem
- `getUserVenuePermission({ userId, organizationId, venueId })` ja filtra o venue
- nenhuma integracao externa
- execucao repo-local depois do review, com `fw:split`

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> integracao (`prisma validate` e SQL so de tabela nova)
- `R-02`, `R-03`, `R-04`, `R-05`, `R-06` -> `T-02` -> unitario do use case
- `R-07`, `R-08`, `R-09`, `R-10` -> `T-03` -> unitario da funcao de piso
- `R-11`, `R-12`, `R-13` -> `T-04` -> e2e manual em Metas e Precos

## Perguntas em aberto

Nenhuma bloqueante. Premissas e o que ainda pode mudar estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
