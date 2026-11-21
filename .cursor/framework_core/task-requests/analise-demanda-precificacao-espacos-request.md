# Solicitacao da Tarefa

## Nome sugerido da tarefa

Analisar demanda e recomendar preços para espaços de eventos.

## Resumo da solicitacao

Investigar quais dados o EventHub já registra e propor um método explicável para recomendar quando subir, baixar ou manter preços, ou indicar que faltam dados.

## Context Pack

- frente principal: diagnóstico de dados, regras de cobrança e indicadores de demanda.
- superficie sensivel: sim, financeira. Examinar a definição de pagamentos e receita nas fontes do repositório e usar exemplos fictícios.
- risco principal: confundir indisponibilidade, diferenças de antecedência ou falta de histórico com demanda baixa.
- repos tocados: `backend` e `frontend` para leitura, com apoio de `eventhub-docs`.
- fora de escopo operacional: implementação, coleta nova, mudança de preço, edição de arquivos, banco ou configuração.
- prova minima desta execucao: relatório na conversa com inventário rastreável a arquivo e símbolo, matriz de indicadores, pseudocódigo e exemplos numéricos fictícios por modalidade confirmada.
- criterio de escalada: promover a implementação futura a spec se houver nova capacidade de produto, persistência, contrato entre repos ou mudança nas regras de preço.
- nivel de autonomia: `L1`.

## Minimal Read Set

- ler primeiro: `project/backend-map.md#estrutura` e `topics/data-and-migrations.md#mapa`.
- libs obrigatorias: `database` para interpretar schema e migrations (começar por `framework_global/framework-libs/database/index.md`).
- documentos obrigatorios: `topics/pricing-and-proposal-calculation.md#pipeline-atual-proposal-amountsts`, `topics/reports-and-kpis.md#relatorios-venueidreports` e `project/project-decisions.md#d-06-datas-de-evento-com-semantica-wall-clock`.
- caminhos candidatos: schema e migrations do Prisma, modelos, consultas, serviços e testes de preços, agenda, orçamento, reserva, pagamento e cancelamento no backend, além dos relatórios no frontend.
- palavras-chave: disponibilidade, bloqueio, status da proposta, preço oferecido, preço contratado, convidados, duração, pagamento, receita e cancelamento.
- testes provaveis: ler os testes existentes de cálculo, agenda e relatórios para conferir as regras identificadas.
- nao ler por padrao: specs, credenciais, dados pessoais e registros de pagamento individuais.

## Contexto informado na entrada

O gestor quer entender padrões de procura por espaço e período e usar essa evidência para decidir o preço. A análise deve verificar no código quais modalidades de cobrança existem e se os dados necessários são preservados.

## Problema atual

A cobertura histórica dos preços, das consultas e da disponibilidade precisa ser confirmada antes de propor métricas e recomendações.

## Objetivo da mudanca

Entregar um diagnóstico somente leitura que demonstre, com referências ao código, quais recomendações de preço são viáveis em cada modalidade e quais evidências faltam para as demais.

## Escopo inicial percebido

Diagnóstico único, da origem dos dados à interpretação da recomendação pelo gestor.

## Itens incluidos neste request

1. Inventariar o schema completo e confirmar no código os campos, relações, estados e regras atuais. Registrar fonte, significado, granularidade, cobertura histórica conhecida e relevância para preços. Classificar os dados como existentes, deriváveis, coletados sem histórico ou ausentes, indicar cobertura indeterminada quando necessário e justificar itens sem utilidade.
2. Rastrear disponibilidade, consulta, orçamento, confirmação, pagamento, cancelamento e realização. Cobrir perfil do espaço, datas e motivos de perda, convidados, duração, diárias, preços anunciados, ofertados e contratados, descontos, taxas, adicionais, mínimos, pacotes e receita efetiva. Verificar se o preço ofertado sobrevive sem conversão ou após alteração da tabela. Distinguir os recortes temporais disponíveis no sistema dos que exigem fonte externa.
3. Entregar matriz indicador → dados, regra, denominador e limitação. Confirmar as modalidades e as regras de cálculo. Quando aplicável, usar R$/pessoa e distinguir uso da capacidade de ocupação do calendário, usar R$/hora e R$/dia com disponibilidade efetiva, e decompor cobranças combinadas em parcelas, identificando qual muda e estimando o total.
4. Propor algoritmo explicável com pseudocódigo, comparações equivalentes por sazonalidade e antecedência, peso por recência e alternativa para amostras pequenas com períodos ou espaços comparáveis, quando justificável. Explicitar critérios para as quatro saídas, como tratar sinais conflitantes e como distinguir associação de causa. Condicionar a evolução para receita esperada por preço à existência de ofertas com e sem conversão, considerando chance de fechar, quantidade faturável e preço total. Separar estimativas históricas de resultados de testes de preço e prever validação temporal com informação disponível na data da recomendação.
5. Propor visão por dia da semana para cobrança por pessoa ou diária e adicionar faixa horária conforme a modalidade de cobrança por tempo. Incluir espaço, período, modalidade e unidade, preço atual e sugerido, variação, ação, justificativa numérica, janela de análise, amostra, comparador, confiança, lacunas, piso, teto e limite de ajuste quando aplicáveis. Exemplificar subir, baixar e manter com valores fictícios, cobrindo as modalidades confirmadas.
6. Fechar com três listas priorizadas. Separar o que já pode ser calculado, o que pode ser estimado com ressalvas e o que depende de coletar ou preservar dados. Para cada lacuna, identificar a decisão afetada e a informação que mais ajudaria.

