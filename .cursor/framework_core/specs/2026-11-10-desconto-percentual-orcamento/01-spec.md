# Spec — Desconto em % no orcamento

## Problema

O bloco `Total estimado` do painel so oferece `Usar este valor`, que copia o estimado para o campo `Total`. Para dar desconto, a equipe calcula fora e digita o valor final. O orcamento nao guarda que houve desconto: o cliente ve so um total menor e o painel nao mostra a % ao reabrir.

## Objetivos

- O dono digita uma % no bloco `Total estimado`, no lugar do botao `Usar este valor`.
- O orcamento grava a % (`discountPercent`) e o valor em R$ (`discountAmount`). `totalAmount` ja sai com desconto.
- O cliente ve no link o subtotal, `Desconto (X%)` e o total final.
- O desconto vale so para o orcamento que o dono montou: se o cliente mudar servicos, data, convidados ou horas pelo link, o desconto cai.
- Total digitado a mao e o valor final e zera a %.

## Fora de escopo

- desconto em R$ digitado; desconto por servico (ja existe a cortesia)
- desconto na criacao e na edicao por dia (`createPerDay`, `updatePerDay`, `PerDayProposalForm`); o `/quote` so cota espacos por pessoa
- formularios publicos de criar orcamento (`ClientPerPersonProposalForm`, `ClientPerDayProposalForm`)
- desconto no `/quote` (a tela calcula a % sobre o estimado com a mesma formula do backend)
- contrato em PDF, relatorios de receita e metas
- trocar `Float` do dinheiro (D-07)

## User stories ou cenarios principais

- O dono monta um orcamento com Espaco R$ 5.000,00 e Servicos R$ 800,00. O bloco mostra R$ 5.800,00. Ele digita `10` no `Desconto (%)`: aparecem `Desconto (10%) - R$ 580,00` e `Total com desconto R$ 5.220,00`, e o campo `Total` vira R$ 5.220,00. Ao salvar, o orcamento grava `discountPercent` 10, `discountAmount` 580 e `totalAmount` 5220.
- Ele reabre a edicao: o campo vem com `10`. Ele digita R$ 5.000,00 no `Total`: o campo de % zera e o orcamento grava 5000 sem desconto.
- A cliente abre o link e ve `Subtotal R$ 5.800,00`, `Desconto (10%) - R$ 580,00` e `Investimento total R$ 5.220,00`.
- Ela abre `Alterar servicos`, le o aviso de que o desconto deixa de valer e adiciona um servico de R$ 300,00. O orcamento passa a R$ 6.100,00, sem desconto.

## Criterios de aceite

- `R-01`: `Proposal` ganha `discountPercent Float @default(0)` e `discountAmount Float @default(0)`. Orcamentos ja gravados ficam com 0 e nenhum valor muda.
- `R-02`: o calculo e `discountAmount = round2(subtotal x % / 100)` e `totalAmount = subtotal - discountAmount`, onde subtotal e o total que o pipeline atual produz (espaco, preco minimo, horas extras e servicos ja com cortesia).
  - % aceita: numero de 0 a 100 com ate duas casas decimais.
  - Fora disso: 400 com "Informe um desconto de 0 a 100%, com até duas casas decimais." e nada e gravado.
- `R-03`: `POST /proposal/createPerPerson` aceita `discountPercent` opcional.
  - Com % acima de 0 e permissao: ignora `totalAmountInput`, calcula pelo pipeline automatico, aplica `R-02` e grava `discountPercent`, `discountAmount` e `totalAmount`.
  - Espaco sem preco de catalogo por pessoa: 400 com a mensagem de `NO_QUOTE_MESSAGE`.
- `R-04`: desconto acima de 0 exige token valido de usuario com `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` no espaco.
  - Sem token: 401. Sem permissao: 403 com "Você não tem permissão para dar desconto neste espaço.". Nada e gravado.
  - O formulario publico, que nao envia o campo, continua criando igual.
