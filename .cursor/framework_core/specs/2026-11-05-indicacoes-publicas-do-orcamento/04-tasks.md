# Tasks — Indicacoes publicas do orcamento

## Ordem macro

`T-01` abre a tabela. `T-02` e `T-03` dependem dela e podem correr em paralelo. `T-04` depende de `T-02` e de `T-03`. `T-05` depende de `T-03`. `T-04` e `T-05` podem correr em paralelo.

## Tasks

### T-01 - Criar o vinculo do orcamento com o parceiro indicado

- objetivo: persistir, no orcamento, qual contato foi indicado e em que posicao, sem copiar os dados do parceiro
- cobre requisitos: `R-02`, `R-12`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: o jeito de `ProposalService` ligar orcamento a outro registro, com `onDelete: Cascade` no Prisma
- prompt recomendado: `smart`
- estrategia de teste: `npx prisma validate` e a migration gerada so cria tabela e indices
- cenarios obrigatorios:
  - o par orcamento + contato e unico
  - `position` guarda a ordem
  - apagar orcamento ou contato declara cascata no Prisma
- definition of done:
  - `ProposalIndication` esta no schema e o client gera
  - a migration e aditiva e nao e aplicada em producao nesta task
  - nenhum campo de PII do parceiro foi duplicado na tabela

#### Context Pack

- frente principal: backend
- superficie sensivel: nao — a task so cria a tabela; a PII continua em `Contact`
- risco principal: copiar telefone e e-mail para o vinculo, ou escrever migration que altera tabela existente
- repos tocados: `backend`
- fora de escopo desta task: rotas, painel, pagina publica e aplicar `migrate deploy` em producao
- prova minima desta task: `npx prisma validate` aceita `ProposalIndication` com unico em `proposalId` + `contactId`, `position` e cascata Prisma nos dois lados; o SQL novo so cria `proposal_indication` e indices
- criterio de escalada: `normal` se a migration precisar tocar `proposal` ou `contact` alem da relacao
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Dados`
- libs obrigatorias: `database`, `node`
- documentos obrigatorios:
  - `03-design.md#Dados`
  - `.cursor/framework_core/project/project-decisions.md#D-03`
  - `.cursor/framework_global/framework-libs/database/skills/designing-relational-schemas.md`
  - `.cursor/framework_global/framework-libs/database/skills/writing-zero-downtime-migrations.md`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma` no model `Proposal` e no model `Contact`
- palavras-chave ou simbolos de busca: `ProposalService`, `onDelete: Cascade`, `relationMode`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, frontend

### T-02 - Gravar a selecao com permissao no espaco do orcamento

- objetivo: substituir, numa transacao, os vinculos daquele orcamento pelos fornecedores enviados
- cobre requisitos: `R-01`, `R-02`, `R-05`, `R-06`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: `ensureAuthenticate`, o repository Prisma e o formato de controller/factory/use case do dominio `proposal`
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case com repositorio em memoria ou Prisma mockado, mais um teste do controller para 401 sem token
- cenarios obrigatorios:
  - conjunto novo substitui o anterior e grava `position` na ordem, sem id repetido
  - lista vazia zera os vinculos
  - o mesmo conjunto gravado duas vezes termina igual
  - contato inexistente, de equipe ou de outro espaco responde 400 e nao grava nada
  - sem `SEND_PROPOSAL_INFO` naquele espaco responde 403
  - orcamento inexistente responde 404
- definition of done:
  - `PUT /proposal/indications/:proposalId` exige JWT
  - a checagem nao usa `ensurePermission`
  - log de erro nao imprime WhatsApp, e-mail nem nome
  - `npm test -- --run` do use case fica verde

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a gravacao decide qual PII de parceiro a pagina publica podera mostrar
- risco principal: aceitar contato de outro espaco ou tratar permissao de outro venue como suficiente
- repos tocados: `backend`
- fora de escopo desta task: o GET publico, o painel, a pagina e fechar `GET /contact/list`
- prova minima desta task: os cenarios de substituicao, 400, 403 e 404 do use case passam em `npm test -- --run`; pedido sem token no PUT responde 401
- criterio de escalada: `complete` se a permissao de venue nao puder ser lida pelo repository que ja existe e for preciso abrir o modelo de autorizacao inteiro
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Gravacao`
- libs obrigatorias: `node`, `patterns`, `security`, `database`
- documentos obrigatorios:
  - `03-design.md#Gravacao`
  - `.cursor/framework_core/topics/auth-and-security.md#Regras de execucao`
  - `.cursor/framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md`
  - `.cursor/framework_global/framework-libs/security/references/auth-and-access-control.md`
  - `.cursor/framework_global/framework-libs/node/references/node-express-coding-style.md`
