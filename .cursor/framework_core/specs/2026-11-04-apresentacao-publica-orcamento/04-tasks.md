# Tasks — Apresentacao publica do orcamento

## Ordem macro

1. `T-01` cria as tres colunas
2. `T-02` e `T-03` podem seguir em paralelo
3. `T-04` espera a gravacao; `T-05` espera o pacote publico
4. `T-04` e `T-05` podem seguir em paralelo

Nao executar o conjunto num unico passo. Depois do review, `fw:split` separa `backend` e `frontend`.

## Tasks

### T-01 - Colunas de cor da proposta no venue

- objetivo: persistir cor primaria, secundaria e de texto no venue, nulas ate alguem gravar
- cobre requisitos: `R-08`, `R-09`, `R-12`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: colunas opcionais ja existentes no `Venue`, como `logoUrl`
- prompt recomendado: `normal`
- estrategia de teste: `npx prisma validate` e leitura do SQL gerado
- cenarios obrigatorios: tres colunas `VarChar(7)` nulas, sem default e sem backfill; a migration nao altera outras colunas de `venue`
- definition of done: model, migration aditiva e `prisma validate` verdes; sem promocao de topic

#### Context Pack

- frente principal: banco
- superficie sensivel: nao
- risco principal: migration que reescreve `venue` ou preenche cor para todas as casas
- repos tocados: `backend`
- fora de escopo desta task: rota, tela e validacao de hex
- prova minima desta task: `npx prisma validate` ok e o SQL so adiciona `proposalPrimaryColor`, `proposalSecondaryColor` e `proposalTextColor` nulas
- criterio de escalada: parar se a migration precisar copiar ou apagar linha de `venue`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/database/skills/writing-zero-downtime-migrations.md`
  - `.cursor/framework_core/project/project-decisions.md#D-03`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` model `Venue`
- palavras-chave ou simbolos de busca: `model Venue`, `proposalPrimaryColor`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: `security`, `01-spec.md`, `ProposalView`

### T-02 - Gravar as tres cores no update do venue

- objetivo: Configuracoes consegue persistir hex valido ou nulo, e request sem token nao grava
- cobre requisitos: `R-08`, `R-09`, `R-10`, `R-12`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: `PUT /venue/update` e o schema Zod desse update
- prompt recomendado: `normal`
- estrategia de teste: teste do use case ou da validacao com hex, vazio e invalido; chamada sem token nao persiste
- cenarios obrigatorios: `#112233` grava; `""` grava nulo; `vermelho` responde 400 e nao grava; request sem autenticacao nao grava
- definition of done: os tres campos passam pelo update autenticado e a resposta de sucesso nao e o contrato da pagina publica; sem promocao de topic

#### Context Pack

- frente principal: backend
- superficie sensivel: sim
- risco principal: aceitar cor por uma rota anonima ou devolver o venue inteiro para a pagina publica
- repos tocados: `backend`
- fora de escopo desta task: tela, pacote publico e permissao nova
- prova minima desta task: hex valido e vazio persistem no venue autenticado; valor invalido responde 400; request sem token nao altera a coluna
- criterio de escalada: parar se a gravacao exigir uma rota nova ou uma permissao que Configuracoes ainda nao usa
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Cores no cadastro`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Cores no cadastro`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md`
  - `.cursor/framework_core/topics/auth-and-security.md#Regras de execucao`
- caminhos candidatos: `art56_server_v3/src/use-cases/venue/update-venue/`, `art56_server_v3/src/zod/venue/update-venue-params-schema.ts`
- palavras-chave ou simbolos de busca: `UpdateVenueUseCase`, `ensureAuthenticate`, `proposalPrimaryColor`
- testes provaveis: vitest do schema ou do use case; request sem token
- nao ler por padrao: `ProposalView`, `01-spec.md`

### T-03 - Pacote publico da casa por orcamento

- objetivo: o link publico le so o recorte de apresentacao da casa daquele orcamento
- cobre requisitos: `R-02`, `R-03`, `R-04`, `R-05`, `R-11`, `R-14`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: router de proposal, `venue_amenity` e o filtro `isShowOnOrganization`
- prompt recomendado: `normal`
- estrategia de teste: teste do use case ou do repositorio com select explicito e um caso sem orcamento
- cenarios obrigatorios: foto marcada e caracteristica entram; foto desmarcada, dono, contrato, pagamento, rua e preco nao entram; id inexistente nao devolve casa; a rota nao usa `ensureAuthenticate`
- definition of done: `GET /proposal/presentation/:proposalId` responde o objeto de `03-design.md#Pacote publico`; sem promocao de topic

