# Indicacoes publicas do orcamento

## Identificacao

- nome da feature: salvar as indicacoes no orcamento e abrir a pagina publica dos parceiros
- slug: `indicacoes-publicas-do-orcamento`
- status: planejada
- origem: `task-requests/indicacoes-publicas-do-orcamento-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: a indicacao de parceiros so existe numa mensagem de WhatsApp e nao fica no orcamento
- resultado esperado: a equipe grava a selecao no orcamento e a pessoa abre `/proposal/:id/indications` com os dados atuais desses parceiros

## Contexto base

- requests relacionados: `task-requests/indicacoes-publicas-do-orcamento-request.md`
- documentos de produto relacionados: nenhum; a jornada publica de referencia esta nas listas ja entregues
- topics relacionados: `topics/auth-and-security.md`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: spec pronta para revisao
- task em andamento: nenhuma
- proxima task recomendada: `T-01`

## Observacoes

- restricoes: migration aditiva; a pagina publica mostra so o que foi indicado; sem envio de mensagem
- riscos principais: vazar fornecedor nao indicado ou contato de equipe; gravar contato de outro espaco
