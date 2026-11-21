# Clarify — Foto, video e descricao na caracteristica

## Perguntas criticas

- A descricao e obrigatoria?
- Foto e video podem coexistir?
- Onde o convidado ve o complemento?
- Qual link de video vale?
- O video e arquivo ou link?
- A foto entra em storage privado?

## Respostas confirmadas

- Pedido do chat de 2026-11-05: cada caracteristica aceita foto, link de video do YouTube e descricao.
- Chat de 2026-11-12:
  - o video e so um link; nao ha upload de arquivo de video
  - so links do YouTube valem
  - foto e video podem coexistir na mesma caracteristica
  - na proposta publica, o item com descricao, foto ou video ganha um "?" ao lado do nome; o clique abre um modal, no mesmo padrao dos servicos
  - o video aparece no modal como player do YouTube, sem autoplay

## Requisitos implicitos confirmados

- Autorizacao no backend, no venue da caracteristica.
- As colunas ja existem nulas no main; sem backfill.
- Pagina publica so ganha descricao, foto e video da caracteristica.
- O frontend continua em React Query e Zustand, sem uma terceira forma de estado.

## Premissas assumidas

- Descricao opcional, no maximo 500 caracteres, igual ao servico. Risco se estiver errado: texto longo demais e cortado.
- Uma foto, opcional. Risco se estiver errado: o usuario queria uma galeria por item.
- Link `https` do YouTube, inclusive Shorts e `youtu.be`. Risco se estiver errado: o usuario queria Vimeo ou outro host.
- A foto usa o mesmo bucket publico do servico, com URL aberta. Risco se estiver errado: o time queria objeto privado. Nao e o caso, porque a foto nasce para a proposta publica.
- O player tem controles e nao herda o autoplay mudo do tour. Risco se estiver errado: o video deveria tocar sozinho, sem som.
- A tabela do painel continua com posicao, nome e acoes. Risco se estiver errado: falta uma miniatura na lista.
- No formulario, foto e link sao campos independentes; escolher um nao limpa o outro.
- O modal reaproveita `PublicServiceDetailDialog` com uma prop opcional de video. Risco se estiver errado: o modal do servico muda de aparencia; a prop nova so tem efeito quando vem preenchida.

## Premissas descartadas em 2026-11-12

- "No maximo uma midia": foto e video agora coexistem.
- "Escolher uma foto limpa o campo do link, e digitar um link limpa o arquivo": os campos sao independentes.
- "Descricao e midia aparecem direto no card": o conteudo so aparece no modal do "?".

## Perguntas de erro e borda ainda abertas

- Nenhuma. Os casos de `01-spec.md` seguem com a cobertura indicada.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- A spec inteira. `T-01` pode comecar.
