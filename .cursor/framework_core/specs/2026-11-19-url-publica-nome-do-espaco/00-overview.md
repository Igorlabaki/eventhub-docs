# URL publica pelo nome do espaco

## Identificacao

- nome da feature: Abrir apresentacao e formulario de orcamento pelo nome do espaco
- slug: `url-publica-nome-do-espaco`
- status: spec pronta para review
- origem: `task-requests/url-publica-nome-do-espaco-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: os links publicos da casa mostram o UUID
- resultado esperado: `/venue/AR756/apresentacao` e `/venue/AR756/form` abrem a AR756; o orcamento grava o id real

## Contexto base

- requests relacionados: `task-requests/url-publica-nome-do-espaco-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: `topics/public-pages-and-branding.md#Pedido de orcamento` e `#Demais paginas publicas`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` e `T-02` no codigo; review pendente
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; `fw:review` + `entrega`

## Observacoes

- restricoes: sem slug novo, sem migration, painel e `/proposal/:id/view` fora
- riscos principais: o formulario gravar o nome como `venueId`; a leitura por nome ampliar o pacote publico
