# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abrir o detalhe do orcamento em nova aba e resetar o formulario

## Resumo da solicitacao

Ao criar um orcamento pelo painel, a aba atual deve permanecer no formulario vazio e o detalhe do orcamento criado deve abrir em uma aba nova.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: limpar o formulario tambem quando a criacao falhar, ou abrir a vista publica do cliente (`/proposal/:id/view`) em vez da visao geral interna
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: formulario publico do cliente; API e schema; clique da lista, que ja abre o detalhe em nova aba; edicao de orcamento existente
- prova minima desta execucao: no painel, criar um orcamento (espaco com pernoite e espaco sem pernoite) e confirmar que uma aba nova termina em `/proposal/<id>` e que a aba do formulario fica no estado inicial, pronta para outro orcamento; em falha de criacao, nenhuma aba nova abre e os dados digitados permanecem
- criterio de escalada: promover para `normal` se os dois modos de criacao do painel nao puderem compartilhar o mesmo desfecho; `spec` nao se aplica
- nivel de autonomia: `L2`
- camadas transversais: `design`. `security`, `database`, `observability` e `patterns` nao se aplicam

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx#handleCreateNewProposal`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: formularios de criacao abertos por "Novo Orcamento" em `VenueBudgets`; rota `/proposal/:id` da visao geral
- palavras-chave ou simbolos de busca: `navigate`, `createProposalPerDay`, `createProposalPerPerson`, `Novo Orcamento`, `/proposal/`
- testes provaveis: fluxo manual no painel; teste de frontend se ja existir cobertura desses formularios
- nao ler por padrao: `security`, `topics/`, `specs/`, backend e schema

## Contexto informado na entrada

Pedido em chat: ao criar um orcamento, o usuario e levado ao detalhe na mesma aba. O desejado e abrir esse detalhe em uma aba nova e, na aba do formulario, deixar tudo vazio depois do sucesso.

## Problema atual

Depois de criar o orcamento pelo painel, a mesma aba navega para `/proposal/<id>`. Quem quer lancar outro orcamento precisa voltar e abrir o formulario de novo. Os dados do orcamento recem-criado continuam na tela ate essa navegacao.

## Objetivo da mudanca

Apos criar um orcamento com sucesso pelo painel, a aba do formulario volta ao estado inicial e o detalhe desse orcamento abre em uma aba nova, na rota `/proposal/<id>`.

## Escopo inicial percebido

Ajuste de desfecho no fluxo "Novo Orcamento" do painel, nos dois modos ja usados nessa tela (com e sem pernoite). O id do orcamento criado ja volta na resposta de criacao.

## Itens incluidos neste request

- apos criacao bem-sucedida no painel, abrir `/proposal/<id>` em aba nova
- manter a aba atual no formulario de novo orcamento, resetado
- cobrir os dois modos de criacao do painel
- se nao houver id utilizavel, nao tratar o caso como sucesso

## Requisitos implicitos ja visiveis

- a pagina da aba nova e a visao geral interna, nao a vista publica do cliente
- o feedback de sucesso ja existente pode permanecer
- falha de criacao nao abre aba nova e nao apaga o que foi digitado
- "vazio" significa o estado inicial do formulario, o mesmo de quando "Novo Orcamento" acaba de abrir

## Casos de erro e borda ja percebidos

- criacao recusada ou erro de API: permanecer no formulario preenchido, com a mensagem de erro, sem aba nova
- resposta de sucesso sem id: nao abrir aba nova e nao limpar o formulario como se a criacao tivesse concluido; manter o retorno atual a lista
- navegador bloqueia a aba nova: o orcamento criado nao deve ser desfeito e o formulario da aba atual ainda deve resetar
- espaco com pernoite e espaco sem pernoite: os dois caminhos do botao "Novo Orcamento" precisam do mesmo desfecho
- servicos ou adicionais marcados no formulario tambem voltam ao estado inicial

## Dependencias

- nenhuma dependencia externa
- a criacao pelo painel precisa continuar devolvendo o id do orcamento

## Restricoes e cuidados

- nao alterar o formulario publico, que ja segue para a vista do cliente
- nao mudar contrato de API, permissao nem o clique na lista
- nao substituir a visao geral interna pela rota publica `/proposal/:id/view`

## Perguntas em aberto

- A aba nova abre a visao geral interna ou a vista do cliente? Premissa: visao geral interna, rota `/proposal/<id>`.
- A aba do formulario volta para a lista ou continua em "Novo Orcamento"? Premissa: continua no formulario resetado.
- Horarios que o formulario de pernoite ja traz do espaco devem sumir? Premissa: nao; o reset reproduz o estado inicial, inclusive esses horarios.
- O formulario publico do cliente entra neste ajuste? Premissa: nao.

## Prioridade sugerida

Media. Ajuste de fluxo diario do painel, sem bloqueio de dado ou pagamento.

## Faixa sugerida para task workflow

- `A` — um comportamento de navegacao e reset, frente unica, criterio de pronto observavel
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: nao cria jornada, contrato nem modulo; muda o desfecho de uma acao que ja existe

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `detalhe-orcamento-em-nova-aba-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
- status: executado em 2026-11-04; review de entrega ainda nao rodou. Fluxo no browser nao exercitado: a tela de orcamentos redireciona para o login
