# Spec — Novos blocos nos relatorios

## Problema

`/venue/:id/reports` mostra volume, receita, origem dos leads e categoria, mas nao responde: em que dias e horarios o espaco fica ocupado; com quanta antecedencia os pedidos chegam e se isso muda a aprovacao; quais servicos adicionais entram nos eventos fechados; e se os eventos chegam perto da capacidade. Alem disso, os endpoints de relatorio atuais so checam se o espaco existe, sem conferir permissao do usuario.

## Objetivos

- quatro leituras agregadas novas no backend, uma por bloco, com `VIEW_VENUE_ANALYSIS` checada no servidor
- quatro cards no padrao visual dos relatorios, cada um com carregamento, erro e vazio proprios
- regras de calculo explicitas e testadas para fuso, meia-noite, sobreposicao, limites de faixa e dados legados
- relatorios atuais intactos

## Fora de escopo

- schema, migration e indice novo
- cadastro de dias de funcionamento do espaco
- seletor de mes no cabecalho da pagina (o recorte mensal e local ao card de ocupacao)
- corrigir permissao de `analysisByMonth`, `trafficCount` e `analytics` (registrar como divida)
- aba `Financeiro`, visao geral, KPIs, grafico mensal, origem dos leads e rosca de categorias
- exportacao, comparacao com ano anterior e drill-down para a lista de propostas

## User stories ou cenarios principais

- como gestor, na aba `Evento`, vejo em que dias da semana e faixas de horario o espaco fica ocupado no ano ou num mes, separando eventos, visitas e bloqueios
- como gestor, na aba `Orçamentos`, vejo com quanta antecedencia os pedidos chegam e quanto cada faixa converte, por categoria do evento
- como gestor, na aba `Evento`, vejo quais servicos adicionais entram nos eventos fechados e quanto somam, sabendo quando o valor nao foi registrado
- como gestor, na aba `Evento`, vejo o porte dos eventos e quantos chegam perto ou passam da capacidade

## Criterios de aceite

- `R-01`: os quatro endpoints exigem token (401 sem token), devolvem 404 para espaco inexistente e 403 quando o usuario nao tem `VIEW_VENUE_ANALYSIS` no espaco; nenhuma consulta de dados roda antes da checagem.
- `R-02`: parametros invalidos (`year` fora de 2000–2100, `month` fora de 1–12, `eventCategory` fora do enum mais `NONE`, `venueId` vazio) devolvem 400.
- `R-03`: ocupacao devolve 84 celulas (7 dias x 12 faixas de 2 h) com minutos por `events`, `visits`, `blocks` e `total`; intervalos que cruzam a meia-noite sao divididos entre os dias; sobreposicao conta uma vez por categoria; `total` usa a uniao entre categorias.
- `R-04`: ocupacao aceita `month` opcional; sem mes o periodo e o ano inteiro; com mes, o periodo fica dentro do ano ativo; intervalos sao cortados nas bordas do periodo; a resposta identifica `period.kind` (`year` ou `month`).
- `R-05`: ocupacao devolve `occupancyRate: null` enquanto o espaco nao tiver dias de funcionamento definidos, junto com minutos ocupados e dias com registro por categoria e no total.
- `R-06`: antecedencia considera propostas do espaco com `createdAt` no ano em `America/Sao_Paulo`; dias = data do evento (componentes UTC de `startDate`) menos data local de `createdAt`; dias negativos saem do calculo e aparecem em `excluded`.
- `R-07`: antecedencia devolve mediana e as faixas 0–7, 8–30, 31–90 e >90 com `total`, `approved` e `approvalRate` (`null` quando `total` = 0); aceita filtro `eventCategory`.
- `R-08`: servicos considera propostas aprovadas com `startDate` no ano (mesmo recorte da aba `Evento`), com filtro `eventCategory`; por servico devolve orcamentos distintos e `adherence` = distintos / aprovados no recorte.
- `R-09`: servicos soma so `ProposalService.amount` nao nulo; devolve `linesWithAmount` e `linesTotal`; `amountSum` e `null` quando nenhuma linha tem valor; linhas sem valor contam na adesao.
- `R-10`: porte usa a mesma populacao da aba `Evento` (propostas aprovadas com `startDate` no ano), uma por proposta independente de quantas `DateEvent` tenha; devolve faixas ate 50, 51–100, 101–150, 151+ e contagem por `eventCategory` (com `null`).
- `R-11`: porte devolve, com `Venue.maxGuest` inteiro positivo, quantos eventos tem convidados >= 80% da capacidade e, separado, quantos passam de 100%; com capacidade invalida devolve `capacity: null` e mantem as faixas.
- `R-12`: as respostas so trazem agregados; nenhuma traz id de proposta, nome, contato ou documento de cliente.
- `R-13`: `Antecedência dos pedidos` aparece na aba `Orçamentos`; `Ocupação da agenda`, `Aderência dos serviços adicionais` e `Porte e perfil dos eventos` na aba `Evento`, abaixo do conteudo atual; cada card tem carregamento, erro com tentar de novo e vazio proprios; o conteudo atual das abas nao muda.
- `R-14`: os textos seguem o pedido: taxa vazia mostra `indisponível`; cobertura `valor registrado em X de Y linhas` ou `sem valor registrado`; soma rotulada `valor em orçamentos aprovados`; capacidade invalida mostra o indicador como indisponivel; ocupacao mostra `Ano inteiro` ou o mes.
- `R-15`: `project/api-endpoints.md` e `topics/reports-and-kpis.md` descrevem os quatro endpoints e as regras.

