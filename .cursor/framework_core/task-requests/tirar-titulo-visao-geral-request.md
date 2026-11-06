# Solicitacao da Tarefa

## Nome sugerido da tarefa

Tirar titulo e subtitulo da visao geral do espaco

## Resumo da solicitacao

A pagina `/venue/:id` deixa de mostrar o titulo "Visao Geral" e o subtitulo "Acompanhe os principais indicadores do seu espaco". Os indicadores continuam no mesmo lugar. O item "Visao Geral" da sidebar permanece.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: sumir o item da sidebar ou o cabecalho com o nome do espaco junto com o titulo da pagina
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: sidebar, cabecalho "Painel de controle", outras paginas, schema e API
- prova minima desta execucao: abrir `/venue/:id` e ver os indicadores sem o titulo "Visao Geral" e sem o subtitulo; o item "Visao Geral" continua na sidebar e o nome do espaco continua no cabecalho
- criterio de escalada: promover para `normal` se o mesmo titulo existir em outras paginas e o pedido passar a valer para todas; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx` no bloco do titulo da pagina
- libs obrigatorias: `react`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx`
- caminhos candidatos: titulo renderizado no conteudo de `VenueDashboard`; item de menu em `sidebar-nav-model.ts`
- palavras-chave ou simbolos de busca: `Visão Geral`, `Acompanhe os principais indicadores`, `VenueDashboard`
- testes provaveis: abrir `/venue/:id` e conferir a ausencia do titulo e do subtitulo; conferir que a sidebar ainda tem "Visao Geral"
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema. `design` nao entra: a mudanca so apaga texto ja renderizado, sem componente novo

## Contexto informado na entrada

Pedido em chat, com a Visao Geral do espaco AR756 aberta. No card branco, acima dos filtros de mes e ano, aparecem "Visao Geral" e "Acompanhe os principais indicadores do seu espaco".

## Problema atual

A pagina repete o nome da secao que a sidebar ja mostra e acrescenta um subtitulo que o usuario nao quer na tela.

## Objetivo da mudanca

Em `/venue/:id`, o conteudo da visao geral comeca nos indicadores, sem o titulo "Visao Geral" e sem o subtitulo.

## Escopo inicial percebido

Remocao de um bloco de texto em uma pagina que ja existe. Sem contrato, schema ou tela nova.

## Itens incluidos neste request

- o titulo "Visao Geral" sai do conteudo de `/venue/:id`
- o subtitulo "Acompanhe os principais indicadores do seu espaco" sai da mesma pagina
- filtros, indicadores, proximo evento e desempenho mensal permanecem

## Requisitos implicitos ja visiveis

- vale para a visao geral de qualquer espaco, nao so do AR756
- o item "Visao Geral" da sidebar continua
- o cabecalho com o nome do espaco e "Painel de controle" continua

## Casos de erro e borda ja percebidos

- carregamento: o skeleton nao tem esse titulo; nada a esconder nele
- usuario sem autenticacao e espaco nao encontrado: essas telas nao usam esse titulo

## Dependencias

- a pagina `/venue/:id` ja existe

## Restricoes e cuidados

- nao remover o item da sidebar
- nao alterar o cabecalho do layout
- nao criar endpoint nem mudar schema

## Perguntas em aberto

- O item "Visao Geral" da sidebar tambem sai? Premissa: nao; o pedido aponta o titulo e o subtitulo do conteudo.
- O cabecalho "Painel de controle" sai? Premissa: nao; ele identifica o espaco, nao e o titulo apontado.
- Outras paginas com titulo parecido mudam? Premissa: nao; so a visao geral do espaco.

## Prioridade sugerida

Baixa. A pagina funciona; o texto e redundante com a sidebar.

## Faixa sugerida para task workflow

- `A` — uma pagina, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: remocao de dois textos de uma pagina que ja existe; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `tirar-titulo-visao-geral-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar` a entrega; titulo e subtitulo removidos de `VenueDashboard`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
