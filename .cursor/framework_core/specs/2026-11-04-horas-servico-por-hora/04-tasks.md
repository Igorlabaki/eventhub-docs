# Tasks — Horas escolhidas no servico por hora

## Ordem macro

1. `T-01` ensina a cotacao a usar as horas informadas.
2. `T-02` exige essas horas na criacao. Depende de `T-01`.
3. `T-03` coloca o campo no formulario publico e envia a duracao no painel. Depende de `T-02`.
4. `T-04` leva as horas ao GET e ao PUT do link. Depende de `T-01`. Pode rodar em paralelo com `T-02` e `T-03`.
5. `T-05` coloca o campo no modal. Depende de `T-04`.
6. `T-06` conserva a quantidade no recalculo publico. Depende de `T-01`. Pode rodar em paralelo com `T-02` e `T-04`.

## Tasks

### T-01 - Aceitar horas informadas na cotacao

- objetivo: `quoteServiceLines` usa o inteiro informado no servico por hora e recusa numero invalido.
- cobre requisitos: `R-04`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `quoteServiceLines` e `calcEventDuration`
- prompt recomendado: `smart`
- estrategia de teste: unitario da funcao
- cenarios obrigatorios: 3 horas gravadas como quantidade 3 e valor unitario vezes 3; sem mapa, a quantidade segue a duracao, inclusive pernoite; 0 so passa quando a duracao e 0; negativo, fracao e 8761 lancam o erro e nao devolvem linha
- definition of done: os cenarios passam no spec de `quote-service-lines`; `FIXED` e `PER_PERSON` continuam iguais quando o mapa vem preenchido

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a quantidade que entra no valor
- risco principal: numero invalido cair na duracao ou gerar linha parcial
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: Zod, rotas, tela, recalculo e modal
- prova minima desta task: o unitario da funcao espera quantidade 3 para o mapa `{ svc: 3 }` num evento de outra duracao
- criterio de escalada: se a assinatura precisar de outro dado alem do mapa e das datas ja recebidas, parar e ajustar o design
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_core/project/project-decisions.md#D-07 Dinheiro em Float no legado`
- caminhos candidatos: `art56_server_v3/src/functions/quote-service-lines.ts`, `art56_server_v3/src/functions/calc-event-duration.ts`
- palavras-chave ou simbolos de busca: `hoursByServiceId`, `PER_HOUR`, `quantityFor`, `HttpBadRequestError`
- testes provaveis: `npm test -- --run src/functions/quote-service-lines.spec.ts`
- nao ler por padrao: `01-spec.md` inteiro, `04-tasks.md` inteiro, tela, `security`

### T-02 - Exigir as horas na criacao do orcamento

