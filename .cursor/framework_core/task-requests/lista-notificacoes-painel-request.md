# Solicitacao da Tarefa

## Nome sugerido da tarefa

KPIs, filtros, paginas e leitura na lista de notificacoes

## Resumo da solicitacao

Na pagina de notificacoes do painel, a lista passa a ter quatro cards, filtros e paginas de dez, calculados no backend. Abrir o orcamento no painel marca as notificacoes dele como lidas. A tela ganha um botao para marcar todas as nao lidas do espaco.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — `GET /proposal/byId/:proposalId` tambem atende o link publico; a leitura anonima nao pode gravar `isRead`
- risco principal: marcar como lida na leitura publica do orcamento, ou calcular os cards so nas dez linhas da pagina
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: extrair valor em reais do texto da notificacao; um card por tipo do enum; schema novo; marcar como lida ao abrir o orcamento pelo link publico
- prova minima desta execucao: em Notificacoes, busca, tipo e lida/nao lida mudam a lista pela API; os quatro cards usam o conjunto filtrado e nao as dez linhas; a pagina mostra dez; abrir o orcamento no painel tira o selo Novo; o link publico nao tira; Marcar todas como lidas zera as nao lidas do espaco
- criterio de escalada: a spec e o caminho, porque filtro, pagina, cards e a gravacao de lida mudam contrato nos dois repositorios e cruzam a rota publica do orcamento
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `architecture`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/project-decisions.md#D-05`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: pagina de notificacoes do painel; listagem de notificacoes; detalhe do orcamento no painel; listagem de contatos como referencia de cards, filtro e pagina de dez
- palavras-chave ou simbolos de busca: `VenueNotifications`, `FilterList`, `notification/list`, `isRead`, `GET /proposal/byId`, `PAGE_SIZE`
- testes provaveis: `npm test -- --run` no backend da listagem e da marcacao de lida; no painel, filtros, cards, pagina de dez, selo Novo ao abrir o orcamento e o botao de marcar todas
- nao ler por padrao: `topics/`, pagamento, formularios publicos de orcamento alem do cuidado de nao gravar `isRead` na leitura anonima

## Contexto informado na entrada

Pedido em chat, com a pagina de notificacoes aberta. A tela precisa de KPIs, filtros e paginacao, tudo no backend. Os cards fechados sao Nao lidas, Ultimos 7 dias, Ultimos 30 dias e Orcamentos novos. Visita fica como filtro. O selo Novo sai quando o orcamento e aberto em qualquer tela do painel. A lista ganha Marcar todas como lidas. O link publico do orcamento nao marca como lida.

## Problema atual

`GET /notification/list/:venueId` devolve no maximo 25 linhas, da mais nova para a mais antiga. A busca por texto acontece no navegador, so nesse recorte. Nao ha cards nem paginas. `isRead` nasce falso e nenhuma rota grava verdadeiro, entao o selo Novo nao sai ao abrir o orcamento.

## Objetivo da mudanca

Quem abre Notificacoes filtra a lista, ve os quatro cards desse conjunto e avanca de dez em dez, com filtro, pagina e cards calculados no backend. Abrir o orcamento no painel marca as notificacoes dele como lidas. Marcar todas como lidas zera as nao lidas do espaco.

## Escopo inicial percebido

A pagina de notificacoes do painel, o contrato da listagem e a gravacao de `isRead` ao carregar o detalhe do orcamento no painel. Toca `frontend` e `backend`. Sem coluna nova: `content`, `type`, `createdAt` e `isRead` ja existem.

## Itens incluidos neste request

- quatro cards calculados no backend: Nao lidas, Ultimos 7 dias, Ultimos 30 dias e Orcamentos novos (`type = PROPOSAL` nos ultimos 30 dias)
- filtros no backend: texto em `content`, tipo e lida ou nao lida
- paginas de dez, com o total vindo da API
- abrir o orcamento no painel marca como lidas as notificacoes daquele `proposalId`
- botao Marcar todas como lidas, no espaco inteiro

## Requisitos implicitos ja visiveis

- os cards sao `count` no conjunto filtrado, sem `skip` nem `take`
- busca, tipo e lida/nao lida entram no mesmo filtro dos cards; a pagina nao entra
- as janelas de 7 e 30 dias sao o periodo do card, nao um filtro extra da lista
- visita e os demais tipos ficam no filtro de tipo, nao em card proprio
- trocar filtro volta para a primeira pagina
- quem lista sem pedir pagina continua recebendo o recorte atual de ate 25, para nao quebrar a chamada existente
- `summary` so vale junto com pagina
- abrir o orcamento pela lista de orcamentos, pela agenda ou por outro atalho do painel tambem marca como lida
- a marcacao do orcamento cobre todas as notificacoes nao lidas daquele `proposalId`, inclusive visita ligada a ele
- aviso sem `proposalId` continua Novo ate o botao de marcar todas
- o botao ignora pagina, busca e filtro

## Casos de erro e borda ja percebidos

- conjunto filtrado vazio: lista vazia, cards zerados e sem paginacao extra
- menos de dez notificacoes: uma pagina so
- nenhuma nao lida: o botao nao grava de novo e o card Nao lidas fica em zero
- leitura anonima de `GET /proposal/byId/:proposalId`, inclusive o link publico, nao grava `isRead`
- varias notificacoes do mesmo orcamento: abrir o detalhe no painel marca todas
- notificar valor em reais a partir do texto fica fora; a lista de orcamentos ja tem esse numero

## Dependencias

- a listagem paginada de contatos como padrao de contrato (`specs/2026-11-05-kpis-filtros-lista-contatos/`)
- nenhum schema novo na premissa default

## Restricoes e cuidados

- nao calcular os cards no navegador a partir das linhas da pagina
- nao filtrar nem paginar so nas linhas ja carregadas
- a query continua limitada ao espaco
- a gravacao de lida no detalhe do orcamento exige sessao do painel; a rota publica permanece sem esse efeito
- derivar por repositorio antes de executar: `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Os cards acompanham busca, tipo e lida/nao lida? Premissa default: acompanham esses filtros e ignoram a pagina.
- Sem `page`, a lista segue no teto de 25? Premissa default: sim.
- Marcar todas age no espaco inteiro, mesmo com filtro ativo? Premissa default: sim.

## Prioridade sugerida

media

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: muda o contrato da listagem (filtro, pagina de dez e cards), grava leitura ao abrir o orcamento e atravessa backend, frontend e a rota publica do orcamento

## Sugestao de slug da spec

- `framework_core/specs/2026-11-05-lista-notificacoes-painel/`

## Sugestao de nome do arquivo

- `lista-notificacoes-painel-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-lista-notificacoes-painel/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
