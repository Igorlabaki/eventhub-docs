# Solicitacao da Tarefa

## Nome sugerido da tarefa

Usar o logo e as cores do espaco nos cards da lista de espacos da organizacao

## Resumo da solicitacao

Na lista de espacos da organizacao, cada card mostra o logo do espaco no lugar do nome e usa as tres cores do espaco (primaria, secundaria e de texto) no mesmo papel das paginas publicas; espaco sem marca continua com o card atual do EventHub.

## Context Pack

- frente principal: frontend, com ajuste pequeno de leitura no backend
- superficie sensivel: nao. A rota ja e autenticada e o logo e as cores ja sao publicos nas paginas do espaco; nada de auth, PII, pagamento ou schema
- risco principal: a troca de cores deixar o nome do evento, a data ou o botao ilegiveis; o logo sumir sobre o fundo; e o card perder o link para a pagina do espaco quando o nome sair
- repos tocados: `backend` (`art56_server_v3/`) e `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: paginas publicas (ja usam a marca); skeleton dos cards; sidebar e demais telas do painel; schema, migration e upload de logo; regra automatica de contraste
- prova minima desta execucao: na lista de espacos da organizacao, o card do AR756 (com logo e as tres cores) mostra o logo no lugar do nome, fundo na primaria, quadro `Próxima data` e botao `Gerenciar Espaço` na secundaria, borda esquerda na secundaria e todo o texto na cor de texto; clicar no logo abre a pagina do espaco como o nome abria; um espaco sem marca (ex.: Guaeca House, se nao tiver logo nem cores) continua com nome, card branco e roxo do EventHub; `GET /venue/permittedVenueList` devolve `logoUrl`, `proposalPrimaryColor`, `proposalSecondaryColor` e `proposalTextColor`; vitest do back e do front e `npm run build` verdes
- criterio de escalada: promover para `spec` se o pedido crescer para outras listas do painel; nao se aplica `security`
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/VenueCard.tsx` (componente inteiro, 95 linhas)
- libs obrigatorias: `react`, `design`, `node`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/topics/public-pages-and-branding.md` na parte do papel das cores
  - `.cursor/framework_core/project/api-endpoints.md` na linha de `/venue/permittedVenueList`
- caminhos candidatos:
  - `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts` (`listPermitted`; `list` para manter o par igual)
  - `art56_server_v3/src/repositories/interface/venue-repository-interface.ts` (`ItemListVenueResponse`)
  - `eventhub-vista-dashboard/src/types/venue.ts` (`ItemListVenueResponse`)
  - `eventhub-vista-dashboard/src/components/venue/VenuesList.tsx`
  - `eventhub-vista-dashboard/src/components/VenueCard.tsx`
  - referencia de papel e fallback das cores: `eventhub-vista-dashboard/src/components/proposal/PublicVenueListShell.tsx`
- palavras-chave ou simbolos de busca: `VenueCard`, `VenuesList`, `listPermitted`, `permittedVenueList`, `ItemListVenueResponse`, `logoUrl`, `proposalPrimaryColor`, `proposalSecondaryColor`, `proposalTextColor`, `border-l-eventhub-primary`, `bg-eventhub-primary`, `eventhub-stat`
- testes provaveis: teste do repositorio/use-case de `listPermitted` com os campos novos; teste de render do `VenueCard` com marca completa, so logo, so cores e sem marca (logo x nome, cores de fundo, quadro, botao, borda e texto)
- nao ler por padrao: `security`, `database`, `topics/` alem do de marca, paginas publicas

## Contexto informado na entrada

Pedido em chat com captura da lista de espacos (cards `Guaeca House` e `AR756`, ambos brancos, com borda e botao roxos do EventHub): "os cards do espaco, se tiverem configurados logo e cores do espaco, devem usar essas cores e logo". Na sequencia o usuario fechou: "o logo fica no lugar do nome" e "tem que usar cor primaria, secundaria e de texto dos espacos".

## Problema atual

O espaco ja guarda `logoUrl`, `proposalPrimaryColor`, `proposalSecondaryColor` e `proposalTextColor`, usados nas paginas publicas. Na lista de espacos do painel, `GET /venue/permittedVenueList` nao devolve esses campos e o `VenueCard` mostra so o nome, com card branco, borda (`border-l-eventhub-primary`) e botao (`bg-eventhub-primary hover:bg-indigo-600`) fixos no roxo.

## Objetivo da mudanca

Card de espaco com marca configurada mostra o logo no lugar do nome e pinta fundo, quadro, botao, borda e texto com a primaria, a secundaria e a cor de texto do espaco; card sem marca fica igual ao de hoje.

## Escopo inicial percebido

Leitura aditiva de quatro colunas que ja existem na listagem e ajuste visual de um componente. Sem schema, sem rota nova, sem mudanca de permissao.

## Itens incluidos neste request

- `listPermitted` (e `list`, para manter as duas iguais) passa a selecionar `logoUrl`, `proposalPrimaryColor`, `proposalSecondaryColor` e `proposalTextColor`
- `ItemListVenueResponse` no back e no front ganha os quatro campos, opcionais e anulaveis
- `VenuesList` repassa logo e cores ao card
- logo no lugar do nome, com o mesmo link para a pagina do espaco, `alt` com o nome do espaco e tamanho limitado sem distorcer
- cores no mesmo papel das paginas publicas:
  - primaria no fundo do card (o logo ja e pensado para ficar sobre a primaria no topo das paginas publicas)
  - secundaria no quadro `Próxima data`, no botao `Gerenciar Espaço` e na borda esquerda
  - cor de texto em todo o texto do card: rotulo `Próxima data`, icone, nome do evento, data, `Nenhuma data agendada` e rotulo do botao
- hover do botao que funcione sobre a cor do espaco (o `hover:bg-indigo-600` fixo nao vale quando a cor vem do espaco)

## Requisitos implicitos ja visiveis

- vale para todos os espacos da lista, nao so para o AR756
- sem logo, o card mostra o nome, como hoje
- cor ausente cai no mesmo fallback das paginas publicas para aquele papel (`PublicVenueListShell`); sem nenhuma cor, o card fica exatamente como hoje
- busca, link do card e navegacao de `Gerenciar Espaço` continuam como estao
- o nome do espaco continua acessivel (via `alt`/`aria-label`) quando o logo ocupa o lugar dele
- documentar os campos novos de `/venue/permittedVenueList` em `project/api-endpoints.md` se a tabela listar o formato da resposta

## Casos de erro e borda ja percebidos

- so logo, sem cores: logo no lugar do nome sobre o card branco atual, borda e botao roxos
- so cores, sem logo: nome no topo, na cor de texto, e cores aplicadas
- primaria configurada sem secundaria ou sem cor de texto: usar o fallback das paginas publicas para o papel que falta
- logo que falha ao carregar: cair para o nome, sem quebrar o layout
- logo muito largo ou muito alto: limitado em altura e largura, alinhado como o nome hoje
- cores com contraste ruim configuradas pelo espaco: aceitar o que o espaco configurou; sem regra automatica de contraste nesta task

## Dependencias

- campos de marca do espaco ja existem no schema e na tela de configuracoes (`VenueSettings`)
- o frontend usa fallback quando os campos nao vem, entao a ordem de publicacao nao quebra a tela; o efeito so aparece com a API nova publicada

## Restricoes e cuidados

- nao mudar schema nem criar migration
- nao alterar as paginas publicas nem o `PublicVenueListShell`
- nao mexer no `VenueCardSkeleton`
- nao inventar um quarto papel de cor; usar so primaria, secundaria e cor de texto
- publicar API e front so com aprovacao

## Perguntas em aberto

- O site publico da organizacao (`OrganizationWebsiteVenues`, que tambem usa `VenuesList`) muda junto? Premissa: o card e compartilhado, entao muda tambem se a pagina buscar os espacos pela mesma rota; se usar outra, fica como esta.
- Com logo no lugar do nome, o nome do espaco aparece em algum outro ponto do card? Premissa: nao; fica so no `alt` e no `aria-label`.
- Primaria no fundo e secundaria no quadro e no botao, ou o inverso? Premissa: primaria no fundo e secundaria no quadro e no botao, como fundo e cards das paginas publicas.

## Prioridade sugerida

Media. Melhoria visual do painel; nao bloqueia operacao.

## Faixa sugerida para task workflow

- `B` — dois repos (leitura aditiva no back e componente no front), sem schema nem contrato novo de rota
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: leitura aditiva de colunas existentes e ajuste de um componente; nao abre jornada, migration nem rollout proprio

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `marca-espaco-cards-lista-espacos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `executar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `opcional`
