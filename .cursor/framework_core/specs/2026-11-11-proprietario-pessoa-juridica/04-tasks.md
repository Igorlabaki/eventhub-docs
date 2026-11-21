# Tasks — Proprietario pessoa fisica ou juridica

## Ordem macro

1. `T-01`: colunas, migration e deploy request. O codigo vem primeiro; aplicar na `main` exige aprovacao.
2. `T-02`: resposta publica de espaco sem proprietario. Sem dependencia; pode ir ao ar sozinha.
3. `T-03`: `OwnerAuthorizer` e isolamento nas seis rotas de `/owner`. Sem dependencia de banco.
4. `T-04`: regras de documento e PF/PJ (`owner-document.ts`) e schemas Zod. Depende de `T-01` (tipos do Prisma).
5. `T-05`: criacao, edicao parcial, vinculos e duplicidade. Depende de `T-03` e `T-04`.
6. `T-06`: formulario, lista, busca e seletores no painel. Depende de `T-05` (contrato).
7. `T-07`: variaveis do contrato e regra de vazio no PDF. Depende do `lib/owner-document.ts` de `T-06`. Pode rodar em paralelo com o resto de `T-06`.

Paralelo: `T-01`, `T-02` e `T-03` desde o inicio; `T-04` logo apos o codigo de `T-01`.

Deploy: `T-02` quando aprovado; depois `T-01` na `main`; depois a API (`T-03` a `T-05`); depois o painel (`T-06` e `T-07`).

## Tasks

### T-01 - Colunas de tipo de pessoa e empresa em owner

- objetivo: `owner.personType`, `companyName`, `cnpj` e `companySize` existem no schema Prisma, na migration versionada e na `main`.
- cobre requisitos: `R-01`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`, `T-03`
- reusa: o fluxo de branch e deploy request de `project/planetscale.md`
- prompt recomendado: `normal`
- estrategia de teste: `npx prisma validate`; `SHOW COLUMNS` na branch e depois na `main`
- cenarios obrigatorios:
  - `schema.prisma` com os enums `OwnerPersonType` e `CompanySize` e os quatro campos em `Owner`;
  - `migration.sql` com um `ALTER TABLE` aditivo (`03-design.md#Contratos e dados`);
  - branch criada a partir da `main`, DDL aplicada nela e deploy request aberto;
  - o deploy request so e aplicado com aprovacao nomeada;
  - leitura de volta mostra `personType enum('PF','PJ') NOT NULL DEFAULT 'PF'` e as outras tres colunas `NULL`;
  - `SELECT personType, COUNT(*) FROM owner GROUP BY personType` (reader) mostra so `PF`.
- definition of done:
  - validate verde;
  - deploy request `complete` na `main`, com numero em `05-state.md` e `project/planetscale.md`;
  - `product/08-data-model.md` com os campos e o enum.

#### Context Pack

- frente principal: banco
- superficie sensivel: sim — DDL em producao numa tabela com PII
- risco principal: API nova no ar sem as colunas, ou DDL direto na `main`
- repos tocados: `backend` (`art56_server_v3/`), PlanetScale `ar756`
- fora de escopo desta task: regras, use cases, autorizacao e tela
- prova minima desta task: `pscale sql ar756 main --org igorlabakig --format json --query "SHOW COLUMNS FROM owner"` mostra as quatro colunas
- criterio de escalada: qualquer DDL que nao seja `ADD COLUMN` com default ou `NULL`, ou falha do deploy request, faz parar e reportar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database` (`.cursor/framework_global/framework-libs/database/index.md`)
- documentos obrigatorios:
  - `.cursor/framework_core/project/planetscale.md#Fluxo real de schema`
  - `.cursor/framework_core/project/planetscale.md#Permissoes do agente`
  - `.cursor/framework_core/product/08-data-model.md` (linha `Owner`)
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` (`model Owner`), `art56_server_v3/prisma/migrations/20261110220000_add_proposal_discount/migration.sql` (modelo)
- palavras-chave ou simbolos de busca: `model Owner`, `@@map("owner")`, `enum`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: use cases, frontend, `security`

### T-02 - Resposta publica de espaco sem o proprietario

- objetivo: `GET /venue/getById` devolve `ownerVenue` so com `ownerId` e `venueId`, com ou sem `userId`.
- cobre requisitos: `R-10`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-03`, `T-04`
- reusa: `getSelectedVenue` e `GetVenueByIdUseCase`
- prompt recomendado: `smart`
- estrategia de teste: unitario do use case com repositorio falso; conferencia do `select` no repositorio; chamada local sem token; browser de um formulario publico
- cenarios obrigatorios:
  - `getSelectedVenue` usa `ownerVenue: { select: { ownerId: true, venueId: true } }`;
  - resposta sem token e sem `userId` nao tem `owner`, `cpf`, `pix`, `bankAccountNumber` nem `cnpj`;
  - `VenueSettings` continua marcando os proprietarios do espaco;
  - `ProposalForm` publico carrega o espaco normalmente.
