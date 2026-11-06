# Adicionar ou tirar servico no link publico

## Identificacao

- nome da feature: Adicionar ou tirar servico no link publico do orcamento
- slug: `adicionar-servico-proposta-publica`
- status: codigo escrito; falta prova no browser
- origem: `.cursor/framework_core/task-requests/adicionar-servico-proposta-publica-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: no link publico o cliente ve os servicos ligados e nao consegue marcar nem desmarcar nenhum
- resultado esperado: o botao "Adicionar servico" abre um modal; confirmar grava a selecao, trava o obrigatorio e atualiza a experiencia e o total

## Contexto base

- requests relacionados: `task-requests/adicionar-servico-proposta-publica-request.md`
- documentos de produto relacionados: `product/02-business-rules.md#Proposal`, `product/03-user-profiles.md#Cliente proponente`, `product/08-data-model.md`
- topics relacionados: nenhum de proposta; vale `project-decisions.md` D-02, D-05 e D-07
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-03` escritas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; a prova que falta e o modal no browser

## Observacoes

- restricoes: pagina publica; sem regravar locacao, horas ou dia; sem tabela de preco unitario na resposta; sem schema novo
- riscos principais: o link tirar servico obrigatorio, ou a tela substituir um total negociado pela tabela da casa
