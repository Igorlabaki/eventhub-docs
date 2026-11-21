# Improvement Backlog — EventHub

Lista viva de tudo que esta errado, perigoso ou precisa melhorar no EventHub. Cada item ja vem no formato de task-request para virar task (`fw:intake`) ou spec (`fw:spec`). Criado em 2026-11-10 a partir do mapeamento completo do workspace.

Retrato atual e lacunas gerais: `topics/delivery-and-known-gaps.md`. Este arquivo e o backlog acionavel.

## Como usar

- **adicionar item**: copie o modelo do fim do arquivo, use o proximo numero do prefixo, preencha evidencia (arquivo e linha, rota ou comando) e inclua a linha na tabela-indice;
- **virar trabalho**: item simples e local vai por `fw:intake`; item que mexe em contrato, dados, dinheiro, auth ou varios repos vai por `fw:spec`. Grave o nome da task ou spec em `Virou` e mude o status;
- **nunca apagar item**: resolvido muda para `resolvido em AAAA-MM-DD` com a prova; descartado muda para `descartado` com o motivo;
- **antes de executar**: reconfirme a evidencia no codigo (o item pode ter mudado) e leia o topic da area;
- **seguranca**: nunca copie valor de `.env` ou segredo para ca; so nomes de variaveis.

### Legendas

- tipo: `perigo` (seguranca ou perda de dados), `bug` (comportamento errado hoje), `divida` (estrutura que atrapalha), `melhoria` (ganho novo), `divergencia` (documento diz uma coisa, codigo outra);
- severidade: `critica` (expoe dados, dinheiro ou permite abuso agora), `alta` (quebra fluxo de cliente ou produto), `media` (custo de manutencao ou risco moderado), `baixa` (higiene);
- status: `aberto`, `em analise`, `virou task <nome>`, `virou spec <nome>`, `resolvido em <data>`, `descartado`;
- prefixos: `SEC` seguranca, `AUTH` sessao e rotas publicas, `PERM` permissoes, `API` contrato HTTP, `PRICE` preco, `PROP` ciclo da proposta, `DATA` dados e schema, `DIV` divergencias de artefato, `TEST` testes, `OBS` observabilidade, `INFRA` entrega e configuracao, `FE` frontend, `HYG` higiene, `DOC` documentacao.

## Indice

| ID | Titulo | Tipo | Severidade | Repo | Status | Virou |
|---|---|---|---|---|---|---|
| SEC-01 | Rotas de pagamento e taxa sazonal sem autenticacao | perigo | critica | backend, frontend | aberto | — |
| SEC-02 | Documentos, contratos e clausulas sem autenticacao | perigo | critica | backend, frontend | aberto | — |
| SEC-03 | Dados pessoais (PII) expostos em rotas publicas | perigo | critica | backend, frontend | aberto | — |
| SEC-04 | Envio de e-mail e configuracao de e-mail publicos | perigo | critica | backend | aberto | — |
| SEC-05 | Uploads publicos sem limite de tamanho | perigo | alta | backend | aberto | — |
| SEC-06 | Conteudo do site, FAQ e programacao editaveis sem login | perigo | alta | backend | aberto | — |
| SEC-07 | Autenticacao sem rate limit | perigo | alta | backend | aberto | — |
| SEC-08 | CORS aberto, `CORS_ORIGIN` ignorada e sem helmet | perigo | alta | backend | aberto | — |
| SEC-09 | Erro 500 devolve detalhe interno ao cliente | perigo | media | backend | aberto | — |
| SEC-10 | Valor com aparencia de credencial no `.env.example` | perigo | critica | backend | aberto | — |
| SEC-11 | Token da API da Vercel no bundle do navegador | perigo | alta | frontend | aberto | — |
| SEC-12 | JWT sem checagem de sessao/revogacao e token em localStorage | perigo | media | backend, frontend | aberto | — |
| AUTH-01 | `PUBLIC_ROUTES` errada e duplicada manda cliente para o login | bug | alta | frontend | aberto | — |
| AUTH-02 | `/profile` fora do `ProtectedRoute` | bug | baixa | frontend | aberto | — |
| PERM-01 | Permissoes divergentes entre sidebar, rota e backend | bug | alta | frontend, backend | aberto | — |
| PERM-02 | Backend quase nao checa permissao por recurso | perigo | alta | backend | aberto | — |
| API-01 | Frontend chama rotas que nao existem no backend | bug | media | frontend | aberto | — |
| API-02 | Rotas com defeito de declaracao | bug | media | backend | aberto | — |
| API-03 | `express.json` duplicado limita JSON a 100 kb | bug | media | backend | aberto | — |
| API-04 | `controller.handle` sem `await` em rotas com upload | bug | media | backend | aberto | — |
| API-05 | Sem handler global de erro, 404 proprio e logger HTTP | divida | media | backend | aberto | — |
| PRICE-01 | Dinheiro em `Float` sem regra de arredondamento | perigo | alta | backend, frontend | aberto | — |
| PRICE-02 | Regra sazonal + meta em tres implementacoes com fusos diferentes | bug | alta | backend | aberto | — |
| PRICE-03 | `TIERED` selecionavel sem calculo | bug | media | backend, frontend | aberto | — |
| PRICE-04 | Funcoes de preco legadas, uma com bug e uma vazia | divida | baixa | backend | aberto | — |
| PRICE-05 | Despesa recorrente `WEEKLY` ignorada na analise | bug | media | backend | resolvido 2026-11-14 | spec `investimento-anuncios-por-canal` |
| PRICE-06 | Esporadicas de janeiro do ano seguinte na analise de despesas | bug | media | backend | resolvido 2026-11-14 | spec `investimento-anuncios-por-canal` |
| PROP-01 | Proposta sem maquina de estados; `paid` nunca vira `true` | divida | alta | backend, frontend | aberto | — |
| DATA-01 | Fluxos com varias escritas sem transacao | perigo | alta | backend | aberto | — |
| DATA-02 | Schema vai para producao sem staging nem aprovacao obrigatoria | perigo | alta | infra | aberto | — |
| DATA-03 | Campos e relacoes legados no schema | divida | baixa | backend | aberto | — |
| DIV-01 | Spec DocuSign diz que ha codigo e migration que nao existem | divergencia | alta | backend, docs | aberto | — |
| DIV-02 | Midia de caracteristica (`VenueAmenity`) ausente no `schema.prisma` | divergencia | alta | backend, docs | resolvido 2026-11-12 | — |
| DIV-03 | `AGENTS.md` aponta `.cursor/framework_global/`, caminho real e outro | divergencia | baixa | docs | aberto | — |
| DIV-04 | Task-requests "revisar entrega" nao verificados contra o codigo | divergencia | media | docs | aberto | — |
| TEST-01 | Sem testes HTTP, de auth negativa, pagamento, documento e contrato | divida | alta | backend | aberto | — |
| TEST-02 | Sem CI nem gate de PR | divida | alta | backend, frontend | aberto | — |
| TEST-03 | Testes de frontend sem DOM (sem jsdom/Testing Library) | divida | media | frontend | aberto | — |
| TEST-04 | Sem conta e ambiente de teste para prova no browser | divida | alta | infra | aberto | — |
| OBS-01 | Sem log estruturado, correlation id, metricas e alertas | divida | media | backend | aberto | — |
| INFRA-01 | `package.json` do backend com build anomalo e `main` inexistente | bug | media | backend | aberto | — |
| INFRA-02 | Variaveis de ambiente divergentes dos `.env.example` | bug | media | backend, frontend | aberto | — |
| INFRA-03 | Dominio e remetentes de e-mail fixos no codigo | divida | media | backend, frontend | aberto | — |
| FE-01 | React Query e 30 stores Zustand convivendo | divida | media | frontend | aberto | — |
| FE-02 | `App.tsx` sem lazy loading e paginas com mais de 1000 linhas | divida | media | frontend | aberto | — |
| FE-03 | Codigo morto e componentes duplicados em `ui/` | divida | baixa | frontend | aberto | — |
| FE-04 | `PartnerForm` e `CrewForm` ignoram as cores da casa | bug | baixa | frontend | aberto | — |
| FE-05 | TypeScript frouxo e ESLint permissivo | divida | media | frontend | aberto | — |
| FE-06 | Token de cor inexistente e dark mode morto | bug | baixa | frontend | aberto | — |
| HYG-01 | Backend com dependencias sem uso, dois lockfiles e sobras | divida | baixa | backend | aberto | — |
| HYG-02 | Frontend com tres lockfiles, arquivo `Untitled` e dependencias sem uso | divida | baixa | frontend | aberto | — |
| DOC-01 | Backlog legado em `docs/` ainda nao convertido | divida | baixa | docs | aberto | — |

