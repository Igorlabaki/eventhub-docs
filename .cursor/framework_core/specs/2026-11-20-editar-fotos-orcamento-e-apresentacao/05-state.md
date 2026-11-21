# State — Reordenar e trocar fotos no orcamento e na apresentacao

## Snapshot

- status: `T-01` a `T-03` no codigo, review de entrega pendente
- ultima task concluida: `T-03`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest backend dos specs de apresentacao, escolha, ordem e fotos do espaco; vitest frontend `public-photo-edit` 4 e `venue-presentation` 7; `tsc` do frontend sem erro

## Delta da ultima task

- mudou: alca e Trocar foto saem do mesmo componente no orcamento e na apresentacao; a apresentacao grava nos `PUT` do espaco
- ficou pendente: browser com sessao de Site
- lacunas de prova: arrastar e trocar no browser nao foi exercitado

## Decisoes recentes

- Site (`EDIT_VENUE_SITE`) segue como unica permissao desta edicao
- catalogo da apresentacao sai de uma segunda leitura, so com Site
- `PUT` da apresentacao e do espaco, nao de um orcamento

## Riscos ou bloqueios

- nenhum bloqueio
- risco aberto: vazar foto oculta no `GET` publico; os testes cobrem o corpo sem a url

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote no codigo, falta review de entrega
- bloqueantes: nenhum
- achados: browser nao exercitado
