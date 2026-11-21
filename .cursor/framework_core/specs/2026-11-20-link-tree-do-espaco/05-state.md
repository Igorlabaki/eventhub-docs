# State — link tree do espaco

## Snapshot

- status: `T-01` a `T-04` no codigo; falta review e a migration na `main`
- ultima task concluida: `T-04`
- task em andamento: nenhuma
- proxima task exata: nenhuma; o passo e `fw:review` da entrega
- prova mais recente: vitest back 15 (`venue-link` e o use case) e front 30 (checagem, abas, sidebar, allowlists, configuracoes); `npx prisma validate` ok

## Delta da ultima task

- mudou: tabela `venue_link`, GET publico, GET do editor, PUT, aba Redes, pagina `/espaco/:id/links` e item Link tree
- ficou pendente: deploy request na `main`; browser com login
- lacunas de prova: a pagina e a aba nao foram abertas no browser; a tabela nao existe no banco de producao

## Decisoes recentes

- o editor autenticado e `GET /venue/links/:venueId/editor`, para a leitura publica nao levar link oculto
- gravar exige `EDIT_VENUE_INFO`
- Salvar geral deixa de enviar as quatro colunas; o PUT dos links e quem as copia

## Riscos ou bloqueios

- sem a migration na `main`, o GET e o PUT falham no banco atual
- `EditVenueForm` da organizacao ainda grava as quatro colunas sem mexer na lista

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo das quatro tasks pronto para review
- bloqueantes: nenhum de spec; a `main` nao foi alterada
- achados: nenhum
