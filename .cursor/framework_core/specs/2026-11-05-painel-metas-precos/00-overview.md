# Painel de metas e precos

## Identificacao

- nome da feature: Painel de metas e precos igual a referencia
- slug: `painel-metas-precos`
- status: spec pronta para execucao
- origem: `.cursor/framework_core/task-requests/painel-metas-precos-referencia-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o painel nao segue a referencia e trata bloco vazio como zero ou como bloco tracejado
- resultado esperado: a aba Painel mostra o resumo e as secoes da referencia; sem configuracao, o bloco diz "Nada configurado"

## Contexto base

- requests relacionados: `task-requests/painel-metas-precos-referencia-request.md`
- documentos de produto relacionados: `product/04-user-journeys.md` (configurar metas permanece o mesmo passo)
- topics relacionados: `topics/frontend-application.md`
- ADRs relacionados: nenhum
- spec vizinha: `specs/2026-11-02-precos-minimos-por-periodo/` continua dona do piso

## Estado atual da feature

- fase atual: `T-01` e `T-02` no codigo; falta a tela no browser
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; a prova que falta e abrir o Painel logado

## Observacoes

- restricoes: sem campo novo, sem API, sem ilustracao obrigatoria
- riscos principais: mostrar zero no lugar do vazio; desenhar faturamento que o produto nao tem
