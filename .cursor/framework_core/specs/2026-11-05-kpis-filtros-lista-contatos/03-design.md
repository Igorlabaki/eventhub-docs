# Design — KPIs, filtros e paginas de dez na lista de contatos

## Visao geral da solucao

`GET /contact/list` continua sendo a unica listagem. Com `page`, devolve 10 linhas e `pagination`. Com `summary=true`, devolve tambem os tres counts do mesmo filtro. A pagina de contatos manda `page` e `summary=true` e so desenha. Indicar parceiros nao manda `page` e segue recebendo a lista inteira.

Os counts nao carregam as linhas da pagina para o Node contar.

## Passada transversal

- architecture: sim, o contrato da listagem muda. Nao ha ADR: estende o use case existente (`project-decisions.md#D-02`).
- database: sim, a leitura passa a contar e a paginar. Sem coluna, sem indice e sem migration. O `@@index([venueId])` permanece.
- design: sim, Contatos ganha a faixa de filtro, tres cards, a contagem e o pager de orcamentos, com vazio, loading e erro.
- observability: nao. Nao ha servico novo nem alerta. A prova e teste e a tela.
- security: nao nesta mudanca. A rota hoje nao usa `ensureAuthenticate`; esta spec nao corrige isso (`project-decisions.md#D-05`). A query nao sai do `venueId` pedido e nao ganha log de nome, WhatsApp ou e-mail.
- patterns/06: nao. Leitura paginada, sem fila, cache, retry ou escrita concorrente.

## Componentes e modulos impactados

- `art56_server_v3/src/zod/contact/list-contact-query-schema.ts`
- `art56_server_v3/src/use-cases/contact/list-contact/`
- `art56_server_v3/src/repositories/interface/contact-repository-interface.ts`
- `art56_server_v3/src/repositories/in-prisma/contact-in-prisma-repository.ts`
- `eventhub-vista-dashboard/src/services/contactService.ts`
- `eventhub-vista-dashboard/src/store/contactStore.ts`
- `eventhub-vista-dashboard/src/types/contact.ts`
- `eventhub-vista-dashboard/src/pages/VenueContacts.tsx`
- `eventhub-vista-dashboard/src/components/contact/contact-list.tsx`
- `docs/referencias/API_CONTRACTS.md` secao `GET /contact/list`

## Reuso previsto

- o use case `list-contact`, sem rota nova
- `ProposalListPager` como esta: `page`, `totalPages`, `onPageChange`
- a faixa branca, a busca com debounce de 300 ms e a linha de erro com tentar de novo de `VenueBudgets.tsx`
- `ContactHeader`, o botao de copiar o link e `ContactListSkeleton`
- Zustand, ja usado pelo contato. Nao criar outra camada de estado

Nao reusar `FilterList` nesta pagina. O componente fica para as outras telas.

## Contratos e dados

Query, alem de `venueId`, `name` e `type`:

- `page`: inteiro >= 1. Ausente = lista inteira, sem `pagination` e sem `summary`
- `summary`: `true` ou `false`. `true` sem `page` responde 400
- `q`: trim, no maximo 80. Vazio e ignorado. Casa `name`, `role`, `whatsapp` ou `email` com `contains`
- `category`: enum `PartnerCategory`. Ausente nao filtra. Valor fora do enum responde 400
- `name`: permanece, so no nome. Se vier com `q`, os dois restringem
- `pageSize` do cliente e ignorado. O servidor usa 10

`type` ausente nao filtra. `category` filtra o valor gravado. `OUTROS` nao inclui `category` nula.

Ordenacao: `name` ascendente e, sempre, `id` ascendente no desempate.

Resposta com `page`:

```ts
{
  data: { contactList: Contact[], summary?: Summary },
  count: contactList.length,
  pagination: { page, pageSize: 10, total, totalPages }
}
```

`totalPages` e `Math.ceil(total / 10)` e `0` quando `total` e 0. `count` continua sendo o tamanho da pagina, nao o total.

`Summary`, so com `summary=true`:

```ts
{
  total: number
  withLogo: number
  withDescription: number
}
```

