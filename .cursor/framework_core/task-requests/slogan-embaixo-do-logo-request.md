# Solicitacao da Tarefa

## Nome sugerido da tarefa

Slogan embaixo do logo nas paginas publicas

## Resumo da solicitacao

O texto curto embaixo do logo, nas paginas publicas, passa a ser o slogan. A descricao deixa esse lugar. A apresentacao publica ja faz isso. O orcamento, o formulario e as outras cascas publicas ainda mostram a descricao. A resposta publica do orcamento ainda nao devolve o slogan.

## Context Pack

- frente principal: produto (frontend e o pacote publico do orcamento)
- superficie sensivel: sim — a resposta publica do orcamento ganha o slogan; o select nao pode passar a devolver dono, contrato, pagamento nem outros campos internos do venue
- risco principal: o slogan substituir a descricao no card A casa da apresentacao, ou a troca do texto alargar o pacote publico
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: criar bloco novo para a descricao no orcamento, no formulario ou nas cascas; mudar Configuracoes, a coluna `slogan` ou a copia ja feita; refazer a apresentacao (slogan no topo e descricao no card A casa ja estao certos); topo dos formularios de parceiro e de colaborador; descricao no card da lista de espacos da organizacao
- prova minima desta execucao: em `/venue/AR756/form` e em `/proposal/:id/view`, o texto debaixo do logo e o slogan, nao a descricao longa; uma pagina da casca (regras do espaco) faz o mesmo; a apresentacao continua com o slogan no topo e a descricao no card A casa; slogan vazio nao mostra paragrafo
- criterio de escalada: promover para `spec` se a descricao longa precisar de um bloco novo no orcamento ou no formulario, em vez de sair dessas paginas
- nivel de autonomia: `L2`
- camadas transversais: `design`, `security`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Provas`
  - `.cursor/framework_core/topics/public-pages-and-branding.md`
  - `framework_global/framework-libs/security/index.md`
  - `framework_global/framework-libs/design/index.md`
- caminhos candidatos: `ProposalView.tsx`; `ProposalForm.tsx`; `PublicVenueListShell.tsx`; `VenuePresentation.tsx` como referencia; titulo da aba em `VenueDashboard.tsx`; `getPresentation` em `proposal-in-prisma-repository.ts`; `to-proposal-presentation.ts`; `venue-presentation.test.ts`
- palavras-chave ou simbolos de busca: `slogan`, `house?.description`, `venue.description`, `venueTabTitle`, `getPresentation`, `PublicVenueListShell`
- testes provaveis: a resposta publica do orcamento devolve `slogan` e nao alarga o pacote; o teste que hoje exige `house?.description` na pagina do orcamento passa a exigir o slogan; a apresentacao continua com slogan no topo e descricao no card
- nao ler por padrao: `topics/` alem de `public-pages-and-branding.md`; spec da apresentacao publica inteira; `database`

## Contexto informado na entrada

Pedido em chat, a partir de `/venue/AR756/form`. Embaixo do logo aparece a descricao longa. O lugar certo desse texto curto e o slogan. A apresentacao (`/venue/:id/apresentacao`) ja mostra o slogan embaixo do logo e a descricao no card A casa. O campo slogan ja existe e ja e gravado em Configuracoes.

## Problema atual

O formulario publico, o link do orcamento e a casca compartilhada das outras paginas publicas imprimem `description` embaixo do logo, no esqueleto de carregamento e no titulo da aba. A apresentacao ja usa o slogan nesses dois primeiros papeis e deixa a descricao no card. A leitura publica do orcamento seleciona `description` e nao devolve `slogan`, entao trocar so o texto da tela do orcamento deixa o paragrafo vazio. O formulario e a casca ja recebem o venue com slogan.

## Objetivo da mudanca

Quem abre o orcamento, o formulario ou as outras paginas publicas da casa ve o slogan embaixo do logo, e a descricao longa sai desse lugar.

## Escopo inicial percebido

Troca do texto debaixo do logo, do esqueleto e do titulo da aba, e inclusao do slogan no pacote publico que o orcamento ja devolve. Toca `frontend` e `backend`. A apresentacao nao muda de papel.

## Itens incluidos neste request

- embaixo do logo, no lugar da descricao: `/proposal/:id/view`, `/venue/:id/form` e a casca de `/venue/:id/rules/view`, `/proposal/:id/links`, `/proposal/:id/guest-list`, `/proposal/:id/indications`, `/proposal/:id/staff-list`, `/proposal/:id/schedule-list`, `/proposal/:id/b2b-contract` e `/proposal/:id/person-contract`
- o esqueleto dessas paginas acompanha o slogan, nao a descricao
- o titulo da aba dessas paginas e o do painel do espaco usam o slogan
- a resposta publica do orcamento passa a devolver `slogan`

## Requisitos implicitos ja visiveis

- a apresentacao continua com o slogan no topo e a descricao no card A casa
- slogan vazio ou so com espaco: o paragrafo nao aparece e a aba fica so com o nome
- a descricao continua gravada e editavel em Configuracoes
- o pacote publico do orcamento so ganha o slogan

## Casos de erro e borda ja percebidos

- orcamento sem slogan na resposta: o paragrafo nao pode cair de volta na descricao
- descricao longa e slogan curto: so o slogan fica embaixo do logo
- casa sem slogan: some o paragrafo, como ja some quando a descricao esta vazia
- o teste que prende `house?.description` na pagina do orcamento precisa acompanhar a troca, sem soltar a descricao do card da apresentacao

## Dependencias

- a coluna `slogan` e o campo em Configuracoes ja existem
- a apresentacao publica ja separa slogan e descricao
- o formulario e a casca ja leem o venue por `getById`, que devolve o slogan
- o orcamento publico ainda nao

## Restricoes e cuidados

- nao criar um card ou bloco novo para a descricao no orcamento, no formulario ou nas cascas
- nao mover a descricao para fora do card A casa na apresentacao
- nao alterar schema, migration nem o salvamento de Configuracoes
- nao alargar o select publico alem do slogan
- nao ler nem versionar valores de `.env`
- a derivacao por repositorio e opcional; se a execucao separar, usar `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Nenhuma. A descricao longa sai do orcamento, do formulario e das cascas e nao ganha bloco novo. Continua no card A casa da apresentacao. O titulo da aba do painel tambem usa o slogan.

## Prioridade sugerida

Media. O texto curto do espaco ja tem campo proprio. As paginas publicas ainda mostram a descricao no lugar dele.

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

## Candidato a spec

- `nao`
- motivo: um texto, nas cascas que ja existem, e um campo a mais num pacote publico que ja sai. Nao cria jornada. Vira spec se a descricao longa precisar de um bloco novo no orcamento ou no formulario.

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `slogan-embaixo-do-logo-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
