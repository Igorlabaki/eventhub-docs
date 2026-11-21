# Tasks — Categoria do evento na proposta

## Ordem macro

`T-01` abre a coluna. `T-02` depende dela. `T-03` e `T-04` dependem do contrato de `T-02` e podem correr em paralelo. `T-05` depende do modulo de rotulos de `T-03`. O deploy request no `main` (aprovacao nomeada) acontece depois de `T-01` e antes da prova no browser.

## Tasks

### T-01 - Acrescentar a categoria do evento a proposta

- objetivo: criar o enum `EventCategory` e a coluna opcional `Proposal.eventCategory`, com migration aditiva
- cobre requisitos: `R-01`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: o model `Proposal` e o padrao de `20261105153000_add_partner_category`
- prompt recomendado: `smart`
- estrategia de teste: `npx prisma format`, `npx prisma validate` e leitura do SQL
- cenarios obrigatorios:
  - o enum tem os seis valores, na ordem do design
  - a coluna e opcional e sem `@default`
  - o SQL e um `ALTER TABLE ... ADD COLUMN ... NULL`, sem `UPDATE`
- definition of done:
  - schema e migration escritos
  - `npx prisma validate` passa
  - nada aplicado no PlanetScale sem aprovacao nomeada

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: coluna `NOT NULL` ou com default
- repos tocados: `backend`
- fora de escopo desta task: schemas HTTP, use cases, frontend, deploy request
- prova minima desta task: `npx prisma validate` aceita `eventCategory EventCategory?` sem `@default`, e `migration.sql` contem so o `ALTER TABLE` da coluna
- criterio de escalada: `normal` se o Prisma gerar alteracao em outra coluna
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`, `node`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_core/topics/data-and-migrations.md#Regras`
  - `.cursor/framework_global/framework-libs/database/skills/writing-zero-downtime-migrations.md#Processo obrigatorio`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` em `model Proposal` e `enum ProposalType`; `art56_server_v3/prisma/migrations/20261105153000_add_partner_category/migration.sql`
- palavras-chave ou simbolos de busca: `model Proposal`, `enum ProposalType`, `PartnerCategory`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, frontend

### T-02 - Validar e gravar a categoria nos use cases de proposta

- objetivo: os quatro use cases de create e update gravam a categoria resolvida pela regra unica
- cobre requisitos: `R-02`, `R-03`, `R-04`, `R-05`, `R-06`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `HttpBadRequestError`, o padrao de `assertChosenServiceHours`, o `...rest` dos use cases
- prompt recomendado: `normal`
- estrategia de teste: unitario de `resolveEventCategory`; casos nos specs dos use cases de create por pessoa e por dia
- cenarios obrigatorios:
  - `EVENT` sem categoria, com `null` ou com `"FESTA"`: 400 com "Selecione a categoria do evento"
  - `EVENT` com `BIRTHDAY`: devolve `BIRTHDAY`
  - `PRODUCTION` com `BIRTHDAY`: devolve `null`
  - create por pessoa com `BARTER` grava `eventCategory: null` (branch que sai cedo)
  - create por pessoa com `EVENT` sem categoria nao chama o repositorio
  - update por pessoa com `EVENT` sem categoria falha; com `PRODUCTION` grava `null`
- definition of done:
  - `src/functions/event-category.ts` existe e e a unica fonte da lista no backend
  - os cinco schemas Zod aceitam `eventCategory` opcional e nulo
  - todo objeto enviado ao repositorio nos quatro use cases usa a variavel resolvida
  - `npm test -- --run` verde

#### Context Pack

- frente principal: backend
- superficie sensivel: nao — a rota publica de create ja existe; a task so valida um enum
- risco principal: um dos varios caminhos de `createPerPerson`/`createPerDay`/`update` dentro do use case gravar o valor cru do payload
- repos tocados: `backend`
- fora de escopo desta task: corrigir o `safeParse` ignorado no controller; aceitar `OVERNIGHT` nos schemas por pessoa; listagem e relatorios
- prova minima desta task: `event-category.spec.ts` cobre os tres primeiros cenarios, os specs dos use cases cobrem `BARTER`, create sem categoria e update, e `npm test -- --run` passa
- criterio de escalada: `complete` se algum use case gravar fora do `...rest` e exigir refatoracao
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_global/framework-libs/node/references/node-express-coding-style.md`
- caminhos candidatos: `art56_server_v3/src/functions/quote-service-lines.ts` (`assertChosenServiceHours`); `art56_server_v3/src/zod/proposal/*-proposal-per-*-schema.ts` e `update-proposal-in-db-params-schema.ts`; `art56_server_v3/src/repositories/interface/proposal-repository-interface.ts`; `art56_server_v3/src/use-cases/proposal/{create,update}-proposal-per-{person,day}/use-case-*.ts` e `.spec.ts`
- palavras-chave ou simbolos de busca: `...rest`, `createPerPerson(`, `createPerDay(`, `proposalRepository.update(`, `params.type === "BARTER"`, `HttpBadRequestError`
- testes provaveis: `art56_server_v3/src/functions/event-category.spec.ts`; `use-case-create-proposal-per-person.spec.ts`; `use-case-create-proposal-per-day.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, frontend, controllers alem de confirmar o `safeParse`

### T-03 - Pedir a categoria nos formularios do painel

- objetivo: criacao por pessoa, criacao por dia e edicao pedem a categoria quando o tipo e Evento e enviam `null` nos outros tipos
- cobre requisitos: `R-07`, `R-09`
- depende de: `T-02`
- pode rodar em paralelo com: `T-04`
- reusa: o select "Tipo do aluguel"; `PROPOSAL_TYPE_OPTIONS`
- prompt recomendado: `normal`
- estrategia de teste: unitario de `src/lib/event-category.ts`
- cenarios obrigatorios:
  - `EVENT_CATEGORY_OPTIONS` segue a tabela do design, de Empresarial a Outro
  - `eventCategoryForPayload(EVENT, BIRTHDAY)` devolve `BIRTHDAY`; com `PRODUCTION` devolve `null`; `EVENT` sem valor devolve `null`
  - o select aparece so com tipo Evento e some ao trocar
  - trocar de Evento para outro tipo limpa o valor
  - salvar Evento sem categoria mostra "Selecione a categoria do evento" no campo
  - edicao de proposta antiga abre com o select vazio
- definition of done:
  - `EventCategory` e o campo existem em `types/proposal.ts` (`Proposal` e os quatro DTOs)
  - os tres formularios usam o modulo e o payload novo
  - teste do modulo verde; `npm run lint` sem erro novo nesses arquivos

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: enviar categoria em proposta de Producao, ou travar a edicao de proposta que nao e Evento
- repos tocados: `frontend`
- fora de escopo desta task: formularios publicos, detalhe, `NewBudget.tsx`, `BudgetSidebar`
- prova minima desta task: `event-category.test.ts` cobre os dois primeiros cenarios e os tres formularios enviam `eventCategory` pelo `eventCategoryForPayload`
- criterio de escalada: `complete` se o select condicional exigir componente novo
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
- caminhos candidatos: `eventhub-vista-dashboard/src/types/proposal.ts`; `src/components/proposal/forms/constants.ts`; `src/components/proposal/forms/PerPersonProposalForm.tsx` (schema `baseFormSchema`, `onSubmit`, campo `type`); `src/components/proposal/forms/PerDayProposalForm.tsx`; `src/pages/ProposalEdit.tsx` (`editProposalSchema`, `form.reset`, `onSubmit`)
- palavras-chave ou simbolos de busca: `PROPOSAL_TYPE_OPTIONS`, `name="type"`, `name="data.type"`, `form.watch("type")`, `CreateProposalPerPersonDTO`
- testes provaveis: `eventhub-vista-dashboard/src/lib/event-category.test.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, backend alem do contrato do design

