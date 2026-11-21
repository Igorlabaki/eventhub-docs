# Reordenar e trocar fotos no orcamento e na apresentacao

## Identificacao

- nome da feature: reordenar e trocar fotos no orcamento e na apresentacao
- slug: `editar-fotos-orcamento-e-apresentacao`
- status: codigo das tres tasks pronto, review de entrega pendente
- origem: `task-requests/editar-fotos-orcamento-e-apresentacao-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: a mesma galeria do espaco se edita na URL antiga do orcamento, some a troca na URL nova e nao se edita na apresentacao
- resultado esperado: quem tem Site naquele espaco reordena e troca a foto nas tres paginas; os demais so assistem

## Contexto base

- requests relacionados: `task-requests/editar-fotos-orcamento-e-apresentacao-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: `topics/public-pages-and-branding.md#Orcamento publico`, `topics/permissions-catalog.md#Onde o backend verifica`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-03` no codigo
- task em andamento: nenhuma
- proxima task recomendada: review de entrega

## Observacoes

- restricoes: mesma permissao Site (`EDIT_VENUE_SITE`); sem schema; o layout de cada pagina fica
- riscos principais: catalogo de foto oculta vazar na rota publica; a apresentacao gravar sem checar Site