## Agrupamentos sugeridos para spec

Itens que devem andar juntos porque mexem no mesmo contrato:

| Spec sugerida | Itens | Por que juntos |
|---|---|---|
| Fechar rotas publicas sensiveis | SEC-01, SEC-02, SEC-03, SEC-04, SEC-06, PERM-02, TEST-01 | as paginas publicas usam varias dessas rotas; fechar exige token de link ou rota publica dedicada e testes 401/403 |
| Endurecer borda HTTP | SEC-05, SEC-07, SEC-08, SEC-09, API-03, API-04, API-05, OBS-01 | todos mudam `server.ts` e o tratamento de erro |
| Alinhar permissoes | PERM-01, AUTH-01, AUTH-02 | enum, rotas, sidebar e backfill na mesma entrega |
| Dinheiro e estado da proposta | PRICE-01, PRICE-02, PROP-01, DATA-01 | mudam calculo, schema e fluxo de pagamento juntos |
| Esteira de entrega | TEST-02, TEST-04, INFRA-01, INFRA-02, DATA-02 | CI, ambiente de teste e configuracao |

## Itens

### Seguranca

#### SEC-01 — Rotas de pagamento e taxa sazonal sem autenticacao

- tipo / severidade / repo: perigo / critica / backend, frontend
- problema: todo `/payment` e todo `/seasonalFee` aceitam chamada sem token.
- evidencia: `art56_server_v3/src/router/payment.ts` (linhas 15-36, nenhum `ensureAuthenticate`); `src/router/seasonal-fee.ts`; lista em `project/api-endpoints.md`.
- impacto: qualquer pessoa com um `proposalId` ou `paymentId` cria, altera ou apaga pagamento, o que muda `amountPaid` da proposta; qualquer pessoa altera taxa sazonal e, com isso, o preco de novos orcamentos.
- proposta: exigir `ensureAuthenticate` + permissao `VIEW/EDIT_PROPOSAL_PAYMENTS` (payment) e `VIEW/EDIT_VENUE_PRICES` (seasonalFee) com checagem de que o recurso pertence a venue do usuario; confirmar antes se alguma pagina publica usa essas rotas.
- criterios de aceite:
  - sem token: 401 em todas as rotas;
  - token sem permissao ou de outra venue: 403;
  - usuario com permissao: comportamento atual mantido;
  - telas do painel de pagamento e precos continuam funcionando.
- dependencias e riscos: PERM-02, TEST-01; usa lib `security`.
- encaminhamento: `fw:spec` (lote "Fechar rotas publicas sensiveis")
- status: aberto

#### SEC-02 — Documentos, contratos e clausulas sem autenticacao

- tipo / severidade / repo: perigo / critica / backend, frontend
- problema: `/document`, `/contract` e `/clause` sao 100% publicos, incluindo upload e delete.
- evidencia: `src/router/document.ts`, `contract.ts`, `clause.ts`; `DELETE /document/delete/:documentId` apaga o arquivo no S3 e recalcula `amountPaid`.
- impacto: leitura e apagamento de documentos de clientes, troca de modelos de contrato da organizacao.
- proposta: auth + `VIEW/EDIT_PROPOSAL_DOCUMENTS` (document) e `VIEW/EDIT_ORG_CONTRACTS` (contract, clause), com checagem de ownership.
- criterios de aceite: 401 sem token, 403 sem permissao ou fora da organizacao, painel de documentos e contratos funcionando, teste de ownership por rota.
- dependencias e riscos: PERM-02, TEST-01; verificar se a geracao de contrato publica (`/proposal/:id/person-contract`) depende de alguma dessas rotas.
- encaminhamento: `fw:spec` (lote "Fechar rotas publicas sensiveis")
- status: aberto

#### SEC-03 — Dados pessoais (PII) expostos em rotas publicas

- tipo / severidade / repo: perigo / critica / backend, frontend
- problema: rotas publicas devolvem ou alteram CPF/CNPJ/RG, endereco, telefone e dados bancarios.
- evidencia: todo `/person`, todo `/contact`, `GET /proposal/byId/:id`, `PUT /proposal/updatePersonalInfo`, `GET /notification/list/:venueId` (`project/api-endpoints.md`, secao "Endpoints publicos sensiveis").
- impacto: vazamento de dados pessoais (LGPD) e alteracao de dados contratuais por terceiros; `notification/list` e `contact/list` so precisam do `venueId`.
- proposta: separar o que a pagina publica precisa (apresentacao da proposta, lista de convidados, formulario de contrato) em rotas publicas dedicadas com payload minimo e token de link; o resto passa a exigir auth + permissao.
- criterios de aceite:
  - `GET /proposal/byId` exige auth; a pagina publica usa `presentation/:id` ou equivalente sem PII;
  - listas de pessoas e contatos exigem auth fora do fluxo publico com token;
  - paginas publicas (`ProposalView`, `GuestList`, `WorkerList`, formularios de contrato, parceiro e equipe) continuam funcionando;
  - testes 401/403 e de payload sem PII.
- dependencias e riscos: AUTH-01 (paginas publicas), decisao de produto sobre token de link.
- encaminhamento: `fw:spec`
- status: aberto

#### SEC-04 — Envio de e-mail e configuracao de e-mail publicos

