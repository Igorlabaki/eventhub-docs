# State — Subtitulo, ordem e remocao na pagina de links

## Snapshot

- status: `T-01` a `T-03` no codigo; review de entrega nao rodada
- ultima task concluida: `T-03`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest back 21 (`venue-link` e use case); vitest front 8 (`VenueLinks.test.tsx`)

## Delta da ultima task

- mudou: a pagina mostra o subtitulo, a alca e o Remover com confirmacao; os `PUT` de ordem e de ocultar exigem Site
- ficou pendente: browser com sessao de Site
- lacunas de prova: arrastar, cancelar e confirmar no browser nao foram exercitados

## Decisoes recentes

- subtitulo no mapa do backend; a pagina so renderiza
- ordem e ocultar nao usam o save da aba Redes
- confirmar esconde; a linha fica

## Riscos ou bloqueios

- nenhum bloqueio
- risco: o browser ainda nao mostrou alca, dialogo e gravacao

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md#Demais paginas publicas`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote executado; falta review de entrega se o usuario pedir
- bloqueantes: nenhum
- achados: vitest verde; browser pendente