## Requisitos implicitos ja visiveis

Calcular ocupação e conversão somente com denominadores verificáveis. Justificar comparabilidade por atributos observáveis, como localização, capacidade e perfil de evento. Tratar feriados e datas especiais conforme a origem dos dados.

## Casos de erro e borda ja percebidos

Sobreposição, bloqueios, cancelamentos e reabertura da agenda, eventos de várias horas ou dias, bloqueio exclusivo do espaço, preços antigos sobrescritos, consultas sem desfecho, datas futuras com antecedências diferentes e amostras pequenas. Baixa ocupação com muitas consultas exige verificar disponibilidade, adequação do espaço e perda antes de sugerir alteração.

## Dependencias

Acesso de leitura ao repositório. A cobertura histórica efetiva depende da evidência disponível durante o diagnóstico.

## Restricoes e cuidados

Executar somente leitura. Entregar na conversa. Preservar a semântica local dos horários e anonimizar qualquer evidência sensível.

Flags transversais: `security` pela leitura de fluxos financeiros, `database` pelo schema e histórico e `design` pela proposta conceitual do relatório. `observability` e `patterns` ficam fora do diagnóstico.

## Perguntas em aberto

- Qual janela e quais espaços são representativos? Por padrão, propor critérios com base na cobertura confirmada e explicitar as limitações.
- O histórico permite medir procura e conversão? Por padrão, trabalhar com evidência do repositório e marcar o que não for verificável.
- Existem pisos, tetos e limites comerciais? Por padrão, identificar regras comprovadas e rotular valores de exemplo como fictícios.

## Prioridade sugerida

Média, como insumo para decidir a implementação futura.

## Decisões registradas após a criação

