# Design — Lista de servicos no painel

## Visao geral da solucao

O painel ganha um unico componente de lista, usado ao criar por pessoa, ao criar por dia e ao editar. A lista repete a regra do link publico: uma linha, texto de obrigatorio, checkbox travado no minimo e "Quantas horas?" a direita quando o servico por hora esta marcado. O envio usa as horas digitadas. A edicao passa a aceitar `serviceHours` do mesmo jeito que a criacao ja aceita.

## Componentes e modulos impactados

- `frontend`: componente novo `eventhub-vista-dashboard/src/components/proposal/DashboardServiceChoices.tsx`; `PerPersonProposalForm.tsx`; `PerDayProposalForm.tsx`; `ProposalEdit.tsx`; `UpdateProposalPerPersonDTO` em `types/proposal.ts`
- `backend`: Zod e use cases `update-proposal-per-person` e `update-proposal-per-day`; o teste que hoje espera a edicao sem `serviceHours` em `create-proposal-per-person.spec.ts`
- produto: `product/02-business-rules.md#Proposal`

## Reuso previsto

- `chosenServiceHours`, `serviceHourFieldError`, `sameDayEventHours` e `stayEventHours` em `event-duration.ts`
- `serviceUnitLabel` para o preco que permanece na linha
- a juncao de obrigatorios do link publico: os ids exigidos pelo numero de convidados entram na selecao; o que a pessoa marcou e nao e obrigatorio permanece
- `assertChosenServiceHours`, `serviceHoursMap` e `quoteServiceLines` com `hoursByServiceId`, como a criacao ja faz
- os formularios publicos nao sao extraidos nem alterados; eles sao so o modelo

## Contratos e dados

`serviceHours` continua `{ serviceId, hours }`, no maximo 100 itens, `hours` inteiro de 0 a 8760. Nao ha coluna nova. A quantidade vai para `ProposalService.quantity`.

`PUT /updatePerPerson` e `PUT /updatePerDay` ganham o mesmo campo opcional do Zod da criacao. O use case monta o mapa, chama `assertChosenServiceHours` com a duracao ja calculada para a cotacao e passa `hoursByServiceId` no unico `quoteServiceLines` que roda antes dos ramos de tipo, inclusive permuta. Servico por hora selecionado sem item valido responde o erro da criacao e nao grava. Sem o mapa, a quantidade nao volta a ser a duracao do evento.

A criacao nao muda de contrato. `PerPersonProposalForm` e `PerDayProposalForm` deixam de chamar `durationServiceHours`.

No pernoite, o teto do formulario e `stayEventHours` com check-in e check-out do espaco, fallback `14:00` e `12:00`. No evento e na edicao, o teto e `sameDayEventHours`.

A edicao preenche o campo com `proposalServices.quantity` quando a linha e `PER_HOUR` e a quantidade e um inteiro. Isso acontece ao carregar o orcamento, nao a cada tecla.

## Falhas, casos de borda e invariantes

- O input fica fora do `label` do checkbox.
- Desmarcar apaga as horas daquele id. Marcar de novo abre vazio.
- Obrigatorio que entra porque os convidados subiram abre o campo vazio.
- Convidados abaixo do minimo destravam o checkbox e nao o desmarcam.
- Campo vazio so vira erro no envio. Inteiro acima da duracao mostra a frase na hora. Falha HTTP nao limpa o texto.
- So abrir a edicao nao chama update.
- Servico fixo sem `serviceHours` continua gravando quantidade 1.

## Decisoes arquiteturais importantes

- Um componente so no painel. Descartado: copiar o JSX nas tres telas, porque as tres desviariam. Descartado: reutilizar o JSX publico, porque ele esconde o preco e abre foto e descricao.
- A edicao exige o mapa para todo `PER_HOUR`, como a criacao. Descartado: omitir e cair na duracao, porque e o comportamento que este pedido troca.
- `PUT /updatePerDay` entra no mesmo contrato. Descartado: mudar so a rota que a tela chama, porque a outra edicao continuaria cotando pela duracao.
- A quantidade reusa `ProposalService.quantity`. Descartado: coluna nova.
- O preco fica na linha do painel. Descartado: esconder, porque a entrada nao pediu isso.

## Passada transversal

- architecture: nao. Nao ha fronteira nova. O contrato dos dois PUT muda; o artefato canonico e esta spec, e o recorte por repo fica para `fw:split`.
- database: nao. Sem migration, indice ou retencao. A quantidade usa a coluna que ja existe.
- design: sim. Lista em coluna, rotulo visivel, teclado numerico, erro no campo, valor preservado na falha.
- observability: nao. Sem metrica, dashboard ou alerta. O sinal continua o historico do orcamento e a mensagem HTTP.
- security: sim. A edicao autenticada grava valor. As horas sao validadas no servidor. O corpo nao aceita unitario nem valor da linha. A permissao da tela nao muda.
- patterns/rules/06: nao ha gatilho novo. A ultima gravacao vale. Sem fila, cache, lock ou retry automatico.

## Riscos e mitigacoes

- Publicar o backend da edicao sem a tela faz salvar servico por hora falhar. Mitigacao: `T-01` e `T-03` saem no mesmo lote de deploy.
- O teto do pernoite divergir do check-in do espaco faz a API recusar uma hora que a tela aceitou. Mitigacao: `stayEventHours` com os mesmos fallbacks da criacao publica por dia.
- A juncao de obrigatorios apagar as horas ja preenchidas. Mitigacao: o efeito so mexe nos ids selecionados.

## Rollout, observabilidade e rollback

Sem migration. Rollback e reverter o lote. Linhas ja gravadas continuam legiveis. Nao ha flag nem metrica nova.

## Estrategia de validacao

- unitario dos dois use cases de edicao e do Zod que deixa de descartar `serviceHours`
- browser de criar por pessoa, criar por dia e editar
- `npm test -- --run` no backend nos arquivos tocados
- `npm run lint` no frontend nos arquivos tocados

## Fontes determinantes

- `project-decisions.md` D-01, D-06 e D-07
- `product/02-business-rules.md#Proposal`
- `framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
- `framework-libs/security/index.md#Quando esta lib e obrigatoria`
- `specs/2026-11-04-horas-servico-por-hora/03-design.md#Contratos e dados` para o contrato que a edicao passa a seguir
- `specs/2026-11-04-limite-horas-servico-duracao-evento/01-spec.md#Objetivos` para o teto pela duracao do evento
