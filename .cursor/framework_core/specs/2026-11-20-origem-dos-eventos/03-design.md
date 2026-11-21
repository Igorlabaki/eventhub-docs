# Design — De onde vem os eventos

## Visao geral da solucao

Um `GET /venue/reports/event-origin` le so cidade, estado e bairro das propostas aprovadas com inicio no ano. Uma funcao pura monta tres rankings. A aba EVENTO ganha um card de largura inteira, abaixo de servicos e porte.

## Passada transversal

- architecture: nao. Nova rota no `venueRoutes` que ja existe. Sem fronteira nova.
- database: nao. Sem coluna, indice ou migration. A leitura filtra `venueId` + `startDate`, e `Proposal` ja tem `@@index([venueId, startDate])`.
- design: sim. Card novo, tres listas, estados de carregando, erro e vazio herdados do `ReportBlock`.
- observability: nao. Sem log, metrica ou alerta novo. O authorizer nao passa a registrar endereco.
- security: sim. A fonte e endereco do cliente. A rota e autenticada, a permissao e `VIEW_VENUE_ANALYSIS`, o `select` tem tres colunas e o JSON nao leva dado de pessoa.
- patterns/rules/06: nao para idempotencia, retry, fila, concorrencia e paginacao. A resposta e um agregado de um espaco e um ano, no tamanho de `event-profile`, nao uma listagem de propostas. Cache: so o `staleTime` de 5 min que `venueReportBlocks.ts` ja aplica. Sem cache no servidor.

## Componentes e modulos impactados

- `art56_server_v3/src/functions/report-event-origin.ts` e `report-event-origin.spec.ts`
- `proposal-repository-interface.ts` e `proposal-in-prisma-repository.ts`: `eventOriginRows`
- `use-cases/venue/reports/event-origin/`: use case e factory, no molde de `event-profile`
- `router/venue.ts`: `GET /reports/event-origin`
- `use-cases/venue/reports/reports.spec.ts`: o fake do repositorio ganha o metodo
- `eventhub-vista-dashboard`: `types/venue.ts`, `venue.service.ts`, `venueReportBlocks.ts`, `components/reports/EventOriginCard.tsx`, `EventsReport.tsx`
- docs: linha em `project/api-endpoints.md#Venue, precos e configuracao`; paragrafo em `topics/reports-and-kpis.md#Blocos agregados`

## Reuso previsto

- `approvedInYearWhere` e `reportEnvelope` de `report-query.ts`
- `ReportController` + `reportParamsSchema` (ano 2000–2100)
- `ReportAuthorizer` (`REPORT_PERMISSION`)
- `ReportBlock` e o padrao de `useReportEventProfile`
- lista do card de porte (rotulo a esquerda, quantidade a direita), sem `MeterBar`

## Contratos e dados

`GET /venue/reports/event-origin?venueId&year`

Envelope: `{ success: true, message: "Sucesso", data, count: 1, type: "EventOriginReport" }`.

```ts
type EventOriginData = {
  year: number;
  events: number;
  cities: { label: string; count: number }[];
  states: { label: string; count: number }[];
  neighborhoods: { label: string; count: number }[];
};
```

`eventOriginRows` faz `findMany` com `select: { city: true, state: true, neighborhood: true }` e o `where` de `approvedInYearWhere(venueId, year)` sem categoria.

Agrupamento, para cada um dos tres campos, so das linhas em que os tres campos passam no `trim`:

- chave: `trim().toLocaleLowerCase("pt-BR")`
- rotulo: `trim()` da primeira linha daquele grupo
- ordem: `count` desc, depois `label.localeCompare(label, "pt-BR")`

`events` = quantidade de linhas completas. Cada ranking soma `events`.

## Falhas, casos de borda e invariantes

- campo nulo ou `trim` vazio em qualquer um dos tres: a linha nao entra
- espaco interno permanece na chave
- acento permanece na chave
- `month` e `eventCategory` nao filtram
- o card nao renderiza campo que o tipo nao tem

## Decisoes arquiteturais importantes

- Funcao pura separada do Prisma, como `buildEventProfile`. O use case so autoriza, busca e envelopa.
- Um endpoint para os tres rankings. Tres requests repetiriam a mesma leitura.
- Sem top N. A soma visivel e a soma real.
- Descartado: faixa "Sem endereco". O pedido recusou.
- Descartado: normalizar acento. O pedido separou "São Paulo" de "Sao Paulo".
- Descartado: paginar. Nao e listagem de propostas.

## Riscos e mitigacoes

- `select` largo demais: o tipo da row e o teste do repositorio (ou o spec do use case com fake) nao incluem outra chave; a review olha o `select`.
- KPI da aba maior que `events`: so acontece com proposta aprovada sem os tres campos. Premissa do negocio e que isso nao ocorre. O card mostra o proprio `events`.

## Rollout, observabilidade e rollback

Sem migration e sem flag. Publicar a API antes do frontend. Rollback e tirar a rota e o card. Nenhum dado gravado muda.

## Estrategia de validacao

- `T-01`: `npm test -- --run` no spec da funcao
- `T-02`: o mesmo, no `reports.spec.ts`, com authorizer negado e concedido
- `T-03`: vitest do card (listas, vazio) e build do frontend
- browser, na execucao da `T-03`: aba EVENTO mostra o card; sem login a rota responde 401

## Fontes

- `topics/reports-and-kpis.md#Blocos agregados`
- `topics/auth-and-security.md#Regras de execucao`
- `project/api-endpoints.md#Venue, precos e configuracao`
- `framework-libs/node/index.md#Criacao de endpoint Read Model`
- `framework-libs/patterns/index.md#Decidir a estrutura de uma solucao nova`
- `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- `framework-libs/react/index.md#Estruturar camada de dados com React Query`
- `framework-libs/design/index.md#Tabelas, listas e dashboards`
- codigo modelo: `report-event-profile.ts`, `use-case-get-event-profile-report.ts`, `report-controller.ts`, `EventProfileCard.tsx`, `venueReportBlocks.ts`
