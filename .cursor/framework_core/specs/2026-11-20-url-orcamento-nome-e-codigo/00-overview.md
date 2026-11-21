# URL publica do orcamento

## Identificacao

- nome da feature: URL publica do orcamento com o nome da pessoa e um codigo
- slug: `url-orcamento-nome-e-codigo`
- status: spec pronta para review
- origem: `task-requests/url-orcamento-nome-e-codigo-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: cada link enviado ao cliente usa uma palavra e uma chave diferentes
- resultado esperado: tudo que o cliente abre comeca em `/espaco/AR756`; o orcamento leva `maria-silva-{codigo}`; o link antigo continua abrindo

## Contexto base

- requests relacionados: `task-requests/url-orcamento-nome-e-codigo-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: `topics/public-pages-and-branding.md`, `topics/data-and-migrations.md`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: spec escrita, sem codigo
- task em andamento: nenhuma
- proxima task recomendada: `T-01` depois do `fw:review`

## Observacoes

- restricoes: so a URL do browser muda; a API e o painel continuam em `/proposal/`
- riscos principais: codigo enumeravel; dois homonimos no mesmo orcamento; link antigo deixar de abrir
