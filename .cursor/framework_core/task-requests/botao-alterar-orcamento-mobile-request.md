# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mover Alterar orcamento para baixo do WhatsApp no celular

## Resumo da solicitacao

Na pagina publica do orcamento, o botao "Alterar orçamento" deixa o topo do card no celular e passa a ficar abaixo de "Conversar com nossa equipe". Em telas maiores ele continua ao lado do titulo "Seu investimento".

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o botao sumir no celular ou abrir o dialogo de recalculo em so um dos dois lugares
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: calculo, dialogo de recalculo, copia do card, API e o botao de desktop
- prova minima desta execucao: no celular, "Alterar orçamento" aparece abaixo de "Conversar com nossa equipe" e abre o mesmo dialogo; a partir de `sm`, o botao volta ao canto do titulo e a copia de baixo some
- criterio de escalada: promover para `normal` se a mudanca exigir contrato ou outra tela; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no card "Seu investimento"
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: card "Seu investimento" em `ProposalView`
- palavras-chave ou simbolos de busca: `Alterar orçamento`, `Conversar com nossa equipe`, `setRecalculateOpen`
- testes provaveis: abrir `/proposal/:id/view` em viewport de celular e em viewport larga
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com print do celular: o botao "Alterar orçamento" deve ficar abaixo do botao "Conversar com nossa equipe".

## Problema atual

No celular o botao fica no topo do card, a direita do titulo "Seu investimento", acima da lista de valores e do WhatsApp.

## Objetivo da mudanca

No celular, "Alterar orçamento" fica imediatamente abaixo de "Conversar com nossa equipe". Em telas a partir de `sm`, permanece no topo do card.

## Escopo inicial percebido

Reordenar o mesmo botao na pagina publica que ja abre `RecalculateProposalDialog`.

## Itens incluidos neste request

- esconder o botao do titulo em viewport menor que `sm`
- mostrar o mesmo botao, centralizado, abaixo do WhatsApp somente nessa viewport
- os dois disparam `setRecalculateOpen(true)`

## Requisitos implicitos ja visiveis

- o dialogo de recalculo nao muda
- a nota de e-mail continua depois das acoes
- sem WhatsApp, o botao de alterar ainda aparece no fim do card no celular

## Casos de erro e borda ja percebidos

- os dois botoes nao podem aparecer juntos
- o botao de baixo nao pode ficar visivel no desktop
- orcamento sem WhatsApp ainda precisa do botao de alterar

## Dependencias

- o card "Seu investimento" e o dialogo de recalculo ja existem na pagina publica

## Restricoes e cuidados

- nao mudar calculo, contrato nem o conteudo do dialogo
- nao mover o botao no desktop

## Perguntas em aberto

- O botao de baixo fica antes ou depois da nota de e-mail? Premissa: logo abaixo do WhatsApp, antes da nota.
- Qual corte e "celular"? Premissa: abaixo do breakpoint `sm` (640px), o mesmo corte ja usado nesta pagina.

## Prioridade sugerida

Media. O botao no topo compete com o titulo no celular.

## Faixa sugerida para task workflow

- `A` — uma tela, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: reordena um botao que a pagina publica ja tem

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `botao-alterar-orcamento-mobile-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
