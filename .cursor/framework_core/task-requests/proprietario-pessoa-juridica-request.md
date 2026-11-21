# Solicitacao da Tarefa

## Nome sugerido da tarefa

Proprietario pessoa fisica ou juridica

## Resumo da solicitacao

O proprietario (`Owner`) hoje so pode ser pessoa fisica: CPF obrigatorio e nenhum campo de empresa. O dono da organizacao precisa cadastrar o proprietario como pessoa fisica (PF) ou pessoa juridica (PJ), e na PJ informar, se quiser, o porte (MEI, ME, EPP ou Demais). Os proprietarios que ja existem passam a ser PF sem nenhuma acao manual. A mudanca leva junto quatro correcoes que o modelo novo expoe: edicao parcial que apaga vinculos, duplicidade por nome, falta de isolamento entre organizacoes nas rotas de `/owner` e marcador ou `null` impresso no PDF do contrato.

## Context Pack

- frente principal: cadastro de proprietario (banco, validacao e autorizacao no backend, `OwnerForm` e seletores no painel), com as variaveis de proprietario do contrato em PDF
- superficie sensivel: sim — PII (CPF, CNPJ, RG, endereco, PIX e dados bancarios); autorizacao por organizacao nas rotas de `/owner`; rota publica `GET /venue/getById` devolve o `Owner` inteiro hoje
- camadas transversais: `database`, `security`, `design`
- risco principal: um usuario autenticado ler ou alterar proprietarios de outra organizacao, a edicao parcial apagar dados ou vinculos com espacos, e os campos novos vazarem pelas respostas que incluem o `Owner` inteiro
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`), banco PlanetScale `ar756/main`
- fora de escopo operacional: consulta de CNPJ ou CPF na Receita; digito verificador; busca de CNPJ para preencher endereco; natureza juridica (EI, LTDA, SLU, S/A); limites de faturamento por porte; nome fantasia e inscricoes estadual e municipal; e-mail e telefone do proprietario; assinatura do proprietario no DocuSign; mudar o cliente PJ da proposta (`pj-contract-form`); permissao fina `EDIT_ORG_OWNERS`; mudar a regra de vazio das variaveis fora do grupo `owner`
- prova minima desta execucao:
  - `npx prisma validate`
  - vitest dos schemas Zod: PF sem CNPJ (ok), PJ sem CNPJ ou razao social (400), CNPJ numerico e alfanumerico com e sem pontuacao (ok), CNPJ com letra nas duas ultimas posicoes (400), porte fora do enum (400), payload sem `personType` na criacao (PF)
  - vitest dos use-cases: transicoes PF -> PJ -> PF persistidas; editar so o PIX de uma PJ preserva tipo, razao social, CNPJ, porte e vinculos; `venueIds` omitido preserva vinculos e `[]` limpa; `companySize: null` remove o porte mantendo PJ; mesmo CNPJ com e sem pontuacao na mesma organizacao da 409 e em outra organizacao passa
  - vitest do autorizador: usuario da organizacao A recebe 403/404 ao listar, criar, editar, excluir ou vincular espaco da organizacao B
  - `GET /venue/getById` sem token nao traz CPF, RG, PIX, conta, CNPJ nem razao social do proprietario
  - vitest da substituicao de variaveis do PDF: PF legado, PJ sem porte e PJ MEI, sem `{{...}}` nem `null` impressos
  - no painel: criar PJ MEI (rotulos de Titular), ver razao social nos seletores do espaco e do contrato e gerar o PDF
- criterio de escalada: ja e `spec` (faixa `C`); escalar antes de mexer em `GET /venue/getById` (rota publica usada pelos formularios publicos) e se a correcao de isolamento exigir mudar contrato de outras rotas alem de `/owner`
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/prisma/schema.prisma` em `model Owner`; `art56_server_v3/src/repositories/in-prisma/owner-in-prisma-repository.ts` (inteiro); `eventhub-vista-dashboard/src/components/owner/OwnerForm.tsx` (inteiro); `eventhub-vista-dashboard/src/components/proposal/forms/ContractPdfGenerator.tsx` em `replaceTemplateVars`
- libs obrigatorias: `node`, `database`, `security`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/planetscale.md`
  - `.cursor/framework_core/topics/auth-and-security.md`
  - `.cursor/framework_global/framework-libs/database/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos:
  - backend: `src/zod/owner/{create-owner,create-venue-owner,update-owner,list-owner,list-owners-by-venue}-params-schema.ts`; `src/use-cases/owner/*/`; `src/repositories/in-prisma/owner-in-prisma-repository.ts` e `src/repositories/interface/owner-repository-interface.ts`; `src/router/owner.ts`; autorizadores existentes como modelo (`src/use-cases/service/service-authorizer.ts`, `venue-rule/venue-rule-authorizer.ts`); `src/repositories/in-prisma/venue-in-prisma-repository.ts` (`getSelectedVenue`, `getById`, `update`) e `organization-in-prisma-repository.ts` (`owners: true`); `src/use-cases/venue/get-by-id-venue/`
  - frontend: `src/types/owner.ts`; `src/components/owner/OwnerForm.tsx`, `OwnersList.tsx`; `src/pages/OrganizationOwners.tsx`; seletores em `src/components/venue/CreateVenueForm.tsx`, `src/pages/VenueSettings.tsx`, `src/components/proposal/forms/pf-contract-form.tsx` e `pj-contract-form.tsx`; `src/types/contract.ts` (`DynamicField`, `fieldGroups`); `src/components/proposal/forms/ContractPdfGenerator.tsx`
