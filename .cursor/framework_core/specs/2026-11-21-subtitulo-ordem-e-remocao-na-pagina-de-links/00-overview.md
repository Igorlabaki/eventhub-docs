# Subtitulo, ordem e remocao na pagina de links

## Identificacao

- nome da feature: subtitulo, ordem e remocao na pagina de links
- slug: `subtitulo-ordem-e-remocao-na-pagina-de-links`
- status: codigo das tres tasks pronto, review de entrega pendente
- origem: `task-requests/subtitulo-ordem-e-remocao-links-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: o botao da pagina de links nao tem a segunda linha, e ordem e oculto so mudam na aba Redes
- resultado esperado: cada botao mostra um subtitulo; quem tem Site naquele espaco arrasta a ordem na propria pagina e, depois de confirmar, omite o link

## Contexto base

- requests relacionados: `task-requests/subtitulo-ordem-e-remocao-links-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: `topics/public-pages-and-branding.md#Demais paginas publicas`, `topics/permissions-catalog.md#Onde o backend verifica`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-03` no codigo
- task em andamento: nenhuma
- proxima task recomendada: review de entrega

## Observacoes

- restricoes: sem schema; sem permissao nova; a lixeira da aba Redes fica; icone, seta e titulo do card ficam
- riscos principais: visitante gravar ordem ou oculto; o `PUT` da aba Redes apagar links se a pagina mandar a lista incompleta
