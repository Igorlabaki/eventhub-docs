# Solicitacao da Tarefa

## Nome sugerido da tarefa

Desconto em % salvo no orcamento

## Resumo da solicitacao

No bloco `Total estimado` do painel, o botao `Usar este valor` sai e entra um campo `Desconto (%)`. A porcentagem e gravada no orcamento, o total gravado ja vem com o desconto, e o cliente ve no link o valor cheio, o desconto e o total final. O desconto vale so para o orcamento que o dono montou: se o cliente mudar algo pelo link, o desconto cai. Se o dono digitar o Total a mao, esse valor e o final e a % zera.

## Context Pack

- frente principal: backend (gravar a % e aplicar no total), com campo no painel e exibicao no link do cliente
- superficie sensivel: sim — dinheiro (total do orcamento) e rotas publicas do link que recalculam e trocam servicos
- camadas transversais: `database`, `security`, `design`
- risco principal: total gravado divergir do que o cliente ve (desconto exibido sem estar aplicado, ou aplicado duas vezes), e o cliente conseguir mandar ou manter desconto pelas rotas publicas
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`), banco PlanetScale `ar756/main`
- fora de escopo operacional: desconto em R$; desconto por servico (ja existe a cortesia); desconto nos formularios publicos de criar orcamento (`ClientPerPersonProposalForm`, `ClientPerDayProposalForm`); campo na criacao por dia (`PerDayProposalForm` nao tem o bloco `Total estimado`); contrato PDF; relatorios de receita (continuam somando o `totalAmount` gravado); adicionais e descontos sazonais do espaco
- prova minima desta execucao: vitest do calculo com total estimado R$ 5.800,00 e 10% gravando `totalAmount` 5220 e `discountPercent` 10; `totalAmountInput` com valor grava esse valor e `discountPercent` 0; spec do link publico mostrando que recalcular ou trocar servicos zera a % e grava o total cheio, que a rota publica ignora `discountPercent` no payload e que um pedido sem mudanca nao mexe no desconto; no browser, criar orcamento com 10%, reabrir a edicao com `10` preenchido e ver no link `Desconto (10%) - R$ 580,00` e total R$ 5.220,00
- criterio de escalada: ja e `spec` (faixa `C`); volta a discutir escopo se pedirem desconto em R$ ou manter o desconto quando o cliente muda o orcamento
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/proposal/ProposalQuoteSummary.tsx` (inteiro); `art56_server_v3/src/functions/proposal-amounts.ts` (calculo do total); `art56_server_v3/prisma/schema.prisma` em `model Proposal`
- libs obrigatorias: `node`, `database`, `security`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/topics/pricing-and-proposal-calculation.md`
  - `.cursor/framework_core/project/planetscale.md`
  - `.cursor/framework_core/specs/2026-11-09-total-estimado-orcamento-painel/01-spec.md#R-12`
  - `.cursor/framework_core/specs/2026-11-10-cortesia-servicos-orcamento/00-overview.md` (modelo de regra no link publico)
- caminhos candidatos:
  - backend: `src/zod/proposal/create-proposal-per-person-params-schema.ts`, `create-proposal-per-day-params-schema.ts`, `update-proposal-per-person-params-schema.ts`, `update-proposal-per-day--params-schema.ts`, `quote-proposal-schema.ts`; `src/use-cases/proposal/{create,update}-proposal-per-{person,day}/`, `quote-proposal/`, `recalculate-public-proposal/`, `update-public-proposal-services/`; `src/repositories/in-prisma/proposal-in-prisma-repository.ts`
  - frontend: `src/components/proposal/ProposalQuoteSummary.tsx`; `src/components/proposal/forms/PerPersonProposalForm.tsx`; `src/pages/ProposalEdit.tsx`; `src/pages/ProposalView.tsx`; `src/pages/ProposalDetails.tsx`; `src/lib/proposal-quote-input.ts`; `src/types/proposal.ts`; `src/services/proposal.service.ts`