- definition of done:
  - testes verdes;
  - `project/api-endpoints.md` registra o formato de `ownerVenue` em `/venue/getById`;
  - `topics/auth-and-security.md` sem o vazamento do proprietario na lista de riscos (ou com a correcao anotada).

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — rota publica com PII
- risco principal: quebrar uma tela publica ou do painel que leia `ownerVenue.owner`
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: fechar a rota com token; `getById` interno do repositorio; `/venue/update`
- prova minima desta task: `GET http://localhost:3000/venue/getById?venueId=<id>` sem `Authorization` devolve `ownerVenue: [{ ownerId, venueId }]`
- criterio de escalada: deploy so com o owner ciente (rota publica usada por pagina publica); se alguma tela depender de `ownerVenue.owner`, parar e reportar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Decisoes arquiteturais importantes`
- libs obrigatorias: `node`, `security` (`.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md`)
- documentos obrigatorios:
  - `.cursor/framework_core/topics/auth-and-security.md#Regras de execucao`
  - `02-clarify.md#Respostas confirmadas`
- caminhos candidatos: `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts` (`getSelectedVenue`), `art56_server_v3/src/use-cases/venue/get-by-id-venue/`, `eventhub-vista-dashboard/src/types/venue.ts`
- palavras-chave ou simbolos de busca: `getSelectedVenue`, `ownerVenue`, `owner: true`, `fetchVenueById`
- testes provaveis: novo `src/use-cases/venue/get-by-id-venue/use-case-get-by-id-venue.spec.ts`
- nao ler por padrao: use cases de owner, frontend alem do tipo `Venue`

### T-03 - Autorizador de proprietario e isolamento entre organizacoes

- objetivo: as seis rotas de `/owner` conferem a organizacao pelo usuario do token e pelo registro gravado.
- cobre requisitos: `R-08`, `R-09`, parte de `R-05` (espaco de outra organizacao)
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`, `T-02`, `T-04`
- reusa: `ServiceAuthorizer` (formato), `verifyByUserIdAndOrganizationId`, `venueRepository.getById`, `AuthenticatedRequest`
- prompt recomendado: `normal`
- estrategia de teste: unitario do autorizador e dos use cases com repositorios falsos, no formato de `service.spec.ts`
- cenarios obrigatorios:
  - membro lista, cria, edita e exclui na propria organizacao;
  - nao membro lista ou cria em outra organizacao: 403, nada gravado;
  - nao membro edita ou exclui proprietario de outra organizacao: 404, nada gravado;
  - `venueIds` ou `venueId` de outra organizacao na criacao ou edicao: 403;
  - `listByVenue` com espaco de outra organizacao: 403;
  - sem `userId`: 401;
  - `data.organizationId` no corpo da edicao e descartado.
- definition of done:
  - testes verdes;
  - os seis controllers passam `req.user.id`;
  - `project/api-endpoints.md` anota a autorizacao de `/owner`;
  - `topics/auth-and-security.md` lista as lacunas de `02-clarify.md#Lacunas registradas fora do escopo`.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — autorizacao e PII
