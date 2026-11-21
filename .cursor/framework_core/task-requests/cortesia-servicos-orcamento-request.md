# Solicitacao da Tarefa

## Nome sugerido da tarefa

Cortesia de servicos no orcamento

## Resumo da solicitacao

O dono do espaco escolhe, em cada orcamento, servicos para dar de cortesia: horas no servico `PER_HOUR`, pessoas no `PER_PERSON` e o servico inteiro no `FIXED`. A linha do orcamento cobra so o que nao e cortesia, e o cliente ve o valor cheio, a cortesia descontada e o valor final.

## Context Pack

- frente principal: backend (calculo e gravacao da linha de servico), com formulario e exibicao no frontend
- superficie sensivel: sim — dinheiro (total do orcamento) e rotas publicas do link que alteram servicos e recalculam
- camadas transversais: `database`, `security`, `design`
- risco principal: o cliente conseguir criar ou aumentar cortesia pelas rotas publicas, ou o total ficar errado quando horas ou convidados mudam depois da cortesia dada
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`), banco PlanetScale `ar756/main`
- fora de escopo operacional: cortesia definida no catalogo (`Service` nao muda); desconto em R$ ou % na linha; cortesia na locacao do espaco; formularios publicos de criar orcamento (`ClientPerPersonProposalForm`, `ClientPerDayProposalForm`); contrato em PDF; relatorios de receita
- prova minima desta execucao: vitest de `quote-service-lines` com os tres tipos (6h com 2h de cortesia cobra 4h; 100 pessoas com 10 de cortesia cobra 90; fixo de cortesia cobra 0) e com os erros de limite; spec do link publico mostrando que payload com cortesia nao altera nada e que remover e readicionar zera a cortesia; no painel, criar orcamento com cortesia e ver o total estimado e o detalhe com `Cortesia: 2h (-R$ ...)`
- criterio de escalada: ja e `spec` (faixa `C`); volta a discutir escopo se surgir pedido de cortesia no catalogo ou desconto em valor
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/functions/quote-service-lines.ts` (inteiro); `art56_server_v3/prisma/schema.prisma` em `model ProposalService`; `art56_server_v3/src/use-cases/proposal/update-public-proposal-services/use-case-update-public-proposal-services.ts` em `execute`
- libs obrigatorias: `node`, `database`, `security`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/topics/pricing-and-proposal-calculation.md#Servicos (quote-service-lines.ts)`
  - `.cursor/framework_core/project/planetscale.md`
  - `.cursor/framework_global/framework-libs/database/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/specs/2026-11-04-horas-servico-por-hora/00-overview.md#Objetivo rapido`
- caminhos candidatos:
  - backend: `src/zod/proposal/create-proposal-per-person-params-schema.ts`, `create-proposal-per-day-params-schema.ts`, `update-proposal-per-person-params-schema.ts`, `update-proposal-per-day--params-schema.ts`, `quote-proposal-schema.ts`; `src/use-cases/proposal/{create,update}-proposal-per-{person,day}/`, `quote-proposal/`, `recalculate-public-proposal/`; `src/repositories/in-prisma/proposal-in-prisma-repository.ts` (`serviceLineRows`); `src/repositories/interface/proposal-repository-interface.ts`
  - frontend: `src/components/proposal/DashboardServiceChoices.tsx`; `src/lib/proposal-quote-input.ts`; `src/components/proposal/forms/PerPersonProposalForm.tsx`, `PerDayProposalForm.tsx`; `src/pages/ProposalEdit.tsx`; `src/components/proposal/ProposalServicesSummary.tsx`; `src/pages/ProposalView.tsx`; `src/components/proposal/UpdateProposalServicesDialog.tsx`; `src/types/proposal.ts`; `src/services/proposal.service.ts`
- palavras-chave ou simbolos de busca: `quoteServiceLines`, `quantityFor`, `serviceHoursMap`, `assertChosenServiceHours`, `sumServiceQuote`, `serviceLineRows`, `resolvePublicHours`, `hoursUnchanged`, `chosenServiceHours`, `serviceHours`, `proposalServices`
- testes provaveis: `functions/quote-service-lines.spec.ts`; specs dos use-cases `create/update-proposal-per-*`, `quote-proposal`, `update-public-proposal-services`, `recalculate-public-proposal`; `lib/proposal-quote-input.test.ts`; teste novo do helper de rotulo da cortesia
- nao ler por padrao: `SeasonalFee`, `Goal`, `MinimumPricePeriod`, `proposal-amounts.ts` alem de confirmar que o total soma `sumServiceQuote`; Asaas, DocuSign, relatorios

## Contexto informado na entrada

Pedido em chat: "como dono do espaco dar cortesia nos servicos; se for por hora posso dar duas horas de cortesia, se for por pessoa algumas de cortesia, se for fixo tambem". Na mesma conversa o usuario fechou tres decisoes: a cortesia e por orcamento (nao no catalogo); o cliente ve valor cheio, cortesia e valor final; se o cliente remover pelo link um servico com cortesia, ela some e so o dono pode dar de novo. Plano em fases ja escrito em `C:\Users\AR756\.cursor\plans\cortesia_de_servicos_cf8769b9.plan.md`.

## Problema atual

Hoje a unica forma de dar algo de graca e zerar o preco no catalogo (vale para todos os orcamentos) ou mexer no total manual (perde o detalhe por servico). `ProposalService` grava `pricingType`, `unitPrice`, `quantity` e `amount`, mas nao tem como dizer que parte da quantidade e cortesia.

## Objetivo da mudanca