- caminhos candidatos: `art56_server_v3/src/router/proposal.ts`, `art56_server_v3/src/middleware/ensureAuthenticate.ts`, um use case de `proposal` com factory e repository Prisma
- palavras-chave ou simbolos de busca: `ensureAuthenticate`, `SEND_PROPOSAL_INFO`, `UserVenuePermission`, `SUPPLIER`
- testes provaveis: `npm test -- --run` no use case novo
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, frontend, `ensurePermission` alem da decisao de nao usa-lo

### T-03 - Ler em publico so os parceiros indicados

- objetivo: devolver, sem login, os fornecedores vinculados aquele orcamento, na ordem salva e com o cadastro atual
- cobre requisitos: `R-07`, `R-08`, `R-12`, `R-13`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: o `GET /proposal/byId/:proposalId`, que ja e publico no mesmo router
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case com vinculos de fornecedor, de equipe e de outro orcamento
- cenarios obrigatorios:
  - sem token, a lista volta na ordem de `position` com os oito campos do cadastro
  - fornecedor nao vinculado e contato de equipe ficam de fora
  - orcamento sem vinculo responde 200 e lista vazia
  - orcamento inexistente responde 404 sem lista
  - contato apagado nao aparece
- definition of done:
  - `GET /proposal/indications/:proposalId` nao usa `ensureAuthenticate`
  - a resposta nao inclui catalogo do espaco nem campo fora do contrato
  - uma linha em `topics/auth-and-security.md` registra esta rota na allowlist publica
  - `npm test -- --run` do use case fica verde

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a resposta publica leva WhatsApp e e-mail dos parceiros indicados
- risco principal: devolver todo `SUPPLIER` do espaco, ou um contato de equipe ligado por engano
- repos tocados: `backend`
- fora de escopo desta task: o PUT, o painel, a pagina e tornar privada a listagem geral de contatos
- prova minima desta task: o use case, sem token, devolve so os fornecedores vinculados, na ordem, e responde 404 para orcamento ausente; o teste nao precisa de sessao
- criterio de escalada: `complete` se o `byId` publico da proposta tiver um filtro de campos que esta leitura precise copiar alem do id
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Leitura publica`
- libs obrigatorias: `node`, `security`, `database`
- documentos obrigatorios:
  - `03-design.md#Leitura publica`
  - `.cursor/framework_core/topics/auth-and-security.md#Regras de execucao`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md`
  - `.cursor/framework_global/framework-libs/node/references/node-express-coding-style.md`
- caminhos candidatos: `art56_server_v3/src/router/proposal.ts` no `GET /byId/:proposalId`
- palavras-chave ou simbolos de busca: `byId`, `position`, `SUPPLIER`
- testes provaveis: `npm test -- --run` no use case novo
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, frontend, pagamento

### T-04 - Trocar o WhatsApp por salvar e copiar o link

- objetivo: Enviar Parceiros grava a selecao, remarca ao reabrir e oferece o link da pagina
- cobre requisitos: `R-01`, `R-03`, `R-04`
- depende de: `T-02`, `T-03`
- pode rodar em paralelo com: `T-05`
- reusa: a lista de fornecedores, `FilterList`, o toast de erro e a rota protegida atuais
- prompt recomendado: `normal`
- estrategia de teste: exercitar a tela no browser; se o banco local impedir o login, registrar o que ficou sem prova
- cenarios obrigatorios:
  - marcar, salvar e recarregar mantem os mesmos parceiros
  - salvar nao abre WhatsApp e nao mostra a caixa de mensagem
  - desmarcar todos e salvar deixa a selecao vazia
  - falha da API mostra erro e nao apresenta a selecao como salva
  - copiar o link usa a origem do painel e o caminho `/proposal/:id/indications`
- definition of done:
  - a tela nao chama `wa.me`
  - o catalogo continua vindo da listagem de contatos do espaco
  - a rota do painel segue exigindo `SEND_PROPOSAL_INFO`

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — a tela autenticada so envia ids; quem autoriza e a API da `T-02`
- risco principal: o botao continuar abrindo WhatsApp, ou a remarcacao usar a lista inteira de fornecedores como se todos tivessem sido indicados
- repos tocados: `frontend`
- fora de escopo desta task: a pagina publica, o visual da casca, Enviar Orcamento e Entrar em contato
- prova minima desta task: no painel, salvar uma selecao nao abre WhatsApp; recarregar mantem os marcados; o link copiado termina em `/proposal/:id/indications`; esvaziar e salvar desmarca todos
- criterio de escalada: `complete` se o store de proposta nao tiver o orcamento aberto e a tela precisar de um fluxo novo de carregamento
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Painel`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Painel`
  - `03-design.md#Gravacao`
  - `03-design.md#Leitura publica`
  - `.cursor/framework_global/framework-libs/react/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/SendSuppliers.tsx`, `eventhub-vista-dashboard/src/App.tsx` na rota `send-suppliers`
