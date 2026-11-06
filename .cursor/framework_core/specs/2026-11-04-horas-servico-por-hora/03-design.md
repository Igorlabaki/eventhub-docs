# Design — Horas escolhidas no servico por hora

## Visao geral da solucao

`quoteServiceLines` passa a aceitar as horas escolhidas por id. Na criacao, cada servico por hora precisa desse numero. No link, o modal pergunta de novo e a linha ja gravada conserva o unitario. O recalculo publico nao substitui a quantidade escolhida pela duracao nova do evento.

## Componentes e modulos impactados

- `backend`: `art56_server_v3/src/functions/quote-service-lines.ts`; use cases `create-proposal-per-person`, `create-proposal-per-day`, `update-public-proposal-services` e `recalculate-public-proposal`; Zod de criacao e de `update-public-proposal-services`
- `frontend`: `ClientPerPersonProposalForm.tsx`, `ClientPerDayProposalForm.tsx`, `PerPersonProposalForm.tsx`, `PerDayProposalForm.tsx`, `UpdateProposalServicesDialog.tsx`, `proposal.service.ts`
- produto: `product/02-business-rules.md#Proposal` e `product/03-user-profiles.md#Cliente proponente`

## Reuso previsto

- `quoteServiceLines` e `sumServiceQuote` continuam sendo a unica conta da linha
- `calcEventDuration` continua a duracao do evento para o painel na edicao e para linha por hora sem quantidade gravada
- `proposalRepository.update` com `serviceLines` no link e no recalculo
- checkbox, texto de obrigatorio e estado local que os formularios publicos ja usam
- `Dialog` de `UpdateProposalServicesDialog`

## Contratos e dados

`serviceHours` e uma lista de `{ serviceId, hours }`. No maximo 100 itens. `hours` e inteiro. Id repetido responde erro. Item de servico que nao esta em `serviceIds`, ou que nao e `PER_HOUR`, e ignorado. Nao ha coluna nova: a quantidade escolhida vai para `ProposalService.quantity`.

`quoteServiceLines` recebe `hoursByServiceId` opcional. Para `PER_HOUR`:

- com entrada valida, a quantidade e esse inteiro
- 0 so vale quando `calcEventDuration` tambem e 0
- abaixo de 0, fracao ou acima de 8760 responde `HttpBadRequestError` com "Informe um número inteiro de horas para o serviço."
- sem entrada, a quantidade continua sendo `calcEventDuration`

`POST /proposal/createPerPerson` e `POST /proposal/createPerDay` ganham `serviceHours` opcional no Zod. O use case monta o mapa e, para cada id `PER_HOUR` selecionado, exige o item. Ausencia cai no mesmo erro, sem usar a duracao como substituto. `serviceId` segue o mesmo tipo ja aceito em `serviceIds` (`z.string()`), nao o uuid do `PUT` publico.

`PUT /updatePerPerson` e `PUT /updatePerDay` nao recebem o campo e nao passam o mapa.

`GET /proposal/presentation/:proposalId/services` acrescenta em cada item:

- `hourly`: verdadeiro so quando o cadastro e `PER_HOUR`
- `hours`: quantidade gravada se `hourly` e a linha ja existe com quantidade numerica; senao `null`

A resposta segue sem `pricingType`, `price` e `unitPrice`.

`PUT /proposal/presentation/:proposalId/services` aceita `serviceHours` junto de `serviceIds`. Zod descarta preco e valor. Para cada id `PER_HOUR` do conjunto final:

- linha nova, ou obrigatoria que ainda nao estava gravada, exige inteiro de 1 a 8760
- linha ja gravada usa as horas do corpo quando vierem; senao conserva `quantity` se for inteiro de 0 a 8760
- o valor novo e o `unitPrice` ja gravado vezes a quantidade; se esse unitario nao for numero, usa o unitario da cotacao atual
- 0 no corpo so passa se a duracao ja gravada do evento for 0

Ids e horas iguais ao que ja esta gravado nao chamam `update` nem historico. Historico, quando houver, permanece "Cliente atualizou os serviços pelo link". `approved` ou `paid` continuam recusando antes de gravar.

O recalculo publico monta `hoursByServiceId` com a `quantity` das linhas `PER_HOUR` que ja tem quantidade numerica e passa esse mapa para `quoteServiceLines`. O unitario dessas linhas sai do cadastro atual, como o recalculo ja faz. Linha sem quantidade segue a duracao nova.

