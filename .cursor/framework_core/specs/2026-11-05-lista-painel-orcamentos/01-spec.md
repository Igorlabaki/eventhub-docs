# Spec — Lista paginada de orcamentos no painel

## Problema

A pagina de orcamentos pede o mes inteiro e filtra nome e dia no navegador. Nao ha pagina, cards nem status. A lista de eventos repete o mesmo padrao com os aprovados. O `GET /proposal/list`, quando `approved` nao vem, devolve so os nao aprovados, entao Fechado nao aparece.

## Objetivos

Quem abre orcamentos ve a referencia: ano, meses, busca, copiar o link, dia, tres cards e tabela com status, em paginas de 10. Filtros, ordenacao, totais e conversao saem do backend. Quem abre eventos recebe so a pagina de 10 aprovados, com a busca no backend.

## Fora de escopo

- visual novo na pagina de eventos, alem da busca e da paginacao
- status Enviado, coluna nova ou migration de estado
- menu de tres pontos
- relatorio anual `analysisByMonth`
- fechar a lacuna de ownership do espaco (`project-decisions.md#D-05`)
- trocar `Float` de dinheiro (`project-decisions.md#D-07`)
- paginas publicas do orcamento

## User stories ou cenarios principais

- Quem gerencia orcamentos filtra mes, dia e nome, ve no maximo 10 linhas e le total, valor e conversao do filtro inteiro.
- Quem gerencia eventos percorre os aprovados de 10 em 10, sem baixar o mes.

## Criterios de aceite

- `R-01`: com `page`, a lista devolve no maximo 10 itens e `pagination.total` do filtro inteiro
- `R-02`: mes, ano e dia filtram `startDate` pelo calendario wall-clock, sem puxar o dia para o mes seguinte
- `R-03`: `sortBy` `startDate`, `totalAmount` ou `status`, com desempate estavel por `id`
- `R-04`: `approved` ausente devolve Aberto e Fechado; `true` so Fechado; `false` so Aberto
- `R-05`: `summary.total`, `summary.monthAmount` e `summary.conversionRate` usam o filtro inteiro, nao a pagina
- `R-06`: `summary.daily` traz cada dia da janela, com zero nos dias vazios e `conversionRate` ja arredondado
- `R-07`: a pagina de orcamentos mostra a referencia e apenas exibe `summary`, sem contar nem somar
- `R-08`: a pagina de eventos pede `approved=true` e pagina de 10, e a busca vai na API
- `R-09`: `GET /proposal/list` sem JWT responde 401
- `R-10`: filtro sem linhas devolve lista vazia, totais zero e conversao 0
- `R-11`: dia inexistente no mes devolve lista vazia e nao inclui o mes seguinte
- `R-12`: o indice novo e so `@@index([venueId, startDate])`, sem coluna nova

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a rota continua com `ensureAuthenticate`; o filtro continua por `venueId`; esta feature nao passa a checar se o usuario pertence ao espaco
- erros e mensagens esperadas: query invalida responde 400; espaco ausente continua 404
- observabilidade minima: sem metrica nova; a prova e o teste da listagem e a resposta consumida na tela
- concorrencia, idempotencia ou retry: nao se aplica; a lista e leitura
- rollout, fallback ou degradacao: sem `page`, a rota segue devolvendo a lista inteira, ja com `R-04`

## Casos de erro e borda obrigatorios

- caso: pagina alem do fim, ou filtro vazio
  impacto: itens vazios, `pagination.total` correto, cards em zero
  cobertura esperada: `T-01` e `T-02`
- caso: dia 31 num mes de 30, ou 29 de fevereiro fora do bissexto
  impacto: nenhuma linha do mes seguinte
  cobertura esperada: `T-01`
- caso: varias linhas no mesmo horario
  impacto: a pagina nao repete nem perde linha
  cobertura esperada: `T-01`
- caso: `summary=true` sem `page`
  impacto: 400
  cobertura esperada: `T-02`
- caso: request sem JWT
  impacto: 401, sem lista
  cobertura esperada: `T-01`

## Impacto esperado

Orcamentos deixa de travar com o mes inteiro e mostra o funil do mes. Eventos baixa uma pagina. O contrato de `GET /proposal/list` passa a paginar quando `page` vem.

## Areas impactadas

- `backend`: `GET /proposal/list`, schema Zod, use case, repositorio e indice de `Proposal`
- `frontend`: pagina de orcamentos, pagina de eventos, servico e store da proposta
- `docs/referencias/API_CONTRACTS.md`: secao `GET /proposal/list`

## Restricoes e cuidados

- data de evento permanece wall-clock (`project-decisions.md#D-06`)
- valor permanece `Float` (`project-decisions.md#D-07`)
- contrato compartilhado entre os dois repositorios (`project-decisions.md#D-01`)
- a tela nao recalcula KPI, pagina, filtro nem ordenacao

## Dependencias

- referencia visual do chat
- listagem atual usada por `fetchProposals` e `fetchEvents`
- nenhum estado novo de proposta (`project-decisions.md`, decisoes pendentes: estados oficiais de Proposal)

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-01` -> unitario
- `R-03` -> `T-01` -> unitario
- `R-04` -> `T-01` -> unitario
- `R-09` -> `T-01` -> unitario
- `R-11` -> `T-01` -> unitario
- `R-12` -> `T-01` -> `npx prisma validate`
- `R-05` -> `T-02` -> unitario
- `R-06` -> `T-02` -> unitario
- `R-10` -> `T-02` -> unitario
- `R-07` -> `T-03` -> tela de orcamentos
- `R-08` -> `T-04` -> tela de eventos

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md#Premissas assumidas`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `dividir por repo`
- entrada publica recomendada: `fw:split`
