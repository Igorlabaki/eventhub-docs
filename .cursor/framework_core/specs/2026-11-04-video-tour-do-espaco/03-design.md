# Design — Video do tour na proposta publica

## Visao geral da solucao

O venue ganha `tourVideoUrl`. Configuracoes grava esse campo no update que ja existe. A apresentacao publica devolve o campo no pacote que ja existe. A pagina so monta o player quando um resolver reconhece YouTube ou arquivo de video.

## Passada transversal

- architecture: nao. Continua `PUT /venue/update` e `GET /proposal/presentation/:proposalId`. Sem fronteira nova.
- database: sim. Coluna nullable em `venue`, sem indice e sem backfill.
- design: sim. Um campo no formulario e um bloco com dois estados visiveis (arquivo ou YouTube) mais o estado oculto.
- observability: nao. Nao ha servico nem fluxo novo. Sem dashboard e sem alerta.
- security: sim. A apresentacao publica passa a expor um link e o browser pode embarcar midia. A allowlist fica no schema e de novo no resolver. Nao ha rota nova.
- patterns/rules/06: nao. Nao ha retry, fila, cache, concorrencia nem idempotencia alem do save unico.

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: campo em `Venue`
- `art56_server_v3/prisma/migrations/<timestamp>_add_venue_tour_video_url/migration.sql`
- `art56_server_v3/src/zod/venue/update-venue-params-schema.ts`
- `art56_server_v3/src/zod/venue/update-venue-params-schema-db.ts`
- `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts`: `select` de `getPresentation`
- `art56_server_v3/src/repositories/interface/proposal-repository-interface.ts`
- `art56_server_v3/src/functions/to-proposal-presentation.ts`
- `art56_server_v3/src/use-cases/proposal/get-proposal-presentation/use-case-get-proposal-presentation.spec.ts`
- `eventhub-vista-dashboard/src/types/venue.ts`
- `eventhub-vista-dashboard/src/pages/VenueSettings.tsx`
- `eventhub-vista-dashboard/src/services/proposal.service.ts`
- `eventhub-vista-dashboard/src/lib/tour-video.ts` (novo)
- `eventhub-vista-dashboard/src/pages/ProposalView.tsx`

O `update` do repositorio de venue ja espalha `rest` no Prisma. Nao criar use case novo. `getById` devolve a linha do venue; o campo chega no painel sem endpoint novo.

## Reuso previsto

- O mesmo lugar das URLs do espaco em `VenueSettings`.
- O mesmo pacote publico da apresentacao, no mesmo estilo de `instagramUrl`.
- `RevealBlock` e a largura dos cards de `ProposalView`.

## Contratos e dados

Coluna: `tourVideoUrl String? @db.VarChar(2048)` em `Venue`. Nullable. Sem indice. Sem default.

Migration compativel, direta, uma fase: `ALTER TABLE venue ADD COLUMN tourVideoUrl VARCHAR(2048) NULL`. Codigo antigo ignora a coluna. Rollback da coluna so depois do codigo que a le sair. Nao rodar `migrate dev` contra producao.

Schema dos dois arquivos de update do venue:

- `null` ou `""` viram `null`; chave ausente nao zera a coluna, para um save do painel antigo nao apagar o link
- valor aceito permanece string
- valor rejeitado falha o parse

Aceitar somente `https`:

- YouTube: host `youtube.com`, `www.youtube.com`, `m.youtube.com` ou `youtu.be`. Formas: `watch` com `v` de 11 caracteres (`[A-Za-z0-9_-]{11}`), `/shorts/<id>`, `/embed/<id>` ou `youtu.be/<id>`.
- Arquivo: o pathname termina em `.mp4`, `.webm`, `.ogg` ou `.mov`, sem distinguir maiusculas. Query string pode existir.

Rejeitar `http`, usuario na URL (`https://user@host`), `javascript:`, `data:`, Vimeo, Drive, Instagram e pagina sem essas extensoes.

`ProposalPresentation` nos dois repositorios ganha `tourVideoUrl: string | null`. `toProposalPresentation` copia o campo. O `select` de `getPresentation` inclui a coluna. Nenhum outro campo interno entra nesse pacote.

## Campo nas configuracoes

Label visivel: "Video do tour". Placeholder com exemplo `https://`. Texto de ajuda: o video entra mudo na proposta publica; vale YouTube ou arquivo mp4, webm, ogg ou mov.