`total` e o `count` do mesmo `where` da pagina, sem `skip` e sem `take`. `withLogo` e esse `where` mais `logoUrl` preenchido depois do trim. `withDescription` faz o mesmo com `description`. Os tres counts e a pagina saem juntos. Nao ha serie diaria.

Sem schema novo. Sem indice novo.

## Tela

A aba continua no `ContactHeader`. Abaixo, um card branco com a busca, o botao de copiar o link e, so em Parceiros, o select de categoria com Todas e os rotulos de `PARTNER_CATEGORY_LABELS`.

Os tres cards ficam em seguida, no formato dos cards de orcamento, sem grafico e sem variacao anual: Total, Com logo, Com descricao. A linha seguinte mostra `pagination.total` contatos.

A tabela renderiza `contactList`. O pager e `ProposalListPager` e fica oculto quando `totalPages` e menor ou igual a 1. Loading usa o skeleton atual. Vazio usa o empty state atual. Erro da lista mostra a mensagem e Tentar de novo.

A busca espera 300 ms e so entao muda `q` e volta para a pagina 1. Categoria e aba tambem voltam para a pagina 1. Trocar para Equipe limpa a categoria. Criar, editar e apagar repetem a consulta atual. Se a pagina pedida for maior que `totalPages` e `totalPages` for maior que 0, a tela pede `totalPages`.

`SendSuppliers` nao passa `page` nem `summary`.

## Falhas, casos de borda e invariantes

- pagina alem do fim: `contactList` vazio e `pagination.total` do filtro
- filtro vazio com `summary=true`: os tres numeros sao 0
- `summary` ignora `skip` e `take`
- duas linhas com o mesmo `name` nao trocam de pagina entre si
- `q` e `category` se somam; um nao substitui o outro
- logo ou descricao nulos ou em branco nao entram no count
- sem `page`, `summary` nao e calculado

## Decisoes arquiteturais importantes

- Estender `GET /contact/list` em vez de criar outra rota, porque o painel e Indicar parceiros ja usam essa listagem.
- Cards na mesma resposta, atras de `summary=true`, para a tela nao fazer uma segunda ida e o chamador sem pagina nao pagar o count.
- Descartado paginar no front: a pagina de 10 deixaria de valer o total.
- Descartado indice novo: a lista e do espaco e ja ha indice em `venueId`.
- Descartado corrigir o JWT nesta spec: e a lacuna `D-05`, outra frente.
- Descartado grafico nos cards: contato nao tem serie no tempo.

## Riscos e mitigacoes

- Backend sobe antes do front: sem `page`, a lista inteira continua. A tela velha segue filtrando no navegador ate `T-02`. Aceito.
- Store com `isLoading` unico. A listagem passa a guardar `contactListPagination`, `contactListSummary` e `contactListError` ao lado da lista, para o erro nao apagar o contrato da pagina.

## Rollout, observabilidade e rollback

- Sem migration. Rollback do codigo restaura a lista cheia.
- Sem feature flag.
- Sem log novo de nome, WhatsApp ou e-mail.

## Estrategia de validacao

- `T-01`: unitario do use case com repositorio falso. `npm test -- --run` desse spec.
- `T-02`: na pagina de contatos, buscar, filtrar categoria, ver no maximo 10 linhas, virar a pagina e ler os cards da resposta. Indicar parceiros continua listando todos.
- Atualizar `docs/referencias/API_CONTRACTS.md#GET /contact/list` na `T-01`.

## Fontes que fecharam a solucao

- `project/project-decisions.md#D-02`, `#D-05`
- `specs/2026-11-05-lista-painel-orcamentos/03-design.md#Contratos e dados`
- `art56_server_v3/src/router/contact.ts` (lista sem `ensureAuthenticate`)
- `art56_server_v3/src/repositories/in-prisma/contact-in-prisma-repository.ts` (`list` sem pagina)
- `eventhub-vista-dashboard/src/pages/VenueContacts.tsx` e `components/contact/contact-list.tsx` (`FilterList` no cliente)
- `framework-libs/node/index.md#Criacao de endpoint Read Model`
- `framework-libs/database/index.md#Query lenta, indice ou performance`
- `framework-libs/design/index.md#Tabelas, listas e dashboards`
