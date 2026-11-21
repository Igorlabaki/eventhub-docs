# Tasks — Cortesia de servicos no orcamento

## Ordem macro

1. `T-01`: coluna no schema, migration e deploy request. O codigo vem primeiro; aplicar na `main` exige aprovacao.
2. `T-02`: regra na cotacao. Pode rodar em paralelo com `T-01`.
3. `T-03`: criacao com cortesia e permissao. Depende de `T-01` (codigo) e `T-02`.
4. `T-04`: edicao e cotacao. Depende de `T-03`, que cria o ramo de autorizacao e o `serviceLineRows`.
5. `T-05`: link publico e recalculo. Depende de `T-01` e `T-02`. Pode rodar em paralelo com `T-03` e `T-04`.
6. `T-06`: campos no painel. Depende de `T-03` e `T-04`.
7. `T-07`: exibicao e docs. Depende de `T-05`. Pode rodar em paralelo com `T-06`.

Deploy: `T-01` na `main`, depois a API (`T-02` a `T-05`), depois o frontend (`T-06` e `T-07`).

## Tasks

### T-01 - Coluna courtesyQuantity e deploy request

- objetivo: `proposalService.courtesyQuantity` existe no schema Prisma, na migration versionada e na `main`.
- cobre requisitos: `R-01`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`
- reusa: o fluxo de branch e deploy request de `project/planetscale.md`
- prompt recomendado: `normal`
- estrategia de teste: `npx prisma validate`; `SHOW COLUMNS` na branch e depois na `main`
- cenarios obrigatorios:
  - `schema.prisma` com `courtesyQuantity Int @default(0)` em `ProposalService`;
  - `migration.sql` com o `ALTER TABLE` aditivo;
  - branch criada a partir da `main`, DDL aplicada nela e deploy request aberto;
  - o deploy request so e aplicado com aprovacao nomeada;
  - leitura de volta mostra a coluna `int NOT NULL DEFAULT 0`.
- definition of done:
  - validate verde;
  - deploy request `complete` na `main`, com numero registrado em `05-state.md` e `project/planetscale.md`;
  - `product/08-data-model.md` com o campo.

#### Context Pack

- frente principal: banco
- superficie sensivel: sim — DDL em producao
- risco principal: API nova no ar sem a coluna, ou DDL direto na `main`
- repos tocados: `backend` (`art56_server_v3/`), PlanetScale `ar756`
- fora de escopo desta task: codigo de calculo, use cases e tela
- prova minima desta task: `pscale sql ar756 main --org igorlabakig --format json --query "SHOW COLUMNS FROM proposalService LIKE 'courtesyQuantity'"` devolve a coluna
- criterio de escalada: qualquer DDL que nao seja `ADD COLUMN` com default, ou falha do deploy request, faz parar e reportar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`
- documentos obrigatorios:
  - `.cursor/framework_core/project/planetscale.md#Fluxo real de schema`
  - `.cursor/framework_core/project/planetscale.md#Permissoes do agente`
  - `.cursor/framework_global/framework-libs/database/index.md`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma`, `art56_server_v3/prisma/migrations/20261109190000_add_proposal_event_category/migration.sql` (modelo)
- palavras-chave ou simbolos de busca: `model ProposalService`, `proposalService`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: use cases, frontend, `topics/` alem do data model

### T-02 - Cortesia na cotacao das linhas

- objetivo: `quoteServiceLines` desconta a cortesia, com validacao estrita ou reducao, e devolve `courtesyQuantity` em cada linha.
- cobre requisitos: `R-02`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`
- reusa: `quantityFor`, o formato de `serviceHoursMap` e `HttpBadRequestError`
- prompt recomendado: `smart`
- estrategia de teste: unitario da funcao
- cenarios obrigatorios:
  - 6h com 2 de cortesia vale `unitPrice x 4`;
  - 100 pessoas com 10 vale `x 90`;
  - `FIXED` com 1 vale 0;
  - `FIXED` com 2, valor negativo, valor fracionado e valor acima da quantidade lancam `COURTESY_MESSAGE` em `strict`;
  - `clamp` com 5 de cortesia e 3 horas grava cortesia 3 e valor 0;
  - id repetido em `serviceCourtesyMap` lanca erro; item de servico nao selecionado e ignorado;
  - sem mapa, tudo igual a hoje, com `courtesyQuantity` 0.
