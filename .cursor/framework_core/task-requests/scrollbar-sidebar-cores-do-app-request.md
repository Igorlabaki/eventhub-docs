# Solicitacao da Tarefa

## Nome sugerido da tarefa

Scroll da sidebar fino, nas cores do app e com fade

## Resumo da solicitacao

A barra de rolagem da sidebar do painel hoje e a padrao do Windows (trilho cinza, setas, polegar grosso). Ela passa a ser fina, no roxo do EventHub, invisivel em repouso e aparecendo com transicao suave ao passar o mouse ou focar a lista.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: os estilos `::-webkit-scrollbar` serem ignorados no Chrome 121+ se `scrollbar-width`/`scrollbar-color` forem aplicados fora do fallback do Firefox; ou o truque de cor herdada pintar borda visivel no container
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: scroll do `main` em `DashboardLayout`, `EventSidebar`, `ui/sidebar.tsx` (shadcn), itens, secoes e ordem do menu, comportamento de colapso e mobile da sidebar
- prova minima desta execucao: em `/venue/:id` com a janela baixa o bastante para a sidebar rolar, a barra nao aparece em repouso; ao passar o mouse na lista ela surge com fade, fina, roxa e arredondada, sem setas; ao sair, some com fade; os itens nao mudam de largura quando a barra aparece; o mesmo vale num nivel sem secoes (site do espaco)
- criterio de escalada: permanece `smart`; sobe para `normal` se for preciso trocar a rolagem nativa por componente (ex.: `ScrollArea` do Radix)
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/sidebar/SectionedNav.tsx` no container `overflow-y-auto` da lista; `eventhub-vista-dashboard/src/components/SidebarNav.tsx` no container com `!sectionedNav && "overflow-y-auto"`
- libs obrigatorias: `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/frontend-map.md#Aplicacao e design`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/index.css` (tokens `--primary` e camadas do Tailwind); `eventhub-vista-dashboard/tailwind.config.ts` (`eventhub.primary`) so para leitura
- palavras-chave ou simbolos de busca: `overflow-y-auto`, `sectionedNav`, `SectionedNav`, `--primary`, `::-webkit-scrollbar`, `scrollbar-gutter`
- testes provaveis: teste de render garantindo a classe do scroll nos dois containers, se ja houver teste da sidebar; a prova principal e visual no browser
- nao ler por padrao: `security`, `database`, backend, `topics/`

## Contexto informado na entrada

Pedido em chat com print da visao geral do AR756: a barra de rolagem da sidebar (secoes Dia a dia e Comercial) esta "horrorosa"; deve usar as cores do app, ser mais delicada e ter animacao melhor.

## Problema atual

Os containers rolaveis da sidebar nao tem estilo de scrollbar, entao o navegador desenha a barra padrao do sistema, grossa, cinza e com setas, destoando do restante do painel.

## Objetivo da mudanca

A rolagem da sidebar usa uma barra fina na cor primaria do app, que so aparece com fade quando o usuario interage com a lista.

## Escopo inicial percebido

Uma classe utilitaria de scrollbar em `index.css` aplicada aos dois containers rolaveis da sidebar. Sem dependencia nova, sem mudar estrutura do menu.

## Itens incluidos neste request

- classe reutilizavel de scrollbar (ex.: `scrollbar-eventhub`) em `index.css`, dentro de `@layer utilities`
- polegar fino (~6px), arredondado, na cor `--primary` com opacidade baixa; mais forte ao passar o mouse no polegar
- trilho transparente, sem botoes de seta
- barra transparente em repouso; aparece com transicao (~300ms) em `:hover` e `:focus-within` do container
- `scrollbar-gutter: stable` para nao deslocar os itens
- fallback para Firefox com `scrollbar-width: thin` e `scrollbar-color`, restrito a navegadores sem `::-webkit-scrollbar`
- `prefers-reduced-motion: reduce` sem transicao
- aplicar a classe no container da lista em `SectionedNav.tsx` e no container `overflow-y-auto` de `SidebarNav.tsx`

## Requisitos implicitos ja visiveis

- a cor vem do token `--primary`, nao de hex fixo, para acompanhar tema e modo escuro
- no Chromium o polegar nao aceita `transition` direto; a animacao depende de herdar uma cor transicionada do container (ex.: `border-color: inherit` no polegar)
- o container nao pode ganhar borda visivel por causa desse truque (`border-width` continua zero; a classe precisa vencer o `* { @apply border-border }`)
- sem barra quando a lista cabe na altura

## Casos de erro e borda ja percebidos

- sidebar colapsada (`w-16`): a barra nao pode cobrir os icones
- mobile com sidebar aberta: rolagem por toque continua funcionando; sem hover, a barra pode nao aparecer, o que e aceitavel
- navegacao por teclado: ao focar um item da lista, a barra aparece (`:focus-within`)
- Firefox: sem fade no polegar se `scrollbar-color` nao animar; aceitavel desde que fique fino e na cor do app

## Dependencias

- sidebar por secoes ja entregue ([organizar-sidebar-por-secoes](organizar-sidebar-por-secoes-request.md), [sidebar-secoes-sempre-abertas](sidebar-secoes-sempre-abertas-request.md))

## Restricoes e cuidados

- nao usar `scrollbar-width`/`scrollbar-color` fora do bloco de fallback, senao o Chrome ignora os estilos `::-webkit-scrollbar`
- nao instalar plugin de scrollbar nem trocar por `ScrollArea` nesta task
- nao alterar a rolagem do conteudo principal

## Perguntas em aberto

- A barra fica sempre visivel (bem clara) ou so no hover? Premissa: so no hover/foco, com fade.
- Aplicar o mesmo estilo em outras areas rolaveis (conteudo principal, `EventSidebar`)? Premissa: nao; so a sidebar do painel. A classe fica pronta para reuso.
- Adicionar fade (mascara) no topo e no fim da lista para indicar mais itens? Premissa: nao nesta task.

## Prioridade sugerida

Baixa a media. E acabamento visual; a sidebar funciona.

## Faixa sugerida para task workflow

- `A` — CSS utilitario e duas classes aplicadas, sem contrato nem dado novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so o frontend, sem dados nem contratos

## Sugestao de slug da spec

- `framework_core/specs/scrollbar-sidebar-cores-do-app/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `scrollbar-sidebar-cores-do-app-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: `.scrollbar-eventhub` em `index.css` (`@layer utilities`, polegar herda `border-color` animada do container, fallback Firefox em `@supports not selector(::-webkit-scrollbar)`, sem transicao com `prefers-reduced-motion`); aplicada em `SectionedNav.tsx` (`data-nav-scroll`) e no container sem secoes de `SidebarNav.tsx`, com `overflow-x-hidden` e `[scrollbar-gutter:stable]` so com a sidebar aberta, para nao apertar os icones em `w-16`; vitest 19 em `src/components/sidebar` (1 novo); eslint sem erro; `vite build` ok; browser parado no login, entao a barra foi provada num bloco injetado na pagina de login: invisivel em repouso, 6px roxa no hover, cor animando 0 -> 0,09 -> 0,275 -> 0,35 em ~300ms; sidebar real nao exercitada
- derivacao repo-local: `nao se aplica`
