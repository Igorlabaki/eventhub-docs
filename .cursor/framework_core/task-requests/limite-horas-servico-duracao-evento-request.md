# Solicitacao da Tarefa

## Nome sugerido da tarefa

Limitar as horas do servico a duracao do evento

## Resumo da solicitacao

No modal "Adicionar servico" e na criacao publica do orcamento, a quantidade de horas de um servico por hora nao pode passar da duracao do evento. Se passar, a mensagem de erro aparece na hora, no campo.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — valor do orcamento em formulario e link publicos
- risco principal: a tela recusar e a API gravar mais horas do que o evento, ou a mensagem so aparecer depois de confirmar
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: criar campo de horas no painel interno; preco fixo, preco por pessoa e preco da locacao; obrigatoriedade por numero de pessoas; reescrever orcamento ja salvo so porque a quantidade antiga passa da duracao
- prova minima desta execucao: com evento de N horas, digitar N+1 no "Quantas horas?" do modal e da criacao publica mostra na hora a frase de que nao pode passar da duracao; N confirma; a API recusa N+1 na criacao e no ajuste publico e nao grava
- criterio de escalada: promover para spec antes de executar; voltar para `normal` somente se a regra ficar so na tela
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `node`, `patterns`, `react`, `design`, `security`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/task-requests/horas-servico-por-hora-request.md#Perguntas em aberto`
  - `.cursor/framework_core/specs/2026-11-04-horas-servico-por-hora/01-spec.md#Criterios de aceite`
- caminhos candidatos: campo "Quantas horas?" no modal "Adicionar servico" e nos formularios publicos de criar orcamento; validacao das horas na criacao por pessoa, na criacao por dia e na gravacao publica de servicos
- palavras-chave ou simbolos de busca: `Quantas horas?`, `chosenServiceHours`, `SERVICE_HOURS_MESSAGE`, `resolvePublicHours`, `PER_HOUR`
- testes provaveis: `npm test -- --run` no backend na cotacao e na gravacao publica; no formulario e no modal, digitar acima da duracao e ver o erro antes de confirmar
- nao ler por padrao: `topics/`, specs de outras frentes, locacao do espaco, contrato e e-mail

## Contexto informado na entrada

Pedido em chat, com o modal "Adicionar servico" aberto e "Painel de Led" marcado em "Quantas horas?". Nem nesse modal nem na criacao do orcamento a pessoa pode informar mais horas do que o evento dura. Se informar, a mensagem de erro ja aparece dizendo isso.

## Problema atual

O campo aceita qualquer inteiro de 1 a 8760. Nao compara com a duracao do evento. A frase atual so fala de numero inteiro e so aparece ao confirmar ou enviar. A API grava essa quantidade.

## Objetivo da mudanca

Informar mais horas do que o evento dura nao grava, e a mensagem no campo aparece assim que o numero passa da duracao.

## Escopo inicial percebido

Os dois lugares em que o cliente digita as horas, mais a recusa no servidor. Toca `backend` e `frontend` e aperta o contrato ja fechado de horas escolhidas no servico por hora.

## Itens incluidos neste request

- teto igual a duracao do evento no modal "Adicionar servico"
- o mesmo teto na criacao publica do orcamento, por pessoa e por dia
- mensagem no campo assim que o numero passa da duracao
- confirmar e enviar continuam bloqueados enquanto o numero passar
- a API recusa o mesmo caso na criacao e no ajuste publico e nao grava

## Requisitos implicitos ja visiveis

- a tela nao substitui a validacao da API publica
- quantidade igual a duracao continua valida
- vazio, zero, negativo e fracao continuam com a recusa que ja existe
- servico fixo e servico por pessoa continuam sem o campo
- a duracao e a mesma conta de horas inteiras ja usada na cotacao, inclusive quando o fim cai no dia seguinte
- no orcamento por dia, a duracao vai do check-in do primeiro dia ao check-out do ultimo
- dinheiro e horario wall-clock permanecem como estao
- orcamento aprovado ou pago continua sem gravar servicos

## Casos de erro e borda ja percebidos

- numero uma hora acima da duracao: erro na hora, envio parado, API nao grava
- numero igual a duracao: segue
- apagar ou voltar para um numero valido: a mensagem some
- valor ja preenchido acima da duracao: a mensagem aparece e confirmar fica bloqueado
- duracao do evento igual a zero: inteiro positivo tambem nao passa
- orcamento ja salvo com quantidade acima da duracao: nao e reescrito sozinho; a recusa vale quando a pessoa informa de novo

## Dependencias

- o campo "Quantas horas?" ja existe no modal publico e nos dois formularios publicos de criar orcamento
- a quantidade escolhida ja entra na linha do servico por hora
- o painel interno nao pede horas; envia a duracao do evento
- mudanca multi-repo: derivar com `tasking/task-request-repo-split-prompt.md` depois da spec

## Restricoes e cuidados

- nao criar campo de horas no painel
- nao alterar preco fixo, preco por pessoa nem preco da locacao
- nao mudar a obrigatoriedade do servico
- nao ler nem versionar valores de `.env`
- a rota publica ja existe; o teto e validado no backend, nao so no formulario

## Perguntas em aberto

- Qual frase exata? Premissa: dizer que o servico nao pode ter mais horas do que o evento e mostrar essa duracao.
- Igual a duracao vale? Premissa: sim. So acima da duracao e erro.
- O painel tambem ganha o campo? Premissa: nao. La as horas ja sao as do evento.
- Orcamento antigo acima da duracao e corrigido sozinho? Premissa: nao.

## Prioridade sugerida

Media. O campo ja existe; falta o teto da duracao do evento.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: a regra entra no modal publico e nos dois formularios de criar orcamento, e a API de criacao e de ajuste publico precisa recusar o mesmo caso. Toca `backend` e `frontend` e altera o contrato de horas escolhidas. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/limite-horas-servico-duracao-evento/`

## Sugestao de nome do arquivo

- `limite-horas-servico-duracao-evento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-04-limite-horas-servico-duracao-evento/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