#### Context Pack

- frente principal: backend
- superficie sensivel: sim
- risco principal: `include` do venue devolver dono, contrato ou pagamento no link publico
- repos tocados: `backend`
- fora de escopo desta task: enxugar `GET /proposal/byId` e desenhar a pagina
- prova minima desta task: a resposta de um orcamento existente contem os campos da allowlist e nao contem `ownerVenue`, `contracts`, `Payment`, `street` nem `pricePerPerson`; id inexistente nao devolve casa
- criterio de escalada: parar se a leitura precisar da permissao `VIEW_VENUE_AMENITIES` ou do `GET /venue/getById`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Pacote publico`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Pacote publico`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md`
- caminhos candidatos: `art56_server_v3/src/router/proposal.ts`, `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `getById`, `isShowOnOrganization`, `VenueAmenity`, `proposalServices`
- testes provaveis: vitest da leitura com allowlist e id inexistente
- nao ler por padrao: `VenueSettings`, `01-spec.md`

### T-04 - Cores em Configuracoes do espaco

- objetivo: quem edita Configuracoes grava, reve e limpa as tres cores
- cobre requisitos: `R-08`, `R-09`, `R-10`, `R-12`
- depende de: `T-02`
- pode rodar em paralelo com: `T-05`
- reusa: formulario e submit de `VenueSettings`
- prompt recomendado: `normal`
- estrategia de teste: `npm run lint` no frontend e a tela no browser
- cenarios obrigatorios: gravar tres hex e ve-los ao reabrir; limpar volta a nulo; valor invalido nao salva; o painel fora dessa tela nao muda de cor
- definition of done: os campos estao em `/venue/:id/settings` e o submit existente envia as cores; sem promocao de topic

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: criar outra forma de estado ou uma tela nova fora de Configuracoes
- repos tocados: `frontend`
- fora de escopo desta task: pintar `ProposalView` e criar permissao
- prova minima desta task: em Configuracoes, gravar as tres cores, recarregar e ve-las; limpar e recarregar mostra o padrao
- criterio de escalada: parar se as cores precisarem de uma rota que nao seja o update do venue
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Cores no cadastro`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Cores no cadastro`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
  - `.cursor/framework_core/project/project-decisions.md#D-05`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueSettings.tsx`
- palavras-chave ou simbolos de busca: `VenueSettings`, `EDIT_VENUE_INFO`, `proposalPrimaryColor`
- testes provaveis: `npm run lint`; gravar e limpar na tela
- nao ler por padrao: `security`, `ProposalView`, `01-spec.md`

### T-05 - Pagina publica da casa antes do valor

- objetivo: `/proposal/:id/view` apresenta a casa e deixa o card de valor no fim
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-06`, `R-07`, `R-09`, `R-10`, `R-13`
- depende de: `T-03`
- pode rodar em paralelo com: `T-04`
- reusa: card de valor, footer e helpers wall-clock de `ProposalView`
- prompt recomendado: `normal`
- estrategia de teste: `npm run build`, `npm run lint` e o fluxo no browser
- cenarios obrigatorios: casa completa mostra a ordem da spec antes do total; sem foto, sem caracteristica ou sem servico omite so esse bloco; sem logo usa o fallback; cor gravada aparece no container da proposta e nao no painel; a pagina nao chama `fetchVenueById`
- definition of done: a pagina usa o pacote publico e o orcamento atual; sem promocao de topic

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim
- risco principal: a pagina continuar em `GET /venue/getById` e levar dono ou contrato para o cliente
- repos tocados: `frontend`
- fora de escopo desta task: gravar cor, mudar calculo e enxugar `GET /proposal/byId`
- prova minima desta task: no browser, a casa aparece antes do total; secoes vazias somem; as cores do pacote ficam so nessa pagina; a rede da pagina nao chama `/venue/getById`
- criterio de escalada: parar se a tela precisar da lista autenticada de caracteristicas
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Pagina publica`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Pagina publica`
  - `03-design.md#Pacote publico`
  - `.cursor/framework_global/framework-libs/design/rules/03_layout_grid_and_hierarchy.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalView.tsx`, `eventhub-vista-dashboard/src/components/proposalFooter.tsx`
- palavras-chave ou simbolos de busca: `ProposalView`, `fetchVenueById`, `wallClockDateBr`, `proposalServices`
- testes provaveis: `npm run build`; `npm run lint`; pagina no browser com e sem foto, caracteristica, servico e cor
- nao ler por padrao: `VenueSettings`, `01-spec.md`
