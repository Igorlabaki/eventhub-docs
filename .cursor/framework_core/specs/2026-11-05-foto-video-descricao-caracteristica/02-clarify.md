# Clarify — Foto ou video e descricao na caracteristica

## Perguntas criticas

- A descricao e obrigatoria?
- Foto e video podem coexistir?
- Onde o convidado ve o complemento?
- Qual link de video vale?
- A foto entra em storage privado?

## Respostas confirmadas

- Pedido do chat: cada caracteristica aceita uma foto ou um link de video do YouTube, e uma descricao.
- O request fechou as premissas abaixo para a execucao nao travar. Ninguem contradisse.

## Requisitos implicitos confirmados

- Autorizacao no backend, no venue da caracteristica.
- Migration aditiva, colunas nulas, sem backfill.
- Pagina publica so ganha descricao e midia da caracteristica.
- O frontend continua em React Query e Zustand, sem uma terceira forma de estado.

## Premissas assumidas

- Descricao opcional, no maximo 500 caracteres, igual ao servico. Risco se estiver errado: texto longo demais e cortado.
- No maximo uma midia, e as duas sao opcionais. Risco se estiver errado: o usuario queria foto e video juntos.
- O convidado ve o complemento no bloco "Conheça nosso espaço". Item sem complemento fica check e nome. Risco se estiver errado: o conteudo ficaria so no painel.
- Uma foto, opcional. Risco se estiver errado: o usuario queria uma galeria por item.
- Link `https` do YouTube, inclusive Shorts e `youtu.be`. Arquivo de video fica de fora. Risco se estiver errado: o usuario queria mp4.
- A foto usa o mesmo bucket publico do servico, com URL aberta. Risco se estiver errado: o time queria objeto privado. Nao e o caso, porque a foto nasce para a proposta publica.
- O player tem controles e nao herda o autoplay mudo do tour. Risco se estiver errado: o video deveria tocar sozinho, sem som.
- A tabela do painel continua com posicao, nome e acoes. Risco se estiver errado: falta uma miniatura na lista.
- Escolher uma foto limpa o campo do link, e digitar um link limpa o arquivo escolhido. Risco se estiver errado: o formulario teria de explicar os dois campos cheios em vez de impedir.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Os casos de `01-spec.md` seguem com a cobertura indicada.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- A spec inteira. `T-01` pode comecar.
