# Solicitacao da Tarefa

## Nome sugerido da tarefa

Trocar a tela de carregamento do link publico do orcamento pela marca do espaco

## Resumo da solicitacao

Quem abre o link publico do orcamento deixa de ver a tela de carregamento do EventHub. Enquanto a pagina carrega, a tela usa o logo e as cores daquele espaco. A tela de carregamento de dentro do sistema permanece a do EventHub.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o cliente continuar vendo a marca EventHub no link, ou a tela de dentro do sistema perder a marca EventHub
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: tela de carregamento das rotas internas, painel, textos, fotos, rodape, animacao de entrada da pagina pronta, schema e API
- prova minima desta execucao: abrir `/proposal/:id/view` de um espaco com logo e cores e ver o carregamento com esse logo e essas cores, sem a palavra EventHub nem o calendario indigo; abrir uma tela interna que ainda carrega (login ou rota protegida) e continuar vendo a tela EventHub
- criterio de escalada: promover para `normal` se a marca do espaco precisar valer para outros links publicos (convidados, equipe, agenda, contratos); `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no estado de carregamento e nas cores da pagina
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `eventhub-vista-dashboard/src/components/ui/AppLoadingScreen.tsx`
- caminhos candidatos: pagina publica da proposta; payload de apresentacao que ja traz logo e cores; tela de carregamento usada pelas rotas internas
- palavras-chave ou simbolos de busca: `AppLoadingScreen`, `ProposalView`, `logoUrl`, `proposalPrimaryColor`, `proposalSecondaryColor`, `proposalTextColor`
- testes provaveis: abrir o link publico com espaco que tem logo e cores; abrir o mesmo link de um espaco sem logo ou sem cor; abrir uma rota interna e confirmar que a tela EventHub continua
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat: a tela de carregamento do link deve ser diferente da de dentro do EventHub e seguir as cores e o logo do espaco desse link. A pagina publica, depois de carregada, ja usa o logo e as cores do espaco. O intervalo anterior ainda mostra a marca do produto.

## Problema atual

Ao abrir `/proposal/:id/view`, o cliente ve a mesma tela das rotas internas: fundo indigo, calendario, a palavra EventHub e o spinner indigo. A peca que deveria apresentar o espaco comeca com a marca do EventHub.

## Objetivo da mudanca

No link publico de qualquer orcamento, a tela de carregamento mostra o logo e as cores do espaco daquele link, e nao a marca EventHub.

## Escopo inicial percebido

Ajuste visual do carregamento de uma pagina que ja existe. Logo, nome e cores do espaco ja chegam na apresentacao publica. A tela interna `AppLoadingScreen` continua para o sistema.

## Itens incluidos neste request

- o carregamento de `/proposal/:id/view` deixa de usar a tela EventHub
- com os dados do espaco, a tela mostra o logo e as cores desse espaco
- a tela de carregamento de dentro do EventHub permanece como esta

## Requisitos implicitos ja visiveis

- a mudanca vale para todo link publico de orcamento, nao para um registro so
- logo e cores so existem depois que a apresentacao do espaco chega; ate la a tela nao pode exibir a marca EventHub
- assim que a apresentacao chega, a tela ja pode mostrar o espaco, mesmo que data, valor ou servicos ainda estejam carregando
- a pagina pronta continua com as mesmas cores, para nao haver salto de paleta
- rotas internas, login e rotas protegidas continuam com `AppLoadingScreen`

## Casos de erro e borda ja percebidos

- apresentacao ainda nao chegou: fundo neutro no mesmo fallback da pagina, sem calendario e sem a palavra EventHub
- espaco sem logo: o nome do espaco ocupa o lugar; a marca EventHub nao entra
- espaco sem cor cadastrada: o carregamento usa o mesmo fallback de fundo da pagina publica
- apresentacao falha e a pagina cai em nao encontrado: a tela de erro nao vira a marca de outro espaco
- rota interna carregando ao mesmo tempo: continua com a tela EventHub

## Dependencias

- a pagina publica ja existe em `ProposalView.tsx` e ja consome logo e cores do espaco
- `AppLoadingScreen` ja existe e segue sendo a tela interna

## Restricoes e cuidados

- nao alterar a tela de carregamento das rotas internas
- nao criar endpoint novo so para a marca
- nao mudar texto, foto, calculo, rota publica, schema nem API
- nao recolocar a marca EventHub no carregamento do link quando o espaco nao tem logo

## Perguntas em aberto

- Outros links publicos (convidados, equipe, agenda, contratos) tambem trocam de tela? Premissa: nao; neste request so `/proposal/:id/view`.
- O que aparece no primeiro instante, antes da apresentacao? Premissa: fundo neutro no fallback da pagina (`#111315`) e um spinner discreto, sem marca EventHub; logo e cores entram quando a apresentacao chega.
- Espaco sem logo mostra o que? Premissa: o nome do espaco.
- Qual cor pinta o fundo quando as tres existem? Premissa: a mesma da pagina pronta, a cor primaria; sem primaria, `#111315`.

## Prioridade sugerida

Media. O cliente ve a marca errada no primeiro contato com o link, sem o fluxo do orcamento estar quebrado.

## Faixa sugerida para task workflow

- `A` — uma pagina, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: ajuste visual do carregamento da pagina publica que ja existe; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; a pagina continua na spec `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `carregamento-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
