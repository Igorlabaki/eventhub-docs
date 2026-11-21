# Ate tres fotos na caracteristica

## Identificacao

- nome da feature: Ate tres fotos, em ordem escolhida, em cada caracteristica do espaco
- slug: `multiplas-fotos-caracteristica`
- status: `T-01` a `T-06` executadas em 2026-11-13; tabela na `main` (deploy request 48) e foto atual copiada; codigo nao commitado; browser pendente
- origem: `.cursor/framework_core/task-requests/multiplas-fotos-caracteristica-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: a caracteristica aceita uma foto so; o painel nao deixa mostrar mais de um angulo do item
- resultado esperado: criar e editar gravam ate 3 fotos, com adicionar, remover e reordenar; o modal publico do "?" mostra as fotos em grid, na ordem salva

## Contexto base

- requests relacionados: `task-requests/multiplas-fotos-caracteristica-request.md`; `task-requests/navegar-caracteristicas-modal-proposta-request.md` (mesmo modal)
- spec anterior: `specs/2026-11-05-foto-video-descricao-caracteristica/` (criou a foto unica)
- documentos de produto relacionados: `product/08-data-model.md` (linha `VenueAmenity`)
- topics relacionados: `topics/data-and-migrations.md#Regras`, `project/planetscale.md#Permissoes do agente`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: lote executado
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta browser, commit e publicacao (API, segunda copia, front)

## Observacoes

- restricoes: sem biblioteca de arrastar e soltar; sem apagar a coluna `imageUrl`; video e descricao nao mudam
- riscos principais: a foto que ja existe sumir na troca de modelo; foto removida ficar no storage
- decisoes do chat de 2026-11-13: no maximo 3 fotos; reordenar no criar e no editar; grid no modal publico