- `R-05`: `PUT /proposal/updatePerPerson` aceita `discountPercent` como fonte da verdade: ausente vale 0.
  - Com % acima de 0: mesma permissao de `R-04`, conferida pelo usuario do token e pelo `venueId` gravado; calcula pelo pipeline automatico e aplica `R-02`.
  - Com % 0 ou ausente: regra atual (Total igual ao gravado recalcula; Total diferente e manual) e grava 0 nos dois campos.
- `R-06`: total manual, permuta e `updatePerDay` gravam `discountPercent` 0 e `discountAmount` 0. Permuta com % acima de 0 ignora a % sem pedir permissao.
- `R-07`: `PUT /proposal/presentation/:proposalId/services` nunca le desconto do corpo.
  - Pedido sem mudanca: nada e gravado e o desconto fica.
  - Pedido com mudanca: `totalAmount = totalAmount + discountAmount - oldSum + newSum`, `discountPercent` 0 e `discountAmount` 0.
  - A resposta traz `discountPercent` e `discountAmount`.
- `R-08`: `PUT /proposal/presentation/:proposalId/recalculate` nunca le desconto do corpo.
  - Mesma data, convidados e horas do gravado: aplica a % gravada sobre o subtotal recalculado.
  - Qualquer mudanca: grava o subtotal como total e zera os dois campos.
  - A resposta traz `discountPercent` e `discountAmount`.
- `R-09`: no bloco `Total estimado` (criar por pessoa e `ProposalEdit`), o botao `Usar este valor` sai e entra o campo `Desconto (%)`.
  - Com % acima de 0, o bloco mostra `Desconto (X%) - R$` e `Total com desconto`, e o campo `Total` recebe o total com desconto, reaplicado quando o estimado muda.
  - Digitar no `Total` zera o campo de %.
  - Valor invalido mostra erro no campo e nao envia.
  - O payload leva `discountPercent`.
- `R-10`: `ProposalEdit` abre com a % gravada. O aviso "Ao salvar sem mudar o Total..." compara com o total com desconto.
- `R-11`: com `discountPercent` acima de 0, "Seu investimento" no link (`ProposalView`) e o detalhe do painel (`ProposalServicesSummary`) mostram `Subtotal`, `Desconto (X%) - R$` e o total final. Sem desconto, ficam como hoje.
- `R-12`: no link, os modais `Alterar servicos` e `Alterar orçamento` mostram "O desconto de X% deixa de valer se você alterar o orçamento." quando houver desconto. Depois de gravar, a pagina reflete o desconto zerado sem recarregar.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership:
  - desconto so com permissao de orcamentos no espaco, pelo `ProposalQuoteAuthorizer`;
  - rotas publicas do link nao aceitam desconto;
  - o corpo nunca envia `discountAmount`; ele e sempre calculado.
- erros e mensagens esperadas:
  - validacao: "Informe um desconto de 0 a 100%, com até duas casas decimais.";
  - permissao: "Você não tem permissão para dar desconto neste espaço.".
- observabilidade minima: `console.error` com `userId` e `venueId` quando o desconto e negado, como a cortesia. Historico do link diz quando o desconto caiu.
- concorrencia, idempotencia ou retry: sem mudanca. Ultima gravacao vence.
- rollout, fallback ou degradacao:
  - ordem de deploy: banco, backend, frontend;
  - backend sem `discountPercent` no corpo se comporta como hoje.

## Casos de erro e borda obrigatorios

- caso: % negativa, acima de 100, com tres casas, texto
  - impacto: total errado ou negativo
  - cobertura esperada: unitario da funcao de desconto e da criacao
- caso: 100%
  - impacto: total 0; o valor cheio volta pelo `discountAmount`, sem divisao
  - cobertura esperada: unitario da funcao e do PUT publico
- caso: criacao com desconto sem token, com token sem permissao, ou com `userId` forjado no corpo
  - impacto: cliente se dando desconto
  - cobertura esperada: unitario da criacao
