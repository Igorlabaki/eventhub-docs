# Spec — Cortesia de servicos no orcamento

## Problema

Para dar algo de graca, o dono hoje zera o preco do servico no catalogo, o que vale para todos os orcamentos, ou digita um total manual, que esconde o que foi dado. `ProposalService` grava `pricingType`, `unitPrice`, `quantity` e `amount`, mas nada diz que parte da quantidade e cortesia.

## Objetivos

Em cada orcamento, o dono informa a cortesia de um servico selecionado:

- `PER_HOUR`: horas de cortesia;
- `PER_PERSON`: pessoas de cortesia;
- `FIXED`: o servico inteiro.

A linha cobra `unitPrice x (quantity - courtesyQuantity)`. Painel e link publico mostram valor cheio, cortesia e valor final. Pelas rotas publicas, o cliente nao cria nem aumenta cortesia.

## Fora de escopo

- cortesia definida no catalogo (`Service` nao muda)
- desconto em R$ ou % na linha; cortesia na locacao, nas horas extras ou no piso minimo
- formularios publicos de criar orcamento (`ClientPerPersonProposalForm`, `ClientPerDayProposalForm`)
- contrato em PDF, relatorios de receita e metas
- trocar `Float` do dinheiro (D-07)
- fechar a lacuna atual de permissao por espaco em `updatePerPerson`, `updatePerDay` e na criacao por dia, alem do que a cortesia exige

## User stories ou cenarios principais

- O dono cria um orcamento com "Garcom (R$ 50,00/hora)", 6 horas, e informa 2 horas de cortesia. A linha fica com quantidade 6, cortesia 2 e valor R$ 200,00. O total estimado cai R$ 100,00.
- No mesmo orcamento, "Buffet (R$ 80,00/pessoa)" para 100 pessoas com 10 de cortesia vale R$ 7.200,00. "DJ (R$ 1.500,00)" marcado como cortesia vale R$ 0,00.
- A cliente abre o link e ve "Garcom — R$ 50,00 x 6h", "Cortesia: 2h (-R$ 100,00)" e R$ 200,00. Ela reduz para 1 hora: a cortesia vira 1 e a linha vale R$ 0,00.
- Ela remove o DJ e adiciona de novo. O DJ volta cobrando R$ 1.500,00, sem cortesia.

## Criterios de aceite

- `R-01`: `ProposalService` ganha `courtesyQuantity Int @default(0)`. Orcamentos ja gravados ficam com 0 e nenhum valor muda.
- `R-02`: `quoteServiceLines` aceita cortesia por servico.
  - Limites: inteiro de 0 ate a quantidade da linha. No `FIXED` isso significa 0 ou 1. No `PER_HOUR`, ate as horas escolhidas, ou ate a duracao quando nao ha escolha. No `PER_PERSON`, ate os convidados.
  - `amount = unitPrice x (quantity - courtesyQuantity)`.
  - Fora do limite responde 400 com "Informe uma cortesia inteira, de 0 até a quantidade do serviço." e nao devolve linha.
  - Id repetido em `serviceCourtesy` responde o mesmo erro.
  - Item de servico nao selecionado e ignorado.
- `R-03`: `POST /proposal/createPerPerson` e `POST /proposal/createPerDay` aceitam `serviceCourtesy: [{ serviceId, quantity }]`.
  - Com permissao, grava `courtesyQuantity` na linha.
  - O total sai do pipeline atual somando os servicos ja liquidos, inclusive com o piso minimo.
- `R-04`: na criacao, `serviceCourtesy` com alguma quantidade acima de 0 exige token valido de usuario com `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` no espaco.
  - Sem token: 401. Sem permissao: 403. Em ambos os casos nada e gravado.
  - O formulario publico, que nao envia o campo, continua criando igual.
- `R-05`: `PUT /proposal/updatePerPerson` e `PUT /proposal/updatePerDay` aceitam `serviceCourtesy`, que e a fonte da verdade da edicao: ausente significa 0 em todas as linhas.
  - Cortesia acima de 0 exige a mesma permissao de `R-04`, conferida pelo usuario do token e nao pelo `userId` do corpo.
- `R-06`: `POST /proposal/quote` aceita `serviceCourtesy`. `totalAmountService` e `totalAmount` saem liquidos.
- `R-07`: `PUT /proposal/presentation/:proposalId/services` nunca le cortesia do corpo.
  - Linha ja gravada conserva `courtesyQuantity`.
  - Servico novo, ou removido e adicionado de novo na mesma ou em outra chamada, entra com 0.
  - Se as horas de um `PER_HOUR` caem abaixo da cortesia, a cortesia vira as horas novas e o valor e recalculado pelo unitario gravado.
  - A resposta e o `GET` da mesma rota trazem `courtesyQuantity` e `courtesyAmount` por item, sem `unitPrice` nem `pricingType`.
- `R-08`: `PUT /proposal/presentation/:proposalId/recalculate` conserva a cortesia gravada. Se os convidados novos ficam abaixo da cortesia de um `PER_PERSON`, ela vira o numero de convidados. O corpo nao aceita cortesia.
- `R-09`: nos formularios de criar do painel (por pessoa e por dia), servico marcado mostra o campo de cortesia:
  - `PER_HOUR`: "Horas de cortesia";
  - `PER_PERSON`: "Pessoas de cortesia";
  - `FIXED`: checkbox "Cortesia".
  - Valor invalido mostra o erro no campo e nao envia.
  - Desmarcar o servico apaga a cortesia dele.
  - O total estimado ja desconta a cortesia.
