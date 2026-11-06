# Overview — Limite de horas do servico

## Identificacao

- nome da feature: Limitar as horas do servico a duracao do evento
- slug: `limite-horas-servico-duracao-evento`
- status: spec pronta para review
- origem: `task-requests/limite-horas-servico-duracao-evento-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: o cliente informa mais horas do que o evento dura e o orcamento grava
- resultado esperado: a mensagem aparece no campo na hora, e a API recusa sem gravar

## Contexto base

- requests relacionados: `task-requests/limite-horas-servico-duracao-evento-request.md`, `task-requests/horas-servico-por-hora-request.md`
- documentos de produto relacionados: `product/02-business-rules.md#Proposal`, `product/03-user-profiles.md#Cliente proponente`
- topics relacionados: nenhum
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: tasks executadas; review de entrega nao rodou
- task em andamento: nenhuma
- proxima task recomendada: nenhuma

## Observacoes

- restricoes: sem campo novo no painel, sem coluna, sem mexer no recalculo publico
- riscos principais: colocar o teto dentro de `quantityFor` e quebrar o recalculo que conserva a quantidade
