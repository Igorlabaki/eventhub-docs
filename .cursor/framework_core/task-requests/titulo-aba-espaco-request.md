# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mostrar nome e descricao do espaco na aba do painel

## Resumo da solicitacao

A aba do navegador em `/venue/:id` passa a mostrar o nome e a descricao daquele espaco. O titulo generico EventHub deixa de aparecer nessa pagina.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: a aba continuar com o titulo generico do EventHub, ou o titulo do espaco vazar para login, organizacao e orcamento
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: outras rotas do espaco, preview de link, meta tags, painel interno, schema e API
- prova minima desta execucao: abrir `/venue/:id` de um espaco com nome e descricao e ver os dois na aba; abrir a mesma rota de um espaco sem descricao e ver so o nome; sair para login ou organizacao e voltar a ver o titulo EventHub
- criterio de escalada: promover para `normal` se o titulo do espaco precisar valer para todas as rotas `/venue/:id/...`; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx` no titulo passado ao layout
- libs obrigatorias: `react`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `eventhub-vista-dashboard/index.html` no `title`
  - `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx`
- caminhos candidatos: titulo fixo do HTML; dados `name` e `description` do espaco ja carregados no painel
- palavras-chave ou simbolos de busca: `VenueDashboard`, `document.title`, `name`, `description`, `DashboardLayout`
- testes provaveis: abrir `/venue/:id` com descricao; abrir um espaco sem descricao; navegar para fora do painel e conferir a aba
- nao ler por padrao: `security`, `design`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a aba aberta em `localhost:8080/venue/:id`. A aba mostra "EventHub - Gestao de Casas de Festas e Eventos". O esperado nessa pagina e o nome do espaco e a descricao do espaco.

## Problema atual

O titulo da aba e fixo no HTML do frontend e nao muda quando o painel do espaco carrega. O nome do espaco aparece so no cabecalho da tela. A descricao nao entra na aba.

## Objetivo da mudanca

Em `/venue/:id`, a aba do navegador mostra o nome e a descricao daquele espaco, e nao o titulo generico do EventHub.

## Escopo inicial percebido

Ajuste de uma pagina que ja existe e ja carrega nome e descricao do espaco. Sem contrato, schema ou tela nova.

## Itens incluidos neste request

- a aba de `/venue/:id` usa o nome do espaco
- a mesma aba inclui a descricao quando ela existe
- ao sair dessa pagina, a aba volta ao titulo generico do EventHub

## Requisitos implicitos ja visiveis

- vale para qualquer espaco aberto em `/venue/:id`, nao para um registro so
- nome e descricao sao os campos que o painel ja tem do espaco
- a descricao so entra na aba quando existe
- login, organizacao, orcamento e as demais rotas continuam com o titulo EventHub

## Casos de erro e borda ja percebidos

- espaco sem descricao: a aba mostra so o nome
- descricao longa: o texto entra no titulo; o navegador corta a exibicao
- espaco ainda carregando ou nao encontrado: a aba nao fica com nome ou descricao de outro espaco
- navegacao para fora de `/venue/:id`: a aba volta ao titulo EventHub

## Dependencias

- o painel `/venue/:id` ja existe e ja carrega o espaco
- o titulo generico ja existe no HTML inicial do frontend

## Restricoes e cuidados

- nao alterar o titulo das outras rotas
- nao criar endpoint nem mudar schema
- nao tratar preview de WhatsApp, busca ou meta tags neste request
- nao inventar um texto curto no lugar da descricao cadastrada

## Perguntas em aberto

- As outras telas do mesmo espaco (`/venue/:id/events`, orcamentos, ajustes) tambem trocam a aba? Premissa: nao; neste request so `/venue/:id`.
- A descricao entra inteira? Premissa: sim, junto do nome; sem descricao, so o nome.
- Meta description e preview de link tambem mudam? Premissa: nao; so o texto da aba.
- Outras areas (login, organizacao, orcamento) mudam? Premissa: nao.

## Prioridade sugerida

Media. A aba identifica o produto em vez do espaco aberto, sem o painel estar quebrado.

## Faixa sugerida para task workflow

- `A` — uma pagina, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: troca do titulo da aba de uma pagina que ja existe; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `titulo-aba-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar` a entrega; codigo em `VenueDashboard` e `venue-tab-title`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
