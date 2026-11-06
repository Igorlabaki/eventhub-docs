# State — Precos minimos por periodo

## Snapshot

- status: codigo das quatro tasks no workspace; prova da tela ainda nao rodou no browser
- ultima task concluida: `T-03` com Vitest; `T-04` implementada, sem passagem manual
- task em andamento: nenhuma
- proxima task exata: nenhuma; falta abrir Metas e Precos logado e salvar padrao mais dezembro
- prova mais recente: `npx prisma validate` ok; migration `20261102203900_add_minimum_price_period` aplicada no MySQL local; Vitest 19 testes (faixa, piso e updates de orcamento)

## Delta da ultima task

- mudou: tabela `minimum_price_period`, CRUD em `/minimumPricePeriod` com `VIEW_VENUE_PRICES` e `EDIT_VENUE_PRICES` no venue, `resolveVenueMinimumPrice` nos ramos automaticos, aba Minimos e resumo no painel
- ficou pendente: exercitar a aba no browser
- lacunas de prova: sem sessao logada para criar dezembro e recarregar a tela; `tsc` do frontend nao acusou os arquivos novos

## Decisoes recentes

- piso da data usa `isWallClockDayInRange`, nao `date-fns` local
- total digitado na criacao por dia nao sobe mais ao piso; o ramo automatico sobe
- `migrate deploy` local tambem aplicou as migrations pendentes de Google Calendar que ainda nao estavam neste banco

## Riscos ou bloqueios

- o update de venue trata minimo `0` como ausente e mantem o valor anterior
- o request de adicionais na edicao ainda mexe nos mesmos use cases

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum
- produto: `product/07-domain-model.md` e `product/04-user-journeys.md`

## Veredito

- veredito: entrega sem review
- bloqueantes: prova manual da aba
- achados: nenhum review
