# Solicitacao da Tarefa

## Nome sugerido da tarefa

Esconder o preco do servico no orcamento e abrir foto e descricao

## Resumo da solicitacao

Quem preenche o orcamento publico deixa de ver qualquer preco na lista de servicos. Se o servico tiver descricao ou foto, um icone de interrogacao ao lado do titulo abre um modal com o que existir.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao. A tela ja e publica e ja lista os servicos; este request nao muda o que e enviado nem cria upload
- risco principal: o clique no interrogacao marcar ou desmarcar o servico, ou o preco sumir tambem da proposta, que e onde a pessoa passa a ver o valor
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: calculo de preco, proposta publica ja gerada, dialogo de adicionar servico na proposta, formularios de orcamento do painel, schema e API
- prova minima desta execucao: em `/venue/:id/form`, no passo dos servicos, nenhum valor em reais aparece; servico com descricao ou foto mostra `?` ao lado do titulo; o clique abre um modal com a foto e a descricao que existirem e nao altera a marcacao; servico sem os dois nao mostra o icone; o envio continua no ultimo passo
- criterio de escalada: promover para `normal` e dividir com `tasking/task-request-repo-split-prompt.md` se a lista que o formulario ja usa nao trouxer descricao e foto; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/proposal/forms/ClientPerPersonProposalForm.tsx` na lista `Servicos`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/passos-formulario-publico-orcamento-request.md#Objetivo da mudanca`
- caminhos candidatos: formulario publico por pessoa; formulario publico por dia; pagina `/venue/:id/form`, ultimo passo
- palavras-chave ou simbolos de busca: `Servicos`, `serviceUnitLabel`, `ClientPerPersonProposalForm`, `ClientPerDayProposalForm`
- testes provaveis: lista sem cifra; icone so com descricao ou foto; modal com um dos dois e com os dois; clique no icone sem mudar o checkbox; envio do formulario
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com o formulario publico do espaco AR756 no passo "Como nos encontrou". A lista mostra Limpeza, Recepcionista, Seguranca e Painel de Led com valor em reais ao lado do nome. A pessoa que faz o orcamento nao deve ver preco; o valor aparece so depois. Servico com descricao ou foto ganha um `?` ao lado do titulo, e o clique abre um modal com a foto e a descricao.

## Problema atual

No ultimo passo do formulario publico, cada servico mostra o preco, inclusive por hora. A pessoa ve o valor antes de a proposta existir. Descricao e foto do servico, quando existem, nao tem um atalho ao lado do titulo.

## Objetivo da mudanca

No formulario publico, a lista de servicos nao mostra preco, e um `?` ao lado do titulo abre a foto e a descricao do servico quando pelo menos uma das duas existir.

## Escopo inicial percebido

Ajuste visual da lista de servicos nos dois formularios publicos que ja existem. Sem campo novo, sem contrato e sem schema. O texto de obrigatoriedade e a pergunta de horas permanecem.

## Itens incluidos neste request

- nenhum preco na lista de servicos do formulario publico
- icone `?` ao lado do titulo quando o servico tiver descricao ou foto
- clique no icone abre um modal com a foto e a descricao que existirem
- servico sem descricao e sem foto fica sem o icone
- o formulario por pessoa e o formulario por dia seguem a mesma regra

## Requisitos implicitos ja visiveis

- o preco continua existindo no cadastro e na proposta; some so desta lista
- "Obrigatorio a partir de N pessoas" continua visivel
- servico por hora continua pedindo quantas horas quando marcado
- o clique no `?` nao marca nem desmarca o checkbox
- o modal mostra so o que o servico tiver: foto, descricao ou as duas
- logo, cores, passos, aba, rodape e skeleton do espaco nao mudam de papel

## Casos de erro e borda ja percebidos

- servico sem descricao e sem foto: nao ha icone nem modal
- servico so com descricao, ou so com foto: o icone aparece e o modal mostra apenas o que existe
- servico obrigatorio: continua marcado e desabilitado; o `?`, se houver, ainda abre o modal
- fechar o modal: a marcacao do servico permanece como estava
- espaco com pernoite e espaco sem pernoite: os dois formularios publicos escondem o preco da mesma forma

## Dependencias

- os dois formularios publicos ja existem em `/venue/:id/form`
- descricao e foto ja fazem parte do cadastro do servico
- a proposta publica ja mostra o valor depois que o orcamento existe

## Restricoes e cuidados

- nao alterar o calculo nem o payload do envio
- nao esconder o preco na proposta publica
- nao alterar o formulario de orcamento do painel
- nao criar campo, upload nem migration
- nao fazer o clique no `?` disparar o checkbox

## Perguntas em aberto

- O formulario do painel tambem esconde o preco? Premissa: nao; so quem preenche o formulario publico.
- O dialogo "Adicionar servico" da proposta ja gerada tambem esconde o valor? Premissa: nao; ali a pessoa ja esta na proposta e o valor continua visivel.
- O icone e um `?` simples ao lado do titulo? Premissa: sim, sem texto extra do tipo "saiba mais".
- Servico sem foto mostra o modal so com a descricao? Premissa: sim; o mesmo vale para servico sem descricao e com foto.

## Prioridade sugerida

Media. O formulario publico funciona; o preco aparece cedo demais e o detalhe do servico nao tem atalho.

## Faixa sugerida para task workflow

- `A` — a mesma lista em dois formularios publicos, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: esconde um rotulo e abre um detalhe que o cadastro do servico ja tem; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `preco-e-detalhe-servico-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar` a entrega (`fw:review`)
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