- palavras-chave ou simbolos de busca: `wa.me`, `selectedContacts`, `SEND_PROPOSAL_INFO`
- testes provaveis: fluxo de salvar, recarregar, esvaziar e copiar o link no browser
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, schema

### T-05 - Abrir a pagina publica das indicacoes

- objetivo: mostrar os parceiros indicados na casca das listas publicas, so com os campos preenchidos
- cobre requisitos: `R-09`, `R-10`, `R-11`
- depende de: `T-03`
- pode rodar em paralelo com: `T-04`
- reusa: `PublicVenueListShell`, `usePublicListVenue`, `public-list-pattern.ts` e `GET /proposal/byId/:proposalId`
- prompt recomendado: `smart`
- estrategia de teste: abrir a rota sem sessao no browser, com indicacao, sem indicacao e com campo vazio
- cenarios obrigatorios:
  - a pagina sem login mostra nome, funcao e so os contatos preenchidos
  - WhatsApp, e-mail e rede apontam para o destino certo e a rede abre em nova aba
  - lista vazia mostra a frase combinada, na marca do espaco
  - durante o carregamento a casca nao cai na marca EventHub
  - sair da rota devolve a aba ao titulo EventHub
- definition of done:
  - a rota nova nao usa `ProtectedRoute`
  - a pagina nao busca `GET /contact/list`
  - campo vazio nao renderiza link

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a tela publica exibe WhatsApp e e-mail que a API devolver
- risco principal: buscar o catalogo de contatos do espaco, ou montar a pagina fora da casca e perder a marca
- repos tocados: `frontend`
- fora de escopo desta task: o painel, gravacao, foto ou descricao nova, e as outras paginas publicas
- prova minima desta task: sem login, `/proposal/:id/indications` lista so os indicados na casca das listas; campo vazio some; orcamento sem indicacao mostra "Ainda nao ha indicacoes para o seu evento."; a aba usa o nome do espaco e volta ao titulo EventHub ao sair
- criterio de escalada: `normal` se `usePublicListVenue` nao receber o `venueId` que `byId` ja devolve e a marca precisar de outro endpoint
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Pagina publica`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Pagina publica`
  - `03-design.md#Leitura publica`
  - `.cursor/framework_core/task-requests/marca-espaco-listas-publicas-request.md#Objetivo da mudanca`
  - `.cursor/framework_global/framework-libs/design/skills/designing-empty-loading-error-states.md`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/GuestList.tsx`, `eventhub-vista-dashboard/src/components/proposal/PublicVenueListShell.tsx`, `eventhub-vista-dashboard/src/App.tsx`
- palavras-chave ou simbolos de busca: `PublicVenueListShell`, `usePublicListVenue`, `guest-list`
- testes provaveis: abrir a rota sem sessao com lista cheia, lista vazia e campo ausente
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, schema, Enviar Orcamento
