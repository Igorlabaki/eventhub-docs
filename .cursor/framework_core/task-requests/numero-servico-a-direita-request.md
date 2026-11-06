# Solicitacao da Tarefa

## Nome sugerido da tarefa

Colocar o numero do servico a direita da linha

## Resumo da solicitacao

No passo "Como nos encontrou", o numero que o cliente informa para um servico deixa de ficar embaixo do nome e passa a ficar na mesma linha, no fim do card, do lado oposto ao checkbox.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — so posicao do campo; a quantidade enviada nao muda
- risco principal: o numero sumir da linha, o aviso de erro se separar do campo, ou a linha quebrar no celular e o campo sair do card
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: criar campo novo de quantidade de pessoas; mudar preco, quantidade gravada, validacao ou obrigatoriedade; painel interno
- prova minima desta execucao: no passo "Como nos encontrou", marcar "Painel de Led" mostra a caixa de horas no fim da mesma linha, a direita; desmarcar esconde a caixa; servico sem numero continua uma linha so; o mesmo vale no modal de servicos do link publico
- criterio de escalada: promover para `normal` se for preciso criar o campo de pessoas ou mudar contrato; `spec` nao se aplica
- nivel de autonomia: `L2`
- camadas transversais: `design`; `security`, `database`, `observability` e `patterns` nao entram

## Minimal Read Set

- ler primeiro: a lista de servicos do passo "Como nos encontrou" em `eventhub-vista-dashboard/src/components/proposal/forms/ClientPerPersonProposalForm.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `ClientPerPersonProposalForm`, `ClientPerDayProposalForm` e `UpdateProposalServicesDialog`
- palavras-chave ou simbolos de busca: `Quantas horas?`, `asksHours`, `PER_HOUR`
- testes provaveis: abrir o passo "Como nos encontrou" e o modal de servicos do link publico, marcar um servico por hora e conferir a caixa no fim da linha
- nao ler por padrao: `security`, `database`, `topics/`, backend, schema e a spec de horas alem do que o campo ja faz

## Contexto informado na entrada

Pedido em chat, com print do passo "Como nos encontrou". "Painel de Led" marcado mostra "Quantas horas?" e a caixa com `4` embaixo do nome. O pedido: quando for quantas horas, ou quando o servico depender de pessoas e o cliente tiver que informar o numero, esse numero fica do lado, no fim do card, do outro lado — nao embaixo.

## Problema atual

A caixa numerica do servico por hora abre numa linha nova, recuada, abaixo do checkbox, do nome e do preco.

## Objetivo da mudanca

Com o servico marcado, a caixa do numero fica na mesma linha, encostada no fim do card, do lado oposto ao checkbox.

## Escopo inicial percebido

Reposicionar o campo que ja aparece na lista de servicos dos formularios publicos de orcamento e no modal de servicos do link publico.

## Itens incluidos neste request

- a caixa de "Quantas horas?" no fim da linha do servico, nos dois formularios publicos
- a mesma posicao no modal de servicos do link publico
- o mesmo lugar para um numero que a lista ja peca quando o servico depende de pessoas

## Requisitos implicitos ja visiveis

- o rotulo curto do campo continua junto da caixa
- o aviso de erro continua junto da caixa
- desmarcar o servico esconde a caixa
- servico sem numero nao ganha caixa
- o texto "Obrigatorio a partir de N pessoas" continua ao lado do nome
- checkbox, preco e envio do formulario nao mudam

## Casos de erro e borda ja percebidos

- nome longo mais texto de obrigatoriedade nao podem empurrar a caixa para fora do card
- no celular a caixa continua no fim da linha, ou quebra sem perder o campo
- servico por hora obrigatorio, com checkbox travado, tambem mostra a caixa a direita
- mais de um servico com numero: cada caixa fica na propria linha

## Dependencias

- o campo de horas ja existe na lista de servicos do passo "Como nos encontrou" e no modal do link publico
- a spec `specs/2026-11-04-horas-servico-por-hora/` ja define quando a caixa aparece; este pedido so muda o lugar

## Restricoes e cuidados

- nao criar um campo de quantidade de pessoas que a lista ainda nao tem
- nao alterar a conta, a validacao nem o que e enviado
- nao ler nem versionar valores de `.env`

## Perguntas em aberto

- "Depender de pessoas" pede um numero novo? Premissa: nao. So muda de lugar o numero que a lista ja mostra. Hoje isso e a caixa de horas. Servico por pessoa segue usando os convidados do passo anterior.
- O modal do link publico entra? Premissa: sim, porque a caixa de horas tambem nasce embaixo da linha ali.
- O rotulo "Quantas horas?" vai junto? Premissa: sim, curto, ao lado ou acima da caixa, no fim da linha.

## Prioridade sugerida

Media. O campo ja existe; a posicao embaixo alonga o card do passo.

## Faixa sugerida para task workflow

- `A` — uma lista, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: reposiciona um campo que os formularios publicos e o modal do link ja mostram

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `numero-servico-a-direita-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; caixa de horas no fim da linha nos dois formularios publicos e no modal; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
