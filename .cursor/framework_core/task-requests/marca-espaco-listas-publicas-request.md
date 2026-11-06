# Solicitacao da Tarefa

## Nome sugerido da tarefa

Levar a marca do espaco as listas publicas de convidados, colaboradores e programacao

## Resumo da solicitacao

As tres listas publicas da proposta passam a usar a marca do espaco ja aplicada em criar orcamento e em ver o orcamento: cores, fonte, animacao de entrada, logo, aba, skeleton e rodape.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao. As rotas ja sao publicas e ja gravam nome e e-mail; este request nao muda campos, gravacao nem o que a API devolve
- risco principal: as tres listas continuarem na marca EventHub, ou a troca alterar o rodape e o carregamento das telas que ainda devem mostrar a marca do produto
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: formularios de parceiro, equipe e contrato; painel; fotos, mapa e tour da pagina de ver o orcamento; gravacao das listas; schema e API
- prova minima desta execucao: abrir `/proposal/:id/guest-list`, `/proposal/:id/staff-list` e `/proposal/:id/schedule-list` de um espaco com cor primaria, secundaria, cor de texto, logo, nome, descricao e ao menos uma rede e ver, nas tres, fundo na primaria, cards na secundaria, texto na cor do texto, fonte Manrope, logo e descricao no topo, aba com nome e descricao, entrada animada e rodape igual ao de criar orcamento; durante o carregamento, a tela usa as cores do espaco e nao mostra a marca EventHub; sair da pagina devolve a aba ao titulo EventHub; adicionar um item e salvar continua gravando como hoje
- criterio de escalada: promover para `normal` se o rodape compartilhado ou o carregamento global tiver de mudar para as outras telas acompanharem; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalForm.tsx` na aplicacao de cores, Manrope, logo, descricao, aba, skeleton, animacao e rodape
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/marca-espaco-formulario-publico-request.md#Objetivo da mudanca`
- caminhos candidatos: listas publicas de convidados, colaboradores e programacao; pagina publica de criar orcamento; helper de titulo da aba
- palavras-chave ou simbolos de busca: `GuestList`, `WorkerList`, `ScheduleList`, `ProposalForm`, `venueTabTitle`, `proposalPrimaryColor`, `proposalSecondaryColor`, `proposalTextColor`, `logoUrl`, `AppLoadingScreen`, `ProposalFooter`, `Manrope`
- testes provaveis: abrir as tres rotas com e sem logo, descricao, cores e redes; comparar topo, fonte, skeleton e rodape com `/venue/:id/form`; adicionar e salvar um item em cada lista; sair da pagina e conferir a aba
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, depois do padrao visual de criar orcamento e de ver o orcamento. O usuario quer levar cores, fontes, animacoes, logos e rodape para os outros links publicos: adicionar convidados, colaboradores e a programacao do evento. As capturas dessas telas mostram a marca EventHub: logo do produto no topo, fundo claro, cards brancos e, nas listas de pessoas, o rodape roxo "Seu hub para gestao de eventos".

## Problema atual

`/proposal/:id/guest-list`, `/proposal/:id/staff-list` e `/proposal/:id/schedule-list` apresentam as listas com a marca fixa do EventHub. Criar orcamento e ver o orcamento, do mesmo espaco, ja usam cor primaria no fundo, secundaria nos cards e no rodape, cor do texto na fonte, Manrope, logo e descricao do espaco, aba com nome e descricao, animacao de entrada e skeleton na marca do espaco.

## Objetivo da mudanca

Nas tres listas publicas, cores, fonte, animacao de entrada, logo, aba, skeleton e rodape seguem a marca do espaco com a mesma logica visual de criar orcamento.

## Escopo inicial percebido

Ajuste visual de tres paginas publicas que ja existem e ja carregam a proposta e o espaco. Sem contrato, schema ou tela nova. A referencia visual ja esta em criar orcamento e em ver o orcamento.

## Itens incluidos neste request

