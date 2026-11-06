# Design — Assinatura do contrato no DocuSign

## Passada transversal

- architecture: sim. O monolito Express passa a chamar o DocuSign e a receber o webhook. Nao nasce outro servico nem outro deploy. Sem ADR (`project-decisions.md#D-02`).
- database: sim. Tabela nova e colunas nulas em `Proposal`. Migration aditiva.
- design: sim. Botao e estado na tela de contrato que ja existe. Sem pagina nova.
- observability: sim. Log com ids. Sem dashboard novo; o projeto nao tem esse baseline.
- security: sim. Permissao no venue, segredo no servidor, HMAC no webhook, PDF com dado pessoal.
- patterns/rules/06: sim. Idempotencia no envio e no webhook. Timeout na chamada externa. Sem fila.

## Visao geral da solucao

O browser monta o mesmo PDF de "Gerar Contrato" e envia os bytes para a API. A API autentica no DocuSign com JWT, abre um envelope com um signatario e grava o estado na proposta. O DocuSign manda o e-mail. Quando o Connect avisa `completed`, a API baixa o PDF combinado, sobe no S3 e cria o `Document` da proposta.

## Tela

Nos formularios PF e PJ, ao lado de "Gerar Contrato":

- sem envelope, formulario completo e e-mail salvo: botao "Enviar para assinatura";
- enviando: botao indisponivel;
- `sent` ou `delivered`: texto "Aguardando assinatura", sem segundo envio;
- `completed`: texto "Contrato assinado" e link para o PDF gravado;
- `declined` ou `voided`: texto da recusa e o botao de enviar de novo;
- erro: toast, estado anterior permanece.

Se o e-mail do formulario ainda nao foi salvo na proposta, o botao pede para salvar antes. "Gerar Contrato" continua so o download.

## Componentes e modulos impactados

- `frontend`: `ContractPdfGenerator.tsx`, `pf-contract-form.tsx`, `pj-contract-form.tsx`, um service e um hook para envelope.
- `backend`: `src/integrations/docusign/` (token JWT, criar envelope, baixar PDF, validar HMAC), router `/integration/docusign`, use cases de enviar, ler e receber webhook, repositorio Prisma.
- `prisma`: `DocusignEnvelope` e campos em `Proposal`.
- `server.ts`: o webhook precisa do body cru, registrado antes do `express.json()`.

## Reuso previsto

- `generateContractPdf` ganha um retorno dos bytes; o download atual permanece.
- `ensureAuthenticate` e `UserVenuePermission` com `SEND_PROPOSAL_DOCUMENTS`, no mesmo desenho de `read-by-proposal`.
- Upload S3 com `PutObjectCommand` e a URL no mesmo formato de `controller-create-document.ts`.
- `jsonwebtoken`, ja usado na API, assina o JWT do DocuSign. Sem SDK novo.
- `fetch` com timeout. Sem fila.

## Contratos e dados

`POST /integration/docusign/envelopes`

- auth: Bearer
- corpo: `proposalId`, `pdfBase64`
- a API ignora e-mail e nome que venham no corpo
- 201: `{ envelopeId, status: "sent" }`
- 401 sem login; 403 sem permissao; 409 se ja existe envelope `sent`, `delivered` ou `completed`; 422 sem e-mail ou sem PDF; 502 se o DocuSign recusar, sem gravar `sent`

`GET /integration/docusign/proposals/:proposalId/envelope`

- auth e a mesma permissao
- 200: `{ status, envelopeId, contractSignedAt, documentUrl }`
- sem envelope: `{ status: null }`

`DocusignEnvelope`: `id`, `proposalId`, `envelopeId` unico, `status`, `documentId` nulo, `createdAt`, `updatedAt`.

`Proposal`: `contractSignedAt DateTime?` e `docusignEnvelopeId String?` apontando para o id do envelope vigente. A coluna nao vira relacao Prisma: ligar envelope, documento e proposta no mesmo ciclo quebra o validate. O `documentId` do envelope tambem fica coluna, e a URL sai de uma leitura do `Document`.

Status locais: `sent`, `delivered`, `completed`, `declined`, `voided`.

