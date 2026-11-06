# KPIs, filtros e paginas de dez na lista de contatos

## Identificacao

- nome da feature: KPIs, filtros e paginas de dez na lista de contatos
- slug: `kpis-filtros-lista-contatos`
- status: codigo escrito; prova no browser pendente
- origem: `task-requests/kpis-filtros-lista-contatos-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: Contatos baixa a lista inteira e filtra no navegador, sem pagina nem cards
- resultado esperado: busca, categoria, pagina de 10 e os tres cards saem do `GET /contact/list`, no padrao de orcamentos

## Contexto base

- requests relacionados: `task-requests/kpis-filtros-lista-contatos-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project/project-decisions.md#D-02` e `#D-05`

## Estado atual da feature

- fase atual: `T-01` e `T-02` escritas
- task em andamento: nenhuma
- proxima task recomendada: prova no browser, depois `fw:review` se quiser

## Observacoes

- restricoes: sem schema novo, sem JWT novo na listagem, sem mudar Indicar parceiros
- riscos principais: cards ou filtro calculados so nas dez linhas; chamada sem `page` deixar de devolver a lista inteira
