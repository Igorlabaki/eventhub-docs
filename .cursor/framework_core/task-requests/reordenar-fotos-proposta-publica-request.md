# Solicitacao da Tarefa

## Nome sugerido da tarefa

Reordenar as fotos da proposta publica arrastando

## Resumo da solicitacao

O dono do espaco, logado e dentro do link publico do orcamento, arrasta as fotos de lugar; ao soltar, a ordem fica gravada e as proximas aberturas mostram essa ordem.

## Context Pack

- frente principal: frontend, com gravacao no backend
- superficie sensivel: sim — a pagina e publica e a gravacao so pode ocorrer para o dono autenticado daquele espaco
- risco principal: um visitante do link reordenar as fotos, ou a ordem solta nao permanecer na proxima abertura
- repos tocados: `frontend` (`eventhub-vista-dashboard/`) e `backend` (`art56_server_v3/`)
- fora de escopo operacional: carrossel, grade de duas colunas, cores, textos, mapa, rodape e o formulario numerico de posicao no painel
- prova minima desta execucao: dono logado arrasta uma foto, solta, recarrega o link e ve a ordem nova; visitante sem essa sessao nao arrasta e ve a ordem gravada
- criterio de escalada: promover para `spec` antes de executar; a mudanca cruza os dois repositorios e grava a partir de uma pagina publica
- nivel de autonomia: `L2`
- camadas: `security`, `design`, `database`; `observability` nao se aplica; `patterns` entra porque a gravacao e um fluxo novo de escrita

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx#A casa`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `security`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/node/index.md`
- caminhos candidatos: `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts#getPresentation`; `eventhub-vista-dashboard/src/components/image/image-form.tsx#Posicao`
- palavras-chave ou simbolos de busca: `position`, `isShowOnOrganization`, `ProposalView`, `A casa`
- testes provaveis: dono arrasta e recarrega; visitante nao arrasta; falha ao gravar devolve a ordem anterior
- nao ler por padrao: `topics/`, `observability`, upload S3 e o painel alem do campo de posicao que ja existe

## Contexto informado na entrada

Pedido em chat, com a pagina publica do orcamento aberta. O dono quer entrar no link, arrastar as fotos de um lugar para outro e, ao soltar, ver essa ordem salva e estavel.

## Problema atual

A ordem vem do numero Posicao de cada foto. Na pagina publica nao da para arrastar. Mudar a ordem exige editar esse numero no painel.

## Objetivo da mudanca

O dono logado arrasta as fotos no link publico e, ao soltar, a ordem fica gravada para as proximas aberturas.

## Escopo inicial percebido

Interacao nova na pagina publica que ja existe, com gravacao da ordem das fotos do espaco. Visitante continua so olhando.

## Itens incluidos neste request

- arrastar as fotos visiveis no link quando o dono do espaco estiver logado
- gravar a ordem no momento em que a foto e solta
- mostrar essa ordem na proxima abertura, para o dono e para o visitante
- esconder o arraste de quem nao e o dono logado daquele espaco

## Requisitos implicitos ja visiveis

- a foto grande do topo e as de "A casa" sao a mesma sequencia; a primeira continua grande
- a grade de duas colunas permanece, inclusive a ultima foto larga quando a quantidade e impar
- a ordem gravada e a do espaco, nao de um orcamento isolado
- so entram as fotos que a pagina ja mostra

## Casos de erro e borda ja percebidos

- visitante ou dono de outro espaco: as fotos ficam fixas
- uma unica foto: nao ha destino para arrastar
- galeria vazia: a secao continua oculta
- soltar no mesmo lugar: nada e gravado
- falha ao gravar: a ordem visual volta para a ultima ordem salva

## Dependencias

- a pagina publica e a ordenacao por Posicao ja existem
- a gravacao precisa reconhecer o dono logado daquele espaco

## Restricoes e cuidados

- nao abrir o arraste para quem apenas possui o link
- nao criar upload, coluna nova nem outra lista de fotos
- nao alterar carrossel, cores, textos, mapa nem rodape
- a ordem nova passa a valer em toda superficie que ja le a Posicao dessas fotos

## Perguntas em aberto

- A foto grande entra no arraste? Premissa: sim; ela e a primeira da mesma sequencia.
- Quem pode arrastar? Premissa: usuario logado que ja pode editar as imagens daquele espaco.
- Quando grava? Premissa: ao soltar, sem botao extra de salvar.
- A ordem vale so neste orcamento? Premissa: nao; vale para as fotos do espaco e para as proximas propostas publicas.

## Prioridade sugerida

Media. A pagina publica ja esta em uso e a ordem ainda depende do numero editado no painel.

## Faixa sugerida para task workflow

- `C` — gravacao nova a partir de uma pagina publica, nos dois repositorios
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o arraste no link publico precisa de permissao do dono e de gravacao da ordem; isso cruza frontend e backend e nao cabe numa task isolada

## Sugestao de slug da spec

- `framework_core/specs/2026-11-04-reordenar-fotos-proposta-publica/`

## Sugestao de nome do arquivo

- `reordenar-fotos-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-04-reordenar-fotos-proposta-publica/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria` com `tasking/task-request-repo-split-prompt.md` depois da spec, porque a gravacao separa `backend` e `frontend`
