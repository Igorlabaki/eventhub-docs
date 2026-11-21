# Tasks — Desconto em % no orcamento

## Ordem macro

1. `T-01`: colunas no schema, migration e deploy request. O codigo vem primeiro; aplicar na `main` exige aprovacao.
2. `T-02`: funcao do desconto e autorizacao. Pode rodar em paralelo com `T-01`.
3. `T-03`: criacao e edicao do dono. Depende de `T-01` (codigo) e `T-02`.
4. `T-04`: link publico e recalculo. Depende de `T-01` (codigo) e `T-02`. Pode rodar em paralelo com `T-03`.
5. `T-05`: campo no painel. Depende de `T-03`.
6. `T-06`: exibicao, aviso no link e docs. Depende de `T-04`. Pode rodar em paralelo com `T-05`.

Deploy: `T-01` na `main`, depois a API (`T-02` a `T-04`), depois o frontend (`T-05` e `T-06`).

## Tasks

### T-01 - Colunas discountPercent e discountAmount e deploy request

- objetivo: `proposal.discountPercent` e `proposal.discountAmount` existem no schema Prisma, na migration versionada e na `main`.
- cobre requisitos: `R-01`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`
- reusa: o fluxo de branch e deploy request de `project/planetscale.md`
- prompt recomendado: `normal`
- estrategia de teste: `npx prisma validate`; `SHOW COLUMNS` na branch e depois na `main`
- cenarios obrigatorios:
  - `schema.prisma` com `discountPercent Float @default(0)` e `discountAmount Float @default(0)` em `Proposal`;
  - `migration.sql` com os dois `ALTER TABLE` aditivos;
  - branch criada a partir da `main`, DDL aplicada nela e deploy request aberto;
  - o deploy request so e aplicado com aprovacao nomeada;
  - leitura de volta mostra as duas colunas `double NOT NULL DEFAULT 0`.
- definition of done:
  - validate verde;
  - deploy request `complete` na `main`, com numero registrado em `05-state.md` e `project/planetscale.md`;
  - `product/08-data-model.md` com os campos.

#### Context Pack

- frente principal: banco
- superficie sensivel: sim — DDL em producao
- risco principal: API nova no ar sem as colunas, ou DDL direto na `main`
- repos tocados: `backend` (`art56_server_v3/`), PlanetScale `ar756`
- fora de escopo desta task: funcao de desconto, use cases e tela
- prova minima desta task: `pscale sql ar756 main --org igorlabakig --format json --query "SHOW COLUMNS FROM proposal LIKE 'discount%'"` devolve as duas colunas
- criterio de escalada: qualquer DDL que nao seja `ADD COLUMN` com default, ou falha do deploy request, faz parar e reportar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`
- documentos obrigatorios:
  - `.cursor/framework_core/project/planetscale.md#Fluxo real de schema`
  - `.cursor/framework_core/project/planetscale.md#Permissoes do agente`
  - `.cursor/framework_global/framework-libs/database/index.md`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` (`model Proposal`), `art56_server_v3/prisma/migrations/20261110190000_add_proposal_service_courtesy/migration.sql` (modelo)
- palavras-chave ou simbolos de busca: `model Proposal`, `totalAmount`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: use cases, frontend, `topics/` alem do data model

### T-02 - Funcao do desconto e autorizacao

- objetivo: `applyProposalDiscount` e `discountPercentValue` fazem a conta e a validacao, e `assertDiscountAllowed` exige permissao no espaco para % acima de 0.
- cobre requisitos: `R-02`, `R-04`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`
- reusa: `HttpBadRequestError`, `ProposalQuoteAuthorizer.assert` com `PermissionDenial`, o formato de `assertCourtesyAllowed`
- prompt recomendado: `smart`
- estrategia de teste: unitario da funcao e do autorizador
- cenarios obrigatorios:
  - 5800 com 10% da `discountAmount` 580 e `totalAmount` 5220;
  - 999,99 com 7,5% da 75 e 924,99;
  - 100% da total 0 e `discountAmount` igual ao subtotal;
  - 0 e `undefined` dao `discountAmount` 0;
  - -1, 100,01, 10,123, `NaN` e texto lancam `DISCOUNT_MESSAGE`;
  - `assertDiscountAllowed` com 0 nao chama o autorizador; sem authorizer e com % acima de 0 lanca 403; com authorizer repassa `DISCOUNT_DENIAL`.
