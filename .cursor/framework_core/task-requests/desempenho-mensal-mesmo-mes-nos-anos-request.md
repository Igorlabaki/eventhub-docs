# Solicitacao da Tarefa

## Nome sugerido da tarefa

Desempenho mensal do mesmo mes em todos os anos

## Resumo da solicitacao

O grafico Desempenho Mensal da visao geral passa a mostrar o mes selecionado em cada ano em que o espaco tem registro, no grafico de tendencia dos relatorios: uma barra de receita por ano e a linha de tendencia sobre a mesma serie.

## Context Pack

- frente principal: frontend e backend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: montar a serie so com o ano que ja esta na tela, ou trocar a receita de evento por outro total
- repos tocados: `frontend` (`eventhub-vista-dashboard/`) e `backend` (`art56_server_v3/`)
- fora de escopo operacional: Desempenho Anual, abas de relatorio, cards de KPI, proximo evento, proxima visita, seletor de mes e ano, cadastro de meta
- prova minima desta execucao: em `/venue/:id`, com um mes selecionado, uma barra por ano com registro e a linha de tendencia da receita desse mes; ano sem evento nesse mes em zero; Desempenho Anual e os relatorios iguais ao que estao
- criterio de escalada: ja e `spec`; a serie do mesmo mes em varios anos nao vem no contrato atual da visao geral
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueDashboard.tsx` no bloco Desempenho Mensal
- libs obrigatorias: `react`, `design`, `node`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/node/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenuePerformanceSeries.tsx`; `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx`; `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts`; `eventhub-vista-dashboard/src/types/venue.ts`
- palavras-chave ou simbolos de busca: `Desempenho Mensal`, `monthlyRevenue`, `proposalYears`, `Tendência`
- testes provaveis: dois anos com receita no mesmo mes; ano com registro e sem evento nesse mes em zero; espaco com um unico ano; mes sem nenhum evento
- nao ler por padrao: `security`, `topics/`, schema e migration

## Contexto informado na entrada

Pedido em chat, depois do desenho dos graficos da visao geral. No Desempenho Mensal, o mes selecionado deve aparecer em todos os anos em que o espaco tem registro. O grafico deve ser o de tendencia dos relatorios.

## Problema atual

Desempenho Mensal mostra um unico ponto: a receita do mes no ano filtrado, com a meta na linha. A visao geral nao devolve a receita desse mes nos outros anos.

## Objetivo da mudanca

Quem abre o Desempenho Mensal ve a receita do mes escolhido em cada ano com registro, com barra e linha de tendencia.

## Escopo inicial percebido

Serie nova no contrato da visao geral e troca do grafico mensal. O anual permanece os doze meses do ano escolhido. Sem schema novo.

## Itens incluidos neste request

No mes selecionado, uma barra por ano com registro do espaco. A linha de tendencia acompanha a receita dessas barras, no desenho de Orcamentos e Evento. Ano com registro e sem receita nesse mes entra zerado. O rotulo e o tooltip seguem o grafico de tendencia ja usado nos relatorios.

## Requisitos implicitos ja visiveis

- o mes e o que esta selecionado na visao geral; a tela abre no mes corrente
- os anos sao os que o espaco ja reconhece como anos com registro
- a receita continua a dos eventos, a mesma conta que o grafico ja usa
- a meta sai desse grafico; a linha passa a ser a tendencia da receita
- Desempenho Anual nao muda de serie

## Casos de erro e borda ja percebidos

- espaco com um unico ano: uma barra e um ponto de tendencia
- ano sem evento no mes: a barra fica em zero e o rotulo some
- nenhum ano com registro: o grafico nao inventa coluna
- troca de mes: a serie acompanha o mes escolhido
- tela estreita: o grafico continua oculto abaixo de `lg`, como hoje

## Dependencias

- a visao geral ja lista os anos com registro do espaco
- a receita do mes no ano filtrado ja e calculada para o grafico atual
- Orcamentos e Evento ja entregam o desenho de barra com linha de tendencia

## Restricoes e cuidados

- nao alterar Desempenho Anual nem as abas de relatorio
- nao mudar cards, proximo evento, proxima visita nem o seletor
- nao criar coluna nem migration
- nao copiar valores de print como dado fixo
- a execucao multi-repo pode ser derivada depois com `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Os anos sao os do seletor, vindos dos orcamentos do espaco? Premissa: sim; ano sem receita no mes fica zero.
- A receita continua a dos eventos com valor, como no grafico atual? Premissa: sim.
- A linha e a tendencia da receita, e a meta sai do mensal? Premissa: sim.
- O anual continua os doze meses do ano escolhido? Premissa: sim.

## Prioridade sugerida

Media. A visao geral ja mostra a receita do mes; a diferenca e comparar esse mes entre os anos.

## Faixa sugerida para task workflow

- `C` — a serie do mesmo mes em varios anos nao existe no contrato; a mudanca toca frontend e backend
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: um objetivo, mas a serie nova cruza os dois repositorios e o contrato da visao geral. Nao cabe executar direto no tasking.

## Sugestao de slug da spec

- `framework_core/specs/desempenho-mensal-mesmo-mes-nos-anos/`

## Sugestao de nome do arquivo

- `desempenho-mensal-mesmo-mes-nos-anos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-desempenho-mensal-mesmo-mes-nos-anos/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