O campo entra no schema do formulario, nos valores iniciais, no reset quando `selectedVenue` carrega e no objeto de `updateVenue`. Vazio vai como string vazia; o backend grava `null`.

Erro ao lado do campo, no submit: "Use um link do YouTube ou um arquivo de video (mp4, webm, ogg ou mov)." Nao validar a cada tecla. Nao limpar o formulario se o save falhar.

## Player na proposta

Funcao pura `resolveTourVideo(url)` em `src/lib/tour-video.ts`:

- `null` se vazio ou fora da allowlist
- `{ kind: "file", src }` para arquivo
- `{ kind: "youtube", embedUrl }` para YouTube

`embedUrl`: `https://www.youtube.com/embed/<id>?autoplay=1&mute=1&loop=1&playlist=<id>&controls=0&rel=0&modestbranding=1&playsinline=1&disablekb=1`

O iframe nao leva `allowFullScreen`, leva `pointer-events-none` e `tabIndex={-1}`, `title="Tour do espaço"` e `allow="autoplay"`.

O `<video>` leva `autoPlay`, `muted`, `loop`, `playsInline`, `preload="auto"` e nao leva `controls`. `aria-label="Tour do espaço"`.

Os dois ficam num bloco `aspect-video`, largura total, `rounded-xl`, `overflow-hidden`, entre o `RevealBlock` de "Sua experiencia inclui" e o `RevealBlock` de "Seu investimento". O bloco nao olha `serviceList`.

## Falhas, casos de borda e invariantes

- Invariante: player na pagina implica `resolveTourVideo` diferente de `null`.
- Invariante: o banco nao guarda string vazia; guarda `null` ou um valor que o schema aceitou.
- Valor legado irreconhecivel: a pagina omite o bloco (`R-09`), sem quebrar o resto.
- Experiencia ausente nao remove o video (`R-07`).

## Decisoes arquiteturais importantes

- Coluna no `Venue`, nao tabela nova. E um link opcional, como as redes.
- `VarChar(2048)` porque URL de CDN com query passa de `VARCHAR(191)` e nao precisa de `TEXT`.
- Allowlist duplicada no Zod e no resolver. Os repositorios nao compartilham pacote. A lista desta spec e a fonte.
- Player nativo para arquivo, porque so ele fica sem chrome. YouTube usa iframe com controles desligados e clique bloqueado; a marca do YouTube pode permanecer.
- Descartado: upload para o S3. Fora de escopo.
- Descartado: aceitar qualquer `https` num iframe. Abre pagina arbitraria na proposta publica.
- Descartado: video com som. O autoplay nao dispara.

## Riscos e mitigacoes

- Embed aberto. Mitigacao: allowlist nos dois lados e `pointer-events-none` no iframe.
- YouTube ainda mostra marca. Aceito: e o limite do embed, nao um controle nosso.
- `PUT /venue/update` autentica e nao prova dono do venue alem do que a rota ja faz. Aceito nesta feature; D-05 fica de fora.

## Rollout, observabilidade e rollback

- Ordem: migration, backend que grava e le, depois o painel e a pagina. O painel antigo ignora a coluna. A pagina antiga ignora o campo novo do JSON.
- Sem log novo.
- Rollback de codigo: a coluna pode ficar. Rollback da coluna so sem codigo lendo `tourVideoUrl`.

## Estrategia de validacao

- Backend: teste do schema (vazio, YouTube, arquivo com query, pagina, `javascript:`) e o pacote publico copiando `tourVideoUrl` sem ganhar campo interno. `npx prisma validate`.
- Frontend: teste do `resolveTourVideo`. Na pagina, salvar um link, ver o video no lugar, apagar o link e ver o bloco sumir.

## Fontes determinantes

- `topics/data-and-migrations.md#Regras`: migration aditiva e `migrate deploy`
- `framework-libs/database/skills/writing-zero-downtime-migrations.md#1. Classificar a mudanca`: add de coluna nullable e compativel
- `framework-libs/security/skills/reviewing-security-sensitive-changes.md#3. Revisar dados e segredos`: validar input antes de usar na superficie publica
- `framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`: erro no campo, no submit, em linguagem de usuario
- `project/project-decisions.md#D-05`: nao transformar esta feature numa correcao de autorizacao
- codigo: `proposal.ts` deixa `GET /presentation/:proposalId` sem auth; `venue.ts` deixa `PUT /update` com `ensureAuthenticate`; `getPresentation` lista colunas uma a uma