- definition of done: os cenarios passam em `proposal-discount.spec.ts` e no spec do autorizador; `NO_DISCOUNT` exportado.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — valor do orcamento e permissao
- risco principal: total negativo, % fora do limite passar, ou desconto sem permissao
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: Zod, use cases, repositorio e tela
- prova minima desta task: o unitario espera `{ discountPercent: 10, discountAmount: 580, totalAmount: 5220 }` para 5800 com 10%
- criterio de escalada: se o `round2` precisar de biblioteca decimal, parar; D-07 mantem `Float`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_core/project/project-decisions.md#D-07 Dinheiro em Float no legado`
- caminhos candidatos: `art56_server_v3/src/functions/proposal-discount.ts` (novo), `art56_server_v3/src/use-cases/proposal/proposal-quote-authorizer.ts`
- palavras-chave ou simbolos de busca: `assertCourtesyAllowed`, `COURTESY_DENIAL`, `PermissionDenial`
- testes provaveis: `npm test -- --run src/functions/proposal-discount.spec.ts src/use-cases/proposal/proposal-quote-authorizer`
- nao ler por padrao: use cases de criar e editar, link publico, frontend

### T-03 - Desconto na criacao e na edicao do dono

- objetivo: `createPerPerson` e `updatePerPerson` gravam a %, o valor e o total com desconto quando o usuario do token tem permissao; manual, permuta e `updatePerDay` gravam desconto 0.
- cobre requisitos: `R-03`, `R-05`, `R-06`
- depende de: `T-01` (codigo do schema), `T-02`
- pode rodar em paralelo com: `T-04`
- reusa: ramo automatico atual (`adjustVenueUnitPrice` + `calcProposalAmounts`), `assertDiscountAllowed`, `NO_QUOTE_MESSAGE`
- prompt recomendado: `normal`
- estrategia de teste: unitario dos use cases de criar por pessoa, editar por pessoa e editar por dia
- cenarios obrigatorios:
  - criar com 10% e permissao grava 10, 580 e 5220 (subtotal 5800), mesmo com `totalAmountInput` preenchido;
  - criar com 10% sem token: 401; token sem permissao ou `userId` forjado no corpo: 403; `create` nao e chamado;
  - criar com 10% em espaco sem preco de catalogo: 400;
  - criar com total manual ou permuta (mesmo com % no corpo) grava desconto 0;
  - editar com 10% forca o recalculo mesmo com Total diferente do gravado;
  - editar sem `discountPercent` grava desconto 0 e segue a regra atual do Total;
  - editar por dia grava desconto 0.
- definition of done:
  - os cenarios passam nos specs dos tres use cases;
  - Zod de criar e editar por pessoa com `discountPercent`;
  - tipos de criar e editar no repositorio com os dois campos.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — POST publico que passa a aceitar campo que reduz valor
- risco principal: cliente anonimo ou forjando `userId` gravar desconto; ramo manual deixar desconto antigo gravado
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: link publico, recalculo, `/quote`, tela e a falta antiga de permissao na edicao sem desconto
- prova minima desta task: o unitario de criar sem token e com 10% espera 401 e nenhuma chamada a `createPerPerson`
- criterio de escalada: se o formulario publico passar a enviar `Authorization` com token de cliente, ou se a edicao precisar autorizar por outro `venueId`, parar e revisar
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
  - `art56_server_v3/src/use-cases/proposal/create-proposal-per-person/use-case-create-proposal-per-person.ts`;
  - `art56_server_v3/src/use-cases/proposal/update-proposal-per-person/use-case-update-proposal-per-person.ts`;
  - `art56_server_v3/src/use-cases/proposal/update-proposal-per-day/use-case-update-proposal-per-day.ts`;
  - `art56_server_v3/src/zod/proposal/create-proposal-per-person-params-schema.ts`, `update-proposal-per-person-params-schema.ts`, `update-proposal-in-db-params-schema.ts`;
  - `art56_server_v3/src/repositories/interface/proposal-repository-interface.ts` (`CreateProposalInDbParams`).
