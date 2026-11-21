# Visual da aba Redes e da pagina publica de links

## Identificacao

- nome da feature: visual da aba Redes e da pagina publica de links
- slug: `visual-redes-e-link-tree`
- status: pronta para execucao
- origem: `framework_core/task-requests/visual-redes-e-link-tree-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: a aba Redes usa cartao com Subir, Descer e "No link tree"; a pagina publica centraliza o texto de cada pilula num ponto diferente
- resultado esperado: aba no desenho de Contatos, com arraste; pagina publica no card de "Gerencie seu evento", titulos alinhados

## Contexto base

- requests relacionados: `task-requests/visual-redes-e-link-tree-request.md`; nao reabrir `visual-pagina-links-espaco-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: `topics/public-pages-and-branding.md#Demais paginas publicas`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` e `T-02` no codigo, sem review
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; review de entrega se o usuario pedir

## Observacoes

- restricoes: sem schema, endpoint ou campo novo; so `eventhub-vista-dashboard`
- riscos principais: o teste da pilula exige a cor invertida e precisa ser reescrito em `T-02`