- tipo / severidade / repo: perigo / critica / backend
- problema: `POST /email/proposal`, `POST /email/contract` e todo `/emailConfig` (com upload) nao exigem token.
- evidencia: `src/router/email.ts`, `src/router/email-config.ts`.
- impacto: uso do remetente da plataforma para spam ou phishing; alteracao do texto dos e-mails de uma venue.
- proposta: auth + `SEND_PROPOSAL_*` para envio e `EDIT_VENUE_INFO` (ou permissao nova) para configuracao; rate limit no envio.
- criterios de aceite: 401/403 testados; envio pelo painel funcionando; limite de envios por usuario.
- dependencias e riscos: SEC-07.
- encaminhamento: `fw:spec` (lote "Fechar rotas publicas sensiveis")
- status: aberto

#### SEC-05 — Uploads publicos sem limite de tamanho

- tipo / severidade / repo: perigo / alta / backend
- problema: 19 rotas com `multer` em memoria; 12 sao publicas e so `contact` e `service` limitam tamanho.
- evidencia: `src/router/payment.ts` linhas 11-12 (`multer({ storage })` sem `limits`); `image.ts`, `document.ts`, `email-config.ts`.
- impacto: estouro de memoria da funcao serverless e custo de S3 com arquivos arbitrarios.
- proposta: `limits.fileSize` e filtro de MIME em todos os uploads; reaproveitar o padrao de `contact-logo-storage` (5 MB, magic bytes).
- criterios de aceite: arquivo acima do limite recebe 413 com `{ title, message }`; tipos fora da lista recebem 400; testes por rota.
- encaminhamento: `fw:intake`
- status: aberto

#### SEC-06 — Conteudo do site, FAQ e programacao editaveis sem login

- tipo / severidade / repo: perigo / alta / backend
- problema: `/text`, `/question`, `/schedule` e `/image` (incluindo delete no S3) sao publicos para escrita.
- evidencia: `src/router/text.ts`, `question.ts`, `schedule.ts`, `image.ts`.
- impacto: desfiguracao do site publico da venue e da organizacao; apagamento de imagens.
- proposta: manter leitura publica onde o site precisa; escrita exige auth + `EDIT_VENUE_SITE`/`EDIT_ORG_SITE` (schedule: `EDIT_PROPOSAL_SCHEDULE`, conferindo a pagina publica `ScheduleList`).
- criterios de aceite: GET publicos inalterados; POST/PUT/DELETE com 401/403 testados; site publico e paginas de edicao funcionando.
- encaminhamento: `fw:spec` (lote "Fechar rotas publicas sensiveis")
- status: aberto

#### SEC-07 — Autenticacao sem rate limit

- tipo / severidade / repo: perigo / alta / backend
- problema: register, authenticate, forgot/reset password e refresh nao tem limite de tentativas.
- evidencia: `src/router/auth.ts`, `src/router/token.ts`; nenhum middleware de rate limit em `src/server.ts`.
- impacto: forca bruta de senha, enumeracao de e-mail e envio em massa de e-mails de reset.
- proposta: rate limit por IP e por e-mail nas rotas de auth e e-mail; resposta 429 padronizada. Em serverless, avaliar armazenamento compartilhado (ex.: Redis/Upstash) ou protecao na borda da Vercel.
- criterios de aceite: N tentativas por janela e depois 429; login normal sem impacto; teste automatizado.
- encaminhamento: `fw:spec` (lote "Endurecer borda HTTP")
- status: aberto

#### SEC-08 — CORS aberto, `CORS_ORIGIN` ignorada e sem helmet

- tipo / severidade / repo: perigo / alta / backend
- problema: `cors({ origin: "*" })` com metodo invalido `UPDATE`; `CORS_ORIGIN` existe no `.env.example` e nao e lida; nenhum header de seguranca.
- evidencia: `src/server.ts` linhas 40-45.
- impacto: qualquer site chama a API a partir do navegador do usuario; sem protecoes basicas de header.
- proposta: allowlist a partir de `CORS_ORIGIN` (lista separada por virgula), remover `UPDATE`, adicionar `helmet`.
- criterios de aceite: origem fora da lista sem header CORS; painel e paginas publicas funcionando nos dominios configurados; `CORS_ORIGIN` documentada.
- dependencias e riscos: INFRA-02, INFRA-03 (dominios reais).
- encaminhamento: `fw:intake`
- status: aberto

#### SEC-09 — Erro 500 devolve detalhe interno ao cliente

- tipo / severidade / repo: perigo / media / backend
- problema: erro nao mapeado responde `message: error.toString()`.
- evidencia: `src/errors/error-handler.ts` linha 99.
- impacto: vaza mensagens do Prisma, nomes de tabela e detalhes de infraestrutura.
- proposta: responder mensagem generica com id de correlacao e logar o detalhe no servidor.
- criterios de aceite: 500 sem detalhe interno; log com o erro completo e o mesmo id; teste do handler.
- dependencias e riscos: OBS-01.
- encaminhamento: `fw:intake`
- status: aberto

#### SEC-10 — Valor com aparencia de credencial no `.env.example`

- tipo / severidade / repo: perigo / critica / backend
- problema: o `.env.example` versionado do backend contem um valor que parece credencial real.
- evidencia: `art56_server_v3/.env.example` (valor nao reproduzido aqui de proposito).
- impacto: se for real, esta exposto no historico do git.
- proposta: tratar como incidente: confirmar com o dono, rotacionar a credencial no provedor, trocar o valor por placeholder e avaliar limpeza de historico.
- criterios de aceite: credencial rotacionada (confirmacao do dono), `.env.example` so com placeholders, nenhum outro segredo no repo (busca registrada).
- encaminhamento: `fw:intake` com aprovacao nomeada (credencial)
- status: aberto

#### SEC-11 — Token da API da Vercel no bundle do navegador

- tipo / severidade / repo: perigo / alta / frontend
- problema: `VITE_VERCEL_API_TOKEN` e lida em `services/analytics.service.ts`; toda variavel `VITE_*` vai para o bundle.
- evidencia: `eventhub-vista-dashboard/src/services/analytics.service.ts`; `project/frontend-map.md`.
- impacto: qualquer visitante extrai o token e acessa a conta da Vercel com o escopo dele.
- proposta: mover a chamada para o backend (rota autenticada que consulta a Vercel) e rotacionar o token.
- criterios de aceite: nenhum token no bundle (`npm run build` + busca no `dist/`); grafico de analytics funcionando via backend; token rotacionado.
- encaminhamento: `fw:spec` (cruza repos)
- status: aberto

#### SEC-12 — JWT sem checagem de sessao/revogacao e token em localStorage

- tipo / severidade / repo: perigo / media / backend, frontend
- problema: `ensureAuthenticate` so valida assinatura e `id`; Session e RefreshToken existem mas logout nao invalida o access token; token e sessao ficam em `localStorage`.
- evidencia: `src/middleware/ensureAuthenticate.ts` (versao com sessao comentada); `eventhub-vista-dashboard/src/lib/axios.ts`.
- impacto: token roubado (XSS) vale ate expirar; nao ha como derrubar sessao.
- proposta: decidir modelo (access curto + refresh em cookie httpOnly, ou checagem de Session no middleware) em ADR; implementar logout que revoga.
- criterios de aceite: logout invalida refresh; token revogado recebe 401; testes.
- encaminhamento: `fw:spec`
- status: aberto

