# De onde vem os eventos

## Identificacao

- nome da feature: ranking de cidade, estado e bairro na aba EVENTO
- slug: `origem-dos-eventos`
- status: em execucao (`T-01` a `T-03` no codigo; browser pendente)
- origem: `task-requests/origem-dos-eventos-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: a aba EVENTO nao mostra de onde sao os clientes dos eventos do ano
- resultado esperado: um bloco agregado, so com quantidade, por cidade, estado e bairro

## Contexto base

- requests relacionados: `task-requests/origem-dos-eventos-request.md`
- topics relacionados: `topics/reports-and-kpis.md#Blocos agregados`; `topics/auth-and-security.md#Regras de execucao`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: codigo das tres tasks; falta a aba EVENTO no browser
- task em andamento: nenhuma
- proxima task recomendada: review de entrega, se pedirem

## Observacoes

- restricoes: sem schema, sem mapa, sem valor, sem faixa "sem endereco"; resposta sem rua, numero, CEP, nome ou documento
- riscos principais: o `select` trazer coluna a mais, ou a soma dos rankings nao fechar
- toca backend e frontend; depois da review, `fw:split` antes da execucao repo-local