- risco principal: membro legitimo bloqueado, ou erro que revela dado de outra organizacao
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: PF/PJ, duplicidade, `VIEW_ORG_OWNERS`/`EDIT_ORG_OWNERS`, rotas fora de `/owner`
- prova minima desta task: vitest com usuario da organizacao A recebendo 404 ao editar um proprietario da organizacao B, sem chamada ao `update` do repositorio
- criterio de escalada: se algum usuario com permissao de espaco nao tiver `userOrganization` na `main` (consulta reader), parar e reportar antes do deploy
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados` (bloco `OwnerAuthorizer`)
- libs obrigatorias: `node`, `patterns`, `security` (`.cursor/framework_global/framework-libs/security/references/auth-and-access-control.md`)
- documentos obrigatorios:
  - `.cursor/framework_core/topics/auth-and-security.md#Regras de execucao`
  - `03-design.md#Falhas, casos de borda e invariantes`
- caminhos candidatos: `art56_server_v3/src/use-cases/service/service-authorizer.ts`, `art56_server_v3/src/use-cases/service/service.spec.ts`, `art56_server_v3/src/use-cases/owner/*/`, `art56_server_v3/src/router/owner.ts`, `art56_server_v3/src/repositories/interface/user-organization-repository-interface.ts`, `art56_server_v3/src/types/authenticated-request.ts`
- palavras-chave ou simbolos de busca: `verifyByUserIdAndOrganizationId`, `ServiceAuthorizer`, `HttpForbiddenError`, `AuthenticatedRequest`, `ownerRoutes`
- testes provaveis: novo `src/use-cases/owner/owner.spec.ts`
- nao ler por padrao: frontend, PDF, `ensurePermission`

### T-04 - Regras de documento e de PF/PJ

- objetivo: `owner-document.ts` normaliza e valida CNPJ e resolve os campos de PF/PJ para criacao e edicao; os schemas Zod aceitam os campos novos.
- cobre requisitos: `R-02`, `R-03`, regra de merge de `R-04`
- depende de: `T-01` (codigo do schema, para os enums do Prisma)
- pode rodar em paralelo com: `T-02`, `T-03`
- reusa: `HttpBadRequestError`
- prompt recomendado: `smart`
- estrategia de teste: unitario da funcao e dos schemas
- cenarios obrigatorios:
  - `12abc34501de35` e `12.ABC.345/01DE-35` normalizam para `12ABC34501DE35`;
  - `12.345.678/0001-95` e valido;
  - letra nas duas ultimas posicoes, 13 ou 15 posicoes, ou `@`: `OWNER_CNPJ_FORMAT`;
  - criacao sem `personType` vira PF com campos de empresa `null`, mesmo se enviados;
  - PJ sem `companyName` ou `cnpj`: `OWNER_COMPANY_REQUIRED`;
  - edicao com `{ pix }` sobre PJ com porte preserva tipo, empresa e porte;
  - PJ -> PF limpa; PF -> PJ sem CNPJ falha; `companySize: null` remove so o porte;
  - `companySize: "GRANDE"`: `ZodError`.
- definition of done: os cenarios passam em `owner-document.spec.ts`; os tres schemas atualizados e `organizationId` fora do schema de edicao.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — PII
- risco principal: aceitar PJ sem CNPJ ou rejeitar CNPJ alfanumerico valido
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: repositorio, autorizacao, duplicidade e tela
- prova minima desta task: o unitario espera `resolveOwnerData(pjComPorte, { pix: "x" })` com `personType: "PJ"`, `cnpj` e `companySize` iguais aos gravados
- criterio de escalada: se a edicao parcial precisar de algo alem do registro gravado e do corpo, parar e revisar o design
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados` (bloco `owner-document.ts`)
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `01-spec.md#Criterios de aceite` (`R-02` a `R-04`)
  - `02-clarify.md#Premissas assumidas`
- caminhos candidatos: `art56_server_v3/src/functions/` (modelo: `quote-service-lines.ts`), `art56_server_v3/src/zod/owner/create-owner-params-schema.ts`, `create-venue-owner-params-schema.ts`, `update-owner-params-schema.ts`
- palavras-chave ou simbolos de busca: `createOrganizationOwnerSchema`, `createVenueOwnerSchema`, `updateOwnerSchema`, `HttpBadRequestError`
- testes provaveis: novo `src/functions/owner-document.spec.ts`
- nao ler por padrao: use cases, repositorio, frontend, `security`

### T-05 - Criacao, edicao parcial, vinculos e duplicidade

