# Precos minimos por periodo

## Identificacao

- nome da feature: Precos minimos por periodo no espaco
- slug: `precos-minimos-por-periodo`
- status: implementada, prova da tela pendente
- origem: `.cursor/framework_core/task-requests/precos-minimos-por-periodo-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o espaco so tem um piso de orcamento, sem faixa por periodo
- resultado esperado: a aba Minimos edita o piso padrao e as faixas; o orcamento automatico usa a faixa da data de inicio

## Contexto base

- requests relacionados: `task-requests/precos-minimos-por-periodo-request.md`; o calculo da edicao tambem e tocado por `task-requests/edicao-orcamento-adicionais-descontos-request.md`
- documentos de produto relacionados: `product/02-business-rules.md`, `product/04-user-journeys.md`, `product/07-domain-model.md`, `product/08-data-model.md`
- topics relacionados: `topics/backend-api.md`
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03, D-05 e D-07

## Estado atual da feature

- fase atual: `T-01` a `T-04` no codigo; falta a passagem manual da aba
- task em andamento: nenhuma
- proxima task recomendada: abrir Metas e Precos logado; review de entrega so se for pedida

## Observacoes

- restricoes: nao usar `SeasonalFee`; nao mudar adicional, desconto, meta, site, contrato nem pagamento
- riscos principais: piso da data errada; autorizar faixa em outro venue; a edicao de adicionais apagar o piso, ou esta feature apagar o adicional da edicao