Em um orcamento, o dono informa a cortesia por servico, o total cai exatamente `unitPrice x cortesia`, e painel e link publico mostram a linha com valor cheio, cortesia e valor final.

## Escopo inicial percebido

Um campo novo na linha do orcamento, a regra no calculo das linhas, o campo no payload dos fluxos do dono, a preservacao da cortesia nos fluxos publicos, o campo no formulario do painel e a exibicao nas tres telas que mostram servicos.

## Itens incluidos neste request

- banco: `ProposalService.courtesyQuantity Int @default(0)`, migration aditiva via deploy request
- regra: `amount = unitPrice x (quantity - courtesyQuantity)`; limites `PER_HOUR` ate as horas escolhidas, `PER_PERSON` ate os convidados, `FIXED` 0 ou 1
- contrato do dono: `serviceCourtesy: [{ serviceId, quantity }]` opcional em criar e editar (por pessoa e por dia) e em `POST /proposal/quote`
- link publico: payload continua sem cortesia; linha existente preserva; servico novo ou readicionado entra com 0; quantidade menor reduz a cortesia
- painel: campo de cortesia por servico marcado (horas, pessoas ou "Dar de cortesia"), total estimado com a cortesia, edicao preenchida com o que esta gravado
- exibicao: `ProposalServicesSummary`, `ProposalView` e `UpdateProposalServicesDialog` com valor cheio, cortesia e valor final

## Requisitos implicitos ja visiveis

- a cortesia e inteira, na mesma unidade da quantidade da linha
- o valor da cortesia e derivado (`unitPrice x courtesyQuantity`), nao gravado
- orcamentos antigos ficam com 0 e nao mudam de valor
- piso minimo, total manual (`totalAmountInput`) e permuta continuam somando `sumServiceQuote`, agora com o valor liquido
- backend aceita payload sem `serviceCourtesy` (frontend antigo continua funcionando)
- historico do orcamento registra a alteracao como hoje

## Casos de erro e borda ja percebidos

- cortesia maior que a quantidade, negativa ou nao inteira: 400 com mensagem em portugues
- `FIXED` com cortesia 2: 400
- cortesia para servico nao selecionado: ignorada ou 400 (ver pergunta em aberto)
- cortesia total: linha com R$ 0, ainda exibida
- cliente baixa as horas abaixo da cortesia no link: cortesia vira o novo numero de horas
- recalculo publico com menos convidados que a cortesia `PER_PERSON`: cortesia vira o numero de convidados
- cliente envia `serviceCourtesy` na rota publica: sem efeito
- servico `PER_HOUR` sem horas informadas (usa a duracao do evento): limite da cortesia e a duracao
- servico obrigatorio por `rpaMinPeople` tambem pode receber cortesia

## Dependencias

- spec [Preco, foto e descricao do servico](../specs/2026-11-04-preco-foto-descricao-servico/00-overview.md): criou as linhas gravadas em `ProposalService`
- spec [Pedir quantas horas o cliente quer no servico por hora](../specs/2026-11-04-horas-servico-por-hora/00-overview.md): `serviceHours` e o modelo de contrato a seguir
- spec [Adicionar ou tirar servico no link publico](../specs/2026-11-04-adicionar-servico-proposta-publica/00-overview.md): rota publica que precisa preservar a cortesia
- spec [Total estimado do orcamento no painel](../specs/2026-11-09-total-estimado-orcamento-painel/00-overview.md): `POST /proposal/quote` recebe a cortesia

## Restricoes e cuidados

- migration so aditiva e na `main` do PlanetScale por deploy request; escrita no banco real exige aprovacao nomeada
- ordem de deploy: banco, backend, frontend
- nao abrir nenhuma rota publica nova nem aceitar cortesia em rota publica
- dinheiro continua em `Float` (D-07); nao introduzir arredondamento novo nesta mudanca
- seguir o formato de `serviceHours` (`serviceHoursMap`) para o novo `serviceCourtesy`
- atualizar `topics/pricing-and-proposal-calculation.md`, `project/api-endpoints.md` e `product/08-data-model.md`

## Perguntas em aberto

- Cortesia enviada para servico nao selecionado: 400 ou ignorar? Premissa: ignorar, como `serviceHours` de servico nao marcado.
- Desmarcar e remarcar o servico no painel mantem a cortesia digitada? Premissa: nao; desmarcar limpa o campo.
- A cortesia aparece no contrato PDF? Premissa: nao nesta entrega; o contrato continua com o total.
- O cliente ve a cortesia no formulario de alterar servicos do link? Premissa: sim, so leitura, ao lado do valor.

## Prioridade sugerida

Media. Funcionalidade comercial nova, sem bloqueio atual.

## Faixa sugerida para task workflow

- `C` — dinheiro, schema novo, rota publica e dois repos, com ordem de entrega propria
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: toca banco, backend e frontend, mexe em total de orcamento e em rota publica, e se divide naturalmente em tasks com ordem (banco, regra, fluxos do dono, fluxos publicos, formulario, exibicao, docs)

## Sugestao de slug da spec

- `framework_core/specs/2026-11-10-cortesia-servicos-orcamento/`

## Sugestao de nome do arquivo

- `cortesia-servicos-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `spec`
- status: promovido para spec em 2026-11-10; nada implementado
- proximo passo: ver spec
- promovida para: `specs/2026-11-10-cortesia-servicos-orcamento/`
- entrada publica recomendada: `fw:review` na spec
- derivacao repo-local: depois da spec, com `spec-driven/spec-repo-split-prompt.md` (banco e backend antes do frontend)
