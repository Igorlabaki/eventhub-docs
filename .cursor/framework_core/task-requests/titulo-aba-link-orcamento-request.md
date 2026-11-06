# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mostrar nome e descricao do espaco na aba do link publico do orcamento

## Resumo da solicitacao

A aba do navegador em `/proposal/:id/view` passa a mostrar o nome e a descricao do espaco daquele orcamento. O titulo generico EventHub deixa de aparecer nesse link.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao. A rota ja e publica e o nome e a descricao ja aparecem na pagina; este request nao muda autorizacao nem o que a API devolve
- risco principal: a aba do link continuar com o titulo EventHub, ou o titulo do espaco vazar para o painel, login e as outras rotas
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: painel `/venue/:id`, outras rotas publicas, preview de link, meta tags, schema e API
- prova minima desta execucao: abrir `/proposal/:id/view` de um espaco com nome e descricao e ver os dois na aba; abrir um link de espaco sem descricao e ver so o nome; sair do link e voltar a ver o titulo EventHub
- criterio de escalada: promover para `normal` se o titulo do espaco precisar valer para outros links publicos (convidados, equipe, agenda, contratos); `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no carregamento de `presentation`
- libs obrigatorias: `react`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `eventhub-vista-dashboard/src/pages/ProposalView.tsx`
  - `eventhub-vista-dashboard/src/lib/venue-tab-title.ts`
- caminhos candidatos: apresentacao publica que ja traz `name` e `description`; titulo fixo do HTML; titulo ja aplicado no painel `/venue/:id`
- palavras-chave ou simbolos de busca: `ProposalView`, `presentation`, `document.title`, `venueTabTitle`, `name`, `description`
- testes provaveis: abrir `/proposal/:id/view` com descricao; abrir um link sem descricao; sair da pagina e conferir a aba
- nao ler por padrao: `security`, `design`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a aba aberta em `/proposal/35dcfff0-8161-4668-9546-e3876cd3150e/view`. A pagina mostra o espaco, mas a aba continua "EventHub - Gestao de Casas de Festas e Eventos". O esperado nesse link e o nome do espaco e a descricao do espaco.

## Problema atual

O titulo da aba do link publico fica no HTML inicial do frontend. `ProposalView` nao troca `document.title` quando a apresentacao do espaco chega. O ajuste anterior vale so para o painel `/venue/:id`.

## Objetivo da mudanca

Em `/proposal/:id/view`, a aba do navegador mostra o nome e a descricao do espaco daquele link, e nao o titulo generico do EventHub.

## Escopo inicial percebido

Ajuste de uma pagina publica que ja existe e ja recebe nome e descricao do espaco na apresentacao. Sem contrato, schema ou tela nova.

## Itens incluidos neste request

- a aba de `/proposal/:id/view` usa o nome do espaco
- a mesma aba inclui a descricao quando ela existe
- ao sair desse link, a aba volta ao titulo generico do EventHub

## Requisitos implicitos ja visiveis

- vale para qualquer link publico de orcamento, nao para um registro so
- nome e descricao sao os campos da apresentacao que a pagina ja usa
- a descricao so entra na aba quando existe
- o painel `/venue/:id` ja tem o proprio titulo e nao entra neste request
- login, organizacao e as demais rotas continuam com o titulo EventHub

## Casos de erro e borda ja percebidos

- espaco sem descricao: a aba mostra so o nome
- descricao longa: o texto entra no titulo; o navegador corta a exibicao
- apresentacao ainda carregando ou link inexistente: a aba nao fica com nome ou descricao de outro espaco
- navegacao para fora de `/proposal/:id/view`: a aba volta ao titulo EventHub

## Dependencias

- `ProposalView` ja existe e ja consome a apresentacao do espaco
- `venueTabTitle` ja existe para montar o texto da aba no painel
- o titulo generico ja existe no HTML inicial do frontend

## Restricoes e cuidados

- nao alterar o titulo do painel nem das outras rotas
- nao criar endpoint nem mudar schema
- nao tratar preview de WhatsApp, busca ou meta tags neste request
- nao inventar um texto curto no lugar da descricao cadastrada
- nao ampliar o que a rota publica devolve

## Perguntas em aberto

- Outros links publicos (convidados, equipe, agenda, contratos) tambem trocam a aba? Premissa: nao; neste request so `/proposal/:id/view`.
- A descricao entra inteira? Premissa: sim, junto do nome; sem descricao, so o nome.
- Meta description e preview de link tambem mudam? Premissa: nao; so o texto da aba.
- O painel `/venue/:id` muda de novo? Premissa: nao; ele ja tem o titulo do espaco.

## Prioridade sugerida

Media. Quem abre o link ve a marca do produto na aba, sem a pagina do orcamento estar quebrada.

## Faixa sugerida para task workflow

- `A` — uma pagina, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: troca do titulo da aba de uma pagina publica que ja existe; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; a pagina continua na spec `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `titulo-aba-link-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar` a entrega; codigo em `ProposalView` usando `venueTabTitle`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
