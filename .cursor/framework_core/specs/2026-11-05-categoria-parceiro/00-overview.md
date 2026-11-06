# Categoria do parceiro

## Identificacao

- nome da feature: categorizar o parceiro no cadastro e agrupar os indicados na pagina publica
- slug: `categoria-parceiro`
- status: planejada
- origem: `task-requests/categoria-parceiro-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: o parceiro nao tem categoria, e a pagina publica lista os indicados numa fila so
- resultado esperado: o cadastro exige uma categoria da lista; quem ja existe fica em Outros; `/proposal/:id/indications` separa os indicados por categoria

## Contexto base

- requests relacionados: `task-requests/categoria-parceiro-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: `topics/data-and-migrations.md`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: spec pronta para revisao
- task em andamento: nenhuma
- proxima task recomendada: `T-01`

## Observacoes

- restricoes: coluna nova opcional; fallback so em fornecedor; funcao livre permanece; rota publica nao muda
- riscos principais: marcar membro de equipe como Outros; a pagina mostrar indicado de outro orcamento
