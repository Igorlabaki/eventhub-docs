# Auth and Security

## Estado atual

- JWT Bearer assinado por `JWT_SECRET_KEY`;
- frontend guarda access token e Session em localStorage;
- Session e RefreshToken existem no banco;
- `ensureAuthenticate` valida JWT e expoe `req.user.id`;
- `ensurePermission` e usado no fluxo Google Calendar;
- `GET /proposal/indications/:proposalId` e publico de proposito e devolve so os parceiros indicados naquele orcamento; o `PUT` na mesma rota exige JWT e `SEND_PROPOSAL_INFO` no espaco do orcamento;
- `ProtectedRoute` aplica strings de permissao na UI;
- refresh do Axios usa `GET /auth/refresh`, enquanto existe `POST /token/refresh` com contrato diferente.

## Riscos confirmados

- varias rotas de image, document, payment, text, clause, contract, contact e afins nao exigem auth;
- permissao por recurso nao e garantida em todo backend;
- CORS `*`, body grande e erros 500 podem ampliar exposicao;
- PII e dados bancarios existem em Proposal, Person e Owner;
- `.env.example` backend contem valor com aparencia de credencial; nao reproduzir, remover e rotacionar em tarefa aprovada;
- frontend `.env.example` e backend `.env.example` estao incompletos.

## Regras de execucao

Toda mudanca nesta area usa lib `security`, testes 401/403/ownership, allowlist explicita de rotas publicas e compatibilidade de cliente. Nao revelar segredos em logs, docs, diffs ou saida de ferramenta.

## Fontes

`docs/referencias/AUTHORIZATION_MODEL.md`, `docs/processo/SECURITY_HARDENING.md` e routers/middlewares atuais.
