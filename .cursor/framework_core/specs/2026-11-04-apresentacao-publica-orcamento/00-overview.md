# Apresentacao publica do orcamento

## Identificacao

- nome da feature: Apresentar a casa na proposta publica e deixar o valor no fim
- slug: `apresentacao-publica-orcamento`
- status: spec em execucao; codigo das 5 tasks escrito
- origem: `.cursor/framework_core/task-requests/apresentacao-publica-orcamento-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o link publico do orcamento so mostra numeros e nao apresenta a casa
- resultado esperado: a pagina mostra logo, fotos do site, caracteristicas, dados de venda e servicos deste orcamento, nas cores de Configuracoes, e o total fica no fim

## Contexto base

- requests relacionados: `task-requests/apresentacao-publica-orcamento-request.md`
- documentos de produto relacionados: `product/04-user-journeys.md`, `product/06-design-system-direction.md`
- topics relacionados: `topics/auth-and-security.md`
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03, D-05 e D-06

## Estado atual da feature

- fase atual: `T-01` a `T-05` implementadas; colunas de cor no `main` de `ar756` (deploy request 35)
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta provar a pagina no browser

## Observacoes

- restricoes: pagina publica; cores so nessa pagina; sem regras, textos antigos de amenities, endereco completo nem tabela de preco
- riscos principais: o pacote publico da casa vazar dono, contrato ou pagamento; a pagina continuar lendo o venue completo
