# Cortesia de servicos no orcamento

## Identificacao

- nome da feature: Cortesia de servicos no orcamento
- slug: `cortesia-servicos-orcamento`
- status: `T-01` a `T-07` implementadas; coluna na `main` (deploy request `#45`); nao pronto para producao
- origem: `.cursor/framework_core/task-requests/cortesia-servicos-orcamento-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o dono nao tem como dar parte de um servico de graca em um orcamento sem zerar o preco do catalogo ou perder o detalhe no total manual
- resultado esperado: o dono informa a cortesia por servico (horas, pessoas ou o fixo inteiro), a linha cobra so o restante e painel e link mostram valor cheio, cortesia e valor final

## Contexto base

- requests relacionados: `task-requests/cortesia-servicos-orcamento-request.md`
- documentos de produto relacionados: `product/02-business-rules.md#Precificacao`, `product/08-data-model.md`
- topics relacionados: `topics/pricing-and-proposal-calculation.md#Servicos (quote-service-lines.ts)`; valem `project-decisions.md` D-05, D-07 e D-09
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: spec pronta para review
- task em andamento: nenhuma
- proxima task recomendada: `T-01` (schema e deploy request), com `T-02` em paralelo

## Observacoes

- restricoes: coluna aditiva na `main` antes do backend; criacao de orcamento e publica, entao cortesia exige token e permissao no espaco
- riscos principais: cliente criar cortesia pela rota publica; total errado quando horas ou convidados caem abaixo da cortesia
