# Solicitacao da Tarefa

## Nome sugerido da tarefa

Corrigir o papel das cores na proposta publica

## Resumo da solicitacao

Na pagina publica do orcamento, a cor primaria pinta o fundo, a secundaria pinta os cards e a cor do texto pinta a fonte.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: a cor do texto continuar perdendo para titulos e icones pintados com a primaria, ou o fundo e os cards trocarem de novo
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: schema, API, gravacao das cores, painel administrativo, site da organizacao e o restante do layout da apresentacao
- prova minima desta execucao: com primaria, secundaria e texto preenchidos, a pagina publica mostra fundo na primaria, cards na secundaria e fonte na cor do texto; com uma cor vazia, so esse papel volta ao visual atual
- criterio de escalada: promover para `normal` se a correcao exigir mudar contrato ou coluna; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no bloco que aplica `proposalPrimaryColor`, `proposalSecondaryColor` e `proposalTextColor`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/specs/2026-11-04-apresentacao-publica-orcamento/02-clarify.md#Premissas assumidas`
- caminhos candidatos: secoes com fundo branco em `ProposalView`; campos "Cores da proposta" em `VenueSettings`
- palavras-chave ou simbolos de busca: `proposalPrimaryColor`, `proposalSecondaryColor`, `proposalTextColor`, `bg-white`
- testes provaveis: abrir a pagina publica de um orcamento com as tres cores salvas e com uma delas vazia
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a pagina publica e a secao "Cores da proposta" abertas: a primaria deveria ser a do fundo, a secundaria a dos cards e a cor da letra a cor da fonte.

## Problema atual

A primaria pinta titulos, icones e total. A secundaria pinta o fundo da pagina. Os cards continuam brancos, e a cor do texto nao governa a fonte inteira.

## Objetivo da mudanca

Na pagina publica do orcamento, fundo usa a cor primaria, cards usam a secundaria e toda a fonte usa a cor do texto.

## Escopo inicial percebido

Ajuste visual na pagina que ja consome as tres cores do espaco. Os campos de Configuracoes e as colunas ja existem.

## Itens incluidos neste request

- fundo da pagina na cor primaria
- cards da pagina na cor secundaria
- fonte, inclusive titulo, icone e total, na cor do texto
- cada cor vazia continua caindo so no visual atual daquele papel

## Requisitos implicitos ja visiveis

- as tres cores ja gravadas nao mudam de coluna nem de nome
- a escolha continua valendo so na pagina publica do orcamento
- "Usar cores padrao" continua limpando as tres cores

## Casos de erro e borda ja percebidos

- uma cor vazia nao pode apagar as outras duas
- titulo, icone, total e link de WhatsApp nao podem continuar na primaria
- a galeria "A casa" nao e card; a frase usa a cor do texto sobre o fundo
- cor invalida continua nao sendo salva

## Dependencias

- a pagina publica da apresentacao ja aplica as tres cores
- as colunas `proposalPrimaryColor`, `proposalSecondaryColor` e `proposalTextColor` ja estao no `main`

## Restricoes e cuidados

- nao criar coluna, endpoint nem permissao
- nao pintar o painel nem o site da organizacao
- nao redesenhar capa, fotos, servicos nem card de valor alem do papel das cores
- a premissa antiga de papeis (primaria em titulo, secundaria em fundo) fica substituida por este pedido

## Perguntas em aberto

- Titulo, icone, total e WhatsApp entram na cor do texto? Premissa: sim; a primaria deixa de pintar fonte.
- Quais blocos sao cards? Premissa: as secoes hoje brancas (evento, caracteristicas, servicos inclusos e valor). A galeria fica sem preenchimento de card.
- O formulario de Configuracoes muda os rotulos? Premissa: nao; os tres nomes permanecem e o texto de ajuda pode dizer o papel de cada uma.

## Prioridade sugerida

Alta. A pagina publica ja esta no ar com o papel das cores invertido em relacao ao que o operador escolheu.

## Faixa sugerida para task workflow

- `A` — uma tela, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: corrige o papel das cores de uma pagina que ja existe na spec `apresentacao-publica-orcamento`; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; permanece em `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `papeis-cores-proposta-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
