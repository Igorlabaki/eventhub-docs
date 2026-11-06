# Clarify — Limite de horas do servico

## Perguntas criticas

- Qual frase exata, e ela inclui a duracao?
- Igual a duracao vale?
- O painel ganha o campo?
- Orcamento antigo ou o recalculo corrigem sozinhos uma quantidade acima da duracao nova?
- A frase de inteiro muda?

## Respostas confirmadas

- Pedido em chat: nem no modal "Adicionar servico" nem na criacao do orcamento da para informar mais horas do que o evento dura. Se informar, a mensagem ja aparece dizendo isso.
- A spec de horas escolhidas ja fixou que o painel nao pede horas e que mudar o horario no link nao substitui a quantidade gravada.

## Requisitos implicitos confirmados

- A tela nao substitui a API publica. Confirmado por D-05 e pelo pedido de nao gravar.
- A duracao do teto e a mesma conta de horas inteiras da cotacao, inclusive pernoite. Confirmado por D-06 e por `calcEventDuration`.
- Vazio, zero, fracao e negativo continuam invalidos como hoje.

## Premissas assumidas

- A frase e "O serviço não pode ter mais horas do que o evento (N horas)." Com N igual a 1, "1 hora". Risco se estiver errada: a execucao troca a copia nos dois repositorios.
- Igual a duracao grava. Risco se estiver errada: o cliente nao consegue pedir o servico pelo evento inteiro.
- O painel nao ganha campo. Risco se estiver errada: falta um input na criacao autenticada.
- Orcamento ja salvo e o recalculo publico nao reescrevem a quantidade. Risco se estiver errada: encurtar o evento deixa a linha mais cara do que a duracao nova.
- A frase antiga de inteiro permanece para o que nao e inteiro de 1 a 8760. Risco se estiver errada: o campo mostra a frase de duracao tambem para texto vazio ou fracao.
- No formulario por pessoa, intervalo incompleto ou com fim anterior ao inicio nao mostra a frase de duracao. Risco se estiver errada: a pessoa ve um teto de pernoite que esse formulario nao aceita enviar.
- No formulario por dia, o teto usa check-in do primeiro dia e check-out do ultimo, com o fallback que o formulario ja envia (`14:00` e `12:00`). Risco se estiver errada: a tela usa um intervalo diferente do que a API vai medir.

## Perguntas de erro e borda ainda abertas

Nenhuma. As premissas acima fecham a execucao.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

Tudo. A copia da frase e a unica escolha de produto, e a premissa acima e a que a execucao usa.
