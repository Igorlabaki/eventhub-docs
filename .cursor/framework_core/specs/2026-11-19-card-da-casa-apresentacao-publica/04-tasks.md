# Tasks — Card da casa na apresentacao publica

## Ordem macro

1. `T-01` acrescenta `slogan` ao GET publico.
2. `T-02` desenha o topo e o card. Depende de `T-01`.

## Tasks

### T-01 - Slogan no GET publico

- objetivo: `GET /venue/presentation/:venueId` devolve `slogan` e nenhuma chave a mais.
- cobre requisitos: `R-01`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `toVenuePresentation`, `getPublicPresentation`, `ALLOWED_KEYS`
- prompt recomendado: `smart`
- estrategia de teste: vitest do mapper com slogan preenchido e nulo; a lista de chaves
- cenarios obrigatorios:
  - slogan preenchido volta o mesmo texto
  - slogan `null` volta `null`
  - `Object.keys` igual a `ALLOWED_KEYS` com `slogan`
  - a resposta continua sem `email`, `cep` e dono
- definition of done:
  - o `select` de `getPublicPresentation` pede `slogan`
  - o teste do mapper verde
  - nenhuma coluna nova

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — o GET publico ganha uma chave
- risco principal: o retorno levar e-mail, CEP ou dono junto com o slogan
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: pagina, card, aba, migration
- prova minima desta task: vitest verde com slogan preenchido, slogan nulo e a lista de chaves
- criterio de escalada: parar se `slogan` nao existir no client do Prisma
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_global/framework-libs/security/rules/02_auth_and_access.md`
- caminhos candidatos: `art56_server_v3/src/functions/to-venue-presentation.ts`; `getPublicPresentation` em `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts`; `use-case-get-venue-presentation.spec.ts`
- palavras-chave ou simbolos de busca: `ALLOWED_KEYS`, `slogan`, `getPublicPresentation`
- testes provaveis: `npx vitest run src/use-cases/venue/get-venue-presentation/use-case-get-venue-presentation.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `VenuePresentation.tsx`

### T-02 - Card e slogan na pagina

- objetivo: a apresentacao mostra o slogan no topo e o card da casa entre o hero e a foto.
- cobre requisitos: `R-02`, `R-03`, `R-04`, `R-05`, `R-06`, `R-07`, `R-08`, `R-09`, `R-10`, `R-11`, `R-12`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: casca do card em `ProposalView`, `venueTabTitle`, `mapLabel`, `planVenuePhotos`
- prompt recomendado: `normal`
- estrategia de teste: vitest da funcao pura; a pagina consome `slogan` e `houseCard`; `ProposalView` segue com a descricao no topo
- cenarios obrigatorios:
  - com video, `blocks` tem `video`, `house`, `solo-photo` nessa ordem
  - sem video, `house` fica entre `hero-photo` e `solo-photo`
  - sem foto, `house` permanece e nao ha `solo-photo` nem `grid`
  - slogan e descricao so com espaco viram `null`
  - sem pernoite, schedule usa abertura e fechamento; com pernoite, usa check-in e check-out
  - um lado do horario vazio sai da frase; os dois vazios deixam `schedule` nulo
  - noites so com pernoite e valor maior que zero
  - `placeLabel` omite bairro ou cidade ausente
  - capacidade usa `maxGuest`
- definition of done:
  - vitest de `venue-presentation` verde
  - `npm test` do frontend verde
  - a aba chama `venueTabTitle` com o slogan
  - `topics/public-pages-and-branding.md#Demais paginas publicas` descreve slogan, card e foto nessa ordem
  - no browser, com sessao, a apresentacao mostra o card entre o video e a foto

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a pagina e publica; o desenho nao amplia o contrato
- risco principal: a descricao continuar no topo, ou a foto deixar de aparecer depois do card
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: backend, orcamento, formulario publico, migration
- prova minima desta task: vitest da ordem e do card verde; no browser, slogan, card e foto nessa sequencia
- criterio de escalada: parar se o card exigir chave que `T-01` nao devolve
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Card da casa`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Card da casa`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/design/rules/03_layout_grid_and_hierarchy.md`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Demais paginas publicas`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenuePresentation.tsx`; `eventhub-vista-dashboard/src/lib/venue-presentation.ts`; `eventhub-vista-dashboard/src/lib/venue-presentation.test.ts`; card e `hourLabel` em `eventhub-vista-dashboard/src/pages/ProposalView.tsx`
- palavras-chave ou simbolos de busca: `soloPhoto`, `venuePresentationView`, `venueTabTitle`, `hourLabel`, `mapLabel`
- testes provaveis: vitest de `src/lib/venue-presentation.test.ts`; `npm test` no frontend
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, backend alem de `slogan` em `03-design.md#Contratos e dados`
