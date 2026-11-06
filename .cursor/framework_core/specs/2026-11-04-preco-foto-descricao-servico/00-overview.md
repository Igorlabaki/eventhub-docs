# Preco, foto e descricao do servico

## Identificacao

- nome da feature: Preco por hora ou por pessoa, foto e descricao no servico do espaco
- slug: `preco-foto-descricao-servico`
- status: codigo das cinco tasks escrito; prova de tela e schema no main pendentes
- origem: `.cursor/framework_core/task-requests/preco-foto-descricao-servico-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o servico do espaco so entra no orcamento como um preco fixo, sem texto e sem imagem
- resultado esperado: o cadastro aceita preco fixo, por hora ou por pessoa, descricao e uma foto; o orcamento grava o valor da linha

## Contexto base

- requests relacionados: `task-requests/preco-foto-descricao-servico-request.md`
- documentos de produto relacionados: `product/02-business-rules.md#Pagamentos e contratos`, `product/08-data-model.md#Convencoes e riscos`
- topics relacionados: `topics/data-and-migrations.md#Regras`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: execucao do lote
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; revisar a entrega se o time pedir

## Observacoes

- restricoes: sem preco por diaria, sem mudar a locacao da casa, sem mexer na obrigatoriedade por numero de pessoas
- riscos principais: somar o unitario cru, ou um orcamento ja enviado mudar so porque o cadastro mudou
