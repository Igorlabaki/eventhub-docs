# Solicitacao da Tarefa

## Nome sugerido da tarefa

Pedir quantas horas o cliente quer no servico por hora

## Resumo da solicitacao

Quando o servico e cobrado por hora e o cliente marca ele, o formulario mostra um campo para a quantidade de horas. Essa quantidade entra na conta da linha.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — valor do orcamento em formulario e link publicos
- risco principal: aceitar a hora digitada so na tela e continuar multiplicando pela duracao do evento, ou gravar hora zero e zerar a linha
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: preco fixo e preco por pessoa; preco da locacao do espaco; regra de obrigatoriedade a partir de N pessoas; foto e descricao do servico; o painel interno escolher horas no lugar da duracao do evento
- prova minima desta execucao: no passo "Como nos encontrou", marcar um servico por hora mostra o campo de horas e desmarcar esconde; servico fixo ou por pessoa nao mostra o campo; enviar sem horas, com zero ou com fracao nao cria o orcamento; enviar 3 horas grava quantidade 3 e valor unitario vezes 3; a API recusa hora ausente, zero ou nao inteira nesse servico; no link publico, marcar o mesmo tipo de servico pede as horas e atualiza o total; um orcamento ja salvo com servico por hora permanece com a quantidade que tinha
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o campo ficar só visual e a conta continuar sendo a duracao do evento
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `node`, `patterns`, `react`, `design`, `security`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-07`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/task-requests/preco-foto-descricao-servico-request.md#Perguntas em aberto`
- caminhos candidatos: passo "Como nos encontrou" dos formularios publicos de orcamento; modal de servicos do link publico; calculo da linha do servico na criacao, na edicao publica e no recalculo
- palavras-chave ou simbolos de busca: `PER_HOUR`, `quoteServiceLines`, `serviceIds`, `pricingType`, `ProposalService`
- testes provaveis: `npm test -- --run` no backend nos testes da cotacao do servico; no formulario publico, marcar, informar horas e conferir o total
- nao ler por padrao: `topics/`, specs de outras frentes, locacao do espaco, contrato e e-mail

## Contexto informado na entrada

Pedido em chat, com o passo "Como nos encontrou" na tela: quando o servico for por hora e o cliente escolher, deve aparecer um input de quantas horas ela quer. O exemplo visivel e "Painel de Led (R$ 250,00/hora)".

## Problema atual

O servico por hora aparece com o rotulo "/hora", mas a marcacao so envia o id. A quantidade da linha sai das horas entre o inicio e o fim do evento. O cliente nao informa quantas horas quer daquele servico.

## Objetivo da mudanca

O cliente marca um servico por hora, informa um numero inteiro de horas, e o orcamento grava essa quantidade na linha.

## Escopo inicial percebido

Campo no formulario publico e no ajuste de servicos do link publico, mais a conta no servidor. Toca `backend` e `frontend` e muda a premissa de que a hora do servico e sempre a duracao do evento.

## Itens incluidos neste request

- campo de horas visivel so quando o servico por hora esta marcado
- a quantidade escolhida entra na linha e no total
- a mesma pergunta no modal de servicos do link publico
- o servidor recusa a linha por hora sem uma quantidade inteira valida
- orcamentos ja salvos mantem a quantidade gravada

## Requisitos implicitos ja visiveis

- a hora digitada na tela nao vale se o servidor nao usar essa quantidade
- servico fixo e servico por pessoa continuam sem campo de horas
- servico por hora obrigatorio, com checkbox travado, tambem pede as horas
- desmarcar o servico esconde o campo e nao envia as horas
- dinheiro continua no tipo ja usado no legado
- horario do evento permanece wall-clock
- a pagina publica nao passa a expor a tabela de precos alem da linha deste orcamento

## Casos de erro e borda ja percebidos

- horas vazias, zero, negativas ou fracionadas: o envio para e o servidor recusa
- desmarcar e marcar de novo: o campo volta vazio
- mudar dia, convidados ou horario do evento: as horas ja escolhidas do servico permanecem
- orcamento ja confirmado ou pago: o link publico continua sem alterar servicos
- orcamento antigo com servico por hora: a quantidade ja gravada permanece, sem pedir horas de novo sozinho

## Dependencias

- o tipo de preco por hora ja existe no cadastro do servico
- a linha do orcamento ja guarda quantidade
- a premissa atual, no request de preco do servico, e que a hora da linha e o intervalo do evento; este pedido substitui essa premissa so para o servico por hora escolhido pelo cliente
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao criar outro tipo de preco
- nao alterar o preco da locacao do espaco
- nao mudar a obrigatoriedade do servico a partir de um numero de pessoas
- nao ler nem versionar valores de `.env`
- a rota publica ja existe; a quantidade de horas e validada no backend, nao so no formulario

## Perguntas em aberto

- Onde o campo aparece? Premissa: nos dois formularios publicos de criar orcamento e no modal de servicos do link publico. O painel interno continua usando a duracao do evento.
- Servico por hora obrigatorio tambem pede horas? Premissa: sim.
- Qual numero vale? Premissa: inteiro maior ou igual a 1. Sem teto de negocio.
- Recalcular dia, convidados ou horario muda essas horas? Premissa: nao.
- Orcamento ja salvo muda sozinho? Premissa: nao. Mantem a quantidade gravada.

## Prioridade sugerida

Media. O rotulo por hora ja existe; falta a quantidade que o cliente escolhe.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o campo entra em dois formularios publicos e no link publico, e a conta muda na criacao, na edicao publica e no recalculo. Toca `backend` e `frontend` e substitui uma premissa ja fechada. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/horas-servico-por-hora/`

## Sugestao de nome do arquivo

- `horas-servico-por-hora-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-04-horas-servico-por-hora/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
