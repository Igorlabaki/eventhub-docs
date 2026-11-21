# Clarify — Proprietario pessoa fisica ou juridica

## Perguntas criticas

- O proprietario pode ser PF ou PJ? Sim. Confirmado pelo usuario.
- O que acontece com os que existem? Ficam PF. Confirmado pelo usuario.
- Quais dados a PJ tem? Razao social e CNPJ; nome, CPF e RG viram do representante legal, no padrao do cliente PJ da proposta. Confirmado pelo usuario.
- Tipo de empresa? Porte opcional (MEI, ME, EPP, Demais), sem natureza juridica. Com MEI, Titular no lugar de Representante Legal. Confirmado pelo usuario.
- Revisao estatica pediu: edicao parcial com merge, CNPJ alfanumerico, duplicidade de PJ por CNPJ na organizacao, isolamento entre organizacoes e prova da selecao ate o PDF. Aceito no request.

## Respostas confirmadas

- `Owner` tem `completeName`, `cpf` (obrigatorio), `rg` (opcional), endereco, PIX e banco; nenhum campo de empresa (`schema.prisma`, `model Owner`).
- `owner-in-prisma-repository.ts#update`: com `venueIds` omitido, `venuesToDisconnect` recebe todos os vinculos atuais e o `deleteMany` apaga todos.
- `updateOwnerSchema` aceita `data.organizationId`, que vai direto ao `prisma.owner.update`.
- `vefiryIfOwnerExists(completeName)` busca em todas as organizacoes e e usado nas duas criacoes.
- `ownerRoutes.use(ensureAuthenticate)`; nenhum controller de owner le `req.user.id`. Listar usa `organizationId` da query; editar e excluir usam `ownerId`.
- `verifyByUserIdAndOrganizationId({ userId, organizationId })` ja existe em `UserOrganizationRepositoryInterface`.
- `ServiceAuthorizer` e o modelo de autorizador: recebe repositorios por `Pick`, lanca `HttpTokenError`, `HttpResourceNotFoundError` ou `HttpForbiddenError`, e faz `console.error` sem PII.
- `GET /venue/getById` nao tem `ensureAuthenticate`; chama `getSelectedVenue({ venueId, userId })` com `userId` opcional da query e inclui `ownerVenue: { include: { owner: true } }`. Os formularios publicos (`ProposalForm`, `PartnerForm`, `CrewForm`, `usePublicListVenue`) chamam sem `userId`.
- No painel, `selectedVenue.ownerVenue` so e usado para ler `ownerId` (`VenueSettings.tsx`). As listas de proprietarios vem de `/owner/*` pelo `ownerStore`.
- `VenueSelectionDialog` ja chama `updateOwner(ownerId, { venueIds })`, uma edicao parcial real.
- `OwnersList` e `OrganizationOwners` filtram em memoria (`completeName` e `cpf.includes`). A API de listagem so filtra `completeName`.
- `replaceTemplateVars` em `ContractPdfGenerator.tsx`: propriedade `undefined` devolve o marcador; `null` passa por `value !== undefined` e vira o texto `null`.
- `HttpConflictError(msg)` responde 409 com "`msg` ja registrado."; `HttpResourceNotFoundError(msg)` responde 404 com "`msg` nao encontrado".
- `handleErrors` ja traduz `ZodError` em 400.
- Prisma em MySQL grava enum como coluna `ENUM`.
- A Receita emite CNPJ alfanumerico para inscricoes novas desde julho de 2026 (IN RFB 2.229/2024); os antigos seguem numericos. Formato: 12 posicoes `A-Z0-9` mais 2 digitos verificadores numericos.

## Requisitos implicitos confirmados

- `cpf` segue obrigatorio nos dois tipos, entao a coluna nao muda.
- O rotulo Titular e so de tela; os campos gravados sao os mesmos.
- O porte nao muda nenhuma validacao.
- A organizacao do proprietario nunca muda depois da criacao.

