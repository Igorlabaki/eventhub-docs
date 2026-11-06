# Tasks — Limite de horas do servico

## Ordem macro

1. `T-01` recusa no servidor horas acima da duracao, sem mexer na cotacao do recalculo.
2. `T-02` mostra a frase na hora nos dois formularios e no modal. Pode rodar em paralelo com `T-01`: a frase ja esta fechada no design.

## Tasks

### T-01 - Recusar horas acima da duracao na API

- objetivo: criacao por pessoa, criacao por dia e gravacao publica recusam inteiro acima da duracao e nao gravam; o recalculo conserva a quantidade.
- cobre requisitos: `R-04`, `R-05`, `R-06`, `R-07`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`
- reusa: `assertChosenServiceHours`, `resolvePublicHours`, `calcEventDuration`
- prompt recomendado: `smart`
- estrategia de teste: unitario dos use cases e de `quantityFor`
- cenarios obrigatorios: 5 horas num evento de 4 lanca a frase nova e nao grava, na criacao por pessoa, na criacao por dia e no PUT publico; 4 horas grava; 0 com duracao 0 continua gravando; fracao continua na frase de inteiro; `quantityFor` com mapa 5 e evento de 4 devolve quantidade 5
- definition of done: esses cenarios passam; `quantityFor` nao ganhou o teto; Zod segue 0 a 8760

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a quantidade entra no valor publico
- risco principal: colocar o teto em `quantityFor` e o recalculo passar a falhar
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: tela, painel, Zod, produto e recalculo alem de provar que a quantidade antiga permanece
- prova minima desta task: o unitario do PUT publico espera a frase com "(4 horas)" quando o corpo pede 5 e o evento dura 4, e o repositorio nao recebe `update`
- criterio de escalada: se a criacao nao tiver `startDate` e `endDate` antes do assert, parar e ajustar o design
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
  - `.cursor/framework_core/project/project-decisions.md#D-06`
- caminhos candidatos: `quote-service-lines.ts`, `use-case-create-proposal-per-person.ts`, `use-case-create-proposal-per-day.ts`, `use-case-update-public-proposal-services.ts`
- palavras-chave ou simbolos de busca: `assertChosenServiceHours`, `resolvePublicHours`, `quantityFor`, `calcEventDuration`
- testes provaveis: `npm test -- --run` nos specs de criacao por pessoa, criacao por dia, gravacao publica e `quote-service-lines`
- nao ler por padrao: `01-spec.md` inteiro, formularios, `topics/`

### T-02 - Mostrar a frase assim que as horas passam da duracao

- objetivo: modal e criacao publica mostram a frase no campo assim que o inteiro passa da duracao, e confirmar ou enviar nao seguem.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-08`, `R-09`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`
- reusa: `eventDurationHours`, `wallClockDate`, `chosenServiceHours`, o `role="alert"` do campo
- prompt recomendado: `normal`
- estrategia de teste: unitario do helper e browser do modal e de um formulario de criacao
- cenarios obrigatorios: digitar 5 com duracao 4 mostra a frase antes de confirmar e o texto permanece; digitar 4 tira a frase; apagar tira a frase de duracao; modal aberto com 10 e evento de 4 ja mostra a frase e confirmar nao chama a API; fim anterior ao inicio no formulario por pessoa nao mostra a frase de duracao; servico fixo continua sem o campo
- definition of done: o helper cobre esses casos; o browser confirma a frase no modal e num formulario antes do envio; `product/02-business-rules.md#Proposal` e `product/03-user-profiles.md#Cliente proponente` dizem que a quantidade nao passa da duracao do evento

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o campo decide o valor que o cliente tenta gravar
- risco principal: usar o rotulo arredondado da pagina e divergir da duracao que a API mede
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: painel, API, recalculo e preco fixo ou por pessoa
- prova minima desta task: no modal, com evento de 4 horas, digitar 5 mostra a frase sem confirmar; voltar para 4 esconde a frase
- criterio de escalada: se a duracao por dia nao puder ser montada com `wallClockDate` e o check-in/check-out do venue, parar e ajustar o design
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Reuso previsto`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
  - `.cursor/framework_core/product/02-business-rules.md#Proposal`
- caminhos candidatos: `event-duration.ts`, `ClientPerPersonProposalForm.tsx`, `ClientPerDayProposalForm.tsx`, `UpdateProposalServicesDialog.tsx`, `ProposalView.tsx`
- palavras-chave ou simbolos de busca: `Quantas horas?`, `chosenServiceHours`, `eventDurationHours`, `hourErrors`
- testes provaveis: `npm test -- --run` no spec de `event-duration`; no browser, o fluxo da prova minima
- nao ler por padrao: `01-spec.md` inteiro, `security`, use cases do backend, `topics/`
