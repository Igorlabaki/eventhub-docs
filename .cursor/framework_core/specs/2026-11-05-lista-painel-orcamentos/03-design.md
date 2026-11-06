# Design — Lista paginada de orcamentos no painel

## Visao geral da solucao

`GET /proposal/list` continua sendo a unica listagem. Com `page`, devolve 10 linhas, `pagination` e, se `summary=true`, os KPIs ja calculados. A pagina de orcamentos manda `summary=true` e so desenha. A pagina de eventos manda `approved=true` e nao pede `summary`.

O intervalo de data nasce em `wall-clock-datetime`, com componentes UTC. A soma, a contagem e a serie diaria nao carregam as linhas da pagina para o Node somar.

## Passada transversal

- architecture: sim, o contrato da listagem muda para as duas telas. Nao ha ADR: segue o use case existente (`project-decisions.md#D-02`).
- database: sim, indice aditivo `(venueId, startDate)`. Sem coluna nova e sem mudar `Float`.
- design: sim, a pagina de orcamentos ganha a hierarquia da referencia, com vazio, loading e erro. Eventos so ganha busca no servidor e pager.
- observability: nao. Nao ha servico novo nem alerta. A prova e teste e a tela.
- security: sim, a rota ja exige JWT. A query nao alarga o filtro alem do `venueId` pedido. Nao corrige ownership (`project-decisions.md#D-05`).
- patterns/06: nao. Leitura paginada, sem fila, cache, retry ou escrita concorrente.

## Componentes e modulos impactados

- `art56_server_v3/src/zod/proposal/list-proposal-query-schema.ts`
- `art56_server_v3/src/functions/wall-clock-datetime.ts`
- `art56_server_v3/src/use-cases/proposal/list-proposal/`
- `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts`
- `art56_server_v3/prisma/schema.prisma` (`Proposal`)
- `eventhub-vista-dashboard/src/services/proposal.service.ts`
- `eventhub-vista-dashboard/src/store/proposalStore.ts`
- `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`
- `eventhub-vista-dashboard/src/pages/VenueEvents.tsx`
- `eventhub-vista-dashboard/src/components/proposal/ProposalTable.tsx`
- `docs/referencias/API_CONTRACTS.md` secao `GET /proposal/list`

## Reuso previsto

- `ensureAuthenticate` na rota, sem middleware novo
- `wall-clock-datetime` para o intervalo; nao criar outro tipo de data
- `MonthYearNavigator` e `EventMonthYearNavigator`
- `PageHeader` com Novo Orcamento
- Recharts, ja usado no dashboard, so para plotar `summary.daily`
- selos com as cores ja usadas no painel: ambar para Aberto, verde para Fechado, `primary` no mes ativo

Nao reusar `analysisByMonth`: ele carrega o ano e agrega no use case para o relatorio.

## Contratos e dados

Query nova, alem de `venueId`, `completeClientName`, `email`, `month`, `year` e `approved`:

- `page`: inteiro >= 1. Ausente = lista inteira, sem `pagination` e sem `summary`
- `summary`: `true` ou `false`. `true` sem `page` responde 400
- `day`: 1 a 31. Sem `month`, responde 400
- `sortBy`: `startDate` | `totalAmount` | `status`. Default `startDate`
- `sortDir`: `asc` | `desc`. Default `asc`
- `completeClientName`: trim, no maximo 80. Vazio e ignorado
- `pageSize` do cliente e ignorado. O servidor usa 10

`approved` ausente nao filtra. `true` e `false` filtram. Isso substitui o `approved: approved ? true : false` do repositorio.

Intervalo wall-clock:

- mes: `[Date.UTC(ano, mes-1, 1), Date.UTC(ano, mes, 1))`
- dia: `[Date.UTC(ano, mes-1, dia), Date.UTC(ano, mes-1, dia+1))`, so se esse instante ainda cai no mesmo dia UTC. Se o dia nao existe, a lista e vazia
- ano ausente com mes presente: ano UTC atual

Ordenacao: o campo pedido e, sempre, `id` ascendente no desempate. `status` ordena `approved` (falso = Aberto primeiro no `asc`).

Item da lista, mantendo os campos atuais e acrescentando:

- `approved`
- `status`: `ABERTO` ou `FECHADO`

Resposta com `page`:

```ts
{
  data: { proposalList: Item[], summary?: Summary },
  count: proposalList.length,
  pagination: { page, pageSize: 10, total, totalPages }
}
```