- palavras-chave ou simbolos de busca: `totalAmountInput`, `onUseValue`, `Usar este valor`, `calculateAmounts`, `sumServiceQuote`, `oldSum`, `newSum`, `quoteProposal`, `minimumApplied`
- testes provaveis: specs dos use cases `create/update-proposal-per-*`, `quote-proposal`, `recalculate-public-proposal`, `update-public-proposal-services`; `functions/proposal-amounts.spec.ts`; `lib/proposal-quote-input.test.ts`; teste novo de `ProposalQuoteSummary`
- nao ler por padrao: `SeasonalFee`, `Goal`, `MinimumPricePeriod` alem do que `proposal-amounts.ts` ja aplica; Asaas, DocuSign, relatorios

## Contexto informado na entrada

Pedido em chat com print do bloco `Total estimado` (Espaco R$ 5.000,00, Servicos R$ 800,00, Total R$ 5.800,00): tirar `Usar este valor` e colocar um campo de % que calcula o desconto. Na mesma conversa o usuario pediu para salvar o desconto e fechou tres decisoes:

- o cliente ve no link o valor cheio, `Desconto (X%)` e o total final
- o desconto vale so para o orcamento que o dono montou (cliente mudou pelo link, o desconto cai)
- Total digitado a mao e o valor final e zera a %

## Problema atual

O bloco so oferece `Usar este valor`, que copia o total estimado para o `Total`. Para dar desconto a equipe calcula fora e digita o valor final, e o orcamento nao guarda que houve desconto: o cliente ve so um total menor, sem saber quanto ganhou, e o painel nao mostra a % ao reabrir.

## Objetivo da mudanca

Um orcamento criado ou editado no painel com X% grava `discountPercent = X` e `totalAmount = total estimado x (1 - X/100)`, e o link do cliente mostra valor cheio, desconto e total final.

## Escopo inicial percebido

Coluna nova na proposta, regra no calculo do total dos fluxos do dono e no `quote`, zerar o desconto nos dois fluxos publicos que mudam o orcamento, campo no bloco do painel e exibicao no link e no detalhe do painel.

## Itens incluidos neste request

- banco: `Proposal.discountPercent Float @default(0)` e `Proposal.discountAmount Float @default(0)` (este ultimo decidido na spec, para reconstruir o subtotal sem divisao), migration aditiva via deploy request
- regra: com % > 0, `totalAmount = round2(total estimado x (1 - % / 100))`, sobre o total que ja inclui espaco, preco minimo, horas extras e servicos com cortesia
- contrato do dono: `discountPercent` opcional (0 a 100) em criar e editar (por pessoa e por dia) e em `POST /proposal/quote`; o quote devolve o valor do desconto e o total com desconto
- Total manual: `totalAmountInput` informado e o total final e grava `discountPercent = 0`
- link publico: `Recalcular` e `Alterar servicos` com mudanca real gravam `discountPercent = 0` e o total cheio; pedido sem mudanca nao mexe no desconto; payload publico nao aceita `discountPercent`
- painel: campo `Desconto (%)` no bloco `Total estimado` no lugar do botao, nas telas onde o bloco existe (criacao por pessoa e edicao); edicao abre com a % gravada; digitar no `Total` zera o campo de %
- exibicao: link do cliente (`ProposalView`) e detalhe do painel com valor cheio, `Desconto (X%) - R$` e total final quando a % for maior que 0

## Requisitos implicitos ja visiveis

- orcamentos antigos ficam com 0 e nao mudam de valor
- valor cheio e valor do desconto sao derivados (`totalAmount` e `discountPercent`), nao gravados; definir na spec como reconstruir o valor cheio com 100% de desconto
- permuta continua com total zero e sem desconto
- backend aceita payload sem `discountPercent` (frontend antigo continua funcionando e grava 0)
- historico do orcamento registra a alteracao como hoje; quando o desconto cair pelo link, a entrada do historico diz isso
- `R$ X / pessoa` acompanha o total com desconto

