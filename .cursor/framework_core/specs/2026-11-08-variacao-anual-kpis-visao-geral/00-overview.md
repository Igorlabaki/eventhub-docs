# Variacao anual dos KPIs da visao geral do espaco

## Identificacao

- nome da feature: variacao anual dos KPIs da visao geral do espaco
- slug: `variacao-anual-kpis-visao-geral`
- status: `T-01` e `T-02` escritas; falta a prova no painel com sessao
- origem: `task-requests/variacao-anual-kpis-visao-geral-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: os quatro cards da visao geral nao dizem se o periodo esta acima ou abaixo do mesmo periodo do ano anterior; so Orcamentos mostra percentual, e contra o mes anterior
- resultado esperado: o canto superior direito de Eventos, Orcamentos, Visitas Agendadas e Receita mostra o percentual inteiro contra o mesmo mes (ou ano) do ano anterior

## Contexto base

- requests relacionados: `task-requests/variacao-anual-kpis-visao-geral-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project/project-decisions.md#D-01`, `#D-06` e `#D-08`
- spec irma: `specs/2026-11-05-variacao-anual-kpis-orcamentos/` (mesma regra de percentual e o mesmo canto)

## Estado atual da feature

- fase atual: execucao
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; prova visual pendente

## Observacoes

- restricoes: sem endpoint novo, sem schema, sem mudar o numero principal dos cards
- riscos principais: o backend novo quebrar a tela antiga por troca de formato; a janela anterior nao bater com a janela do card
