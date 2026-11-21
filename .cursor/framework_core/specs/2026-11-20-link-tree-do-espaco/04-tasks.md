# Tasks — link tree do espaco

## Ordem macro

1. `T-01` checagem, lista padrao e schema
2. `T-02` leitura publica e gravacao
3. `T-03` aba Redes e `T-04` pagina e sidebar, em paralelo depois de `T-02`

## Tasks

### T-01 - Checagem da URL, lista padrao e tabela

- objetivo: o backend reconhece o dominio de cada tipo e calcula a lista padrao; a tabela existe no schema
- cobre requisitos: `R-06`, `R-08`, `R-09`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `isTourVideoUrl` so para nao misturar o tour com o canal
- prompt recomendado: smart
- estrategia de teste: unitario da funcao pura; `npx prisma validate`
- cenarios obrigatorios:
  - Instagram de perfil verde; `/p/`, reel, story e explore ambar
  - Facebook `profile.php?id=100085832906065` verde
  - TikTok `@usuario` verde e `/video/` ambar
  - site com dominio de Instagram vermelho
  - YouTube `@canal` verde; `watch?v=` e `youtu.be` ambar
  - lista padrao da AR756 liga apresentacao, orcamento, regras e os quatro links preenchidos
  - site da organizacao so entra com `Organization.url`
  - WhatsApp vazio fica na lista e nao nasce visivel
- definition of done: funcao e enum no backend; migration aditiva so no repositorio; Prisma valida; testes verdes; nenhuma chamada a `main`

#### Context Pack

- frente principal: backend
- superficie sensivel: nao
- risco principal: a migration nascer destrutiva ou ser aplicada na `main`
- repos tocados: `art56_server_v3`
- fora de escopo desta task: rota HTTP, aba Redes, pagina publica, deploy request
- prova minima desta task: `npm test` da checagem e da lista padrao verde; `npx prisma validate` verde; a migration nao foi enviada ao PlanetScale
- criterio de escalada: parar se a tabela precisar apagar `url`, `instagramUrl`, `facebookUrl` ou `tiktokUrl`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `database`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `topics/data-and-migrations.md#Regras`
  - `framework-libs/database/index.md#Modelar schema novo ou dominio novo`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma`, `art56_server_v3/src/lib/tour-video.ts` se existir no backend, senao a regra fica no modulo novo
- palavras-chave ou simbolos de busca: `VenueLink`, `VenueLinkKind`, `instagramUrl`, `relationMode`
- testes provaveis: spec novo da checagem e da lista padrao
- nao ler por padrao: `01-spec.md`, `04-tasks.md`, `security`

### T-02 - Ler e gravar a lista

- objetivo: a API publica devolve so o link tree e o PUT grava a lista e copia as quatro URLs verdes
- cobre requisitos: `R-02`, `R-03`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `GET /venue/presentation/:venueId` como rota publica; helpers de href ja existentes
- prompt recomendado: normal
- estrategia de teste: unitario do use case e do registro da rota
- cenarios obrigatorios:
  - GET sem token devolve nome, logo, cores, slogan e os hrefs visiveis em ordem
  - GET omite oculto, origem vazia, dono, preco e contrato
  - casa inexistente nao devolve outra casa
  - sem linhas, o GET usa a lista padrao
  - PUT com tipo repetido ou URL nao verde responde 400
  - PUT copia site, Instagram, Facebook e TikTok para as colunas mesmo com o olho desligado
  - tipo ausente limpa a coluna correspondente
  - segundo PUT igual nao duplica linha
  - `GET /venue/links/:venueId` nao usa `ensureAuthenticate`; o PUT usa
- definition of done: rotas e use cases no router de venue; testes verdes; DTO publico limitado ao desenho

#### Context Pack

- frente principal: backend
- superficie sensivel: sim
- risco principal: o GET publico devolver campo interno ou aceitar URL invalida na coluna
- repos tocados: `art56_server_v3`
- fora de escopo desta task: tela, sidebar, allowlist do Axios, aplicar migration na `main`
- prova minima desta task: teste do GET sem `ensureAuthenticate` e do PUT com copia das quatro colunas, ambos verdes
- criterio de escalada: parar se a apresentacao ou o rodape precisarem passar a ler a lista
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
  - `framework-libs/patterns/rules/06_senior_engineering_concepts.md`
  - `topics/public-pages-and-branding.md#Riscos`
- caminhos candidatos: `art56_server_v3/src/router/venue.ts`, `use-case-get-venue-presentation.spec.ts`, `to-venue-presentation.ts`
- palavras-chave ou simbolos de busca: `ensureAuthenticate`, `presentation/:venueId`, `instagramUrl`
- testes provaveis: spec do GET e do PUT, no modelo do teste que afirma ausencia de `ensureAuthenticate`
- nao ler por padrao: `01-spec.md`, `04-tasks.md`, formulario de criar espaco

