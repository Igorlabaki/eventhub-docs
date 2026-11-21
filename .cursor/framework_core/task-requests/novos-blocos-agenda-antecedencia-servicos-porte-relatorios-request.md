# Solicitacao da Tarefa

## Nome sugerido da tarefa

Quatro blocos novos nos relatorios: ocupacao da agenda, antecedencia dos pedidos, aderencia dos servicos adicionais e porte e perfil dos eventos

## Resumo da solicitacao

Em `/venue/:id/reports`, a aba `Orçamentos` ganha o bloco `Antecedência dos pedidos` e a aba `Evento` ganha `Ocupação da agenda`, `Aderência dos serviços adicionais` e `Porte e perfil dos eventos`. Todos usam o espaco e o ano da pagina, sao agregados no backend com permissao checada no servidor e seguem o visual dos cards atuais, sem mexer nos relatorios existentes.

## Context Pack

- frente principal: backend (agregacoes e contrato novo), com frontend para os quatro cards
- superficie sensivel: sim — endpoints novos de leitura por espaco; os atuais (`analysisByMonth`, `trafficCount`) so checam se o espaco existe, sem permissao do usuario
- camadas transversais: `security`, `database`, `design`
- risco principal: misturar fuso nas datas (`startDate`/`endDate` sao wall-clock gravados como UTC; `createdAt` e instante real); contar duas vezes horas sobrepostas ou orcamentos com varias datas; total do bloco nao bater com a populacao da aba
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`), docs (`eventhub-docs/`)
- fora de escopo operacional: schema e migration; cadastro de dias de funcionamento do espaco; seletor de mes no cabecalho da pagina; aba `Financeiro`; mudar KPIs, grafico mensal, origem dos leads ou rosca de categorias; corrigir permissao dos endpoints antigos
- prova minima desta execucao: vitest no backend cobrindo sobreposicao na agenda, evento que cruza a meia-noite, limites 7/8, 30/31 e 90/91 dias, data do evento anterior a criacao, servico legado sem `amount`, orcamento com varias `DateEvent`, `maxGuest` invalido, filtro por espaco e ano e 403 sem `VIEW_VENUE_ANALYSIS`; vitest e `npm run build` no frontend; nas abas, cada bloco mostra carregamento, erro e estado vazio, e a soma das faixas de convidados bate com o total de eventos da aba
- criterio de escalada: ja nasce `spec` (quatro blocos, contrato novo nos dois repos, ordem de entrega backend -> frontend)
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts` em `analysisByMonth` e `trafficCount`; `art56_server_v3/src/functions/report-year-range.ts`; `art56_server_v3/src/use-cases/venue-rule/venue-rule-authorizer.ts`; `eventhub-vista-dashboard/src/components/reports/EventsReport.tsx`; `eventhub-vista-dashboard/src/components/reports/BudgetsReport.tsx`; `eventhub-vista-dashboard/src/components/reports/ReportsChartCard.tsx`
- libs obrigatorias: `node`, `react`, `security`, `database`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/node/index.md`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/database/rules/09_read_models_and_reporting.md`
  - `.cursor/framework_global/framework-libs/design/rules/07_data_display_and_dashboards.md`
  - `docs/planos/horario-wall-clock/01-analise-problema.md#Causa raiz`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` (`Proposal`, `ProposalService`, `Service`, `DateEvent`, `DateEventType`, `Venue`); `art56_server_v3/src/router/venue.ts`; `art56_server_v3/src/use-cases/venue/get-analysis-by-month-venue/`; `art56_server_v3/src/functions/monthly-average-by-years.ts` (`yearStart`); `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts` (`VIEW_VENUE_ANALYSIS`); `eventhub-vista-dashboard/src/store/venueReportsStore.ts`; `eventhub-vista-dashboard/src/services/venue.service.ts`; `eventhub-vista-dashboard/src/types/venue.ts`; `eventhub-vista-dashboard/src/components/reports/report-metrics.ts`; `eventhub-vista-dashboard/src/components/sidebar/sidebar-nav-model.ts`
- palavras-chave ou simbolos de busca: `reportYearRange`, `yearStart`, `analysisByMonth`, `DateEventType`, `proposalServices`, `amount`, `maxGuest`, `openingHour`, `closingHour`, `eventCategory`, `VIEW_VENUE_ANALYSIS`, `getUserVenuePermission`, `ReportsChartCard`, `useVenueReportsStore`
- testes provaveis: funcoes puras de corte na meia-noite, uniao de intervalos por categoria e no total, mapa dia da semana x faixa horaria, dias corridos em data local, faixa de antecedencia, mediana, faixa de convidados, razao de capacidade; use cases com repositorio fake (espaco e ano, aprovados, filtro por tipo de evento); authorizer 401/403/404; cards com carregamento, erro, vazio e "indisponivel"
- nao ler por padrao: `topics/`, specs antigas de relatorios, `observability`, `.env`

## Contexto informado na entrada

Pedido em chat. O usuario detalhou as regras de cada bloco: mapa de calor por dia da semana e faixa horaria com horas ocupadas por eventos, visitas e bloqueios; antecedencia entre `Proposal.createdAt` e `Proposal.startDate` em faixas 0–7, 8–30, 31–90 e >90 dias com mediana e taxa de aprovacao por faixa; ranking de servicos por adesao e soma de `ProposalService.amount` em orcamentos aprovados; distribuicao de convidados em ate 50, 51–100, 101–150 e 151+, por tipo de evento, e proporcao de eventos com 80% ou mais de `Venue.maxGuest`, destacando acima de 100%. Pediu registro no `fw:spec` e contrato coordenado entre backend e frontend.

Leitura previa no codigo:

- a aba `Evento` conta `Proposal` aprovadas com `startDate` no ano (`analysisByMonth`, `reportYearRange`), e nao `DateEvent`
- `DateEventType` tem `VISIT`, `EVENT`, `OTHER`, `BARTER`, `PROPOSAL`, `OVERNIGHT`, `PRODUCTION`; nao existe tipo "bloqueio"
- `Venue` so tem `openingHour` e `closingHour`, sem dias de funcionamento
- a pagina tem apenas seletor de ano; nao ha mes selecionado
- o front exige `VIEW_VENUE_ANALYSIS` para a pagina; o backend dos relatorios nao checa permissao

## Problema atual

Os relatorios mostram volume, receita, origem e categoria, mas nao respondem quando o espaco esta ocupado, com quanta antecedencia os pedidos chegam e se isso afeta a aprovacao, quais servicos adicionais vendem, nem se os eventos usam a capacidade do espaco.

## Objetivo da mudanca

Para o espaco e o ano selecionados, as abas `Orçamentos` e `Evento` exibem os quatro blocos com os numeros calculados no backend pelas regras abaixo, com permissao checada no servidor e testes cobrindo os casos de borda listados.

## Escopo inicial percebido

Quatro leituras agregadas novas no backend, no padrao rota -> controller -> zod -> use case -> repositorio, com as contas em funcoes puras testaveis e um authorizer de relatorio. No frontend, tipos, servico, estado por bloco e quatro cards reaproveitando os componentes de relatorio. Contrato documentado na spec.

## Itens incluidos neste request

- `Ocupação da agenda` (aba `Evento`): mapa de calor dia da semana x faixa horaria com horas ocupadas, separavel por eventos, visitas e bloqueios; total geral pela uniao dos intervalos; dias com registro; rotulo `Ano inteiro` ou mes escolhido dentro do ano ativo
- `Antecedência dos pedidos` (aba `Orçamentos`): orcamentos criados no ano; mediana; faixas 0–7, 8–30, 31–90, >90 com total, aprovados e taxa; quantidade excluida por data do evento anterior a criacao; filtro por tipo de evento
- `Aderência dos serviços adicionais` (aba `Evento`): aprovados com evento no ano; por servico, orcamentos distintos, % de adesao, soma de `amount` rotulada como valor em orcamentos aprovados e cobertura `valor registrado em X de Y linhas`; filtro por tipo de evento
- `Porte e perfil dos eventos` (aba `Evento`): mesma populacao da aba, um orcamento por evento; faixas de convidados; distribuicao por tipo de evento; % com 80% ou mais de `maxGuest` e, separado, quantos acima de 100%
- authorizer checando `VIEW_VENUE_ANALYSIS` nos endpoints novos
- carregamento, erro e vazio por bloco
- contrato da API registrado na spec

## Requisitos implicitos ja visiveis

- horario das `DateEvent` lido pelos componentes UTC (wall-clock); `createdAt` convertido para `America/Sao_Paulo` antes de pegar a data local
- intervalo que cruza a meia-noite dividido entre os dias; sobreposicao contada uma vez por categoria; total geral pela uniao entre categorias
- percentual de ocupacao so quando a disponibilidade puder ser definida; hoje nao pode, entao exibir horas ocupadas e dias com registro
- recorte mensal limitado ao ano ativo
- adesao = aprovados que incluem o servico / aprovados no recorte; mesmo servico repetido na proposta conta uma vez
- linhas sem `amount` contam na adesao e ficam fora da soma; todas sem valor -> `sem valor registrado`
- valores historicos da proposta, nunca `Service.price` atual
- taxa por faixa com zero orcamentos -> indisponivel, nao 0%
- `maxGuest` menor ou igual a zero ou ausente -> indicador de capacidade indisponivel, distribuicao mantida
- payload so com agregados; nada de lista de propostas ou dados de cliente
- reaproveitar estilo e componentes de `ReportsChartCard`; `recharts` ja e dependencia
- estado de carregamento e erro por bloco, sem usar o `isLoading` unico do `venueReportsStore`

## Casos de erro e borda ja percebidos

- duas `DateEvent` sobrepostas da mesma categoria; sobreposicao entre categorias diferentes no total geral
- evento 22:00–02:00 e evento de varios dias
- `endDate` menor ou igual a `startDate`: descartar o registro
- `DateEvent` que comeca em 31/12 e termina no ano seguinte: cortar no limite do ano
- antecedencia de exatamente 7, 8, 30, 31, 90 e 91 dias; mesmo dia (0); evento antes da criacao
- orcamento criado em dezembro com evento no ano seguinte (entra pela criacao)
- servico legado sem `amount`, com `amount` 0 e repetido na mesma proposta
- orcamento aprovado com varias `DateEvent`
- `guestNumber` 0 ou exatamente nos limites 50/51, 100/101, 150/151
- `eventCategory` nulo (anterior a 09/11/2026 ou tipo diferente de `EVENT`)
- espaco de outra organizacao ou usuario sem permissao: 403; espaco inexistente: 404
- ano sem dados: estado vazio em cada bloco

## Dependencias

- `eventCategory` ja no `main` (spec `2026-11-09-categoria-do-evento-na-proposta`), usada nos filtros por tipo de evento
- `reportYearRange` ja corrigido para `[1/1 do ano, 1/1 do ano seguinte)`

## Restricoes e cuidados

- nao criar coluna nem migration; usar o schema atual
- nao mudar campos nem significado de `analysisByMonth` e `trafficCount`
- nao ler nem versionar `.env`; nao escrever no banco de producao
- consultas com `select` minimo e filtro por `venueId` e ano no banco, sem carregar o ano todo de todos os espacos

## Perguntas em aberto

- Como agrupar `DateEventType` no mapa de calor? Premissa: eventos = `EVENT`, `OVERNIGHT`, `PRODUCTION`, `BARTER`; visitas = `VISIT`; bloqueios = `OTHER`; `PROPOSAL` (reserva provisoria) fica fora.
- Quais faixas horarias? Premissa: blocos de 2 horas (00–02 ... 22–24).
- `Tipo de evento` no filtro e `eventCategory` ou `Proposal.type`? Premissa: `eventCategory`, com opcao `Sem categoria`, igual a rosca dos relatorios.
- Ocupacao usa todas as `DateEvent` do espaco ou so as ligadas a orcamentos aprovados? Premissa: todas do espaco no periodo, filtradas pelo tipo, porque bloqueios e visitas nao tem orcamento aprovado.
- Recorte mensal da ocupacao? Premissa: seletor local no card com `Ano inteiro` como padrao, sem seletor de mes na pagina.
- Qual permissao exigir? Premissa: `VIEW_VENUE_ANALYSIS`, a mesma que libera a pagina no front.

## Prioridade sugerida

Media. Leitura de negocio nova, sem bloqueio para outras entregas.

## Faixa sugerida para task workflow

- `C` — quatro blocos, contrato novo nos dois repos, regras de calculo proprias e superficie de permissao
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: se quebra naturalmente em tasks (authorizer e funcoes puras; quatro endpoints; contrato; quatro cards), com ordem backend -> frontend e contrato a coordenar

## Sugestao de slug da spec

- `framework_core/specs/2026-11-10-novos-blocos-relatorios/`

## Sugestao de nome do arquivo

- `novos-blocos-agenda-antecedencia-servicos-porte-relatorios-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `spec`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-10-novos-blocos-relatorios/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: depois da spec, as tasks podem ser divididas com `tasking/task-request-repo-split-prompt.md` em backend (authorizer, funcoes, endpoints) e frontend (cards)
