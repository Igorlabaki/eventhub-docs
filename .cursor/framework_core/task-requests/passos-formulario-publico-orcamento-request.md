# Solicitacao da Tarefa

## Nome sugerido da tarefa

Dividir o formulario publico de orcamento em tres passos

## Resumo da solicitacao

A tela publica de criar orcamento deixa de mostrar todos os campos de uma vez. O formulario passa a ter tres passos: informacoes pessoais, informacoes do evento e, no ultimo, de "Ja conhece o espaco?" para baixo.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao. O formulario ja coleta nome, e-mail e WhatsApp; este request nao muda quais campos existem nem o que e enviado
- risco principal: o cliente perder o que digitou ao trocar de passo, ou o envio acontecer antes do ultimo passo
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: formulario do painel, parceiro, equipe, contrato, schema, API e a marca do espaco ja aplicada nesta tela
- prova minima desta execucao: abrir `/venue/:id/form` e ver so os campos pessoais; avancar e ver so os campos do evento; avancar de novo e ver "Ja conhece o espaco?", servicos, "Onde nos achou?" e Enviar; voltar e encontrar os valores ainda preenchidos; o envio so ocorrer no ultimo passo. Repetir num espaco com pernoite, em que o segundo passo mostra check-in e check-out
- criterio de escalada: promover para `normal` se a troca de passo exigir estado novo fora do formulario que ja existe; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/proposal/forms/ClientPerPersonProposalForm.tsx` na ordem dos campos
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
  - `.cursor/framework_core/task-requests/marca-espaco-formulario-publico-request.md#Objetivo da mudanca`
- caminhos candidatos: formulario publico por pessoa; formulario publico por dia; pagina `/venue/:id/form`
- palavras-chave ou simbolos de busca: `ClientPerPersonProposalForm`, `ClientPerDayProposalForm`, `Ja conhece o espaco`, `Onde nos achou`
- testes provaveis: percorrer os tres passos nos dois tipos de espaco; tentar avancar com campo obrigatorio vazio; voltar e conferir o que foi digitado; enviar so no ultimo passo
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com o formulario publico do espaco AR756 aberto. Ha campos demais numa tela so. Separar em tres passos: informacoes pessoais, informacoes do evento e, no ultimo, de "Ja conhece o espaco?" para baixo.

## Problema atual

`/venue/:id/form` mostra nome, contato, data, horario, convidados, descricao, conhecimento do espaco, servicos e origem numa unica tela. O preenchimento fica longo antes de qualquer avanco.

## Objetivo da mudanca

No formulario publico, o cliente preenche primeiro os dados pessoais, depois os dados do evento e, no ultimo passo, o que hoje fica de "Ja conhece o espaco?" para baixo.

## Escopo inicial percebido

Reorganizacao visual de dois formularios publicos que ja existem. Sem campo novo, sem contrato e sem schema. A pagina e a marca do espaco permanecem.

## Itens incluidos neste request

- o primeiro passo mostra so as informacoes pessoais
- o segundo passo mostra so as informacoes do evento
- o terceiro passo mostra "Ja conhece o espaco?", servicos, "Onde nos achou?" e o botao de envio
- da para voltar sem perder o que ja foi digitado
- o envio so acontece no ultimo passo
- o formulario por pessoa e o formulario por dia seguem a mesma divisao

## Requisitos implicitos ja visiveis

- informacoes pessoais, no formulario por pessoa: Nome, Nome da Empresa, E-mail e WhatsApp
- informacoes pessoais, no formulario por dia: Nome, E-mail e WhatsApp
- informacoes do evento, no formulario por pessoa: Data do evento, Horario Inicio, Horario Fim, Convidados e Descricao
- informacoes do evento, no formulario por dia: datas e horarios de check-in e check-out, numero de hospedes e Descricao
- o ultimo passo comeca em "Ja conhece o espaco?" e inclui tudo que hoje vem depois, ate o envio
- avancar valida so os campos do passo atual
- e-mail continua opcional, como ja esta no formulario
- logo, cores, aba, rodape e skeleton do espaco nao mudam de papel

## Casos de erro e borda ja percebidos

- campo obrigatorio vazio: o passo nao avanca e o erro aparece no campo
- voltar e avancar de novo: os valores continuam preenchidos
- servico obrigatorio pelo numero de convidados: a regra continua valendo no ultimo passo, depois que o numero de convidados ja foi informado
- espaco com pernoite e espaco sem pernoite: cada um mostra os campos do proprio formulario, na mesma ordem de passos
- envio no ultimo passo com erro da API: o cliente permanece nesse passo, com os dados intactos

## Dependencias

- os dois formularios publicos ja existem em `/venue/:id/form`
- a validacao dos campos ja existe no formulario
- a marca do espaco nesta tela ja foi aplicada na task `marca-espaco-formulario-publico-request.md`

## Restricoes e cuidados

- nao criar campo nem mudar o payload do envio
- nao alterar o formulario de novo orcamento do painel
- nao partir o formulario em tres rotas
- nao limpar o formulario ao voltar de passo
- nao mudar logo, cores, aba, rodape ou skeleton

## Perguntas em aberto

- Qual o titulo do terceiro passo? Premissa: "Como nos encontrou", cobrindo "Ja conhece o espaco?", servicos e "Onde nos achou?".
- O indicador dos passos usa a cor do espaco? Premissa: sim; o passo atual usa a cor do texto do espaco, sem uma paleta nova.
- O formulario do painel tambem vira passo? Premissa: nao; so os formularios publicos de `/venue/:id/form`.
- Da para pular um passo? Premissa: nao; so avanca com os campos daquele passo validos, e so volta para o passo anterior.

## Prioridade sugerida

Media. O formulario publico funciona; a tela e que esta longa demais para preencher de uma vez.

## Faixa sugerida para task workflow

- `A` — dois formularios da mesma tela, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: reordena campos de formularios que ja existem; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `passos-formulario-publico-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar` a entrega (`fw:review`)
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