### T-03 - Aba Redes em Configuracoes

- objetivo: o dono monta a lista na aba Redes e o Salvar geral deixa de apagar as quatro colunas
- cobre requisitos: `R-04`, `R-05`, `R-06`, `R-07`, `R-11`
- depende de: `T-02`
- pode rodar em paralelo com: `T-04`
- reusa: `SETTINGS_TABS`, `FormLayout`, arraste nativo das fotos
- prompt recomendado: normal
- estrategia de teste: unitario do mapeamento da aba, da checagem na linha e do payload
- cenarios obrigatorios:
  - as abas renderizam Geral, Endereco, Precos, Redes e Apresentacao
  - Apresentacao nao mostra os quatro campos de URL
  - escolher Instagram abre a URL e tira Instagram do seletor
  - Facebook colado no Instagram fica vermelho e Salvar nao envia
  - `https://` ausente e completado antes da checagem
  - Subir e Descer trocam a posicao; o olho nao remove a linha
  - origem vazia mostra onde preencher e o olho nao liga
  - o payload de Configuracoes nao inclui `url`, `instagramUrl`, `facebookUrl` nem `tiktokUrl`
  - criar espaco continua com os quatro campos
- definition of done: aba ligada ao PUT; `firstInvalidSettingsTab` aponta o erro da URL para Redes; testes verdes

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o salvamento geral enviar os quatro campos vazios e zerar as colunas
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: pagina publica, item da sidebar, `CreateVenueForm` alem de seguir com os quatro campos
- prova minima desta task: teste da aba Redes bloqueando Salvar no aviso vermelho e do payload sem as quatro URLs
- criterio de escalada: parar se o Salvar das outras abas deixar de gravar nome, endereco ou preco
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `framework-libs/design/index.md#Formularios e fluxos de entrada`
- caminhos candidatos: `venue-settings-tabs.ts`, `VenueSettings.tsx`, `CreateVenueForm.tsx`
- palavras-chave ou simbolos de busca: `SETTINGS_FIELD_TAB`, `firstInvalidSettingsTab`, `instagramUrl`, `Salvar Alterações`
- testes provaveis: `venue-settings` da aba e do payload
- nao ler por padrao: `01-spec.md`, `04-tasks.md`, `security`

### T-04 - Pagina publica e item da sidebar

- objetivo: o Link tree abre em outra aba e a pagina sem login mostra a lista
- cobre requisitos: `R-01`, `R-02`, `R-03`
- depende de: `T-02`
- pode rodar em paralelo com: `T-03`
- reusa: casca da apresentacao, `opensExternalUrl`, `publicVenuePresentationShareUrl`
- prompt recomendado: smart
- estrategia de teste: unitario da rota, das duas allowlists e do href da sidebar
- cenarios obrigatorios:
  - `/espaco/:id/links` e `/venue/:id/links` abrem a pagina sem login
  - as duas listas `PUBLIC_ROUTES` incluem os dois caminhos
  - o item Link tree, secao A casa, usa `VIEW_VENUE_SITES` e abre `https://event-hub-dashboard.vercel.app/espaco/{nome}/links` em outra aba
  - a pagina pede o GET publico e mostra so os hrefs recebidos, com logo e cores
  - lista vazia mostra logo e nenhuma linha
  - casa inexistente nao mostra dado de outra casa
- definition of done: pagina, rotas e item entregues; testes verdes; `topics/public-pages-and-branding.md#Demais paginas publicas` ganha a rota do link tree

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim
- risco principal: a pagina pedir token ou ficar fora da allowlist e redirecionar para o login
- repos tocados: `eventhub-vista-dashboard`, `eventhub-docs` no topic
- fora de escopo desta task: editor, schema, mudanca da apresentacao e do rodape
- prova minima desta task: teste do item da sidebar e das allowlists cobrindo `/espaco/AR756/links` sem login
- criterio de escalada: parar se a pagina precisar de campo que o GET publico nao devolve
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Reuso previsto`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `03-design.md#Reuso previsto`
  - `03-design.md#Contratos e dados`
  - `topics/public-pages-and-branding.md#Demais paginas publicas`
  - `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- caminhos candidatos: `App.tsx`, `sidebar-nav-model.ts`, `VenueNav.tsx`, `public-venue-presentation.ts`, `axios.ts`, `useBootstrapUser.ts`, `VenuePresentation.tsx`
- palavras-chave ou simbolos de busca: `PUBLIC_ROUTES`, `opensExternalUrl`, `publicVenuePresentationShareUrl`, `VIEW_VENUE_SITES`
- testes provaveis: spec da sidebar e das allowlists, no modelo de `public-venue-presentation.test.ts`
- nao ler por padrao: `01-spec.md`, `04-tasks.md`, `VenueSettings.tsx`