- palavras-chave ou simbolos de busca: `totalAmountInput`, `hasCatalogPrice`, `calcCustomTotalAmount`, `assertCourtesyAllowed`, `withLines`
- testes provaveis: `npm test -- --run src/use-cases/proposal/create-proposal-per-person src/use-cases/proposal/update-proposal-per-person src/use-cases/proposal/update-proposal-per-day`
- nao ler por padrao: link publico, recalculo, frontend

### T-04 - Desconto no link publico e no recalculo

- objetivo: as rotas publicas mantem o desconto quando nada muda, zeram quando o cliente muda algo, nunca leem desconto do corpo e devolvem os dois campos.
- cobre requisitos: `R-07`, `R-08`
- depende de: `T-01` (codigo), `T-02`
- pode rodar em paralelo com: `T-03`
- reusa: `currentResponse`, `oldSum`/`newSum`, `calculateAmounts`, `applyProposalDiscount`, `NO_DISCOUNT`
- prompt recomendado: `normal`
- estrategia de teste: unitario dos dois use cases
- cenarios obrigatorios:
  - PUT de servicos sem mudanca com desconto 10% nao grava e devolve 10 e 580;
  - PUT com servico novo de R$ 300 num orcamento de 5220 com 580 de desconto grava 6100 e desconto 0;
  - PUT com 100% de desconto e mudanca reconstroi o subtotal pelo `discountAmount`;
  - corpo com `discountPercent` nao altera nada;
  - historico ganha " (desconto de 10% removido)" quando havia desconto;
  - recalculo com mesma data, convidados e horas aplica 10% sobre o subtotal recalculado;
  - recalculo com convidados novos grava o subtotal e desconto 0.
