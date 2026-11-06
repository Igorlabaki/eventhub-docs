# Recalcular o orcamento no link publico

## Identificacao

- nome da feature: Recalcular o orcamento no link publico
- slug: `recalcular-orcamento-proposta-publica`
- status: spec pronta para execucao
- origem: `.cursor/framework_core/task-requests/recalcular-orcamento-proposta-publica-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o cliente ve o total no link e nao consegue mudar dia, convidados nem horas
- resultado esperado: um modal com esses tres campos grava o recálculo da tabela da casa e atualiza o card

## Contexto base

- requests relacionados: `task-requests/recalcular-orcamento-proposta-publica-request.md`
- documentos de produto relacionados: `product/02-business-rules.md#Proposal`, `product/03-user-profiles.md`
- topics relacionados: nenhum de proposta; vale `project-decisions.md` D-02, D-05 e D-06
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: bootstrap concluido
- task em andamento: nenhuma
- proxima task recomendada: `T-01`

## Observacoes

- restricoes: pagina publica; sem tabela de preco na resposta; sem agenda, servico, desconto nem schema novo
- riscos principais: o link reescrever orcamento aprovado ou pago, ou a tela inventar o total
