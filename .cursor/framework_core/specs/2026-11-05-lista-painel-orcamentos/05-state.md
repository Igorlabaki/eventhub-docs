# State — Lista paginada de orcamentos no painel

## Snapshot

- status: codigo das quatro tasks escrito
- ultima task concluida: `T-04`
- task em andamento: nenhuma
- proxima task exata: nenhuma; falta a prova no browser
- prova mais recente: vitest 15 testes da listagem e do intervalo; `npx prisma validate` limpo; indice `proposal_venueId_startDate_idx` presente em `main`

## Delta da ultima task

- mudou: `GET /proposal/list` pagina, filtra em wall-clock e devolve `summary`; orcamentos e eventos consomem pagina de 10
- ficou pendente: a prova das duas telas no browser, com login
- lacunas de prova: mes, dia, busca, ordenacao, cards e pager ainda nao foram clicados na tela

## Decisoes recentes

- serie diaria usa `DATE_FORMAT` no DATETIME, nao `DATE()`, para o driver nao mudar o dia
- `summary=true` sem `page` responde 400
- loading de orcamentos e de eventos ficaram separados na store

## Riscos ou bloqueios

- deploy request 40 aplicado em `main` (`complete_pending_revert`); o diff so adiciona `KEY proposal_venueId_startDate_idx (venueId, startDate)`
- sem a prova no browser, a tela pode divergir da referencia

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote escrito; nao esta pronto para producao
- bloqueantes: prova manual das telas
- achados: `startDate` confirmado como `DATETIME(3)`
