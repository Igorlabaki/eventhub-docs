# State

## Snapshot

- status: `T-01` e `T-02` no codigo; build ok
- ultima task concluida: `T-02`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest 14 verde e `npm run build` ok em 2026-11-21

## Delta da ultima task

- mudou: aba Redes com faixa, KPIs, tabela e arraste; pagina publica em card; topic da pilula atualizado
- ficou pendente: ver os cards no browser com a API no ar
- lacunas de prova: browser em `/espaco/AR756/links` mostrou so "Nao foi possivel carregar os links"; a aba Redes nao foi aberta no painel

## Decisoes recentes

- KPIs e o recorte filtrado ficam em `venueLinkSummary` e `venueLinkView`
- arraste desligado fora da lista inteira
- card publico sem descricao, uma coluna, cor do card do evento

## Riscos ou bloqueios

- a pagina publica local nao carregou o `GET`, entao o card nao foi visto no browser

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md#Demais paginas publicas`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo das duas tasks entregue; vitest e build ok; browser da pagina publica sem dados
- bloqueantes: nenhum de spec
- achados: vitest cobre o editor e o card; o browser local nao trouxe os links
