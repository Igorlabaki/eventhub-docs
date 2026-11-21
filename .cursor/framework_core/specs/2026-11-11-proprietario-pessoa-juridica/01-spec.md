# Spec — Proprietario pessoa fisica ou juridica

## Problema

`Owner` so representa pessoa fisica: `cpf` obrigatorio, sem CNPJ nem razao social, e o contrato so tem `NOME_PROPRIETARIO` e `CPF_PROPRIETARIO`. Espaco cujo dono e uma empresa nao tem como cadastra-la.

O modelo novo expoe quatro falhas que ja existem:

- a edicao com `venueIds` omitido apaga todos os vinculos com espacos, e `data.organizationId` muda o proprietario de organizacao;
- a duplicidade e por `completeName` em todas as organizacoes; com PJ esse campo vira o representante;
- as rotas de `/owner` so exigem token; nenhuma confere se o usuario pertence a organizacao;
- `GET /venue/getById` e publica e devolve `ownerVenue.owner` inteiro (CPF, RG, PIX, banco), inclusive sem `userId`.

No PDF, variavel ausente fica como `{{owner.x}}` e coluna opcional vazia imprime `null`.

## Objetivos

- Cadastrar e editar proprietario PF ou PJ. PJ tem razao social, CNPJ (numerico ou alfanumerico) e porte opcional (MEI, ME, EPP, Demais); nome, CPF e RG passam a ser do representante legal, que no MEI aparece como Titular.
- Os proprietarios que ja existem viram PF sem acao manual.
- A edicao parcial preserva o que nao foi enviado.
- Toda rota de `/owner` respeita a organizacao do usuario.
- Nenhuma rota publica devolve dados do proprietario.
- O PDF preenche razao social, CNPJ e porte sem marcador nem `null`.

## Fora de escopo

- consulta de CNPJ ou CPF na Receita; digito verificador; preencher endereco pelo CNPJ
- natureza juridica (EI, LTDA, SLU, S/A); limites de faturamento; nome fantasia; inscricoes estadual e municipal
- e-mail e telefone do proprietario; assinatura do proprietario no DocuSign
- permissao fina `VIEW_ORG_OWNERS`/`EDIT_ORG_OWNERS` no backend
- autorizacao por organizacao fora de `/owner` (`/organization/getById`, `/venue/update`, vinculo de proprietario pela edicao do espaco)
- regra de vazio do PDF fora do grupo `owner`; cliente PJ da proposta

## User stories ou cenarios principais

- A dona da organizacao cadastra "Festas Silva LTDA", CNPJ `12.ABC.345/01DE-35`, porte ME, representante "Ana Silva", CPF dela. A lista mostra "Festas Silva LTDA" e `12.ABC.345/01DE-35`.
- Ela cadastra "Joao Souza 12345678900", MEI, CNPJ numerico. O formulario mostra Titular, CPF do Titular e RG do Titular.
- Ela abre "Vincular espacos" de uma PJ e marca dois espacos. Tipo, razao social, CNPJ e porte continuam iguais.
- Um usuario de outra organizacao chama `PUT /owner/update` com o `ownerId` da Festas Silva e recebe 404. Nada muda.
- Alguem sem login abre o formulario publico de orcamento do espaco. A resposta de `GET /venue/getById` nao traz CPF, PIX nem CNPJ do proprietario.
- O contrato da Festas Silva sai com razao social, CNPJ formatado, "ME" e o nome e o CPF da Ana. O de um proprietario PF antigo sai com esses tres campos em branco.

## Criterios de aceite

- `R-01`: `owner` ganha `personType` (`PF`/`PJ`, padrao `PF`), `companyName`, `cnpj` e `companySize` (`MEI`/`ME`/`EPP`/`DEMAIS`) por migration aditiva. Todas as linhas existentes ficam `PF`, com os tres outros campos `NULL`, e nenhum dado muda.
- `R-02`: na criacao (`createOrganizationOwner` e `createVenueOwner`), `personType` ausente vale `PF`.
  - PF exige `completeName` e `cpf`, como hoje, e grava `companyName`, `cnpj` e `companySize` como `NULL`, mesmo se vierem no corpo.
  - PJ exige tambem `companyName` e `cnpj`. Sem eles: 400 "Informe a razão social e o CNPJ da empresa.".
  - `companySize` aceita so os quatro valores ou ausente. Fora disso: 400.
