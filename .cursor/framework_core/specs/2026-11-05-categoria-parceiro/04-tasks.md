# Tasks — Categoria do parceiro

## Ordem macro

`T-01` abre a coluna. `T-02` e `T-03` dependem dela e podem correr em paralelo. `T-04` depende de `T-02`. `T-05` depende de `T-03` e de `T-04`.

## Tasks

### T-01 - Acrescentar a categoria ao contato

- objetivo: criar o enum, a coluna opcional e o backfill so dos fornecedores
- cobre requisitos: `R-01`, `R-02`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: o model `Contact` e as migrations aditivas ja existentes
- prompt recomendado: `smart`
- estrategia de teste: `npx prisma validate` e leitura do SQL
- cenarios obrigatorios:
  - o enum tem os dezessete valores, sem default na coluna
  - o `UPDATE` atinge so `type = SUPPLIER` com categoria nula
  - membro de equipe nao e preenchido
- definition of done:
  - `PartnerCategory` e `Contact.category` estao no schema
  - a migration e aditiva e contem o `UPDATE` do design
  - `npx prisma validate` passa
  - a migration nao e aplicada em producao

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: default `OUTROS` na coluna, ou `UPDATE` sem filtrar `SUPPLIER`
- repos tocados: `backend`
- fora de escopo desta task: schemas HTTP, formularios, pagina publica e `migrate deploy`
- prova minima desta task: `npx prisma validate` aceita `category PartnerCategory?` sem `@default`, e o SQL faz o `UPDATE` apenas com `type = 'SUPPLIER' AND category IS NULL`
- criterio de escalada: `normal` se o Prisma gerar a coluna `NOT NULL` ou o backfill nao couber no mesmo arquivo
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`, `node`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_core/topics/data-and-migrations.md#Regras`
  - `.cursor/framework_global/framework-libs/database/skills/writing-zero-downtime-migrations.md#Processo obrigatorio`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` no model `Contact`; `art56_server_v3/prisma/migrations/`
- palavras-chave ou simbolos de busca: `enum ContactType`, `model Contact`, `SUPPLIER`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, frontend

### T-02 - Validar a categoria ao gravar o contato

- objetivo: recusar parceiro sem categoria da lista e zerar a categoria da equipe
- cobre requisitos: `R-03`, `R-04`, `R-05`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: os schemas Zod de create e update e o repositorio que ja espalha o payload
- prompt recomendado: `normal`
- estrategia de teste: unitario de `assertPartnerCategory` e dos dois schemas
- cenarios obrigatorios:
  - create `SUPPLIER` sem categoria ou com valor estranho falha
  - create `SUPPLIER` com `OUTROS` passa
  - create sem tipo, ou com `TEAM_MEMBER`, passa so sem categoria
  - update para `TEAM_MEMBER` grava `category: null`
  - update para `SUPPLIER` sem categoria falha
  - update sem tipo e sem categoria nao exige categoria
- definition of done:
  - create e update usam a mesma regra
  - `role` continua como esta
  - `npm test -- --run` do spec novo fica verde

#### Context Pack

- frente principal: backend
- superficie sensivel: nao — a rota publica de create ja existe; a task so valida o enum
- risco principal: aceitar fornecedor sem categoria, ou gravar categoria em membro de equipe
- repos tocados: `backend`
- fora de escopo desta task: a leitura publica, os formularios e a migration
- prova minima desta task: o spec cobre os seis cenarios e `npm test -- --run` desse arquivo passa
- criterio de escalada: `complete` se a gravacao nao passar pelo schema e exigir regra no repositorio
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/node/references/node-express-coding-style.md`
- caminhos candidatos: `art56_server_v3/src/zod/contact/create-contact-params-schema.ts`; `update-contact-params-schema.ts`; `contact-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `createContactSchema`, `updateContactSchema`, `ContactType`
- testes provaveis: `art56_server_v3/src/zod/contact/partner-category.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, frontend

### T-03 - Devolver a categoria na leitura publica

- objetivo: incluir `category` na allowlist da lista de indicacoes, sem abrir outro campo
- cobre requisitos: `R-08`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: `publicContactSelect`, `PUBLIC_KEYS` e `use-case-list-proposal-indications.spec.ts`
- prompt recomendado: `smart`
- estrategia de teste: estender o spec que ja compara o objeto publico
- cenarios obrigatorios:
  - o item publico inclui `category` e mantem a ordem recebida
  - `venueId`, `type` e campo extra continuam de fora
  - o `GET` continua sem `ensureAuthenticate`
  - lista vazia continua vazia
