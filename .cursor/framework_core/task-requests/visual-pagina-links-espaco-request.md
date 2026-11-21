# Solicitacao da Tarefa

## Nome sugerido da tarefa

Visual da pagina publica de links do espaco

## Resumo da solicitacao

A pagina publica de links do espaco deixa de repetir o nome embaixo do logo e troca as pilulas escuras por botoes no padrao das outras paginas publicas. O topo fica so com o logo e o slogan.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — a pagina e a leitura publica ja existem; esta mudanca so altera o que a tela desenha
- risco principal: o nome sumir da aba, ou o botao continuar sem contraste quando a cor do card for tao escura quanto o fundo
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: editor da aba Redes; ordem, rotulo e visibilidade dos links; outras paginas publicas; contrato de `GET /venue/links/:venueId`; rodape novo
- prova minima desta execucao: em `/espaco/AR756/links`, o topo mostra o logo e o slogan O OASIS URBANO, sem um segundo AR756; cada link ligado e um botao que se le no fundo escuro, no mesmo desenho dos botoes publicos; a aba continua com o nome e o slogan
- criterio de escalada: promover para `normal` se o contraste exigir cor nova gravada no espaco; `spec` nao se aplica
- nivel de autonomia: `L2`
- camadas transversais: `design`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueLinks.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Demais paginas publicas`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Marca do espaco`
  - `framework_global/framework-libs/react/index.md`
  - `framework_global/framework-libs/design/index.md#Criar ou evoluir componente`
- caminhos candidatos: `VenueLinks.tsx`; topo de `PublicVenueListShell.tsx` e de `VenuePresentation.tsx` (logo e slogan, sem o nome); botao Fazer orçamento em `VenuePresentation.tsx`; destinos em `ProposalEventLink.tsx`
- palavras-chave ou simbolos de busca: `house.name`, `house.slogan`, `proposalSecondaryColor`, `Fazer orçamento`, `/espaco/:id/links`
- testes provaveis: a pagina de links renderiza logo e slogan e nao renderiza o nome como titulo; o botao nao usa a cor do card como fundo quando essa cor some no fundo da pagina
- nao ler por padrao: `security`, `database`, backend, spec do link tree inteira, `topics/` alem das secoes citadas

## Contexto informado na entrada

Pedido em chat, com print de `/espaco/AR756/links`. O logo ja e a palavra AR756. Embaixo dele a pagina escreve AR756 de novo e so depois o slogan O OASIS URBANO. Os botoes sao pilulas pretas, sem icone, quase da cor do fundo. O pedido e ficar so com logo e slogan, e os botoes no padrao das outras paginas publicas.

A spec do link tree ja esta concluida. O topic das paginas publicas descreve essa pagina como lista vertical com logo, slogan e cores.

## Problema atual

`VenueLinks` coloca o nome do espaco num titulo entre o logo e o slogan. Apresentacao, orcamento e link do evento nao fazem isso: o topo e o logo e, embaixo, o slogan. O nome fica na aba.

Os links usam a cor secundaria no fundo e a cor do texto na fonte. Na AR756 as duas sao escuras, entao a pilula some no fundo. Nas outras paginas, o botao de acao inverte essas cores, leva icone e o mesmo peso de Fazer orçamento.

## Objetivo da mudanca

Quem abre a pagina de links ve o logo, o slogan e uma lista vertical de botoes legiveis, sem o nome repetido embaixo do logo.

## Escopo inicial percebido

Ajuste visual de uma pagina que ja existe, so no frontend. A lista continua vertical e so com os links que o dono ligou, na ordem gravada.

## Itens incluidos neste request

- tirar o titulo com o nome entre o logo e o slogan
- slogan no mesmo texto das outras paginas publicas
- botoes da lista no desenho do botao publico de acao: pilula, cores invertidas em relacao ao card, icone e o mesmo peso tipografico
- a aba do navegador continua com o nome e o slogan

## Requisitos implicitos ja visiveis

- a lista permanece vertical
- ordem, rotulo e conjunto de links nao mudam
- casa sem slogan: o paragrafo nao aparece
- casa sem logo: o mesmo fallback das outras paginas publicas, sem colocar o nome no lugar do titulo removido
- WhatsApp, Instagram, Facebook, TikTok e Site usam os icones que as paginas publicas ja usam

## Casos de erro e borda ja percebidos

- cor secundaria igual ou proxima da cor de fundo: o botao nao pode voltar a ser uma pilula escura no fundo escuro
- logo que nao contem o nome: o nome continua fora do topo; a aba segue identificando a casa
- pagina sem links ligados: so logo e slogan, sem lista vazia com titulo
- falha ao carregar: a mensagem atual permanece, sem o titulo com o nome

## Dependencias

- a pagina `/espaco/{casa}/links` e o alias `/venue/:id/links` ja existem
- logo, slogan e cores ja chegam na leitura publica
- apresentacao e link do evento ja mostram o padrao de topo e de botao

## Restricoes e cuidados

- nao alterar o payload publico nem o que o dono grava em Redes
- nao redesenhar apresentacao, orcamento ou link do evento para "acompanhar" esta pagina
- nao inventar cor fixa da AR756; o contraste sai das cores que a casa ja tem

## Perguntas em aberto

- O botao deve ser a pilula invertida de Fazer orçamento ou o card com borda do link do evento? Premissa: pilula invertida, lista vertical, com icone. O card na cor secundaria repetiria o problema da AR756.

## Prioridade sugerida

- media: a pagina publica ja esta no ar e o print mostra o nome duplicado e os botoes ilegíveis

## Faixa sugerida para task workflow

- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- motivo: uma pagina, um repositorio, objetivo observavel, sem contrato nem schema

## Candidato a spec

- `nao`
- motivo: nao ha fluxo novo, nem quebra em varias tasks; e um ajuste visual da pagina que a spec do link tree ja entregou

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `visual-pagina-links-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
