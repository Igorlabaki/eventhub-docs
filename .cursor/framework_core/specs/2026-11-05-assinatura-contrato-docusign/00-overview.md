# Overview — Assinatura do contrato no DocuSign

## Identificacao

- nome da feature: Assinar o contrato da proposta no DocuSign
- slug: `assinatura-contrato-docusign`
- status: spec pronta para review
- origem: `.cursor/framework_core/task-requests/assinatura-contrato-docusign-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: o contrato sai por e-mail e a assinatura nao volta para a proposta
- resultado esperado: o operador envia o PDF pelo DocuSign e, depois da assinatura, a proposta mostra o contrato assinado

## Contexto base

- requests relacionados: `task-requests/assinatura-contrato-docusign-request.md`
- documentos de produto relacionados: `product/09-integrations.md`, `docs/planos/PLANO_INTEGRACAO_DOCUSIGN.md`
- topics relacionados: `topics/integrations.md`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01`, `T-02` e `T-03` no codigo; prova manual ainda aberta
- task em andamento: nenhuma
- proxima task recomendada: nenhuma no codigo

## Observacoes

- restricoes: uma conta DocuSign do EventHub, sandbox, JWT; sem login do operador nem do cliente
- riscos principais: segredo no log, PDF da proposta errada, marcar assinado sem gravar o arquivo
