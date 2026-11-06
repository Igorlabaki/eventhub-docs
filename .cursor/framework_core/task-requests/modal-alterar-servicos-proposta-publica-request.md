# Solicitacao da Tarefa

## Nome sugerido da tarefa

Ajustar titulo, total por hora e ordem no modal de servicos da proposta publica

## Resumo da solicitacao

No modal aberto por "Alterar servicos" na proposta publica, o titulo passa a "Alterar servicos", o servico por hora mostra o total das horas escolhidas, e a lista segue a ordem custo fixo, custo por hora, custo por pessoa.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — a pagina e publica, mas a mudanca e titulo, ordem e o numero do servico por hora; o que a confirmacao grava nao muda
- risco principal: o modal mostrar o preco da hora como se fosse o total, a ordem divergir dos cards, ou o titulo continuar "Adicionar servico"
- repos tocados: `frontend` (`eventhub-vista-dashboard/`); `backend` so se o total do servico por hora nao estiver na lista que o modal ja le
- fora de escopo operacional: alterar o valor gravado ao confirmar; reordenar de novo "Sua experiencia inclui" e "Seu investimento"; formularios de criar orcamento; painel autenticado; schema
- prova minima desta execucao: no link publico, o modal tem titulo "Alterar servicos"; um servico por hora (como Painel de Led com 5 horas) mostra o total dessas horas, nao so o preco da hora; a lista vem em custo fixo, depois por hora, depois por pessoa
- criterio de escalada: promover para `normal` se o total das horas nao puder ser mostrado sem mudar o contrato da lista publica; `spec` nao se aplica. Se `backend` entrar, derivar com `tasking/task-request-repo-split-prompt.md`
- nivel de autonomia: `L2`
- camadas transversais: `design`; `security`, `database`, `observability` e `patterns` nao entram

## Minimal Read Set

- ler primeiro: o modal de servicos da proposta publica em `eventhub-vista-dashboard/src/components/proposal/UpdateProposalServicesDialog.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `UpdateProposalServicesDialog.tsx`, abertura do modal em `ProposalView.tsx`, ordem ja usada nos cards em `service-price-label.ts`
- palavras-chave ou simbolos de busca: `Adicionar serviço`, `Alterar serviços`, `Quantas horas?`, `FIXED`, `PER_HOUR`, `PER_PERSON`
- testes provaveis: abrir o modal no link publico, conferir titulo, total do servico por hora ao mudar as horas, e a ordem fixo / por hora / por pessoa
- nao ler por padrao: `security`, `database`, `topics/`, backend, schema e os formularios de criar orcamento

## Contexto informado na entrada

Pedido em chat, com print do modal "Adicionar servico" na proposta publica. O titulo deve ser "Alterar servicos". O valor ao lado do servico por hora e o preco da hora, nao o total que a confirmacao calcula (Painel de Led com 5 horas mostra R$ 1.500,00). A lista nao segue a ordem ja usada nos cards: todos os valores fixos, depois todos por hora, depois todos por pessoa.

## Problema atual

O botao do card ja diz "Alterar servicos", mas o titulo do modal continua "Adicionar servico". O numero ao lado do servico por hora nao acompanha as horas do campo "Quantas horas?". A lista do modal segue a ordem em que os servicos chegam, com o servico por hora no meio dos demais.

## Objetivo da mudanca

O modal da proposta publica se chama "Alterar servicos", mostra no servico por hora o total das horas escolhidas, e lista os servicos em custo fixo, custo por hora e custo por pessoa.

## Escopo inicial percebido

Titulo, valor exibido do servico por hora e ordem da lista no modal que o botao "Alterar servicos" ja abre. Um fluxo, uma tela.

## Itens incluidos neste request

- titulo do modal, de "Adicionar servico" para "Alterar servicos"
- no servico por hora, o valor visivel e o total das horas informadas no campo, nao so o preco da hora
- esse total acompanha a alteracao das horas antes de confirmar
- ordem da lista: custo fixo, depois custo por hora, depois custo por pessoa

## Requisitos implicitos ja visiveis

- o botao do card que abre o modal permanece "Alterar servicos"
- servico de valor fixo e servico por pessoa continuam mostrando o valor da linha, que ja e o total
- servicos do mesmo tipo mantem a ordem relativa que ja tinham
- servico sem tipo informado entra no grupo de custo fixo
- "Sua experiencia inclui" e "Seu investimento" nao mudam de ordem nem de valor
- confirmar continua gravando o mesmo total que ja grava hoje

## Casos de erro e borda ja percebidos

- so um tipo de custo: a lista continua estavel
- nenhum servico: o modal segue o comportamento atual
- servico por hora desmarcado: nao mostra campo de horas nem total de horas
- horas invalidas: o aviso atual do campo continua; o total nao inventa um numero
- 1 hora e varias horas: o total usa a quantidade informada
- servico por hora que tambem e obrigatorio: o aviso "Obrigatorio a partir de N pessoas." continua
- nome longo e o campo de horas continuam na mesma linha no celular

## Dependencias

- o modal e o campo "Quantas horas?" ja existem na proposta publica
- os cards "Sua experiencia inclui" e "Seu investimento" ja ordenam custo fixo, por hora e por pessoa; o modal deve usar o mesmo criterio
- o botao do card ja diz "Alterar servicos"

## Restricoes e cuidados

- nao alterar preco unitario, quantidade gravada nem o total do orcamento alem do que a confirmacao ja faz
- nao mudar obrigatoriedade, selecao nem o texto do botao que abre o modal
- nao reordenar os formularios de criar orcamento nem as listas do painel
- nao ler nem versionar valores de `.env`
- se a lista publica nao trouxer o bastante para calcular o total das horas, nao inventar o numero; escalar para `normal` e, se o contrato mudar, dividir por repositorio

## Perguntas em aberto

- O total do servico por hora atualiza enquanto a pessoa digita as horas, antes de confirmar? Premissa: sim.
- Valor fixo e valor por pessoa mudam de formato? Premissa: nao. So o servico por hora passa a mostrar o total das horas.
- Dentro do mesmo tipo, qual desempate? Premissa: manter a ordem relativa atual.
- Servico sem tipo entra onde? Premissa: no grupo de custo fixo.
- Os dois cards da proposta tambem mudam? Premissa: nao. A ordem deles ja e essa; este pedido e o modal.
- O titulo leva acento, como o botao? Premissa: sim. "Alterar servicos" no mesmo texto do botao do card.

## Prioridade sugerida

Media. O modal que o cliente usa para mudar servicos ainda se apresenta como inclusao, mostra o preco da hora no lugar do total e nao segue a ordem dos cards.

## Faixa sugerida para task workflow

- `A` — titulo, numero e ordem de um modal, um repo na via principal, sem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: ajusta titulo, valor exibido e ordem de um modal que a proposta publica ja abre; nao abre fluxo, jornada nem schema

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `modal-alterar-servicos-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
- status: executado em 2026-11-04; titulo Alterar servicos, total das horas no servico por hora e ordem fixo / por hora / por pessoa na lista do modal; review de entrega ainda nao rodou
