# Tasks — Reordenar fotos da proposta publica

## Ordem macro

`T-01` libera o contrato de leitura. `T-02` grava a ordem e depende de `T-01`. `T-03` arrasta na pagina e depende de `T-02`. Nenhuma corre em paralelo.

## Tasks

### T-01 - Expor id e canReorder na apresentacao

- objetivo: a leitura publica identifica cada foto visivel e diz se o usuario atual pode reordenar, sem deixar de responder para quem nao tem sessao
- cobre requisitos: `R-01`, `R-03`, `R-10`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `getPresentation` e a checagem de `UserVenuePermission` por espaco
- prompt recomendado: normal
- estrategia de teste: vitest do use case com repositorio e permissao falsos
- cenarios obrigatorios:
  - sem token, 200, `canReorder: false` e cada foto com `id`
  - dono com `EDIT_VENUE_SITE` naquele espaco, `canReorder: true`
  - autenticado sem essa permissao naquele espaco, `canReorder: false`
  - token invalido, 200 e `canReorder: false`
  - proposta ausente, 404
- definition of done:
  - `GET /proposal/presentation/:proposalId` segue publico
  - foto oculta nao entra na lista
  - vitest desses cinco casos verde
  - nenhum topic, decisao ou ADR novo

#### Context Pack

- frente principal: backend
- superficie sensivel: sim
- risco principal: token invalido passar a responder 401 na pagina publica
- repos tocados: `backend`
- fora de escopo desta task: gravar posicao, arraste e carrossel
- prova minima desta task: os cinco cenarios do vitest
- criterio de escalada: parar se a leitura precisar de coluna nova ou de autenticacao obrigatoria
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contrato de leitura`
- libs obrigatorias: `node`, `security`
- documentos obrigatorios:
  - `03-design.md#Contrato de leitura`
  - `.cursor/framework_global/framework-libs/security/references/auth-and-access-control.md#Principios`
  - `.cursor/framework_core/topics/auth-and-security.md#Regras de execucao`
  - `.cursor/framework_core/project/project-decisions.md#D-05`
- caminhos candidatos: `art56_server_v3/src/use-cases/proposal/get-proposal-presentation/`; `art56_server_v3/src/router/proposal.ts`
- palavras-chave ou simbolos de busca: `canReorder`, `getPresentation`, `EDIT_VENUE_SITE`, `ensureAuthenticate`
- testes provaveis: `use-case-get-proposal-presentation.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, upload e o painel

### T-02 - Gravar a ordem das fotos visiveis

- objetivo: o dono autorizado grava a ordem solta nas posicoes das fotos visiveis, e qualquer outro conjunto ou usuario e recusado sem escrita
- cobre requisitos: `R-02`, `R-04`, `R-06`, `R-08`, `R-09`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `ensureAuthenticate`, `image.position` e a transacao curta do Prisma
- prompt recomendado: normal
- estrategia de teste: vitest do use case com repositorio falso que registra se houve update
- cenarios obrigatorios:
  - sem token, 401 e sem update
  - autenticado sem `EDIT_VENUE_SITE` naquele espaco, 403 e sem update
  - ids repetidos ou conjunto diferente, 400 e sem update
  - ordem nova, posicoes gravadas na ordem enviada
  - a mesma ordem, 200 sem update
  - foto oculta permanece com a posicao anterior
- definition of done:
  - `PUT /proposal/presentation/:proposalId/image-order` exige autenticacao
  - a escrita cabe numa transacao sem chamada externa
  - vitest desses seis casos verde
  - `PUT /image/update` permanece intocado

#### Context Pack

- frente principal: backend
- superficie sensivel: sim
- risco principal: gravar foto de outro espaco ou apagar a posicao de uma foto oculta
- repos tocados: `backend`
- fora de escopo desta task: arraste, carrossel e mudanca de schema
- prova minima desta task: os seis cenarios do vitest
- criterio de escalada: parar se a gravacao precisar de migration ou de lock fora da transacao curta
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Gravacao da ordem`
- libs obrigatorias: `node`, `patterns`, `database`, `security`
- documentos obrigatorios:
  - `03-design.md#Gravacao da ordem`
  - `.cursor/framework_global/framework-libs/database/rules/05_transactions_and_locking.md#Regras`
  - `.cursor/framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md`
  - `.cursor/framework_global/framework-libs/security/references/auth-and-access-control.md#Principios`
  - `.cursor/framework_core/topics/auth-and-security.md#Regras de execucao`
- caminhos candidatos: `art56_server_v3/src/router/proposal.ts`; `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts#getPresentation`
- palavras-chave ou simbolos de busca: `image-order`, `isShowOnOrganization`, `position`, `EDIT_VENUE_SITE`
- testes provaveis: spec novo ao lado do use case de apresentacao
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, S3 e o formulario de Posicao

### T-03 - Arrastar as fotos na pagina publica

- objetivo: o dono arrasta capa e galeria, solta, e a ordem permanece apos recarregar; o visitante nao arrasta
- cobre requisitos: `R-02`, `R-05`, `R-07`, `R-11`, `R-12`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: `ProposalView`, o carrossel de "A casa" e o arraste nativo do browser
- prompt recomendado: normal
- estrategia de teste: funcao pura da troca de posicao e da restauracao; prova de ponta no browser
- cenarios obrigatorios:
  - dono arrasta a capa para a grade, recarrega e ve a capa nova
  - visitante nao ve alca de arraste e ve a ordem gravada
  - falha do PUT restaura a ordem anterior na tela
  - clique sem movimento numa foto de "A casa" abre o carrossel
  - uma unica foto nao oferece arraste
  - galeria com quantidade impar mantem a ultima foto na largura das duas colunas
- definition of done:
  - a gravacao acontece ao soltar, sem botao extra
  - o carrossel nao inclui a capa
  - a funcao pura tem teste verde
  - o fluxo do dono e o do visitante foram exercitados no browser
  - nenhum pacote novo de arraste

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim
- risco principal: o visitante ver o arraste ou o clique deixar de abrir o carrossel
- repos tocados: `frontend`
- fora de escopo desta task: autorizacao no backend, painel e teclado
- prova minima desta task: arraste com recarga no browser e visitante sem alca
- criterio de escalada: parar se a pagina precisar de uma terceira forma de estado alem do estado local que ja tem
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Arraste na pagina`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Arraste na pagina`
  - `.cursor/framework_global/framework-libs/react/index.md#Criacao de componente React`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalView.tsx`; `eventhub-vista-dashboard/src/services/proposal.service.ts#ProposalPresentation`
- palavras-chave ou simbolos de busca: `canReorder`, `gallery`, `activePhoto`, `col-span-2`
- testes provaveis: teste da funcao que reordena a lista e restaura a anterior; browser na rota `/proposal/:id/view`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, backend e o painel
