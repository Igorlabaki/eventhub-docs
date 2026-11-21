# Icone da aba do espaco

## Identificacao

- nome da feature: Icone da aba do espaco
- slug: `icone-aba-espaco`
- status: spec pronta para review
- origem: `task-requests/icone-aba-espaco-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: a aba mostra o nome do espaco e o favicon fixo do EventHub
- resultado esperado: ao lado do logo da para gravar um icone, e a aba daquele lugar usa esse arquivo

## Contexto base

- requests relacionados: `task-requests/icone-aba-espaco-request.md`
- documentos de produto relacionados: `product/08-data-model.md#Models por area`
- topics relacionados: `topics/public-pages-and-branding.md#Marca do espaco`, `topics/data-and-migrations.md#Regras`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-05` no codigo; browser e deploy da coluna ainda nao
- task em andamento: nenhuma
- proxima task recomendada: review de entrega, se for pedida

## Observacoes

- restricoes: o logo continua no campo `file`; sem icone, a aba fica em `/favicon.ico`; a migration nao entra na `main` sem aprovacao nomeada
- riscos principais: o icone gravar por cima do logo, ou a aba de outra casa herdar o icone anterior