## Falhas, casos de borda e invariantes

- O input fica fora do `label` do checkbox, para o clique no numero nao desmarcar o servico.
- Desmarcar apaga as horas daquele id no estado local.
- Marcar de novo, ou um obrigatorio entrar pela mudanca de convidados, abre o campo vazio.
- O erro do formulario aparece no submit, no proprio campo, e o passo visivel e "Como nos encontrou".
- Falha HTTP nao limpa o que foi digitado.
- O painel calcula as horas com a mesma regra de `calcEventDuration`: floor de milissegundos, pernoite quando o fim e menor que o inicio, 0 na mesma hora.
- A criacao publica e a do painel saem no mesmo lote. A rota passa a falhar para servico por hora se o cliente antigo omitir `serviceHours`.

## Decisoes arquiteturais importantes

- A quantidade escolhida reusa `ProposalService.quantity`. Descartado: coluna nova, porque a linha ja guarda quantidade, unitario e valor.
- A criacao exige o mapa para todo `PER_HOUR`. Descartado: omitir e cair na duracao, porque um POST publico sem o campo anularia o input.
- Zero com evento longo e erro. Descartado: aceitar zero sempre, porque a linha de um evento de varias horas ficaria de graca. A excecao de duracao 0 preserva o comportamento ja testado do painel.
- A leitura publica ganha `hourly` e `hours`. Descartado: devolver `pricingType` ou `unitPrice`, porque o contrato atual esconde a tabela.
- Horas de linha ja gravada no link nao recotam o unitario. Descartado: buscar o preco novo do cadastro, porque isso mudaria um orcamento ja enviado. O recalculo publico continua recotando o unitario, como ja faz.
- O painel nao ganha input. Descartado: o mesmo campo na edicao autenticada, porque o request deixa essa duracao com o evento.

## Passada transversal

- architecture: nao ha fronteira nova. O contrato dos dois POST de criacao e do GET/PUT de servicos muda; o artefato canonico e esta spec, e o recorte por repo fica para `fw:split`.
- database: nao. Sem migration, indice ou retencao nova. A quantidade usa a coluna que ja existe.
- design: sim. Campo com rotulo visivel, teclado numerico, erro no submit ao lado do campo, valor preservado na falha.
- observability: nao. Sem metrica, dashboard ou alerta. O sinal e o historico da proposta e a mensagem HTTP.
- security: sim. Rota publica grava valor. As horas sao validadas no servidor, com teto, e o corpo nao aceita unitario nem valor da linha.
- patterns/rules/06: a selecao igual, com as mesmas horas, nao grava. Concorrencia fica com a ultima gravacao, sem lock novo. Sem fila, cache ou retry automatico.

## Riscos e mitigacoes

- Publicar o backend sem o frontend do painel faz a criacao de servico por hora falhar. Mitigacao: o mesmo lote leva os dois POST no frontend.
- O floor do painel divergir de `calcEventDuration` grava outra quantidade. Mitigacao: teste de pernoite e de mesma hora no frontend, com os mesmos instantes do teste da funcao.
- Recalculo antigo, se esquecido, troca as horas escolhidas. Mitigacao: `T-06` passa a quantidade gravada no mapa.

## Rollout, observabilidade e rollback

Sem migration. Rollback e reverter o lote. Orcamentos gravados com a quantidade escolhida continuam legiveis pela coluna que ja existia. Nao ha flag nem metrica nova.

## Estrategia de validacao

- unitario de `quoteServiceLines`, da criacao, da gravacao publica e do recalculo
- browser dos dois formularios publicos e do modal
- `npm test -- --run` no backend nos arquivos tocados
- `npm run lint` no frontend nos arquivos tocados

## Fontes determinantes

- `project-decisions.md` D-01, D-05, D-06 e D-07
- `product/02-business-rules.md#Proposal` e `product/03-user-profiles.md#Cliente proponente`
- `framework-libs/design/rules/06_forms_and_input_ux.md`
- `framework-libs/security/index.md#Quando esta lib e obrigatoria`
- `specs/2026-11-04-preco-foto-descricao-servico/03-design.md#Contratos e dados` para a conta que esta sendo especializada
- `specs/2026-11-04-adicionar-servico-proposta-publica/03-design.md#Contratos e dados` para o GET/PUT que ganha as horas