- palavras-chave ou simbolos de busca: `model Owner`, `personType`, `companySize`, `vefiryIfOwnerExists`, `venuesToDisconnect`, `updateOwnerSchema`, `ensureAuthenticate`, `ensurePermission`, `userOrganization`, `getSelectedVenue`, `ownerVenue`, `owners: true`, `replaceTemplateVars`, `owner.completeName`, `CPF_PROPRIETARIO`, `fieldGroups`
- testes provaveis: schemas Zod de owner; use-cases de criar, editar, listar e excluir owner com repositorio falso; autorizador novo de owner; helper de normalizacao e formato de CNPJ (backend e frontend); helper de nome exibido do proprietario; substituicao de variaveis do PDF extraida para funcao testavel
- nao ler por padrao: `Proposal` e formularios de contrato do cliente alem dos seletores de proprietario; Asaas, DocuSign, relatorios

## Contexto informado na entrada

Pergunta em chat: "consigo cadastrar como proprietario so pessoa fisica?". Confirmado no codigo que sim. O usuario decidiu: o proprietario pode ser PF ou PJ, os que existem ficam PF, PJ segue o padrao do cliente PJ da proposta (empresa mais representante legal), porte opcional (MEI, ME, EPP, Demais) sem natureza juridica, e MEI mostra Titular no lugar de Representante Legal.

Revisao estatica posterior pediu cinco fechamentos antes de dividir a implementacao: edicao parcial, CNPJ alfanumerico, duplicidade de PJ, isolamento entre organizacoes e prova da selecao ate o PDF. Todos conferidos no codigo:

- `owner-in-prisma-repository.ts#update`: com `venueIds` omitido, `venuesToDisconnect` recebe todos os vinculos atuais e apaga todos
- `updateOwnerSchema` aceita `organizationId` em `data`, o que permite mover o proprietario de organizacao
- `vefiryIfOwnerExists` busca `completeName` em todas as organizacoes; com PJ esse campo vira o representante
- rotas de `/owner` so passam por `ensureAuthenticate`; listagem usa `organizationId` da query e edicao e exclusao usam `ownerId`, sem conferir se o usuario pertence a organizacao
- `GET /venue/getById` e publica e chama `getSelectedVenue` com `userId` opcional da query; sem `userId`, o filtro `userOrganization: { userId: undefined }` nao restringe nada e a resposta inclui `ownerVenue.owner` inteiro (CPF, RG, PIX, banco). Leitura de codigo, nao exercitado
- `replaceTemplateVars`: propriedade ausente mantem `{{owner.x}}` no PDF; propriedade `null` (coluna opcional vazia) imprime `null`

