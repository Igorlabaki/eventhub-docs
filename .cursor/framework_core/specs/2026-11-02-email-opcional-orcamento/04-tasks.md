# Tasks — e-mail opcional na criacao do orcamento

## Ordem macro

1. `T-01` torna a coluna anulavel
2. `T-02` afrouxa a API do painel
3. `T-03` afrouxa os formularios do painel
4. `T-04` obriga e grava o e-mail no salvamento do contrato

Nenhuma task roda em paralelo. `T-03` e `T-04` mexem nos tipos do frontend.

## Tasks

### T-01 - Tornar o e-mail do orcamento anulavel

- objetivo: `Proposal.email` aceita ausencia sem apagar e-mails ja gravados
- cobre requisitos: `R-10`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: migration Prisma aditiva do projeto
- prompt recomendado: smart
- estrategia de teste: `npx prisma validate` e leitura do SQL gerado
- cenarios obrigatorios: coluna anulavel; indice `[email, startDate]` permanece; SQL nao faz backfill nem reescreve e-mail existente
- definition of done: schema e client Prisma aceitam `null`; migration pronta para `prisma migrate deploy`; nenhum formulario muda

#### Context Pack

- frente principal: banco
- superficie sensivel: sim
- risco principal: migration que reescreve a tabela ou apaga e-mail existente
- repos tocados: `backend`
- fora de escopo desta task: validacao de API, formularios e link do contrato
- prova minima desta task: `npx prisma validate` ok e SQL apenas tornando `proposal.email` anulavel
- criterio de escalada: parar se a migration precisar copiar ou limpar linhas
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `framework-libs/database/rules/04_migrations_and_zero_downtime.md#Regras`
  - `framework-libs/security/skills/reviewing-security-sensitive-changes.md#3. Revisar dados e segredos`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` model `Proposal`
- palavras-chave ou simbolos de busca: `email`, `Proposal`, `@@index([email, startDate])`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, pagamento, site publico

### T-02 - Aceitar orcamento do painel sem e-mail na API

- objetivo: criacao e edicao por dia e por pessoa gravam `null` quando o e-mail vem vazio e rejeitam e-mail invalido
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-09`, `R-12`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: schemas Zod atuais e o `rest` que ja leva `email` ao repositorio
- prompt recomendado: normal
- estrategia de teste: unitario dos schemas de criacao e edicao
- cenarios obrigatorios: vazio e espacos viram `null`; e-mail valido passa; texto invalido falha; WhatsApp ausente continua falhando; schemas do pedido publico do site permanecem obrigatorios
- definition of done: `CreateProposalInDbParams.email` aceita `null`; testes dos quatro schemas do painel verdes; pedido do site intocado

#### Context Pack

- frente principal: backend
- superficie sensivel: sim
- risco principal: afrouxar tambem o pedido publico do site ou gravar `""`
- repos tocados: `backend`
- fora de escopo desta task: formularios e `updatePersonalInfo`
- prova minima desta task: testes unitarios cobrindo vazio, valido e invalido na criacao e na edicao
- criterio de escalada: parar se a criacao nao repassar `email` no objeto que vai ao Prisma
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `framework-libs/security/skills/reviewing-security-sensitive-changes.md#3. Revisar dados e segredos`
- caminhos candidatos: `src/zod/proposal/create-proposal-per-day-params-schema.ts`, `create-proposal-per-person-params-schema.ts`, `update-proposal-per-day--params-schema.ts`, `update-proposal-per-person-params-schema.ts`, `src/repositories/interface/proposal-repository-interface.ts`
- palavras-chave ou simbolos de busca: `email: z.string().email()`, `CreateProposalInDbParams`
- testes provaveis: `npm test -- --run` nos schemas ou use cases de proposal alterados
- nao ler por padrao: `01-spec.md`, link do contrato, envio de e-mail

### T-03 - Tirar a obrigatoriedade do e-mail nos formularios do painel

