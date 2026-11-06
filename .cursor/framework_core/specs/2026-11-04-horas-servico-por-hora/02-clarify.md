# Clarify — Horas escolhidas no servico por hora

## Perguntas criticas

- O campo aparece no painel? Nao. Premissa do request: o painel continua com a duracao do evento.
- Servico por hora obrigatorio pede horas? Sim.
- Qual numero vale? Inteiro de 1 a 8760 no cliente. Zero so sobrevive quando a duracao do evento tambem e 0.
- Recalcular dia, convidados ou horario troca as horas do servico? Nao, se a quantidade ja estiver gravada.
- Orcamento antigo muda sozinho? Nao.

## Respostas confirmadas

- O rotulo "/hora" ja vem de `pricingType === "PER_HOUR"` nos formularios publicos.
- A quantidade ja tem coluna em `ProposalService.quantity`. Nao ha migration.
- A criacao por pessoa e por dia e publica e compartilhada com o painel. Exigir `serviceHours` nessa rota sem atualizar o painel quebra a criacao de servico por hora no painel.
- A edicao autenticada usa outras rotas e pode continuar sem o campo.
- A resposta publica de servicos esconde `pricingType`, `price` e `unitPrice`. O modal precisa de um booleano, nao do unitario.
- `calcEventDuration` devolve horas inteiras, arredondadas para baixo, com pernoite.

## Requisitos implicitos confirmados

- O servidor e quem grava a quantidade. O input sozinho nao altera o total.
- Desmarcar nao envia as horas daquele id.
- O unitario da linha nova sai do cadastro. O unitario de uma linha que ja estava no orcamento nao e trocado so porque as horas mudaram.
- Dinheiro permanece `Float`. Horario permanece wall-clock.

## Premissas assumidas

- Teto tecnico de 8760 horas. Nao e regra comercial. Risco se estiver errado: um servico continuo acima de um ano nao entra por esta rota.
- Zero e recusado quando o evento dura uma hora ou mais. Risco se estiver errado: o painel deixa de gravar linha zerada num evento que comeca e termina na mesma hora. A excecao cobre esse caso.
- O painel envia a duracao ja calculada no frontend, espelhando `calcEventDuration`. Risco se estiver errado: pernoite gravado com um numero diferente do que a edicao autenticada usaria. O teste do pernoite fecha essa conta.
- `hourly` na leitura publica nao revela a tabela de preco. Risco se estiver errado: o modal nao sabe em qual linha abrir o campo.

## Perguntas de erro e borda ainda abertas

- Nenhuma. A execucao segue pelas premissas acima.

## Itens bloqueantes

- Nenhum para revisar e executar `T-01`.

## O que pode seguir mesmo com lacunas

- Nao ha lacuna de negocio aberta. O review pode ajustar o teto 8760 sem redesenhar o fluxo.
