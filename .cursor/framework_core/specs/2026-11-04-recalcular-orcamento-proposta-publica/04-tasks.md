# Tasks — Recalcular o orcamento no link publico

## Ordem macro

`T-01` grava a conta. `T-02` publica a rota e o corpo de resposta. `T-03` liga o modal. `T-03` depende de `T-02`.

## Tasks

### T-01 - Calcular e gravar o recálculo publico

- objetivo: o use case aplica a tabela da casa e grava so data, convidados e valor, ou recusa sem gravar.
- cobre requisitos: `R-04`, `R-06`, `R-07`, `R-08`, `R-09`, `R-11`, `R-12`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: helpers citados em `03-design.md#Reuso previsto` e o update de proposta ja existente
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case com repositorios falsos
- cenarios obrigatorios:
  - `PER_PERSON` muda convidados e horas, lanca hora extra so acima da duracao padrao e soma o servico ja ligado
  - total abaixo do minimo troca a locacao pelo minimo e tira as horas extras
  - `PER_PERSON_HOUR` sem receita mensal usa duracao × convidados e nao lanca hora extra
  - `PER_DAY` no mesmo dia civil cobra 1 dia, grava os convidados e zera hora extra
  - aprovado, pago, acima da capacidade, mais de um dia civil, fim apos meia-noite, `BARTER` e `TIERED` nao chamam update
  - historico sem `userId` com a frase do `R-12`
- definition of done: os cenarios passam em `npm test -- --run`; nenhuma coluna alem das sete de `03-design.md#Contratos e dados` e escrita; create e update do painel ficam como estao.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a conta vai servir uma gravacao publica de valor
- risco principal: gravar total de `calcCustomTotalAmount` ou zerar a diaria do mesmo dia
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: rota HTTP, modal, agenda, migration, refatorar create
- prova minima desta task: os seis cenarios do use case verdes
- criterio de escalada: parar se a conta exigir coluna nova ou mudanca no create
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Reuso previsto`
  - `.cursor/framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md#Conceitos e roteamento`
  - `.cursor/framework_core/project/project-decisions.md#D-06`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/update-proposal-per-person/use-case-update-proposal-per-person.ts`, `art56_server_v3/src/functions/transform-date.ts`, `art56_server_v3/src/functions/wall-clock-datetime.ts`
- palavras-chave ou simbolos de busca: `adjustProposalUnitPrice`, `calcExtraHoursQty`, `resolveVenueMinimumPrice`, `PER_PERSON_HOUR`, `hasMonthlyRevenue`
- testes provaveis: `npm test -- --run` no spec do use case novo
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, frontend, `calcCustomTotalAmount`

### T-02 - Publicar a rota de recálculo

- objetivo: `PUT /proposal/presentation/:proposalId/recalculate` chama o use case sem login e devolve so o recorte.
- cobre requisitos: `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `handleErrors`, factory dos outros use cases de proposal, o use case de `T-01`
- prompt recomendado: `smart`
- estrategia de teste: unitario do controller com use case falso
- cenarios obrigatorios:
  - sucesso responde 200 e `data` tem so `id`, `startDate`, `endDate`, `guestNumber`, `basePrice`, `extraHoursQty`, `extraHourPrice`, `totalAmount`
  - `data` nao tem `pricePerPerson`, `pricePerDay`, `pricePerPersonDay`, `pricePerPersonHour`, dono, pagamento nem documento
  - corpo invalido nao chama o use case
  - a rota em `proposal.ts` nao usa `ensureAuthenticate`
- definition of done: o spec do controller passa; a rota esta registrada; a mensagem de erro continua a do `handleErrors`.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — endpoint publico que grava valor
- risco principal: a resposta levar a tabela de preco ou a rota exigir login e o modal nao conseguir gravar
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: mudar a conta do `T-01`, modal, autenticar a rota
- prova minima desta task: os quatro cenarios do controller verdes
- criterio de escalada: parar se o recorte exigir campo que `03-design.md#Contratos e dados` nao lista
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md#2. Revisar autenticacao e autorizacao`
  - `.cursor/framework_global/framework-libs/node/references/node-express-coding-style.md`
- caminhos candidatos: `art56_server_v3/src/router/proposal.ts`, `art56_server_v3/src/use-cases/proposal/get-proposal-presentation/controller-get-proposal-presentation.ts`
- palavras-chave ou simbolos de busca: `presentation/:proposalId`, `handleErrors`, `ensureAuthenticate`
- testes provaveis: spec do controller novo
- nao ler por padrao: `01-spec.md`, frontend, use cases de create

### T-03 - Modal de dia, convidados e horas

- objetivo: o cliente abre o modal, valida os tres campos e ve o card atualizado ou o motivo da falha.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-05`, `R-13`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: `Dialog`, `zodResolver`, `setCurrentProposal`, o card "Seu investimento"
- prompt recomendado: `normal`
- estrategia de teste: browser na pagina publica; `npm run lint` no arquivo do modal
- cenarios obrigatorios:
  - o botao abre o modal com dia, convidados e horas atuais e nenhum outro campo
  - convidado vazio e hora 0 mostram erro no campo e nao chamam a rota
  - convidado acima da capacidade mostra o maximo
  - Recalcular valido atualiza locacao, total, convidados e horario e o modal fecha
  - resposta de falha deixa os valores digitados, mostra o alerta e o total da pagina continua o anterior
  - o botao fica desabilitado enquanto a requisicao nao volta
- definition of done: os seis fluxos vistos no browser; lint sem erro novo; o store de proposta continua o unico estado desse dado.

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o modal dispara a gravacao publica; esta task nao muda a regra do servidor
- risco principal: recalcular na tela, ou limpar o formulario quando a gravacao falha
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: conta, rota, painel, WhatsApp verde, servicos
- prova minima desta task: os seis fluxos do modal no `/proposal/:id/view`
- criterio de escalada: parar se a pagina precisar de uma biblioteca de estado nova
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Visao geral da solucao`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Visao geral da solucao`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
  - `.cursor/framework_global/framework-libs/react/references/react-coding-style.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalView.tsx`, `eventhub-vista-dashboard/src/components/ui/dialog.tsx`, `eventhub-vista-dashboard/src/components/proposal/forms/PerPersonProposalForm.tsx`
- palavras-chave ou simbolos de busca: `Seu investimento`, `zodResolver`, `setCurrentProposal`, `DialogContent`
- testes provaveis: fluxo no browser e `npm run lint`
- nao ler por padrao: `01-spec.md`, `security`, backend alem do contrato em `03-design.md#Contratos e dados`