CNPJ alfanumerico: a Receita Federal emite CNPJ alfanumerico para novas inscricoes desde julho de 2026 (IN RFB 2.229/2024). Os CNPJs existentes continuam numericos.

## Problema atual

Espaco cujo dono e uma empresa nao consegue cadastrar o proprietario: o cadastro exige CPF, nao tem CNPJ nem razao social, e o contrato so oferece `NOME_PROPRIETARIO` e `CPF_PROPRIETARIO`. Alem disso, a API de proprietarios nao isola organizacoes, a edicao parcial apaga vinculos com espacos e uma rota publica expoe os dados do proprietario.

## Objetivo da mudanca

O painel cadastra e edita proprietario PF ou PJ (CNPJ numerico ou alfanumerico, porte opcional) so dentro da organizacao do usuario, a edicao parcial preserva o que nao foi enviado, os proprietarios antigos seguem como PF, nenhuma rota publica devolve dados do proprietario, e o PDF preenche razao social, CNPJ e porte sem imprimir marcador nem `null`.

## Escopo inicial percebido

Dois enums e quatro colunas em `Owner`; regras de criacao e de edicao parcial nos use-cases; normalizacao e formato de CNPJ; duplicidade por CNPJ na organizacao; autorizador por organizacao em todas as rotas de `/owner`; resposta publica de espaco sem proprietario; formulario, lista, busca e seletores no painel; tres variaveis novas e regra de vazio no PDF.

## Itens incluidos neste request

- banco: `enum OwnerPersonType { PF PJ }`; `enum CompanySize { MEI ME EPP DEMAIS }`; `Owner.personType OwnerPersonType @default(PF)`; `Owner.companyName String?`; `Owner.cnpj String?`; `Owner.companySize CompanySize?`; `@@index([organizationId, cnpj])`; migration aditiva via deploy request (linhas existentes ficam `PF` e sem porte)
- regra dos campos:
  - PF: `completeName` = nome completo, `cpf` obrigatorio, `rg` opcional (como hoje); sem dados de empresa
  - PJ: `companyName` (razao social) e `cnpj` obrigatorios; `companySize` opcional; `completeName`, `cpf` e `rg` sao do representante legal (`completeName` e `cpf` obrigatorios, `rg` opcional)
  - endereco e dados bancarios iguais nos dois tipos (em PJ: sede e conta da empresa)
- CNPJ:
  - 14 posicoes: as 12 primeiras letras maiusculas ou digitos, as 2 ultimas digitos
  - formulario, API e busca aceitam com ou sem pontuacao (`.`, `/`, `-`, espacos) e com letras minusculas
  - gravado normalizado (14 caracteres, sem pontuacao, maiusculo) e exibido formatado `XX.XXX.XXX/XXXX-XX`
- criacao: `personType` ausente = `PF`; dados de empresa enviados para PF sao gravados como `null`
- edicao parcial:
  - `personType` ausente mantem o tipo gravado
  - o use-case combina o payload com o registro atual e valida o resultado com as regras de PF ou PJ
  - campo omitido preserva o valor gravado
  - `venueIds` omitido preserva os vinculos; `[]` remove todos; lista sincroniza
  - PJ -> PF grava `companyName`, `cnpj` e `companySize` como `null`
  - PF -> PJ exige `companyName` e `cnpj` no payload
  - `companySize: null` remove o porte e mantem PJ; omitido preserva
  - `organizationId` em `data` deixa de ser aceito (proprietario nao muda de organizacao)
- duplicidade:
  - PJ: CNPJ normalizado unico dentro da organizacao, na criacao e na edicao (excluindo o proprio registro); 409 com mensagem em portugues
  - PJ nao passa mais pela checagem de `completeName`
  - PF: politica legada explicita (ver pergunta em aberto)
