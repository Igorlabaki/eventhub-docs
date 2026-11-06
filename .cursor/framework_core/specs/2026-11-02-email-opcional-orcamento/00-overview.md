# E-mail opcional na criacao do orcamento

## Identificacao

- nome da feature: E-mail opcional na criacao do orcamento
- slug: `email-opcional-orcamento`
- status: codigo das 4 tasks pronto; prova manual pendente
- origem: `.cursor/framework_core/task-requests/email-opcional-orcamento-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o dono e obrigado a informar e-mail ao criar o orcamento, e o link do contrato nao pede e-mail
- resultado esperado: o painel cria sem e-mail; o cliente so salva os dados do contrato com e-mail valido

## Contexto base

- requests relacionados: `task-requests/email-opcional-orcamento-request.md`
- documentos de produto relacionados: `product/03-user-profiles.md`, `product/05-functional-flows.md`, `product/08-data-model.md`
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03 e D-05

## Estado atual da feature

- fase atual: `T-01` a `T-04` implementadas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta o fluxo manual no painel e nos links

## Observacoes

- restricoes: WhatsApp, pedido publico do site e envio do orcamento por e-mail ficam como estao
- riscos principais: o cliente salvar o contrato sem e-mail; a coluna continuar obrigando o dono
