# Clarify — Ate tres fotos na caracteristica

## Perguntas criticas

- Quantas fotos?
- Onde reordenar?
- Como o modal publico mostra as fotos?
- O que acontece com a foto que ja existe?
- A pagina publica antiga quebra entre o deploy da API e o do front?

## Respostas confirmadas

- Chat de 2026-11-13:
  - no maximo 3 fotos por caracteristica
  - reordenar tudo no criar e no editar da caracteristica
  - no modal publico, as fotos em grid
- Leitura da `main` em 2026-11-13 (`--role reader`): 10 caracteristicas, 1 com `imageUrl`.
- Backend da spec anterior commitado; `git status` limpo em `art56_server_v3`.
- Frontend com a navegacao entre caracteristicas no modal escrita e nao commitada (`PublicServiceDetail.tsx`, `ProposalView.tsx`, `amenity-video.ts` e testes).

## Requisitos implicitos confirmados

- Autorizacao no backend antes de qualquer upload.
- Migration de producao aditiva; a coluna `imageUrl` fica.
- Pagina publica so recebe URL e ordem das fotos.
- Frontend segue com Zustand na caracteristica, sem terceira forma de estado.

## Premissas assumidas

- Reordenar com botoes de mover para a esquerda e para a direita em cada miniatura. Risco se estiver errado: o usuario queria arrastar; da para trocar so a UI depois.
- Clicar na foto do grid nao amplia. Risco: o usuario espera ver a foto grande; vira pedido proprio.
- Sem legenda por foto. Risco: falta texto por foto; a descricao da caracteristica continua.
- A foto atual vira a primeira por uma copia unica de `imageUrl` para a tabela nova, feita com aprovacao nomeada. Risco: sem a copia, a 1 caracteristica com foto aparece sem foto ate alguem reenviar.
- A API para de ler e gravar `venue_amenity.imageUrl`. Risco: alguma leitura esquecida mostrar a URL antiga; a busca por `imageUrl` no backend fecha isso.
- A apresentacao publica devolve `imageUrl` (primeira foto) junto de `images` para a pagina antiga seguir funcionando entre o deploy da API e o do front. Risco: campo redundante; sai junto da coluna numa limpeza futura.
- O painel nao tem compatibilidade com o contrato antigo (`file` e `removeImage`). API e front do painel saem em sequencia curta. Risco: quem salvar uma caracteristica nessa janela recebe 400.
- A ordem das fotos novas no criar e a ordem dos arquivos; o criar nao recebe `images`. Risco: nenhum, o front monta os arquivos ja na ordem da tela.

## Premissas descartadas

- Fallback de leitura (usar `imageUrl` quando a tabela nova estiver vazia): duas fontes da mesma foto e reordenacao com item sem id. A copia unica e mais simples para 1 linha.
- `upload.fields` aceitando `file` e `files` para compatibilidade do painel: a janela e curta e o uso e interno.
- Carrossel no modal: o usuario escolheu grid; carrossel tambem brigaria com o deslizar entre caracteristicas.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Os casos de `01-spec.md` seguem com a cobertura indicada.

## Itens bloqueantes

- Nenhum para `T-01` a `T-03`.
- `T-05` mexe nos mesmos arquivos da navegacao nao commitada: commitar a navegacao antes, ou executar `T-05` em cima dela sem descartar o diff.
- `T-06` depende de aprovacao nomeada para o deploy request na `main` e para a copia da foto.

## O que pode seguir mesmo com lacunas

- `T-01` pode comecar.
