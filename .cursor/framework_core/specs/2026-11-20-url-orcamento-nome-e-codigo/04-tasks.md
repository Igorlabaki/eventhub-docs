# Tasks

## Ordem macro

1. `T-01` grava e le o codigo no backend.
2. `T-02` troca os links do orcamento. Depende de `T-01`.
3. `T-03` troca os links da casa para `/espaco/{nome}/...`. Pode correr com `T-01`.

## Tasks

### T-01 - Codigo publico do orcamento

- objetivo: gravar `publicCode` na criacao e achar o orcamento por esse codigo ou pelo id
- cobre requisitos: `R-03`, `R-04`, `R-05`, `R-06`, `R-10`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: regex de UUID em `venue-public-key.ts`
- prompt recomendado: normal
- estrategia de teste: unitario do gerador, do rotulo e da leitura
- cenarios obrigatorios: codigo com 8 caracteres do alfabeto; dois nomes iguais geram codigos diferentes; rotulo errado com codigo certo acha o orcamento; `maria-silva-1` nao acha; id antigo acha mesmo sem codigo; colisao tenta outro codigo
- definition of done: `npx prisma validate` aceita a coluna; migration so adiciona `publicCode` nulo e unico; a criacao grava o codigo; a leitura publica usada pelas paginas do cliente aceita id ou codigo; reordenar foto continua no id; a `main` nao recebe deploy request; `topics/data-and-migrations.md` nao muda

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — o codigo passa a abrir o orcamento publico
- risco principal: codigo previsivel ou a leitura por nome juntar dois clientes
- repos tocados: `art56_server_v3`
- fora de escopo desta task: rotas do browser, painel, deploy na `main`, backfill
- prova minima desta task: os cenarios obrigatorios verdes e `npx prisma validate`
- criterio de escalada: parar se a leitura precisar de outro campo alem do codigo e do id
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `database`, `security`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `topics/data-and-migrations.md#Regras`, `framework_global/framework-libs/security/index.md#Quando esta lib e obrigatoria`
- caminhos candidatos: `prisma/schema.prisma` model `Proposal`; `src/functions/venue-public-key.ts`; criacao `createPerPerson` e `createPerDay`; `getPresentation`
- palavras-chave ou simbolos de busca: `completeClientName`, `proposalId`, `isVenueIdKey`, `publicCode`
- testes provaveis: spec nova do gerador e da leitura ao lado de `use-case-get-proposal-presentation.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, paginas do frontend

### T-02 - URL publica do orcamento

- objetivo: copiar e abrir o orcamento em `/espaco/{casa}/orcamento/{ref}` e os sufixos em portugues
- cobre requisitos: `R-01`, `R-02`, `R-07`, `R-08`, `R-09`, `R-13`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: `Venue.name`; `publicCode` de `T-01`
- prompt recomendado: normal
- estrategia de teste: unitario da montagem e das rotas; browser no caminho novo, num id antigo e em `/contrato` dos dois tipos
- cenarios obrigatorios: Maria Silva na AR756 vira `/espaco/AR756/orcamento/maria-silva-` mais 8 caracteres; nome vazio omite o rotulo; `José da Silva` vira `jose-da-silva`; sufixos `evento`, `convidados`, `colaboradores`, `programacao`, `indicacoes` e `contrato`; `/contrato` de pessoa fisica e de juridica; `/proposal/:id/view` e `person-contract` seguem registrados; o painel segue `/proposal/:id`; `PUBLIC_ROUTES` inclui o caminho novo
- definition of done: cada copia listada no design usa a URL nova; as rotas velhas continuam; `topics/public-pages-and-branding.md` cita o endereco novo; browser abre a URL nova e uma URL antiga com id

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — `PUBLIC_ROUTES` precisa reconhecer a URL nova senão o cliente cai no login
- risco principal: alguma copia continuar em `/proposal/{id}`
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: caminhos da casa (`T-03`), API, painel, deploy
- prova minima desta task: testes do formato e das rotas verdes; no browser, a URL nova, `/proposal/{id}/view` e os dois tipos de contrato abrem
- criterio de escalada: parar se alguma copia do design ficar no caminho velho
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `security`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `03-design.md#Componentes e modulos impactados`
- caminhos candidatos: `src/App.tsx`; `src/lib/event-link.ts`; `src/lib/axios.ts`; `src/hooks/useBootstrapUser.ts`; `src/pages/ProposalDetails.tsx`; `src/components/email-config/EmailTab.tsx`; `src/pages/SendProposalPage.tsx`; `src/components/person/person-list.tsx`; `src/components/schedule/schedule-list.tsx`; `src/components/proposal/ProposalContractForm.tsx`; `src/pages/ProposalEventLinkShare.tsx`; `src/pages/SendSuppliers.tsx`; `ClientPerPersonProposalForm.tsx`; `ClientPerDayProposalForm.tsx`
- palavras-chave ou simbolos de busca: `PUBLIC_ROUTES`, `event-hub-dashboard.vercel.app/proposal`, `person-contract`, `b2b-contract`
- testes provaveis: `src/lib/event-link.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, schema Prisma

### T-03 - URL publica da casa

- objetivo: apresentacao, formulario, regras, parceiro e colaborador passam a `/espaco/{nome}/...`
- cobre requisitos: `R-11`, `R-12`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01` e `T-02`
- reusa: `publicVenueKey` em `lib/public-venue-presentation.ts`
- prompt recomendado: normal
- estrategia de teste: unitario dos cinco enderecos e das rotas velhas; browser em `/espaco/AR756/apresentacao` e num `/venue/AR756/form` antigo
- cenarios obrigatorios: apresentacao, formulario, regras, parceiro e colaborador usam o nome da casa; regras e os dois cadastros deixam de copiar o id; `/venue/{nome}/form`, `/venue/{nome}/apresentacao`, `/venue/{id}/rules/view`, `partner-form` e `crew-form` seguem abrindo; `PUBLIC_ROUTES` inclui os caminhos novos
- definition of done: as cinco copias usam `/espaco/{nome}`; as rotas velhas continuam; browser abre uma URL nova e uma antiga

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — `PUBLIC_ROUTES` precisa reconhecer `/espaco/` senão o cliente cai no login
- risco principal: regras, parceiro ou colaborador continuarem com o id
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: orcamento e codigo (`T-01`, `T-02`), API, painel, deploy
- prova minima desta task: testes dos cinco caminhos verdes; no browser, `/espaco/AR756/apresentacao` e `/venue/AR756/form` abrem
- criterio de escalada: parar se o nome da casa nao resolver uma dessas cinco paginas
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `security`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `03-design.md#Componentes e modulos impactados`
- caminhos candidatos: `src/lib/public-venue-presentation.ts`; `src/lib/public-venue-rules.ts`; `src/pages/VenueContacts.tsx`; `src/pages/VenuePresentation.tsx`; `src/pages/VenueBudgets.tsx`; `src/components/venue/VenueNav.tsx`; `src/App.tsx`; `src/lib/axios.ts`; `src/hooks/useBootstrapUser.ts`
- palavras-chave ou simbolos de busca: `publicVenuePresentationShareUrl`, `publicVenueRulesShareUrl`, `partner-form`, `crew-form`, `/venue/`
- testes provaveis: `src/lib/public-venue-presentation.test.ts`; `src/lib/public-venue-rules.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, schema Prisma
