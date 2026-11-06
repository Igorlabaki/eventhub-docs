# Solicitacao da Tarefa

## Nome sugerido da tarefa

Deixar as secoes da sidebar sempre abertas

## Resumo da solicitacao

A sidebar deixa de ter grupos que abrem e fecham. Todos os grupos ficam visiveis. O nome do orcamento deixa de parecer um rotulo de secao.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o nome do cliente continuar com a mesma cara do rotulo, ou a sidebar recolhida passar a lotar de icones
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: rotas, permissoes, editor de Site, novos itens e reordenacao dos grupos
- prova minima desta execucao: no orcamento, ver Orçamento, Falar com o cliente, Fechar e No dia abertos, sem seta; o nome do cliente em caixa normal e mais escuro que esses rotulos; no espaco, Comercial e A casa abertos do mesmo jeito; o nome do espaco tambem separado dos rotulos
- criterio de escalada: `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/sidebar/SectionedNav.tsx` no `Collapsible` e na classe do `heading`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/organizar-sidebar-por-secoes-request.md#Itens incluidos neste request`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/ProposalNav.tsx`; `eventhub-vista-dashboard/src/components/venue/VenueNav.tsx`; `eventhub-vista-dashboard/src/components/sidebar/sidebar-nav-model.ts`
- palavras-chave ou simbolos de busca: `Collapsible`, `headingClassName`, `alwaysOpen`, `uppercase`
- testes provaveis: `eventhub-vista-dashboard/src/components/sidebar/SectionedNav.test.tsx`; grupos do orcamento todos abertos; nome do cliente distinto do rotulo
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a sidebar do orcamento de Igor Augusto Labaki aberta em Link do evento. Falar com o cliente esta aberto e tem seta. Fechar e No dia estao fechados. O nome do cliente sai em caixa alta, no mesmo cinza e no mesmo tamanho de Orcamento.

## Problema atual

Parte dos grupos esconde os itens atras de um clique. O nome do orcamento usa o mesmo estilo do rotulo da secao, entao os dois parecem o mesmo nivel. O nome do espaco usa esse mesmo titulo.

## Objetivo da mudanca

Quem abre o painel ve todos os itens do nivel, e o nome do orcamento se le como o registro aberto, nao como mais um grupo.

## Escopo inicial percebido

Ajuste visual do menu que ja existe. Sem rota nova.

## Itens incluidos neste request

- nenhum grupo da sidebar abre ou fecha
- a seta de expandir sai
- espaco, orcamento e organizacao mostram todos os grupos de uma vez
- o nome do orcamento fica em caixa normal, maior e mais escuro que o rotulo da secao
- o nome do espaco recebe o mesmo tratamento, porque usa o mesmo titulo

## Requisitos implicitos ja visiveis

- os rotulos Orçamento, Falar com o cliente, Fechar, No dia, Dia a dia, Comercial e A casa continuam pequenos, cinza e em caixa alta
- cada item continua na rota e na permissao que ja tem
- a sidebar recolhida em icones nao passa a listar todos os grupos; continua so com o conjunto que ja mostra hoje
- Configuracoes continua no rodape

## Casos de erro e borda ja percebidos

- grupo sem item permitido continua oculto
- nome longo do cliente quebra a linha dentro da coluna, sem voltar a caixa alta
- sidebar recolhida: sem rotulo e sem seta; so os icones que ja aparecem nesse modo

## Dependencias

- a sidebar por secoes ja esta no frontend

## Restricoes e cuidados

- nao recolocar a sanfona
- nao mudar a ordem dos itens
- nao tratar "sempre aberto" como "mostrar todo icone com a sidebar recolhida"

## Perguntas em aberto

- O nome do espaco muda junto? Premissa: sim; e o mesmo titulo do menu.
- A organizacao muda o nome? Premissa: o nome dela ja nao vai para caixa alta; neste request o ajuste forte e o do orcamento e o do espaco.
- A sidebar recolhida mostra todos os icones? Premissa: nao; fica como esta.

## Prioridade sugerida

Media. O menu novo ja esta na tela e a sanfona esconde o que a pessoa acabou de pedir para ver.

## Faixa sugerida para task workflow

- `A` — um componente, um repo, sem rota nem contrato
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: tira a sanfona e diferencia o titulo de um menu que ja existe

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `sidebar-secoes-sempre-abertas-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: grupos sempre abertos, sem seta; nome do orcamento e do espaco em caixa normal e mais escuro que o rotulo; sidebar recolhida inalterada; 8 testes em `sidebar-nav-model.test.ts` e `SectionedNav.test.tsx`
- derivacao repo-local: `nao se aplica`
