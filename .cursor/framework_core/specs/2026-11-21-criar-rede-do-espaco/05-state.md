# State — Criar a rede do espaco

## Snapshot

- status: `T-01` e `T-02` no codigo, sem review
- ultima task concluida: `T-02` — select, modal, linha verde e lapis
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest back 28 (funcao 12, use case 16); vitest front 13 (lib 6, editor 7); `npm run build` do front ok

## Delta da ultima task

- mudou: a leitura ignora rede sem URL verde; destino gerado grava `created`; a aba cria pelo select, edita no lapis e pinta de verde so quem esta no link tree
- ficou pendente: review de entrega; o browser da aba Redes nao foi aberto
- lacunas de prova: nenhum clique real no modal; o `GET` publico nao foi chamado no localhost

## Decisoes recentes

- `createVenueLink` recebe `name` e `source` para decidir se o destino gerado nasce visivel
- o marcador nao aparece na coluna Link
- a lixeira vale para toda rede criada, inclusive Apresentacao

## Riscos ou bloqueios

- quem usava o padrao perde Apresentacao, orcamento e regras no link tree ate criar de novo
- uma aba de Configuracoes aberta antes desta mudanca ainda pode gravar a lista antiga

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md#Demais paginas publicas`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote executado; nao esta pronto para producao
- bloqueantes: nenhum
- achados: o portal do modal nao entra no markup estatico; o formulario da URL foi provado fora do `Dialog`