## Requisitos implicitos esperados

- horario de agenda e data do evento sao wall-clock (componentes UTC); `createdAt` e instante real
- valores historicos da proposta, nunca `Service.price` atual
- mesmo servico repetido numa proposta conta uma vez na adesao e soma todas as linhas no valor
- dia da semana e faixa vem dos componentes UTC do intervalo; `0` = domingo
- percentuais calculados no backend como fracao 0–1; o front formata
- consultas sempre filtradas por `venueId` e periodo no banco

## Casos de erro e borda obrigatorios

- duas `DateEvent` sobrepostas da mesma categoria; sobreposicao entre categorias diferentes no `total`
- evento 22:00–02:00; evento de varios dias; evento terminando exatamente 00:00
- `endDate <= startDate`: descartado e contado em `discarded`
- `DateEvent` que cruza o inicio ou o fim do periodo (ano ou mes): cortado na borda
- antecedencia 0 (mesmo dia), 7/8, 30/31, 90/91 dias; evento antes da criacao
- proposta criada 31/12 as 22:00 em Sao Paulo (01/01 em UTC) entra no ano do dia 31
- quantidade par e impar para a mediana; nenhuma proposta considerada -> mediana `null`
- servico sem `amount`, com `amount` 0 (conta como registrado) e repetido na mesma proposta
- proposta aprovada sem servico conta no denominador da adesao
- proposta aprovada com varias `DateEvent` conta uma vez no porte
- `guestNumber` 0 e nos limites 50/51, 100/101, 150/151; convidados exatamente 80% e exatamente 100% da capacidade
- `maxGuest` 0, negativo ou nao inteiro -> `capacity: null`
- `eventCategory` `NONE` filtra propostas sem categoria
- usuario de outra organizacao ou sem a permissao -> 403; espaco inexistente -> 404

## Impacto esperado

Gestor consegue planejar agenda e equipe por dia e horario, ajustar prazo de resposta por antecedencia, priorizar servicos que vendem e avaliar se o espaco esta sub ou superdimensionado.

## Areas impactadas

- backend: `src/router/venue.ts`, `src/use-cases/venue/reports/*` (novo), `src/functions/report-*.ts` (novos), `src/repositories/*/proposal-*`, `src/repositories/*/da*-event-*`, `src/zod/venue/`
- frontend: `src/types/venue.ts`, `src/services/venue.service.ts`, `src/hooks/venue/queries/` (novo hook), `src/components/reports/` (cards e modelo novos), `BudgetsReport.tsx`, `EventsReport.tsx`
- docs: `project/api-endpoints.md`, `topics/reports-and-kpis.md`

## Restricoes e cuidados

- nao ler nem versionar `.env`; nao escrever no banco de producao
- nao alterar campos nem significado de `analysisByMonth`, `trafficCount` e `analytics`
- `recharts` para graficos; o mapa de calor e grade de divs (recharts nao tem heatmap)
- nao criar terceira abordagem de estado no front: usar React Query, que ja coexiste com Zustand

## Dependencias

- `Proposal.eventCategory` no `main` (spec `2026-11-09-categoria-do-evento-na-proposta`)
- `reportYearRange` e `yearStart` com o fim do ano corrigido
- `UserVenuePermission` e o padrao de `VenueRuleAuthorizer`

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-02` -> `T-01`, `T-05` -> spec do authorizer e dos use cases com repositorio fake
- `R-03`, `R-04`, `R-05` -> `T-02`, `T-05` -> `report-occupancy.spec.ts`
- `R-06`, `R-07` -> `T-03`, `T-05` -> `report-lead-time.spec.ts`
- `R-10`, `R-11` -> `T-03`, `T-05` -> `report-event-profile.spec.ts`
- `R-08`, `R-09` -> `T-04`, `T-05` -> `report-service-adherence.spec.ts`
- `R-12` -> `T-05` -> spec do use case confere as chaves da resposta
- `R-13`, `R-14` -> `T-06`, `T-07` -> `report-blocks.test.ts`, build e browser
- `R-15` -> `T-08` -> leitura dos docs

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao` (pode dividir com `spec-repo-split-prompt.md`: backend `T-01`..`T-05`, frontend `T-06`, `T-07`)
- review pre-implementacao: `nao feita`
- proxima acao: executar `T-01` a `T-04` e `T-06`; depois `T-05`, `T-07` e `T-08`
- entrada publica recomendada: `fw:run` + `T-01`
