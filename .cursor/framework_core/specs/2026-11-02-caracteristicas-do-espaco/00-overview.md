# Caracteristicas do espaco

## Identificacao

- nome da feature: Cadastrar caracteristicas do espaco no venue
- slug: `caracteristicas-do-espaco`
- status: spec pronta para execucao
- origem: `.cursor/framework_core/task-requests/caracteristicas-do-espaco-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o painel do venue nao tem cadastro proprio da lista do que o espaco tem
- resultado esperado: no painel, quem pode editar aquele venue cria, altera e remove caracteristicas, e elas permanecem

## Contexto base

- requests relacionados: `task-requests/caracteristicas-do-espaco-request.md`
- documentos de produto relacionados: `product/02-business-rules.md`, `product/04-user-journeys.md`, `product/08-data-model.md`
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03 e D-05

## Estado atual da feature

- fase atual: `T-01` a `T-04` implementadas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta o fluxo manual no painel

## Observacoes

- restricoes: so painel do venue; os `Text` com `area: "amenities"` no site e na proposta ficam como estao
- riscos principais: gravar no venue errado; copiar `ensurePermission`, que nao amarra o venue da caracteristica