### Sessao e rotas publicas do frontend

#### AUTH-01 — `PUBLIC_ROUTES` errada e duplicada manda cliente para o login

- tipo / severidade / repo: bug / alta / frontend
- problema: a lista diz `/proposal/:id/worker-list`, mas a rota real e `/proposal/:id/staff-list`; faltam `/proposal/:id/links`, `/proposal/:id/indications`, `/venue/:id/partner-form` e `/venue/:id/crew-form`. A lista e duplicada em dois arquivos.
- evidencia: `src/lib/axios.ts` linhas 22-26; `src/hooks/useBootstrapUser.ts` linhas 7-11.
- impacto: um 401 nessas paginas limpa o storage e manda o cliente final para `/login`.
- proposta: uma unica constante exportada (ex.: `lib/public-routes.ts`) usada pelos dois arquivos, com as rotas publicas reais de `App.tsx`; teste que compara a lista com as rotas publicas declaradas.
- criterios de aceite: lista unica; teste cobre todas as paginas publicas; nenhuma pagina publica redireciona para login.
- encaminhamento: `fw:intake`
- status: aberto

#### AUTH-02 — `/profile` fora do `ProtectedRoute`

- tipo / severidade / repo: bug / baixa / frontend
- problema: `/profile` nao passa pelo `ProtectedRoute`.
- evidencia: `src/App.tsx` linha 100.
- impacto: pagina abre sem sessao e quebra ou mostra estado vazio.
- proposta: envolver em `ProtectedRoute` sem permissao especifica.
- criterios de aceite: sem sessao vai para `/login`; com sessao abre normalmente.
- encaminhamento: `fw:intake`
- status: aberto

### Permissoes

#### PERM-01 — Permissoes divergentes entre sidebar, rota e backend

- tipo / severidade / repo: bug / alta / frontend, backend
- problema: cinco telas pedem permissoes diferentes na sidebar e na rota, e quatro rotas usam permissoes que nao existem no enum (`VIEW_VENUE_NEW_BUDGET`, `VIEW_PROPOSAL_SEND`, `VIEW_PROPOSAL_CONTACT`, `VIEW_PROPOSAL_PAYMENT`); a sidebar usa `VIEW_VENUE_CONFIG`, que nao existe no backend.
- evidencia: tabela "Divergencias conhecidas" em `topics/permissions-catalog.md`; `src/App.tsx`; `src/components/sidebar/sidebar-nav-model.ts`; `src/types/permissions.ts`.
- impacto: usuario ve item no menu e recebe "sem permissao" ao abrir (ou o contrario); rotas com permissao fora do enum negam sempre.
- proposta: tabela unica tela -> permissao; corrigir rota e sidebar para o mesmo valor; criar permissoes faltantes no backend com backfill ou trocar por existentes.
- criterios de aceite: para cada tela, sidebar e rota usam a mesma permissao; nenhuma permissao fora do enum; teste do modelo da sidebar e do gate de rota; backfill aplicado quando houver permissao nova.
- encaminhamento: `fw:spec` (lote "Alinhar permissoes")
- status: aberto

#### PERM-02 — Backend quase nao checa permissao por recurso

- tipo / severidade / repo: perigo / alta / backend
- problema: fora de precos minimos, regras, caracteristicas, servicos, cotacao, indicacoes e site, as rotas so exigem login (ou nada). `ensurePermission` so e usado no Google Calendar e passa se o usuario tiver a permissao em qualquer venue da organizacao.
- evidencia: `src/middleware/ensurePermission.ts`; tabela "Onde o backend verifica" em `topics/permissions-catalog.md`.
- impacto: qualquer usuario logado de qualquer organizacao pode ler e alterar dados de outra venue se souber os ids.
- proposta: authorizer por venue reutilizavel (padrao de `venue-price-authorizer`) aplicado por dominio, com checagem de ownership do recurso.
- criterios de aceite: por dominio, testes de acesso permitido, 403 sem permissao e 403 em venue de outra organizacao.
- dependencias e riscos: SEC-01 a SEC-06; frontend precisa tratar 403 nas telas.
- encaminhamento: `fw:spec` (lote "Fechar rotas publicas sensiveis")
- status: aberto

### Contrato HTTP

#### API-01 — Frontend chama rotas que nao existem no backend

- tipo / severidade / repo: bug / media / frontend
- problema: services declaram 13 rotas inexistentes e chamam `GET /person/getById/:id`, que no backend e `PUT`.
- evidencia: lista em `project/api-endpoints.md`, secao "Chamadas do frontend sem rota no backend"; `src/services/`.
- impacto: 404 silencioso onde alguma tela usa essas funcoes.
- proposta: verificar quais funcoes sao chamadas por telas; remover as mortas; criar rota no backend so onde a tela precisa (e corrigir `person/getById` para `GET` nos dois lados).
- criterios de aceite: nenhum service aponta para rota inexistente; `person/getById` com o mesmo metodo nos dois repos.
- encaminhamento: `fw:intake`
- status: aberto

#### API-02 — Rotas com defeito de declaracao

- tipo / severidade / repo: bug / media / backend
- problema: `GET /person/list` declarado duas vezes (o segundo, `listWebPerson`, nunca roda); `/contract/list/:venueId?/:venueId?/:name?` com parametro repetido; padroes `?:param` que casam prefixos inesperados; leitura feita por `PUT /person/getById`.
- evidencia: `src/router/person.ts`, `src/router/contract.ts`; `project/backend-map.md`, "Pontos de atencao do codigo".
- impacto: comportamento imprevisivel de roteamento e codigo morto.
- proposta: corrigir declaracoes mantendo os caminhos que o frontend usa; teste de roteamento por router.
- criterios de aceite: cada caminho resolve para um unico handler; chamadas atuais do frontend continuam respondendo.
- encaminhamento: `fw:intake`
- status: aberto

#### API-03 — `express.json` duplicado limita JSON a 100 kb

- tipo / severidade / repo: bug / media / backend
- problema: `express.json()` sem limite roda antes de `express.json({ limit: "50mb" })`; o primeiro vence.
- evidencia: `src/server.ts` linhas 47-49.
- impacto: payload JSON acima de 100 kb recebe 413, apesar da intencao de 50 MB; o limite de 50 MB tambem e alto demais.
- proposta: um unico `express.json` com limite decidido (ex.: 1-5 MB) e uploads so por multipart.
- criterios de aceite: um parser; limite documentado; teste de 413 acima do limite.
- encaminhamento: `fw:intake`
- status: aberto

#### API-04 — `controller.handle` sem `await` em rotas com upload

