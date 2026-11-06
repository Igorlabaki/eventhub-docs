# State — Caracteristicas do espaco

## Snapshot

- status: `T-01` a `T-04` implementadas; prova manual do painel pendente
- ultima task concluida: `T-04`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: `prisma validate` ok; migrations `venue_amenity` e backfill aplicadas no MySQL local; vitest 5 testes verdes; `npm run build` ok

## Delta da ultima task

- mudou: tabela, permissao, API `/venue-amenity` e tela `/venue/:id/amenities`
- ficou pendente: criar, editar e remover no painel com um usuario real
- lacunas de prova: fluxo manual no browser; `npm run lint` do frontend continua falhando em arquivos antigos, sem erro novo nesta tela

## Decisoes recentes

- nome unico por venue, conferido no use case antes de gravar, com 409
- backfill so em quem ja tem a permissao de servicos correspondente
- textos `area: "amenities"` nao foram migrados

## Riscos ou bloqueios

- nenhum bloqueio
- update e delete autorizam o `venueId` gravado no item

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote executado; nao esta pronto para producao enquanto o painel nao for provado
- bloqueantes: nenhum
- achados: a tela segue o cadastro de regras; a prova que falta e o clique no painel
