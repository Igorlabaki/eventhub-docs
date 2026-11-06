# Solicitacao da Tarefa

## Nome sugerido da tarefa

Pintar os cards do skeleton com a cor secundaria

## Resumo da solicitacao

Os skeletons do link publico do orcamento e da criacao publica de orcamento mostram cards brancos. O card deve usar a cor secundaria do espaco assim que ela existir, e nao nascer branco antes disso.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o card do skeleton continuar branco depois que a marca do espaco ja chegou, ou o fallback de cor vazia deixar de bater com a pagina pronta
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: schema, API, gravacao das cores, painel, galeria e rodape alem do fundo do card
- prova minima desta execucao: com secundaria preenchida, o skeleton de `/proposal/:id/view` e de `/venue/:id/form` pinta os cards nessa cor enquanto a pagina ainda espera; antes da resposta, o card nao e um bloco branco; com secundaria vazia, o card volta ao branco da pagina pronta
- criterio de escalada: promover para `normal` se a cor nao vier no payload; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no skeleton publico e `eventhub-vista-dashboard/src/pages/ProposalForm.tsx` no skeleton do formulario
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `PublicProposalPageSkeleton`, `PublicBudgetFormSkeleton`
- palavras-chave ou simbolos de busca: `proposalSecondaryColor`, `cardBackground`, `#ffffff`
- testes provaveis: abrir o link e o formulario com a rede lenta, com secundaria preenchida e com secundaria vazia
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com o skeleton do link aberto: os cards ficam brancos no link do orcamento e na criacao do orcamento. Deviam usar a cor secundaria.

## Problema atual

Enquanto a marca do espaco ainda nao chegou, os dois skeletons pintam o card de `#ffffff`. O fundo da pagina ja e escuro, entao o card aparece branco.

## Objetivo da mudanca

O card do skeleton usa a cor secundaria do espaco assim que ela existe. Antes da resposta, o card nao nasce branco. Secundaria vazia continua no branco da pagina pronta.

## Escopo inicial percebido

Ajuste visual nos dois skeletons publicos que ja leem `proposalSecondaryColor`.

## Itens incluidos neste request

- cards do skeleton de `/proposal/:id/view`
- card do skeleton de `/venue/:id/form`
- fase anterior a resposta sem card branco solido

## Requisitos implicitos ja visiveis

- primaria continua no fundo da pagina
- secundaria vazia continua caindo no branco da pagina pronta
- galeria e demais blocos do fundo nao viram card

## Casos de erro e borda ja percebidos

- sem resposta ainda: nao ha secundaria para pintar; o card nao pode ser branco solido
- secundaria vazia: o card branco da pagina pronta permanece
- secundaria escura: as linhas do skeleton precisam continuar visiveis em cima do card

## Dependencias

- as colunas e o papel das cores na pagina publica ja existem

## Restricoes e cuidados

- nao criar coluna, endpoint nem permissao
- nao mudar o skeleton das telas internas do painel

## Perguntas em aberto

- Antes da resposta, qual superficie no lugar do branco? Premissa: bloco translucido sobre o fundo escuro de espera, ate a secundaria chegar.

## Prioridade sugerida

Media. O primeiro contato das duas paginas publicas mostra a cor errada no card.

## Faixa sugerida para task workflow

- `A` — duas paginas, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: correcao visual de dois skeletons que ja existem; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `skeleton-cor-secundaria-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
