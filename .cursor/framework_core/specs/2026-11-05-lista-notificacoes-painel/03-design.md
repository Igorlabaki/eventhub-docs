# Design — KPIs, filtros, paginas e leitura na lista de notificacoes

## Visao geral da solucao

`GET /notification/list/:venueId` continua sendo a unica listagem. Com `page`, devolve 10 linhas e `pagination`. Com `summary=true`, devolve os quatro counts do mesmo filtro. A pagina de notificacoes manda `page` e `summary=true` e so desenha.

A gravacao de lida nao entra nesse GET nem em `GET /proposal/byId/:proposalId`. O detalhe do painel, depois de carregar o orcamento, chama `PATCH /notification/read-by-proposal/:proposalId`. O botao chama `PATCH /notification/read-all/:venueId`. As duas exigem JWT e uma permissao do usuario naquele espaco. As duas so atualizam linhas com `isRead` falso.

Os counts nao carregam as linhas da pagina para o Node contar.

## Passada transversal

- architecture: sim, o contrato da listagem muda e nascem duas gravacoes. Nao ha ADR: estende o dominio `notification` (`project-decisions.md#D-02`).
- database: sim, a leitura passa a contar e a paginar, e a gravacao faz `updateMany`. Sem coluna, sem indice e sem migration. O `@@index([venueId])` permanece.
- design: sim, Notificacoes ganha a faixa de filtro, quatro cards, a contagem, o pager e o botao de marcar todas, com vazio, loading e erro.
- observability: nao. Nao ha servico novo nem alerta. Nao logar `content`. A prova e teste e a tela.
- security: sim nas gravacoes. A listagem continua sem `ensureAuthenticate` (`project-decisions.md#D-05`). `GET /proposal/byId` continua sem efeito de escrita, porque o link publico usa essa rota. As gravacoes usam `ensureAuthenticate` e `getUserVenuePermission`.
- patterns/06: sim, idempotencia. `updateMany` com `isRead: false` repetido nao grava de novo. Nao ha fila, cache, retry externo nem check-then-act.

## Componentes e modulos impactados

- `art56_server_v3/src/zod/notification/list-notification-query-schema.ts`
- `art56_server_v3/src/use-cases/notification/list-notification/`
- `art56_server_v3/src/repositories/interface/notification-repository-interface.ts`
- `art56_server_v3/src/repositories/in-prisma/notification-in-prisma-repository.ts`
- `art56_server_v3/src/router/notification.ts`
- use cases novos `read-by-proposal` e `read-all` em `art56_server_v3/src/use-cases/notification/`
- `eventhub-vista-dashboard/src/pages/VenueNotifications.tsx`
- `eventhub-vista-dashboard/src/pages/ProposalDetails.tsx`
- `eventhub-vista-dashboard/src/services/notification.service.ts`
- `eventhub-vista-dashboard/src/types/notification.ts`
- `docs/referencias/API_CONTRACTS.md` secao `Notification`

`GetProposalByIdUseCase` nao muda.

## Reuso previsto

- o use case `list-notification` e a rota `GET /notification/list/:venueId`
- o contrato de `page` e `summary` de `specs/2026-11-05-kpis-filtros-lista-contatos/03-design.md#Contratos e dados`
- `ProposalListPager`
- a faixa branca, a busca com debounce de 300 ms e a linha de erro com tentar de novo de `VenueBudgets.tsx`
- `ensureAuthenticate` e `getUserVenuePermission`, no mesmo formato de `use-case-create-proposal-per-day.ts`: carrega o espaco, le `organizationId` e busca a permissao do `userId`
- React Query, ja usado por `useGetNotificationsList`. Nao criar store novo

Nao reusar `FilterList` nesta pagina.

## Contratos e dados

Query, alem de `venueId` no path:

- `page`: inteiro >= 1. Ausente = no maximo 25 linhas, sem `pagination` e sem `summary`
- `summary`: `true` ou `false`. `true` sem `page` responde 400
- `q`: trim, no maximo 80. Vazio e ignorado. Casa `content` com `contains`
- `type`: enum `VISIT`, `EVENT`, `OTHER`, `BARTER`, `PROPOSAL`, `OVERNIGHT`, `PRODUCTION`. Ausente nao filtra. Fora do enum responde 400
- `isRead`: `true` ou `false`. Ausente nao filtra
- `pageSize` do cliente e ignorado. O servidor usa 10

Ordenacao, com ou sem pagina: `createdAt` descendente e `id` descendente.

Resposta com `page`:

```ts
{
  data: { notificationList: Notification[], summary?: Summary },
  count: notificationList.length,
  pagination: { page, pageSize: 10, total, totalPages }
}
```

`totalPages` e `Math.ceil(total / 10)` e `0` quando `total` e 0. `count` continua sendo o tamanho da pagina, nao o total.

`Summary`, so com `summary=true`. Cada numero usa o mesmo `where` de `q`, `type` e `isRead`, mais o predicado do card, sem `skip` e sem `take`:

```ts
{
  unread: number
  last7Days: number
  last30Days: number
  newProposals: number
}
```

- `unread`: `isRead` falso. Com filtro `isRead=true`, a intersecao e vazia e o numero e 0
- `last7Days`: `createdAt` maior ou igual ao instante do servidor menos 7 dias de 24 horas
- `last30Days`: o mesmo com 30 dias
- `newProposals`: `type = PROPOSAL` e a janela de 30 dias. Com outro `type` no filtro, o numero e 0

Sem schema novo. Sem indice novo.

