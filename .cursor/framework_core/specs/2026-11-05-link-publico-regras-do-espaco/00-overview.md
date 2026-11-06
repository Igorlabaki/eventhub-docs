# Link publico das regras do espaco

## Identificacao

- nome da feature: Abrir o link publico das regras do espaco
- slug: `link-publico-regras-do-espaco`
- status: `T-01` a `T-03` escritas; o gesto de copiar no painel passou para `specs/2026-11-05-links-painel-e-formularios/`
- origem: `.cursor/framework_core/task-requests/link-publico-regras-do-espaco-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: as regras so aparecem na tela autenticada do venue
- resultado esperado: um endereco publico daquele espaco mostra as regras, da para copiar na tela Regras, e o Link do evento abre a mesma pagina

## Contexto base

- requests relacionados: `task-requests/link-publico-regras-do-espaco-request.md`
- documentos de produto relacionados: `product/04-user-journeys.md`, `product/08-data-model.md`
- specs relacionadas: `specs/2026-11-02-regras-do-espaco/` (cadastro; a listagem autenticada permanece)
- topics relacionados: nenhum
- ADRs relacionados: nenhum; valem `project-decisions.md` D-02 e D-05

## Estado atual da feature

- fase atual: `T-01` a `T-03` escritas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma nesta spec; falta o clique no destino publico "Regras do espaço". Copiar em Regras e o item da sidebar estao em `specs/2026-11-05-links-painel-e-formularios/`

## Observacoes

- restricoes: sem coluna nova; criar, alterar e remover continuam autenticados; fora orcamento, contrato, e-mail e organizacao
- riscos principais: a leitura publica devolver regra de outro espaco ou campo alem de id, titulo, texto e posicao