- `R-03`: CNPJ aceita 14 posicoes, as 12 primeiras letras ou digitos e as 2 ultimas digitos.
  - Aceita pontuacao (`.`, `/`, `-`, espacos) e minusculas.
  - Grava normalizado: 14 caracteres, maiusculo, sem pontuacao.
  - Fora do formato: 400 "Informe um CNPJ com 12 letras ou números e 2 dígitos no final.".
- `R-04`: `PUT /owner/update` combina o corpo com o registro gravado e valida o resultado pelas regras de `R-02` e `R-03`.
  - Campo omitido preserva o valor gravado, inclusive `personType`.
  - PJ -> PF grava `companyName`, `cnpj` e `companySize` como `NULL`.
  - PF -> PJ sem `companyName` ou `cnpj` responde 400.
  - `companySize: null` remove o porte e mantem PJ.
  - `data.organizationId` e ignorado.
- `R-05`: na edicao, `venueIds` omitido preserva os vinculos, `[]` remove todos e uma lista sincroniza. Espaco de outra organizacao em `venueIds` (edicao ou criacao) ou em `venueId` (criacao no espaco) responde 403, sem gravar nada.
- `R-06`: PJ com CNPJ ja usado por outro proprietario da mesma organizacao responde 409 "Proprietario com este CNPJ ja registrado." (`HttpConflictError("Proprietario com este CNPJ")`), na criacao e na edicao. A comparacao e pelo CNPJ normalizado e exclui o proprio registro. O mesmo CNPJ em outra organizacao passa. PJ nao passa pela checagem de nome.
- `R-07`: na criacao de PF, a duplicidade continua por `completeName` exato, mas so dentro da organizacao (409 "Proprietario ja registrado."). O mesmo nome em outra organizacao passa. A edicao de PF nao checa nome, como hoje.
- `R-08`: listar (`listByOrganization`, `listByVenue`) e criar exigem que o usuario do token pertenca a `organizationId`. Se nao pertence: 403 "Você não tem acesso a esta organização.". Em `listByVenue`, espaco de outra organizacao responde 403.
- `R-09`: editar e excluir carregam a organizacao do proprietario gravado. Se o usuario nao pertence a ela: 404 "Proprietario nao encontrado", igual a id inexistente, e nada e gravado.
- `R-10`: `GET /venue/getById`, com ou sem `userId`, devolve `ownerVenue` so com `ownerId` e `venueId`, sem o objeto `owner`. Painel e formularios publicos continuam funcionando.
- `R-11`: no `OwnerForm`:
  - seletor PF/PJ no topo; registro sem `personType` abre como PF;
  - em PJ: Razao Social, CNPJ (letras nas 12 primeiras posicoes, maiusculas) e Porte (MEI, ME, EPP, Demais ou em branco);
  - rotulos Representante Legal, CPF do Representante e RG do Representante; com MEI, Titular, CPF do Titular e RG do Titular;
  - erros no campo, sem enviar;
  - a edicao abre com tipo e porte gravados e envia `companySize: null` ao limpar o porte.
- `R-12`: `OwnersList` e `OrganizationOwners` mostram razao social e CNPJ formatado para PJ, e nome e CPF para PF. A busca acha por nome, razao social, CPF e CNPJ, com ou sem pontuacao e sem diferenciar maiusculas.
- `R-13`: os seletores de proprietario em `CreateVenueForm`, `VenueSettings`, `pf-contract-form` e `pj-contract-form` mostram `Razão social (Representante)` para PJ e o nome para PF.
- `R-14`: o grupo Proprietario do contrato ganha `RAZAO_SOCIAL_PROPRIETARIO` (`owner.companyName`), `CNPJ_PROPRIETARIO` (`owner.cnpj`, formatado) e `PORTE_PROPRIETARIO` (`owner.companySize`: MEI, ME, EPP ou Demais).
  - Campo conhecido do proprietario sem valor sai em branco, sem `{{...}}` e sem `null`.
  - `NOME_PROPRIETARIO` e `CPF_PROPRIETARIO` trazem o dono em PF e o representante em PJ.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership:
  - a organizacao vem do token mais o registro gravado, nunca so do corpo;
  - a tela nao substitui o backend (D-05).