Envio concorrente: gravar o ponteiro com update condicional. Se a proposta ja tem envelope `sent`, `delivered` ou `completed`, o segundo request recebe 409. Dois cliques com ponteiro vazio nao podem deixar dois envelopes vigentes; o que perder a condicao apaga ou abandona o envelope que acabou de criar e responde 409.

Variaveis novas no `.env.example`, sem valor: as sete ja combinadas e, no webhook, `DOCUSIGN_CONNECT_SECRET`.

## Webhook

`POST /integration/docusign/webhook`

- sem JWT de usuario
- body cru; HMAC-SHA256 com `DOCUSIGN_CONNECT_SECRET`; header `X-Docusign-Signature-1` em base64; comparacao em tempo constante
- HMAC invalido: 401 e nenhum write
- JSON que nao seja evento de envelope: 400
- `completed`: baixar o PDF combinado, subir no S3, criar `Document` (`fileType` PDF, titulo "Contrato assinado", `proposalId`), ligar `documentId`, gravar status e `contractSignedAt`
- se o documento ja esta ligado, responder 200 e nao criar outro
- `declined` e `voided` atualizam o status e nao mexem em `contractSignedAt`
- `sent` ou `delivered` nao rebaixam `completed`, `declined` nem `voided`
- falha de download ou S3: 500, status local continua o anterior, para o Connect tentar de novo

## Falhas, casos de borda e invariantes

- `contractSignedAt` so existe junto de um `Document` ligado ao envelope `completed`.
- O PDF enviado e o PDF assinado pertencem ao `proposalId` do envelope, nunca a outro.
- Log nao inclui `pdfBase64`, token, chave, CPF nem o corpo cru do webhook.
- Timeout da chamada ao DocuSign. Sem retry automatico no envio: o operador ve o erro e tenta de novo, e o ponteiro so vira `sent` depois do `envelopeId`.

## Decisoes arquiteturais importantes

- JWT de uma conta, lido do ambiente a cada envio. Descartada a tabela `DocusignIntegration` por organizacao: a entrada fechou uma conta so.
- O servidor nao gera o PDF. Descartado HTML no backend nesta feature: o arquivo valido ja e o da tela.
- Webhook sincrono, com 500 para retry. Descartada fila: nao existe no runtime (`D-04`).
- Bucket atual dos documentos. Descartado objeto privado nesta feature.

## Riscos e mitigacoes

- Chave no git ou no log: so nomes no example; teste garante que a resposta nao contem os nomes dos segredos como valor.
- HMAC com body ja parseado: a rota do webhook e registrada com body cru antes do JSON global.
- URL publica do documento: chave `uuid`, sem listar o bucket. Privacidade forte fica fora.

## Rollout, observabilidade e rollback

- Sandbox: `DOCUSIGN_OAUTH_BASE_URL=account-d.docusign.com` e `DOCUSIGN_BASE_URL=https://demo.docusign.net/restapi`.
- Connect, depois do deploy: URL `https://<api>/integration/docusign/webhook`, JSON, HMAC, eventos de envelope.
- Log: `docusign.envelope.sent`, `docusign.webhook.rejected`, `docusign.webhook.completed`, `docusign.webhook.failed`, cada um com `proposalId` e `envelopeId` quando existirem.
- Rollback: remover o botao e parar de chamar as rotas. Colunas novas podem ficar. Envelopes ja abertos continuam no DocuSign.

## Estrategia de validacao

- Unitario no use case de envio, na condicao do ponteiro e no HMAC, com HTTP e S3 mockados. Sem chamada real ao DocuSign no teste.
- `npx prisma validate` na migration.
- Tela: enviar com e-mail salvo, recusar sem e-mail, mostrar aguardando e, com status `completed` de fixture, mostrar o link.

## Fontes que fecharam a solucao

- `project-decisions.md#D-02` a `#D-05`
- `topics/integrations.md` e `product/09-integrations.md`
- `security/references/secrets-and-key-management.md#Principios`
- `patterns/rules/06_senior_engineering_concepts.md` (idempotencia, timeout, concorrencia)
- `ContractPdfGenerator.tsx`, `ensureAuthenticate.ts`, `controller-create-document.ts`
