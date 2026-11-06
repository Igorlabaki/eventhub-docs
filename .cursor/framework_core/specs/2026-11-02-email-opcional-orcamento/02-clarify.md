# Clarify — e-mail opcional na criacao do orcamento

## Perguntas criticas

- O pedido de orcamento no site continua exigindo e-mail?
- A edicao no painel tambem aceita e-mail vazio?
- Campo vazio grava ausencia ou texto vazio?
- O link mostra o e-mail que o dono ja informou?

## Respostas confirmadas

- Na criacao pelo dono, e-mail nao e obrigatorio. Fonte: pedido em chat.
- No link de dados do contrato, e-mail e obrigatorio. Fonte: pedido em chat.

## Requisitos implicitos confirmados

- e-mail preenchido continua tendo de ser valido
- a API do link rejeita ausencia; a tela nao e a unica barreira
- WhatsApp nao entra nesta mudanca
- rota do contrato continua publica, como ja e `PUT /proposal/updatePersonalInfo`

## Premissas assumidas

- O pedido publico do site continua exigindo e-mail. Risco se estiver errada: o cliente do site tambem passaria a criar orcamento sem e-mail.
- A edicao no painel aceita e-mail vazio. Risco se estiver errada: o dono cria sem e-mail e nao consegue salvar de novo na edicao.
- Campo vazio ou so com espacos grava `null`, nunca `""`. Risco se estiver errada: listagem e envio futuro tratam texto vazio como e-mail.
- O link preenche o e-mail ja existente e nao salva se o cliente apagar. Risco se estiver errada: o cliente seria obrigado a digitar de novo, ou poderia apagar um e-mail ja valido.
- Os formularios internos `pf-contract-form` e `pj-contract-form` tambem exigem e-mail, porque salvam pelo mesmo `updatePersonalInfo`. Risco se estiver errada: o dono precisaria de outro contrato de API so para a tela interna.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Execucao segue pelas premissas acima.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- A review pode seguir. Nao ha lacuna que mude o recorte.