### T-04 - Pedir a categoria no formulario publico

- objetivo: o cliente escolhe a categoria no passo dos dados do evento, nos formularios publicos por pessoa e por dia
- cobre requisitos: `R-08`
- depende de: `T-02`
- pode rodar em paralelo com: `T-03`
- reusa: `EVENT_CATEGORY_OPTIONS` (criado em `T-03`; se `T-04` rodar antes, criar o modulo conforme o design); estilo dos selects publicos (`[role=combobox]` com `--field-bg`)
- prompt recomendado: `smart`
- estrategia de teste: lint e browser; o modulo ja tem teste
- cenarios obrigatorios:
  - o select aparece no passo 2, antes da descricao, com as seis opcoes
  - "Próximo" no passo 2 sem categoria nao avanca e mostra a mensagem no campo
  - o payload envia `eventCategory` junto de `type: EVENT`
  - o select segue as cores do espaco como os outros campos
- definition of done:
  - os dois formularios publicos exigem e enviam a categoria
  - `goNext` do passo 2 inclui `eventCategory`
  - `npm run lint` sem erro novo nesses arquivos

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — formulario ja publico; campo sem PII
- risco principal: o passo avancar sem categoria e o cliente so descobrir o 400 no envio final
- repos tocados: `frontend`
- fora de escopo desta task: formularios do painel, link publico da proposta, identidade visual do formulario
- prova minima desta task: no formulario publico de um espaco, o passo 2 nao avanca sem categoria e o envio grava a proposta com a categoria escolhida
- criterio de escalada: `normal` se o passo exigir reorganizar campos alem de inserir o select
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/forms/ClientPerPersonProposalForm.tsx` (`baseSchema`, `goNext`, `onSubmit`); `src/components/proposal/forms/ClientPerDayProposalForm.tsx`; `src/lib/event-category.ts`
- palavras-chave ou simbolos de busca: `goNext`, `step === 0`, `type: ProposalType.EVENT`, `PublicBudgetStepStage`, `description`
- testes provaveis: `eventhub-vista-dashboard/src/lib/event-category.test.ts` (ja existente)
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, backend, `PublicBudgetFormSteps.tsx` alem do uso

### T-05 - Mostrar a categoria no detalhe da proposta

- objetivo: o detalhe mostra `Evento · <categoria>` ou so o tipo
- cobre requisitos: `R-10`
- depende de: `T-03`
- pode rodar em paralelo com: `T-04`
- reusa: `PROPOSAL_TYPE_OPTIONS`, `EVENT_CATEGORY_OPTIONS`, o layout de linha do card "Informações Pessoais"
- prompt recomendado: `smart`
- estrategia de teste: unitario de `proposalTypeWithCategoryLabel`
- cenarios obrigatorios:
  - `EVENT` + `BIRTHDAY` vira `Evento · Aniversário`
  - `EVENT` + `null` vira `Evento`
  - `PRODUCTION` + `BIRTHDAY` vira `Produção`
  - tipo desconhecido devolve o valor cru
- definition of done:
  - linha "Tipo do evento" abaixo de "Por onde nos conheceu"
  - teste do formatador verde

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: quebrar o detalhe de proposta antiga sem `eventCategory`
- repos tocados: `frontend`
- fora de escopo desta task: lista de orcamentos, `BudgetSidebar`, link publico, mover a linha para outro card
- prova minima desta task: o teste cobre os quatro cenarios e o detalhe de uma proposta antiga mostra so `Evento`
- criterio de escalada: `normal` se a linha precisar sair do card de dados pessoais por causa de permissao
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `02-clarify.md#Premissas assumidas`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalDetails.tsx` (desestruturacao de `currentProposal` e card "Informações Pessoais"); `src/lib/event-category.ts`
- palavras-chave ou simbolos de busca: `Por onde nos conheceu`, `trafficSource`, `hasViewPersonalInfoPermission`
- testes provaveis: `eventhub-vista-dashboard/src/lib/event-category.test.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, backend, formularios