- definition of done: os cenarios passam em `quote-service-lines.spec.ts`; `hasCourtesy` exportado.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — valor da linha
- risco principal: valor negativo ou cortesia acima da quantidade passar
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: Zod, use cases, repositorio e tela
- prova minima desta task: o unitario espera `amount = 200` para 6h a R$ 50,00 com cortesia 2
- criterio de escalada: se `clamp` precisar saber algo alem da quantidade calculada, parar e revisar o design
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_core/project/project-decisions.md#D-07 Dinheiro em Float no legado`
- caminhos candidatos: `art56_server_v3/src/functions/quote-service-lines.ts`, `art56_server_v3/src/functions/quote-service-lines.spec.ts`
- palavras-chave ou simbolos de busca: `quoteServiceLines`, `quantityFor`, `serviceHoursMap`, `ServiceQuoteLine`
- testes provaveis: `npm test -- --run src/functions/quote-service-lines.spec.ts`
- nao ler por padrao: use cases, tela, `security`

### T-03 - Criacao com cortesia e permissao no espaco

- objetivo: os dois POST de criacao gravam a cortesia quando o usuario do token tem permissao, e recusam sem gravar quando nao tem.
- cobre requisitos: `R-03`, `R-04`
- depende de: `T-01` (codigo do schema), `T-02`
- pode rodar em paralelo com: `T-05`
- reusa: `ProposalQuoteAuthorizer`, `readOptionalUserId` e `serviceLineRows`
- prompt recomendado: `normal`
- estrategia de teste: unitario dos dois use cases de criacao
- cenarios obrigatorios:
  - com permissao, cortesia 2 em `PER_HOUR` grava `courtesyQuantity` 2 e o total cai `2 x unitario`;
  - sem `authUserId` e com cortesia: 401 e `create` nao e chamado;
  - com token sem permissao: 403 e `create` nao e chamado;
  - `userId` do corpo com permissao, mas token de outro usuario: 403;
  - sem `serviceCourtesy`, ou so com zeros, cria igual a hoje, sem chamar o autorizador;
  - permuta com cortesia grava a cortesia e total 0;
  - total manual com cortesia mantem o total digitado.
- definition of done:
  - os cenarios passam nos specs de criacao;
  - `serviceLineRows` grava a cortesia;
  - controllers passam `authUserId`;
  - Zod com `serviceCourtesy`.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — POST publico que passa a aceitar um campo que reduz valor
- risco principal: cliente anonimo ou forjando `userId` gravar cortesia
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: edicao, cotacao, link publico, tela e o `safeParse` descartado do controller (so registrar)
- prova minima desta task: o unitario sem token e com cortesia espera 401 e nenhuma chamada a `create`
- criterio de escalada: se o formulario publico passar a enviar `Authorization` com token de cliente, ou se o autorizador exigir outra permissao, parar e revisar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/project/project-decisions.md#D-05 Autorizacao parcialmente client-side`
- caminhos candidatos:
  - `art56_server_v3/src/use-cases/proposal/create-proposal-per-person/`;
  - `art56_server_v3/src/use-cases/proposal/create-proposal-per-day/`;
  - `art56_server_v3/src/use-cases/proposal/proposal-quote-authorizer.ts`;
  - `art56_server_v3/src/middleware/ensureAuthenticate.ts`;
  - `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts`;
  - `art56_server_v3/src/zod/proposal/create-proposal-per-*-params-schema.ts`.
- palavras-chave ou simbolos de busca: `readOptionalUserId`, `ProposalQuoteAuthorizer`, `serviceLineRows`, `quoteServiceLines`, `totalAmountInput`
- testes provaveis: `npm test -- --run src/use-cases/proposal/create-proposal-per-person src/use-cases/proposal/create-proposal-per-day`
- nao ler por padrao: link publico, recalculo, frontend

### T-04 - Edicao e cotacao com cortesia

- objetivo: as duas edicoes regravam a cortesia enviada, conferindo permissao pelo token, e a cotacao devolve o total liquido.
- cobre requisitos: `R-05`, `R-06`
- depende de: `T-03`
- pode rodar em paralelo com: `T-05`
- reusa: o ramo de autorizacao de `T-03` e o `ProposalQuoteAuthorizer` que `quote` ja usa
- prompt recomendado: `normal`
- estrategia de teste: unitario das edicoes e da cotacao
- cenarios obrigatorios:
  - edicao com cortesia e permissao grava a cortesia;
  - edicao sem `serviceCourtesy` grava 0 nas linhas;
  - edicao com cortesia e token sem permissao responde 403 e nao chama `update`;
  - `quote` com 2h de cortesia reduz `totalAmountService` e `totalAmount`;
  - `quote` sem o campo continua igual.
