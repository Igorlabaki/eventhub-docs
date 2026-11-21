# Estado — De onde vem os eventos

## Snapshot

- status: `T-01` a `T-03` no codigo; browser da aba EVENTO pendente
- ultima task concluida: `T-03`
- task em andamento: nenhuma
- proxima task exata: nenhuma; review de entrega so se o humano pedir
- prova mais recente: vitest back 5 + 11; vitest front 4; `npm run build` do frontend ok

## Delta da ultima task

- mudou: `buildEventOrigin`, `GET /venue/reports/event-origin`, card na aba EVENTO, linha em `api-endpoints.md` e paragrafo em `topics/reports-and-kpis.md`
- ficou pendente: abrir a aba EVENTO no browser com a API no ar
- lacunas de prova: sem servidor local nesta sessao; 401 da rota sem token nao foi chamado de verdade

## Decisoes recentes

- lote executado sem a review previa e sem `fw:split`; o pedido foi executar as tres tasks
- linha incompleta continua fora dos tres rankings
- card usa `EventOriginView` para o teste estatico; `originCardRetry` liga o botao ao `refetch`

## Riscos ou bloqueios

- nenhum bloqueio
- KPI "Total de eventos" pode ficar maior que `events` deste card se houver proposta aprovada sem os tres campos

## Memoria promovida

- topics atualizados: `topics/reports-and-kpis.md#Blocos agregados`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo das tres tasks entregue; nao esta pronto para producao
- bloqueantes: nenhum
- achados: browser nao exercitado
