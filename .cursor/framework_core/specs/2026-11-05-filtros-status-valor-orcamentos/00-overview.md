# Filtros de status e valor na lista de orcamentos

## Identificacao

- nome da feature: filtros de status e valor na lista de orcamentos
- slug: `filtros-status-valor-orcamentos`
- status: `T-01` e `T-02` escritas; tela ainda nao provada no browser
- origem: `task-requests/filtros-status-valor-painel-orcamentos-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: o bloco abaixo dos filtros fica achatado, nao ha status nem corte por valor, e o Valor no mes soma todos os orcamentos
- resultado esperado: status e arraste ficam numa faixa propria, e o Valor no mes soma so o que virou evento no mes

## Contexto base

- requests relacionados: `task-requests/filtros-status-valor-painel-orcamentos-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project/project-decisions.md#D-01`, `#D-06` e `#D-07`. Esta spec substitui, so para `monthAmount`, o `R-05` de `specs/2026-11-05-lista-painel-orcamentos/01-spec.md`

## Estado atual da feature

- fase atual: codigo das duas tasks escrito
- task em andamento: nenhuma
- proxima task recomendada: prova da tela no browser, com a sessao ja logada

## Observacoes

- restricoes: sem status novo, sem preco minimo por periodo, sem mudar a pagina de eventos
- riscos principais: o card continuar somando Aberto, ou o arraste filtrar so as 10 linhas da pagina
