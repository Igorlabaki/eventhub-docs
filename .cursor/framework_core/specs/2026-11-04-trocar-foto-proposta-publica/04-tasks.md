# Tasks — Trocar a foto do link de orcamento

## Ordem macro

1. `T-01` grava a coluna e faz o link e a reordenacao lerem essa marca.
2. `T-02` grava a troca e so entao entrega o catalogo a quem pode usa-lo.
3. `T-03` coloca o controle na pagina.

`T-02` depende de `T-01`. `T-03` depende de `T-02`. Nenhuma roda em paralelo.

## Tasks

### T-01 - Marcar a foto que entra no link

- objetivo: a foto do espaco passa a ter `isShowOnProposal`, e o link e a reordenacao usam so essa marca
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-14`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: o filtro e a ordenacao que a apresentacao e o `image-order` ja tem
- prompt recomendado: `normal`
- estrategia de teste: vitest no repositorio da apresentacao e no plano de posicoes visiveis; conferencia do SQL da migration; `npx prisma validate`
- cenarios obrigatorios: link filtra `isShowOnProposal` verdadeiro; foto so do site fica de fora; reordenacao nao altera posicao de foto fora do link; o update das imagens da organizacao nao escreve a coluna nova; a migration copia a marca do site e nao a apaga
- definition of done: coluna nullable no schema, migration aditiva com o backfill, testes acima verdes, site da organizacao ainda le `isShowOnOrganization`

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a leitura da proposta e publica
- risco principal: o link passar a esconder as fotos atuais, ou o site mudar junto
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: endpoint de troca, catalogo, botao e dialogo
- prova minima desta task: vitest mostra o filtro novo e uma foto so do site de fora; a migration contem a coluna nullable e o `UPDATE` de backfill; `npx prisma validate` aceita o schema
- criterio de escalada: parar se a coluna precisar ser not null ou se o backfill nao puder ser um `UPDATE` unico
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Coluna`
- libs obrigatorias: `database`, `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Coluna`
  - `03-design.md#Leitura`
  - `.cursor/framework_global/framework-libs/database/skills/writing-zero-downtime-migrations.md`
  - `.cursor/framework_core/project/project-decisions.md#D-03`
  - `.cursor/framework_global/framework-libs/security/references/auth-and-access-control.md#Principios`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` modelo `Image`; `proposal-in-prisma-repository.ts` em `getPresentation` e `listVenueImagesForReorder`; update das imagens da organizacao
- palavras-chave ou simbolos de busca: `isShowOnOrganization`, `isShowOnProposal`, `listVenueImagesForReorder`
- testes provaveis: `use-case-get-proposal-presentation.spec.ts`; spec da reordenacao que exige o conjunto visivel
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `ProposalView.tsx`

### T-02 - Gravar a troca da foto

- objetivo: o dono daquele espaco substitui a foto de um lugar do link por qualquer foto do espaco, e o visitante nao recebe o catalogo
- cobre requisitos: `R-05`, `R-06`, `R-07`, `R-08`, `R-09`, `R-10`, `R-11`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `ensureAuthenticate`, `EDIT_VENUE_SITE` e o use case de `image-order`
- prompt recomendado: `normal`
- estrategia de teste: vitest do use case com repositorio falso, mais o GET publico serializado
- cenarios obrigatorios: 401, 403 e 404; 400 sem escrita para outro espaco e para origem fora do link; mesmo id sem escrita; foto oculta entra no lugar e a anterior sai; duas visiveis trocam de posicao e continuam visiveis; GET sem token nao contem a URL oculta; GET do dono traz essa URL no catalogo
- definition of done: `PUT /proposal/presentation/:proposalId/image-choice` no padrao router, controller, use case e repository; transacao curta; testes acima verdes

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — escrita a partir da pagina publica e catalogo de fotos ocultas
- risco principal: visitante gravar a troca ou receber URL de foto de fora do link
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: botao, dialogo e qualquer escrita de `isShowOnOrganization`
- prova minima desta task: vitest cobre 401, 403, 400 sem escrita, substituicao, troca de lugar e o JSON publico sem a URL oculta
- criterio de escalada: parar se a permissao precisar ser outra que nao `EDIT_VENUE_SITE`, ou se o catalogo tiver de ir no GET mesmo sem permissao
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Troca`
- libs obrigatorias: `node`, `patterns`, `security`, `database`
- documentos obrigatorios:
  - `03-design.md#Troca`
  - `03-design.md#Leitura`
  - `.cursor/framework_global/framework-libs/security/references/auth-and-access-control.md#Principios`
  - `.cursor/framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md`
  - `.cursor/framework_core/topics/auth-and-security.md#Regras de execucao`
- caminhos candidatos: `art56_server_v3/src/router/proposal.ts`; `use-cases/proposal/reorder-proposal-images/`; `get-proposal-presentation`
- palavras-chave ou simbolos de busca: `image-order`, `canReorder`, `EDIT_VENUE_SITE`, `ensureAuthenticate`
- testes provaveis: spec do use case de reordenacao, como modelo de 401, 403 e conjunto invalido
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `ProposalView.tsx`, formulario do site

### T-03 - Trocar a foto na pagina publica

- objetivo: o dono abre o catalogo num controle a parte, troca a foto e ve o resultado permanecer depois de recarregar
- cobre requisitos: `R-08`, `R-12`, `R-13`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: `canReorder`, o `Dialog` de `ProposalView` e o estado local da ordem
- prompt recomendado: `normal`
- estrategia de teste: funcao pura da troca e da restauracao; browser com dono logado e com o link sem essa sessao
- cenarios obrigatorios: dono troca, recarrega e ve a foto nova no lugar; visitante nao ve o controle; uma unica foto nao mostra o controle; falha ao gravar restaura a foto anterior; clique na grade abre o carrossel; o botao de trocar nao abre o carrossel
- definition of done: controle e dialogo na capa e na grade, chamada no `proposal.service`, estados disabled e de erro, prova no browser registrada no state da spec

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o controle aparece numa pagina publica
- risco principal: o visitante ver o seletor, ou o clique de trocar deixar de abrir o carrossel para quem so olha
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: schema, endpoint e marca do site
- prova minima desta task: dono logado troca uma foto, recarrega e ve a nova; o link sem essa sessao nao mostra o controle e o clique na grade abre o carrossel
- criterio de escalada: parar se a troca precisar de um estado global novo ou de uma tela no painel
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Pagina`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Pagina`
  - `03-design.md#Troca`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
  - `.cursor/framework_core/project/project-decisions.md#D-05`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalView.tsx`; `src/services/proposal.service.ts`; tipo `ProposalPresentation`
- palavras-chave ou simbolos de busca: `canReorder`, `dragBindings`, `setActivePhoto`, `reorderProposalImages`
- testes provaveis: `src/lib/reorder-proposal-images` como modelo da funcao pura
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, migration e use case alem do contrato em `03-design.md#Troca`