- definition of done: os cenarios passam nos specs de `update-public-proposal-services` e `recalculate-public-proposal`; respostas com `discountPercent` e `discountAmount`.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — rotas publicas que regravam valor
- risco principal: desconto sobreviver a mudanca do cliente, ou ser criado pelo corpo publico
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: fluxos do dono, tela e regra de cortesia
- prova minima desta task: o unitario do PUT com servico novo espera `totalAmount` 6100 e `discountPercent` 0 gravados
- criterio de escalada: se a decisao mudar para "desconto fixo em R$", parar; muda a formula do PUT e o texto do aviso
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/update-public-proposal-services/use-case-update-public-proposal-services.ts`, `art56_server_v3/src/use-cases/proposal/recalculate-public-proposal/use-case-recalculate-public-proposal.ts`
- palavras-chave ou simbolos de busca: `currentResponse`, `oldSum`, `newSum`, `HISTORY_ACTION`, `calculateAmounts`, `wallClockDateIsoFromDate`
- testes provaveis: `npm test -- --run src/use-cases/proposal/update-public-proposal-services src/use-cases/proposal/recalculate-public-proposal`
- nao ler por padrao: criacao, edicao, frontend

### T-05 - Campo Desconto (%) no painel

- objetivo: o bloco `Total estimado` troca `Usar este valor` pelo campo `Desconto (%)`; criar por pessoa e editar preenchem o `Total` com o total com desconto e enviam `discountPercent`.
- cobre requisitos: `R-09`, `R-10`
- depende de: `T-03`
- pode rodar em paralelo com: `T-06`
- reusa: `ProposalQuoteSummary`, `useProposalQuote`, `NumericFormat` do campo `Total`
- prompt recomendado: `normal`
- estrategia de teste: vitest de `proposal-discount` e de `ProposalQuoteSummary`; browser do painel; lint
- cenarios obrigatorios:
  - estimado 5800 e `10` mostram `Desconto (10%) - R$ 580,00`, `Total com desconto R$ 5.220,00` e o `Total` com 5220;
  - `7,5` aceito; `101` e `-1` mostram erro no campo e nao enviam;
  - mudar convidados com a % preenchida reaplica sobre o novo estimado;
  - digitar no `Total` limpa a %;
  - abrir a criacao ou a edicao sem tocar na % nao mexe no `Total`;
  - `ProposalEdit` abre com a % gravada, o aviso de salvar usa o total com desconto e o PUT leva `discountPercent`;
  - permuta esconde o campo.
- definition of done:
  - os cenarios passam (vitest e browser);
  - tipos e `proposal.service.ts` atualizados;
  - `npm run build` e lint sem erro novo nos arquivos tocados.

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — a autorizacao fica no backend (D-05)
- risco principal: o `Total` sobrescrever um valor salvo ao abrir a tela, ou o payload nao levar `discountPercent`
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: exibicao no detalhe e no link, modais publicos, formularios publicos e por dia
- prova minima desta task: no painel, criar com 10% num estimado de R$ 5.800,00 mostra R$ 5.220,00 no `Total` e o POST leva `discountPercent: 10`
- criterio de escalada: se o `Total` precisar ficar bloqueado com a % preenchida, parar; a premissa e que digitar no `Total` limpa a %
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados` (bloco Frontend)
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/ProposalQuoteSummary.tsx`, `src/components/proposal/forms/PerPersonProposalForm.tsx`, `src/pages/ProposalEdit.tsx`, `src/lib/proposal-discount.ts` (novo), `src/types/proposal.ts`, `src/services/proposal.service.ts`
- palavras-chave ou simbolos de busca: `onUseValue`, `totalAmountInput`, `saveNotice`, `useProposalQuote`, `NumericFormat`, `sourceInfo`
- testes provaveis: `npm test -- src/lib/proposal-discount.test.ts src/components/proposal/ProposalQuoteSummary.test.tsx`
- nao ler por padrao: `ProposalView`, formularios publicos, `security`

### T-06 - Exibir o desconto, avisar no link e atualizar docs

- objetivo: link e detalhe do painel mostram subtotal, desconto e total; os modais publicos avisam que o desconto cai; a pagina reflete o desconto zerado; os docs registram regra e contrato.
- cobre requisitos: `R-11`, `R-12`
- depende de: `T-04`
- pode rodar em paralelo com: `T-05`
- reusa: `formatCurrency`, `applyPublicServices`, `discountLabel` de `T-05` (criar aqui se `T-05` ainda nao existir)
- prompt recomendado: `normal`
- estrategia de teste: vitest de `applyPublicServices` (ou do helper extraido) e de `discountLabel`; browser do detalhe e do link; lint
- cenarios obrigatorios:
  - link com 10% mostra `Subtotal R$ 5.800,00`, `Desconto (10%) - R$ 580,00` e `Investimento total R$ 5.220,00`;
  - detalhe do painel mostra o mesmo antes do Total;
  - orcamento sem desconto fica como hoje;
  - os dois modais mostram o aviso so quando ha desconto;
  - depois de alterar servicos ou recalcular com mudanca, as linhas de desconto somem sem recarregar.
- definition of done:
  - os cenarios passam (vitest e browser);
  - docs atualizados: `topics/pricing-and-proposal-calculation.md`, `project/api-endpoints.md` (dois corpos e duas respostas publicas), `product/02-business-rules.md#Precificacao` e `R-12` da spec do total estimado marcado como substituido;
  - lint sem erro novo.

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o link mostrar desconto ja zerado no banco, ou subtotal que nao fecha com o total
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `eventhub-docs`
- fora de escopo desta task: formularios de criar e editar, contrato em PDF e relatorios
- prova minima desta task: no link de um orcamento com 10%, "Seu investimento" mostra subtotal, desconto e total, e apos adicionar um servico o desconto some
- criterio de escalada: se a resposta publica nao trouxer `discountPercent` e `discountAmount`, parar e voltar a `T-04`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados` (bloco Exibicao)
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_core/topics/pricing-and-proposal-calculation.md#Pipeline atual (proposal-amounts.ts)`
  - `.cursor/framework_core/project/api-endpoints.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` (`applyPublicServices`, "Seu investimento"), `src/components/proposal/ProposalServicesSummary.tsx`, `src/components/proposal/UpdateProposalServicesDialog.tsx`, `src/components/proposal/RecalculateProposalDialog.tsx`
- palavras-chave ou simbolos de busca: `applyPublicServices`, `Investimento total`, `setCurrentProposal`, `RecalculateProposalDialog`, `onSaved`
- testes provaveis: `npm test -- src/lib/proposal-discount.test.ts`
- nao ler por padrao: formularios de criar, backend, `security`
