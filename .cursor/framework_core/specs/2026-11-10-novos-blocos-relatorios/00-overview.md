# Novos blocos nos relatorios

## Identificacao

- nome da feature: ocupacao da agenda, antecedencia dos pedidos, aderencia dos servicos adicionais e porte e perfil dos eventos em `/venue/:id/reports`
- slug: `novos-blocos-relatorios`
- status: em execucao (codigo e docs prontos; browser pendente)
- origem: `task-requests/novos-blocos-agenda-antecedencia-servicos-porte-relatorios-request.md`
- owner: nao definido

## Objetivo rapido

- problema que resolve: os relatorios nao mostram quando o espaco esta ocupado, com quanta antecedencia os pedidos chegam, quais servicos adicionais vendem nem se os eventos usam a capacidade
- resultado esperado: quatro blocos agregados no backend, com permissao `VIEW_VENUE_ANALYSIS` checada no servidor; `Antecedência dos pedidos` na aba `Orçamentos` e os outros tres na aba `Evento`

## Contexto base

- requests relacionados: `task-requests/novos-blocos-agenda-antecedencia-servicos-porte-relatorios-request.md`
- topics relacionados: `topics/reports-and-kpis.md`; `project/api-endpoints.md#venue`; `docs/planos/horario-wall-clock/01-analise-problema.md`
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-08` implementadas; falta prova no browser
- proxima task recomendada: prova no browser; depois `fw:review` + `entrega`, se o humano quiser
