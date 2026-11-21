# Solicitacao da Tarefa

## Nome sugerido da tarefa

Total estimado do orcamento enquanto o formulario e preenchido

## Resumo da solicitacao

Nos formularios do painel de criar e editar orcamento por pessoa, mostrar o total estimado (espaco + horas extras + servicos) e o detalhamento enquanto data, horario, convidados e servicos sao preenchidos. O valor vem de uma cotacao do backend que usa o mesmo calculo da gravacao, sem gravar nada.

## Context Pack

- frente principal: backend e frontend
- superficie sensivel: sim (sensivel financeiro; rota nova que expoe regra de preco, ajuste por meta derivado do faturamento do mes e preco minimo)
- camadas transversais: `security`, `design`, `patterns`
- risco principal: a estimativa divergir do valor que a gravacao salva; o calculo hoje esta repetido em `create-proposal-per-person`, `update-proposal-per-person` e `recalculate-public-proposal`
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: formularios publicos (`ClientPerPersonProposalForm`, `ClientPerDayProposalForm`); orcamento por diaria; mudar a regra de preco, de preco minimo, de meta ou de sazonalidade; preencher o Total automaticamente sem acao do usuario; schema e migration
- prova minima desta execucao: num espaco `PER_PERSON` sem meta ativa, criar orcamento com 100 convidados, horario na duracao padrao e um servico fixo mostra `Total estimado` = 100 x preco por pessoa + servico, com o detalhamento; mudar convidados atualiza em ate ~0,5 s sem salvar; salvar com o Total vazio grava exatamente o valor estimado; rota sem token responde 401; vitest da funcao de cotacao com os casos de borda e do caso de uso de criar continuando verde
- criterio de escalada: ja nasce candidato a `spec`
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/use-cases/proposal/recalculate-public-proposal/use-case-recalculate-public-proposal.ts` em `calculateAmounts`, `adjustUnitPrice`, `applyWallClockSeason` e `applyMinimum`; `art56_server_v3/src/use-cases/proposal/create-proposal-per-person/use-case-create-proposal-per-person.ts` nos blocos `PER_PERSON`, `PER_PERSON_HOUR` e `CUSTOM`; `art56_server_v3/src/router/proposal.ts`
- libs obrigatorias: `node`, `patterns`, `security`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/topics/backend-api.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
  - `.cursor/framework_core/specs/2026-11-04-recalcular-orcamento-proposta-publica/00-overview.md`
- caminhos candidatos: `art56_server_v3/src/functions/quote-service-lines.ts`; `art56_server_v3/src/functions/calc-custom-total-amount.ts`; `art56_server_v3/src/functions/resolve-minimum-price.ts`; `art56_server_v3/src/use-cases/proposal/update-proposal-per-person/use-case-update-proposal-per-person.ts` (regra de recalculo, linhas ~128 e ~218); `eventhub-vista-dashboard/src/components/proposal/forms/PerPersonProposalForm.tsx`; `eventhub-vista-dashboard/src/pages/ProposalEdit.tsx`; `eventhub-vista-dashboard/src/services/proposal.service.ts`; `eventhub-vista-dashboard/src/components/proposal/ProposalServicesSummary.tsx` como possivel modelo do detalhamento
- palavras-chave ou simbolos de busca: `calculateAmounts`, `applyMinimum`, `resolveVenueMinimumPrice`, `calcExtraHourPrice`, `calcExtraHoursQty`, `monthlyRevenueAnalysis`, `findByVenueAndRevenue`, `quoteServiceLines`, `sumServiceQuote`, `ensureAuthenticate`, `totalAmountInput`
- testes provaveis: `PER_PERSON` simples; `PER_PERSON_HOUR` com e sem faturamento no mes; taxa sazonal; meta com `increasePercent`; horas extras acima de `standardEventDuration`; total abaixo do minimo; permuta = 0; servico por pessoa, por hora e obrigatorio por `rpaMinPeople`; `TIERED` sem preco; mesmo resultado da cotacao e da gravacao com Total vazio
- nao ler por padrao: `database`, schema Prisma, formularios publicos, `topics/` fora de `backend-api`

## Contexto informado na entrada

Pedido em chat: "como poderiamos mostrar o valor que seria o total enquanto vamos preenchendo as informacoes", confirmado como "o total somando todo o orcamento, servicos e valor base". Na conversa ficou mapeado que o total do backend e `valor base + preco da hora extra x horas extras + servicos`, com preco minimo, permuta e Total digitado como excecoes, e que copiar esse calculo no front divergiria com o tempo.

## Problema atual

O formulario so sabe o total quando o usuario digita o campo Total. Com o campo vazio, o backend calcula na gravacao e quem preenche so ve o valor depois de salvar. Na edicao, o backend recalcula pelo catalogo apenas quando o Total enviado e igual ao salvo, regra que nao aparece na tela.

## Objetivo da mudanca

Com data, horarios e convidados preenchidos, o formulario do painel mostra `Total estimado` e o detalhamento (espaco, horas extras, servicos, aviso de preco minimo) vindos do backend, atualizado a cada mudanca e igual ao que seria gravado com o Total vazio.

## Escopo inicial percebido

- backend: extrair o calculo de valores para uma funcao compartilhada e expor uma rota autenticada de cotacao que nao grava; os casos de uso de criar, editar e recalcular publico passam a usar a mesma funcao
- frontend: chamada com debounce nos dois formularios do painel e um bloco de total estimado com detalhamento

## Itens incluidos neste request

- funcao compartilhada de cotacao (ex.: `quoteProposalAmounts`) com venue, datas, convidados, valor dos servicos e tipo; devolve `basePrice`, `extraHoursQty`, `extraHourPrice`, `totalAmountService`, `totalAmount` e se o minimo foi aplicado
- rota `POST /proposal/quote` (nome a confirmar) com `ensureAuthenticate`, corpo `venueId`, `date`, `startHour`, `endHour`, `guestNumber`, `serviceIds`, `serviceHours`, `type`, validado com zod
- checagem no backend de que o usuario tem acesso ao `venueId`
- `create-proposal-per-person`, `update-proposal-per-person` e `recalculate-public-proposal` usando a funcao compartilhada, sem mudar resultado
- frontend: servico `quoteProposal`, debounce de ~400 ms, bloco `Total estimado` com detalhamento e botao `Usar este valor` que preenche o campo Total
- na edicao, texto curto explicando que salvar sem alterar o Total recalcula para o valor estimado

## Requisitos implicitos ja visiveis

- total = valor base + preco da hora extra x horas extras + servicos
- valor base: convidados x preco por pessoa ajustado por sazonalidade e meta; em `PER_PERSON_HOUR` sem faturamento no mes, x duracao
- preco minimo: se o total ficar abaixo, espaco = minimo, horas extras zeradas, total = minimo + servicos
- permuta: total 0
- Total digitado continua sendo o total final com servicos incluidos; a estimativa nao o sobrescreve sozinha
- chamada so com data, horarios e convidados validos; mensagens de erro do backend nao travam o formulario

## Casos de erro e borda ja percebidos

- campos minimos incompletos: bloco mostra `—` sem chamar o backend
- espaco `TIERED` ou sem preco de catalogo: bloco explica que o espaco nao calcula sozinho
- horas do servico por hora invalidas: mesma mensagem de `assertChosenServiceHours`, sem estimativa
- respostas fora de ordem com digitacao rapida: vale so a ultima
- convidados acima de `maxGuest`: estimativa aparece; a validacao do campo continua
- erro de rede: bloco com aviso discreto; salvar continua possivel
- permuta selecionada: `R$ 0,00` sem chamar o backend ou com retorno 0

## Dependencias

- calculo atual em `recalculate-public-proposal` (o mais organizado dos tres) como base da extracao
- `tr-01` deste lote nao e pre-requisito

## Restricoes e cuidados

- nao mudar nenhum valor calculado hoje; a extracao e refatoracao com prova de igualdade nos specs existentes
- rota autenticada; nao reaproveitar a rota publica de recalculo, que grava
- nao expor faturamento do mes nem percentual de meta na resposta; so os valores finais
- nao criar terceira abordagem de estado no frontend
- preservar wall-clock nas datas da cotacao

## Perguntas em aberto

- A comparacao do minimo usa o total com servicos e depois soma os servicos de novo (`minimo + servicos`). E a regra desejada? Premissa: manter como esta; corrigir seria outro request.
- Quando o Total estiver vazio, o `/ pessoa` deve usar o total estimado? Premissa: sim, com o texto deixando claro que e estimativa.
- Vale para o orcamento por diaria? Premissa: nao nesta entrega.
- Vale para o formulario publico? Premissa: nao; exigiria rota publica e outro desenho de seguranca.
- `Usar este valor` na edicao transforma o total em valor digitado. Premissa: aceitar; o valor gravado fica igual ao estimado.
- Nome da rota? Premissa: `POST /proposal/quote`.

## Prioridade sugerida

Media. Ganho de leitura para quem monta o orcamento; nada quebra hoje.

## Faixa sugerida para task workflow

- `C` — rota nova, refatoracao do calculo em tres casos de uso e mudanca em dois formularios
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: dois repos, rota nova, extracao de regra de preco com prova de igualdade e ordem clara (funcao compartilhada, rota, formularios)

## Sugestao de slug da spec

- `framework_core/specs/2026-11-09-total-estimado-orcamento-painel/`

## Sugestao de nome do arquivo

- `tr-02-total-estimado-ao-preencher.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `spec`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-09-total-estimado-orcamento-painel/`
- entrada publica recomendada: `fw:review` na spec
- derivacao repo-local: na spec, com `spec-driven/spec-repo-split-prompt.md` (backend antes do frontend)
