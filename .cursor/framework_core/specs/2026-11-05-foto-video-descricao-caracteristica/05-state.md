# State — Foto ou video e descricao na caracteristica

## Snapshot

- status: `T-01` a `T-04` no codigo; colunas no `main`; tela nao provada
- ultima task concluida: `T-04`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: deploy request 43; `description`, `imageUrl` e `videoUrl` nulos em `venue_amenity` no `main`

## Delta da ultima task

- mudou: descricao e uma midia no cadastro, no contrato publico e no bloco "Conheça nosso espaço"
- ficou pendente: gravar uma caracteristica real e abrir a proposta
- lacunas de prova: browser nao exercitado; `prisma migrate deploy` nao grava historico neste banco

## Decisoes recentes

- foto reusa o upload publico do servico; video so YouTube
- player `https://www.youtube.com/embed/{id}?rel=0`, sem autoplay
- colunas nascem nulas; linha antiga continua so com o nome

## Riscos ou bloqueios

- deploy request 43 ficou em `complete_pending_revert`; rollback e tirar as tres colunas enquanto a janela existir
- bloqueio de tela: o painel recente para no login

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum
- `product/08-data-model.md`: linha de `VenueAmenity` com descricao e midia

## Veredito

- veredito: lote entregue em L2; nao marcar pronto para producao
- bloqueantes: sessao do painel para criar foto e video
- achados: nenhum