- tipo / severidade / repo: bug / media / backend
- problema: alguns routers chamam `controller.handle(req, res)` sem `await`.
- evidencia: `src/router/payment.ts` linhas 17 e 35; tambem `document.ts`, `image.ts`, `user.ts`.
- impacto: erro fora do try/catch do controller vira rejeicao nao tratada e a requisicao pode ficar sem resposta.
- proposta: padronizar `async (req, res) => { await controller.handle(req, res) }` ou um wrapper unico.
- criterios de aceite: nenhum `handle` sem `await` nos routers (busca registrada).
- encaminhamento: `fw:intake`
- status: aberto

#### API-05 — Sem handler global de erro, 404 proprio e logger HTTP

- tipo / severidade / repo: divida / media / backend
- problema: erros so sao tratados dentro de cada controller; rota inexistente cai no 404 padrao do Express; nao ha log de requisicao.
- evidencia: `src/server.ts` (nenhum `app.use((err, ...))` nem 404); `express-async-errors` instalado e nunca importado.
- impacto: respostas inconsistentes e nenhuma trilha para investigar incidentes.
- proposta: middleware final de erro no formato `{ title, message }`, 404 JSON e logger HTTP com correlation id.
- criterios de aceite: erro nao tratado responde 500 padrao; rota inexistente responde 404 JSON; cada requisicao logada com id.
- dependencias e riscos: SEC-09, OBS-01.
- encaminhamento: `fw:spec` (lote "Endurecer borda HTTP")
- status: aberto

### Preco e proposta

#### PRICE-01 — Dinheiro em `Float` sem regra de arredondamento

- tipo / severidade / repo: perigo / alta / backend, frontend
- problema: 12 campos de valor/preco/taxa sao `Float` no schema; nao ha regra central de arredondamento (D-07).
- evidencia: `art56_server_v3/prisma/schema.prisma` (campos `*Amount`, `*Price`, `price`, `fee`); `topics/pricing-and-proposal-calculation.md`.
- impacto: centavos divergentes entre total, saldo e pagamentos; `create-payment` compara valor com saldo em ponto flutuante.
- proposta: decidir em ADR entre `Decimal` ou inteiro em centavos; migrar schema por deploy request; funcao unica de arredondamento usada no backend e no frontend.
- criterios de aceite: nenhum campo de dinheiro em `Float`; testes de `functions/` cobrindo arredondamento; totais iguais antes e depois da migracao numa amostra.
- dependencias e riscos: DATA-02; migracao de dados em producao com aprovacao nomeada.
- encaminhamento: `fw:spec` (lote "Dinheiro e estado da proposta")
- status: aberto

#### PRICE-02 — Regra sazonal + meta em tres implementacoes com fusos diferentes

- tipo / severidade / repo: bug / alta / backend
- problema: a mesma regra existe em `proposal-amounts.ts`, em `adjust-proposal-unit-price.ts` (date-fns em horario local) e copiada inline em `create-proposal-per-day`; a meta le a receita do mes em horario local, enquanto as listagens usam wall-clock.
- evidencia: `src/functions/proposal-amounts.ts`, `src/functions/adjust-proposal-unit-price.ts`, `src/use-cases/proposal/create-proposal-per-day/`, `src/use-cases/proposal/update-proposal-per-day/`.
- impacto: o mesmo evento pode ter preco diferente ao criar, editar ou recalcular, principalmente perto da virada de dia/mes.
- proposta: um unico pipeline (o de `proposal-amounts`) usado por criacao, edicao e recalculo, por pessoa e por dia; tudo em wall-clock.
- criterios de aceite: create/update per-day usam o pipeline; testes com datas na virada de mes e de ano; nenhuma copia inline.
- encaminhamento: `fw:spec`
- status: aberto

#### PRICE-03 — `TIERED` selecionavel sem calculo

- tipo / severidade / repo: bug / media / backend, frontend
- problema: `pricingModel = TIERED` existe (tabelas `TieredPrice`/`Tier`), mas o calculo devolve `null` e o recalculo publico bloqueia.
- evidencia: `src/functions/proposal-amounts.spec.ts` linha 99; `use-case-recalculate-public-proposal.ts` linha 159.
- impacto: venue configurada como `TIERED` nao gera orcamento automatico.
- proposta: decisao de produto: implementar faixas ou esconder a opcao na UI ate existir.
- criterios de aceite: ou `TIERED` calcula com testes, ou nao aparece como opcao selecionavel.
- encaminhamento: `fw:intake` (esconder) ou `fw:spec` (implementar)
- status: aberto

#### PRICE-04 — Funcoes de preco legadas, uma com bug e uma vazia

- tipo / severidade / repo: divida / baixa / backend
- problema: `calc-base-price` usa valores fixos antigos; `calc-standart-total-amount` chama `calcExtraHoursQty` com um argumento so; `calc-price-per-day.ts` esta vazio.
- evidencia: `src/functions/`; `project/backend-map.md`.
- impacto: risco de alguem reusar codigo errado.
- proposta: confirmar que nao ha import e apagar.
- criterios de aceite: arquivos removidos; `npm test -- --run` verde.
- encaminhamento: `fw:intake`
- status: aberto

#### PRICE-05 — Despesa recorrente `WEEKLY` ignorada na analise

- tipo / severidade / repo: bug / media / backend
- problema: a analise de despesas nao considera recorrencia semanal.
- evidencia: `src/use-cases/expense/` (analysis); `topics/pricing-and-proposal-calculation.md`, "Riscos registrados".
- impacto: relatorio de despesas e lucro subestimados.
- proposta: incluir `WEEKLY` (semanas do mes) na analise com teste.
- criterios de aceite: despesa `WEEKLY` aparece no total mensal correto; teste cobrindo meses de 4 e 5 semanas.
- encaminhamento: `fw:intake`
- status: resolvido em 2026-11-14 pela spec `investimento-anuncios-por-canal` (`T-02`); criterio adotado: 52 semanas por ano, mensal = valor x 52 / 12 (semanal 120 = 520/mes e 6.240/ano), em `functions/expense-recurrence.ts#recurringAmounts`; `expense-recurrence.spec.ts` e `use-case-analysis-expense.spec.ts` verdes

#### PRICE-06 — Esporadicas de janeiro do ano seguinte na analise de despesas

- tipo / severidade / repo: bug / media / backend
- problema: `analyze` recortava as esporadicas com `new Date(year, 0, 1)` ate `new Date(year, 12, 31)` em hora local, ou seja, ate 31/01 do ano seguinte; com servidor fora de UTC o pagamento de 1/1 (meia-noite UTC) ficava de fora.
- evidencia: `src/repositories/in-prisma/expense-in-prisma-repository.ts#analyze` antes de 2026-11-14.
- impacto: total do ano e comparativo anual do Financeiro inflados por despesas de janeiro do ano seguinte.
- proposta: recortar por `reportYearRange(year)` (1/1 a 1/1 em UTC, como `paymentDate` wall-clock).
- criterios de aceite: pagamento de 1/1 entra; pagamento de 15/01 do ano seguinte nao entra, inclusive com `TZ=America/Sao_Paulo`.
- encaminhamento: encontrado e resolvido na spec `investimento-anuncios-por-canal` (`T-02`, `R-15`)
- status: resolvido em 2026-11-14; `expense-in-prisma-repository.spec.ts` verde