- **Atualização automática diária.** Usar Vercel Cron no projeto de backend `art56-server-v3`. A configuração candidata é `0 6 * * *` em UTC. O plano Hobby executa na janela das 3h às 3h59 em São Paulo. A execução independe de alguém abrir o dashboard. Consultas, orçamentos, confirmações, cancelamentos e bloqueios entram conforme a evidência gravada até o corte de cada execução. Recálculo imediato por evento fica como evolução se houver necessidade de atualização intradiária.
- **Responsabilidade de cada camada.** A Vercel chama uma rota Express protegida por `CRON_SECRET`. O backend lê dados agregados e grava recomendações no PlanetScale. O dashboard consulta o último resultado válido por espaço e faixa e mostra quando foi calculado, a janela de dados e a justificativa. O gestor decide se aplica o preço.
- **Regra inicial explicável.** Usar `preço sugerido = preço atual × (1 + ajuste)`, com `ajuste = limitar(fator × (ocupação observada − ocupação de referência), −limite, +limite)`. Ocupações entram como frações entre 0 e 1. Fator de 0,5 e limite de 10% são parâmetros ilustrativos a calibrar. Com preço de R$ 200 na unidade aplicável e referência de 60%, ocupações de 80%, 60% e 40% dão R$ 220, R$ 200 e R$ 180, respectivamente, antes de pisos, tetos e regras comerciais.
- **Entradas e confiança.** Comparar o mesmo espaço, modalidade, dia da semana, sazonalidade e antecedência. Para `PER_PERSON`, como no AR756, sugerir um valor em R$/pessoa por dia da semana, usando datas ocupadas sobre datas vendáveis e quantidade de orçamentos pela data solicitada do evento. Usar faixa horária quando fizer sentido para cobrança por tempo. Ponderar recência e exigir amostra mínima. Considerar capacidade, convidados e mínimo na cobrança por pessoa, duração nas cobranças por tempo e conversão e motivos de perda onde houver evidência. Separar volume bruto de orçamentos de pedidos únicos, quando houver dados para deduplicar. Se ocupação e procura divergem, evitar ajuste automático até entender a divergência. Pesos e faixa de manutenção ficam para calibração. Sem denominador confiável ou evidência suficiente, mostrar `dados insuficientes`.
- **Infraestrutura verificada.** A CLI confirmou o backend em produção como `Ready`, Node 22, função `src/server.ts` e plano Hobby. A rota pública respondeu `API online!`. O cron está incluído no plano e sua execução consome a franquia das funções. A consulta de billing para o período atual não retornou dados, a CLI do PlanetScale estava sem sessão e o custo incremental e o tempo de execução continuam pendentes de medição. Referência: [Vercel Cron — uso e preços](https://vercel.com/docs/schedules/cron-jobs/usage-and-pricing).

## Evidência encontrada no repositório

| Área | O que já existe | Lacuna para recomendar preço |
|---|---|---|
| Agenda e disponibilidade | `art56_server_v3/prisma/schema.prisma` define `DateEvent` com intervalo, tipo e vínculo opcional com proposta. `Venue` tem abertura, fechamento e regras de check-in/check-out. `src/functions/report-occupancy.ts` agrupa faixas de duas horas, separa eventos, visitas e bloqueios e exclui `PROPOSAL` provisória. `Schedule` registra atividades de uma proposta, com equipe e horários. | O relatório atual devolve `availability.defined: false`. Precisamos comprovar horas/diárias vendáveis por data, o efeito de visitas e bloqueios comerciais, a união de intervalos sobrepostos e o histórico de mudanças. Tratar `BARTER` separadamente como ocupação sem receita. A exclusão de um `DateEvent` remove o registro corrente, portanto a reconstituição de cancelamentos e reaberturas requer trilha verificável. |
| Procura e conversão | `Proposal` grava criação, datas pretendidas, convidados, tipo, categoria, canal e flags `approved`, `paid` e `termsAccepted`. `leadTimeRows` hoje seleciona `createdAt`, `startDate` e `approved`. `History` guarda ação textual com timestamp. A migration `20261109190000_add_proposal_event_category` adiciona categoria anulável. | A antecedência disponível nesse relatório é da proposta, e a flag atual não determina quando ela foi aprovada. Verificar a cobertura das ações de `History` antes de usá-las para reconstruir conversão no tempo. A cotação em `quote-proposal` calcula e responde em memória. Ainda é preciso verificar outros canais antes de contar consultas sem proposta, perdas, cancelamentos e confirmações históricas. |
| Preço e receita | `Proposal` persiste base, extras, total e descontos. `ProposalService` tem preço unitário, quantidade, cortesia e valor opcionais. `Payment` tem valor e data. `Venue`, `SeasonalFee`, períodos de mínimo e metas alimentam preço e regras atuais. A migration `20261110220000_add_proposal_discount` introduz os campos de desconto. | O total atual da proposta pode ser alterado. Para comparar preços ofertados com desfechos, precisamos de oferta, timestamp, modalidade, unidade, quantidade e valor preservados por versão, inclusive quando não há reserva. Separar preço cotado, contratado e pagamento registrado. A projeção de receita por preço depende dessa cobertura. |
| Modalidades | `PricingModel` declara `PER_PERSON`, `PER_DAY`, `PER_PERSON_DAY`, `PER_PERSON_HOUR` e `TIERED`. `proposal-amounts.ts` calcula as quatro modalidades unitárias. O endpoint `quote-proposal` aceita preço automático por pessoa e por pessoa/hora, e `create-proposal-per-day` e `update-proposal-per-day` tratam as diárias. Serviços têm `FIXED`, `PER_HOUR` e `PER_PERSON`. | A unidade de `PER_PERSON_HOUR` é R$/pessoa/hora, e `PER_PERSON_DAY` usa R$/pessoa/dia. R$/hora puro é modalidade de serviço no schema, sem modelo equivalente para o preço base do espaço. Validar o fluxo vigente de `TIERED` e totais manuais antes de sugerir ajustes. A regra futura precisa indicar a parcela ajustada e simular o total após mínimos, taxas, adicionais e descontos. |
| Relatórios e acesso | O backend já tem `GetOccupancyReportUseCase`, `GetLeadTimeReportUseCase` e `ReportAuthorizer`. O dashboard já consome esses dados via `src/hooks/venue/queries/venueReportBlocks.ts` e tem `OccupancyCard` e `LeadTimeCard`. | Criar leitura autorizada por espaço para as recomendações e integrar a visualização ao relatório. Reutilizar convenções dos relatórios existentes e preservar isolamento entre organizações. |
| Agendamento e persistência | `art56_server_v3/vercel.json` usa `builds` com `@vercel/node` e encaminha requisições para `src/server.ts`. | Adicionar o agendamento e a rota autenticada. Definir persistência com migration aditiva, chave por espaço e faixa, publicação que preserve o último sucesso e proteção contra duplicidade ou concorrência. Registrar duração, volume, falhas e idade do resultado. O tempo disponível deve ser verificado com a configuração real. O campo `functions` do Vercel não pode coexistir com o `builds` atual. |

## Pendências para colocar em produção

1. **Medir antes de definir o tamanho da execução.** Com acesso de leitura ao PlanetScale, testar um espaço com consulta limitada e agregada, sem dados pessoais. Medir volume lido, duração e cobertura de datas e estados. Verificar também se os dados permitem recompor disponibilidade histórica e qual é a franquia real das contas. O diagnóstico ainda pode avançar com os arquivos do repositório.
2. **Definir o recorte inicial.** Já é possível contar eventos, visitas, bloqueios, propostas persistidas e medir a antecedência entre criação e início. Ocupação percentual e conversão por faixa só entram com denominador verificável. Quando houver evidência parcial, avaliar estimativas com a ressalva explícita e usar `dados insuficientes` para decisão de preço se a comparação não for confiável. Dar prioridade ao histórico de disponibilidade para recomendar por faixa e, para estimar receita por preço, ao histórico de ofertas com e sem fechamento.
3. **Especificar a implementação.** Abrir a spec indicada abaixo para separar backend, persistência, agendamento e dashboard. Confirmar unidade e piso por modalidade, granularidade por espaço e faixa, critérios de amostra e manutenção, retenção e tratamento de falhas. Se o volume exceder a duração da função, dimensionar lotes a partir da medição.
4. **Provar antes de disponibilizar.** Validar a fórmula com períodos posteriores à calibração e somente com dados disponíveis no corte histórico, autenticação do cron, repetição sem duplicar resultados, falha preservando o último cálculo válido e leitura isolada por espaço. Confirmar uma execução agendada de produção e a atualização visível no dashboard.

## Teste de leitura do AR756 por dia da semana

O espaço usa `PER_PERSON` com base de R$ 100 por pessoa. Comparação de dez semanas completas, de 06/09 a 14/11/2025 e de 05/09 a 13/11/2026, pela data solicitada (`Proposal.startDate`, tipo `EVENT`) e pela data de início dos eventos da agenda (`DateEvent.startDate`, tipo `EVENT`).

- Sábados: 448 → 309 orçamentos (44,8 → 30,9 por sábado, queda de 31%). As datas com evento na agenda passaram de 3 → 4 em cada 10 sábados nominais.
- Domingos: 126 → 80 orçamentos e 0 → 2 datas com evento em cada 10 domingos nominais.
- Sextas: 24 → 13 orçamentos e zero datas com evento nos dois recortes.

A fórmula de ocupação isolada daria R$ 105 por pessoa para sábado, de 30% para 40% de ocupação nominal. A queda no volume de orçamentos indica sinais divergentes. Como o histórico de disponibilidade efetiva e a deduplicação de pedidos ainda não foram comprovados, a saída deste teste para sábado é `dados insuficientes`, com o preço-base atual de R$ 100 por pessoa. Comparar futuramente os orçamentos na mesma antecedência em relação à data solicitada e distinguir propostas aprovadas de eventos registrados na agenda.

## Faixa sugerida para task workflow

`B`, pela abrangência do diagnóstico de leitura.

## Candidato a spec

O diagnóstico cabe em uma tarefa. A implementação da recomendação no produto é candidata a spec após a análise.

## Sugestao de slug da spec

`framework_core/specs/recomendacao-precos-por-demanda/` para eventual implementação.

## Sugestao de nome do arquivo

`analise-demanda-precificacao-espacos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao` nesta etapa
- execucao recomendada: `normal`
- proximo passo: `executar` o diagnóstico somente leitura quando solicitado
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica` ao diagnóstico integrado
