# Design — Preco, foto e descricao do servico

## Visao geral da solucao

O cadastro ganha tipo de preco, descricao e uma URL de foto. Uma funcao unica monta a linha a partir do unitario, dos convidados e das horas do evento. Criar, editar e recalcular gravam essa linha em `ProposalService` e usam a soma no total. A pagina publica le a linha gravada para o dinheiro e o cadastro para foto, nome e descricao.

## Passada transversal

- architecture: nao. Continua no monolito Express. O contrato entre painel, API e pagina publica muda; nao pede ADR.
- database: sim. Colunas aditivas em `service` e `proposalService`. Sem indice novo e sem expurgo.
- design: sim. Formulario de servico, marcacao no orcamento e dois blocos da pagina publica. Sem tela nova e sem token novo.
- observability: nao. Nao ha fluxo operacional novo alem do cadastro e do orcamento que ja existem. A recusa de permissao reusa o log das regras.
- security: sim. Escrita do servico passa a exigir `EDIT_VENUE_SERVICES`. Upload de imagem e valor do orcamento. A listagem publica nao e fechada.
- patterns/rules/06: sim, consistencia. Total e linhas commitam na mesma transacao. Recalcular e deterministico: a mesma entrada regrava as mesmas linhas. Nao ha fila, cache nem retry externo.

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: `Service` e `ProposalService`
- `art56_server_v3/src/repositories/in-prisma/service-in-prisma-repository.ts`: a soma `_sum.price` deixa de ser a formula
- `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts`: `createPerPerson`, `createPerDay`, `update` e `updateServices` gravam a linha, nao so o `serviceId`
- use cases de orcamento que hoje chamam `getByProposalServiceListTotalAmount`: criar e editar por pessoa, criar e editar por dia, recalcular o link publico
- `art56_server_v3/src/router/service.ts` e os use cases de criar, atualizar e apagar servico
- `eventhub-vista-dashboard`: `service-form`, `service-list`, tipos e servico HTTP; marcacao em `PerPersonProposalForm`, `PerDayProposalForm`, `ClientPerPersonProposalForm`, `ClientPerDayProposalForm` e `ProposalEdit`; `ProposalServicesSummary`, `ProposalDetails` e `ProposalView`

## Reuso previsto

- `calcEventDuration` e a unica duracao. Nao criar outro jeito de contar hora.
- `VenueRuleAuthorizer` e o modelo da checagem. A permissao e `EDIT_VENUE_SERVICES`, nao uma permissao nova.
- Upload: `sharp` para WebP a 1200 px e qualidade 80, `s3Client` e a URL publica `https://{bucket}.s3.{region}.amazonaws.com/{key}`, como em `use-cases/image/create-image`. A foto nao cria linha em `Image`.
- Apagar objeto antigo: so se a URL for daquele bucket, no mesmo cuidado de `use-cases/image/update-image`. Falha ao apagar o arquivo antigo nao desfaz a gravacao do servico.
- Zod nos dois repositorios. Estado do painel continua no store de servico que ja existe.

## Contratos e dados

`Service`, migration aditiva:

- `pricingType` enum `FIXED | PER_HOUR | PER_PERSON`, default `FIXED`
- `description` opcional, no maximo 500 caracteres; vazio vira nulo
- `imageUrl` opcional
- `price` continua Float e passa a ser o unitario; aceita zero; recusa negativo

`ProposalService`, colunas novas todas opcionais, para o codigo antigo conviver:

- `pricingType`, `unitPrice`, `quantity`, `amount`
- `quantity` e inteira: 1 no fixo, horas no por hora, convidados no por pessoa
- `amount` e `unitPrice * quantity`

Formula, num unico lugar:

- `FIXED`: quantidade 1, valor `price`
- `PER_HOUR`: quantidade `calcEventDuration(start, end)`, valor `price * quantidade`
- `PER_PERSON`: quantidade `guestNumber`, valor `price * quantidade`

A funcao recebe os servicos ja filtrados pelo `venueId` do orcamento. Se algum id pedido nao pertence a esse espaco, a gravacao falha e o orcamento nao e salvo. A soma das linhas substitui `_sum.price` em todos os chamadores. O preco minimo continua em `applyMinimum`: troca a base e zera hora extra da locacao; os servicos permanecem na soma.

Ordem: primeiro inicio e fim, depois a duracao, depois as linhas, depois o total. Hoje varios use cases somam o servico antes de montar as datas; essa ordem muda.

Quando o total do orcamento e gravado, as linhas dos servicos ligados sao regravadas na mesma `prisma.$transaction`, inclusive as que ja estavam ligadas. Nao basta incluir so o id novo: convidados e horas mudam a quantidade. Recalcular o link nao recebe lista de servicos; relê os ids ligados, busca o unitario atual do cadastro e regrava tipo, unitario, quantidade e valor.

Orcamento sem `amount` na linha e anterior a esta feature. A leitura trata como linha fixa de `service.price`, quantidade 1, sem conta de multiplicacao.

