# Design — Filtros de status e valor na lista de orcamentos

## Visao geral da solucao

O `GET /proposal/list` ganha `minAmount` opcional e, no `summary`, separa o funil da tabela do valor que virou evento. A pagina de orcamentos ganha uma segunda faixa, com status e um arraste de um ponto, e so desenha o `monthAmount` que a API devolve.

A faixa atual (busca, copiar o link, dia) permanece. Abaixo dela entram o select Todos / Aberto / Fechado e o arraste. Os tres cards e a tabela ficam depois, com a altura que ja tem.

## Componentes e modulos impactados

- `art56_server_v3/src/zod/proposal/list-proposal-query-schema.ts`: `minAmount` opcional
- `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.ts`: monta `monthAmount`, `daily.amount` e `amountMax` fora do filtro de busca, status e valor
- `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts`: `totalAmount >= minAmount` na lista e no funil; agregado a parte para evento e teto
- `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`: segunda faixa, status, arraste e parametros da busca
- `eventhub-vista-dashboard/src/services/proposal.service.ts` e `src/types/proposal.ts`: `minAmount` na ida e `amountMax` na volta
- `eventhub-vista-dashboard/src/components/ui/slider.tsx`: reusar o ponto unico; nao criar o segundo
- `docs/referencias/API_CONTRACTS.md#GET /proposal/list`

A store da proposta so repassa o parametro novo. A pagina de eventos nao muda a chamada.

## Reuso previsto

- `approved` ausente, `true` e `false` continuam Aberto e Fechado, como em `R-04` da spec da lista paginada
- `summary.total`, `conversionRate` e a contagem diaria continuam o funil do filtro, agora tambem com `minAmount`
- paginacao de 10, wall-clock e ordenacao nao mudam
- `minimumPrice` do espaco ja carregado no painel e o piso; nao consultar preco minimo por periodo
- o card continua lendo `summary.monthAmount`; o grafico desse card continua lendo `daily.amount`

## Contratos e dados

`minAmount` entra no mesmo preprocesso dos outros opcionais: vazio vira ausente. Presente, e numero finito e maior ou igual a zero. Fora isso, 400.

Na lista e no funil (`total`, `conversionRate`, `daily.count`, `daily.conversionRate`), `minAmount` presente vira `totalAmount >= minAmount`, junto com busca, `approved` e a janela. Ausente, nao entra no `where`.

`monthAmount`, `daily.amount` e `amountMax` usam so `venueId` e a janela de mes ou dia:

- `monthAmount` e a soma de `totalAmount` onde `approved` e verdadeiro
- cada `daily.amount` e essa soma no dia; dia sem evento fica 0
- `amountMax` e o maior `totalAmount` da janela, aprovado ou nao; sem linha, 0

Esse agregado nao recebe busca, `approved` da query nem `minAmount`. Pode ser uma segunda leitura. Nao entra na resposta quando `summary` nao vem.

`amountMax` nao muda o `where` da lista. Sem `page`, a lista inteira tambem respeita `minAmount`, para o contrato nao divergir.

Nao ha coluna, migration nem indice novo. A janela ja corta por `venueId` e `startDate`.

`docs/referencias/API_CONTRACTS.md#GET /proposal/list` passa a descrever `minAmount`, `amountMax` e o novo significado de `monthAmount`. O texto que diz que `monthAmount` segue o filtro inteiro fica so para `total` e `conversionRate`.

## Falhas, casos de borda e invariantes

- piso do arraste: `selectedVenue.minimumPrice` ou 0; valor inicial igual ao piso; `minAmount` so sai no `onValueCommit` quando o ponto esta acima do piso
- `amountMax` menor ou igual ao piso: controle desabilitado, sem `minAmount`
- passo de 1 real
- trocar mes, ano ou dia zera o ponto para o piso e tira `minAmount`; o status fica
- enquanto `summary` nao chegou, o arraste fica desabilitado
- comparacao de valor usa o `Float` gravado, sem arredondar para centavos
- a lista de eventos nao ganha `minAmount`
- `GET` sem JWT continua 401; espaco ausente continua 404
- dia invalido continua a lista vazia da spec anterior; `monthAmount` e `amountMax` vem 0

## Decisoes arquiteturais importantes

- O mesmo `GET /proposal/list` absorve o corte. Nao nasce endpoint de KPI. Alternativa descartada: somar evento no navegador, porque a pagina so tem 10 linhas.
- `monthAmount` deixa de seguir o filtro da tabela. Alternativa descartada: manter o `R-05` antigo, porque Aberto zeraria o valor do mes.
- No piso, a ausencia de `minAmount` mostra tambem o que esta abaixo do minimo da casa. Alternativa descartada: ja filtrar `>= minimo` ao abrir, porque o pedido filtra quando a pessoa sobe o ponto.
- O teto vem da API e ignora o proprio arraste. Alternativa descartada: usar o maior valor da pagina.

## Camadas transversais

- topologia, fronteira ou fluxo: nao. O mesmo use case e a mesma rota; sem ADR.
- dados persistidos: nao. Sem schema, migration ou indice; so predicado e agregacao na janela que ja existe.
- interface: sim. Segunda faixa, select e arraste, com vazio, desabilitado e soltar.
- producao: sim, sem metrica nova. A prova e o teste da listagem e a tela.
- fluxo sensivel: nao. Nao muda auth, pagamento, segredo nem PII. A rota segue com JWT e `venueId`.
- conceito senior de `patterns`: nao. Leitura, sem idempotencia, retry, fila ou cache.

## Riscos e mitigacoes

- Publicar o backend antes da tela ja corrige o Valor no mes, porque a pagina de orcamentos pede `summary`. A tela antiga ignora `amountMax`.
- Publicar a tela antes do backend: o Zod atual descarta `minAmount` desconhecido, o arraste nao corta e o card continua a soma antiga ate o backend subir. Ordem segura: backend, depois tela.
- Teste antigo que espera `monthAmount` como soma de todos os orcamentos precisa mudar nesta feature.

## Rollout, observabilidade e rollback

- sem flag e sem metrica nova
- rollback: reverter o agregado e o parametro; a tela volta a nao enviar `minAmount`
- `D-08`: atualizar `docs/referencias/API_CONTRACTS.md#GET /proposal/list` na mesma entrega do backend

## Estrategia de validacao

- `T-01`: `npm test -- --run` no use case da listagem, cobrindo `minAmount`, 400, `monthAmount` so de aprovado, `amountMax` e 401
- `T-02`: na pagina de orcamentos, status e arraste na faixa de baixo, cards com altura, corte so depois de soltar acima do piso, e Valor no mes vindo de `summary.monthAmount`
- a chamada de eventos permanece sem `minAmount`

## Fontes que fecharam a solucao

- `task-requests/filtros-status-valor-painel-orcamentos-request.md`
- `specs/2026-11-05-lista-painel-orcamentos/01-spec.md#Criterios de aceite` (`R-04`, `R-05`)
- `project/project-decisions.md#D-01`, `#D-06`, `#D-07`
- `docs/referencias/API_CONTRACTS.md#GET /proposal/list`
- codigo ja lido da listagem: `use-case-list-proposal.ts`, `proposal-in-prisma-repository.ts#summarize`, `VenueBudgets.tsx`, `ProposalListSummaryCards.tsx`