- isolamento entre organizacoes:
  - autorizador de owner (no padrao dos autorizadores existentes) confere `userOrganization` do usuario autenticado em todas as rotas de `/owner`
  - listar e listar por espaco: `organizationId` da query precisa ser do usuario, e o espaco precisa ser da organizacao
  - criar na organizacao e no espaco: `organizationId` do usuario; `venueIds` e `venueId` precisam ser da mesma organizacao
  - editar e excluir: organizacao vem do proprietario gravado, nao do payload; `venueIds` precisam ser da mesma organizacao
- respostas que incluem o `Owner` inteiro:
  - `GET /venue/getById` (publica) deixa de devolver dados do proprietario; prova negativa sem token
  - `/organization/getById`, `/organization/update`, `updateImages` e as rotas autenticadas de espaco (`ownerVenue.owner`) seguem devolvendo o proprietario so para quem passou pela autorizacao da propria rota; registrar no topic de seguranca se a rota nao confere a organizacao
- painel:
  - `OwnerForm`: seletor PF/PJ; em PJ, Razao Social, CNPJ (aceita letras nas 12 primeiras posicoes) e Porte (MEI, ME, EPP, Demais ou em branco); rotulos Representante Legal, CPF do Representante e RG do Representante; com MEI, Titular, CPF do Titular e RG do Titular; edicao abre no tipo e no porte gravados e envia `null` para limpar porte
  - `OwnersList` e `OrganizationOwners`: PJ mostra razao social e CNPJ formatado; PF mostra nome e CPF; busca em memoria normaliza os dois lados e acha por nome, razao social, CPF e CNPJ
  - seletores de proprietario em `CreateVenueForm`, `VenueSettings`, `pf-contract-form` e `pj-contract-form`: PJ mostra `Razao social (Representante)`, PF mostra o nome
- contrato:
  - `owner.companyName` (`RAZAO_SOCIAL_PROPRIETARIO`), `owner.cnpj` (`CNPJ_PROPRIETARIO`, formatado) e `owner.companySize` (`PORTE_PROPRIETARIO`) em `DynamicField` e no grupo Proprietario de `fieldGroups`
  - variaveis `owner.*` com valor ausente, `null` ou vazio saem como texto vazio, sem `{{...}}` e sem `null`
  - `NOME_PROPRIETARIO` e `CPF_PROPRIETARIO` trazem o dono em PF e o representante em PJ
- docs: `product/08-data-model.md`, `project/api-endpoints.md` (payload e autorizacao de `/owner`, resposta de `/venue/getById`) e `topics/auth-and-security.md`

## Requisitos implicitos ja visiveis

- proprietario sem `personType` (resposta de API antiga) e tratado como PF no frontend (`personType ?? "PF"`)
- `cpf` continua obrigatorio nos dois tipos; o formato do CPF gravado nao muda
- o porte nao muda nenhuma validacao; so o rotulo do representante muda no MEI
- o rotulo Titular so muda a tela; os campos gravados continuam `completeName`, `cpf` e `rg`
- o `OwnerForm` atual sempre envia `venueIds`; a regra de omitido protege chamadas de outras telas e da API
- os formularios publicos que usam `GET /venue/getById` nao dependem de dados do proprietario (confirmar antes de mudar a resposta)

## Casos de erro e borda ja percebidos

