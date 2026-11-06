# Solicitacao da Tarefa

## Nome sugerido da tarefa

Redirecionar para a visao geral ao criar orcamento

## Resumo da solicitacao

Ao criar um orcamento novo pelo painel do espaco, o usuario autenticado deve ir para a pagina de visao geral desse orcamento, em vez de voltar para a lista.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: redirecionar para a pagina errada (`/proposal/:id/view`, vista do cliente) ou so em um dos dois modos de criacao do painel
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: formulario publico do cliente; API e schema; permissao; clique da lista que abre a visao geral em nova aba; pagina stub de novo orcamento se nao for o fluxo do botao "Novo Orcamento"
- prova minima desta execucao: no painel, criar um orcamento (espaco com pernoite e espaco sem pernoite) e confirmar que a navegacao termina em `/proposal/<id>` com o titulo de visao geral do orcamento criado; em falha de criacao, o formulario permanece com o erro
- criterio de escalada: promover para `normal` se a criacao do painel nao devolver o id do orcamento ou se os dois modos nao compartilharem o mesmo desfecho; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx#handleCreateNewProposal`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: formularios de criacao abertos por "Novo Orcamento" em `VenueBudgets`; rota `/proposal/:id` da visao geral
- palavras-chave ou simbolos de busca: `onBack`, `createProposalPerDay`, `createProposalPerPerson`, `Novo Orcamento`, `/proposal/`
- testes provaveis: fluxo manual no painel; teste de frontend se ja existir cobertura desses formularios
- nao ler por padrao: `security`, `topics/`, `specs/`, backend e schema

## Contexto informado na entrada

Pedido em chat: ao criar um orcamento novo, o usuario deveria ser redirecionado para a pagina de visao geral do orcamento criado.

## Problema atual

Depois de criar o orcamento pelo painel, a tela volta para a lista de orcamentos. A visao geral (`/proposal/:id`) nao abre para o item recem-criado.

## Objetivo da mudanca

Ao criar um orcamento pelo painel do espaco, o usuario autenticado chega na visao geral desse orcamento, na rota `/proposal/<id>`.

## Escopo inicial percebido

Ajuste de navegacao no fluxo "Novo Orcamento" do painel, nos dois modos ja usados nessa tela (com e sem pernoite). O id do orcamento criado ja volta na resposta de criacao.

## Itens incluidos neste request

- apos criacao bem-sucedida no painel, navegar para `/proposal/<id>` do orcamento criado
- cobrir os dois modos de criacao do painel
- manter o retorno a lista apenas quando nao houver id utilizavel

## Requisitos implicitos ja visiveis

- a pagina de destino e a visao geral interna, nao a vista publica do cliente
- o feedback de sucesso ja existente pode permanecer
- falha de criacao nao redireciona

## Casos de erro e borda ja percebidos

- criacao recusada ou erro de API: permanecer no formulario com a mensagem de erro
- resposta de sucesso sem id: voltar a lista, sem inventar rota
- espaco com pernoite e espaco sem pernoite: os dois caminhos do botao "Novo Orcamento" precisam do mesmo desfecho

## Dependencias

- nenhuma dependencia externa
- a criacao pelo painel precisa continuar devolvendo o id do orcamento

## Restricoes e cuidados

- nao alterar o formulario publico, que ja segue para a vista do cliente
- nao mudar contrato de API, permissao nem o comportamento do clique na lista
- nao abrir a visao geral em nova aba neste fluxo; o pedido e redirecionar quem acabou de criar

## Perguntas em aberto

- A visao geral abre na mesma aba ou em nova aba? Premissa: mesma aba, rota `/proposal/<id>`.
- O formulario publico do cliente entra neste ajuste? Premissa: nao; ele continua na vista publica.
- O toast de sucesso some? Premissa: nao; so muda o destino depois do sucesso.

## Prioridade sugerida

Media. Correcao de fluxo ja esperado no uso diario do painel, sem bloqueio de dado ou pagamento.

## Faixa sugerida para task workflow

- `A` — um comportamento de navegacao, frente unica, criterio de pronto observavel
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: nao cria jornada, contrato nem modulo; e o desfecho de uma acao que ja existe

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `redirecionar-visao-geral-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-02; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
