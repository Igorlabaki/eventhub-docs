# Solicitacao da Tarefa

## Nome sugerido da tarefa

Ordenar os servicos da proposta publica por tipo de custo

## Resumo da solicitacao

Nos cards "Sua experiência inclui" e "Seu investimento" da proposta publica, os servicos aparecem primeiro com custo fixo, depois com custo por hora e por ultimo com custo por pessoa.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — a pagina e publica, mas a mudanca so reordena servicos ja exibidos; preco, selecao e contrato nao mudam
- risco principal: os dois cards ficarem com ordens diferentes, ou a locacao e as horas extras do espaco entrarem no meio dos servicos
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: mudar preco, quantidade, tipo de cobranca ou quais servicos entram; reordenar o modal "Adicionar servico", os formularios de criar orcamento e as listas do painel; alterar schema ou API
- prova minima desta execucao: na proposta publica, "Sua experiência inclui" e "Seu investimento" listam os mesmos servicos nesta ordem: custo fixo, custo por hora, custo por pessoa; a locacao exclusiva continua acima dos servicos
- criterio de escalada: promover para `normal` se a ordem exigir mudanca de contrato ou de persistencia; `spec` nao se aplica
- nivel de autonomia: `L2`
- camadas transversais: `design`; `security`, `database`, `observability` e `patterns` nao entram

## Minimal Read Set

- ler primeiro: as duas listas de servicos em `eventhub-vista-dashboard/src/pages/ProposalView.tsx` ("Sua experiência inclui" e "Seu investimento")
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `ProposalView.tsx`, `service-price-label.ts`
- palavras-chave ou simbolos de busca: `serviceList`, `pricingType`, `FIXED`, `PER_HOUR`, `PER_PERSON`, `Sua experiência inclui`, `Seu investimento`
- testes provaveis: abrir o link publico de um orcamento com os tres tipos e conferir a mesma ordem nos dois cards
- nao ler por padrao: `security`, `database`, `topics/`, backend, schema e os formularios de criar orcamento

## Contexto informado na entrada

Pedido em chat, com prints dos dois cards da proposta publica. "Sua experiência inclui" lista Limpeza, Recepcionista, Seguranca e Painel de Led. "Seu investimento" repete esses servicos, com o Painel de Led em `R$ 250,00 × 5 h`. Os dois containers devem ordenar os servicos: primeiro custo fixo, segundo custo por hora, terceiro custo por pessoa.

## Problema atual

Os dois cards mostram os servicos na ordem em que a proposta chega, sem separar por tipo de cobranca.

## Objetivo da mudanca

"Sua experiência inclui" e "Seu investimento" listam os servicos na mesma ordem: custo fixo, depois custo por hora, depois custo por pessoa.

## Escopo inicial percebido

Ordenar a lista de servicos ja renderizada nos dois cards da pagina publica do orcamento.

## Itens incluidos neste request

- ordem custo fixo, custo por hora, custo por pessoa em "Sua experiência inclui"
- a mesma ordem em "Seu investimento"
- os dois cards continuam com a mesma sequencia de servicos

## Requisitos implicitos ja visiveis

- servicos do mesmo tipo mantem a ordem relativa que ja tinham
- servico sem tipo informado entra no grupo de custo fixo
- "Locação exclusiva do espaço" e horas extras do espaco continuam acima dos servicos, fora dessa ordenacao
- nome, obrigatoriedade, valor, detalhe de horas ou pessoas e total nao mudam
- incluir ou tirar servico no link nao desfaz a ordem na proxima renderizacao

## Casos de erro e borda ja percebidos

- so um tipo de custo: a lista continua estavel
- nenhum servico: os cards seguem o comportamento atual
- servico sem tipo na linha: tratar como custo fixo
- servico recem-incluido cujo tipo ainda nao voltou na resposta: nao pode furar a ordem dos outros que ja tem tipo; se o tipo nao estiver disponivel, cai no grupo fixo ate a pagina ter o tipo

## Dependencias

- a proposta publica ja distingue custo fixo, por hora e por pessoa nas linhas de servico
- os dois cards ja leem a mesma lista de servicos da proposta

## Restricoes e cuidados

- nao alterar valores, quantidades nem o total
- nao mudar o contrato publico nem o schema
- nao ler nem versionar valores de `.env`

## Perguntas em aberto

- Dentro do mesmo tipo, qual desempate? Premissa: manter a ordem relativa atual.
- Servico sem tipo entra onde? Premissa: no grupo de custo fixo.
- O modal "Adicionar servico" tambem ordena? Premissa: nao. O pedido cobre os dois cards da proposta.
- A locacao exclusiva entra na ordenacao? Premissa: nao. Ela continua no topo de "Seu investimento", antes dos servicos.

## Prioridade sugerida

Media. A leitura dos dois cards fica alinhada ao tipo de cobranca, sem mudar o que o cliente paga.

## Faixa sugerida para task workflow

- `A` — uma lista, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: reordena servicos que a pagina publica ja mostra, nos dois cards, sem fluxo novo

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `ordenar-servicos-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; os dois cards da proposta publica ordenam custo fixo, por hora e por pessoa; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
