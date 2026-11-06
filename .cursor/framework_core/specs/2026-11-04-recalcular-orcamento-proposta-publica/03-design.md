# Design — Recalcular o orcamento no link publico

## Visao geral da solucao

O card "Seu investimento" abre um modal com tres campos. Recalcular envia dia, convidados e horas para uma rota publica nova. O use case recalcula pela tabela da casa, grava so os campos de data, pessoas e valor, e devolve esse recorte. A pagina junta o recorte no `currentProposal` que ja renderiza o card e o bloco do evento.

Passada transversal:

- architecture: nao. Nao ha fronteira nova; a rota entra no router de proposal que ja existe. Sem ADR.
- database: sim, atualiza colunas que a proposta ja tem. Sem migration, indice ou retencao nova.
- design: sim. Modal com labels, erro por campo, alerta, loading e trava de duplo clique (`design/rules/06_forms_and_input_ux.md`).
- observability: sim, vai para producao. Sem dashboard: o historico da proposta e a mensagem HTTP sao o sinal. O baseline de metricas do projeto continua ausente.
- security: sim. Escrita publica de valor. Justificativa explicita de rota sem login, recusa de aprovado/pago, corpo de resposta sem tabela nem PII.
- patterns `rules/06`: sim, idempotencia. A mesma entrada grava o mesmo resultado; nao ha chave extra nem fila. Clique repetido com outros valores fica na ultima gravacao.

## Componentes e modulos impactados

- `art56_server_v3/src/router/proposal.ts`: `PUT /proposal/presentation/:proposalId/recalculate`, sem `ensureAuthenticate`.
- use case, factory e controller novos em `use-cases/proposal/recalculate-public-proposal/`.
- Zod do corpo: `date` `YYYY-MM-DD`, `guestNumber` inteiro, `hours` inteiro.
- `eventhub-vista-dashboard/src/pages/ProposalView.tsx`: botao e modal no card "Seu investimento".
- metodo no `proposal.service.ts` e merge em `setCurrentProposal`.

## Reuso previsto

- `transformDate` com a data `YYYY-MM-DD` (o parser ja aceita esse formato) e horas `HH:mm`.
- `formatWallClockTime` e `wallClockDateIsoFromDate` para ler o inicio gravado e comparar o dia civil.
- `calcEventDuration`, `calcExtraHoursQty`, `calcExtraHourPrice`, `resolveVenueMinimumPrice`.
- Sazonalidade e meta com `wallClockWeekdayEn`, `isWallClockDayInRange`, `wallClockYear` e `wallClockMonth`, no mesmo criterio do create. Nao usar `adjustProposalUnitPrice`: ele le `Date` local e foge de D-06.
- Soma dos servicos ja ligados, pelo repositorio de servico que o update ja usa. O corpo nao traz `serviceIds`.
- `Dialog` de `components/ui/dialog.tsx`, `zodResolver` e o `handleErrors` do controller.
- Historico com `action` e `proposalId`, sem `userId`.
- Nao chamar `updatePerPerson` nem `updatePerDay`. O ramo deles cai em `calcCustomTotalAmount` quando o total digitado difere, e esse helper nao usa a tabela.

## Contratos e dados

`PUT /proposal/presentation/:proposalId/recalculate`

Corpo: `{ "date": "2026-11-20", "guestNumber": 29, "hours": 8 }`

Sucesso 200:

```json
{
  "success": true,
  "message": "Orçamento atualizado",
  "data": {
    "id": "<proposalId>",
    "startDate": "<Date>",
    "endDate": "<Date>",
    "guestNumber": 29,
    "basePrice": 0,
    "extraHoursQty": 0,
    "extraHourPrice": 0,
    "totalAmount": 0
  }
}
```

So esses campos em `data`.

Intervalo: o relogio de inicio e o de `formatWallClockTime(proposal.startDate)`. O fim e esse relogio mais `hours`, com os mesmos minutos. Se a hora do fim passar de 23, recusar. Os dois instantes nascem em `transformDate` no dia informado.

Dia civil: `wallClockDateIsoFromDate(start)` igual ao do fim atual. Se diferir, recusar antes de calcular.

Conta, sempre com o preco unitario do modelo depois de sazonalidade e, se houver receita e meta no mes, o acrescimo da meta:

