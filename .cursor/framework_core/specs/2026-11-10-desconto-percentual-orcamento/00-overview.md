# Desconto em % no orcamento

## Identificacao

- nome da feature: Desconto em % no orcamento
- slug: `desconto-percentual-orcamento`
- status: `T-01` a `T-06` implementadas; aguardando review de entrega; browser pendente
- origem: `.cursor/framework_core/task-requests/desconto-percentual-total-estimado-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o dono so consegue dar desconto digitando um Total menor, sem registro do desconto, e o cliente nao ve quanto ganhou
- resultado esperado: o dono informa a % no bloco `Total estimado`; o orcamento grava a % e o valor do desconto; o total sai com desconto; o link mostra subtotal, desconto e total; se o cliente mudar o orcamento pelo link, o desconto cai

## Contexto base

- requests relacionados: `task-requests/desconto-percentual-total-estimado-request.md`
- documentos de produto relacionados: `product/02-business-rules.md#Precificacao`, `product/08-data-model.md`
- topics relacionados: `topics/pricing-and-proposal-calculation.md#Pipeline atual (proposal-amounts.ts)`; valem `project-decisions.md` D-05, D-07 e D-09
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: implementada; review de entrega pendente
- task em andamento: nenhuma
- proxima task recomendada: review de entrega (`fw:review` + `entrega`); prova no browser com login

## Observacoes

- restricoes: colunas aditivas na `main` antes do backend; a criacao por pessoa e rota publica, entao desconto exige token e permissao no espaco
- riscos principais: cliente se dar desconto pela criacao publica; total gravado diferente do que o dono viu no bloco; desconto sobrevivendo a uma mudanca feita pelo cliente
