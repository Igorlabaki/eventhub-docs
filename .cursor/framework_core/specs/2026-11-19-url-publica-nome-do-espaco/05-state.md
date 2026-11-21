# State — URL publica pelo nome do espaco

## Snapshot

- status: `T-01` e `T-02` no codigo; review de entrega pendente
- ultima task concluida: `T-02`
- task em andamento: nenhuma
- proxima task exata: nenhuma; proximo passo e `fw:review` + `entrega`
- prova mais recente: vitest back 14 (6 getById + 8 apresentacao) e front 17; API local `AR756` e o UUID abrem; nome ausente 404; browser `/venue/AR756/apresentacao` e `/venue/AR756/form` mostram a AR756

## Delta da ultima task

- mudou: links usam o nome; o formulario passa `venue.id` para servicos e criacao
- ficou pendente: publicar a API antes do frontend
- lacunas de prova: o envio do formulario nao foi disparado no browser, porque gravaria um orcamento real; o id saiu no teste de `venueIdForPublicForm`

## Decisoes recentes

- chave UUID busca so por id; nome usa `findUnique` por `name`
- `getById` com `userId` nao resolve nome
- sem migration e sem endpoint novo

## Riscos ou bloqueios

- publicar a API antes do frontend, senao o link com nome responde 404
- `getById` publico continua devolvendo `contracts` e `attachments`

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md#Pedido de orcamento` e `#Demais paginas publicas`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo das duas tasks feito; nao esta pronto para producao
- bloqueantes: nenhum para a review
- achados: o formulario no browser carregou a AR756 pelo nome; o POST de criacao ficou so no teste
