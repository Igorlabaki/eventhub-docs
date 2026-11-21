# Proprietario pessoa fisica ou juridica

## Identificacao

- nome da feature: Proprietario pessoa fisica ou juridica
- slug: `proprietario-pessoa-juridica`
- status: spec pronta para review; nada implementado
- origem: `.cursor/framework_core/task-requests/proprietario-pessoa-juridica-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o proprietario so pode ser pessoa fisica, e a API de proprietarios nao isola organizacoes, apaga vinculos na edicao parcial e vaza dados do proprietario numa rota publica
- resultado esperado: o painel cadastra PF ou PJ (CNPJ numerico ou alfanumerico, porte opcional) so dentro da organizacao do usuario, os antigos seguem PF, nenhuma rota publica devolve o proprietario e o PDF preenche os dados da empresa

## Contexto base

- requests relacionados: `task-requests/proprietario-pessoa-juridica-request.md`
- documentos de produto relacionados: `product/08-data-model.md` (linha `Owner`, secao PII)
- topics relacionados: `topics/auth-and-security.md`; valem `project-decisions.md` D-05 e D-09
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: spec pronta para review
- task em andamento: nenhuma
- proxima task recomendada: `T-02` (resposta publica sem proprietario, pode sair sozinha antes), com `T-01`, `T-03` e `T-04` em paralelo

## Observacoes

- restricoes: colunas aditivas na `main` por deploy request antes da API; ordem banco, API, painel
- riscos principais: usuario de uma organizacao ler ou alterar proprietario de outra; edicao parcial apagar dados; PII do proprietario na rota publica de espaco
