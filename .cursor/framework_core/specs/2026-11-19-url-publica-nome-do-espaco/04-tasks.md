# Tasks — URL publica pelo nome do espaco

## Ordem macro

1. `T-01` backend resolve nome ou UUID nas duas leituras publicas
2. `T-02` frontend monta os links com o nome e grava o orcamento com o id

`T-02` depende de `T-01` no ar. Sem a API, o link com nome responde 404.

## Tasks

### T-01 - Resolver a casa pelo nome nas leituras publicas

- objetivo: apresentacao e `getById` sem `userId` encontram a casa pelo nome decodificado ou pelo UUID, sem campo novo
- cobre requisitos: `R-03`, `R-04`, `R-05`, `R-06`, `R-07`, `R-09`, `R-10`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `getPublicPresentation`, `getSelectedVenue`, `toVenuePresentation`
- prompt recomendado: normal
- estrategia de teste: vitest no repositorio e no use case, com o prisma capturado como no spec de `getById` sem proprietario
- cenarios obrigatorios:
  - nome gravado encontra a casa na apresentacao e no `getById` sem `userId`
  - UUID encontra por id e nao consulta `name`
  - nome ausente devolve o 404 atual de cada leitura
  - texto com espaco, ja decodificado, busca esse texto
  - `getById` com `userId` e um nome nao busca `name`
  - a apresentacao continua sem `ensureAuthenticate` e o body nao ganha dono, contrato nem pagamento
  - o `getById` sem `userId` nao ganha include
- definition of done:
  - `project/api-endpoints.md#Venue, precos e configuracao` e `#Endpoints publicos sensiveis` dizem que essas duas leituras aceitam nome ou UUID
  - vitest do backend desses casos passa
  - nenhuma migration

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — as duas rotas sao publicas
- risco principal: resolver nome tambem quando ha `userId`, ou acrescentar campo na resposta
- repos tocados: `art56_server_v3/`
- fora de escopo desta task: links do frontend, `/service/list`, POST de proposta, limpar `contracts` do `getById`
- prova minima desta task: vitest mostra nome e UUID abrindo a casa, nome ausente no 404, e `userId` sem busca por nome
- criterio de escalada: se a resolucao exigir endpoint novo ou mudanca de schema, parar e voltar ao `03-design.md#Decisoes arquiteturais importantes`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Decisoes arquiteturais importantes`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `framework-libs/security/rules/02_auth_and_access.md`
  - `project/api-endpoints.md#Endpoints publicos sensiveis`
- caminhos candidatos: `venue-in-prisma-repository.ts` `getPublicPresentation` e `getSelectedVenue`; `use-case-get-venue-presentation.ts`; `use-case-get-by-id-venue.ts`; `router/venue.ts`
- palavras-chave ou simbolos de busca: `getPublicPresentation`, `getSelectedVenue`, `where: { id: venueId }`, `userId`
- testes provaveis: `use-case-get-venue-presentation.spec.ts`, `use-case-get-by-id-venue.spec.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, formulario do frontend

### T-02 - Montar os links com o nome e gravar o orcamento com o id

- objetivo: apresentacao e formulario copiam o nome; o formulario carrega por essa chave e envia `venue.id`
- cobre requisitos: `R-01`, `R-02`, `R-06`, `R-08`, `R-09`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `publicVenuePresentationShareUrl`, `ProposalForm`, `PUBLIC_ROUTES`
- prompt recomendado: normal
- estrategia de teste: vitest do link e do contrato do formulario; a rota publica nao muda de padrao
- cenarios obrigatorios:
  - share da apresentacao e link copiado do formulario usam `encodeURIComponent(name)` no host fixo
  - nome com espaco sai codificado
  - `ProposalForm` trata o parametro como nome, espera a casa e passa `selectedVenue.id` aos dois formularios de envio
  - parametro UUID ainda casa com `selectedVenue.id`
  - nome desconhecido mostra a falha ja existente, sem outra casa
  - `PUBLIC_ROUTES` segue cobrindo as duas paginas
- definition of done:
  - `topics/public-pages-and-branding.md#Pedido de orcamento` e `#Demais paginas publicas` citam o nome na URL e o UUID antigo ainda valido
  - vitest do frontend desses casos passa
  - browser: `/venue/AR756/apresentacao` e `/venue/AR756/form` abrem sem login; o payload de criacao leva o id da AR756

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — as paginas sao publicas; o risco e gravar o nome como id
- risco principal: `ClientPerPersonProposalForm` ou `ClientPerDayProposalForm` receberem o nome
- repos tocados: `eventhub-vista-dashboard/`
- fora de escopo desta task: busca no backend, painel, `/proposal/:id/view`
- prova minima desta task: os dois links da AR756 usam o nome; o formulario, com o parametro `AR756`, chama servicos e criacao com o id
- criterio de escalada: se o formulario precisar de um endpoint que nao seja o `getById` atual, parar e voltar ao `03-design.md#Decisoes arquiteturais importantes`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `security`
- documentos obrigatorios:
  - `03-design.md#Visao geral da solucao`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `topics/public-pages-and-branding.md#Pedido de orcamento`
  - `framework-libs/security/rules/02_auth_and_access.md`
- caminhos candidatos: `public-venue-presentation.ts`, `VenueNav.tsx`, `VenueBudgets.tsx`, `ProposalForm.tsx`, `ClientPerPersonProposalForm.tsx`, `ClientPerDayProposalForm.tsx`
- palavras-chave ou simbolos de busca: `publicVenuePresentationShareUrl`, `selectedVenue.id`, `venueId={id}`, `Copiar link do formulário de orçamento`
- testes provaveis: `public-venue-presentation.test.ts`, `sidebar-nav-model.test.ts`, teste do formulario publico
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, repositorio Prisma