- definition of done:
  - `PublicIndication.category` existe nos dois lados do contrato de tipo do backend
  - o spec atualizado fica verde

#### Context Pack

- frente principal: backend
- superficie sensivel: nao — nao entra PII nova; a allowlist continua fechada
- risco principal: o select passar `venueId` ou `type` junto com `category`
- repos tocados: `backend`
- fora de escopo desta task: agrupar na pagina, mudar o `PUT` e o cadastro
- prova minima desta task: o spec de leitura publica espera `category` no objeto e continua sem `venueId` e sem `type`
- criterio de escalada: `normal` se o agrupamento precisar mudar a forma da resposta
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/list-proposal-indications/use-case-list-proposal-indications.ts`; `proposal-indication-in-prisma-repository.ts`; `proposal-indication-repository-interface.ts`
- palavras-chave ou simbolos de busca: `PUBLIC_KEYS`, `publicContactSelect`, `toPublic`
- testes provaveis: `use-case-list-proposal-indications.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, frontend

### T-04 - Pedir a categoria no cadastro

- objetivo: o painel e o formulario publico so enviam parceiro com categoria, e a lista mostra o rotulo
- cobre requisitos: `R-06`, `R-07`
- depende de: `T-02`
- pode rodar em paralelo com: `T-03`
- reusa: o `Select` do tipo no `contact-form.tsx` e o modulo de rotulos descrito no design
- prompt recomendado: `normal`
- estrategia de teste: unitario de `partner-category.ts` com os dezessete rotulos
- cenarios obrigatorios:
  - os rotulos seguem a tabela do design, de Buffet a Outros
  - fornecedor no painel exige categoria; equipe nao envia categoria
  - o formulario publico exige categoria e continua enviando `SUPPLIER`
  - a funcao livre permanece nos dois formularios
  - a lista mostra o rotulo do fornecedor e a funcao quando existe
- definition of done:
  - `src/lib/partner-category.ts` existe com a ordem e os rotulos
  - erro do campo e "Selecione a categoria"
  - o teste do modulo fica verde
  - `npm run lint` nao aponta erro novo nesses arquivos

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o formulario publico seguir gravando parceiro sem categoria, ou a equipe passar a enviar `OUTROS`
- repos tocados: `frontend`
- fora de escopo desta task: a pagina `/proposal/:id/indications` e o schema do backend
- prova minima desta task: o teste dos rotulos passa, e os dois formularios deixam de enviar fornecedor sem `category`
- criterio de escalada: `complete` se o select do painel precisar de um componente novo
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/contact/contact-form.tsx`; `src/pages/PartnerForm.tsx`; `src/components/contact/contact-list.tsx`; `src/types/contact.ts`
- palavras-chave ou simbolos de busca: `ContactType.SUPPLIER`, `role`, `partner-form`
- testes provaveis: `eventhub-vista-dashboard/src/lib/partner-category.test.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, backend alem do enum ja fechado no design

### T-05 - Agrupar os indicados na pagina publica

- objetivo: separar os parceiros do link publico pela categoria, sem mudar o card
- cobre requisitos: `R-09`, `R-10`
- depende de: `T-03`, `T-04`
- pode rodar em paralelo com: nenhuma
- reusa: `partner-category.ts`, `indicationLinks` e o card atual de `ProposalIndications.tsx`
- prompt recomendado: `smart`
- estrategia de teste: unitario de `groupIndicationsByCategory`
- cenarios obrigatorios:
  - duas categorias viram dois grupos, na ordem do enum, nao na ordem de chegada
  - dentro do grupo, a ordem recebida se mantem
  - categoria nula cai em Outros junto de `OUTROS`
  - grupo sem gente nao volta
  - lista vazia nao volta grupo
- definition of done:
  - a pagina usa a funcao e o titulo e o rotulo
  - nome, funcao e links do item permanecem
  - lista vazia continua com o texto atual, sem titulo de grupo
  - o teste da funcao fica verde

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: reordenar os parceiros dentro da categoria, ou mostrar grupo de quem nao foi indicado
- repos tocados: `frontend`
- fora de escopo desta task: filtro, rota nova, casca da pagina e o cadastro
- prova minima desta task: o unitario cobre os cinco cenarios e a pagina renderiza um titulo por grupo devolvido
- criterio de escalada: `normal` se a API precisar devolver grupos em vez da lista
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalIndications.tsx`; `src/lib/partner-category.ts`; `src/services/proposal.service.ts`
- palavras-chave ou simbolos de busca: `PublicIndication`, `indications.map`, `Nossas indicacoes`
- testes provaveis: `eventhub-vista-dashboard/src/lib/partner-category.test.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, cadastro de contato
