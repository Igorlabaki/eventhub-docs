# Design — Icone da aba do espaco

## Visao geral da solucao

O espaco ganha `faviconUrl`. O formulario manda esse arquivo no campo `favicon`, no mesmo save do logo. A URL publica vai para o S3 no mesmo formato do logo. As telas que ja trocam o titulo apontam o `<link rel="icon">` para essa URL e, ao sair, devolvem `/favicon.ico`.

## Passada transversal

- architecture: nao. Continuam `POST /venue/create` e `PUT /venue/update`; nao ha fronteira nova nem ADR.
- database: sim. Coluna nula em `venue`, sem indice e sem copia. A migration nao entra na `main` sem aprovacao nomeada.
- design: sim. Um campo a mais, copiando o logo: label, arquivo, previa e uma frase de ajuda.
- observability: nao. Nao nasce servico, metrica nem alerta. A prova e teste e o `href` da aba.
- security: sim. Upload autenticado de imagem e URL publica no mesmo tipo de `logoUrl`. Nao e storage privado e nao abre rota.
- patterns/rules/06: nao. Nao ha fila, retry, cache nem webhook. A unica ordem e subir o objeto novo antes de apagar o antigo.

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: `faviconUrl String?` ao lado de `logoUrl`
- migration aditiva no estilo de `prisma/migrations/20261119180000_add_venue_slogan`, so com `ADD COLUMN`, sem `UPDATE`
- `art56_server_v3/src/router/venue.ts`: `upload.fields([{ name: "file", maxCount: 1 }, { name: "favicon", maxCount: 1 }])` no create e no update
- `controller-create-venue.ts` e `controller-update-venue.ts`
- selects de `getPublicPresentation` e de `proposal.getPresentation`
- `to-venue-presentation.ts` e `to-proposal-presentation.ts`
- `eventhub-vista-dashboard/src/services/venue.service.ts`: `faviconFile` sai do loop e entra como `favicon`
- `VenueSettings.tsx`, `CreateVenueForm.tsx`, `venue-settings-tabs.ts`, `types/venue.ts`
- helper novo ao lado de `venue-tab-title.ts`, chamado nos cinco `useEffect` que ja definem `document.title`
- `project/api-endpoints.md`: o create e o update passam a aceitar `file` e `favicon`
- `product/08-data-model.md` e `topics/public-pages-and-branding.md#Marca do espaco`: uma linha para `faviconUrl`

## Reuso previsto

- a URL continua `https://{bucket}.s3.{region}.amazonaws.com/{key}`, com `PutObjectCommand` e `ContentType` do arquivo
- a previa copia `handleLogoChange`: objeto local, clique abre, valor inicial e o que ja esta gravado
- o titulo continua em `venueTabTitle`; o icone e outra funcao
- `GET /venue/getById` nao ganha `select`; o campo novo volta com os demais do espaco. Painel, formulario e `usePublicListVenue` leem dai

## Contratos e dados

- coluna: `faviconUrl String?`, sem `@db` extra e sem indice, igual a `logoUrl`
- multipart: logo em `file`, icone em `favicon`
- o schema do corpo (`update-venue-params-schema-db.ts` e `create-venue-request-schema.ts`) nao aceita `faviconUrl`; Zod ja descarta chave desconhecida
- o schema que persiste (`create-venue-db-schema.ts` e o schema de update que o use case grava) aceita `faviconUrl` opcional, preenchido so pelo controller depois do upload
- `Venue`, `VenuePresentation` e `ProposalPresentation` ganham `faviconUrl: string | null`
- `getPublicPresentation` e `proposal.getPresentation` incluem `faviconUrl: true` no `select` do espaco
- o helper puro devolve a URL aparada, ou `/favicon.ico` se vier vazia ou so com espaco
- o efeito cria `<link rel="icon">` quando o head nao tem, grava o `href` e, no cleanup, grava `/favicon.ico`

## Falhas, casos de borda e invariantes

