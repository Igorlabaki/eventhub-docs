# Clarify — Card da casa na apresentacao publica

## Perguntas criticas

- O titulo da aba da apresentacao troca a descricao pelo slogan?
- O card leva um rotulo curto alem do nome?
- Horario incompleto mostra traco ou some o lado que falta?

## Respostas confirmadas

- O card fica so em `/venue/:id/apresentacao`. Orcamento e formulario publico continuam com a descricao embaixo do logo.
- O card leva descricao, horario, capacidade, noites minimas com pernoite, e bairro com cidade.
- A foto que hoje ocupa o vao continua depois do card. O repartir das fotos nao muda.
- Preco, duracao padrao, servicos, caracteristicas, WhatsApp e mapa ficam nos blocos atuais.
- Rua, numero e CEP nao entram escritos.

## Requisitos implicitos confirmados

- Campo vazio some. O card nao some: nome e capacidade sempre existem.
- Casa sem pernoite nao mostra check-in, check-out nem noites.
- Casa com pernoite nao mostra abertura e fechamento.
- O GET ja devolve capacidade, horarios, pernoite, bairro e cidade. A unica chave nova e `slogan`.
- Sem migration.

## Premissas assumidas

- O titulo da aba desta pagina usa o slogan. Premissa: o texto curto do topo e o que `venueTabTitle` recebe hoje; uma descricao longa nao pode ir para a aba. Risco se estiver errada: a aba continua com a descricao. A execucao segue o slogan.
- O rotulo acima do nome e `A casa`, no mesmo lugar de `Proposta personalizada`. O titulo e o nome do espaco. Risco se estiver errada: o card fica sem o rotulo curto. A execucao segue com o rotulo.
- Horario pela metade mostra so o lado preenchido, sem `—`. Os dois vazios escondem a linha. Risco se estiver errada: o visitante ve um traco. A execucao omite o lado vazio.
- `8:00` vira `8h` e `8:30` vira `8h30`, como em `ProposalView`. A funcao mora em `venue-presentation.ts`.

## Perguntas de erro e borda ainda abertas

- Nenhuma.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` e `T-02` seguem com as premissas acima. Nao ha lacuna de contrato.
