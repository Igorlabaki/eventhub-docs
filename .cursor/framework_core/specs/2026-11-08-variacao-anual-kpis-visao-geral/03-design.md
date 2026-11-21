# Design — Variacao anual dos KPIs da visao geral do espaco

## Visao geral da solucao

`getVenueAnalytics` passa a carregar tambem a janela do ano anterior e devolve `yearlyChange` com o percentual dos quatro KPIs. A visao geral troca o `MonthChange` pelo `YearlyChange` da lista de orcamentos, agora num arquivo compartilhado, e o desenha nos quatro cards.

## Componentes e modulos impactados

- `art56_server_v3/src/functions/yearly-change.ts` (novo): `previousYearWindow` e `yearlyChange`, puras
- `art56_server_v3/src/functions/yearly-change.spec.ts` (novo)
- `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts`: `getVenueAnalytics` inclui a janela anterior no `OR` de `DateEvent` e de `proposals` e monta `yearlyChange`
- `art56_server_v3/src/repositories/interface/venue-repository-interface.ts`: `yearlyChange` em `VenueAnalyticsResponse`
- `eventhub-docs/docs/referencias/API_CONTRACTS.md#GET /venue/analytics/:venueId`: descreve `yearlyChange`
- `eventhub-vista-dashboard/src/components/ui/yearly-change.tsx` (novo): `YearlyChange` sai de `ProposalListSummaryCards.tsx` sem mudar markup
- `eventhub-vista-dashboard/src/components/proposal/ProposalListSummaryCards.tsx`: importa o compartilhado
- `eventhub-vista-dashboard/src/types/venue.ts`: `yearlyChange` em `VenueDashboardData`
- `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.tsx`: canto nos quatro cards; `MonthChange` sai
- `eventhub-vista-dashboard/src/components/venue/VenueStatsPanel.test.tsx`: casos do canto

Nao muda rota, controller, use case, Zod, servico do painel, store nem os graficos.

## Reuso previsto

- `YearlyChange` da lista de orcamentos: sinal unico, cor, icone, traco e nome acessivel ja fechados
- a regra `Math.round(((atual - anterior) / anterior) * 100)` com `null` sem base, da spec irma
- os `filter` de `getVenueAnalytics` que ja contam eventos, propostas, visitas e receita; a janela anterior entra como outro intervalo nos mesmos `filter`

## Contratos e dados

Campo novo, sempre presente quando o analytics responde:

```ts
yearlyChange: {
  events: number | null;
  proposals: number | null;
  visits: number | null;
  revenue: number | null;
}
```

```ts
export function yearlyChange(current: number, previous: number): number | null
// previous === 0 -> null; senao Math.round(((current - previous) / previous) * 100)

export function previousYearWindow(year: number, monthIndex: number | null): { start: Date; end: Date }
// monthIndex null (month=all) -> new Date(year - 1, 0, 1) .. new Date(year - 1, 11, 31)
// monthIndex 0..11            -> new Date(year - 1, monthIndex, 1) .. new Date(year - 1, monthIndex + 1, 0)
```

A construcao repete a de `firstDayOfMonth` e `lastDayOfMonth` do card, so com o ano menos um. Exemplos fechados: 248 contra 175 e 42; 3 contra 5 e -40; iguais e 0; 0 contra 4 e -100; 5 contra 0 e `null`; -10,5 arredonda para -10.

No repositorio, o `OR` de `DateEvent` ganha `{ startDate: { gte: prev.start, lte: prev.end } }` e o de `proposals` o mesmo intervalo. Os quatro numeros anteriores usam os mesmos predicados dos atuais: `EVENT` para eventos, `VISIT` para visitas, `startDate` para propostas, `EVENT` com `proposal.totalAmount` para receita.

`proposalsVariation`, `visitsVariation` e `revenueVariation` permanecem como hoje, com a janela do mes anterior.

## Falhas, casos de borda e invariantes

- `yearlyChange` sempre presente, mesmo com os quatro campos `null`
- os numeros principais e `monthlyRevenueList` nao leem a janela anterior; o `OR` maior so traz linhas a mais que os `filter` atuais ignoram por data
- em `month=all`, a janela anterior coincide com a janela "anterior" dos campos antigos; o `OR` repetido nao muda o resultado
- janeiro compara com janeiro do ano anterior
- `totalEventsInYear` nao ganha par anual