### Marcacao de lida

`PATCH /notification/read-by-proposal/:proposalId`

- `ensureAuthenticate`. Sem token, 401
- orcamento ausente, 404
- sem `UserVenuePermission` do usuario no espaco do orcamento, 403 e nenhuma escrita
- `updateMany` onde `proposalId`, `venueId` do orcamento e `isRead` falso, gravando `isRead` verdadeiro
- resposta 200 com a quantidade de linhas atualizadas. Zero e sucesso

`PATCH /notification/read-all/:venueId`

- `ensureAuthenticate`. Sem token, 401
- espaco ausente, 404
- sem permissao do usuario nesse espaco, 403 e nenhuma escrita
- `updateMany` onde `venueId` e `isRead` falso. Nao recebe `q`, `type`, `isRead` nem `page`
- resposta 200 com a quantidade atualizada. Zero e sucesso

## Tela

Abaixo do titulo, um card branco com a busca, o select de tipo (Todos e os rotulos Visita, Evento, Outro, Permuta, Orcamento, Pernoite, Producao) e o select Todas / Nao lidas / Lidas. No mesmo card, o botao Marcar todas como lidas.

Os quatro cards ficam em seguida, no formato dos cards de orcamento, sem grafico e sem variacao: Nao lidas, Ultimos 7 dias, Ultimos 30 dias, Orcamentos novos.

A lista renderiza `notificationList`. O selo Novo so com `isRead` falso. O clique continua abrindo `/proposal/:id` quando ha `proposalId`. O pager e `ProposalListPager` e fica oculto quando `totalPages` e menor ou igual a 1. Loading usa o skeleton atual. Vazio usa o empty state atual. Erro da lista mostra a mensagem e Tentar de novo.

A busca espera 300 ms e so entao muda `q` e volta para a pagina 1. Tipo e lida/nao lida tambem voltam para a pagina 1. Se a pagina pedida for maior que `totalPages` e `totalPages` for maior que 0, a tela pede `totalPages`.

O botao chama read-all e, no sucesso, refaz a listagem. Nao usa o card filtrado para se desligar.

`ProposalDetails`, depois de `fetchProposalById` resolver, chama read-by-proposal. Se a chamada falhar, o orcamento permanece na tela. No sucesso, invalida a query `notifications` daquele `venueId`. `ProposalEventLink` e a apresentacao publica nao chamam.

## Falhas, casos de borda e invariantes

- pagina alem do fim: lista vazia e `pagination.total` do filtro
- filtro vazio com `summary=true`: os quatro numeros sao 0
- `summary` ignora `skip` e `take`
- duas linhas com o mesmo `createdAt` nao trocam de pagina entre si
- aviso sem `proposalId` nao entra no read-by-proposal
- read-by-proposal nao altera notificacao de outro `proposalId`
- read-all nao altera outro `venueId`
- `GET /proposal/byId` nao escreve em `notification`
- a segunda gravacao atualiza zero linhas

## Decisoes arquiteturais importantes

- Estender `GET /notification/list/:venueId` em vez de criar outra listagem, porque a tela ja usa essa rota.
- Cards na mesma resposta, atras de `summary=true`, para a tela nao fazer uma segunda ida.
- Descartado paginar no front: a pagina de 10 deixaria de valer o total.
- Descartado gravar `isRead` dentro de `GetProposalByIdUseCase`: o link publico usa o mesmo GET e marcaria a notificacao sem o dono abrir o painel.
- Descartado exigir so `VIEW_VENUE_NOTIFICATIONS`: quem abre o orcamento no painel precisa limpar o selo. Basta uma `UserVenuePermission` naquele espaco.
- Descartado corrigir o JWT da listagem nesta spec: e a lacuna `D-05`, outra frente. As gravacoes novas nao herdam essa lacuna.
- Descartado indice novo: a lista e do espaco e ja ha indice em `venueId`.
- Descartado meia-noite no fuso do espaco: `createdAt` e instante, e `D-06` vale para data de agenda.

## Riscos e mitigacoes

- Backend da lista sobe antes do front: sem `page`, seguem no maximo 25 linhas. A tela velha segue filtrando no navegador ate `T-03`. Aceito.
- A marcacao do detalhe falha: o orcamento abre mesmo assim e o selo fica ate a proxima abertura ou o botao. Aceito.
- Query `notifications` com `staleTime` de 5 minutos: o sucesso da marcacao invalida essa query. Sem isso, o selo sobrevive a volta para a lista.

## Rollout, observabilidade e rollback

- Sem migration. Rollback do codigo restaura o teto de 25 e o selo que nao sai.
- Nao logar `content`.
- Nao ha feature flag.

## Estrategia de validacao

- `T-01` e `T-02`: `npm test -- --run` nos use cases, com repositorio falso
- `T-03`: Notificacoes no browser, filtro, cards, pagina e o botao
- `T-04`: abrir um orcamento pelo painel e voltar; o selo Novo daquele orcamento sumiu. O link publico nao chama a marcacao

## Fontes determinantes

- `task-requests/lista-notificacoes-painel-request.md`
- `specs/2026-11-05-kpis-filtros-lista-contatos/03-design.md#Contratos e dados`
- `project/project-decisions.md#D-02`, `#D-05` e `#D-06`
- `framework-libs/patterns/rules/06_senior_engineering_concepts.md` (idempotencia)
- `framework-libs/security/references/auth-and-access-control.md#Principios`
- `framework-libs/design/rules/05_component_states_and_variants.md#Estados de tela com dados`