- definition of done: os cenarios passam nos specs de `update-proposal-per-person`, `update-proposal-per-day` e `quote-proposal`; os controllers de edicao passam `req.user.id`.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — grava valor do orcamento
- risco principal: usar o `userId` do corpo para autorizar
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: fechar a falta de permissao por espaco na edicao sem cortesia; link publico; tela
- prova minima desta task: o unitario da edicao com cortesia e token sem permissao espera 403 sem `update`
- criterio de escalada: se a edicao por dia nao usar `quoteServiceLines` no mesmo ponto da edicao por pessoa, parar e mapear antes
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/project/project-decisions.md#D-05 Autorizacao parcialmente client-side`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/update-proposal-per-person/`, `art56_server_v3/src/use-cases/proposal/update-proposal-per-day/`, `art56_server_v3/src/use-cases/proposal/quote-proposal/`, `art56_server_v3/src/zod/proposal/update-proposal-per-*-params-schema.ts`, `art56_server_v3/src/zod/proposal/quote-proposal-schema.ts`
- palavras-chave ou simbolos de busca: `serviceHours`, `withLines`, `AuthenticatedRequest`, `authorizer.assert`
- testes provaveis: `npm test -- --run src/use-cases/proposal/update-proposal-per-person src/use-cases/proposal/update-proposal-per-day src/use-cases/proposal/quote-proposal`
- nao ler por padrao: criacao, link publico, frontend

### T-05 - Cortesia no link publico e no recalculo

- objetivo: as rotas publicas conservam a cortesia gravada, reduzem quando a quantidade cai, zeram em servico readicionado, ignoram cortesia no corpo e expoem `courtesyQuantity` e `courtesyAmount`.
- cobre requisitos: `R-07`, `R-08`
- depende de: `T-01` (codigo), `T-02`
- pode rodar em paralelo com: `T-03`, `T-04`
- reusa: `update-public-proposal-services`, `recalculate-public-proposal` e `quoteServiceLines` em `clamp`
- prompt recomendado: `normal`
- estrategia de teste: unitario dos dois use cases e do controller do PUT
- cenarios obrigatorios:
  - PUT mantem a cortesia 2 de uma linha `PER_HOUR` quando so outro servico muda;
  - reduzir de 6 para 1 hora grava cortesia 1 e valor 0;
  - remover e readicionar um `FIXED` com cortesia volta com cortesia 0 e valor cheio;
  - corpo com `serviceCourtesy` nao altera nada;
  - GET e PUT trazem `courtesyQuantity` e `courtesyAmount`, sem `unitPrice`;
  - recalculo de 100 para 5 convidados com cortesia 10 em `PER_PERSON` grava cortesia 5 e valor 0;
  - recalculo sem cortesia continua igual.
- definition of done: os cenarios passam nos specs de `update-public-proposal-services` e `recalculate-public-proposal`.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — rotas publicas que regravam valor
- risco principal: cortesia criada ou ressuscitada pelo cliente, ou erro 400 para o cliente por cortesia acima da quantidade
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: fluxos do dono, tela e regra de obrigatorio
- prova minima desta task: o unitario do PUT com 1 hora espera `courtesyQuantity` 1 e `amount` 0 na linha gravada
- criterio de escalada: se a resposta publica precisar de `unitPrice` para a tela, parar; o contrato e `courtesyAmount`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/update-public-proposal-services/use-case-update-public-proposal-services.ts`, `art56_server_v3/src/use-cases/proposal/recalculate-public-proposal/use-case-recalculate-public-proposal.ts`, `art56_server_v3/src/zod/proposal/update-public-proposal-services-schema.ts`
- palavras-chave ou simbolos de busca: `resolvePublicHours`, `hoursUnchanged`, `visibleStored`, `storedLines`, `hoursByServiceId`
- testes provaveis: `npm test -- --run src/use-cases/proposal/update-public-proposal-services src/use-cases/proposal/recalculate-public-proposal`
- nao ler por padrao: criacao, edicao, frontend

### T-06 - Campos de cortesia no painel

- objetivo: criar e editar orcamento no painel deixa informar a cortesia por servico marcado, valida o limite e envia `serviceCourtesy`, com o total estimado ja liquido.
- cobre requisitos: `R-09`, `R-10`
- depende de: `T-03`, `T-04`
- pode rodar em paralelo com: `T-07`
- reusa: `DashboardServiceChoices`, `chosenServiceHours` e `useProposalQuote`
- prompt recomendado: `normal`
- estrategia de teste: vitest de `chosenServiceCourtesy` e `courtesyFieldError`; browser do painel; lint
- cenarios obrigatorios:
  - `PER_HOUR` marcado mostra "Horas de cortesia";
  - `PER_PERSON` mostra "Pessoas de cortesia";
  - `FIXED` mostra o checkbox "Cortesia";
  - valor acima das horas ou dos convidados, negativo ou fracionado mostra erro no campo e nao envia;
  - desmarcar o servico apaga a cortesia;
  - o total estimado cai ao digitar a cortesia;
  - criar envia `serviceCourtesy`;
  - `ProposalEdit` abre com a cortesia gravada e reenvia ao salvar.
- definition of done:
  - os cenarios passam (vitest e browser);
  - os tipos e `proposal.service.ts` foram atualizados;
  - `npm run build` e lint sem erro novo nos arquivos tocados.

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — a autorizacao fica no backend (D-05)
- risco principal: o campo existir e o payload ou a cotacao nao levarem `serviceCourtesy`
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: formularios publicos, exibicao no detalhe e no link, modal publico
- prova minima desta task: no painel, criar com 2h de cortesia num servico de 6h mostra o total estimado menor e o POST leva `serviceCourtesy: [{ serviceId, quantity: 2 }]`
- criterio de escalada: se o total manual precisar recalcular sozinho com a cortesia, parar; a premissa e que o total digitado vence
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Falhas, casos de borda e invariantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/DashboardServiceChoices.tsx`, `src/components/proposal/forms/PerPersonProposalForm.tsx`, `src/components/proposal/forms/PerDayProposalForm.tsx`, `src/pages/ProposalEdit.tsx`, `src/lib/proposal-quote-input.ts`, `src/types/proposal.ts`, `src/services/proposal.service.ts`
- palavras-chave ou simbolos de busca: `serviceHoursInput`, `chosenServiceHours`, `useProposalQuote`, `onHoursChange`, `selectedServiceIds`
- testes provaveis: `npm test -- src/lib/service-courtesy.test.ts src/lib/proposal-quote-input.test.ts`
- nao ler por padrao: `ProposalView`, formularios publicos, `security`

