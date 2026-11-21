# State — Desconto em % no orcamento

## Snapshot

- status: `T-01` a `T-06` implementadas em 2026-11-10; nao marcada como pronta para producao
- ultima task concluida: `T-06` (docs)
- task em andamento: nenhuma
- proxima acao exata: review de entrega (`fw:review` + `entrega`); depois prova no browser com login
- prova mais recente: vitest back 473 e front 267; build do front ok; colunas na `main` via deploy request `#46`

## Delta

- `T-01`: `discountPercent` e `discountAmount` (`DOUBLE NOT NULL DEFAULT 0`) em `proposal`; migration `20261110220000_add_proposal_discount`; deploy request `#46` aplicado na `main` com aprovacao nomeada; `SHOW COLUMNS` confirmou
- `T-02`: `src/functions/proposal-discount.ts` (validacao 0..100 com 2 casas, formula, sufixo do historico) e `assertDiscountAllowed` em `proposal-quote-authorizer.ts`
- `T-03`: criar e editar por pessoa aceitam `discountPercent`; % > 0 exige token, permissao no espaco e preco de catalogo e ignora `totalAmountInput`; permuta, valor custom e edicao por dia gravam 0
- `T-04`: link mantem o desconto sem mudanca; mudar servicos ou recalcular com dados diferentes zera e grava `(desconto de X% removido)` no historico
- `T-05`: campo `Desconto (%)` no bloco `Total estimado` (criar e editar); digitar no Total limpa a %; botao "Usar este valor" removido
- `T-06`: link e resumo de servicos mostram Subtotal, Desconto e total; modais do link avisam que o desconto cai; docs de produto, topic, api-endpoints e planetscale atualizados; `R-12` da spec do total estimado marcado como substituido

## Lacunas de prova

- browser nao provado: localhost parou no login (sem credenciais) e o banco do local e producao
- POST com `discountPercent: 10` (5800 -> 5220), edicao abrindo com a % e link com Subtotal/Desconto so provados por vitest
- `tsc` back tem erros antigos em specs com mocks frouxos; front tem 1 erro antigo em `ProposalView` (`startDate`); nenhum novo em codigo de producao

## Decisoes recentes

- subtotal reconstruido como `totalAmount + discountAmount` (sem divisao)
- desconto 100% permitido (total 0)
- `discountPercent` no corpo das rotas publicas do link e ignorado
- campo da % fica escondido na permuta e sem estimado

## Riscos ou bloqueios

- API e front ainda nao publicados; publicar a API antes do front
- backend local foi reiniciado apontando para o tunel de producao (porta 3000); qualquer gravacao de teste altera producao

## Memoria promovida

- topics atualizados: `topics/pricing-and-proposal-calculation.md` (secao do desconto e lista de testes)
- project-decisions atualizados: nenhum (regra fica no topic e em `02-business-rules.md`)
- ADRs criados ou alterados: nenhum