- as tres paginas usam as cores do espaco no mesmo papel de criar orcamento: primaria no fundo, secundaria nos cards e no rodape, cor do texto na fonte
- o topo mostra o logo do espaco e, abaixo, a descricao
- a fonte e Manrope, como nas paginas de orcamento
- a entrada da pagina usa a animacao discreta ja usada no formulario publico
- a aba mostra o nome e a descricao do espaco
- o rodape fica igual ao de criar orcamento
- o skeleton usa as cores do espaco e espera a marca antes de mostrar a pagina, no formato de cada lista
- ao sair da pagina, a aba volta ao titulo generico do EventHub
- adicionar, buscar, salvar e remover continuam com o comportamento atual

## Requisitos implicitos ja visiveis

- vale para qualquer proposta aberta nessas tres rotas, nao para um registro so
- a referencia de casca e criar orcamento; ver o orcamento confirma o mesmo papel de cores, fonte, logo e rodape
- sem descricao, a aba mostra so o nome e o topo nao reserva bloco de descricao
- sem logo, o topo usa o mesmo fallback de criar orcamento
- o rodape so aparece quando criar orcamento tambem mostraria rodape
- os botoes de adicionar e de salvar usam a cor primaria, com o rotulo na cor do texto
- os campos continuam claros para digitar dentro do card
- as telas que ainda usam o rodape e o carregamento do EventHub ficam como estao

## Casos de erro e borda ja percebidos

- espaco sem alguma cor: a tela usa o mesmo fallback de criar orcamento para aquele papel
- espaco sem logo, sem descricao ou sem redes: topo, aba e rodape degradam como em criar orcamento
- descricao longa: entra no titulo; o navegador corta a exibicao
- espaco ou lista ainda carregando: a tela nao mostra a marca EventHub nem cores de outro espaco
- logo que falha ao baixar: a espera do skeleton nao prende a pagina para sempre
- navegacao para fora da lista: a aba volta ao titulo EventHub
- lista vazia, busca sem resultado e botao salvar desabilitado continuam visiveis dentro da marca do espaco
- programacao sem botao de salvar lista: cada atracao continua sendo gravada ao adicionar

## Dependencias

- `/venue/:id/form` ja aplica cores, Manrope, logo, descricao, aba, skeleton, animacao e rodape do espaco
- `/proposal/:id/view` ja aplica a mesma marca na pagina do orcamento
- `venueTabTitle` ja monta o texto da aba
- as tres listas ja carregam a proposta e o espaco

## Restricoes e cuidados

- nao alterar o que as listas gravam nem os campos do formulario
- nao alterar o rodape compartilhado nem o carregamento das outras telas
- nao trazer fotos, mapa ou tour da pagina de ver o orcamento
- nao incluir formularios de parceiro, equipe e contrato
- nao criar endpoint nem mudar schema
- nao recolocar a primaria no card

## Perguntas em aberto

- O mapa do espaco, que aparece no corpo de ver o orcamento, entra nestas listas? Premissa: nao; entra o rodape que criar orcamento ja mostra, com logo e redes do espaco.
- Parceiro, equipe e contrato entram junto? Premissa: nao; neste request so convidados, colaboradores e programacao.
- O rodape compartilhado do EventHub muda para todo mundo? Premissa: nao; estas tres paginas deixam de usa-lo e as demais telas continuam com a marca do produto.
- Os campos ficam brancos dentro do card? Premissa: sim; o card usa a secundaria e os campos continuam claros para digitar.

## Prioridade sugerida

Alta. Criar e ver o orcamento ja apresentam o espaco, e os links publicos seguintes da mesma proposta ainda abrem na marca EventHub.

## Faixa sugerida para task workflow

- `A` — tres telas do mesmo tipo, um repo, sem contrato nem schema; a referencia visual ja existe
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: aplica numa familia de paginas publicas que ja existe a marca que criar orcamento e ver o orcamento ja implementam; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; a marca de referencia continua em `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `marca-espaco-listas-publicas-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar` a entrega (`fw:review`)
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; a diagramacao e o texto das tres listas foram alinhados a proposta no mesmo dia; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
