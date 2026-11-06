# Solicitacao da Tarefa

## Nome sugerido da tarefa

Deixar o painel de metas e precos igual a referencia

## Resumo da solicitacao

O painel de Metas e Precos passa a seguir a referencia visual do chat. Cada bloco sem configuracao mostra que nao ha nada configurado.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o painel exibir R$ 0,00 ou esconder um bloco que ja tem dado, ou a mensagem de vazio aparecer enquanto a lista ainda carrega
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: abas de lista e formularios de meta, adicional, desconto e minimo; calculo do orcamento; schema; ilustracoes customizadas como condicao de entrega
- prova minima desta execucao: em `/venue/:id/goals`, na aba Painel, a tela com dados segue a referencia (resumo, modelo de preco, metas ao lado de adicionais, minimos e descontos); com meta, adicional, desconto, faixa e preco minimo ausentes, cada bloco mostra que nao ha nada configurado, sem trocar o dado por zero
- criterio de escalada: promover para spec se a meta anual precisar de campo persistido, ou se a entrega depender de upload de ilustracao
- nivel de autonomia: `L2`
- camadas transversais: `design`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/specs/2026-11-02-precos-minimos-por-periodo/00-overview.md`
- caminhos candidatos: painel de `VenueGoals`; cabecalho das abas; estado vazio ja usado nas secoes
- palavras-chave ou simbolos de busca: `VenueGoals`, `viewMode`, `EmptyState`, `pricingModel`, `minimumPrice`
- testes provaveis: painel com dados renderiza resumo e os blocos da referencia; lista vazia e preco minimo ausente mostram a mensagem; estado de carregamento nao usa essa mensagem
- nao ler por padrao: `topics/`, `security`, backend, calculo de orcamento

## Contexto informado na entrada

Pedido em chat, com tres imagens. A primeira e a referencia do painel. As outras duas sao a tela atual, mais simples. Se a pessoa ainda nao configurou o bloco, a tela deve dizer que nao ha nada configurado.

## Problema atual

O painel existe e ja lista preco, metas, adicionais, minimos e descontos, mas a composicao nao segue a referencia: falta a faixa de resumo, as secoes ficam empilhadas e os botoes de ver todos sao preenchidos. O preco minimo ausente aparece como zero. O vazio de cada lista usa um bloco tracejado, fora do card da referencia.

## Objetivo da mudanca

Na aba Painel, a tela fica com a composicao da referencia e, em bloco sem configuracao, informa que nao ha nada configurado.

## Escopo inicial percebido

A mudanca fica na apresentacao do painel ja existente. Os dados continuam os de metas, adicionais, descontos, preco do espaco e preco minimo por periodo.

## Itens incluidos neste request

- faixa de resumo no topo: preco atual, meta anual, adicionais ativos, descontos ativos e minimo padrao
- card largo do modelo de precificacao, com o valor e a acao de editar para quem pode alterar preco
- metas e adicionais lado a lado, com titulo, subtitulo e ver todos
- card da meta com valor, meses e taxa de aumento
- precos minimos em duas areas: padrao e periodo
- descontos em ate tres cards, com o percentual
- ver todos continua abrindo a aba que ja existe
- bloco sem dado mostra que nao ha nada configurado

## Requisitos implicitos ja visiveis

- as abas Painel, Metas, Adicionais, Descontos e Minimos continuam
- quem nao tem permissao de editar preco ve a mensagem e nao ve a acao de criar
- a amostra do painel continua limitada; o restante fica em ver todos
- percentual de adicional fica positivo e o de desconto fica negativo
- a spec de precos minimos por periodo segue dona do dado; este pedido so apresenta o que ela ja grava

## Casos de erro e borda ja percebidos

- lista ainda carregando
- meta, adicional, desconto ou faixa vazios
- preco minimo padrao ausente ou zero
- espaco sem modelo ou sem preco
- mais de um item em cada secao
- meta sem meses informados
- pessoa sem permissao de editar

## Dependencias

- a tela e as listas do painel ja existem
- a spec `specs/2026-11-02-precos-minimos-por-periodo/` ja coloca o minimo padrao e as faixas nesse painel

## Restricoes e cuidados

- nao criar campo novo de meta anual
- nao alterar formularios, calculo de orcamento nem o contrato da API
- nao tratar ilustracao ausente como bloqueio; a hierarquia da referencia vale com os icones e fundos que o painel ja usa
- nao mostrar zero no lugar de bloco nao configurado

## Perguntas em aberto

- De onde sai a meta anual do resumo? Premissa: soma do valor de cada meta multiplicado pela quantidade de meses dela; sem meta, o resumo desse item diz que nao ha nada configurado.
- O painel mostra so o primeiro item de cada secao, como na referencia? Premissa: nao; mantem a amostra de ate tres e o restante fica em ver todos.
- As ilustracoes da referencia sao obrigatorias? Premissa: nao; a entrega e a composicao, os rotulos e a mensagem de vazio.
- Qual texto exato do vazio? Premissa: "Nada configurado".

## Prioridade sugerida

Media. O painel ja funciona; a entrega e a apresentacao da referencia e a mensagem quando o bloco esta vazio.

## Faixa sugerida para task workflow

- `B` — uma tela, varios blocos de apresentacao, so no frontend, sem contrato novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: redesenha o painel que ja existe, sem jornada nova, sem backend e sem dado novo

## Sugestao de slug da spec

- nao se aplica agora; se escalar, `framework_core/specs/painel-metas-precos/`

## Sugestao de nome do arquivo

- `painel-metas-precos-referencia-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-painel-metas-precos/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
