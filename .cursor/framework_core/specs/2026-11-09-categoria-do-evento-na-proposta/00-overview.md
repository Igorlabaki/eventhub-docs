# Categoria do evento na proposta

## Identificacao

- nome da feature: categoria do evento (empresarial, aniversario, despedida de solteiro, casamento, coffee break, outro) nas propostas de tipo Evento
- slug: `categoria-do-evento-na-proposta`
- status: planejada
- origem: `task-requests/categoria-do-evento-na-proposta-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: `Proposal.type` diz a modalidade (evento, producao, permuta), nao a ocasiao; a ocasiao so aparece no texto livre de `description`
- resultado esperado: toda proposta nova de tipo Evento grava uma categoria da lista fechada; o detalhe mostra `Evento · <categoria>`

## Contexto base

- requests relacionados: `task-requests/categoria-do-evento-na-proposta-request.md`
- documentos de produto relacionados: `product/04-user-journeys.md` (cliente informa o tipo de evento no formulario publico)
- topics relacionados: `topics/data-and-migrations.md`; `project/planetscale.md`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: tasks executadas; falta deploy request e browser
- task em andamento: nenhuma
- proxima task recomendada: nenhuma

## Observacoes

- restricoes: coluna nova opcional, sem backfill; `ProposalType` nao muda; deploy request no `main` so com aprovacao nomeada
- riscos principais: a regra ficar so no schema Zod (o create por pessoa ignora o parse); proposta antiga de Evento quebrar na leitura
