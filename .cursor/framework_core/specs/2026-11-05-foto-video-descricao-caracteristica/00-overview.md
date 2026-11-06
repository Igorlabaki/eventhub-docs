# Foto ou video e descricao na caracteristica

## Identificacao

- nome da feature: Foto ou video do YouTube e descricao em cada caracteristica do espaco
- slug: `foto-video-descricao-caracteristica`
- status: codigo de T-01 a T-04 escrito; colunas no main (deploy request 43); tela nao provada
- origem: `.cursor/framework_core/task-requests/foto-video-descricao-caracteristica-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: a caracteristica so tem nome e posicao, e a proposta publica lista so o nome
- resultado esperado: o cadastro grava descricao opcional e uma midia (foto ou YouTube); a proposta mostra esse complemento

## Contexto base

- requests relacionados: `task-requests/foto-video-descricao-caracteristica-request.md`
- documentos de produto relacionados: `product/08-data-model.md#Dados sensiveis`, `product/04-user-journeys.md`
- topics relacionados: `topics/data-and-migrations.md#Regras`, `topics/backend-api.md#Cuidados`, `topics/frontend-application.md#Cuidados`
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03 e D-05

## Estado atual da feature

- fase atual: lote escrito
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta provar a tela

## Observacoes

- restricoes: sem arquivo de video, sem tour, sem galeria, sem foto de servico, sem storage privado
- riscos principais: foto e video no mesmo item, ou um link que nao e do YouTube na pagina publica
