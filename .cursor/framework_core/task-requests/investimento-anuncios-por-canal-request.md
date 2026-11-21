# Solicitacao da Tarefa

## Nome sugerido da tarefa

Canal na despesa de publicidade e investimento em anuncios por canal nos relatorios

## Resumo da solicitacao

Na despesa da categoria Publicidade (`ADVERTISING`), o dono informa o canal onde gastou (Instagram, Facebook, TikTok, Google ou Outros). Nos relatorios, um card novo "Investimento em anuncios" cruza esse gasto com os orcamentos que chegaram pelo mesmo canal (`Proposal.trafficSource`) e mostra, por canal: investido, orcamentos, custo por orcamento, eventos, custo por evento e retorno.

## Context Pack

- frente principal: backend (calculo do investimento por canal e endpoint novo de relatorio), com formulario de despesa e card no frontend
- superficie sensivel: nao — leitura agregada autenticada seguindo `ReportAuthorizer` (`VIEW_VENUE_ANALYSIS`), sem rota publica e sem PII; atencao financeira: numeros de custo e retorno que o dono usa para decidir investimento
- camadas transversais: `database`, `design`
- risco principal: valor mensal da recorrente errado (tipo ignorado, meses ativos contados alem do mes atual ou antes do cadastro) ou janela de data errada (usar `startDate` em vez de `createdAt` do orcamento), gerando custo por orcamento/evento enganoso
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`), banco PlanetScale `ar756/main`
- fora de escopo operacional: separar orcamento organico de pago no mesmo canal (sem UTM/atribuicao); varios canais por despesa; projetar gasto recorrente futuro; mudar a regra de data dos outros blocos do relatorio (continuam em `startDate`); aplicar "conta a partir do cadastro" na analise de despesas do Financeiro (so o `WEEKLY` muda la); backfill de canal nas despesas antigas; historico de despesa recorrente excluida; corrigir a divida de permissao de `/expense/analysis`
- prova minima desta execucao: vitest da funcao pura do relatorio de anuncios com: semanal 100 vira 433,33/mes; recorrente mensal cadastrada em marco do ano corrente conta de marco ate o mes atual; ano passado conta do mes de cadastro a dezembro; ano futuro conta 0; esporadica entra pelo `paymentDate` no ano; `costPerProposal`/`costPerEvent`/`roas` `null` com divisor zero; bucket "sem canal" para publicidade sem canal; vitest de `use-case-analysis-expense` com despesa `WEEKLY` diferente de zero; zod de despesa recusando `ADVERTISING` sem canal (400); no painel, o campo Canal aparece so em Publicidade e o card mostra a tabela com linha de total
- criterio de escalada: ja e `spec` (faixa `C`); reabrir escopo se surgir pedido de atribuicao por campanha/UTM, varios canais por despesa ou mudar a janela de data do resto do relatorio
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/prisma/schema.prisma` em `model Expense`, `enum ExpenseType`, `enum ExpenseCategory` e `enum TrafficSource`; `art56_server_v3/src/use-cases/expense/analysis-expense/use-case-analysis-expense.ts` (inteiro)
- libs obrigatorias: `node`, `database`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/topics/reports-and-kpis.md#Blocos agregados (/venue/reports/*)` e `#Despesas`
  - `.cursor/framework_core/topics/improvement-backlog.md#PRICE-05 — Despesa recorrente WEEKLY ignorada na analise`
  - `.cursor/framework_core/project/planetscale.md`
  - `.cursor/framework_global/framework-libs/database/index.md`
