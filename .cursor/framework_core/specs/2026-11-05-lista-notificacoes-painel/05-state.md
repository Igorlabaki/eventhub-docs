# State — KPIs, filtros, paginas e leitura na lista de notificacoes

## Snapshot

- status: `T-01` a `T-04` escritas; prova de tela no browser pendente
- ultima task concluida: `T-04`
- task em andamento: nenhuma
- proxima task exata: nenhuma no codigo; falta a prova no browser
- prova mais recente: vitest backend 16 (lista 8, read-by-proposal 4, read-all 4); vitest frontend 2 no contrato da tela

## Delta da ultima task

- mudou: listagem com pagina, filtro e summary; `PATCH` de lida por orcamento e do espaco; tela sem `FilterList`; `ProposalDetails` chama a marcacao
- ficou pendente: filtros, cards, pager, selo e o botao no browser; abrir o orcamento no painel e voltar
- lacunas de prova: browser nao exercitado

## Decisoes recentes

- janela de 7 e 30 dias no helper `notificationSummaryWheres`, instante do servidor
- `GET /proposal/byId` segue sem repositorio de notificacao
- gravacao exige JWT na rota e `UserVenuePermission` antes do `updateMany`
- falha da marcacao no detalhe nao bloqueia o orcamento

## Riscos ou bloqueios

- nenhum bloqueio de codigo
- risco ativo: a tela ainda nao foi aberta com a API nova

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo das quatro tasks escrito; nao pronto para producao
- bloqueantes: nenhum
- achados: prova de browser pendente