- objetivo: os use cases e o repositorio de owner gravam PF/PJ pelas regras de `T-04`, preservam vinculos omitidos e checam duplicidade dentro da organizacao.
- cobre requisitos: `R-04`, `R-05`, `R-06`, `R-07`
- depende de: `T-03`, `T-04`
- pode rodar em paralelo com: `T-07` (parte de lib)
- reusa: `OwnerAuthorizer`, `resolveOwnerData`, `HttpConflictError`
- prompt recomendado: `normal`
- estrategia de teste: unitario dos use cases com repositorio falso; leitura do `data` passado ao Prisma no `update` (sem `ownerVenue` quando `venueIds` omitido)
- cenarios obrigatorios:
  - criar PJ com CNPJ alfanumerico grava normalizado;
  - mesmo CNPJ com e sem pontuacao na mesma organizacao: 409; em outra organizacao: criado;
  - editar PJ trocando o CNPJ para o de outro proprietario da organizacao: 409; manter o proprio CNPJ: ok;
  - PF com mesmo nome na mesma organizacao: 409; em outra: criado;
  - editar so `venueIds` de uma PJ (como o `VenueSelectionDialog`): tipo, empresa e porte iguais;
  - `venueIds` omitido preserva; `[]` remove todos;
  - transicoes PF -> PJ -> PF persistidas no repositorio falso.
- definition of done:
  - testes verdes;
  - `vefiryIfOwnerExists` substituido por `findDuplicate`;
  - `project/api-endpoints.md` com o corpo novo de `/owner/*`.

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — PII e escrita
- risco principal: edicao parcial apagar vinculos ou dados de empresa
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: autorizador (pronto em `T-03`), tela e PDF
- prova minima desta task: vitest em que `update({ ownerId, data: { pix } })` de uma PJ nao manda `ownerVenue` ao repositorio e devolve `personType: "PJ"` com o mesmo CNPJ
- criterio de escalada: se o repositorio precisar de transacao para vinculos mais dados, parar e revisar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados` (blocos Use cases, Duplicidade e Repositorio `update`)
- libs obrigatorias: `node`, `database`
- documentos obrigatorios:
  - `01-spec.md#Criterios de aceite` (`R-04` a `R-07`)
  - `03-design.md#Falhas, casos de borda e invariantes`
- caminhos candidatos: `art56_server_v3/src/repositories/in-prisma/owner-in-prisma-repository.ts`, `art56_server_v3/src/repositories/interface/owner-repository-interface.ts`, `art56_server_v3/src/use-cases/owner/{create-organization-owner,create-venue-owner,update-owner}/`
- palavras-chave ou simbolos de busca: `vefiryIfOwnerExists`, `venuesToDisconnect`, `createOrganizationOwner`, `createVenueOwner`, `update(`
- testes provaveis: `src/use-cases/owner/owner.spec.ts` (o mesmo de `T-03`)
- nao ler por padrao: frontend, `getSelectedVenue`, `security` alem do que `T-03` ja cobriu

### T-06 - Formulario, lista, busca e seletores no painel

- objetivo: o painel cadastra, edita, lista, busca e seleciona proprietarios PF e PJ.
- cobre requisitos: `R-11`, `R-12`, `R-13`
- depende de: `T-05` (contrato da API)
- pode rodar em paralelo com: `T-07`, depois de `lib/owner-document.ts` existir
- reusa: `react-input-mask` 2 (`formatChars`), `Select` do shadcn, rotulos de `PJContractPersonalInfoForm`
- prompt recomendado: `normal`
- estrategia de teste: vitest de `lib/owner-document.ts`; build e lint; browser do painel
- cenarios obrigatorios:
  - `formatCnpj("12ABC34501DE35")` devolve `12.ABC.345/01DE-35`;
  - `ownerMatchesSearch` acha por razao social, `12abc`, `12.ABC` e CPF sem pontos;
  - `ownerDisplayName` de PJ e de PF, e de registro sem `personType`;
  - `representativeLabels` para PF, PJ, PJ MEI;
  - browser: criar PJ MEI com CNPJ alfanumerico, ver rotulos de Titular, editar trocando para PF, limpar porte de outra PJ;
  - browser: lista e os quatro seletores com o nome exibido.
