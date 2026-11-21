# Tasks

## Ordem macro

1. `T-01` cria a coluna. Nada mais depende do banco antes disso.
2. `T-02` grava o arquivo. Depende de `T-01`.
3. `T-03` devolve `faviconUrl` nas apresentacoes publicas. Depende de `T-01` e pode correr com `T-02`.
4. `T-04` coloca o campo nos dois formularios. Depende de `T-02` para o save valer.
5. `T-05` troca o icone da aba. Depende de `T-03` para a proposta e a apresentacao; o painel e as listas leem `getById`, que ja devolve a coluna depois de `T-01`.

## Tasks

### T-01 - Coluna faviconUrl

- objetivo: `Venue` passa a ter `faviconUrl` opcional, nulo nas casas atuais
- cobre requisitos: `R-01`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: a migration `20261119180000_add_venue_slogan`, sem o `UPDATE`
- prompt recomendado: smart
- estrategia de teste: `npx prisma validate` e leitura do SQL
- cenarios obrigatorios: a coluna e anulavel; a migration so tem `ADD COLUMN`; nao ha `UPDATE` nem `DROP`
- definition of done: schema e migration no repositorio; `product/08-data-model.md#Models por area` cita `faviconUrl`; a `main` do PlanetScale nao foi alterada

#### Context Pack

- frente principal: banco
- superficie sensivel: sim — coluna em `venue`; aplicar na `main` exige aprovacao nomeada
- risco principal: migration com copia ou escrita, ou DDL direto na `main`
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: upload, formularios, aba do navegador, deploy request
- prova minima desta task: `npx prisma validate` aceita `faviconUrl String?` em `Venue`; o SQL so adiciona a coluna nula
- criterio de escalada: parar se a mudanca pedir indice, backfill ou apply na `main`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`, `node`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `topics/data-and-migrations.md#Regras`, `project/planetscale.md#Fluxo real de schema`, `framework-libs/database/skills/writing-zero-downtime-migrations.md`
- caminhos candidatos: `art56_server_v3/prisma/schema.prisma`; `art56_server_v3/prisma/migrations/20261119180000_add_venue_slogan/migration.sql`; `product/08-data-model.md`
- palavras-chave ou simbolos de busca: `logoUrl`, `faviconUrl`, `ADD COLUMN`
- testes provaveis: `npx prisma validate`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`

### T-02 - Upload do icone no create e no update

- objetivo: o arquivo `favicon` grava `faviconUrl` sem mexer no logo, e um envio falho nao apaga o icone anterior
- cobre requisitos: `R-03`, `R-04`, `R-05`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: `PutObjectCommand` e a chave publica do logo em `controller-update-venue.ts`
- prompt recomendado: normal
- estrategia de teste: unitario dos controllers com o client S3 mockado
- cenarios obrigatorios: logo e icone no mesmo request geram URLs diferentes; so o icone nao muda `logoUrl`; so o logo nao muda `faviconUrl`; tipo fora de `image/` nao chama `PutObject`; falha no `PutObject` nao chama `DeleteObject`; string `faviconUrl` no corpo nao grava
- definition of done: create e update usam `upload.fields`; `project/api-endpoints.md` descreve `file` e `favicon` nas duas rotas; vitest desses cenarios verde

#### Context Pack

- frente principal: upload do espaco
- superficie sensivel: sim — arquivo autenticado para o S3 e URL publica
- risco principal: gravar o icone em `logoUrl`, ou apagar o objeto antigo antes do save
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: formulario, aba do navegador, storage privado, limite de tamanho, mudar a ordem delete-first do logo
- prova minima desta task: vitest com S3 mockado cobre os seis cenarios obrigatorios
- criterio de escalada: parar se o icone precisar de bucket, ACL ou rota nova
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Falhas, casos de borda e invariantes`
- libs obrigatorias: `node`, `aws`, `security`
- documentos obrigatorios: `03-design.md#Falhas, casos de borda e invariantes`, `03-design.md#Contratos e dados`, `framework-libs/security/index.md#Upload, arquivos ou storage privado`
- caminhos candidatos: `art56_server_v3/src/router/venue.ts`; `controller-create-venue.ts`; `controller-update-venue.ts`; `create-venue-request-schema.ts`; `create-venue-db-schema.ts`; `update-venue-params-schema-db.ts`; `project/api-endpoints.md`
- palavras-chave ou simbolos de busca: `upload.single`, `req.file`, `logoUrl`, `favicon`, `PutObjectCommand`, `DeleteObjectCommand`
- testes provaveis: spec novo ao lado dos controllers, com `s3Client` mockado
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, skill de upload privado da lib `aws`

### T-03 - faviconUrl nas apresentacoes publicas

- objetivo: a apresentacao do espaco e a do orcamento devolvem `faviconUrl`
- cobre requisitos: `R-06`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: o par `logoUrl` em `to-venue-presentation.ts` e `to-proposal-presentation.ts`
- prompt recomendado: smart
- estrategia de teste: unitario dos dois mapeamentos e do select, no spec que ja lista `logoUrl`
- cenarios obrigatorios: URL preenchida sai no payload; `null` sai `null`; `logoUrl` continua no mesmo lugar
- definition of done: os dois `select` e os dois mapeamentos incluem o campo; vitest existente desses specs verde