- `R-10`: `ProposalEdit` abre com a cortesia gravada em cada linha e reenvia `serviceCourtesy` ao salvar.
- `R-11`: `ProposalServicesSummary` (detalhes do painel) e "Seu investimento" em `ProposalView` (link) mostram, em linha com cortesia:
  - o detalhe do valor cheio;
  - "Cortesia: 2h (-R$ 100,00)", "Cortesia: 10 pessoas (-R$ ...)" ou "Cortesia (-R$ ...)";
  - o valor final na coluna de valor.
  - Linha sem cortesia fica como hoje.
- `R-12`: no modal "Alterar servicos" do link, item com cortesia mostra a cortesia so para leitura.
  - A previa do valor por hora desconta a cortesia, limitada as horas digitadas.
  - Depois de gravar, a pagina nao deriva o unitario dividindo o valor liquido pelas horas.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership:
  - cortesia so com permissao de orcamentos no espaco, pelo `ProposalQuoteAuthorizer` ja usado em `/quote`;
  - as rotas publicas do link nao aceitam cortesia;
  - o corpo nunca envia unitario nem valor da linha.
- erros e mensagens esperadas:
  - validacao: "Informe uma cortesia inteira, de 0 até a quantidade do serviço.";
  - permissao: "Você não tem permissão para dar cortesia neste espaço.".
- observabilidade minima: `console.error` com `userId` e `venueId` quando a cortesia e negada, como o autorizador ja faz. Sem metrica nova.
- concorrencia, idempotencia ou retry: sem mudanca. Ultima gravacao vence. Selecao publica repetida continua sem gravar.
- rollout, fallback ou degradacao:
  - ordem de deploy: banco, depois backend, depois frontend;
  - backend sem `serviceCourtesy` no corpo se comporta como hoje.

## Casos de erro e borda obrigatorios

- caso: cortesia negativa, fracionada, acima da quantidade, `FIXED` com 2, id repetido
  - impacto: linha errada ou negativa
  - cobertura esperada: unitario de `quote-service-lines`
- caso: cortesia total
  - impacto: a linha vale 0 e continua listada
  - cobertura esperada: unitario e browser do link
- caso: criacao com cortesia sem token, com token sem permissao, ou com `userId` forjado no corpo
  - impacto: cliente se dando desconto
  - cobertura esperada: unitario dos dois use cases de criacao
- caso: edicao sem `serviceCourtesy`
  - impacto: a cortesia some, conforme a decisao
  - cobertura esperada: unitario da edicao
- caso: link reduz horas abaixo da cortesia; recalculo reduz convidados abaixo da cortesia
  - impacto: valor negativo ou erro 400 no cliente
  - cobertura esperada: unitario do link e do recalculo
- caso: remover e readicionar no link; corpo publico com `serviceCourtesy`
  - impacto: cortesia volta ou e criada pelo cliente
  - cobertura esperada: unitario do link
- caso: total manual (`totalAmountInput`) com cortesia
  - impacto: o total digitado vence e a base absorve a diferenca
  - cobertura esperada: unitario da criacao por pessoa
- caso: permuta com cortesia
  - impacto: total continua 0 e as linhas guardam a cortesia
  - cobertura esperada: unitario da criacao

## Impacto esperado

O dono passa a registrar presentes comerciais por servico, sem mexer no catalogo. O cliente enxerga o que ganhou. A receita aprovada (`totalAmount`) ja sai liquida e os relatorios nao mudam.

## Areas impactadas

- `backend`:
  - `quote-service-lines.ts`;
  - Zod e use cases de criar e editar (por pessoa e por dia) e de `quote`;
  - controllers de criar e editar;
  - `update-public-proposal-services` e `recalculate-public-proposal`;
  - `serviceLineRows` no repositorio;
  - `schema.prisma` e uma migration.
- `frontend`:
  - `DashboardServiceChoices`, `PerPersonProposalForm`, `PerDayProposalForm` e `ProposalEdit`;
  - `proposal-quote-input`, `service-price-label` e helper novo de rotulo da cortesia;
  - `ProposalServicesSummary`, `ProposalView` e `UpdateProposalServicesDialog`;
  - tipos e `proposal.service.ts`.
- banco: `proposalService.courtesyQuantity` na `main` via deploy request.
- docs:
  - `topics/pricing-and-proposal-calculation.md`;
  - `project/api-endpoints.md`;
  - `product/08-data-model.md`;
  - `product/02-business-rules.md#Precificacao`.

## Restricoes e cuidados

- D-05: a tela nao substitui a autorizacao da API
- D-07: dinheiro continua `Float`; sem arredondamento novo
- D-09: DDL so por branch e deploy request; aplicar na `main` exige aprovacao nomeada
- o controller de `createPerPerson` descarta o `safeParse`, entao o use case valida `serviceCourtesy` por conta propria
- nao ler nem versionar `.env`

## Dependencias

- linhas gravadas de `specs/2026-11-04-preco-foto-descricao-servico`
- `serviceHours` de `specs/2026-11-04-horas-servico-por-hora` como modelo de contrato
- GET e PUT do link de `specs/2026-11-04-adicionar-servico-proposta-publica`
- `POST /proposal/quote` e `ProposalQuoteAuthorizer` de `specs/2026-11-09-total-estimado-orcamento-painel`

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> `prisma validate` e `SHOW COLUMNS` na `main`
- `R-02` -> `T-02` -> unitario
- `R-03`, `R-04` -> `T-03` -> unitario
- `R-05`, `R-06` -> `T-04` -> unitario
- `R-07`, `R-08` -> `T-05` -> unitario
- `R-09`, `R-10` -> `T-06` -> vitest do helper e browser do painel
- `R-11`, `R-12` -> `T-07` -> vitest do helper e browser do painel e do link

## Perguntas em aberto

Nenhuma bloqueante. As premissas estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01` (e `T-02` em paralelo)
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