- caso: `discountPercent` e `totalAmountInput` juntos
  - impacto: a % vence no backend; a tela zera a % quando o dono digita no `Total`
  - cobertura esperada: unitario da criacao e da edicao
- caso: edicao sem `discountPercent`
  - impacto: o desconto cai, conforme a decisao
  - cobertura esperada: unitario da edicao
- caso: PUT publico sem mudanca, com mudanca e com `discountPercent` no corpo
  - impacto: desconto mantido, zerado ou criado pelo cliente
  - cobertura esperada: unitario do PUT publico
- caso: recalculo com os mesmos dados e com dados novos
  - impacto: desconto mantido ou zerado
  - cobertura esperada: unitario do recalculo
- caso: preco minimo aplicado
  - impacto: a % entra depois do minimo e pode deixar o total abaixo dele
  - cobertura esperada: unitario da criacao
- caso: permuta com % acima de 0
  - impacto: total 0 e desconto 0
  - cobertura esperada: unitario da criacao

## Impacto esperado

O dono registra o desconto comercial sem conta de cabeca, e o cliente ve quanto ganhou. `totalAmount` continua liquido, entao relatorios, pagamentos e listas nao mudam.

## Areas impactadas

- `backend`:
  - `schema.prisma` e uma migration;
  - funcao nova `functions/proposal-discount.ts`;
  - `proposal-quote-authorizer.ts` (negacao e `assertDiscountAllowed`);
  - Zod e use cases `create-proposal-per-person`, `update-proposal-per-person` e `update-proposal-per-day`;
  - `update-public-proposal-services` e `recalculate-public-proposal`;
  - tipos de criar e editar no repositorio.
- `frontend`:
  - `ProposalQuoteSummary`, `PerPersonProposalForm` e `ProposalEdit`;
  - helper novo `lib/proposal-discount.ts`;
  - `ProposalView`, `ProposalServicesSummary`, `UpdateProposalServicesDialog` e `RecalculateProposalDialog`;
  - tipos e `proposal.service.ts`.
- banco: `proposal.discountPercent` e `proposal.discountAmount` na `main` via deploy request.
- docs:
  - `topics/pricing-and-proposal-calculation.md`;
  - `project/api-endpoints.md`;
  - `product/08-data-model.md`;
  - `product/02-business-rules.md#Precificacao`;
  - `specs/2026-11-09-total-estimado-orcamento-painel/01-spec.md` (`R-12` substituido).

## Restricoes e cuidados

- D-05: a tela nao substitui a autorizacao da API
- D-07: dinheiro continua `Float`; o unico arredondamento novo e o `round2` do valor do desconto
- D-09: DDL so por branch e deploy request; aplicar na `main` exige aprovacao nomeada
- o controller de `createPerPerson` descarta o `safeParse`, entao o use case valida `discountPercent` por conta propria
- nao ler nem versionar `.env`

## Dependencias

- `specs/2026-11-09-total-estimado-orcamento-painel`: bloco `Total estimado` e `useProposalQuote`
- `specs/2026-11-10-cortesia-servicos-orcamento`: `assertCourtesyAllowed`, `PermissionDenial` e a regra do link publico como modelo
- `specs/2026-11-04-recalcular-orcamento-proposta-publica` e `specs/2026-11-04-adicionar-servico-proposta-publica`: rotas publicas que passam a zerar o desconto

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> `prisma validate` e `SHOW COLUMNS` na `main`
- `R-02`, `R-04` -> `T-02` -> unitario
- `R-03`, `R-05`, `R-06` -> `T-03` -> unitario
- `R-07`, `R-08` -> `T-04` -> unitario
- `R-09`, `R-10` -> `T-05` -> vitest do helper e browser do painel
- `R-11`, `R-12` -> `T-06` -> vitest do helper e browser do painel e do link

## Perguntas em aberto

Nenhuma bloqueante. As premissas estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01` (e `T-02` em paralelo)
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
