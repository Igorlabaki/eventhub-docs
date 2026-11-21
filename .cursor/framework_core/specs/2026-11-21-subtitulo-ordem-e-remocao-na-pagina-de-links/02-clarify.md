# Clarify — Subtitulo, ordem e remocao na pagina de links

## Perguntas criticas

Nenhuma bloqueante. As duas lacunas do chat ficam com premissa abaixo.

## Respostas confirmadas

- O subtitulo fica embaixo do titulo do botao que a pagina ja mostra.
- A ordem muda na propria pagina, do jeito das fotos: alca, arraste, gravacao na hora, visitante sem controle.
- Remover pergunta "Tem certeza que quer remover?". Cancelar mantem o botao.
- Quem edita as fotos e quem tem `EDIT_VENUE_SITE` naquele espaco. Esta pagina usa o mesmo criterio, nao "qualquer login" e nao o `EDIT_VENUE_INFO` da aba Redes.

## Requisitos implicitos confirmados

- `GET /venue/links/:venueId` hoje nao le usuario e nao devolve `canReorder`. A apresentacao ja faz isso com `readOptionalUserId` e `canEditVenueSite`.
- O `PUT /venue/links/:venueId` da aba Redes troca a lista, exige `EDIT_VENUE_INFO` e nao serve para a pagina.
- Link com `visible` falso ja nao entra em `publicVenueLinks`.
- `/espaco/:id/links` e `/venue/:id/links` ja estao em `PUBLIC_ROUTES`. Um 401 nessa tela nao manda para `/login`.
- O axios manda `Authorization` quando ha token, inclusive em rota publica.

## Premissas assumidas

- Frases do subtitulo: o chat nao trouxe os textos. Premissa: a tabela de `03-design.md#Subtitulos`, frase fixa por tipo, sem campo e sem edicao. Premissa errada so troca o mapa. Nao vira coluna.
- "Omite da pagina": esconde (`visible` falso). A linha fica. O olho da aba Redes mostra de novo. Premissa errada pediria apagar a linha, o que esta fora de escopo e quebraria o link colado sem a lixeira da aba.
- Duas gravacoes ao mesmo tempo: a ultima vence, como nas fotos. Premissa errada pediria lock. Nao ha esse pedido.

## Perguntas de erro e borda ainda abertas

Nenhuma.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

`T-01` pode comecar depois do review. `T-02` espera `T-01` porque os dois mexem no mesmo use case. `T-03` espera o contrato dos dois.
