# Total estimado do orcamento no painel

## Identificacao

- nome da feature: Total estimado do orcamento enquanto o formulario e preenchido
- slug: `total-estimado-orcamento-painel`
- status: spec pronta para execucao
- origem: `.cursor/framework_core/task-requests/2026-11-09-orcamento-painel-por-pessoa-e-total-estimado/tr-02-total-estimado-ao-preencher.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: no painel, o total so aparece depois de salvar quando o campo Total fica vazio
- resultado esperado: criar e editar orcamento por pessoa mostram o total estimado e o detalhamento, vindos de uma cotacao do backend que nao grava e bate com o valor gravado

## Contexto base

- requests relacionados: lote `task-requests/2026-11-09-orcamento-painel-por-pessoa-e-total-estimado/` (`tr-01` e independente)
- documentos de produto relacionados: `product/02-business-rules.md#Proposal`
- topics relacionados: `topics/backend-api.md`; `project-decisions.md` D-02, D-05, D-06 e D-07
- ADRs relacionados: nenhum
- spec vizinha: `specs/2026-11-04-recalcular-orcamento-proposta-publica/` (dona da conta que vira compartilhada)

## Estado atual da feature

- fase atual: bootstrap concluido
- task em andamento: nenhuma
- proxima task recomendada: `T-01`

## Observacoes

- restricoes: rota autenticada; resposta sem tabela de preco, meta nem faturamento; sem schema novo
- riscos principais: a estimativa divergir do valor gravado; a extracao mudar valor de recalculo publico ja em producao
