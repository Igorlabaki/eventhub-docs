# Clarify — Caracteristicas do espaco

## Perguntas criticas

- A lista e de varios itens ou um texto unico?
- Quais campos entram?
- Onde a lista nova aparece nesta entrega?
- A permissao e propria?
- Os `Text` atuais de amenities entram na tabela nova?
- Nome repetido no mesmo venue e permitido?

## Respostas confirmadas

- Varios itens do mesmo venue. A conversa pediu uma lista (piscina aquecida, salao interno, telao).
- Nome obrigatorio, ate 120 caracteres, e ordem de exibicao. Sem titulo separado nem descricao.
- So no painel do venue nesta entrega.
- Par proprio de ver e editar, no mesmo modelo dos outros cadastros do venue.
- Os `Text` com `area: "amenities"` nao migram e continuam no site e na proposta.

## Requisitos implicitos confirmados

- A gravacao passa pelo backend autenticado. A permissao da tela nao autoriza a API.
- A caracteristica pertence a um venue. Update e delete usam o venue gravado no item.
- A migration de producao e aditiva. Schema e backfill de permissao ficam em passos separados, como em `database/rules/04_migrations_and_zero_downtime.md`.
- O frontend usa o Zustand dos cadastros do venue. Nao abre React Query nem outro store global para este fluxo.
- `D-03`: a cascata existe no client Prisma, nao como FK fisica presumida.
- `D-05`: a rota nasce autenticada e com teste negativo. O buraco das rotas antigas nao e modelo.

## Premissas assumidas

- Nome unico por venue, depois do trim, no mesmo espirito de `Service` em `product/02-business-rules.md`. Risco se a premissa falhar: o operador nao cadastra dois itens com o mesmo rotulo. A execucao segue com `409`.
- Quem ja tem `VIEW_VENUE_SERVICES` ou `EDIT_VENUE_SERVICES` recebe o par correspondente de caracteristicas. Risco se a premissa falhar: quem so tem regras, e nao servicos, nao ganha a permissao nova no backfill e precisa recebe-la na tela de permissao.
- "Caracteristicas" e o rotulo de menu, de permissao e da pagina. `VenueAmenity` e `venue_amenity` ficam no codigo e no banco. Risco se a premissa falhar: o rotulo visivel muda; o contrato tecnico nao.
- Posicao repetida por corrida e aceitavel. A lista desempata por `createdAt`. Risco se a premissa falhar: a ordem de dois itens criados juntos fica estavel pela data, nao pela intencao do operador.

## Perguntas de erro e borda ainda abertas

- Nenhuma que mude o contrato. Limite de quantidade por venue nao foi pedido. Premissa: sem teto nesta entrega. Risco: um venue pode gravar uma lista longa; a tela lista tudo, como regras.

## Itens bloqueantes

- nenhum

## O que pode seguir mesmo com lacunas

- `T-01` a `T-04` seguem com as premissas acima
- trocar a fonte do site e da proposta fica para outro request
- owner da feature continua nao documentado e nao bloqueia o codigo