- objetivo: os dois POST de criacao gravam a quantidade informada e recusam servico por hora sem inteiro valido.
- cobre requisitos: `R-04`, `R-05`
- depende de: `T-01`
- pode rodar em paralelo com: `T-04`, `T-06`
- reusa: o mapa de `T-01` e os use cases de criacao que ja chamam `quoteServiceLines`
- prompt recomendado: `normal`
- estrategia de teste: unitario dos dois use cases de criacao
- cenarios obrigatorios: `PER_HOUR` com 3 horas grava quantidade 3; sem item no mapa nao chama o repositorio; 0 com evento de 4 horas nao grava; 0 com inicio e fim iguais grava quantidade 0; `FIXED` sem `serviceHours` continua gravando
- definition of done: os cenarios passam nos specs de criacao por pessoa e por dia; `updatePerPerson` e `updatePerDay` nao recebem o campo

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — POST publico que grava valor
- risco principal: aceitar a omissao e multiplicar pela duracao do evento
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: tela, GET/PUT do link, recalculo, edicao autenticada
- prova minima desta task: o unitario de criacao nao chama `create` quando o servico por hora vem sem horas
- criterio de escalada: se o Zod de criacao precisar passar a exigir uuid, parar; o id continua `z.string()`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Passada transversal`
  - `.cursor/framework_global/framework-libs/security/index.md#Quando esta lib e obrigatoria`
  - `.cursor/framework_core/project/project-decisions.md#D-05 Autorizacao parcialmente client-side`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/create-proposal-per-person/use-case-create-proposal-per-person.ts`, `art56_server_v3/src/zod/proposal/create-proposal-per-person-params-schema.ts`, `art56_server_v3/src/router/proposal.ts`
- palavras-chave ou simbolos de busca: `serviceHours`, `createPerPerson`, `createPerDay`, `quoteServiceLines`
- testes provaveis: `npm test -- --run src/use-cases/proposal/create-proposal-per-person/use-case-create-proposal-per-person.spec.ts`
- nao ler por padrao: `01-spec.md` inteiro, tela, `topics/`

### T-03 - Campo no formulario publico e duracao no painel

- objetivo: o cliente informa as horas ao marcar o servico, e o painel envia a duracao do evento sem campo novo.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-05`
- depende de: `T-02`
- pode rodar em paralelo com: `T-04`, `T-06`
- reusa: `serviceUnitLabel`, o estado `selectedServiceIds` e o passo "Como nos encontrou"
- prompt recomendado: `normal`
- estrategia de teste: browser dos formularios publicos; unitario da conta de horas do painel; lint dos arquivos tocados
- cenarios obrigatorios: marcar por hora mostra o campo e desmarcar esconde; fixo e por pessoa nao mostram; obrigatorio por hora mostra o campo com o checkbox travado; enviar vazio, 0 ou fracao nao cria e permanece no passo; enviar 3 horas chama o POST com `{ serviceId, hours: 3 }`; o painel, sem input, envia a duracao com pernoite e com a mesma hora
- definition of done: os cenarios de browser e o unitario da duracao passaram; clique no input nao desmarca o checkbox; lint sem erro novo nestes arquivos

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o formulario publico dispara o POST que grava valor
- risco principal: o campo existir e o POST seguir so com `serviceIds`
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: modal do link, recalculo, edicao autenticada, `ProposalEdit`
- prova minima desta task: no passo "Como nos encontrou", marcar o servico por hora mostra "Quantas horas?" e o envio leva `serviceHours`
- criterio de escalada: se o painel precisar de um input para nao quebrar a criacao, parar e voltar ao design
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Falhas, casos de borda e invariantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/forms/ClientPerPersonProposalForm.tsx`, `eventhub-vista-dashboard/src/components/proposal/forms/ClientPerDayProposalForm.tsx`, `eventhub-vista-dashboard/src/components/proposal/forms/PerPersonProposalForm.tsx`, `eventhub-vista-dashboard/src/components/proposal/forms/PerDayProposalForm.tsx`
- palavras-chave ou simbolos de busca: `selectedServiceIds`, `pricingType`, `serviceHours`, `Como nos encontrou`
- testes provaveis: browser em `/proposal/new` publico; unitario ao lado de `service-price-label.test.ts` para a duracao
- nao ler por padrao: `01-spec.md` inteiro, `security`, modal, `topics/`

### T-04 - Horas na leitura e na gravacao do link

- objetivo: o GET diz quais servicos pedem horas, e o PUT grava essa quantidade sem recotar o unitario ja salvo.
- cobre requisitos: `R-06`, `R-07`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`, `T-03`, `T-06`
- reusa: `update-public-proposal-services` e o mapa de `T-01`
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case e do controller
- cenarios obrigatorios: GET de item `PER_HOUR` traz `hourly` verdadeiro e `hours` nulo quando nao esta selecionado; item ja gravado traz a quantidade; a resposta nao contem `pricingType` nem `unitPrice`; PUT de servico novo sem horas nao chama `update`; mudar so as horas atualiza quantidade e valor pelo unitario gravado; ids e horas iguais nao chamam `update` nem historico; aprovado nao grava
- definition of done: os cenarios passam nos specs do use case e do controller; `price` vindo no corpo nao chega ao use case

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — PUT publico grava valor
- risco principal: recotar o unitario de uma linha ja enviada, ou aceitar hora ausente num servico novo
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: tela, criacao, recalculo de dia e locacao
- prova minima desta task: o unitario do PUT mostra quantidade 3 e o mesmo `unitPrice` ja gravado
- criterio de escalada: se a resposta precisar de `pricingType` para o modal, parar; o contrato e `hourly` e `hours`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_global/framework-libs/security/index.md#Quando esta lib e obrigatoria`
  - `.cursor/framework_core/project/project-decisions.md#D-05 Autorizacao parcialmente client-side`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/update-public-proposal-services/use-case-update-public-proposal-services.ts`, `art56_server_v3/src/zod/proposal/update-public-proposal-services-schema.ts`
- palavras-chave ou simbolos de busca: `serviceHours`, `hourly`, `sameSet`, `pricingType`
- testes provaveis: `npm test -- --run src/use-cases/proposal/update-public-proposal-services/use-case-update-public-proposal-services.spec.ts`
- nao ler por padrao: `01-spec.md` inteiro, tela, `topics/`

### T-05 - Campo de horas no modal do link

- objetivo: o cliente informa as horas no modal e ve o total gravado, ou o motivo da falha, sem perder o que digitou.
- cobre requisitos: `R-08`, `R-10`
- depende de: `T-04`
- pode rodar em paralelo com: `T-03`, `T-06`
- reusa: `UpdateProposalServicesDialog` e `proposalService.updatePublicProposalServices`
- prompt recomendado: `normal`
- estrategia de teste: browser em `/proposal/:id/view`; lint dos arquivos tocados
- cenarios obrigatorios: item `hourly` marcado mostra o campo preenchido com `hours`; item nao horario nao mostra; confirmar sem horas nao grava; confirmar com 3 horas atualiza o total; aprovado mostra a mensagem e nao grava; falha de rede conserva o total da pagina e o numero digitado
- definition of done: os cenarios de browser passaram; uma frase em `product/02-business-rules.md#Proposal` e o complemento em `product/03-user-profiles.md#Cliente proponente`; lint sem erro novo nestes arquivos

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o modal grava valor pelo link publico
- risco principal: confirmar sem enviar `serviceHours`, ou limpar o campo quando a rede falha
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: formulario de criacao, recalculo, preco unitario na tela
- prova minima desta task: no modal, o servico por hora marcado pede as horas e confirmar envia `serviceHours`
- criterio de escalada: se o GET nao trouxer `hourly`, parar em `T-04` em vez de inferir pelo texto "/hora"
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
  - `.cursor/framework_core/product/02-business-rules.md#Proposal`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/UpdateProposalServicesDialog.tsx`, `eventhub-vista-dashboard/src/services/proposal.service.ts`
- palavras-chave ou simbolos de busca: `PublicServiceChoice`, `serviceHours`, `hourly`, `updatePublicProposalServices`
- testes provaveis: browser em `/proposal/:id/view`; `npm run lint` nos arquivos do modal
- nao ler por padrao: `01-spec.md` inteiro, criacao do orcamento, `topics/`

### T-06 - Conservar as horas no recalculo publico

- objetivo: mudar dia, convidados ou horario do evento nao substitui a quantidade ja gravada do servico por hora.
- cobre requisitos: `R-09`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`, `T-03`, `T-04`, `T-05`
- reusa: `recalculate-public-proposal` e o mapa de `T-01`
- prompt recomendado: `smart`
- estrategia de teste: unitario do use case de recalculo
- cenarios obrigatorios: linha por hora com quantidade 3 continua 3 quando o evento passa a durar 8 horas, e o valor usa o unitario atual; servico por pessoa segue os convidados novos; linha por hora sem quantidade usa a duracao nova
- definition of done: os cenarios passam no spec de `recalculate-public-proposal`; `basePrice` e horas extras da locacao continuam sendo recalculados

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — o recalculo publico regrava o total
- risco principal: a duracao nova do evento apagar as horas escolhidas
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: tela, criacao, modal, edicao autenticada
- prova minima desta task: o unitario de recalculo grava quantidade 3 depois de o evento passar de 5 para 8 horas
- criterio de escalada: se a linha gravada nao trouxer `quantity`, parar e ler o repositorio antes de inventar outra coluna
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_core/project/project-decisions.md#D-06 Datas de evento com semantica wall-clock`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/recalculate-public-proposal/use-case-recalculate-public-proposal.ts`
- palavras-chave ou simbolos de busca: `hoursByServiceId`, `quoteServiceLines`, `quantity`, `guestNumber`
- testes provaveis: `npm test -- --run src/use-cases/proposal/recalculate-public-proposal/use-case-recalculate-public-proposal.spec.ts`
- nao ler por padrao: `01-spec.md` inteiro, tela, `security`
