# Solicitacao da Tarefa

## Nome sugerido da tarefa

Segurar o menu da sidebar na troca de nivel

## Resumo da solicitacao

Ao sair do espaco e abrir um orcamento, a sidebar nao fica em branco. O menu do nivel anterior permanece ate o menu do orcamento poder aparecer. O mesmo vale nas outras trocas de nivel do painel.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: a sidebar redirecionar de volta para a visao geral do espaco, ou mostrar item sem a permissao que ja filtra o menu
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: tela cheia de loading, paginas publicas, rotas novas, API e schema
- prova minima desta execucao: no espaco, abrir um orcamento e ver a sidebar ocupada o tempo todo; quando a proposta chega, o menu passa a ser o do orcamento; o endereco nao volta sozinho para a visao geral do espaco; item sem permissao continua oculto
- criterio de escalada: `spec` se segurar o menu exigir uma rota de layout unica para todo o painel; senao permanece `normal`
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/ProposalNav.tsx` no retorno em que a proposta ainda nao existe
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/task-requests/loading-so-na-area-carregada-request.md#Problema atual`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/SidebarNav.tsx`; `eventhub-vista-dashboard/src/components/venue/VenueNav.tsx`; `eventhub-vista-dashboard/src/components/organization/OrganizationNav.tsx`
- palavras-chave ou simbolos de busca: `ProposalNav`, `isInProposal`, `isInVenue`, `currentProposal`, `navigate`
- testes provaveis: troca espaco para orcamento sem coluna vazia; menu do orcamento depois que a proposta existe; sem redirecionar para a visao geral; volta do orcamento para o espaco sem coluna vazia
- nao ler por padrao: `security`, `database`, `topics/`, backend e paginas publicas

## Contexto informado na entrada

Pedido em chat, depois do loading parcial da sidebar. Ao trocar de nivel, por exemplo do espaco para o orcamento, a sidebar fica em branco.

## Problema atual

Na troca de nivel a sidebar ja assume o destino e tira o menu anterior. O menu novo so aparece quando o registro daquele nivel existe. No intervalo a coluna fica vazia.

## Objetivo da mudanca

Quem sai de um nivel e entra em outro continua vendo um menu na sidebar, e o menu do destino substitui o anterior quando ja pode ser desenhado.

## Escopo inicial percebido

Ajuste visual da sidebar na navegacao entre organizacao, espaco e orcamento. Sem rota nova e sem contrato de API.

## Itens incluidos neste request

- troca do espaco para o orcamento
- troca do orcamento de volta para o espaco
- troca entre organizacao e espaco
- menu anterior visivel enquanto o menu do destino ainda nao pode ser desenhado
- menu do destino no lugar do anterior assim que o registro daquele nivel existe

## Requisitos implicitos ja visiveis

- o destino de cada item continua o mesmo
- o filtro de permissao de cada item continua valendo
- a tela cheia do EventHub nao volta
- o loading do miolo da pagina continua como ficou no request do loading parcial

## Casos de erro e borda ja percebidos

- proposta ainda nao carregada: a coluna nao fica vazia e o endereco nao volta para a visao geral do espaco
- falha ao carregar o orcamento: o erro continua visivel; a sidebar nao fica vazia para sempre
- item sem permissao: continua oculto no menu que estiver na tela
- troca entre itens do mesmo nivel: o menu daquele nivel permanece, sem piscar em branco

## Dependencias

- a sidebar ja troca de menu conforme o endereco e organizacao, espaco ou orcamento
- o loading parcial do painel ja deixa a sidebar montada durante a troca de rota

## Restricoes e cuidados

- nao redirecionar o usuario por causa da espera do menu
- nao mostrar item de um nivel sem a permissao que esse item ja exige
- nao criar rota nem mudar o destino dos itens
- nao recolocar a tela cheia de loading

## Perguntas em aberto

- O que fica na coluna enquanto o destino nao chega? Premissa: o menu do nivel de onde a pessoa saiu, ate o menu do destino poder ser desenhado.
- Vale para organizacao, espaco e orcamento? Premissa: sim, nas tres trocas de nivel.
- Nasce um esqueleto novo dos grupos? Premissa: nao; segura o menu anterior. Esqueleto so se o nivel anterior nao existir na memoria.
- A volta do orcamento para o espaco tambem segura o menu? Premissa: sim.

## Prioridade sugerida

Media. A troca de item no mesmo nivel ja nao cobre a tela; a troca de nivel ainda apaga a sidebar.

## Faixa sugerida para task workflow

- `B` — um ajuste de menu no frontend, em cima do loading parcial ja feito
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: o resultado e um so, so na sidebar, sem API nova. Vira spec se segurar o menu exigir uma rota de layout unica para todo o painel.

## Sugestao de slug da spec

- `framework_core/specs/menu-sidebar-troca-de-nivel/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `menu-sidebar-troca-de-nivel-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: na troca de nivel a sidebar segura o menu que ja esta na memoria ate o destino existir. Do espaco para um orcamento ainda nao carregado, fica o menu do espaco, sem redirecionar para a visao geral. Quando a proposta chega, entra o menu do orcamento. A volta e a troca com a organizacao seguem a mesma regra. Vitest 9 em `sidebar-level.test.ts`. O clique no browser com sessao nao foi exercitado.
- derivacao repo-local: `nao se aplica`