## Premissas assumidas

- Exposicao publica (`R-10`) sai como `T-02` desta spec, sem depender do banco, e pode ir ao ar antes de tudo.
  - Risco se estiver errado: se o time preferir um request separado, `T-02` vira esse request sem mudar o conteudo.
- Isolamento por participacao na organizacao (`userOrganization`), sem conferir `VIEW_ORG_OWNERS`/`EDIT_ORG_OWNERS` no backend.
  - Risco se estiver errado: um membro sem a permissao de proprietarios consegue editar pela API. Fica registrado em `topics/auth-and-security.md` como lacuna.
- Editar ou excluir proprietario de outra organizacao responde 404, e listar ou criar em organizacao alheia responde 403.
  - Risco se estiver errado: so muda o codigo HTTP; nenhum dado vaza.
- Duplicidade de PF continua por `completeName` exato, mas restrita a organizacao.
  - Risco se estiver errado: duas organizacoes com um proprietario de mesmo nome deixam de conflitar, o que e o comportamento desejado; dentro da organizacao nada muda.
- Duplicidade checada na aplicacao, sem indice unico.
  - Risco se estiver errado: duas criacoes simultaneas com o mesmo CNPJ passam. O cadastro e manual e raro; o indice unico pode vir depois sem mudar contrato.
- Sem indice novo: `@@index([organizationId])` ja cobre as buscas por organizacao.
  - Risco se estiver errado: nenhum com o volume atual.
- So formato do CNPJ; sem digito verificador.
  - Risco se estiver errado: CNPJ digitado errado passa; o mesmo vale hoje para o CPF.
- CNPJ gravado normalizado; CPF continua como chega hoje (com mascara do formulario).
  - Risco se estiver errado: nenhum dado antigo muda; a busca normaliza os dois lados.
- PF com dados de empresa no corpo grava `NULL`, sem 400.
  - Risco se estiver errado: um erro de tela passa sem aviso, sem efeito no dado.
- `companyName` e o nome juridico (razao social); `completeName` continua obrigatorio em PJ (representante).
  - Risco se estiver errado: nenhum; a tela pede os dois.
- Regra de vazio do PDF so para campos conhecidos do grupo `owner`; `{{owner.campoInexistente}}` continua aparecendo para o autor do modelo perceber o erro.
  - Risco se estiver errado: nenhum dado sai errado.
- Porte no PDF: `MEI`, `ME` e `EPP` pela sigla; `DEMAIS` como `Demais`.
  - Risco se estiver errado: so o texto muda.
- Em `/owner/listByOrganization` e `/owner/listByVenue`, a resposta continua com o `Owner` inteiro (inclui os campos novos), porque so membros da organizacao chegam la.

## Perguntas de erro e borda ainda abertas

- Nenhuma. A execucao segue pelas premissas acima.

## Itens bloqueantes

- Aplicar o deploy request na `main` (`T-01`) exige aprovacao nomeada (org `igorlabakig`, banco `ar756`, numero do deploy request). O codigo das outras tasks pode ser escrito antes, mas a API de `T-05` nao vai ao ar antes das colunas.
- `T-02` muda a resposta de uma rota publica usada pelos formularios publicos: confirmar com o owner antes do deploy (criterio de escalada do `agent-entrypoint.md`).

## O que pode seguir mesmo com lacunas

- `T-02`, `T-03` e `T-04` nao dependem do banco e podem comecar ja.
- O review pode trocar 404 por 403 na edicao sem redesenhar: muda so o ramo do autorizador.

## Lacunas registradas fora do escopo

- `/organization/getById`, `/organization/update` e `updateImages` devolvem `owners` inteiro e sao autenticadas, mas nao conferem a organizacao do usuario.
- `/venue/update` aceita `owners` (ids) e liga proprietario ao espaco sem conferir se o proprietario e da mesma organizacao.
- Ambas vao para `topics/auth-and-security.md#Riscos confirmados` em `T-03`.
