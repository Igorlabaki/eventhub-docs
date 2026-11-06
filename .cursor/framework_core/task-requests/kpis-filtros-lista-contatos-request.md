# Solicitacao da Tarefa

## Nome sugerido da tarefa

KPIs, filtros e paginas de dez na lista de contatos

## Resumo da solicitacao

Na pagina de contatos do painel, a lista passa a ter cards, filtros e paginas de dez. Filtro, pagina e calculo dos cards acontecem no backend, no mesmo padrao da pagina de orcamentos.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: nao — nao muda auth, pagamento, segredo nem campo novo; a lista continua restrita ao espaco autorizado
- risco principal: filtrar ou somar os cards so nas dez linhas da pagina, ou a lista sem pagina deixar de devolver todos os contatos
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: cadastro, edicao e exclusao do contato; pagina de indicar parceiros; formularios publicos de parceiro e colaborador; schema novo
- prova minima desta execucao: em Contatos, busca e categoria mudam a tabela pela API; os cards usam o conjunto filtrado e nao as dez linhas visiveis; a pagina mostra dez e a troca de filtro volta para a primeira
- criterio de escalada: a spec e o caminho, porque filtro, pagina e cards mudam o contrato da listagem nos dois repositorios
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/specs/2026-11-05-lista-painel-orcamentos/00-overview.md`
  - `.cursor/framework_global/framework-libs/database/index.md`
- caminhos candidatos: pagina de contatos do painel; listagem de contatos; pagina de orcamentos do painel como referencia de cards, filtro e paginacao
- palavras-chave ou simbolos de busca: `VenueContacts`, `FilterList`, `contact/list`, `PAGE_SIZE`, `ProposalListPager`
- testes provaveis: `npm test -- --run` no backend da listagem; no painel, busca, categoria, cards do conjunto filtrado e pagina de dez
- nao ler por padrao: `security`, `topics/`, specs de outras frentes, pagamento e formularios publicos

## Contexto informado na entrada

Pedido em chat, com a pagina de contatos aberta. A tela precisa de KPIs, filtros e paginacao de dez em dez. Filtro, pagina e calculo dos KPIs ficam no backend. A pagina de orcamentos e o padrao a seguir.

## Problema atual

A listagem de contatos devolve a lista inteira. A busca por nome, funcao, WhatsApp e e-mail acontece no navegador. Nao ha cards nem paginas de dez.

## Objetivo da mudanca

Quem abre Contatos filtra a lista, ve os cards desse conjunto e avanca de dez em dez, com filtro, pagina e cards calculados no backend como na pagina de orcamentos.

## Escopo inicial percebido

A pagina de contatos do painel e o contrato da listagem que alimenta a tabela e os cards. Toca `frontend` e `backend`. A aba Parceiros / Equipe permanece. A lista chamada sem pagina continua inteira.

## Itens incluidos neste request

- cards da lista de contatos, calculados no backend sobre o conjunto filtrado
- filtros da lista no backend
- paginas de dez, com o total vindo da API
- a tela segue o padrao visual e de comportamento da pagina de orcamentos

## Requisitos implicitos ja visiveis

- a busca atual (nome, funcao, WhatsApp e e-mail) deixa o navegador e passa a ir na consulta
- trocar filtro ou aba volta para a primeira pagina
- os cards ignoram a pagina e usam o mesmo filtro da tabela
- criar, editar e apagar recarregam a lista com o filtro e a pagina atuais
- a aba Parceiros / Equipe continua sendo o tipo do contato
- quem lista sem pedir pagina recebe a lista completa

## Casos de erro e borda ja percebidos

- conjunto filtrado vazio: tabela vazia, cards zerados e sem paginacao extra
- menos de dez contatos: uma pagina so, pager oculto
- apagar o ultimo item da pagina: a lista volta para a pagina anterior
- aba Equipe: o filtro de categoria nao se aplica
- a tela que indica parceiros nao pode passar a receber so dez contatos

## Dependencias

- a listagem paginada de orcamentos como padrao de contrato e de tela (`specs/2026-11-05-lista-painel-orcamentos/`)
- nenhum schema novo na premissa default

## Restricoes e cuidados

- nao calcular os cards no navegador a partir das linhas da pagina
- nao filtrar nem paginar so nas linhas ja carregadas
- a query continua limitada ao espaco autorizado
- derivar por repositorio antes de executar: `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Quais cards? Premissa default: Total, Com logo e Com descricao, no conjunto filtrado.
- Quais filtros alem da busca? Premissa default: categoria so na aba Parceiros; a aba continua sendo o tipo.
- Os cards acompanham busca, tipo e categoria? Premissa default: acompanham esses filtros e ignoram a pagina.

## Prioridade sugerida

media

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: muda o contrato da listagem (filtro, pagina de dez e cards) e atravessa backend e frontend, com tela e API que se separam em tasks

## Sugestao de slug da spec

- `framework_core/specs/2026-11-05-kpis-filtros-lista-contatos/`

## Sugestao de nome do arquivo

- `kpis-filtros-lista-contatos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-kpis-filtros-lista-contatos/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
