# Cadastro das redes e consumo por venue_link

## Identificacao

- nome da feature: Cadastro das redes em Configuracoes e consumo so por venue_link
- slug: `cadastro-redes-e-consumo-venue-link`
- status: tasks no codigo; review pendente
- origem: `task-requests/cadastro-redes-e-consumo-venue-link-request.md`
- owner: nao informado

## Objetivo rapido

- problema que resolve: a aba Redes cadastra e escolhe o que aparece, a sidebar abre a pagina publica, e as telas ainda leem as colunas antigas
- resultado esperado: cadastrar cria o link; a sidebar liga e esconde; WhatsApp e tour nascem ao salvar; quem mostra rede le `venue_link`

## Contexto base

- requests relacionados: `task-requests/cadastro-redes-e-consumo-venue-link-request.md`; specs `2026-11-21-visual-redes-e-link-tree`, `2026-11-21-criar-link-na-link-tree`, `2026-11-20-link-tree-do-espaco` (visual fica)
- documentos de produto relacionados: nenhum
- topics relacionados: `topics/public-pages-and-branding.md`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-06` no codigo
- task em andamento: nenhuma
- proxima task recomendada: nenhuma

## Observacoes

- restricoes: sem coluna nova, sem enum novo, sem apagar as colunas, sem redesenho
- riscos principais: apagar URL ainda nao copiada; o GET publico grava so a copia idempotente da propria casa
