# Solicitacao da Tarefa

## Nome sugerido da tarefa

Animar os toggles dos relatorios

## Resumo da solicitacao

Os toggles de serie do grafico e as abas Orcamentos, Evento e Financeiro passam a mover o indicador selecionado, em vez de trocar a cor no mesmo lugar. A serie e o painel da aba entram com um fade curto.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: o indicador deslizar para a posicao errada ou a animacao ignorar `prefers-reduced-motion`
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: outros toggles do painel, dados dos relatorios, API e o seletor de ano
- prova minima desta execucao: em `/venue/:id/reports`, a pilula de Orçamentos/Taxa de conversão, Eventos/Taxa de conversão e Valores/Margem desliza; o sublinhado de ORÇAMENTOS, EVENTO e FINANCEIRO desliza; o grafico e o painel entram em fade; com reduced motion o indicador muda sem transicao
- criterio de escalada: permanece `smart`; sobe para `spec` se a animacao tiver que virar token global do design system
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx` no bloco do toggle de serie
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_global/framework-libs/design/rules/08_motion_and_microinteractions.md`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
  - `.cursor/framework_global/framework-libs/react/rules/05_ui_design_and_accessibility.md`
- caminhos candidatos: `ReportsHeader.tsx`, `FinancialReportCard.tsx`, `VenueReports.tsx`
- palavras-chave ou simbolos de busca: `Taxa de conversão`, `SeriesToggle`, `TabsTrigger`, `Valores`
- testes provaveis: markup da pilula com transform e `motion-reduce`; sublinhado na base da aba; labels Orçamentos, Taxa de conversão, Valores e Margem continuam na tela
- nao ler por padrao: `security`, `database`, `topics/`, backend

## Contexto informado na entrada

Pedido em chat, com quatro prints da tela de relatorios: pilula Orçamentos / Taxa de conversão, abas ORÇAMENTOS / EVENTO / FINANCEIRO, pilula Eventos / Taxa de conversão e pilula Valores / Margem. O pedido e que todos esses toggles tenham animacao.

## Problema atual

A opcao ativa troca de cor no lugar. O sublinhado da aba tambem aparece direto na nova aba. Nada comunica que a selecao se moveu.

## Objetivo da mudanca

Ao trocar qualquer um desses toggles, o indicador desliza ate a opcao escolhida e o conteudo associado entra com um fade curto.

## Escopo inicial percebido

Frontend dos relatorios do espaco. Tres pilulas de serie e o grupo de abas do cabecalho.

## Itens incluidos neste request

- pilula deslizante em Orçamentos, Eventos e Financeiro
- sublinhado deslizante nas abas ORÇAMENTOS, EVENTO e FINANCEIRO
- fade curto do grafico e do painel da aba
- `prefers-reduced-motion` sem o movimento

## Requisitos implicitos ja visiveis

- manter os rotulos e o que cada toggle mostra
- foco visivel no teclado
- animar so transform, largura e altura do indicador pequeno
- setas do teclado trocam a serie da pilula

## Casos de erro e borda ja percebidos

- primeira pintura sem medir o botao ainda: o indicador so aparece depois da medida, para nao sair do zero
- troca de largura da janela: medir de novo
- reduced motion: troca imediata de posicao e sem fade

## Dependencias

Nenhuma.

## Restricoes e cuidados

Nao alterar numeros, series nem o seletor de ano. Nao animar a pagina inteira.

## Perguntas em aberto

- A animacao vale para outros toggles do painel? Premissa: nao. So os quatro controles dos prints.

## Prioridade sugerida

Media. Ajuste visual da tela que o time acabou de alinhar com a referencia.

## Faixa sugerida para task workflow

- `A` — ajuste local de componente, uma frente, baixo risco

## Candidato a spec

- `nao`
- motivo: um comportamento visual em componentes que ja existem, sem contrato novo

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `animacao-toggles-relatorios-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
