# Video do tour na proposta publica

## Identificacao

- nome da feature: Salvar o video do tour do espaco e mostrar na proposta publica
- slug: `video-tour-do-espaco`
- status: codigo das 3 tasks escrito; coluna no main de ar756 (deploy request 36)
- origem: `.cursor/framework_core/task-requests/video-tour-do-espaco-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o espaco nao guarda um tour em video e a proposta publica nao o mostra
- resultado esperado: o link salvo nas configuracoes aparece entre a experiencia e o investimento, mudo, em loop e sem controles

## Contexto base

- requests relacionados: `task-requests/video-tour-do-espaco-request.md`
- documentos de produto relacionados: nenhum jornada nova; vale a pagina publica que ja existe
- topics relacionados: `topics/data-and-migrations.md`, `topics/auth-and-security.md`
- ADRs relacionados: nenhum; valem `project-decisions.md` D-01, D-02, D-03 e D-05

## Estado atual da feature

- fase atual: `T-01` a `T-03` escritas; coluna no main; falta a prova na tela
- task em andamento: nenhuma
- proxima task recomendada: nenhuma de codigo; provar o fluxo na tela

## Observacoes

- restricoes: sem upload, sem rota nova, sem video fora da proposta publica
- riscos principais: embed de pagina arbitraria; autoplay com som, que o navegador bloqueia
- tasks ja separadas por repo; `fw:split` so se a execucao for repo-local