Foto e descricao nao sao copiadas para `ProposalService`.

API de servico:

- criar e atualizar aceitam os campos novos. A foto vai em `multipart`, campo de arquivo, nas rotas que ja exigem autenticacao. Sem arquivo, a atualizacao mantem a URL. Um campo explicito remove a foto.
- limite 5 MB e tipo de imagem antes do `sharp`. `sharp` que falha responde 400 e nao grava URL.
- criar, atualizar e apagar chamam o authorizer com `EDIT_VENUE_SERVICES` no `venueId` do servico.
- `GET /service/list` permanece sem autenticacao e pode devolver tipo, descricao, foto e preco. O formulario publico ja mostra o preco.

Pagina publica, dados que `getById` ja inclui (`proposalServices.service`):

- experiencia: `imageUrl`, `name`, `description` do cadastro
- investimento: `amount` gravado, ou `service.price` se `amount` for nulo; quando houver quantidade gravada e o tipo nao for fixo, mostrar unitario vezes quantidade

## Falhas, casos de borda e invariantes

- Invariante: a soma dos `amount` gravados naquele save e o `totalAmountService` que entrou no total. Na permuta o total continua 0; as linhas nao passam a compor esse total.
- Duracao 0: linha por hora vale 0.
- Servico ligado some por cascata se o cadastro for apagado. O total antigo fica como esta ate o proximo save, igual ao comportamento atual.
- Nome duplicado no espaco continua 409.
- Usuario de outro espaco, mesmo com `EDIT_VENUE_SERVICES` la, recebe 403 neste espaco.

## Decisoes arquiteturais importantes

- A linha de dinheiro fica em `ProposalService`, nao num calculo ao vivo do `price`. Alternativa descartada: multiplicar na leitura. Ela mudaria orcamento ja enviado quando o cadastro mudasse.
- Foto e descricao ficam so em `Service`. Alternativa descartada: copiar os dois para o orcamento. A premissa e que a ilustracao pode acompanhar o cadastro.
- Uma coluna `imageUrl` no servico, nao uma linha na galeria. Alternativa descartada: reusar `Image`. Essa galeria tem ordem e visibilidade da casa.
- Sem tipo por diaria. Alternativa descartada: quarto `pricingType`. O pedido nao inclui diaria, e a hora ja cobre o intervalo do evento.
- Nao fechar `GET /service/list`. Alternativa descartada: exigir `VIEW_VENUE_SERVICES`. O formulario publico depende dessa lista.

## Riscos e mitigacoes

- Use cases de orcamento somam o servico cedo e em varios ramos. Mitigacao: uma funcao de linha e teste em cada ramo que grava total, nao uma soma local.
- Deploy do backend antes do frontend: colunas novas tem default ou nulo; o painel antigo ignora tipo e segue mostrando `price`. Deploy do frontend antes do backend quebra o formulario se ele exigir `pricingType`. Mitigacao: backend primeiro (`T-01` a `T-03`), telas depois.
- URL de foto longa. Mitigacao: coluna de texto, no tamanho que `Payment.imageUrl` ja usa, nao um varchar curto.

## Rollout, observabilidade e rollback

- Migration so adiciona enum, colunas nulas e default. Sem backfill. Producao: `prisma migrate deploy`.
- Rollback da aplicacao: codigo antigo ignora as colunas. Nao remover colunas no mesmo release.
- Sem dashboard novo. Prova e teste mais a tela.

## Estrategia de validacao

- Unitario da formula: fixo, hora, pessoa, duracao 0, pernoite, id de outro espaco, preco zero e preco negativo.
- Unitario dos fluxos que gravam orcamento: a linha persistida bate com a soma usada no total; recalcular de novo nao muda o resultado; editar o cadastro sem save nao muda a linha.
- Unitario da API de servico: 403 sem permissao, 400 para arquivo invalido e descricao longa, foto nao cai na galeria.
- Painel e pagina publica, na execucao das tasks de tela: tres tipos, sem foto, e orcamento antigo sem `amount`.

## Fontes determinantes

- `product/02-business-rules.md`: nome unico do servico e a regra de acesso desejada
- `product/08-data-model.md`: Float e `ProposalService.teste` fora desta mudanca
- `topics/data-and-migrations.md`: migration aditiva e transacao quando ha mais de uma escrita
- `project-decisions.md` D-06 e D-07
- `framework-libs/database/skills/writing-zero-downtime-migrations.md`: coluna nova nula ou com default e mudanca compativel
- `framework-libs/security/index.md` e `framework-libs/aws/index.md`: upload e S3; o caminho implementado continua o bucket publico ja usado pela galeria, nao o upload privado dessas libs
- codigo: `service-in-prisma-repository.ts`, `proposal-in-prisma-repository.ts`, `calc-event-duration.ts`, `router/service.ts`, `venue-rule-authorizer.ts`, `controller-create-image.ts`
