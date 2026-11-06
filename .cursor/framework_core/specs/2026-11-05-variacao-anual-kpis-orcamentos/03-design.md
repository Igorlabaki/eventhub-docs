# Design — Variacao anual dos KPIs na lista de orcamentos

## Visao geral da solucao

`GET /proposal/list` continua a unica listagem. Com `summary=true`, o `summary` ganha `change`, calculado no use case a partir de uma segunda leitura da mesma janela, um ano antes. A pagina de orcamentos so desenha esse campo no canto superior direito de cada card.

## Componentes e modulos impactados

- `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.ts`: monta `change` depois das duas leituras
- `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.spec.ts`: o harness passa a distinguir a janela atual da janela anterior
- `docs/referencias/API_CONTRACTS.md#GET /proposal/list`: descreve `change`
- `eventhub-vista-dashboard/src/types/proposal.ts`: `change` em `ProposalListSummary`
- `eventhub-vista-dashboard/src/components/proposal/ProposalListSummaryCards.tsx`: canto do card
- a store em `proposalStore.ts` ja grava `response.data.summary` inteiro; o servico nao mapeia KPI

Nao muda Zod, repositorio nem a chamada da pagina de eventos.

## Reuso previsto

- `proposalListRange` para as duas janelas; a anterior recebe o ano ja resolvido da atual, menos um
- `summarize` para total e conversao, com o mesmo `summaryQuery` e so a `range` trocada
- `summarizeWindow` para o valor, com o mesmo `venueId` e so a `range` trocada
- `buildSummary` para obter `total`, `monthAmount` e `conversionRate` de cada ano; a serie diaria anterior nao entra na resposta
- o sparkline, as cores emerald e vermelho ja usadas no painel, e os icones do `lucide-react`

## Contratos e dados

`summary.change` vem sempre que `summary` vem:

```ts
change: {
  total: number | null;
  monthAmount: number | null;
  conversionRate: number | null;
}
```

Cada campo e `Math.round(((atual - anterior) / anterior) * 100)`, ou `null` se o anterior e 0. `Math.round(-10.5)` permanece -10. Exemplos fechados: 243 contra 200 e 22; 12590 contra 14000 e -10; conversao 1 contra 2 e -50; iguais e 0; atual 0 contra anterior positivo e -100.

A janela atual segue `month`, `year` e `day` como hoje. A anterior usa o mesmo mes e o mesmo dia, com o ano resolvido menos um. Ano omitido na query usa o ano UTC que `proposalListRange` ja escolheria, e a anterior usa esse ano menos um. Nao chamar de novo a funcao sem ano.

Sem mes, dia invalido no ano atual, ou dia inexistente no ano anterior: nao ha segunda leitura e os tres campos sao `null`.

Total e conversao da anterior passam por `summarize` com busca, e-mail, `approved` e `minAmount`. `monthAmount` da anterior passa por `summarizeWindow`, so `venueId` e janela, somando aprovado. Os tres campos nao se copiam.

Nao ha coluna, migration nem indice novo. A segunda leitura usa o mesmo predicado `venueId` + `startDate` e o indice `proposal_venueId_startDate_idx`.

## Falhas, casos de borda e invariantes

- `summary` presente implica `change` presente, mesmo com os tres campos `null`
- dia 29 de fevereiro cujo ano anterior nao tem o dia: `null`, sem consulta
- filtro que zera so o total anterior deixa `change.total` nulo e pode deixar `change.monthAmount` numerico
- `daily`, `amountMax` e os numeros principais nao ganham par anual
- lista vazia por dia invalido continua vazia e, com `summary`, traz `change` nulo
- sem `summary`, a resposta nao ganha `change` nem a segunda leitura
- a pagina de eventos nao envia `summary`

No card, a coluna direita alinha ao topo: primeiro a variacao, depois o sparkline. O card usa `items-start`.

- positivo: `+22%`, `text-emerald-600`, icone de alta
- negativo: `-10%`, `text-red-600`, icone de queda
- zero: `0%`, `text-muted-foreground`, icone de traco
- `null`: `—`, `text-muted-foreground`, sem seta
- `summary` nulo ou `change` ausente: a variacao nao e renderizada

O texto visivel e so o percentual ou o traco. Um texto só para leitor de tela completa: acima, abaixo, igual ou sem comparacao com o mesmo periodo do ano anterior. Cor nao e o unico sinal. Nao ha `title` com o valor do ano anterior.

## Decisoes arquiteturais importantes

- O percentual nasce no use case, nao no repositorio e nao no navegador. Alternativa descartada: somar o ano anterior no cliente, porque a pagina so tem 10 linhas.
- O mesmo `GET /proposal/list` absorve `change`. Alternativa descartada: endpoint de KPI.
- Dia selecionado compara com o mesmo dia. Alternativa descartada: comparar o dia com o mes inteiro do ano anterior.
- `null` cobre ausencia de base. Alternativa descartada: devolver 0 ou um percentual arbitrario quando o anterior e 0.

## Camadas transversais

- topologia, fronteira ou fluxo: nao. A mesma rota e o mesmo use case; sem ADR.
- dados persistidos: nao. Sem schema, migration ou indice; a leitura nova repete a janela que ja existe.
- interface: sim. O canto tem alta, queda, igual, sem base e carregamento.
- producao: sim, sem metrica nova. A prova e o teste da listagem e a tela.
- fluxo sensivel: nao. Nao muda auth, pagamento, segredo nem PII. A rota segue com JWT e `venueId`.
- conceito senior de `patterns`: nao. Leitura, sem idempotencia, retry, fila ou cache.

## Riscos e mitigacoes

- Publicar o backend antes da tela e seguro: a tela atual ignora `change`.
- Publicar a tela antes deixa o canto vazio ate o campo existir, sem percentual inventado.
- Teste que conta uma unica chamada de `summarize` ou `summarizeWindow` precisa passar a esperar o par, quando a janela anterior existe.

## Rollout, observabilidade e rollback

- sem flag e sem metrica nova
- rollback: tirar `change` e o canto; a listagem atual volta ao `summary` de hoje
- `D-08`: atualizar `docs/referencias/API_CONTRACTS.md#GET /proposal/list` na mesma entrega do backend

## Estrategia de validacao

- `T-01`: `npm test -- --run` no use case da listagem, com 243/200, queda, -10,5 arredondado para -10, conversao 1 contra 2, anterior 0 so num campo, 29 de fevereiro, dia invalido, filtro que nao altera `monthAmount`, ausencia de `summary` e 401
- `T-02`: na pagina de orcamentos, canto com alta, queda, zero e traco; canto vazio enquanto `summary` nao chegou; numero principal e sparkline intactos; lista de eventos sem esse canto

## Fontes que fecharam a solucao

- `task-requests/variacao-anual-kpis-painel-orcamentos-request.md`
- `specs/2026-11-05-lista-painel-orcamentos/01-spec.md` e `specs/2026-11-05-filtros-status-valor-orcamentos/03-design.md#Contratos e dados`
- `project/project-decisions.md#D-01`, `#D-06`, `#D-08`
- `docs/referencias/API_CONTRACTS.md#GET /proposal/list`
- `framework-libs/design/rules/07_data_display_and_dashboards.md#Numeros e KPIs`
- `framework-libs/design/rules/05_component_states_and_variants.md#Estados de tela com dados`
- codigo da listagem: `use-case-list-proposal.ts`, `proposalListRange`, `ProposalListSummaryCards.tsx`, `proposalStore.ts`
