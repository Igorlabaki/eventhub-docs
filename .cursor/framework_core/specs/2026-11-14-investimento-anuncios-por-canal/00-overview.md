# Investimento em anuncios por canal

## Identificacao

- nome da feature: canal na despesa de Publicidade e card "Investimento em anuncios" em `/venue/:id/reports`
- slug: `investimento-anuncios-por-canal`
- status: `T-01` a `T-08` executadas em 2026-11-14; aguardando review e deploy
- origem: `task-requests/investimento-anuncios-por-canal-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: o gasto com anuncio e registrado como despesa `ADVERTISING` sem canal, entao nao da para saber quanto custa um orcamento ou um evento vindo de cada rede
- resultado esperado: despesa de Publicidade com canal obrigatorio; endpoint `GET /venue/reports/ads` com investido, orcamentos, eventos, receita, custos e retorno por canal; card na aba `Financeiro`; na analise de despesas, `WEEKLY` corrigido (`PRICE-05`) e esporadicas recortadas de 1/1 a 31/12 (hoje vai ate 31/01 do ano seguinte)

## Contexto base

- requests relacionados: `task-requests/investimento-anuncios-por-canal-request.md`
- topics relacionados: `topics/reports-and-kpis.md#Blocos agregados (/venue/reports/*)`, `#Despesas`; `topics/improvement-backlog.md#PRICE-05`; spec `specs/2026-11-10-novos-blocos-relatorios/` (padrao dos blocos)
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: execucao concluida; browser pendente (login)
- proxima task recomendada: `fw:review` + `entrega` (opcional); depois publicar API e front
