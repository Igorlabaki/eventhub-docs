# State — Cadastro das redes e consumo por venue_link

## Snapshot

- status: tasks no codigo; review pendente
- ultima task concluida: `T-06`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest do dashboard (link tree, icones, pagina publica, sidebar) 31; `npm run build` do dashboard; browser de `/espaco/AR756/links` e `/apresentacao`

## Delta da ultima task

- mudou: `T-04` abre `/venue/:id/link-tree` no painel e grava `{ kind, visible }`; `T-05` monta Instagram, Facebook, TikTok, site e WhatsApp do icone pela lista; `T-06` tira Cadastrar, alca e Remover da pagina publica
- ficou pendente: review de entrega
- lacunas de prova: sem banco real; Guaeca nao tem vitest (o teste le o `Footer.tsx`); tela interna e paginas logadas nao foram abertas no browser

## Decisoes recentes

- a tela interna nao reusa `/venue/:id/links`; o item da sidebar aponta para `/venue/:id/link-tree`
- `fetchVenueById` anexa `links` com `GET /venue/links`, porque `getById` nao traz a lista resolvida
- quem nao tem `EDIT_VENUE_SITE` ve so os links visiveis do GET e nao chama o PUT
- o botao de visita e o contato da Guaeca continuam no `whatsappNumber`; o icone de rede usa o href da lista
- o player do tour continua em `tourVideoUrl`

## Riscos ou bloqueios

- nenhum bloqueio
- casa que nunca abriu os links ainda depende do GET para copiar o legado; o carregamento do espaco agora dispara esse GET
- contato, parceiro e organizacao nao foram alterados

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md` no trecho de `/espaco/{casa}/links`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: `T-04` a `T-06` no codigo, com teste; lote encerrado sem review
- bloqueantes: nenhum
- achados: nenhum
