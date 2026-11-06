# Clarify — Painel de metas e precos

## Perguntas criticas

- De onde sai a meta anual? Premissa embaixo. Risco se estiver errada: o resumo mostra um total que o operador nao reconhece.
- O painel mostra so o primeiro card, como a imagem? Premissa: nao. Risco: a imagem e uma amostra de um item e a tela mostrara ate tres.
- As ilustracoes e o grafico de barras sao obrigatorios? Premissa: nao. Risco: a tela fica sem a arte da imagem e sem barras decorativas.
- Qual e a frase do vazio? Premissa: "Nada configurado". Risco: o texto diverge do que foi pedido.

## Respostas confirmadas

- A entrada pede a composicao da primeira imagem e uma mensagem quando o bloco nao foi configurado.
- Nao ha campo de meta anual. A meta guardada tem `minValue`, `maxValue` opcional, `increasePercent` e `months`.
- O piso padrao e `venue.minimumPrice`. As faixas vem da spec `precos-minimos-por-periodo`.
- A rota ja exige `VIEW_VENUE_PRICES`. A edicao ja exige `EDIT_VENUE_PRICES`.
- O produto cita metas como configuracao do espaco em `product/04-user-journeys.md`. Esta feature nao muda esse passo.
- O estado da tela continua nas stores Zustand que `VenueGoals` ja usa. `topics/frontend-application.md` nao admite outra camada.

## Requisitos implicitos confirmados

- valor em BRL cheio, como a tela ja formata
- Ver todos abre a aba correspondente que ja existe
- loading, vazio, erro e dados sao estados distintos (`design/rules/05_component_states_and_variants.md#Estados de tela com dados`)
- o vazio explica e, para quem pode editar, oferece o proximo passo
- o resumo responde as cinco perguntas da referencia, sem variacao inventada (`design/rules/07_data_display_and_dashboards.md#Numeros e KPIs`)

## Premissas assumidas

- Meta anual = soma de `minValue` × meses validos de cada meta. Mes fora de 1–12 nao conta. Meta sem mes valido soma zero e continua na lista.
- Sem nenhuma meta, o card Meta anual diz "Nada configurado".
- Preco atual sem modelo, sem valor, ou com valor menor ou igual a zero, diz "Nada configurado".
- Contagem zero de adicional ou desconto diz "Nada configurado", nao o numero 0.
- `minimumPrice` ausente, nulo ou menor ou igual a zero diz "Nada configurado". Faixa cadastrada nao preenche esse card.
- Amostra de ate 3 itens por secao. O restante fica em Ver todos.
- A frase visivel do vazio e "Nada configurado". Com permissao de editar, a acao atual da secao fica junto (Nova Meta, Novo Adicional, Nova faixa, Novo Desconto, Editar no modelo).
- Icone e fundo suave substituem a ilustracao. Nao ha grafico de faturamento.
- Subtitulos da referencia: "O modelo de preço atual para o espaço.", "Acompanhe a meta de faturamento do espaço.", "Valores adicionais aplicados em períodos específicos.", "Valores mínimos aplicados ao espaço.", "Descontos configurados para períodos e condições específicas."
- O botao da secao se chama "Ver todos", inclusive em Metas.

## Perguntas de erro e borda ainda abertas

- A store de adicional e desconto compartilha `isLoading` e `error`. Premissa: o painel obedece esse estado compartilhado e nao separa as duas listas. Risco: uma falha esconde a outra lista. Nao entra nesta feature separar a store.

## Itens bloqueantes

- nenhum

## O que pode seguir mesmo com lacunas

- a execucao segue pelas premissas acima
- a arte da imagem nao precisa existir no repositorio
