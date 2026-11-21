# Card da casa na apresentacao publica

## Identificacao

- nome da feature: Card da casa na apresentacao publica
- slug: `card-da-casa-apresentacao-publica`
- status: `T-01` e `T-02` no codigo; browser pendente
- origem: `.cursor/framework_core/task-requests/card-da-casa-apresentacao-publica-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o vao entre o video e a foto mostra uma foto, e a descricao ainda fica embaixo do logo
- resultado esperado: nesse vao entra o card da casa, e o slogan ocupa a linha do topo

## Contexto base

- requests relacionados: `task-requests/card-da-casa-apresentacao-publica-request.md`; o slogan parou em `task-requests/slogan-espaco-configuracoes-request.md`
- documentos de produto relacionados: `topics/public-pages-and-branding.md#Demais paginas publicas`
- topics relacionados: `topics/public-pages-and-branding.md`
- ADRs relacionados: nenhum; vale `project-decisions.md` D-05 para o GET publico por id

## Estado atual da feature

- fase atual: `T-01` e `T-02` escritas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; a pagina no browser ficou pendente

## Observacoes

- restricoes: sem migration; orcamento e formulario publico nao mudam; rua e numero continuam so no mapa
- riscos principais: a descricao longa permanecer no topo, ou o GET passar a devolver campo alem de `slogan`
