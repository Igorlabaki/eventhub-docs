# Tasks — Assinatura do contrato no DocuSign

## Ordem macro

1. `T-01` grava o envelope e envia ao DocuSign.
2. `T-02` e `T-03` dependem de `T-01` e podem ir em paralelo entre si.
3. A prova de ponta a ponta no sandbox, com Connect real, espera a URL publica e fica fora destas tasks.

## Tasks

### T-01 - Enviar o envelope e guardar o estado

- objetivo: a API autenticada cria um envelope no DocuSign com o PDF e o e-mail salvo da proposta, e a leitura devolve o estado sem segredo.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-06`, `R-13` nos nomes do envio
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `ensureAuthenticate`, permissao `SEND_PROPOSAL_DOCUMENTS`, `jsonwebtoken`
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case com HTTP mockado e Prisma em memoria ou repositorio falso; `npx prisma validate`
- cenarios obrigatorios: envia e grava `sent`; 403 sem permissao; 422 sem e-mail; ignora e-mail do corpo; 409 se ja esta `sent` ou `completed`; resposta sem segredo; dois envios simultaneos com ponteiro vazio deixam um so vigente
- definition of done: rotas POST e GET no ar com auth; migration aditiva aplicada no schema; `.env.example` com as sete variaveis do envio, sem valor; testes dos cenarios verdes; nenhum valor de `.env` no diff

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — chave RSA, PDF com dado pessoal, permissao
- risco principal: gravar `sent` sem `envelopeId`, ou aceitar o e-mail do corpo
- repos tocados: `backend`
- fora de escopo desta task: botao na tela, webhook, S3, `contractSignedAt` preenchido
- prova minima desta task: os cenarios obrigatorios passam em `npm test -- --run` no caso de envio, e `npx prisma validate` passa
- criterio de escalada: se o JWT do DocuSign nao fechar com `jsonwebtoken`, parar e registrar o bloqueio em vez de adicionar SDK sem avisar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `database`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/security/references/secrets-and-key-management.md#Principios`
  - `.cursor/framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md`
  - `.cursor/framework_core/project/project-decisions.md#D-03`
- caminhos candidatos: `art56_server_v3/src/middleware/ensureAuthenticate.ts`, `art56_server_v3/src/use-cases/notification/read-by-proposal/`, `art56_server_v3/src/server.ts`, `art56_server_v3/.env.example`
- palavras-chave ou simbolos de busca: `SEND_PROPOSAL_DOCUMENTS`, `getUserVenuePermission`, `DocusignEnvelope`, `DOCUSIGN_RSA_PRIVATE_KEY`
- testes provaveis: `use-case` de enviar envelope e de ler estado
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, tela do frontend, webhook

### T-02 - Botao e estado na tela de contrato

- objetivo: PF e PJ enviam o PDF ja gerado e mostram aguardando, recusado ou assinado conforme a leitura do envelope.
- cobre requisitos: `R-07`, `R-12`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: `generateContractPdf`, os dois formularios de contrato, React Query
- prompt recomendado: `smart`
- estrategia de teste: unitario do estado do botao com a leitura mockada; na tela, o fluxo de enviar e o de assinado com fixture
- cenarios obrigatorios: sem e-mail salvo o botao nao envia; envio aceito mostra aguardando; `completed` com `documentUrl` mostra o link; erro da API nao muda o rotulo para aguardando; "Gerar Contrato" continua baixando o arquivo
- definition of done: os dois formularios tem o botao e os estados; teste do componente verde; o PDF enviado e o mesmo construtor do download

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o corpo leva o PDF do cliente para a API
- risco principal: enviar o e-mail digitado e ainda nao salvo, ou marcar aguardando quando a API falhou
- repos tocados: `frontend`
- fora de escopo desta task: pagina de integracoes, webhook, mudar o texto das clausulas
- prova minima desta task: o teste do botao cobre os cinco cenarios; no browser, com a API de `T-01`, um envio de proposta com e-mail mostra aguardando
- criterio de escalada: se o construtor do PDF nao puder devolver bytes sem mudar o conteudo, parar e nao duplicar o gerador
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Tela`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Tela`
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/proposal/forms/ContractPdfGenerator.tsx`, `pf-contract-form.tsx`, `pj-contract-form.tsx`
- palavras-chave ou simbolos de busca: `generateContractPdf`, `Gerar Contrato`, `isFormComplete`
- testes provaveis: estado do botao a partir do GET do envelope
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security` (a task nao implementa auth nem webhook)

### T-03 - Receber a assinatura e gravar o PDF

- objetivo: o webhook com HMAC valido, no `completed`, grava um unico PDF assinado na proposta e preenche `contractSignedAt`.
- cobre requisitos: `R-08`, `R-09`, `R-10`, `R-11`, `R-13` no nome do segredo do Connect
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: upload S3 de `controller-create-document.ts`, tabela criada em `T-01`
- prompt recomendado: `normal`
- estrategia de teste: unitario do handler com body cru, segredo de fixture, download e S3 mockados
- cenarios obrigatorios: HMAC errado responde 401 e nao escreve; `completed` cria um `Document` e preenche `contractSignedAt`; repetir `completed` nao cria outro; `declined` nao preenche a data; falha de S3 responde 500 e nao marca `completed`
- definition of done: a rota usa body cru antes do JSON global; `.env.example` tem `DOCUSIGN_CONNECT_SECRET` sem valor; testes dos cenarios verdes; log sem segredo e sem PDF

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — webhook sem login, HMAC, PDF com dado pessoal no S3
- risco principal: marcar assinado sem o arquivo, ou aceitar POST sem HMAC
- repos tocados: `backend`
- fora de escopo desta task: configurar o Connect no painel do DocuSign, objeto privado, botao
- prova minima desta task: os cinco cenarios passam em `npm test -- --run` no handler do webhook
- criterio de escalada: se o body cru for impossivel na ordem atual do `server.ts`, parar e nao validar HMAC em cima de JSON re-serializado
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Webhook`
- libs obrigatorias: `node`, `security`, `aws`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Webhook`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/security/skills/implementing-webhook-signature-validation.md`
  - `.cursor/framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md`
  - `.cursor/framework_core/project/project-decisions.md#D-04`
- caminhos candidatos: `art56_server_v3/src/server.ts`, `art56_server_v3/src/use-cases/document/create-document/controller-create-document.ts`
- palavras-chave ou simbolos de busca: `express.json`, `PutObjectCommand`, `DOCUSIGN_CONNECT_SECRET`, `contractSignedAt`
- testes provaveis: handler do webhook
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, formularios do frontend