- caminhos candidatos:
  - backend: `src/use-cases/expense/` (create, update, analysis); schemas zod de despesa em `src/zod/`; `src/repositories/` de expense e de venue; `src/functions/report-lead-time.ts` (modelo de funcao pura e de fuso `America/Sao_Paulo`); `ReportAuthorizer` e rotas `/venue/reports/*`
  - frontend: `src/components/expense/expense-form.tsx`, `expense-list.tsx`; `src/pages/VenueExpenses.tsx`; `src/components/reports/report-metrics.ts` (`TRAFFIC_SOURCES`), `finance-metrics.ts`, `report-blocks.ts`; `FinancialReportCard`; `src/hooks/venue/queries/venueReportBlocks.ts`; tipos e service de despesa
- palavras-chave ou simbolos de busca: `ExpenseCategory`, `ADVERTISING`, `ExpenseType`, `WEEKLY`, `BIWEEKLY`, `recorringMap`, `analysisExpense`, `TrafficSource`, `trafficSource`, `trafficCount`, `TRAFFIC_SOURCES`, `ReportAuthorizer`, `VIEW_VENUE_ANALYSIS`, `report-lead-time`
- testes provaveis: spec nova da funcao pura do relatorio de anuncios; spec de `use-case-analysis-expense`; specs de create/update de despesa; spec do use case do endpoint (401/403/400); teste do helper de metricas do card no front
- nao ler por padrao: `security` (nao altera runtime de auth); calculo de preco do orcamento (`quote-service-lines`, `proposal-amounts`); outros blocos de relatorio alem do modelo `lead-time`

## Contexto informado na entrada

Pedido em chat: informar em qual rede social/canal foi feito o gasto de publicidade (patrocinio/anuncio) e ver nos relatorios, por canal, quanto investiu, custo por orcamento, custo por evento e retorno (ex.: "custo por orcamento vindo do Instagram").

Ja verificado pelo usuario e confirmado no schema: `Proposal.trafficSource` (`TrafficSource`: `AIRBNB`, `GOOGLE`, `INSTAGRAM`, `TIKTOK`, `OTHER`, `FRIEND`, `FACEBOOK`) e obrigatorio e ja agrupado no card "Canais de entrada"; `Expense` tem `category` (`TAX`, `INVESTMENT`, `MAINTENANCE`, `ADVERTISING`), `type` (`WEEKLY`, `BIWEEKLY`, `MONTHLY`, `ANNUAL`, `SPORADIC`), `recurring`, `paymentDate?` e `createdAt`, sem canal; recorrente nao tem `paymentDate`; a analise de despesas soma as recorrentes sem olhar quando comecaram e ignora `WEEKLY` (backlog `PRICE-05`).

Decisoes fechadas no chat (nao reabrir):

1. Um canal por despesa; campanha da Meta no Instagram e no Facebook vira duas despesas.
2. As metricas de anuncio cruzam a data do gasto com o `createdAt` do orcamento (chegada do lead), nao com o `startDate`; o resto do relatorio fica igual.
3. Recorrente de publicidade conta do mes de cadastro ate o mes atual, sem projetar futuro.
4. Card novo "Investimento em anuncios" na pagina de relatorios: Canal | Investido | Orcamentos | Custo/orcamento | Eventos | Custo/evento | Retorno, com linha de total.
5. Canais no formulario: Instagram, Facebook, TikTok, Google, Outros (sem Amigos); o campo so aparece e so e obrigatorio na categoria Publicidade.

Limitacoes aceitas na v1: organico e pago do mesmo canal se misturam; excluir recorrente apaga o custo passado dela; publicidade antiga fica sem canal (bucket "sem canal").

## Problema atual

O dono registra o gasto com anuncio como despesa `ADVERTISING`, mas sem dizer onde gastou. O relatorio mostra de onde os orcamentos vieram, mas nao quanto custou cada um, entao nao da para comparar canais nem saber se o anuncio se paga.

## Objetivo da mudanca

Com despesas de Publicidade cadastradas com canal, o card "Investimento em anuncios" mostra para o ano escolhido, por canal e no total, investido, orcamentos, custo/orcamento, eventos, custo/evento e retorno, com os valores batendo com a regra de meses ativos e com o `createdAt` dos orcamentos.

