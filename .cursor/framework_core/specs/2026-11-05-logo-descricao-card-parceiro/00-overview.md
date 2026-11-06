# Logo, descricao e card vertical do parceiro

## Identificacao

- nome da feature: Logo, descricao e card vertical do parceiro
- slug: `logo-descricao-card-parceiro`
- status: spec pronta para execucao
- origem: `.cursor/framework_core/task-requests/logo-descricao-card-parceiro-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: o parceiro nao envia logo nem descricao, e nao ve o card antes de salvar
- resultado esperado: cadastro publico com logo, descricao e preview vertical; o card das indicacoes repete esse formato

## Contexto base

- requests relacionados: `task-requests/logo-descricao-card-parceiro-request.md`; `task-requests/indicacoes-publicas-do-orcamento-request.md` (a pagina ja existe e deixou foto e descricao de fora)
- documentos de produto relacionados: nenhum alem do pedido
- topics relacionados: `topics/data-and-migrations.md#Regras`, `topics/integrations.md#S3 e arquivos`, `topics/auth-and-security.md#Estado atual`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: planejamento fechado
- task em andamento: nenhuma
- proxima task recomendada: `T-01`

## Observacoes

- restricoes: migration aditiva; logo so nasce de arquivo enviado; nao autenticar o modulo inteiro de contato nesta spec
- riscos principais: upload na rota publica de cadastro, que hoje ja grava contato sem login