#### PROP-01 — Proposta sem maquina de estados; `paid` nunca vira `true`

- tipo / severidade / repo: divida / alta / backend, frontend
- problema: o estado da proposta e implicito: `approved` muda ao criar/apagar `DateEvent`; `amountPaid` muda em pagamento e documento; `paid` nunca e gravado como `true`.
- evidencia: `topics/pricing-and-proposal-calculation.md`, "Estado da proposta derivado de dinheiro e agenda"; `flows/proposal-lifecycle-current.md`.
- impacto: nao existe "paga" de verdade; relatorios e regras (ex.: recalculo publico) dependem de flags inconsistentes.
- proposta: definir estados (rascunho, enviada, aprovada, paga, cancelada) e transicoes em spec; gravar `paid` quando `amountPaid >= totalAmount`; migrar dados existentes.
- criterios de aceite: transicoes testadas; `paid` coerente com pagamentos em todas as propostas; telas mostram o estado.
- dependencias e riscos: PRICE-01, DATA-01.
- encaminhamento: `fw:spec` (lote "Dinheiro e estado da proposta")
- status: aberto

### Dados e schema

#### DATA-01 — Fluxos com varias escritas sem transacao

- tipo / severidade / repo: perigo / alta / backend
- problema: so tres repositorios usam `$transaction` (proposal, venue, proposal-indication); fluxos como pagamento (grava Payment e atualiza `amountPaid`), documento (apaga e recalcula) e DateEvent (cria e aprova proposta, sincroniza Google) fazem varias escritas soltas.
- evidencia: busca por `$transaction` em `art56_server_v3/src` (3 arquivos de repositorio); `use-cases/payment/`, `use-cases/document/`, `use-cases/data-event/`.
- impacto: falha no meio deixa saldo ou aprovacao inconsistentes.
- proposta: envolver cada fluxo multi-escrita numa transacao do repositorio; chamadas externas (S3, Google) depois do commit ou com compensacao.
- criterios de aceite: teste que forca falha na segunda escrita e prova que nada foi gravado; lista de fluxos cobertos.
- encaminhamento: `fw:spec` (lote "Dinheiro e estado da proposta")
- status: aberto

#### DATA-02 — Schema vai para producao sem staging nem aprovacao obrigatoria

- tipo / severidade / repo: perigo / alta / infra
- problema: mudancas de schema chegam a `main` do PlanetScale por deploy request sem ambiente de staging e sem aprovacao obrigatoria.
- evidencia: `project/planetscale.md`; `topics/delivery-and-known-gaps.md`.
- impacto: migracao errada atinge producao direto.
- proposta: exigir aprovacao de deploy request no PlanetScale, branch de staging com dados de teste e checklist de migracao (backfill, rollback).
- criterios de aceite: configuracao de aprovacao ativa (prova por `pscale` somente leitura); fluxo documentado em `project/planetscale.md`.
- encaminhamento: `fw:intake` com aprovacao nomeada (mexe em configuracao do banco)
- status: aberto

#### DATA-03 — Campos e relacoes legados no schema

- tipo / severidade / repo: divida / baixa / backend
- problema: campos `teste` em `ProposalService`/`ProposalCost` e relacao com grafia `noificationList`.
- evidencia: `prisma/schema.prisma`.
- impacto: confusao e risco de uso acidental.
- proposta: confirmar que nao sao usados, remover por migration e renomear a relacao (so nivel Prisma).
- criterios de aceite: `npx prisma validate` ok; nenhum uso no codigo; deploy request aprovado.
- encaminhamento: `fw:intake`
- status: aberto

### Divergencias de artefato

#### DIV-01 — Spec DocuSign diz que ha codigo e migration que nao existem

- tipo / severidade / repo: divergencia / alta / backend, docs
- problema: a spec `2026-11-05-assinatura-contrato-docusign` marca `T-01` a `T-03` como feitas, com migration `20261105230000_add_docusign_envelope` e `DOCUSIGN_CONNECT_SECRET` no `.env.example`; nada disso existe nos repos.
- evidencia: `topics/delivery-and-known-gaps.md`, tabela de divergencias; busca por `docusign` e `contractSignedAt` sem resultado em backend e frontend.
- impacto: alguem pode seguir para `T-04` em cima de codigo que nao existe, ou recriar migration que ja foi aplicada em algum branch do banco.
- proposta: confirmar com quem executou se o codigo esta em outra branch/maquina; ler o schema real da `main` com `pscale` somente leitura; atualizar `05-state` da spec com o que for verdade.
- criterios de aceite: spec e BOARD refletem o estado real; se o codigo foi perdido, tasks reabertas.
- encaminhamento: `fw:status` / ajuste da spec
- status: aberto

#### DIV-02 — Midia de caracteristica (`VenueAmenity`) ausente no `schema.prisma`

- tipo / severidade / repo: divergencia / alta / backend, docs
- problema: spec `2026-11-05-foto-video-descricao-caracteristica` e `product/08-data-model.md` dizem que `VenueAmenity` tem `description`, `imageUrl` e `videoUrl` na `main` (deploy request 43); o `schema.prisma` so tem `name`, `position`, `venueId` e datas.
- evidencia: `prisma/schema.prisma`, model `VenueAmenity`.
- impacto: banco e Prisma podem estar diferentes; proxima migration pode tentar recriar ou apagar colunas.
- proposta: ler o schema real com `pscale` somente leitura; se as colunas existem, trazer o codigo/schema que falta; se nao, corrigir spec e BOARD.
- criterios de aceite: `schema.prisma` e banco iguais para `VenueAmenity`; spec e BOARD atualizados.
- encaminhamento: `fw:status` / ajuste da spec
- status: resolvido em 2026-11-12; colunas lidas no `main` (`varchar(500)`, `text`, `varchar(2048)`, nulas), `schema.prisma` e migration `20261112120000_add_venue_amenity_media` alinhados; spec reexecutada

#### DIV-03 — `AGENTS.md` aponta `.cursor/framework_global/`, caminho real e outro

- tipo / severidade / repo: divergencia / baixa / docs
- problema: o caminho real do framework global e `eventhub-docs/framework_global/`.
- evidencia: `eventhub-docs/AGENTS.md`; `project/workspace-map.md`.
- impacto: agentes procuram regras no lugar errado.
- proposta: corrigir o caminho no `AGENTS.md` do EventHub (sem mexer no repo global).
- criterios de aceite: todos os caminhos citados no `AGENTS.md` existem.
- encaminhamento: `fw:intake`
- status: aberto

#### DIV-04 — Task-requests "revisar entrega" nao verificados contra o codigo

- tipo / severidade / repo: divergencia / media / docs
- problema: varios task-requests estao como entregues, mas nao foram conferidos um a um no mapeamento de 2026-11-10.
- evidencia: `task-requests/`; BOARD.
- impacto: falsas entregas como as de DIV-01 e DIV-02 podem existir em outros itens.
- proposta: rodar uma revisao de entrega por task-request (codigo, teste e prova) e registrar o resultado.
- criterios de aceite: cada task-request com status confirmado e evidencia.
- encaminhamento: `fw:status`
- status: aberto

