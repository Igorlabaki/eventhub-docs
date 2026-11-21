# Preenchimento de endereco por CEP

## Identificacao

- nome da feature: Preenchimento de endereco por CEP
- slug: `preenchimento-endereco-por-cep`
- status: spec pronta para review
- origem: `task-requests/preenchimento-endereco-por-cep-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: endereco digitado a mao sai com grafias diferentes e o relatorio de origem parte a mesma cidade
- resultado esperado: o CEP preenche logradouro, bairro, cidade e UF no espaco e no contrato; numero e complemento continuam manuais

## Contexto base

- requests relacionados: `task-requests/preenchimento-endereco-por-cep-request.md`
- documentos de produto relacionados: nenhum
- topics relacionados: `topics/frontend-application.md`, `topics/auth-and-security.md`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-05` no codigo, sem review
- task em andamento: nenhuma
- proxima task recomendada: `fw:review`

## Observacoes

- restricoes: busca no navegador; sem coluna nova e sem endpoint novo
- riscos principais: o CEP sai para a ViaCEP; o padrao Sao Paulo / SP do contrato parecer resultado da busca