## Escopo inicial percebido

Um campo opcional novo na despesa, a validacao condicional no cadastro e na edicao, uma funcao pura de investimento por canal, um endpoint de relatorio novo, a correcao do `WEEKLY` na analise de despesas, o campo no formulario e o card na pagina de relatorios.

## Itens incluidos neste request

- banco: `Expense.trafficSource TrafficSource?` + indice `@@index([venueId, category])`, migration aditiva via deploy request na `main`
- contrato de despesa: `trafficSource` em create e update; obrigatorio quando `category = ADVERTISING` e so aceito nos cinco canais (`INSTAGRAM`, `FACEBOOK`, `TIKTOK`, `GOOGLE`, `OTHER`); gravado `null` nas outras categorias; devolvido na listagem
- regra de valor mensal da recorrente: semanal x52/12, quinzenal x2, mensal x1, anual /12; multiplicado pelos meses ativos no ano (do mes de cadastro ate o mes atual, recortado ao ano)
- esporadica de publicidade: entra no ano pelo `paymentDate`
- populacao de orcamentos: `createdAt` no ano, agrupados por `trafficSource`; eventos = os aprovados dessa populacao; receita = soma do `totalAmount` desses aprovados
- endpoint novo autenticado (sugestao do chat: `GET /venue/:venueId/ads-report?year=`) devolvendo por canal `spent`, `proposals`, `events`, `revenue`, `costPerProposal`, `costPerEvent`, `roas` (`null` com divisor zero), mais a linha "sem canal" e o total
- correcao em `use-case-analysis-expense.ts`: `WEEKLY` recorrente entra com x52/12 por mes e x52 no ano (fecha `PRICE-05`)
- frontend: select Canal no formulario de despesa so na categoria Publicidade, obrigatorio; canal visivel na lista de despesas; card "Investimento em anuncios" com tabela e linha de total, reaproveitando nomes e cores de `TRAFFIC_SOURCES`
- docs: `topics/reports-and-kpis.md`, `project/api-endpoints.md`, `product/08-data-model.md`, `topics/improvement-backlog.md` (`PRICE-05`)

## Requisitos implicitos ja visiveis

- despesas existentes ficam com `trafficSource null` e nao mudam nada fora do card novo
- trocar a categoria no formulario de Publicidade para outra limpa o canal
- editar uma despesa de Publicidade antiga passa a exigir o canal (o campo e obrigatorio na categoria)
- datas do ano no fuso `America/Sao_Paulo`, como o bloco de antecedencia (`createdAt` do orcamento, `createdAt` e `paymentDate` da despesa)
- "mes atual" so limita o ano corrente; ano passado vai ate dezembro; ano futuro conta 0 de recorrente
- frontend antigo sem `trafficSource` continua criando despesa das outras categorias
- dinheiro em `Float` (D-07); taxas e custos calculados no backend, formatados no front

## Casos de erro e borda ja percebidos

- `ADVERTISING` sem canal ou com `FRIEND`/`AIRBNB`: 400 com mensagem em portugues
- canal enviado em categoria diferente de Publicidade: gravado `null` (ver pergunta)
- canal com gasto e sem orcamento: `costPerProposal` e `costPerEvent` `null`; `roas` 0
- canal com orcamentos e sem gasto: custos e `roas` `null`
- recorrente cadastrada depois do mes atual do ano corrente (data adiantada no servidor): 0 meses
- esporadica de publicidade sem `paymentDate`: ver pergunta
- ano sem nenhuma despesa de publicidade: card em estado vazio, sem erro
- usuario sem `VIEW_VENUE_ANALYSIS`: 403 no endpoint novo; card mostra erro com `Tentar de novo`, como os blocos atuais
- recorrente excluida some do passado (limitacao aceita)

## Dependencias

