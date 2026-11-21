# State — Biblioteca de fotos do espaco

## Snapshot

- status: codigo das tasks no painel; nao pronto para producao
- ultima task concluida: `T-08`
- task em andamento: nenhuma
- proxima task exata: nenhuma; revisar entrega (`fw:review`)
- prova mais recente: vitest front 20 (sidebar, picker, amenity); `tsc --noEmit` e `vite build` ok; browser do painel parou no login

## Delta da ultima task

- mudou: item "Fotos" em "A casa", rota `/venue/:id/photos`, `PhotoPicker`, site/servico/caracteristica/e-mail gravam `photoId` ou `backgroundPhotoId`
- ficou pendente: abrir a pagina logado; commit e publicacao
- lacunas de prova: login bloqueou o browser; proposta e hub continuam escolhendo linhas `image` (o contrato delas e o id da imagem, nao o da biblioteca)

## Decisoes recentes

- "enviar nova" so aparece com `EDIT_VENUE_PHOTOS`
- upload da organizacao no `image-form` continua com arquivo
- troca de foto da proposta e selecao do hub nao viraram `PhotoPicker`: as duas APIs gravam ids de `image`

## Riscos ou bloqueios

- revert do deploy request `#50` ainda aberto
- painel novo ainda nao foi aberto com um usuario permitido

## Memoria promovida

- topics atualizados: `permissions-catalog.md` (enum e sidebar)
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum
- tambem: nenhum documento novo de contrato; a decisao da proposta/hub fica neste state

## Veredito

- veredito: `T-04` a `T-08` no codigo; nao marcar pronto para producao
- bloqueantes: prova logada da pagina Fotos
- achados: build e tipos passaram; a tela de login impediu clicar em Fotos
