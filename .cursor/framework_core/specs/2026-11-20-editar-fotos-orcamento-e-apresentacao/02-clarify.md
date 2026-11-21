# Clarify — Reordenar e trocar fotos no orcamento e na apresentacao

## Perguntas criticas

Nenhuma em aberto. As decisoes abaixo vieram do pedido e do codigo atual.

## Respostas confirmadas

- As tres paginas fazem as duas coisas: ordem e troca.
- Quem edita e quem tem `EDIT_VENUE_SITE` naquele espaco. Quem criou o espaco ja tem. Outra pessoa so tem se a permissao foi concedida.
- Cliente no link e visitante da apresentacao nao editam e nao recebem o catalogo.
- O layout de cada pagina permanece. Os controles entram nas fotos que a pagina ja mostra.
- A galeria e a do espaco. Uma mudanca numa pagina vale para as outras.

## Requisitos implicitos confirmados

- A URL antiga ja usa `canReorder` e o catalogo so quando `canEditVenueSite` e verdadeiro. Esta feature repete essa regra, nao cria outra.
- A biblioteca de fotos usa `EDIT_VENUE_PHOTOS`. A troca no link publico nao passa a usa-la.
- O axios ja envia `Authorization` quando ha token, inclusive nas rotas de `PUBLIC_ROUTES`. O `GET` publico le o usuario se o token existir (`readOptionalUserId`).
- 401 numa rota publica nao manda o browser para `/login`.

## Premissas assumidas

- `canReorder` e `catalog` passam a existir sempre na apresentacao do espaco, como ja existem no orcamento: `false` e `[]` para quem nao edita. Premissa errada so obrigaria o frontend a tratar campo ausente; o visitante continuaria sem controles.
- Duas edicoes ao mesmo tempo: a ultima gravacao vence, como o orcamento ja faz. Premissa errada pediria lock; nao ha esse pedido.
- Arrastar na apresentacao reordena a lista de fotos visiveis e a pagina recalcula hero, foto solta e grid. Premissa errada mudaria o desenho da pagina, que esta fora de escopo.
- O `PUT` do orcamento tambem aceita o codigo publico, nao so o id. O frontend pode continuar mandando o id ja resolvido. Premissa errada deixaria a troca da URL nova dependente do id na mao do cliente.

## Perguntas de erro e borda ainda abertas

Nenhuma.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

`T-01` pode comecar depois do review. Nao depende de `T-02`.