### Testes e entrega

#### TEST-01 — Sem testes HTTP, de auth negativa, pagamento, documento e contrato

- tipo / severidade / repo: divida / alta / backend
- problema: 48 specs Vitest focados em `functions/` e use cases; nenhum teste passa pelo router (middleware, status, payload) e dominios de dinheiro e documentos nao tem testes.
- evidencia: `project/backend-map.md`, secao "Testes".
- impacto: fechar rotas (SEC-*) ou mudar dinheiro sem rede de seguranca.
- proposta: harness de teste HTTP (ex.: supertest sobre `app` de `server.ts`) com banco de teste ou repositorios em memoria; comecar por auth 401/403, payment e document.
- criterios de aceite: harness rodando em `npm test`; testes 401/403/ownership para as rotas tocadas pelos SEC-*.
- encaminhamento: `fw:spec` (pre-requisito do lote "Fechar rotas publicas sensiveis")
- status: aberto

#### TEST-02 — Sem CI nem gate de PR

- tipo / severidade / repo: divida / alta / backend, frontend
- problema: nao existe `.github/` nem outra esteira; nada roda testes, lint ou build antes do merge.
- evidencia: ausencia de `.github/` nos dois repos; `topics/delivery-and-known-gaps.md`.
- impacto: regressao chega a producao pela Vercel sem verificacao.
- proposta: workflow por repo: backend `npm test -- --run` + `npx prisma validate`; frontend `npm run lint` + `npm test` + `npm run build`; branch protegida exigindo verde.
- criterios de aceite: PR com teste quebrado fica bloqueado nos dois repos.
- encaminhamento: `fw:intake` (por repo)
- status: aberto

#### TEST-03 — Testes de frontend sem DOM

- tipo / severidade / repo: divida / media / frontend
- problema: Vitest em ambiente `node`, componentes testados com `renderToStaticMarkup`; nao ha jsdom nem Testing Library.
- evidencia: config do Vitest no frontend; `project/frontend-map.md`, secao "Testes".
- impacto: interacao (clique, formulario, redirecionamento) nao e testada.
- proposta: adicionar ambiente jsdom para arquivos de componente e Testing Library; comecar por `ProtectedRoute`, formularios publicos e sidebar.
- criterios de aceite: ao menos um teste de interacao por fluxo publico; testes atuais continuam passando.
- encaminhamento: `fw:intake`
- status: aberto

#### TEST-04 — Sem conta e ambiente de teste para prova no browser

- tipo / severidade / repo: divida / alta / infra
- problema: provas de entrega no browser param no login; nao ha conta de teste nem ambiente local com dados.
- evidencia: BOARD (varias entregas com "falta prova no browser").
- impacto: entregas ficam meio verificadas.
- proposta: branch de desenvolvimento no PlanetScale com seed, conta de teste com permissoes conhecidas e roteiro de prova.
- criterios de aceite: qualquer agente consegue logar localmente e abrir painel e paginas publicas com dados de teste.
- encaminhamento: `fw:spec`
- status: aberto

#### OBS-01 — Sem log estruturado, correlation id, metricas e alertas

- tipo / severidade / repo: divida / media / backend
- problema: observabilidade e `console` + `GET /`.
- evidencia: `src/server.ts`; `topics/delivery-and-known-gaps.md`.
- impacto: incidentes so aparecem quando o cliente reclama.
- proposta: logger estruturado (JSON) com correlation id, log de erro no handler global e alerta basico de taxa de 5xx (Vercel ou servico externo).
- criterios de aceite: cada requisicao tem id nos logs; erro 500 aparece com stack no log; alerta configurado.
- dependencias e riscos: API-05, SEC-09.
- encaminhamento: `fw:spec` (lote "Endurecer borda HTTP")
- status: aberto

### Infra e configuracao

#### INFRA-01 — `package.json` do backend com build anomalo e `main` inexistente

- tipo / severidade / repo: bug / media / backend
- problema: `vercel-build` e `prisma generate echo hello`; `main` aponta para `dist/app.js`, que nao existe; nao ha script `build`; nome do pacote e `meu-projeto`; tipos e ferramentas de dev em `dependencies`.
- evidencia: `art56_server_v3/package.json`.
- impacto: build confuso e pacote de producao maior que o necessario.
- proposta: `vercel-build: prisma generate`, script `build`/`typecheck` (`tsc --noEmit`), `main` correto ou removido, mover `@types/*`, `vitest`, `ts-node-dev` para `devDependencies`.
- criterios de aceite: deploy na Vercel continua funcionando (preview); `npm run typecheck` verde.
- encaminhamento: `fw:intake`
- status: aberto

#### INFRA-02 — Variaveis de ambiente divergentes dos `.env.example`

- tipo / severidade / repo: bug / media / backend, frontend
- problema: backend usa `FRONTEND_URL` e nao a lista no exemplo; lista `CORS_ORIGIN` e nao usa. Frontend usa `VITE_API_URL` e `VITE_GOOGLE_CLIENT_ID` e nao os lista.
- evidencia: `project/backend-map.md` e `project/frontend-map.md`, secoes "Configuracao".
- impacto: ambiente novo sobe quebrado sem aviso.
- proposta: alinhar os dois `.env.example` com o uso real (so nomes e placeholders) e validar variaveis obrigatorias na subida (ex.: schema Zod de env).
- criterios de aceite: toda variavel lida no codigo esta no exemplo; subir sem variavel obrigatoria falha com mensagem clara.
- dependencias e riscos: SEC-08, SEC-10.
- encaminhamento: `fw:intake`
- status: aberto

#### INFRA-03 — Dominio e remetentes de e-mail fixos no codigo

- tipo / severidade / repo: divida / media / backend, frontend
- problema: `event-hub-dashboard.vercel.app` aparece em 14 arquivos do frontend e no e-mail de reset do backend; conta Gmail e remetentes fixos.
- evidencia: busca por `event-hub-dashboard.vercel.app` em `.ts`/`.tsx`; `src/services/send-forgot-password-email.ts`.
- impacto: trocar dominio ou ter ambiente de teste gera links errados para clientes.
- proposta: `window.location.origin` ou `VITE_PUBLIC_APP_URL` no frontend; `FRONTEND_URL` e `EMAIL_FROM` no backend.
- criterios de aceite: nenhuma ocorrencia do dominio fixo fora de testes; links corretos em preview.
- encaminhamento: `fw:intake`
- status: aberto

### Frontend

#### FE-01 — React Query e 30 stores Zustand convivendo

- tipo / severidade / repo: divida / media / frontend
- problema: dados de servidor ficam ora em hooks React Query, ora em stores Zustand com fetch manual.
- evidencia: `src/store/` (30 stores); `src/hooks/`; `project/frontend-map.md`, "Estado e dados".
- impacto: cache duplicado, telas desatualizadas apos mutacao e duas formas de fazer a mesma coisa.
- proposta: decidir em ADR que dado de servidor fica no React Query e Zustand so para estado de UI; migrar dominio a dominio, comecando pelos mais usados.
- criterios de aceite: ADR registrada; plano por dominio; cada dominio migrado sem store de dados do servidor.
- encaminhamento: `fw:spec`
- status: aberto

