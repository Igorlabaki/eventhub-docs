# Clarify — Desconto em % no orcamento

## Perguntas criticas

- O desconto e salvo? Sim, a % e o valor. Confirmado pelo usuario.
- O cliente ve o desconto no link? Sim: subtotal, `Desconto (X%)` e total final. Confirmado pelo usuario.
- O cliente muda servicos ou recalcula pelo link: o desconto continua? Nao; vale so para o orcamento que o dono montou. Confirmado pelo usuario.
- O dono digita o Total a mao: o que acontece com a %? O Total digitado e o valor final e a % zera. Confirmado pelo usuario.

## Respostas confirmadas

- `createPerPerson` e rota publica (sem `ensureAuthenticate`); o painel manda `Authorization: Bearer` e o controller ja passa `readOptionalUserId(req)` ao use case (feito na cortesia).
- `ProposalQuoteAuthorizer.assert(userId, venueId, denial)` aceita `PermissionDenial` proprio; `assertCourtesyAllowed` e o modelo.
- Criacao por pessoa: `totalAmountInput` vazio ou 0 com preco de catalogo usa `adjustVenueUnitPrice` + `calcProposalAmounts`; com valor usa `calcCustomTotalAmount`.
- Edicao por pessoa: `totalAmountInput` igual ao `totalAmount` gravado recalcula pelo pipeline; diferente usa o valor como total manual.
- `ProposalEdit` sempre chama `updatePerPerson`, inclusive para orcamento de espaco por dia.
- `/proposal/quote` so cota `PER_PERSON` e `PER_PERSON_HOUR`; nos outros modelos o bloco mostra erro e nao ha estimado para descontar.
- `getById` usa `include`, entao as colunas novas chegam ao painel e ao link (`GET /proposal/byId/:id`) sem rota nova.
- `update-public-proposal-services` grava `totalAmount = totalAmount - oldSum + newSum`; pedido sem mudanca devolve `currentResponse` sem gravar.
- `recalculate-public-proposal` refaz o total inteiro pelo pipeline e sempre grava.
- `ProposalView` aplica a resposta do PUT de servicos em `applyPublicServices` e a do recalculo com `setCurrentProposal({ ...currentProposal, ...data })`.

## Requisitos implicitos confirmados

- `totalAmount` continua liquido; relatorios, pagamentos e listas nao mudam.
- A permissao vem do token, nunca do `userId` do corpo.
- `discountAmount` e gravado para reconstruir o subtotal sem divisao (vale com 100%).

## Premissas assumidas

- Quando o cliente muda o orcamento pelo link, o desconto zera (nao fica fixo em R$).
  - Risco se estiver errado: o cliente ve o total subir mais do que o item adicionado. A alternativa (manter `discountAmount` fixo) muda so `T-04`.
- O link avisa antes que o desconto deixa de valer.
  - Risco se estiver errado: so texto a mais no modal.
- Recalculo com os mesmos dados gravados mantem a % e a aplica sobre o subtotal recalculado.
  - Risco se estiver errado: o cliente perderia o desconto so por abrir e confirmar o modal sem mudar nada.
- O `/quote` nao recebe a %; a tela aplica a mesma formula (`round2`) sobre o estimado.
  - Risco se estiver errado: diferenca de centavos entre tela e gravado. Mitigacao: formula identica e testada nos dois lados.
- Com % acima de 0, o backend ignora `totalAmountInput` e calcula pelo pipeline.
  - Risco se estiver errado: nenhum valor diferente do que a tela mostrou, porque a tela preenche o `Total` com a mesma conta.
- Na edicao, `discountPercent` ausente zera o desconto.
  - Risco se estiver errado: frontend antigo apaga o desconto ao salvar. So ocorre se o backend sair antes do frontend; antes do frontend nao existe desconto gravado.
- A % entra depois do preco minimo e pode deixar o total abaixo dele.
  - Risco se estiver errado: o dono vende abaixo do minimo; a decisao e dele.
- Permuta ignora a % sem pedir permissao.
  - Risco se estiver errado: nenhum valor muda; total da permuta e 0.
- Campo de % vazio vale 0. Apagar o campo depois de usar volta o `Total` ao estimado; abrir a tela sem tocar no campo nao mexe no `Total`.
  - Risco se estiver errado: o dono redigita o Total.
- Historico: a edicao continua "atualizou este orcamento"; no link, a acao ganha " (desconto de X% removido)" quando o desconto cair.
  - Risco se estiver errado: menos rastro de quem deu o desconto; o historico da edicao ja tem o usuario.
- O contrato em PDF continua so com o total.
  - Risco se estiver errado: o cliente nao ve o desconto no contrato.

## Perguntas de erro e borda ainda abertas

- Nenhuma. A execucao segue pelas premissas acima.

## Itens bloqueantes

- Aplicar o deploy request na `main` (`T-01`) exige aprovacao nomeada (org `igorlabakig`, banco `ar756`, numero do deploy request). O codigo das outras tasks pode ser escrito antes, mas o backend nao pode ir ao ar antes das colunas.

## O que pode seguir mesmo com lacunas

- `T-02` nao depende do banco e pode comecar ja.
- Trocar a premissa "desconto zera no link" por "desconto fixo em R$" muda so `T-04` e o texto do aviso em `T-06`.
