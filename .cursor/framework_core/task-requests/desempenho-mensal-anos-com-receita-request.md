# Solicitacao da Tarefa

## Nome sugerido da tarefa

Desempenho mensal so nos anos com receita

## Resumo da solicitacao

O grafico Desempenho Mensal da visao geral passa a mostrar somente os anos em que o espaco teve receita em algum mes. Em cada um desses anos, a barra mostra a receita do mes selecionado, mesmo que seja zero.

## Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: tirar do grafico um ano com receita so porque o mes selecionado ficou em zero, ou mudar o significado de `proposalYears` no contrato
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo operacional: Desempenho Anual, desenho do grafico, cards de KPI, proximo evento, proxima visita, seletor de mes e ano, correcao de datas no banco
- prova minima desta execucao: em `/venue/:id`, com um mes selecionado, o eixo do Desempenho Mensal lista so os anos com receita do espaco; um ano com receita em outros meses e zero no mes escolhido aparece com a barra em zero; anos que so tem proposta sem receita (como 6, 1996, 2030 no print do AR756) somem
- criterio de escalada: `spec` se a regra dos anos precisar mudar o contrato da visao geral ou o seletor de ano
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts` em `getVenueAnalytics`, no bloco de `proposalYears` e `sameMonthRevenueByYear`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/node/index.md`
- caminhos candidatos: `art56_server_v3/src/functions/same-month-revenue-by-year.ts`; `art56_server_v3/src/functions/proposal-years.ts`; `art56_server_v3/src/repositories/interface/venue-repository-interface.ts`; `eventhub-vista-dashboard/src/components/venue/VenuePerformanceSeries.tsx` so para leitura
- palavras-chave ou simbolos de busca: `uniqueProposalYears`, `proposalYears`, `sameMonthRevenueByYear`, `sameMonthEventWhere`, `wallClockYear`
- testes provaveis: ano com receita no mes escolhido; ano com receita so em outro mes entra em zero; ano so com proposta sem receita fica de fora; espaco sem nenhuma receita devolve lista vazia; ano decidido pelo wall-clock da data do evento
- nao ler por padrao: `security`, `topics/`, schema e migration

## Contexto informado na entrada

Pedido em chat sobre o print da visao geral do AR756: o Desempenho Mensal mostra no eixo os anos 6, 1996, 1998, 2001, 2002, 2004, 2008, 2017, 2024, 2025, 2026, 2027, 2028 e 2030, quase todos em zero. O grafico deve mostrar os anos que tiveram receita. Se julho fez zero num desses anos, o ano continua contando, com a barra em zero.

## Problema atual

Os anos do grafico saem de `uniqueProposalYears` sobre o `startDate` de todas as propostas do espaco, com ou sem receita. Qualquer proposta com data digitada errada cria um ano no eixo. Hoje `sameMonthRevenueByYear` devolve um ponto para cada um desses anos.

## Objetivo da mudanca

Quem abre o Desempenho Mensal ve so os anos em que o espaco faturou, e consegue comparar o mes escolhido entre eles, inclusive quando o mes ficou em zero.

## Escopo inicial percebido

Trocar a fonte dos anos da serie do mesmo mes: em vez das propostas, os eventos com receita do espaco, com a mesma conta de receita que o grafico ja usa. O formato de `sameMonthRevenueByYear` no contrato fica igual. O front nao muda.

## Itens incluidos neste request

Uma lista de anos com receita do espaco, tirada dos eventos `type: "EVENT"` cuja proposta tem `totalAmount` maior que zero, com o ano pelo wall-clock da data do evento. Essa lista alimenta `sameMonthEventWhere` e `sameMonthRevenueByYear`. Ano da lista sem receita no mes selecionado entra com `revenue: 0`.

## Requisitos implicitos ja visiveis

- receita de um ano e a soma dos eventos do ano, a mesma conta que `sameMonthRevenueByYear` ja faz por mes
- o mes continua o selecionado na visao geral; a tela abre no mes corrente
- `proposalYears` continua no contrato com o mesmo significado; a nova lista e separada
- os anos ficam em ordem crescente, sem repetir
- Desempenho Anual nao muda

## Casos de erro e borda ja percebidos

- ano com receita so em outros meses: entra com a barra em zero e o rotulo some
- proposta com data errada e sem receita: o ano nao aparece
- proposta com data errada e com receita (ex.: ano 0006 com valor): o ano continua aparecendo; isso pede correcao do dado, fora deste request
- espaco sem nenhuma receita: lista vazia, o grafico nao inventa coluna
- `month=all`: a serie continua `null`, como hoje
- evento perto da virada do ano: o ano segue o wall-clock, sem converter fuso

## Dependencias

- `sameMonthRevenueByYear` e `sameMonthEventWhere` ja montam a serie a partir de uma lista de anos
- `wallClockYear` ja da o ano sem fuso
- o front ja desenha o que vier em `sameMonthRevenueByYear`

## Restricoes e cuidados

- preservar wall-clock
- nao alterar o tipo de `sameMonthRevenueByYear` nem remover `proposalYears`
- nao criar coluna nem migration
- nao corrigir dados no banco de producao por este request; escrita no banco exige aprovacao nomeada
- nao copiar anos do print como dado fixo

## Perguntas em aberto

- Ano com receita e o ano com algum evento de proposta com valor maior que zero, em qualquer mes? Premissa: sim.
- O ano atual entra mesmo sem receita ainda? Premissa: nao; entra quando houver receita.
- Anos com data claramente errada e com receita devem ser cortados por faixa (ex.: 2020 ate o ano atual + 2)? Premissa: nao neste request; levantar as propostas com data fora da faixa e corrigir o dado.

## Prioridade sugerida

Media. O grafico funciona, mas o eixo poluido esconde a comparacao entre os anos reais.

## Faixa sugerida para task workflow

- `A` — so a fonte dos anos muda, no backend, sem mudar o contrato
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, um repositorio, o formato da resposta nao muda

## Sugestao de slug da spec

- `framework_core/specs/desempenho-mensal-anos-com-receita/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `desempenho-mensal-anos-com-receita-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- entrega: `revenueEventWhere` e `revenueYears` em `same-month-revenue-by-year.ts`; `getVenueAnalytics` monta a serie do mesmo mes com os anos de receita; `proposalYears` e o formato da resposta iguais; vitest 13 nos dois arquivos e 277 na suite; `tsc` sem erro nos arquivos tocados; browser parado no login
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
