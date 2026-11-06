# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mostrar loading so na area que a sidebar vai abrir

## Resumo da solicitacao

Ao trocar de item na sidebar do painel, sidebar e cabecalho continuam na tela. So a area da pagina que esta carregando mostra loading. A tela cheia do EventHub fica para quando ainda nao ha sessao.

## Context Pack

- frente principal: frontend
- superficie sensivel: sim — o loading da troca de rota passa pelo guarda autenticado; o ajuste nao pode liberar pagina sem login nem sem a permissao da rota
- risco principal: esconder a checagem de permissao atras de um loading parcial, ou continuar trocando a casca inteira pelo spinner
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: paginas publicas, marca do link, skeleton novo para cada lista, API, schema e mudanca do destino dos itens
- prova minima desta execucao: no mesmo espaco, clicar de Notificacoes para Orcamentos e ver a sidebar e o cabecalho parados enquanto so o miolo carrega; repetir entre dois itens de organizacao e de orcamento; abrir o painel sem sessao continua na tela cheia; item sem permissao continua negado
- criterio de escalada: `spec` se a casca so permanecer exigindo tirar o `DashboardLayout` de cada pagina e criar uma rota de layout; senao permanece `normal`
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/ProtectedRoute.tsx` no retorno que troca a rota por `AppLoadingScreen`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/frontend-map.md#Auth e dividas a nao copiar`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/ui/AppLoadingScreen.tsx`; `eventhub-vista-dashboard/src/components/DashboardLayout.tsx`; `eventhub-vista-dashboard/src/components/SidebarNav.tsx`
- palavras-chave ou simbolos de busca: `AppLoadingScreen`, `ProtectedRoute`, `loading`, `requiredPermission`, `DashboardLayout`
- testes provaveis: troca de item no mesmo espaco sem a tela cheia; sessao ausente ainda na tela cheia; rota sem a permissao exigida continua negada
- nao ler por padrao: `database`, `topics/`, backend, schema e paginas publicas

## Contexto informado na entrada

Pedido em chat, com o painel do espaco aberto em Notificacoes. Ao clicar em outro item da sidebar, a tela inteira entra em loading. O esperado e loading apenas na parte que vai ser carregada.

## Problema atual

A troca de item da sidebar substitui sidebar, cabecalho e conteudo por uma tela cheia de carregamento. A pessoa perde o menu no meio do clique, mesmo continuando no mesmo espaco, organizacao ou orcamento.

## Objetivo da mudanca

Quem troca de item na sidebar ve o menu e o cabecalho onde estavam, e o loading so na area da pagina que esta abrindo.

## Escopo inicial percebido

Ajuste de carregamento na navegacao interna do painel. Sem rota nova, sem pagina nova e sem contrato de API.

## Itens incluidos neste request

- troca entre itens do mesmo espaco, da mesma organizacao e do mesmo orcamento
- sidebar e cabecalho visiveis durante esse carregamento
- loading restrito a area de conteudo
- tela cheia do EventHub somente enquanto nao houver sessao

## Requisitos implicitos ja visiveis

- o destino de cada item da sidebar continua o mesmo
- login e permissao da rota continuam obrigatorios antes de mostrar o conteudo
- o loading que cada pagina ja mostra na propria lista pode continuar; o que sai e a tela cheia no meio da troca
- mobile continua com o menu que ja existe; o loading novo nao cobre a coluna inteira quando a pagina do painel esta aberta

## Casos de erro e borda ja percebidos

- sem sessao, ou usuario ainda nao carregado: a tela cheia permanece
- rota sem a permissao exigida: acesso negado, sem exibir o conteudo protegido enquanto "so o miolo carrega"
- falha ao carregar o espaco, a organizacao ou o orcamento: o erro continua visivel; nao fica um loading infinito na area de conteudo
- troca para outro espaco, outra organizacao ou outro orcamento, quando esse contexto ainda nao esta em memoria: a casca pode esperar esse contexto, mas nao deve sumir se ele ja estiver carregado

## Dependencias

- a sidebar do painel ja navega entre as rotas autenticadas
- cada pagina do painel ja desenha a propria casca com sidebar e cabecalho

## Restricoes e cuidados

- nao dispensar a checagem de login nem a permissao da rota para encurtar o loading
- nao trocar o carregamento das paginas publicas
- nao criar skeleton novo para cada lista neste request
- nao mudar para onde os itens da sidebar levam

## Perguntas em aberto

- O cabecalho tambem fica fixo? Premissa: sim; ficam sidebar e cabecalho, e so o miolo carrega.
- A tela cheia some tambem na primeira entrada do painel, ja com sessao? Premissa: nao; sem sessao ela continua. Com sessao e contexto ja conhecido, a troca de item nao usa a tela cheia.
- Trocar de espaco pelo caminho do topo tambem fica so no miolo? Premissa: sim quando o destino ja estiver em memoria; se o contexto ainda nao existir, a espera fica na area de conteudo se a casca puder permanecer.
- Cada pagina ganha um skeleton novo? Premissa: nao; vale o loading que a pagina ja tem, desde que a casca nao seja substituida.

## Prioridade sugerida

Media. O painel abre as paginas; a troca de item apaga a navegacao a cada clique.

## Faixa sugerida para task workflow

- `B` — um objetivo de navegacao no frontend, com o guarda de rota no caminho
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: o resultado e um so, no frontend, sem API nova. Vira spec se manter a casca exigir uma rota de layout e a retirada do `DashboardLayout` de cada pagina.

## Sugestao de slug da spec

- `framework_core/specs/loading-so-na-area-carregada/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `loading-so-na-area-carregada-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: o guarda autenticado deixa de trocar a pagina pela tela cheia quando a sessao ja existe. Com o espaco, a organizacao ou o orcamento e a permissao ja em memoria, o outro item abre direto e o loading fica no conteudo da pagina. Enquanto o contexto ainda carrega, sidebar e cabecalho permanecem e o spinner fica no miolo. Sem sessao, a tela cheia continua. Item sem a permissao do destino continua em acesso negado, sem mostrar a pagina. A permissao deste espaco nao e buscada de novo a cada clique; a API segue autorizando. Vitest 9 em `panel-route-gate.test.ts`. O clique no browser com sessao nao foi exercitado.
- derivacao repo-local: `nao se aplica`