- erros e mensagens esperadas: as mensagens de `R-02`, `R-03`, `R-06` e `R-08`, em portugues e sem ecoar CPF, CNPJ ou dados bancarios.
- observabilidade minima: `console.error("[owner] acesso negado", { userId, organizationId })` na negativa, sem PII. Sem metrica nova.
- concorrencia, idempotencia ou retry: duplicidade checada na aplicacao; duas criacoes simultaneas com o mesmo CNPJ podem passar (ver `02-clarify.md`). Ultima gravacao vence.
- rollout, fallback ou degradacao:
  - banco, depois API, depois painel;
  - `T-02` pode ir ao ar antes de tudo;
  - o painel trata `personType` ausente como PF;
  - corpo antigo, sem os campos novos, continua valido.

## Casos de erro e borda obrigatorios

- caso: CNPJ `12abc34501de35`, `12.ABC.345/01DE-35` e `12.345.678/0001-95`
  - impacto: os dois primeiros sao o mesmo documento; o terceiro e numerico e valido
  - cobertura esperada: unitario do helper de CNPJ e da duplicidade
- caso: CNPJ com letra nas duas ultimas posicoes, com 13 ou 15 posicoes, ou com caractere especial
  - impacto: documento invalido gravado
  - cobertura esperada: unitario do helper e do schema
- caso: editar so o PIX, ou so `venueIds`, de uma PJ com porte
  - impacto: tipo, empresa, porte ou vinculos apagados
  - cobertura esperada: unitario da edicao
- caso: PJ -> PF -> PJ
  - impacto: dados de empresa orfaos ou PJ sem CNPJ
  - cobertura esperada: unitario da edicao
- caso: usuario da organizacao A lista, cria, edita, exclui ou vincula espaco da organizacao B
  - impacto: leitura ou escrita entre organizacoes
  - cobertura esperada: unitario do autorizador e dos use cases
- caso: `GET /venue/getById` sem `userId`
  - impacto: PII publica
  - cobertura esperada: unitario do use case com repositorio falso e conferencia do `select` no repositorio
- caso: contrato de PF legado com `rg` e `complement` `NULL`
  - impacto: `null` impresso no PDF
  - cobertura esperada: vitest do resolvedor de variaveis

## Impacto esperado

Espacos cujo dono e empresa passam a ter contrato com os dados certos. A API de proprietarios deixa de permitir acesso entre organizacoes, e a PII do proprietario sai da rota publica de espaco.

## Areas impactadas

- `backend`:
  - `prisma/schema.prisma` e uma migration;
  - `src/functions/owner-document.ts` (novo);
  - `src/zod/owner/*`;
  - `src/use-cases/owner/*` e `owner-authorizer.ts` (novo);
  - `owner-in-prisma-repository.ts` e sua interface;
  - `getSelectedVenue` em `venue-in-prisma-repository.ts`.
- `frontend`:
  - `types/owner.ts`;
  - `lib/owner-document.ts` (novo) e `lib/owner-template-values.ts` (novo);
  - `OwnerForm`, `OwnersList` e `OrganizationOwners`;
  - os quatro seletores;
  - `types/contract.ts` e `ContractPdfGenerator.tsx`.
- banco: quatro colunas em `owner` na `main` via deploy request.
- docs:
  - `product/08-data-model.md`;
  - `project/api-endpoints.md`;
  - `topics/auth-and-security.md`.

## Restricoes e cuidados

- D-05: autorizacao no backend; a checagem de `EDIT_ORG_OWNERS` do painel continua so na tela
- D-09: DDL so por branch e deploy request; aplicar na `main` exige aprovacao nomeada
- nao imprimir CPF, CNPJ, RG ou dados bancarios em log, erro ou doc
- `GET /venue/getById` e usada pelos formularios publicos: so muda o formato de `ownerVenue`, a rota continua publica

## Dependencias

- nenhuma spec anterior; `Owner` nao mudou desde a migration inicial
- `verifyByUserIdAndOrganizationId` em `user-organization-in-prisma-repository.ts`
- padrao de autorizador de `src/use-cases/service/service-authorizer.ts`

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> `prisma validate` e `SHOW COLUMNS` na `main`
- `R-10` -> `T-02` -> unitario e chamada sem token
- `R-08`, `R-09` -> `T-03` -> unitario do autorizador e dos use cases
- `R-02`, `R-03` -> `T-04` -> unitario do helper e dos schemas
- `R-04` a `R-07` -> `T-05` -> unitario dos use cases com repositorio falso
- `R-11` a `R-13` -> `T-06` -> vitest dos helpers e browser do painel
- `R-14` -> `T-07` -> vitest do resolvedor e PDF gerado no browser

## Perguntas em aberto

Nenhuma bloqueante. As premissas estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-02` (e `T-01`, `T-03`, `T-04` em paralelo)
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
