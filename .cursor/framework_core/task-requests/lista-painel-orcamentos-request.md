# Solicitacao da Tarefa

## Nome sugerido da tarefa

Deixar a pagina de orcamentos parecida com a referencia, com filtros, KPIs e paginacao no backend

## Resumo da solicitacao

A pagina de orcamentos do painel fica parecida com a referencia: ano, meses, busca, copiar o link do formulario, dia, tres cards e tabela com status. Filtros, ordenacao, paginacao de 10 e os tres KPIs sao calculados no backend. A lista de eventos usa o mesmo contrato, tambem de 10 em 10, e o front so consome.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — a lista mostra nome do cliente e valor, e continua restrita ao espaco autorizado
- risco principal: a tela paginar ou somar no navegador, ou a lista de eventos passar a misturar orcamento nao aprovado
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: redesenhar a pagina de eventos no visual da referencia; criar status Enviado ou coluna nova; mudar o relatorio anual; definir acoes do menu de tres pontos; paginas publicas do orcamento
- prova minima desta execucao: na pagina de orcamentos, o mes, o dia e a busca pedem a API e a tabela mostra no maximo 10 linhas; os tres cards e o total "N orcamentos" repetem os numeros da resposta, nao a soma da pagina; a lista de eventos pede so os aprovados, tambem de 10 em 10
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se a mudanca ficar só no visual e a listagem atual ja devolver pagina, totais e KPIs
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `architecture`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/database/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: pagina de orcamentos do painel; lista de eventos do painel; listagem de propostas usada pelas duas telas
- palavras-chave ou simbolos de busca: `fetchProposals`, `fetchEvents`, `proposal/list`, `approved`
- testes provaveis: `npm test -- --run` no backend da listagem; no painel, orcamentos com pagina de 10, cards vindos da resposta e eventos aprovados paginados
- nao ler por padrao: `topics/`, specs de outras frentes, relatorio anual, pagamento e paginas publicas

## Contexto informado na entrada

Pedido em chat, com a pagina de orcamentos do painel aberta e uma referencia visual. A referencia tem o ano, os meses, a busca, o botao de copiar o link do formulario, o dia, tres cards (total de orcamentos, valor no mes e conversao) e a tabela com cliente, data do evento, valor total e status. A paginacao e de 10 em 10. Filtros, paginacao e KPIs sao calculados no backend; o front so consome. A lista de eventos entra no mesmo acerto, para nao baixar o mes inteiro.

## Problema atual

A pagina de orcamentos pede o mes inteiro e filtra nome e dia no navegador. Nao ha pagina, cards nem coluna de status. A lista de eventos faz o mesmo com os orcamentos aprovados: baixa o mes e busca o nome no navegador.

## Objetivo da mudanca

Quem abre orcamentos ve a pagina parecida com a referencia, com no maximo 10 linhas por pagina, e os cards de total, valor no mes e conversao iguais aos numeros calculados no backend para o filtro inteiro. Quem abre eventos recebe so a pagina de 10 orcamentos aprovados, com a busca tambem no backend.

## Escopo inicial percebido

A listagem compartilhada pelas duas telas e o visual da pagina de orcamentos. Toca `frontend` e `backend`. O contrato da lista passa a devolver a pagina, o total do filtro e os KPIs. A tela deixa de contar, somar ou paginar no navegador.

## Itens incluidos neste request

- pagina de orcamentos parecida com a referencia: ano, meses, busca, copiar link do formulario, dia, tres cards e tabela
- coluna de status com Aberto e Fechado
- paginacao de 10 em 10
- mes, dia, busca e ordenacao calculados no backend
- total, valor no mes, conversao e a serie dos graficos calculados no backend para o filtro inteiro, nao para a pagina
- lista de eventos no mesmo contrato, so com aprovados, tambem de 10 em 10

## Requisitos implicitos ja visiveis

- o botao Novo Orcamento permanece na pagina de orcamentos
- o clique na linha continua abrindo o orcamento
- os tres cards e o texto "N orcamentos" usam o mesmo total do filtro
- com filtro vazio, a conversao vem pronta como zero
- a data do evento continua em wall-clock
- a lista de eventos nao ganha os cards nem o visual da referencia
- dinheiro continua no tipo ja usado no legado

## Casos de erro e borda ja percebidos

- mes sem orcamento: tabela vazia, cards em zero e paginacao sem pagina extra
- busca ou dia sem resultado: a pagina volta para a primeira e o total vem zero
- ultima pagina com menos de 10 linhas
- trocar mes, dia ou busca nao pode permanecer numa pagina que nao existe mais
- a lista de eventos nao pode incluir orcamento nao aprovado
- a lista de orcamentos nao pode ficar restrita aos nao aprovados, senao Fechado some

## Dependencias

- a referencia visual enviada no chat
- a listagem atual de propostas, compartilhada por orcamentos e eventos
- nenhum schema novo na premissa default de status

## Restricoes e cuidados

- filtros, ordenacao, paginacao e KPIs nao sao recalculados no front
- a pagina de eventos so muda o jeito de buscar, nao o visual
- nao criar status Enviado nem migration enquanto essa premissa valer
- nao reaproveitar o relatorio anual para os cards desta pagina
- a query continua limitada ao espaco autorizado
- derivar por repositorio antes de executar: `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- A referencia mostra o status Enviado, e o cadastro atual nao tem esse estado. Premissa default: mostrar Aberto quando o orcamento nao esta aprovado e Fechado quando esta. Nao criar coluna nem selo Enviado.
- Os cards devem acompanhar dia e busca, ou so o mes? Premissa default: acompanham o mesmo filtro da tabela, exceto a pagina.
- O que abre no menu de tres pontos da referencia? Premissa default: o menu nao entra nesta entrega; o clique na linha basta.
- A ordenacao inicial da tabela? Premissa default: data do evento, da mais antiga para a mais nova, calculada no backend.

## Prioridade sugerida

media

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: redesenha a jornada de listar orcamentos, muda o contrato da listagem e atravessa backend e frontend, com pagina, filtros e KPIs que se separam em tasks

## Sugestao de slug da spec

- `framework_core/specs/2026-11-05-lista-painel-orcamentos/`

## Sugestao de nome do arquivo

- `lista-painel-orcamentos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-lista-painel-orcamentos/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