#### Context Pack

- frente principal: contrato publico do espaco
- superficie sensivel: nao — campo a mais numa resposta que ja expoe `logoUrl`; sem rota nova
- risco principal: esquecer um dos dois `select` e a aba publica ficar sem URL
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: upload, formulario, DOM da aba, `getById`
- prova minima desta task: os specs de `get-venue-presentation` e `get-proposal-presentation` esperam `faviconUrl` e passam
- criterio de escalada: parar se a URL tiver de ser assinada ou escondida
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `topics/public-pages-and-branding.md#Marca do espaco`
- caminhos candidatos: `to-venue-presentation.ts`; `to-proposal-presentation.ts`; `getPublicPresentation` em `venue-in-prisma-repository.ts`; `getPresentation` em `proposal-in-prisma-repository.ts`; os dois `*.spec.ts` desses use cases
- palavras-chave ou simbolos de busca: `logoUrl`, `faviconUrl`, `getPublicPresentation`, `getPresentation`
- testes provaveis: `use-case-get-venue-presentation.spec.ts`; `use-case-get-proposal-presentation.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`

### T-04 - Campo Icone da aba nos formularios

- objetivo: a pessoa escolhe o icone ao lado do logo na configuracao e na criacao do espaco
- cobre requisitos: `R-02`
- depende de: `T-02`
- pode rodar em paralelo com: `T-05`
- reusa: `handleLogoChange` e o bloco Logo do Espaco
- prompt recomendado: normal
- estrategia de teste: markup dos dois formularios e o FormData do service
- cenarios obrigatorios: os dois formularios mostram o label, `accept="image/*"` e a frase do icone quadrado; `faviconFile` vai no campo `favicon` e nao no campo `file`; salvar sem arquivo nao manda `favicon`
- definition of done: `venue-settings-tabs.ts` manda `faviconFile` para `apresentacao`; vitest desses cenarios verde

#### Context Pack

- frente principal: formulario do espaco
- superficie sensivel: nao
- risco principal: o arquivo do icone ir no campo `file` e substituir o logo
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: trocar o `href` da aba, recorte, botao de remover
- prova minima desta task: vitest ve o campo nos dois formularios e o `favicon` separado de `file` no service
- criterio de escalada: parar se o campo precisar de outra aba ou de um editor de imagem
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Reuso previsto`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Reuso previsto`, `framework-libs/design/rules/06_forms_and_input_ux.md`
- caminhos candidatos: `VenueSettings.tsx`; `CreateVenueForm.tsx`; `venue.service.ts`; `venue-settings-tabs.ts`; `types/venue.ts`
- palavras-chave ou simbolos de busca: `logoFile`, `logoPreview`, `handleLogoChange`, `Logo do Espaco`, `apresentacao`
- testes provaveis: teste de markup no estilo de `venue-presentation.test.ts`; teste do FormData se o service ja tiver spec, senao um spec curto do append
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`

### T-05 - Icone na aba das cinco telas

- objetivo: a aba usa `faviconUrl` onde o titulo ja usa o nome do espaco, e volta `/favicon.ico` ao sair
- cobre requisitos: `R-07`, `R-08`, `R-09`, `R-11`
- depende de: `T-03`
- pode rodar em paralelo com: `T-04`
- reusa: os `useEffect` de `document.title` e o teste que le o fonte em `venue-presentation.test.ts`
- prompt recomendado: normal
- estrategia de teste: funcao pura do `href` e presenca da chamada nas cinco telas
- cenarios obrigatorios: URL preenchida vira o `href`; `null`, vazio e so espaco viram `/favicon.ico`; as cinco telas chamam o helper no mesmo efeito do titulo; nenhuma delas cria `apple-touch-icon` nem manifest
- definition of done: helper ao lado de `venue-tab-title.ts`; `topics/public-pages-and-branding.md#Marca do espaco` cita `faviconUrl`; vitest verde

#### Context Pack

- frente principal: aba do navegador
- superficie sensivel: nao
- risco principal: a aba ficar com o icone da casa anterior depois da navegacao
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: upload, formularios, apple-touch-icon, manifest, mudar o texto da aba
- prova minima desta task: vitest de `venueTabIconHref` e o fonte das cinco telas chamando o helper
- criterio de escalada: parar se o icone tiver de entrar em pagina que hoje nao troca `document.title`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `03-design.md#Decisoes arquiteturais importantes`, `topics/public-pages-and-branding.md#Marca do espaco`
- caminhos candidatos: `venue-tab-title.ts`; `ProposalView.tsx`; `VenuePresentation.tsx`; `PublicVenueListShell.tsx`; `VenueDashboard.tsx`; `ProposalForm.tsx`; `venue-presentation.test.ts`
- palavras-chave ou simbolos de busca: `document.title`, `venueTabTitle`, `EVENTHUB_TAB_TITLE`, `favicon.ico`, `rel="icon"`
- testes provaveis: spec do helper; `venue-presentation.test.ts` ou um spec irmao que le o fonte das cinco telas
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`