- `files.file[0]` segue o caminho atual do logo; `files.favicon[0]` so mexe em `faviconUrl`
- tipo do icone precisa comecar com `image/`; senao a resposta e erro, sem `PutObject` e sem mudar a coluna
- ordem do icone: `PutObject`, gravar `faviconUrl`, e so entao `DeleteObject` da chave anterior, tirada do ultimo segmento da URL, como o logo ja faz
- se o `PutObject` ou o save falha, a chave antiga nao e apagada
- campo ausente nao entra no `data` do update, entao o Prisma nao zera a coluna
- o controller nao repassa `faviconUrl` vindo do corpo
- o delete-first do logo permanece; esta spec nao troca essa ordem
- duas casas em sequencia: o cleanup da primeira volta `/favicon.ico` e o efeito da segunda aplica o icone dela, ou de novo `/favicon.ico` se ela nao tiver

## Decisoes arquiteturais importantes

- o nome e `faviconUrl` porque o pedido e o icone da aba e o par de `logoUrl` ja e uma URL publica. `iconUrl` foi descartado: e generico demais ao lado de foto, logo e amenidade
- o campo do multipart e `favicon`, e no frontend `faviconFile`, no par de `logoFile` / `file`
- storage privado foi descartado: o pedido repete a URL publica do logo, e a lib de upload privado mudaria o logo inteiro
- um helper puro mais a chamada nas cinco telas foi escolhido em vez de um `<Helmet>` ou de copiar o DOM cinco vezes. O Vitest do dashboard e `environment: "node"`, entao a prova do `href` e a funcao pura; a presenca da chamada se prova lendo o fonte, como `venue-presentation.test.ts` ja faz com `venueTabTitle`
- nao ha limite de tamanho nesta v1

## Riscos e mitigacoes

- o segundo arquivo substituir o logo: testes com so um campo e com os dois
- a aba ficar com o icone da casa anterior: cleanup sempre grava `/favicon.ico`, e espaco sem URL tambem
- objeto orfao se o save falhar depois do `PutObject`: aceito; apagar antes do save perderia o icone, e o pedido proibe isso
- SVG grande ou hostil: aceito nesta v1, igual ao `accept="image/*"`

## Rollout, observabilidade e rollback

- a coluna nula nao muda casa antiga
- frontend antigo ignora `faviconUrl`; backend antigo faz a aba cair em `/favicon.ico`
- rollback de codigo: parar de ler o campo; a coluna pode ficar
- rollback de schema, se precisar, e um `DROP COLUMN` aditivo ao contrario, fora desta spec e so com aprovacao nomeada
- sem log novo. O `console.log` do update do logo nao se copia para o icone

## Estrategia de validacao

- `npx prisma validate` e leitura da migration
- unitario do controller com S3 mockado: dois arquivos, so icone, so logo, tipo invalido, falha no `PutObject`
- unitario dos dois `to*Presentation` com `faviconUrl` presente e nulo
- markup dos dois formularios: label, `accept`, texto de ajuda
- unitario de `venueTabIconHref` e busca da chamada nas cinco telas
- browser da aba fica para o review da entrega; esta spec nao exige login de producao

## Docs que fecham a solucao

- `topics/data-and-migrations.md#Regras`: coluna aditiva, deploy request so com aprovacao nomeada
- `topics/public-pages-and-branding.md#Marca do espaco`: o icone entra na marca, ao lado de `logoUrl`, nas telas que ja usam `venueTabTitle`
- `product/08-data-model.md#Models por area`: `Venue` passa a listar `faviconUrl`
- `framework-libs/database/skills/writing-zero-downtime-migrations.md`: so adicionar coluna nula
- `framework-libs/security/index.md` secao de upload: o arquivo e autenticado no create/update; a URL e publica como o logo, nao como storage privado
- `project/api-endpoints.md`: `POST /venue/create` e `PUT /venue/update` deixam de ser um unico `single("file")`
