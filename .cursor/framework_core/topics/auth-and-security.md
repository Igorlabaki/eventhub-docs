# Auth and Security

## Estado atual

- JWT Bearer assinado por `JWT_SECRET_KEY`; `ensureAuthenticate` valida assinatura e `id`, sem checar Session nem revogacao;
- login por e-mail/senha (`bcryptjs`) ou Google (`POST /auth/register/google`, mesmo endpoint para cadastro e login);
- Session e RefreshToken existem no banco; refresh por `GET /auth/refresh` (usado pelo Axios) e `POST /token/refresh` (mesma factory, contrato alternativo);
- frontend guarda `@EventHub:token` e `@EventHub:session` em localStorage;
- reset de senha por e-mail Gmail com link fixo no codigo;
- permissoes CSV por venue e por organizacao; catalogo e divergencias em `topics/permissions-catalog.md`;
- `ensurePermission` so no Google Calendar; authorizers por venue em precos minimos, regras, caracteristicas, servicos, cotacao, indicacoes e site;
- `/owner/*` isolado por organizacao (`OwnerAuthorizer`, participacao em `userOrganization`): 403 ao listar/criar fora da org, 404 ao editar/excluir proprietario de outra org; ainda sem checar `VIEW_ORG_OWNERS`/`EDIT_ORG_OWNERS` no backend;
- `GET /venue/getById` (publico) devolve `ownerVenue` so com ids desde 2026-11-11; antes vazava CPF, PIX e banco do proprietario;
- `GET /proposal/indications/:proposalId`, `presentation/*` e criacao de proposta sao publicos de proposito; o `PUT` de indicacoes exige JWT e `SEND_PROPOSAL_INFO`;
- tokens Google cifrados com AES-256-GCM (`ENCRYPTION_KEY`).

## Riscos confirmados

- 88 endpoints publicos; 14 routers inteiros sem auth, incluindo payment, document, person, contract, clause, contact, emailConfig e `/email/*` (lista em `project/api-endpoints.md`);
- `GET /proposal/byId/:id` devolve proposta completa com PII sem token;
- 12 uploads publicos, maioria sem limite de tamanho;
- auth sem rate limit (register, authenticate, forgot/reset, refresh);
- CORS `*` e `CORS_ORIGIN` ignorada; sem helmet;
- 500 devolve `error.toString()`;
- PII e dados bancarios em Proposal (CPF/CNPJ/RG, endereco), Person, Contact e Owner (CPF, CNPJ, PIX, banco/agencia/conta);
- Owner completo ainda sai em rotas autenticadas sem checar participacao: `/organization/getById`, `/organization/update` e `/organization/update-venue-organization-images` (`owners: true`); `/venue/update` vincula `owners` sem conferir a organizacao do proprietario;
- frontend: `VITE_VERCEL_API_TOKEN` no bundle, `/profile` fora do `ProtectedRoute`, `PUBLIC_ROUTES` incompleta;
- `.env.example` backend contem valor com aparencia de credencial: nao reproduzir; remover e rotacionar em tarefa aprovada;
- remetentes de e-mail e conta Gmail fixos no codigo.

## Regras de execucao

Toda mudanca nesta area usa lib `security`, testes 401/403/ownership, allowlist explicita de rotas publicas (backend e `PUBLIC_ROUTES`) e compatibilidade de cliente: as paginas publicas dependem de varios endpoints hoje publicos, entao fechar um endpoint exige trocar o fluxo publico por token de link ou rota dedicada. Nao revelar segredos em logs, docs, diffs ou saida de ferramenta.

## Fontes

`docs/referencias/AUTHORIZATION_MODEL.md`, `docs/processo/SECURITY_HARDENING.md`, `project/api-endpoints.md`, `src/middleware/` e `src/lib/axios.ts`.