- PJ sem CNPJ ou sem razao social, inclusive depois de combinar a edicao parcial: 400 com mensagem em portugues
- CNPJ com menos ou mais de 14 posicoes, caractere fora de `A-Z0-9` ou letra nas duas ultimas: 400
- CNPJ `12.ABC.345/01DE-35` e `12abc34501de35` sao o mesmo documento para duplicidade e busca
- porte fora do enum: 400
- PF com CNPJ, razao social ou porte no payload: gravados como `null`
- `venueIds` com espaco de outra organizacao: 403
- `ownerId` de outra organizacao em editar ou excluir: 404 (nao revela que existe)
- `organizationId` de organizacao do qual o usuario nao participa em listar ou criar: 403
- PDF de proprietario PF legado: `RAZAO_SOCIAL_PROPRIETARIO`, `CNPJ_PROPRIETARIO` e `PORTE_PROPRIETARIO` vazios; `RG_PROPRIETARIO` e `COMPLEMENTO_PROPRIETARIO` sem valor saem vazios em vez de `null`
- PDF de PJ sem porte: so `PORTE_PROPRIETARIO` vazio

## Dependencias

- nenhuma spec anterior; o modelo `Owner` nao mudou desde a migration inicial
- ordem de deploy: banco, API, painel
- a correcao da resposta publica de `GET /venue/getById` pode sair antes, como correcao separada (ver pergunta em aberto)

## Restricoes e cuidados

- migration so aditiva e na `main` do PlanetScale por deploy request; escrita no banco real exige aprovacao nomeada
- nao imprimir CPF, CNPJ, RG ou dados bancarios em log nem em mensagem de erro
- nao abrir rota publica nova; mudanca em rota publica existente segue a lib `security` com teste negativo
- nao mexer nos campos do cliente PJ da proposta (`Proposal.cnpj`, `completeCompanyName`)
- autorizacao fica no backend; esconder botao no painel nao conta como isolamento
- seguir os rotulos ja usados no contrato PJ do cliente (`PJContractPersonalInfoForm`)

## Perguntas em aberto

- Duplicidade de PF: manter o criterio por `completeName`? Premissa: sim, mas restrito a organizacao (hoje e global e um 409 revela que o nome existe em outra organizacao); PF -> PF na edicao nao checa nome, como hoje.
- Exposicao publica do proprietario em `GET /venue/getById`: corrigir dentro desta spec ou antes, em request separado? Premissa: request separado de faixa `B` e prioridade alta, executado antes desta spec; se nao sair antes, entra como primeira task daqui.
- Isolamento so por participacao na organizacao ou tambem pela permissao `EDIT_ORG_OWNERS`/`VIEW_ORG_OWNERS`? Premissa: so participacao nesta entrega; permissao fina fica registrada como lacuna.
- Validar digito verificador do CNPJ (numerico e alfanumerico) e do CPF? Premissa: nao; so formato.
- Como o porte sai no contrato? Premissa: `MEI`, `ME` e `EPP` pela sigla e `DEMAIS` como `Demais`.
- Regra de vazio do PDF vale so para `owner.*` ou para todas as variaveis? Premissa: so `owner.*`.
- E-mail e telefone do proprietario entram? Premissa: nao.
- Variavel generica `DOCUMENTO_PROPRIETARIO`? Premissa: nao.

## Prioridade sugerida

Media para PF/PJ. Alta para o isolamento entre organizacoes e para a exposicao publica do proprietario, que ja existem hoje independentemente desta feature.

## Faixa sugerida para task workflow

- `C` — schema novo, PII, autorizacao, rota publica, dois repos e contrato em PDF, com ordem de entrega propria
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: toca banco, backend e frontend, guarda PII nova, muda autorizacao de um router inteiro e se divide em tasks com ordem (migration; autorizador e isolamento; criacao, edicao parcial e duplicidade; CNPJ; formulario, lista e seletores; PDF; docs)

## Sugestao de slug da spec

- `framework_core/specs/2026-11-11-proprietario-pessoa-juridica/`

## Sugestao de nome do arquivo

- `proprietario-pessoa-juridica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `spec`
- status: promovido para spec em 2026-11-11; nada implementado
- proximo passo: ver spec
- promovida para: `specs/2026-11-11-proprietario-pessoa-juridica/`
- entrada publica recomendada: `fw:review` na spec
- derivacao repo-local: depois da spec, com `spec-driven/spec-repo-split-prompt.md` (banco e API antes do painel)
