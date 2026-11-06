# Regras do espaco

## Identificacao

- nome da feature: Cadastrar regras do espaco no venue
- slug: `regras-do-espaco`
- status: implementada, prova manual do painel pendente
- origem: `.cursor/framework_core/task-requests/regras-do-espaco-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o venue nao tem cadastro das regras do espaco
- resultado esperado: no painel, quem pode editar aquele venue cria, altera e remove regras, e elas permanecem

## Contexto base

- requests relacionados: `task-requests/regras-do-espaco-request.md`
- documentos de produto relacionados: `product/02-business-rules.md`, `product/04-user-journeys.md`, `product/08-data-model.md`
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03 e D-05

## Estado atual da feature

- fase atual: `T-01` a `T-04` implementadas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta o fluxo manual no painel

## Observacoes

- restricoes: cadastro so no painel; a leitura publica ficou em `specs/2026-11-05-link-publico-regras-do-espaco/`; fora orcamento, contrato e organizacao
- riscos principais: gravar no venue errado; copiar `ensurePermission`, que nao amarra o venue da regra
