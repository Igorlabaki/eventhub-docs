# Overview — Lista de servicos no painel

## Identificacao

- nome da feature: Lista de servicos ao criar e editar orcamento no painel
- slug: `lista-servicos-painel-orcamento`
- status: codigo escrito; prova no browser pendente
- origem: `.cursor/framework_core/task-requests/lista-servicos-painel-orcamento-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: no painel, os servicos ficam lado a lado, sem o texto de obrigatorio, e a hora da linha e a duracao do evento
- resultado esperado: criar e editar no painel usam a lista do link publico, e a quantidade digitada entra na linha

## Contexto base

- requests relacionados: `task-requests/lista-servicos-painel-orcamento-request.md`; `task-requests/horas-servico-por-hora-request.md` deixou o painel de fora
- documentos de produto relacionados: `product/02-business-rules.md#Proposal`
- topics relacionados: nenhum
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-03` no codigo; tela ainda nao provada
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta o browser

## Observacoes

- restricoes: sem coluna nova; preco permanece na linha do painel; link publico nao e redesenhado
- riscos principais: publicar a edicao no backend antes da tela faz o servico por hora falhar ao salvar