- definition of done: vitest, build e lint verdes; prova de browser registrada em `05-state.md` (ou lacuna, se o login bloquear).

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — PII exibida
- risco principal: registro antigo sem `personType` quebrar o formulario ou a lista
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: PDF (`T-07`), checagem de permissao do backend, telas do cliente PJ da proposta
- prova minima desta task: vitest de `owner-document.test.ts` verde e, no browser, uma PJ MEI criada aparecendo na lista com o CNPJ formatado
- criterio de escalada: se a mascara do `react-input-mask` nao aceitar letras com `formatChars`, parar e propor input com formatacao propria
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados` (bloco Frontend)
- libs obrigatorias: `react`, `design` (`.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`)
- documentos obrigatorios:
  - `01-spec.md#Criterios de aceite` (`R-11` a `R-13`)
  - `02-clarify.md#Premissas assumidas`
- caminhos candidatos: `eventhub-vista-dashboard/src/types/owner.ts`, `src/components/owner/OwnerForm.tsx`, `OwnersList.tsx`, `src/pages/OrganizationOwners.tsx`, `src/components/venue/CreateVenueForm.tsx`, `src/pages/VenueSettings.tsx`, `src/components/proposal/forms/pf-contract-form.tsx`, `pj-contract-form.tsx`, `src/components/proposal/forms/PJContractPersonalInfoForm.tsx` (rotulos)
- palavras-chave ou simbolos de busca: `owner.completeName`, `owner.cpf`, `CreateOwnerDTO`, `UpdateOwnerDTO`, `filterOwners`, `filteredOwners`, `InputMask`
- testes provaveis: novo `src/lib/owner-document.test.ts`
- nao ler por padrao: backend, `ContractPdfGenerator.tsx`, `security`

### T-07 - Variaveis do proprietario e vazio no PDF

- objetivo: o contrato tem razao social, CNPJ e porte do proprietario, e campo do proprietario sem valor sai em branco.
- cobre requisitos: `R-14`
- depende de: `lib/owner-document.ts` de `T-06` (`formatCnpj`, rotulos de porte)
- pode rodar em paralelo com: o resto de `T-06`
- reusa: `replaceTemplateVars`, `fieldGroups`
- prompt recomendado: `smart`
- estrategia de teste: vitest de `lib/owner-template-values.ts`; PDF gerado no browser
- cenarios obrigatorios:
  - PF legado com `rg` e `complement` `null`: `RG_PROPRIETARIO`, `COMPLEMENTO_PROPRIETARIO`, `RAZAO_SOCIAL_PROPRIETARIO`, `CNPJ_PROPRIETARIO` e `PORTE_PROPRIETARIO` em branco, sem `null` nem `{{`;
  - PJ sem porte: `PORTE_PROPRIETARIO` em branco, CNPJ formatado;
  - PJ MEI: `PORTE_PROPRIETARIO` = `MEI`; `NOME_PROPRIETARIO` e `CPF_PROPRIETARIO` do titular;
  - `DEMAIS` sai `Demais`;
  - `{{owner.inexistente}}` continua como marcador.
- definition of done: vitest verde; tres variaveis novas em `DynamicField` e `fieldGroups`; PDF de uma PJ gerado no browser (ou lacuna registrada).

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — PII no contrato
- risco principal: mudar como variaveis de cliente ou proposta saem no PDF
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: regra de vazio fora de `owner.*`; layout do PDF; contrato do cliente PJ
- prova minima desta task: vitest de `owner-template-values.test.ts` com os tres casos (PF legado, PJ sem porte, PJ MEI)
- criterio de escalada: se a troca exigir mexer na regra das outras variaveis, parar e revisar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados` (bloco `lib/owner-template-values.ts`)
- libs obrigatorias: `react`
- documentos obrigatorios:
  - `01-spec.md#Criterios de aceite` (`R-14`)
  - `02-clarify.md#Premissas assumidas` (porte no PDF e regra de vazio)
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/forms/ContractPdfGenerator.tsx` (`replaceTemplateVars`), `src/types/contract.ts` (`DynamicField`, `fieldGroups`)
- palavras-chave ou simbolos de busca: `replaceTemplateVars`, `fieldGroups`, `CPF_PROPRIETARIO`, `values[obj]`
- testes provaveis: novo `src/lib/owner-template-values.test.ts`
- nao ler por padrao: backend, `OwnerForm`, `security`