### T-07 - Exibir a cortesia e atualizar docs

- objetivo: detalhe do painel, "Seu investimento" no link e modal "Alterar servicos" mostram valor cheio, cortesia e valor final; o link nao deriva unitario errado; os docs registram a regra e o contrato.
- cobre requisitos: `R-11`, `R-12`
- depende de: `T-05`
- pode rodar em paralelo com: `T-06`
- reusa: `quotedServiceDetail`, `quotedServiceAmount`, `publicHourlyRate` e `hourlyChoiceAmount`
- prompt recomendado: `normal`
- estrategia de teste: vitest de `courtesyLabel`, `courtesyAmount` e `fullServiceAmount`; browser do detalhe e do link; lint
- cenarios obrigatorios:
  - linha `PER_HOUR` com cortesia 2 mostra "R$ 50,00 × 6 h", "Cortesia: 2h (-R$ 100,00)" e R$ 200,00;
  - `FIXED` de cortesia mostra "Cortesia (-R$ 1.500,00)" e R$ 0,00;
  - linha sem cortesia fica como hoje;
  - o modal mostra a cortesia so para leitura e a previa por hora desconta a cortesia;
  - depois do PUT, o valor por hora da linha continua o unitario, nao `amount / horas`.
- definition of done:
  - os cenarios passam (vitest e browser);
  - docs atualizados: `topics/pricing-and-proposal-calculation.md#Servicos`, `project/api-endpoints.md` (cinco corpos e duas respostas publicas) e `product/02-business-rules.md#Precificacao`;
  - lint sem erro novo.

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o valor por hora derivado do valor liquido no link, ou a cortesia aparecendo no painel sem `hasViewValuesPermission`
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `eventhub-docs`
- fora de escopo desta task: formularios de criar, contrato em PDF e relatorios
- prova minima desta task: no link de um orcamento com 2h de cortesia, "Seu investimento" mostra a linha de cortesia e o total bate com a soma
- criterio de escalada: se a resposta publica nao trouxer `courtesyAmount`, parar e voltar a `T-05`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_core/topics/pricing-and-proposal-calculation.md#Servicos (quote-service-lines.ts)`
  - `.cursor/framework_core/project/api-endpoints.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/ProposalServicesSummary.tsx`, `src/pages/ProposalView.tsx` (`applyPublicServices`, `hourlyRatesForChoices`, "Seu investimento"), `src/components/proposal/UpdateProposalServicesDialog.tsx`, `src/lib/service-price-label.ts`
- palavras-chave ou simbolos de busca: `quotedServiceDetail`, `quotedServiceAmount`, `applyPublicServices`, `publicHourlyRate`, `hourlyChoiceAmount`
- testes provaveis: `npm test -- src/lib/service-courtesy.test.ts src/lib/service-price-label.test.ts`
- nao ler por padrao: formularios de criar, backend, `security`