- objetivo: o dono cria e edita o orcamento no painel sem preencher e-mail
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-09`, `R-12`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: `zodResolver`, `Input type="email"` e `FormMessage` dos formularios atuais
- prompt recomendado: normal
- estrategia de teste: submeter os formularios e `npm run lint` nos arquivos alterados
- cenarios obrigatorios: criar por dia em branco; criar por pessoa em branco; editar em branco; e-mail invalido mostra erro e nao navega; e-mail valido segue no payload; WhatsApp vazio continua bloqueando
- definition of done: os tres formularios do painel aceitam vazio; tipos de criacao e edicao aceitam ausencia; formularios publicos do site continuam obrigando e-mail

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim
- risco principal: o formulario continuar bloqueando o dono ou passar a aceitar e-mail invalido
- repos tocados: `frontend`
- fora de escopo desta task: links do contrato e pedido publico do site
- prova minima desta task: no painel, criar um orcamento com e-mail em branco e editar outro deixando o e-mail em branco
- criterio de escalada: parar se a API ainda responder erro para e-mail ausente
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Componentes e modulos impactados`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Componentes e modulos impactados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
- caminhos candidatos: `src/components/proposal/forms/PerDayProposalForm.tsx`, `PerPersonProposalForm.tsx`, `src/pages/ProposalEdit.tsx`, `src/types/proposal.ts`
- palavras-chave ou simbolos de busca: `email: z.string().email`, `CreateProposalPerDayDTO`, `data.email`
- testes provaveis: fluxo manual no painel; `npm run lint`
- nao ler por padrao: `01-spec.md`, `ClientPerDayProposalForm`, `ClientPerPersonProposalForm`

### T-04 - Exigir e-mail ao salvar os dados do contrato

- objetivo: o cliente so salva o link do contrato com e-mail valido, e esse valor fica no orcamento
- cobre requisitos: `R-06`, `R-07`, `R-08`, `R-11`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `updateProposalPersonalInfo` e os quatro formularios que ja salvam dados pessoais
- prompt recomendado: normal
- estrategia de teste: unitario do schema `updatePersonalInfo` e fluxo manual nos dois links
- cenarios obrigatorios: link PF sem e-mail nao salva; link PJ sem e-mail nao salva; e-mail invalido nao salva; e-mail valido fica no orcamento; payload sem e-mail e rejeitado e o valor anterior permanece; campo preenche quando o orcamento ja tem e-mail
- definition of done: API grava `email`; os quatro formularios enviam e-mail obrigatorio; cliente sem sessao nao e mandado ao login ao abrir o link; nenhum log contem o e-mail

#### Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim
- risco principal: publicar a API obrigatoria sem os formularios, ou aceitar o link sem e-mail
- repos tocados: `backend`, `frontend`
- fora de escopo desta task: criacao do painel, pedido do site, PDF e envio de e-mail
- prova minima desta task: nos dois links, salvar sem e-mail falha e salvar com e-mail valido grava o valor
- criterio de escalada: parar se o link exigir login para o cliente concluir o formulario
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Decisoes arquiteturais importantes`
- libs obrigatorias: `node`, `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Decisoes arquiteturais importantes`
  - `03-design.md#Riscos e mitigacoes`
  - `framework-libs/security/skills/reviewing-security-sensitive-changes.md#3. Revisar dados e segredos`
  - `framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
- caminhos candidatos: `update-personal-info-proposal-params-schema.ts`, `proposal-in-prisma-repository.ts` `updatePersonalInfo`, `PFContractPersonalInfoForm.tsx`, `PJContractPersonalInfoForm.tsx`, `pf-contract-form.tsx`, `pj-contract-form.tsx`, `src/lib/axios.ts` `PUBLIC_ROUTES`
- palavras-chave ou simbolos de busca: `updatePersonalInfo`, `person-contract`, `b2b-contract`, `PUBLIC_ROUTES`
- testes provaveis: schema rejeita ausencia; fluxo manual PF e PJ sem sessao
- nao ler por padrao: `01-spec.md`, criacao do painel, pagamento, geracao de PDF
