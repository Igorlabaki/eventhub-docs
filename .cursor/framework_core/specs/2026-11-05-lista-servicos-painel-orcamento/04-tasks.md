# Tasks — Lista de servicos no painel

## Ordem macro

`T-01` e `T-02` podem andar juntas. `T-03` espera as duas. O deploy da edicao junta `T-01` e `T-03`.

## Tasks

### T-01 - Aceitar as horas na edicao do orcamento

- objetivo: os dois PUT de edicao gravam a quantidade escolhida no servico por hora e recusam hora ausente ou invalida
- cobre requisitos: `R-06`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`
- reusa: `assertChosenServiceHours`, `serviceHoursMap` e `quoteServiceLines` da criacao
- prompt recomendado: normal
- estrategia de teste: unitario do Zod e dos dois use cases de edicao
- cenarios obrigatorios:
  - servico por hora com 3 horas grava quantidade 3 e valor unitario vezes 3
  - ausencia, zero com evento longo, fracao e hora acima da duracao nao gravam e nao usam a duracao do evento
  - zero com duracao 0 grava
  - servico fixo sem `serviceHours` grava quantidade 1
  - o Zod da edicao por pessoa e por dia conserva `serviceHours`
  - permuta tambem recebe as linhas com a quantidade escolhida
- definition of done:
  - os dois schemas e os dois use cases seguem `03-design.md#Contratos e dados`
  - o teste que esperava a edicao sem `serviceHours` passa a esperar o campo
  - `npm test -- --run` verde nos arquivos tocados
  - nenhuma coluna nova

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a quantidade muda o valor da linha
- risco principal: esquecer um ramo de tipo e a permuta continuar cotando pela duracao
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: telas, link publico, criacao
- prova minima desta task: os cenarios obrigatorios verdes no unitario dos dois PUT
- criterio de escalada: parar se a edicao precisar de coluna ou de outro calculo que nao `quoteServiceLines`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_core/project/project-decisions.md#D-07`
  - `.cursor/framework_global/framework-libs/security/index.md#Quando esta lib e obrigatoria`
- caminhos candidatos: `update-proposal-per-person-params-schema.ts`, `update-proposal-per-day--params-schema.ts`, os dois use cases de update, `use-case-create-proposal-per-person.ts` so como modelo, o teste "a edicao por pessoa nao recebe serviceHours"
- palavras-chave ou simbolos de busca: `serviceHours`, `assertChosenServiceHours`, `hoursByServiceId`, `quoteServiceLines`
- testes provaveis: `npm test -- --run` nos specs de update por pessoa, update por dia e no spec de criacao que afirma o Zod da edicao
- nao ler por padrao: formularios publicos, `topics/`, specs de outras frentes

### T-02 - Listar os servicos ao criar orcamento no painel

- objetivo: criar por pessoa e por dia no painel mostra a lista do link e envia as horas digitadas
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-08`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`
- reusa: `chosenServiceHours`, `serviceHourFieldError`, `sameDayEventHours`, `stayEventHours`, `serviceUnitLabel` e a juncao de obrigatorios do link
- prompt recomendado: normal
- estrategia de teste: browser dos dois formularios de criar; lint nos arquivos tocados
- cenarios obrigatorios:
  - cada servico fica em uma linha e o preco continua ao lado do nome
  - minimo de pessoas mostra o texto; no minimo o checkbox marca e trava; abaixo destrava e continua marcado
  - marcar servico por hora mostra "Quantas horas?" e desmarcar esconde e limpa
  - servico fixo nao mostra o campo
  - vazio, zero e hora acima da duracao nao criam o orcamento; o texto digitado fica
  - enviar 3 horas grava quantidade 3
  - o mesmo vale no formulario por dia, com teto de check-in e check-out
  - o link publico nao muda
- definition of done:
  - `DashboardServiceChoices` existe e as duas telas de criar usam ele
  - nenhuma chamada a `durationServiceHours` nesses dois formularios
  - `npm run lint` sem erro novo nos arquivos tocados
  - os cenarios obrigatorios vistos no browser

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o formulario envia a quantidade que define o valor
- risco principal: a lista mudar e o submit continuar mandando a duracao do evento
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: tela de editar, backend, link publico, foto e descricao
- prova minima desta task: criar por pessoa e por dia no browser com os cenarios obrigatorios
- criterio de escalada: parar se a criacao deixar de aceitar `serviceHours` ou se o componente precisar absorver o JSX publico
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Reuso previsto`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Reuso previsto`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
  - `.cursor/framework_global/framework-libs/security/index.md#Quando esta lib e obrigatoria`
- caminhos candidatos: a lista em `ClientPerPersonProposalForm.tsx` so como modelo, `PerPersonProposalForm.tsx`, `PerDayProposalForm.tsx`, `src/lib/event-duration.ts`
- palavras-chave ou simbolos de busca: `durationServiceHours`, `chosenServiceHours`, `rpaMinPeople`, `Quantas horas?`, `Obrigatório a partir de`
- testes provaveis: browser em criar orcamento por pessoa e por dia; `npm run lint` nos arquivos tocados
- nao ler por padrao: use cases de update, modal do link, `topics/`

### T-03 - Listar os servicos ao editar orcamento no painel

- objetivo: a tela de editar usa a mesma lista, abre com a quantidade gravada e salva as horas digitadas
- cobre requisitos: `R-03`, `R-04`, `R-07`, `R-08`
- depende de: `T-01`, `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: `DashboardServiceChoices` e `chosenServiceHours`
- prompt recomendado: normal
- estrategia de teste: browser da tela de editar; lint nos arquivos tocados
- cenarios obrigatorios:
  - a lista e a mesma de criar, com preco e texto de obrigatorio
  - servico por hora abre com a quantidade gravada
  - trocar 3 por 2 grava 2
  - vazio e hora acima da duracao nao salvam e o texto fica
  - so abrir a tela nao grava
  - orcamento antigo mostra a quantidade que ja tinha, sem troca automatica
  - o link publico nao muda
- definition of done:
  - `ProposalEdit` envia `serviceHours` e nao depende da duracao do evento
  - `UpdateProposalPerPersonDTO` inclui `serviceHours`
  - `product/02-business-rules.md#Proposal` diz que criar e editar no painel perguntam a quantidade e gravam essa linha
  - `npm run lint` sem erro novo nos arquivos tocados
  - os cenarios obrigatorios vistos no browser

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — editar grava o valor da linha
- risco principal: o campo aparecer e o PUT seguir sem `serviceHours`
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: criar tela de edicao de pernoite, mudar o backend, mexer no link publico
- prova minima desta task: editar no browser um orcamento com servico por hora, de 3 para 2, e a linha ficar com 2
- criterio de escalada: parar se a tela de editar nao for a atualizacao por pessoa
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_core/product/02-business-rules.md#Proposal`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
- caminhos candidatos: `ProposalEdit.tsx`, `DashboardServiceChoices.tsx`, `UpdateProposalPerPersonDTO` em `types/proposal.ts`
- palavras-chave ou simbolos de busca: `updateProposalPerPerson`, `proposalServices`, `quantity`, `serviceHours`
- testes provaveis: browser em `/proposal/:id/edit`; `npm run lint` nos arquivos tocados
- nao ler por padrao: `PUT /updatePerDay`, formularios publicos, `topics/`
