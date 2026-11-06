# Clarify — Regras do espaco

## Perguntas criticas

- Varias regras ou um texto unico? Premissa: varias regras do mesmo venue. Risco se errada: a tabela `venue_rule` sobra e o cadastro vira um campo.
- Quais campos? Premissa: titulo opcional ate 120 caracteres, texto obrigatorio ate 5000, posicao inteira maior ou igual a zero. Risco se errada: ajuste de validacao, sem mudar a entidade.
- Onde mais aparecem? Premissa: so no painel do venue. Risco se errada: site, orcamento ou contrato ficam para outra spec.
- Permissao propria ou a de informacoes do venue? Premissa: `VIEW_VENUE_RULES` e `EDIT_VENUE_RULES`. Risco se errada: o par novo precisa ser retirado do catalogo e das rotas.

## Respostas confirmadas

- a feature nasce do request `task-requests/regras-do-espaco-request.md`
- texto de site (`Text`) e FAQ (`Question`) nao sao o cadastro de regras
- permissoes de venue sao strings separadas por virgula em `UserVenuePermission.permissions`
- o conjunto padrao ao criar venue esta em `venue-in-prisma-repository.ts`
- o catalogo editavel da tela de permissao esta em `eventhub-vista-dashboard/src/types/permissions.ts`

## Requisitos implicitos confirmados

- autorizacao no backend, no venue da regra, por `project-decisions.md` D-05 e `product/02-business-rules.md`
- migration aditiva, por `agent-entrypoint.md`
- Zustand para o cadastro, por `active-libs.md` (nao abrir terceira forma de estado)
- router, factory, use case e repositorio Prisma, por D-02

## Premissas assumidas

- titulo nao e unico
- regra nova recebe a proxima posicao; a lista ordena por posicao e, no empate, por data de criacao
- reordenar e alterar o numero da posicao no formulario; nao ha arrastar
- o backfill so acrescenta `VIEW_VENUE_RULES` em quem ja tem `VIEW_VENUE_SERVICES`, e `EDIT_VENUE_RULES` em quem ja tem `EDIT_VENUE_SERVICES`
- envio duplicado pode criar duas regras, como em Servicos
- id da regra e UUID, como `Service`

## Perguntas de erro e borda ainda abertas

- limite de 5000 caracteres incomoda uma regra longa? Premissa: 5000 basta. Risco se errada: subir o limite do Zod e da coluna, que ja e `LongText`.
- o backfill por servicos deixa de fora um operador que so tem permissao de informacoes? Premissa: sim, e um administrador marca Regras na tela de permissao. Risco se errada: o backfill passa a copiar outro par.

## Itens bloqueantes

- nenhum

## O que pode seguir mesmo com lacunas

- schema, API, permissao e tela seguem as premissas acima
- site, orcamento e contrato nao entram nesta spec mesmo se o limite de texto mudar
