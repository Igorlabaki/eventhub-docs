# Clarify — Link publico das regras do espaco

## Perguntas criticas

- Onde se copia o endereco? Na tela Regras do painel. Confirmado pelo pedido.
- O Link do evento ganha o botao? Sim. Confirmado pelo pedido.
- A gravacao continua autenticada? Sim. A spec anterior deixa create, update, delete e `GET /list` fechados.

## Respostas confirmadas

- As regras ja cadastradas sao a fonte. Nao ha texto novo nesta feature.
- A pagina e do venue, porque a regra nao muda por orcamento.
- A rota autenticada `/venue/:id/rules` continua sendo o cadastro.

## Requisitos implicitos confirmados

- A resposta publica nao leva `createdAt`, `updatedAt`, `venueId` nem id de usuario. O `id` da regra fica so para a chave da lista e nao autoriza gravacao.
- O texto e no de texto. A pagina nao usa HTML cru.
- Quebra de linha do cadastro permanece visivel.
- Sem logo, cor ou descricao, a casca das listas publicas ja define o fallback.
- Ao sair da pagina, a aba volta ao titulo EventHub, como a casca ja faz.

## Premissas assumidas

- O endereco e `/venue/:id/rules/view`. Risco: se a operacao quiser o link debaixo do orcamento, o botao do Link do evento continua certo e o canonico muda de lugar.
- O botao do Link do evento so aparece quando a leitura do orcamento devolve `venueId`. Risco: falha ao carregar o orcamento deixa os cinco destinos e omite as regras.
- Nao ha limite novo de taxa. Risco: o texto passa a ser legivel por quem tiver o id do espaco, no mesmo patamar do formulario publico.
- Quem abre a tela Regras copia o link, inclusive sem `EDIT_VENUE_RULES`. Risco: quem so consulta tambem divulga o endereco. O dado ja e o que a pagina publica mostra.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Venue vazio, titulo vazio, venue alheio, token ausente na gravacao e falha ao copiar ja tem premissa acima e criterio em `01-spec.md`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01`, `T-02` e `T-03` seguem com o endereco `/venue/:id/rules/view` e o contrato de `03-design.md#Contratos e dados`.
