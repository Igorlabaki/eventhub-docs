# Trocar a foto do link de orcamento

## Identificacao

- nome da feature: Trocar a foto do link de orcamento por qualquer foto do espaco
- slug: `trocar-foto-proposta-publica`
- status: codigo de `T-01` a `T-03` escrito; coluna no main; falta a troca do dono no browser
- origem: `.cursor/framework_core/task-requests/trocar-foto-proposta-publica-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o link so mostra as fotos marcadas para o site, e o arraste nao coloca no lugar uma foto de fora
- resultado esperado: o dono logado troca a foto do link por qualquer foto do espaco, e essa marca fica gravada na foto

## Contexto base

- requests relacionados: `task-requests/trocar-foto-proposta-publica-request.md`
- documentos de produto relacionados: a pagina publica e a spec `specs/2026-11-04-reordenar-fotos-proposta-publica/`
- topics relacionados: `topics/auth-and-security.md`
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03 e D-05

## Estado atual da feature

- fase atual: `T-01` a `T-03` implementadas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta o dono logado trocar uma foto no link

## Observacoes

- restricoes: a marca do site permanece; sem upload, sem painel novo e sem conjunto de fotos por orcamento
- riscos principais: o visitante ver ou gravar uma foto de fora do link