- spec [Novos blocos nos relatorios](../specs/2026-11-10-novos-blocos-relatorios/00-overview.md): padrao `ReportAuthorizer`, funcao pura em `functions/`, envelope e hooks React Query a seguir
- task-request [Relatorios no formato da referencia](relatorios-formato-referencia-request.md): pagina `/venue/:id/reports` onde o card entra
- backlog `PRICE-05` em `topics/improvement-backlog.md`: fechado por este trabalho

## Restricoes e cuidados

- migration so aditiva e na `main` do PlanetScale por deploy request; escrita no banco real exige aprovacao nomeada
- ordem de deploy: banco, backend, frontend
- endpoint novo nasce com permissao (`VIEW_VENUE_ANALYSIS`) e teste negativo; nao herdar a divida dos endpoints antigos sem permissao
- a correcao do `WEEKLY` muda o total de despesas e a margem do Financeiro para quem tem despesa semanal; registrar no `05-state` e no topic
- `PRICE-05` sugeria contar semanas do mes (4 ou 5); a decisao deste chat e x52/12 fixo; atualizar o criterio de aceite do backlog
- nao alterar `trafficCount` nem a janela `startDate` dos outros blocos
- nao criar terceira abordagem de estado no front; seguir React Query como nos blocos agregados

## Perguntas em aberto

- Caminho do endpoint: `GET /venue/:venueId/ads-report?year=` (chat) ou o padrao dos blocos `GET /venue/reports/ads?venueId&year`? Premissa: padrao dos blocos, `/venue/reports/ads`, para reaproveitar `ReportAuthorizer`, zod e envelope.
- Em qual aba o card entra? Premissa: aba FINANCEIRO, abaixo da composicao das despesas.
- Quais linhas a tabela mostra? Premissa: os cinco canais do formulario sempre (mesmo zerados), mais "Sem canal" so quando houver gasto de publicidade sem canal; `FRIEND` e `AIRBNB` ficam fora.
- Como fecha a linha de total? Premissa: investido soma todas as linhas, inclusive "Sem canal"; orcamentos, eventos e receita somam os cinco canais; custos e retorno do total recalculados sobre essas somas.
- "Evento" e `approved = true` ou exige `DateEvent` `EVENT`? Premissa: `approved = true` da populacao por `createdAt`, sem exigir `startDate` no ano.
- Filtro de tipo de proposta (`ProposalType`)? Premissa: o mesmo filtro que `trafficCount` usa hoje, trocando so a data.
- Canal enviado em categoria diferente de Publicidade: 400 ou ignorar? Premissa: ignorar e gravar `null`.
- Esporadica de publicidade sem `paymentDate`? Premissa: usa o `createdAt` da despesa.
- "Retorno" na tela e ROAS em multiplo (`3,2x`) ou percentual? Premissa: multiplo `receita / investido`, com `—` quando `null`.

## Prioridade sugerida

Media. Ferramenta de decisao comercial nova, sem bloqueio; traz junto a correcao de um bug de despesa ja conhecido.

## Faixa sugerida para task workflow

- `C` — schema novo, endpoint novo, regra financeira de relatorio e dois repos, com ordem de entrega propria
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: toca banco, backend e frontend; cria endpoint e regra de calculo de custo/retorno com bordas de data; corrige um bug que muda o Financeiro; e se divide em tasks com ordem (migration, contrato de despesa, funcao pura, endpoint, correcao `WEEKLY`, formulario, card, docs)

## Sugestao de slug da spec

- `framework_core/specs/2026-11-14-investimento-anuncios-por-canal/`

## Sugestao de nome do arquivo

- `investimento-anuncios-por-canal-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `spec`
- status: promovido para spec em 2026-11-14; nada implementado
- proximo passo: ver spec
- promovida para: `specs/2026-11-14-investimento-anuncios-por-canal/`
- entrada publica recomendada: `fw:run` na spec
- derivacao repo-local: depois da spec, com `spec-driven/spec-repo-split-prompt.md` (banco e backend antes do frontend)
