# Foto, video e descricao na caracteristica

## Identificacao

- nome da feature: Foto, link do YouTube e descricao em cada caracteristica do espaco
- slug: `foto-video-descricao-caracteristica`
- status: `T-01` a `T-04` no codigo em 2026-11-12, com testes; tela nao provada no browser; colunas no main (deploy request 43)
- origem: `.cursor/framework_core/task-requests/foto-video-descricao-caracteristica-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: a caracteristica so tem nome e posicao, e a proposta publica lista so o nome
- resultado esperado: o cadastro grava descricao, foto e link do YouTube, todos opcionais e combinaveis; na proposta, o item com complemento ganha um "?" que abre um modal com esse conteudo

## Contexto base

- requests relacionados: `task-requests/foto-video-descricao-caracteristica-request.md`
- documentos de produto relacionados: `product/08-data-model.md#Dados sensiveis`, `product/04-user-journeys.md`
- topics relacionados: `topics/data-and-migrations.md#Regras`, `topics/backend-api.md#Cuidados`, `topics/frontend-application.md#Cuidados`
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03 e D-05

## Estado atual da feature

- fase atual: lote executado
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta provar painel e proposta no browser

## Observacoes

- restricoes: sem upload de arquivo de video, sem tour, sem galeria, sem foto de servico, sem storage privado
- riscos principais: link que nao e do YouTube chegar ao player publico; migration do repo divergir das colunas que ja existem no main
- decisoes de 2026-11-12: o video e so um link do YouTube; foto e video podem coexistir; a proposta mostra o complemento num modal aberto pelo "?", igual aos servicos