`totalPages` e `Math.ceil(total / 10)` e `0` quando `total` e 0. `count` continua sendo o tamanho da pagina, nao o total.

`Summary`, so com `summary=true`:

```ts
{
  total: number
  monthAmount: number
  conversionRate: number
  daily: { day: number, count: number, amount: number, conversionRate: number }[]
}
```

`monthAmount` e a soma de `totalAmount` no `Float` ja gravado, sem arredondar de outro jeito. `conversionRate` do resumo e de cada dia e inteiro. Dia sem linha entra com zeros. A janela de `daily` e o mes, ou o unico dia quando `day` vem. A busca por nome entra nessa agregacao.

Implementacao da serie: `COUNT`, `SUM(totalAmount)` e `SUM(approved)` agrupados por `DATE_FORMAT(startDate, '%Y-%m-%d')`, nao por um `findMany` do mes. O formato devolve o calendario gravado no DATETIME, que e o wall-clock, sem o driver transformar `DATE()` em horario local. Preencher os dias faltantes no use case. Se a coluna for TIMESTAMP, parar e extrair o dia em UTC.

Indice aditivo em `Proposal`: `@@index([venueId, startDate])`. A busca por trecho do nome nao depende desse indice.

## Falhas, casos de borda e invariantes

- pagina alem do fim: `proposalList` vazio e `pagination.total` do filtro
- filtro vazio com `summary=true`: totais 0, `conversionRate` 0, `daily` zerado na janela
- dia invalido: mesma resposta vazia, sem estourar para o mes seguinte
- `summary` ignora `skip` e `take`
- duas linhas com o mesmo `startDate` nao trocam de pagina entre si
- evento nao recebe orcamento com `approved` falso
- orcamento sem `approved` na query recebe os dois status

## Decisoes arquiteturais importantes

- Estender `GET /proposal/list` em vez de criar outra rota, porque orcamentos e eventos ja sao essa listagem.
- KPI na mesma resposta, atras de `summary=true`, para a tela de orcamentos nao fazer uma segunda ida e a de eventos nao pagar a serie.
- Status derivado no use case, nao no banco. A decisao pendente de estados oficiais de Proposal fica como esta.
- Descartado agregar os cards no `analysisByMonth`: aquele use case le o ano inteiro para o relatorio.
- Descartado paginar no front: a pagina de 10 deixaria de valer o total e a ordenacao.
- Descartado corrigir ownership nesta spec: e outra frente, ja descrita em `D-05`.

## Riscos e mitigacoes

- Backend sobe antes do front: sem `page`, a lista inteira continua, e `approved` ausente passa a trazer Fechado. A tela velha mostra essas linhas sem selo ate `T-03`. Aceito.
- `DATE(startDate)` em TIMESTAMP mudaria o dia. `T-02` confere o tipo da coluna antes de agrupar.
- Store unico com `isLoading` compartilhado. Orcamentos e eventos passam a ter flags e metadados separados, para uma resposta nao apagar a outra.

## Rollout, observabilidade e rollback

- Migration so adiciona indice. Aplicar com `prisma migrate deploy`. Nao reescreve linha.
- Sem feature flag. Rollback do codigo restaura a lista cheia. O indice pode ficar.
- Sem log novo de nome ou valor.

## Estrategia de validacao

- `T-01` e `T-02`: unitario do use case com repositorio falso, mais a funcao de intervalo. `npx prisma validate` no indice.
- `T-03`: na pagina de orcamentos, mudar mes, dia e busca, ver no maximo 10 linhas, virar a pagina e ler os cards da resposta.
- `T-04`: na pagina de eventos, ver pagina de 10 aprovados e a busca saindo do filtro local.
- Atualizar `docs/referencias/API_CONTRACTS.md#GET /proposal/list` na `T-01` e o bloco de `summary` na `T-02`.

## Fontes que fecharam a solucao

- `project/project-decisions.md#D-01`, `#D-05`, `#D-06`, `#D-07`
- `art56_server_v3/src/router/proposal.ts` (`ensureAuthenticate` na lista)
- `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts` (o `approved` forcado e o `new Date` local)
- `art56_server_v3/src/functions/wall-clock-datetime.ts`
- `framework-libs/database/index.md#Query lenta, indice ou performance`
- `framework-libs/design/index.md#Tabelas, listas e dashboards`
- `framework-libs/node/index.md#Criacao de endpoint Read Model`
