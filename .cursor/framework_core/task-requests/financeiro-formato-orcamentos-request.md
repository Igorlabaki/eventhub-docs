# Solicitacao da Tarefa

## Nome sugerido da tarefa

Financeiro no formato de orcamentos e evento

## Resumo da solicitacao

A aba Financeiro dos relatorios do espaco passa a mostrar receita bruta, despesas totais, receita liquida e margem liquida no mesmo desenho das abas Orcamentos e Evento. Os numeros e os blocos de despesa vem da referencia; o layout segue o padrao que essas duas abas ja usam.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: copiar os valores do print como dado fixo, ou inventar o mes de uma despesa esporadica que a analise nao guarda
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: abas Orcamentos e Evento, cadastro de despesa, API, schema e a tela de despesas do espaco
- prova minima desta execucao: em `/venue/:id/reports`, aba Financeiro, ver os quatro cards com variacao contra o ano anterior, o grafico mensal de receita e despesa, a composicao em barras e os destaques; trocar o ano e os numeros acompanharem; Orcamentos e Evento iguais ao que estao
- criterio de escalada: permanece `normal`; sobe para `spec` se posicionar a despesa esporadica num mes exigir contrato novo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenueReports.tsx` no bloco da aba Financeiro
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/reports/FinancialBalanceReport.tsx`; `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx`; `eventhub-vista-dashboard/src/components/reports/BudgetsReport.tsx`; `eventhub-vista-dashboard/src/components/reports/EventsReport.tsx`
- palavras-chave ou simbolos de busca: `FinancialBalanceReport`, `ReportsChartCard`, `expenseAnalysis`, `receitaBruta`, `analysisEventsByMonth`
- testes provaveis: quatro indicadores com os totais que a aba ja calcula; margem sem divisao por zero; composicao com o percentual de cada despesa recorrente; ano anterior vazio sem percentual inventado
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com dois prints. O primeiro traz as ideias: quatro indicadores, receita contra despesa no ano, composicao das despesas e os blocos recorrente anual, mensal e esporadico. O segundo e a aba Financeiro atual, em barras horizontais, com os mesmos totais no rodape. O layout deve seguir o padrao ja entregue em Orcamentos e Evento.

## Problema atual

A aba Financeiro concentra receita, despesa anual e receita liquida num cartao unico de barras. Nao mostra margem, variacao contra o ano anterior, grafico mensal nem a composicao no desenho das outras abas.

## Objetivo da mudanca

Quem abre a aba Financeiro ve os numeros da referencia no mesmo formato de Orcamentos e Evento.

## Escopo inicial percebido

Rearranjo visual de uma aba, com contas em cima da analise de despesas e da receita de eventos aprovados que a tela ja carrega. Sem rota, contrato ou schema novo.

## Itens incluidos neste request

Quatro cards: receita bruta, despesas totais, receita liquida e margem liquida, cada um com variacao contra o ano anterior e o tracinho dos meses. Grafico mensal de receita e despesa, no mesmo grafico das outras abas, com troca entre valores e margem. Abaixo, composicao das despesas em barras e os destaques do ano, no lugar dos blocos de origem e insights. A despesa recorrente entra em cada mes. A esporadica permanece no total do ano.

## Requisitos implicitos ja visiveis

- os numeros continuam os que a aba ja calcula; o print nao e valor fixo
- receita bruta e o total dos eventos aprovados do ano
- despesas totais somam o recorrente anual e o esporadico
- receita liquida e receita bruta menos despesas totais
- margem liquida e receita liquida sobre a receita bruta
- a variacao anual usa o mesmo relatorio no ano anterior
- Orcamentos e Evento nao mudam de desenho

## Casos de erro e borda ja percebidos

- ano anterior sem dado: a variacao nao inventa percentual
- receita bruta zero: a margem nao divide por zero
- nenhuma despesa cadastrada: a composicao fica vazia e os totais ficam em zero
- nenhuma despesa esporadica: o destaque mostra zero
- tela estreita: cards e as duas colunas de baixo quebram a linha
- troca de ano: cards, grafico, composicao e destaques acompanham o ano escolhido

## Dependencias

- a aba ja carrega a analise de despesas e a receita dos eventos aprovados
- Orcamentos e Evento ja entregam o desenho de cards, grafico, barras e destaques

## Restricoes e cuidados

- nao alterar as abas Orcamentos e Evento
- nao criar endpoint nem coluna para a serie mensal da despesa esporadica
- nao copiar os numeros nem os percentuais do print como dado fixo
- nao levar o botao de cadastrar despesa para o relatorio
- nao redesenhar a tela de despesas do espaco

## Perguntas em aberto

- A composicao usa barras, como a origem dos leads, ou o anel da referencia? Premissa: barras, no desenho ja usado em Orcamentos e Evento.
- Os tres blocos da referencia (anual, mensal e esporadico) viram tabelas? Premissa: nao; os numeros entram na composicao e nos destaques.
- A despesa esporadica entra num mes do grafico? Premissa: nao; fica no total do ano. Se o produto exigir o mes, promover para spec.
- A variacao pode usar o relatorio do ano anterior? Premissa: sim; se faltar contrato, escalar para spec em vez de inventar a conta.

## Prioridade sugerida

Media. O relatorio financeiro funciona; a diferenca e o formato da leitura.

## Faixa sugerida para task workflow

- `B` — uma aba, no desenho que Orcamentos e Evento ja usam, com contas em cima dos dados que a tela ja carrega
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so o frontend, sem contrato novo. Vira spec se a despesa esporadica precisar de mes proprio ou se a variacao anual exigir endpoint ou schema.

## Sugestao de slug da spec

- `framework_core/specs/financeiro-formato-orcamentos/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `financeiro-formato-orcamentos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: aba Financeiro com os quatro cards, grafico mensal, composicao em barras e destaques; Orcamentos e Evento intactos; vitest 6 em `finance-metrics.test.ts` e `FinancialReportCard.test.tsx`; browser parado no login
- derivacao repo-local: `nao se aplica`
