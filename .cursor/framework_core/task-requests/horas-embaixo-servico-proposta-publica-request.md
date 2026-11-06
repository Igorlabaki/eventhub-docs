# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mostrar as horas do servico e trocar o botao para Alterar servicos

## Resumo da solicitacao

No card "Sua experiencia inclui" da proposta publica, o servico cobrado por hora passa a mostrar, embaixo do nome, quantas horas a pessoa escolheu. O botao do card deixa de dizer "Adicionar servico" e passa a dizer "Alterar servicos".

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — so o texto da lista publica; preco, quantidade gravada e contrato nao mudam
- risco principal: a hora aparecer no servico errado, o numero nao ser o que a pessoa escolheu, o aviso de obrigatoriedade sumir, ou o botao continuar "Adicionar servico"
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: quantidade de pessoas no servico por pessoa; titulo de dentro do modal; preco, calculo e card "Seu investimento"
- prova minima desta execucao: no link publico, um servico por hora (como Painel de Led com 4 horas) mostra "4 horas." embaixo do nome; servico que nao e por hora nao ganha essa linha; o aviso "Obrigatorio a partir de N pessoas." continua; o botao do card diz "Alterar servicos"
- criterio de escalada: promover para `normal` se a lista publica nao trouxer as horas ja escolhidas e for preciso mudar o contrato; `spec` nao se aplica
- nivel de autonomia: `L2`
- camadas transversais: `design`; `security`, `database`, `observability` e `patterns` nao entram

## Minimal Read Set

- ler primeiro: a lista "Sua experiencia inclui" em `eventhub-vista-dashboard/src/pages/ProposalView.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `ProposalView.tsx`, lista de servicos do link publico
- palavras-chave ou simbolos de busca: `Sua experiência inclui`, `Obrigatório a partir de`, `Adicionar serviço`, `PER_HOUR`
- testes provaveis: abrir o link publico com um servico por hora, conferir as horas embaixo do nome e o botao "Alterar servicos"
- nao ler por padrao: `security`, `database`, `topics/`, backend, schema e a spec de horas alem do numero que a proposta ja guarda

## Contexto informado na entrada

Pedido em chat, com print do card "Sua experiencia inclui". O servico por hora deve mostrar embaixo do nome quantas horas a pessoa escolheu. No mesmo card, o botao "Adicionar servico" passa a "Alterar servicos". A quantidade de pessoas ficou de fora.

## Problema atual

A linha pequena debaixo do nome so fala que o servico e obrigatorio a partir de N pessoas. Servico por hora, como o Painel de Led, fica sem dizer quantas horas foram escolhidas. O botao do card diz "Adicionar servico".

## Objetivo da mudanca

No card "Sua experiencia inclui", cada servico por hora mostra embaixo do nome a quantidade de horas escolhida, e o botao do card diz "Alterar servicos".

## Escopo inicial percebido

Texto da lista de servicos inclusos e o rotulo do botao no link publico do orcamento. Um repo, uma tela.

## Itens incluidos neste request

- a quantidade de horas embaixo do nome, so no servico cobrado por hora
- o mesmo estilo visual do aviso "Obrigatorio a partir de N pessoas."
- singular e plural: "1 hora." e "4 horas."
- o botao do card, de "Adicionar servico" para "Alterar servicos"

## Requisitos implicitos ja visiveis

- o aviso de obrigatoriedade continua no servico que ja o tem
- servico de valor fixo e servico por pessoa nao ganham linha de horas
- o numero e o que ja foi escolhido para aquele servico, sem pedir de novo
- o card "Seu investimento" nao muda

## Casos de erro e borda ja percebidos

- servico por hora que tambem e obrigatorio: as duas informacoes aparecem; o aviso de obrigatoriedade nao sai
- 1 hora no singular; 2 ou mais no plural
- servico por hora sem quantidade escolhida nao inventa um numero
- nome longo nao esconde a linha de horas no celular
- o rotulo "Alterar servicos" cabe no botao no celular sem cortar o texto

## Dependencias

- a quantidade de horas ja escolhida precisa estar disponivel na lista publica do orcamento
- o campo de horas do formulario e do modal ja existe; este pedido so mostra o numero na lista

## Restricoes e cuidados

- nao alterar preco, calculo, obrigatoriedade nem o que e gravado
- nao criar campo novo de pessoas
- nao mudar o que o botao abre; so o texto visivel
- nao ler nem versionar valores de `.env`

## Perguntas em aberto

- O texto leva ponto final, como o aviso de obrigatoriedade? Premissa: sim. "4 horas." e "1 hora."
- Servico por hora e obrigatorio mostra os dois? Premissa: sim, no mesmo bloco debaixo do nome.
- A quantidade de pessoas entra? Premissa: nao.
- O titulo de dentro do modal, hoje "Adicionar servico", tambem muda? Premissa: nao. So o botao do card vira "Alterar servicos".
- O card "Seu investimento" tambem muda? Premissa: nao. A hora aparece so em "Sua experiencia inclui".

## Prioridade sugerida

Media. A lista publica do que o evento inclui nao diz as horas do servico por hora, e o botao do card ainda diz "Adicionar servico".

## Faixa sugerida para task workflow

- `A` — texto da lista e do botao, um card, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: mostra na lista um numero que o orcamento ja tem e corrige o rotulo do botao; nao abre fluxo, contrato nem schema

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `horas-embaixo-servico-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; horas embaixo do servico por hora e botao Alterar servicos no card; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