## Casos de erro e borda ja percebidos

- % negativa, acima de 100 ou com mais de 2 casas: 400 com mensagem em portugues
- % com virgula no campo do painel (ex.: `7,5`)
- 100%: total zero, sem divisao por zero ao reconstruir o valor cheio
- `discountPercent` e `totalAmountInput` juntos: o total manual vence e a % grava 0
- cliente envia `discountPercent` na rota publica: sem efeito
- cliente remove e readiciona o mesmo servico, voltando ao mesmo conjunto: conta como mudanca? (ver pergunta em aberto)
- edicao do dono so de dados cadastrais (nome, telefone) sem mexer no valor: a % gravada continua

## Dependencias

- spec [Total estimado do orcamento no painel](../specs/2026-11-09-total-estimado-orcamento-painel/00-overview.md): criou o bloco e o `Usar este valor` (`R-12`, substituido por este trabalho)
- spec [Cortesia de servicos no orcamento](../specs/2026-11-10-cortesia-servicos-orcamento/00-overview.md): o total estimado ja desconta a cortesia antes da %; mesma regra de "cliente mudou, o beneficio do dono cai"
- spec [Recalcular o orcamento no link publico](../specs/2026-11-04-recalcular-orcamento-proposta-publica/00-overview.md) e [Adicionar ou tirar servico no link publico](../specs/2026-11-04-adicionar-servico-proposta-publica/00-overview.md): rotas que passam a zerar o desconto

## Restricoes e cuidados

- migration so aditiva e na `main` do PlanetScale por deploy request; escrita no banco real exige aprovacao nomeada
- ordem de deploy: banco, backend, frontend
- nao abrir rota publica nova nem aceitar desconto em rota publica
- dinheiro continua em `Float` (D-07); arredondar so o total com desconto a 2 casas
- atualizar `topics/pricing-and-proposal-calculation.md`, `project/api-endpoints.md`, `product/08-data-model.md` e marcar `R-12` da spec do total estimado como substituido

## Perguntas em aberto

- Quando o cliente muda o orcamento pelo link, o desconto zera ou fica fixo em R$? Premissa: zera (opcao escolhida: "vale so para o orcamento que o dono montou"). Alternativa registrada: manter o valor em R$ e somar o servico novo a preco cheio.
- O cliente e avisado de que vai perder o desconto antes de confirmar a mudanca no link? Premissa: sim, uma frase no modal de alterar servicos e no recalcular quando houver desconto.
- Remover e readicionar o mesmo servico, voltando ao mesmo conjunto, zera o desconto? Premissa: nao; so zera quando o pedido muda servicos, horas ou convidados em relacao ao gravado.
- O desconto aparece no contrato PDF? Premissa: nao nesta entrega; o contrato continua com o total.
- Apagar o campo de % no painel volta o Total ao estimado? Premissa: sim; campo vazio equivale a 0%.

## Prioridade sugerida

media

## Faixa sugerida para task workflow

- `C` — dinheiro, coluna nova, rotas publicas e dois repos, com ordem de entrega propria
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: toca banco, backend e frontend, muda o total gravado e duas rotas publicas, e se divide em tasks com ordem (banco, regra e quote, fluxos do dono, fluxos publicos, campo no painel, exibicao, docs)

## Sugestao de slug da spec

- `framework_core/specs/2026-11-10-desconto-percentual-orcamento/`

## Sugestao de nome do arquivo

- `desconto-percentual-total-estimado-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `spec`
- status: promovido para spec em 2026-11-10; nada implementado
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-10-desconto-percentual-orcamento/`
- entrada publica recomendada: `fw:review` na spec
- derivacao repo-local: depois da spec, com `spec-driven/spec-repo-split-prompt.md` (banco e backend antes do frontend)
