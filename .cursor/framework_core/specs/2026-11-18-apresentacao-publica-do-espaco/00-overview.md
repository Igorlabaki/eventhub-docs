# Apresentacao publica do espaco

## Identificacao

- nome da feature: Abrir o link publico com a apresentacao do espaco
- slug: `apresentacao-publica-do-espaco`
- status: `T-01` e `T-02` escritas; casa real no browser pendente
- origem: `.cursor/framework_core/task-requests/apresentacao-publica-do-espaco-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: so o orcamento tem pagina publica da casa, e ela exige evento e total
- resultado esperado: `/venue/:id/apresentacao` mostra a casa, os servicos e como o espaco cobra, aberto pela sidebar em outra aba

## Contexto base

- requests relacionados: `task-requests/apresentacao-publica-do-espaco-request.md`
- documentos de produto relacionados: `topics/public-pages-and-branding.md#Orcamento publico`
- topics relacionados: `topics/public-pages-and-branding.md`
- ADRs relacionados: nenhum; valem `project-decisions.md` D-02, D-05 e D-07

## Estado atual da feature

- fase atual: `T-01` e `T-02` escritas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; revisar a entrega

## Observacoes

- restricoes: sem schema novo; `/proposal/:id/view` nao muda; o item Apresentação da sidebar ja existe
- riscos principais: o GET publico devolver preco de servico, dono, contrato ou total de orcamento
