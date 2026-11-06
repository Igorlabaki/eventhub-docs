# Tasks — Video do tour na proposta publica

## Ordem macro

1. `T-01` grava a coluna, valida o link e expoe o campo na apresentacao publica.
2. `T-02` e `T-03` seguem em paralelo. `T-02` e o campo nas configuracoes. `T-03` e o player na proposta.

## Tasks

### T-01 - Gravar o link e devolver na apresentacao

- objetivo: o venue persiste `tourVideoUrl` e o pacote publico devolve esse campo, ja filtrado pela allowlist.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-06`, `R-08`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `PUT /venue/update` e `getPresentation`
- prompt recomendado: normal
- estrategia de teste: unitario do schema e do mapper; `npx prisma validate`
- cenarios obrigatorios:
  - `""` e `null` viram `null`
  - YouTube `watch`, `youtu.be`, `shorts` e `embed` passam
  - `https` terminado em `.mp4` com query passa
  - pagina HTML, `http` e `javascript:` falham
  - `toProposalPresentation` copia `tourVideoUrl` e continua sem dado interno
- definition of done: migration so adiciona a coluna nullable; os dois schemas de update usam a mesma regra; o `select` da apresentacao inclui o campo; testes acima verdes; memoria de topico ou ADR nao muda

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — o campo sai em `GET /proposal/presentation/:proposalId`, que ja e publico
- risco principal: gravar URL que a pagina depois embarca como pagina
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: formulario, player, upload, rota nova, autorizacao das outras rotas do venue
- prova minima desta task: `npm test -- --run` no spec do schema e no da apresentacao, mais `npx prisma validate`
- criterio de escalada: parar se a coluna precisar de `NOT NULL`, backfill ou indice
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`, `node`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `.cursor/framework_global/framework-libs/database/skills/writing-zero-downtime-migrations.md#1. Classificar a mudanca`
  - `.cursor/framework_core/topics/data-and-migrations.md#Regras`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md#3. Revisar dados e segredos`
- caminhos candidatos: `update-venue-params-schema.ts`, `update-venue-params-schema-db.ts`, `getPresentation`, `to-proposal-presentation.ts`
- palavras-chave ou simbolos de busca: `tourVideoUrl`, `proposalColorSchema`, `instagramUrl`, `getPresentation`
- testes provaveis: spec novo do schema ao lado dos schemas de venue; fixture em `use-case-get-proposal-presentation.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `VenueSettings`, `ProposalView`

### T-02 - Campo do tour nas configuracoes

- objetivo: quem edita o espaco informa o link, ve o erro se ele for invalido e salva pela configuracao que ja existe.
- cobre requisitos: `R-01`, `R-06`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: bloco de URLs de `VenueSettings` e `updateVenue`
- prompt recomendado: smart
- estrategia de teste: salvar um YouTube valido e ver o campo preenchido ao reabrir; submeter uma pagina e ver o erro no campo, com o texto digitado preservado
- cenarios obrigatorios:
  - label "Video do tour" visivel
  - vazio salva e o campo volta vazio
  - URL rejeitada mostra a mensagem desta spec e nao limpa o formulario
- definition of done: o campo esta no schema do form, no reset e no payload; o tipo `Venue` e `UpdateVenueDTO` incluem `tourVideoUrl`; nenhuma outra tela de venue muda

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — o painel grava pela rota autenticada que ja existe; o player publico e `T-03`
- risco principal: o campo sumir no reset do formulario ou aceitar pagina que o backend rejeita
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: player, migration, site, e-mail
- prova minima desta task: em Configuracoes, salvar um link de YouTube, reabrir a tela e ver o valor; tentar salvar `https://exemplo.com` e ver o erro no campo
- criterio de escalada: parar se o save exigir endpoint ou permissao novos
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Campo nas configuracoes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Campo nas configuracoes`
  - `03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
  - `.cursor/framework_global/framework-libs/react/rules/main_index.md`
- caminhos candidatos: `VenueSettings.tsx` no grid das URLs; `types/venue.ts`
- palavras-chave ou simbolos de busca: `instagramUrl`, `updateVenue`, `selectedVenue`
- testes provaveis: fluxo manual da tela de configuracoes
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, `ProposalView`, schema Prisma

### T-03 - Player mudo na proposta publica

- objetivo: com link reconhecido, a proposta mostra o tour entre a experiencia e o investimento, em autoplay, loop e sem controle.
- cobre requisitos: `R-02`, `R-04`, `R-05`, `R-07`, `R-09`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: `ProposalView` e o pacote `ProposalPresentation`
- prompt recomendado: normal
- estrategia de teste: unitario de `resolveTourVideo`; na pagina, video presente, mudo e sem controles, e ausente quando o link some
- cenarios obrigatorios:
  - arquivo vira `<video>` sem `controls`, com `muted` e `loop`
  - YouTube vira iframe na `embedUrl` desta spec, com `pointer-events-none`
  - `null`, vazio e pagina nao renderizam bloco
  - sem servicos, o bloco continua acima de "Seu investimento"
- definition of done: helper puro coberto por teste; `ProposalView` consome o helper; o tipo da apresentacao no frontend tem `tourVideoUrl`; memoria de topico ou ADR nao muda

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a pagina publica embarca a midia
- risco principal: iframe de host fora da allowlist ou video com controles e som
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: formulario, migration, upload, outras paginas
- prova minima desta task: teste do resolver verde; em `/proposal/:id/view`, o video toca entre a experiencia e o investimento e some quando o link e apagado
- criterio de escalada: parar se o player precisar de rota nova ou de host fora da allowlist
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Player na proposta`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Player na proposta`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/security/skills/reviewing-security-sensitive-changes.md#1. Classificar a superficie`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
  - `.cursor/framework_global/framework-libs/react/references/react-coding-style.md`
- caminhos candidatos: `ProposalView.tsx` entre os blocos de experiencia e investimento; `proposal.service.ts`
- palavras-chave ou simbolos de busca: `Sua experiência inclui`, `Seu investimento`, `serviceList`, `ProposalPresentation`
- testes provaveis: `src/lib/tour-video` com vitest; pagina publica com e sem link
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `VenueSettings`, schema Prisma
