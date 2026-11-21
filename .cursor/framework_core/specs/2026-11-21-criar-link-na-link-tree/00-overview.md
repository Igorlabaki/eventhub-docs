# Botao para criar link na link tree

## Identificacao

- nome da feature: botao para criar link na link tree, no painel e na pagina publica
- slug: `criar-link-na-link-tree`
- status: tasks no codigo, review de entrega pendente
- origem: `task-requests/criar-link-na-link-tree-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: a aba Redes so cria pelo select, e a pagina publica nao cria nem avisa quando a lista esta vazia
- resultado esperado: um botao abre o modal de rede e link; na publica, quem tem `EDIT_VENUE_SITE` cria, remove e reordena, e o vazio mostra o container

## Contexto base

- requests relacionados: `task-requests/criar-link-na-link-tree-request.md`; nao reabre o visual, a pilula, `specs/2026-11-21-criar-rede-do-espaco/` nem `specs/2026-11-21-subtitulo-ordem-e-remocao-na-pagina-de-links/`
- documentos de produto relacionados: nenhum
- topics relacionados: `topics/public-pages-and-branding.md#Demais paginas publicas`; `topics/permissions-catalog.md` (`EDIT_VENUE_SITE`)
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-03` no codigo
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; review de entrega se for pedida

## Observacoes

- restricoes: sem schema e sem permissao nova; o `PUT` do editor continua em `EDIT_VENUE_INFO`
- riscos principais: visitante gravar ou ver a gestao; rede do sistema sem destino sumir na publica
