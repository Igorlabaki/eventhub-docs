# Clarify — Lista de servicos no painel

## Perguntas criticas

- O preco some da linha do painel? Nao. A entrada pede empilhar, o texto de obrigatorio e o campo de horas.
- O checkbox obrigatorio trava no minimo de pessoas? Sim. O link publico ja faz isso.
- Servico por hora obrigatorio pede horas? Sim.
- Qual numero vale? O mesmo da criacao publica: inteiro de 1 ate a duracao do evento. Zero so quando essa duracao e 0.
- A edicao abre com a quantidade gravada? Sim.
- Os dois formularios de criar entram? Sim, evento e pernoite.
- Existe tela de editar pernoite? Nao. A unica tela de editar chama a atualizacao por pessoa.

## Respostas confirmadas

- O modelo visual e a lista do link publico de criar orcamento, sem o icone de foto e descricao e com o preco que o painel ja mostra.
- A criacao ja aceita `serviceHours` e exige o item para cada servico por hora. O painel hoje manda a duracao do evento.
- A edicao por pessoa e por dia descarta `serviceHours` no Zod e cota pela duracao.
- A quantidade ja mora em `ProposalService.quantity`. Nao ha coluna nova.
- A frase de teto e "O serviço não pode ter mais horas do que o evento (N horas).". A frase de numero invalido e "Informe um número inteiro de horas para o serviço."

## Requisitos implicitos confirmados

- Desmarcar apaga as horas daquele id e nao as envia.
- O input fica fora do `label` do checkbox.
- Falha de envio conserva o que foi digitado.
- Servico fixo e por pessoa continuam sem campo de horas.
- Horario do evento permanece wall-clock. Dinheiro permanece `Float`.

## Premissas assumidas

- Ao cair abaixo do minimo, o servico destrava e continua marcado. Premissa copiada do link publico. Risco: se a operacao quiser desmarcar ao sair do minimo, a lista fica com um servico a mais ate alguem tirar.
- `PUT /updatePerDay` recebe as mesmas horas, embora nenhuma tela chame essa rota hoje. Risco: um cliente antigo dessa rota, se existir fora do painel, passa a falhar em servico por hora sem `serviceHours`.
- A ordenacao e a do link: menor minimo de pessoas primeiro; servico sem minimo fica por ultimo.
- No pernoite, o teto de horas usa check-in e check-out do espaco, como a criacao publica por dia. No evento e na edicao, usa inicio e fim do mesmo dia.

## Perguntas de erro e borda ainda abertas

Nenhuma. A execucao segue as premissas acima.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

A spec inteira. Nao ha lacuna de negocio que trave `T-01`.
