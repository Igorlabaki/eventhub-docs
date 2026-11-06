# Spec — Assinatura do contrato no DocuSign

## Problema

O contrato da proposta e um PDF gerado no navegador. O operador baixa o arquivo ou o envia por e-mail pedindo que o cliente assine e devolva uma copia. A proposta nao sabe se o contrato foi enviado nem se foi assinado, e o PDF assinado nao entra nos documentos da proposta.

## Objetivos

- Enviar, da tela de contrato, o mesmo PDF que "Gerar Contrato" ja produz.
- O cliente assina pelo e-mail do DocuSign, sem conta.
- A proposta mostra aguardando assinatura e, depois, contrato assinado, com o PDF na propria proposta.

## Fora de escopo

- Cada organizacao conectar a propria conta DocuSign.
- Assinatura embutida no EventHub.
- Templates DocuSign e segunda assinatura do locador.
- Ida para producao (go-live) e troca do bucket para objeto privado.
- Reescrever as clausulas ou o miolo do PDF.

## User stories ou cenarios principais

- O operador, na tela de contrato da pessoa fisica ou juridica, envia o PDF para o e-mail ja salvo na proposta.
- O cliente recebe o convite do DocuSign e assina.
- O operador ve "Contrato assinado" e abre o PDF assinado nos documentos daquela proposta.
- Quem nao pode enviar documentos da proposta nao dispara o envelope.

## Criterios de aceite

- `R-01`: usuario autenticado com `SEND_PROPOSAL_DOCUMENTS` no venue da proposta envia o envelope e recebe `envelopeId` e status `sent`.
- `R-02`: sem login, ou sem essa permissao nesse venue, a API responde 401 ou 403 e nao cria envelope.
- `R-03`: proposta sem `email` salvo e recusada e nenhum envelope e criado.
- `R-04`: o signatario e o `email` e o `completeClientName` gravados na proposta, nao os campos soltos do corpo.
- `R-05`: nenhuma resposta, erro ou log devolve integration key, token, chave privada ou o PDF inteiro.
- `R-06`: com envelope `sent`, `delivered` ou `completed`, um novo envio e recusado.
- `R-07`: depois de um envio aceito, a tela mostra aguardando assinatura e o botao de enviar fica indisponivel.
- `R-08`: webhook sem HMAC valido recebe 401 e nao altera envelope, documento nem `contractSignedAt`.
- `R-09`: webhook `completed` com HMAC valido grava um `Document` PDF dessa proposta, liga o envelope a esse documento e preenche `contractSignedAt`.
- `R-10`: repetir o mesmo `completed` nao cria outro `Document`.
- `R-11`: `declined` e `voided` nao preenchem `contractSignedAt`.
- `R-12`: com status `completed` e documento ligado, a tela mostra contrato assinado e um jeito de abrir esse PDF.
- `R-13`: `.env.example` lista os nomes das variaveis DocuSign, sem valor.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: `ensureAuthenticate` e a permissao no venue da proposta. A permissao da rota do painel nao basta (`project-decisions.md#D-05`).
- erros e mensagens esperadas: sem e-mail, envelope ja em andamento, DocuSign recusou, consentimento JWT ausente. A tela mostra o erro e nao marca enviado.
- observabilidade minima: log com `proposalId`, `envelopeId`, status e duracao. Sem segredo, sem CPF, sem corpo do PDF.
- concorrencia, idempotencia ou retry: dois cliques nao criam dois envelopes abertos. O webhook repetido nao duplica o documento. Falha no webhook responde 500 para o DocuSign tentar de novo.
- rollout, fallback ou degradacao: sandbox ate pedido explicito de producao. DocuSign fora do ar nao muda o estado local para enviado.

## Casos de erro e borda obrigatorios

- caso: proposta sem e-mail salvo
  impacto: envelope criado para o destinatario errado ou vazio
  cobertura esperada: `R-03` em teste do use case
- caso: corpo traz outro e-mail
  impacto: contrato da proposta A vai para outra pessoa
  cobertura esperada: `R-04` em teste do use case
- caso: segundo envio com envelope aberto ou assinado
  impacto: dois convites para o mesmo contrato
  cobertura esperada: `R-06` em teste do use case
- caso: HMAC ausente ou errado
  impacto: terceiros marcam a proposta como assinada
  cobertura esperada: `R-08` em teste do webhook
- caso: `completed` chega duas vezes
  impacto: dois PDFs iguais na proposta
  cobertura esperada: `R-10` em teste do webhook
- caso: download ou S3 falha depois do `completed`
  impacto: proposta assinada sem arquivo
  cobertura esperada: `R-09`; estado local nao fica `completed` e a resposta e 500

## Impacto esperado

A tela de contrato ganha envio e estado. O backend ganha um modulo DocuSign, uma tabela de envelope e a data de assinatura na proposta. O PDF assinado passa a ser um documento da proposta.

## Areas impactadas

- `backend`: rotas, use cases, Prisma, S3, `.env.example`
- `frontend`: formularios PF e PJ do contrato da proposta
- DocuSign sandbox, ja criado pelo operador

## Restricoes e cuidados

- Nao ler nem versionar valores de `.env`.
- A chave privada nao sai do servidor.
- Migration aditiva. `relationMode = "prisma"` (`project-decisions.md#D-03`).
- A API e serverless (`project-decisions.md#D-04`).
- O plano antigo em `docs/planos/PLANO_INTEGRACAO_DOCUSIGN.md` nao manda na decisao de conta por organizacao.

## Dependencias

- `generateContractPdf` ja monta o PDF no browser e hoje so faz download.
- A proposta ja tem `email` e `completeClientName`.
- `Document` e o upload S3 de documento da proposta ja existem.
- `EncryptionService` existe, mas o JWT desta feature usa a chave RSA do ambiente, nao um token de usuario gravado.
- Nomes ja combinados no ambiente local: `DOCUSIGN_INTEGRATION_KEY`, `DOCUSIGN_USER_ID`, `DOCUSIGN_API_ACCOUNT_ID`, `DOCUSIGN_RSA_PRIVATE_KEY`, `DOCUSIGN_OAUTH_BASE_URL`, `DOCUSIGN_BASE_URL`, `DOCUSIGN_REDIRECT_URI`.

## Mapeamento leve requisito -> task -> prova

- `R-01` a `R-06` e `R-13` (nomes de envio) -> `T-01` -> unitario
- `R-07` e `R-12` -> `T-02` -> unitario e tela
- `R-08` a `R-11` e o restante de `R-13` -> `T-03` -> unitario

## Perguntas em aberto

Registradas em `02-clarify.md`. Nenhuma bloqueia o recorte.

## Base documental

- `task-requests/assinatura-contrato-docusign-request.md`
- `project/project-decisions.md#D-02`, `#D-03`, `#D-04`, `#D-05`
- `product/09-integrations.md` e `topics/integrations.md`
- `framework-libs/security/references/secrets-and-key-management.md`
- `framework-libs/patterns/rules/06_senior_engineering_concepts.md`
- codigo: `ContractPdfGenerator.tsx`, `router/email.ts`, `ensureAuthenticate.ts`, `controller-create-document.ts`

## Operacao

- tipo: `spec`
- proxima task: nenhuma
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `fw:review` + `entrega`
- entrada publica recomendada: `fw:review`