#### FE-02 — `App.tsx` sem lazy loading e paginas com mais de 1000 linhas

- tipo / severidade / repo: divida / media / frontend
- problema: as 63 rotas sao importadas de forma estatica; paginas como `ProposalView` (1363 linhas) concentram muita logica.
- evidencia: `src/App.tsx`; `src/pages/ProposalView.tsx`.
- impacto: bundle inicial grande (inclusive nas paginas publicas do cliente) e manutencao dificil.
- proposta: `React.lazy` por rota com `Suspense`; quebrar as paginas grandes em componentes e hooks.
- criterios de aceite: bundle das paginas publicas menor (medir antes/depois no `npm run build`); nenhuma pagina acima de ~600 linhas nas tocadas.
- encaminhamento: `fw:intake` (lazy) e `fw:spec` (refatoracao das paginas)
- status: aberto

#### FE-03 — Codigo morto e componentes duplicados em `ui/`

- tipo / severidade / repo: divida / baixa / frontend
- problema: `ProposalDateEvent.tsx`, `website/OrganizationWebsiteFaq.tsx`, `VenueStatsChart.tsx`, `PermissionsManager.tsx` sem uso; import `ScheduleSection` em `App.tsx`; duplicados `EmptyState`, `PageHeader`, `SubmitButton`, `VenueDashboardSkeleton`, `use-toast`.
- evidencia: `project/frontend-map.md`, "Divergencias e dividas a nao copiar".
- impacto: confusao sobre qual componente usar.
- proposta: apagar o morto; escolher uma versao de cada duplicado e trocar os imports.
- criterios de aceite: lint e build verdes; uma versao de cada componente.
- encaminhamento: `fw:intake`
- status: aberto

#### FE-04 — `PartnerForm` e `CrewForm` ignoram as cores da casa

- tipo / severidade / repo: bug / baixa / frontend
- problema: os dois formularios publicos usam `ProposalFooter` roxo fixo, sem as cores da venue.
- evidencia: `topics/public-pages-and-branding.md`.
- impacto: paginas do cliente fora da identidade da venue.
- proposta: aplicar o mesmo tema das demais paginas publicas.
- criterios de aceite: cores da venue aplicadas; prova visual no browser.
- encaminhamento: `fw:intake`
- status: aberto

#### FE-05 — TypeScript frouxo e ESLint permissivo

- tipo / severidade / repo: divida / media / frontend
- problema: `strict: false`, `noImplicitAny: false`, `strictNullChecks: false`; `no-unused-vars` desligado.
- evidencia: `tsconfig*.json`, `eslint.config.js` do frontend.
- impacto: erros de `null`/`undefined` so aparecem em producao.
- proposta: ligar `strictNullChecks` por etapas (por pasta) e reativar `no-unused-vars` como aviso.
- criterios de aceite: plano por etapa; build verde a cada etapa.
- encaminhamento: `fw:spec`
- status: aberto

#### FE-06 — Token de cor inexistente e dark mode morto

- tipo / severidade / repo: bug / baixa / frontend
- problema: `bg-eventhub-primary-dark` e usado e nao definido no Tailwind; variaveis `.dark` existem e nada liga a classe.
- evidencia: `tailwind.config.ts`, `src/index.css`.
- impacto: elemento sem cor de fundo; codigo de tema sem uso.
- proposta: definir o token (ou trocar pelo correto) e remover ou ativar o dark mode por decisao de produto.
- criterios de aceite: nenhuma classe sem definicao; decisao sobre dark mode registrada.
- encaminhamento: `fw:intake`
- status: aberto

### Higiene

#### HYG-01 — Backend com dependencias sem uso, dois lockfiles e sobras

- tipo / severidade / repo: divida / baixa / backend
- problema: `pdf-lib`, `canvas`, `@napi-rs/canvas`, `socket.io`, `socket.io-client`, `axios`, `jwt-decode`, `moment-timezone`, `express-async-errors` sem uso; `package-lock.json` e `yarn.lock` juntos; `debug-upload-*.bin`, `yarn-error.log`, `test-duration.js`, `test-organization.js`, schemas `* copy.ts`.
- evidencia: `project/backend-map.md`, "Stack e scripts" e "Estrutura".
- impacto: build mais lento (canvas nativo), superficie de vulnerabilidade maior.
- proposta: remover dependencias e arquivos; manter um gerenciador de pacotes.
- criterios de aceite: `npm test -- --run` verde; deploy de preview ok.
- encaminhamento: `fw:intake`
- status: aberto

#### HYG-02 — Frontend com tres lockfiles, arquivo `Untitled` e dependencias sem uso

- tipo / severidade / repo: divida / baixa / frontend
- problema: `bun.lockb`, `package-lock.json` e `yarn.lock`; arquivo solto `Untitled`; FullCalendar, swiper, jspdf-autotable e pdfjs-dist sem uso.
- evidencia: raiz de `eventhub-vista-dashboard/`; `project/frontend-map.md`.
- impacto: instalacoes diferentes por maquina e bundle maior.
- proposta: escolher um gerenciador (o que a Vercel usa), apagar os outros lockfiles, `Untitled` e dependencias sem uso.
- criterios de aceite: um lockfile; build e testes verdes; deploy de preview ok.
- encaminhamento: `fw:intake`
- status: aberto

#### DOC-01 — Backlog legado em `docs/` ainda nao convertido

- tipo / severidade / repo: divida / baixa / docs
- problema: `docs/estado/integracao/TODO_MASTER.md`, `KNOWN_LIMITATIONS.md`, `docs/planos/ROADMAP_TECHNICAL.md`, `PERFORMANCE_PLAN.md` e `OBSERVABILITY_PLAN.md` tem propostas historicas fora deste backlog.
- evidencia: `topics/legacy-docs-map.md`.
- impacto: itens validos esquecidos ou executados sem conferir o codigo.
- proposta: revisar cada documento, conferir no codigo e trazer para ca o que ainda vale (com novo ID).
- criterios de aceite: cada documento legado marcado como "convertido" ou "obsoleto" em `topics/legacy-docs-map.md`.
- encaminhamento: `fw:intake`
- status: aberto

## Modelo para novo item

```markdown
#### PREFIXO-NN — Titulo curto

- tipo / severidade / repo:
- problema: o que esta errado, em uma ou duas frases.
- evidencia: arquivo e linha, rota, comando ou print.
- impacto: o que acontece com cliente, dados ou dinheiro.
- proposta: o que fazer.
- criterios de aceite:
  - verificavel 1;
  - verificavel 2.
- dependencias e riscos: outros IDs, aprovacoes, migracoes.
- encaminhamento: `fw:intake` ou `fw:spec` (lote, se houver)
- status: aberto
```

Depois de criar a ficha, adicione a linha na tabela-indice e, se o item andar junto com outros, na tabela de agrupamentos.