- `PER_PERSON`: base = convidados × unitario. Horas extras = duracao − `standardEventDuration`, ou zero se nao houver duracao padrao ou a duracao nao exceder. Hora extra = `calcExtraHourPrice(base)`. Total = base + servicos + hora extra × quantidade.
- `PER_PERSON_HOUR` com receita no mes: igual a `PER_PERSON`, usando `pricePerPersonHour`.
- `PER_PERSON_HOUR` sem receita no mes: base = duracao × convidados × unitario; `extraHoursQty` = 0; `extraHourPrice` = base / duracao.
- `PER_DAY`: base = 1 × `pricePerDay`. `extraHoursQty` e `extraHourPrice` = 0. Convidados so sao gravados.
- `PER_PERSON_DAY`: base = 1 × unitario × convidados. Horas extras = 0.
- Se existir preco minimo na data e o total for menor, `basePrice` vira o minimo e o total vira minimo + servicos, sem horas extras. E o que o update do painel ja faz.
- `BARTER`, `TIERED` ou unitario ausente do modelo: nao grava.

Colunas gravadas: `startDate`, `endDate`, `guestNumber`, `basePrice`, `extraHoursQty`, `extraHourPrice`, `totalAmount`.

## Falhas, casos de borda e invariantes

Mensagens estaveis, via erro bad request ja existente, sem gravar:

- aprovado ou pago: "Este orçamento já foi confirmado e não pode ser recalculado."
- mais de um dia civil: "Este orçamento tem mais de um dia. Para mudar o período, fale com a equipe."
- acima de `maxGuest`: "A capacidade do espaço é de até {n} pessoas."
- fim no dia seguinte: "A quantidade de horas precisa terminar no mesmo dia."
- sem conta: "Este espaço não permite recalcular o orçamento por aqui. Fale com a equipe."
- proposta inexistente: o 404 que o projeto ja devolve.

Zod do servidor recusa data fora de `YYYY-MM-DD`, convidado < 1 e hora fora de 1–24. O frontend repete essas regras e ainda limita convidados a `maxGuest` quando a apresentacao trouxer capacidade.

Invariante: servicos, pagamento, contrato, texto e cliente nao mudam. O modal nao limpa os campos quando a resposta falha.

## Decisoes arquiteturais importantes

- Rota publica nova, em vez de reusar o update autenticado. O update autenticado mistura total digitado e tabela.
- Um dia na conta de `PER_DAY` e `PER_PERSON_DAY`. Descartado: usar `differenceInCalendarDays`, que zera o mesmo dia.
- Wall-clock do create, nao `adjustProposalUnitPrice`. Descartado: chamar o helper da edicao, porque ele usa fuso local.
- Sem chave de idempotencia. Descartado: fila ou token, porque a gravacao do mesmo corpo ja e o mesmo resultado.
- Botao secundario, texto "Alterar orçamento". Descartado: reusar o verde "Conversar com nossa equipe".

## Riscos e mitigacoes

- Qualquer pessoa com o link grava valor. Mitigacao: so aquele id, so orcamento nao confirmado, resposta sem tabela.
- Dois recálculos seguidos. Mitigacao: ultima gravacao vale; o botao trava durante o pedido.
- Create e este use case podem divergir no ramo sem receita. Mitigacao: este use case segue a regra escrita acima, com teste proprio, e nao refatora o create.

## Rollout, observabilidade e rollback

Sem migration e sem flag. Rollback e remover a rota e o botao; orcamentos ja recalculados permanecem. O historico mostra que a mudanca veio do link.

## Estrategia de validacao

- `T-01`: testes do use case nos modelos, nas recusas e na gravacao estreita.
- `T-02`: teste do controller garante a lista de campos de `data` e a ausencia de preco de tabela.
- `T-03`: modal no browser, campo invalido, sucesso e falha.

## Fontes que fecharam a solucao

- `product/02-business-rules.md#Proposal` e `product/03-user-profiles.md`
- `project-decisions.md` D-02, D-05 e D-06
- `design/rules/06_forms_and_input_ux.md`
- `patterns/rules/06_senior_engineering_concepts.md` (idempotencia)
- `security/skills/reviewing-security-sensitive-changes.md` (rota publica com justificativa)
- create e update de proposta por pessoa e por dia, helpers de wall-clock e `calcCustomTotalAmount`
