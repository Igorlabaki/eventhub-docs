# Solicitacao da Tarefa

## Nome sugerido da tarefa

Aplicar a marca do espaco na tela publica de criar orcamento

## Resumo da solicitacao

A tela publica de criar orcamento (`/venue/:id/form`) passa a seguir a marca do espaco do mesmo jeito que o link publico do orcamento: cores, logo, aba, rodape e skeleton. A referencia e a pagina `/proposal/:id/view`.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao. A rota ja e publica e o espaco ja chega com cores, logo, nome, descricao e redes; este request nao muda o que o formulario envia nem o que a API devolve
- risco principal: o formulario publico continuar com a marca EventHub, ou a troca vazar para o rodape e o carregamento das outras telas que ainda usam a marca do produto
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: painel de novo orcamento, formularios de parceiro, equipe e contrato, listas publicas, gravacao das cores, schema, API e o componente de rodape compartilhado
- prova minima desta execucao: abrir `/venue/:id/form` de um espaco com cor primaria, secundaria, cor de texto, logo, nome, descricao e ao menos uma rede e ver fundo na primaria, card na secundaria, texto na cor do texto, logo do espaco no topo, aba com nome e descricao, e rodape igual ao de `/proposal/:id/view`; durante o carregamento, a tela usa as mesmas cores e nao mostra a marca EventHub; sair da pagina devolve a aba ao titulo EventHub; uma tela que ainda usa o rodape padrao continua com a marca EventHub
- criterio de escalada: promover para `normal` se a cor do card precisar de componente compartilhado com o formulario do painel, ou se o rodape compartilhado tiver de mudar; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` na aplicacao de cores, logo, aba, rodape e skeleton
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/papeis-cores-proposta-request.md#Objetivo da mudanca`
- caminhos candidatos: pagina publica de criar orcamento; formularios do cliente por pessoa e por dia; helper de titulo da aba; rodape e skeleton ja usados no link do orcamento
- palavras-chave ou simbolos de busca: `ProposalForm`, `ProposalView`, `venueTabTitle`, `proposalPrimaryColor`, `proposalSecondaryColor`, `proposalTextColor`, `logoUrl`, `AppLoadingScreen`, `ProposalFooter`
- testes provaveis: abrir `/venue/:id/form` com e sem logo, descricao, cores e redes; comparar o rodape com `/proposal/:id/view`; sair da pagina e conferir a aba; abrir uma tela que ainda usa o rodape padrao
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a tela publica de criar orcamento aberta na marca EventHub: logo EventHub, fundo cinza, card branco e rodape roxo "Seu hub para gestao de eventos". Essa tela deve seguir as cores do espaco como o link do orcamento. O logo tambem e o do espaco. A aba mostra o nome e a descricao do espaco. O rodape fica igual ao do link. O skeleton segue a mesma logica. A referencia e a pagina do link do orcamento.

## Problema atual

`/venue/:id/form` apresenta o formulario publico com a marca fixa do EventHub. O link `/proposal/:id/view` do mesmo espaco ja usa cor primaria no fundo, secundaria nos cards e no rodape, cor do texto na fonte, logo do espaco, aba com nome e descricao, e um skeleton que espera a marca do espaco antes de mostrar a pagina.

## Objetivo da mudanca

Em `/venue/:id/form`, cores, logo, aba, rodape e skeleton seguem a marca do espaco com a mesma logica visual do link publico do orcamento.

## Escopo inicial percebido

Ajuste de uma pagina publica que ja existe e ja recebe o espaco, inclusive cores, logo, nome, descricao e redes. Sem contrato, schema ou tela nova. A referencia visual ja esta implementada no link do orcamento.

## Itens incluidos neste request

- a pagina usa as cores do espaco no mesmo papel do link: primaria no fundo, secundaria no card e no rodape, cor do texto na fonte
- o topo mostra o logo do espaco
- a aba mostra o nome e a descricao do espaco
- o rodape fica igual ao do link do orcamento
- o skeleton usa as mesmas cores e a mesma espera da marca, no formato desta tela
- ao sair da pagina, a aba volta ao titulo generico do EventHub

## Requisitos implicitos ja visiveis

- vale para qualquer espaco aberto em `/venue/:id/form`, nao para um registro so
- o papel das cores e o que o link ja aplica; a primaria nao pinta o card nem o botao
- sem descricao, a aba mostra so o nome
- sem logo, o topo nao inventa outra marca alem do fallback que o link ja usa
- o rodape so aparece quando o link tambem mostraria rodape
- o skeleton desta tela tem o formato do formulario; a logica de cor e de espera e a do link
- as outras telas que usam o rodape e o carregamento do EventHub ficam como estao

## Casos de erro e borda ja percebidos

- espaco sem alguma cor: a tela usa o mesmo fallback do link para aquele papel
- espaco sem logo, sem descricao ou sem redes: a aba, o topo e o rodape degradam como no link
- descricao longa: entra no titulo; o navegador corta a exibicao
- espaco ainda carregando: a tela nao mostra a marca EventHub nem cores de outro espaco
- logo que falha ao baixar: a espera do skeleton nao prende a pagina para sempre
- navegacao para fora de `/venue/:id/form`: a aba volta ao titulo EventHub

## Dependencias

- `/proposal/:id/view` ja aplica cores, logo, aba, rodape e skeleton do espaco
- `venueTabTitle` ja monta o texto da aba
- a tela publica de criar orcamento ja carrega o espaco

## Restricoes e cuidados

- nao alterar o rodape compartilhado nem o carregamento das outras telas
- nao alterar o formulario de novo orcamento do painel
- nao criar endpoint nem mudar schema
- nao recolocar a primaria no card; o botao Enviar usa a primaria, com o texto na cor do texto
- nao trazer tipografia, animacao, fotos ou mapa do link para este formulario
- nao ampliar o que a rota publica devolve

## Perguntas em aberto

- O botao Enviar tambem muda de cor? Premissa: sim; o fundo do botao usa a cor primaria e o rotulo usa a cor do texto. Sem primaria, o botao continua violeta.
- Parceiro, equipe, contrato e listas publicas entram junto? Premissa: nao; neste request so `/venue/:id/form`.
- Os campos do formulario ficam brancos dentro do card? Premissa: sim; o card usa a secundaria e os campos continuam claros para digitar.
- A pagina troca a fonte para a do link? Premissa: nao; este request nao muda tipografia.

## Prioridade sugerida

Alta. O link do orcamento ja apresenta o espaco e o formulario publico que origina esse orcamento ainda abre na marca EventHub.

## Faixa sugerida para task workflow

- `A` — uma tela, um repo, sem contrato nem schema; a referencia visual ja existe no link
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: aplica numa pagina publica que ja existe a marca que o link do orcamento ja implementa; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; o link de referencia continua em `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `marca-espaco-formulario-publico-request.md`

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
