# Clarify — Adicionar ou tirar servico no link publico

## Perguntas criticas

Nenhuma bloqueante. As premissas abaixo vieram do pedido e da conversa que fechou o request.

## Respostas confirmadas

- O botao fica no card "Sua experiencia inclui" e o texto e "Adicionar servico".
- Obrigatorio nao desmarca. A regra ja usada no formulario e `rpaRequired` com `rpaMinPeople` atingido pelos convidados atuais.
- A gravacao e no servidor e devolve a lista e o total para os dois cards.
- Dia, convidados e horas nao mudam neste modal.

## Requisitos implicitos confirmados

- A rota publica que grava segue o mesmo tipo de exposicao de `PUT /proposal/presentation/:proposalId/recalculate`: sem login, no orcamento da URL, corpo estreito, recusa `approved` ou `paid`.
- A linha nova usa `quoteServiceLines`. A linha que permanece usa o snapshot ja gravado em `ProposalService`.
- O frontend nao cria store novo.

## Premissas assumidas

- Confirmar e que grava. Cada clique na caixa so altera o modal. Risco: a pessoa espera ver o total mudar antes de confirmar.
- O modal mostra o valor da linha, nao o preco unitario. Para quem ja esta no orcamento, esse valor e o `amount` gravado; para quem nao esta, e a conta atual do cadastro. Risco: a linha nova diverge do preco que a equipe ve no cadastro se o snapshot antigo for outro.
- O total novo e o total atual menos a soma antiga dos servicos mais a soma nova. Locacao, horas extras e qualquer diferenca ja negociada permanecem. Risco: se o total salvo nao contiver os servicos, a diferenca desloca o numero.
- `rpaRequired` sem minimo nao trava. Risco: um cadastro incompleto deixa sair um servico que a equipe queria obrigatorio.
- Orcamento aprovado ou pago nao muda. Risco: a equipe esperava um ajuste tardio pelo link.
- O card aparece mesmo sem servico ligado, quando o espaco tem algum. Risco: o card surge depois do carregamento da lista, sem mudar o skeleton.
- A mudanca entra no historico, sem usuario, so quando o conjunto de ids muda. Risco: o painel ganha uma linha que ninguem pediu na frase original.
- No celular o botao fica no topo do card, nao abaixo do WhatsApp. Risco: em tela estreita o titulo e o botao dividem a primeira linha.
- `BARTER` e `TIERED` tambem podem mudar servico por aqui, porque a locacao nao e recalculada. Risco: um orcamento sem preco de locacao passa a ter total so de servico.
- Nao ha rate limit novo. O risco aceito e o mesmo do recalculo publico.
- Lista com mais de 100 ids e recusada. Risco: um espaco com mais de 100 servicos nao grava.

## Perguntas de erro e borda ainda abertas

Nenhuma. Os casos obrigatorios estao em `01-spec.md`.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

A execucao inteira. `T-01` pode comecar sem a tela.