No card, o canto fica a direita do bloco icone + numero, alinhado ao topo, como hoje em Orcamentos:

- positivo: `+42%`, `text-emerald-600`, icone de alta
- negativo: `-40%`, `text-red-600`, icone de queda
- zero: `0%`, `text-muted-foreground`, icone de traco
- `null`: `—`, `text-muted-foreground`, sem seta
- `numbersLoading` ou `yearlyChange` ausente: o canto nao e renderizado

O texto visivel e so o percentual ou o traco; o nome acessivel e o do `YearlyChange`. Cor nao e o unico sinal.

## Decisoes arquiteturais importantes

- Campo novo `yearlyChange` em vez de mudar os `*Variation`. Alternativa descartada: trocar o significado ou o formato dos antigos, que quebraria ou confundiria o bundle em cache.
- Percentual no backend. Alternativa descartada: buscar o ano anterior do navegador e dividir la.
- Funcao pura em `functions/`, como `sameMonthRevenueByYear`. Alternativa descartada: conta inline no repositorio, sem teste unitario.
- Janela anterior com a mesma construcao local do card. Alternativa descartada: `Date.UTC` com fim do dia so na anterior, que compararia janelas de tamanho diferente.
- `YearlyChange` movido para `components/ui/`. Alternativa descartada: importar de `ProposalListSummaryCards`, acoplando a visao geral a lista de orcamentos.

## Camadas transversais

- topologia, fronteira ou fluxo: nao. A mesma rota e o mesmo repositorio; sem ADR.
- dados persistidos: nao. Sem schema, migration ou indice; a query ganha um intervalo de data no `OR` existente.
- interface: sim. O canto tem alta, queda, igual, sem base e carregamento.
- producao: sim, sem metrica nova. A prova e o vitest e a tela.
- fluxo sensivel: nao. Nao muda auth, pagamento, segredo nem PII.
- conceito senior de `patterns`: nao. Leitura agregada, sem idempotencia, retry, fila ou cache.

## Riscos e mitigacoes

- Publicar o backend antes da tela e seguro: a tela atual le so `proposalsVariation`, que nao muda.
- Publicar a tela antes deixa os cantos vazios ate `yearlyChange` existir.
- O `OR` maior traz mais linhas de `DateEvent` e `proposals` (um mes, ou um ano em `Anual`). Mitigacao: so os campos ja selecionados; se pesar, contar no banco fica para outra spec.

## Rollout, observabilidade e rollback

- sem flag e sem metrica nova
- rollback: tirar `yearlyChange` e voltar o `MonthChange` em Orcamentos
- `D-08`: atualizar `docs/referencias/API_CONTRACTS.md#GET /venue/analytics/:venueId` na mesma entrega do backend
- limpeza posterior: remover os `*Variation` quando nenhuma tela os ler

## Estrategia de validacao

- `T-01`: vitest de `yearlyChange` e `previousYearWindow`; `npm test -- --run` verde no backend
- `T-02`: vitest do markup do `VenueStatsPanel` com alta, queda, zero, traco, loading e campo ausente; vitest de `ProposalListSummaryCards` segue verde; `npm run lint` nos arquivos tocados
- browser: `/venue/:id` num mes e em `Anual`; o login local segue como lacuna conhecida se nao houver sessao

## Fontes que fecharam a solucao

- `task-requests/variacao-anual-kpis-visao-geral-request.md`
- `specs/2026-11-05-variacao-anual-kpis-orcamentos/03-design.md#Contratos e dados`
- `specs/2026-11-05-desempenho-mensal-mesmo-mes-nos-anos/03-design.md#Decisoes arquiteturais importantes`
- `project/project-decisions.md#D-01`, `#D-06`, `#D-08`
- `docs/referencias/API_CONTRACTS.md#GET /venue/analytics/:venueId`
- codigo: `getVenueAnalytics`, `VenueStatsPanel.tsx`, `ProposalListSummaryCards.tsx`, `same-month-revenue-by-year.ts`
