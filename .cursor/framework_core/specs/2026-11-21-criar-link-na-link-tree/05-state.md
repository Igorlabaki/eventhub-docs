# Estado — criar link na link tree

## Snapshot

- status: `T-01`, `T-02` e `T-03` no codigo
- ultima task concluida: `T-03`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest back 23 no use case de links; vitest front 7 no editor e 11 na pagina publica

## Delta da ultima task

- mudou: a publica ganhou o botao, o container vazio e o `PUT` create
- ficou pendente: browser das duas telas
- lacunas de prova: nenhuma suite pedida ficou de fora; o browser nao foi aberto

## Decisoes recentes

- o write novo ficou em `PUT /venue/links/:venueId/create` com `EDIT_VENUE_SITE`
- a aba troca o select por "Cadastrar link" e so grava em Salvar Alteracoes
- a mensagem de falha do create fica no modal via `CreateLinkError`

## Riscos ou bloqueios

- nenhum bloqueio
- `PUBLIC_ROUTES` continua sem `links`; um 401 nesta pagina ainda pode ir para `/login`

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md#Demais paginas publicas`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote executado; nao esta pronto para producao
- bloqueantes: nenhum
- achados: a prova pedida e unitaria; o browser ficou para a review
