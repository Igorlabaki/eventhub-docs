# Reordenar fotos da proposta publica

## Identificacao

- nome da feature: Reordenar as fotos da proposta publica arrastando
- slug: `reordenar-fotos-proposta-publica`
- status: codigo de `T-01` a `T-03` escrito; falta o arraste do dono no browser
- origem: `.cursor/framework_core/task-requests/reordenar-fotos-proposta-publica-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: a ordem das fotos do link publico so muda pelo numero Posicao no painel
- resultado esperado: o dono logado arrasta as fotos no link, solta, e a ordem permanece para todo mundo

## Contexto base

- requests relacionados: `task-requests/reordenar-fotos-proposta-publica-request.md`
- documentos de produto relacionados: nenhum alem da pagina publica ja entregue
- topics relacionados: `topics/auth-and-security.md`
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03 e D-05

## Estado atual da feature

- fase atual: `T-01` a `T-03` implementadas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta o arraste do dono logado no browser

## Observacoes

- restricoes: sem coluna nova, sem upload e sem abrir o arraste para quem so tem o link
- riscos principais: visitante gravar a ordem; token invalido derrubar a pagina publica
