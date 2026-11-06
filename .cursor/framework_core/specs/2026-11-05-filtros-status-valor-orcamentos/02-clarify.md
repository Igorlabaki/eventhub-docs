# Clarify — Filtros de status e valor na lista de orcamentos

## Perguntas criticas

- O arraste e um ponto ou uma faixa com dois pontos?
- O Valor no mes acompanha busca, status e arraste?
- O piso e o preco minimo padrao ou o minimo do periodo?

## Respostas confirmadas

- Nenhuma resposta nova do dono depois do request. A execucao segue as premissas abaixo.

## Requisitos implicitos confirmados

- Fechado (`approved` verdadeiro) e o que virou evento. Nao ha outro estado para isso.
- Total de orcamentos e conversao continuam o funil do filtro da tabela.
- A lista de eventos ja pede `approved=true` e nao usa `summary`.

## Premissas assumidas

- O arraste tem um ponto. Comeca no preco minimo padrao do espaco. No piso, a lista nao envia `minAmount`, entao orcamento mais barato que o minimo continua visivel. Ao soltar acima do piso, a lista pede `totalAmount` maior ou igual ao ponto. Risco se a premissa estiver errada: o piso ja esconderia o que esta abaixo do minimo da casa.
- O trilho vai ate `amountMax`, o maior `totalAmount` do mes ou do dia, sem busca, status ou arraste. Sem linha, `amountMax` e 0 e o controle nao se move. Risco se a premissa estiver errada: o teto acompanharia o filtro e encolheria enquanto a pessoa arrasta.
- Valor no mes e o grafico desse card somam so o aprovado na janela de mes ou dia. Ignoram busca, status e arraste. Risco se a premissa estiver errada: escolher Aberto zeraria o card.
- Total e conversao acompanham o filtro da tabela, inclusive status e arraste, e ignoram a pagina. Risco se a premissa estiver errada: os tres cards ficariam congelados no mes.
- O passo do arraste e 1 real. Risco se a premissa estiver errada: a pessoa esperaria centavos.
- Trocar mes, ano ou dia devolve o arraste ao piso. O status escolhido permanece. Risco se a premissa estiver errada: um minimo do mes anterior esvaziaria o mes novo.
- O filtro de valor sai no soltar, nao a cada pixel. Risco se a premissa estiver errada: a tabela deveria acompanhar o dedo o tempo todo.

## Perguntas de erro e borda ainda abertas

- Nenhuma que bloqueie. Os casos de piso, dia, mes sem evento e `amountMax` no piso estao em `01-spec.md#Casos de erro e borda obrigatorios`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- A execucao inteira. As premissas acima fecham o contrato e a tela.
