# Design — Criar a rede do espaco

## Visao geral da solucao

Rede criada e uma linha que a leitura aceita. Link colado entra quando `checkVenueLinkUrl` e verde. Destino gerado entra quando `url` e o marcador `created`. Lista vazia nao recebe mais `defaultVenueLinks`. A aba so desenha essas linhas: select para criar, modal para a URL, linha verde quando esta no link tree.

## Rede criada

Constante `CREATED_VENUE_LINK_MARK = "created"` nas duas copias de `venue-link.ts`.

`createdVenueLinks(rows)` mantem:

- link colado cuja URL tem status verde
- destino gerado com `url === "created"`

Descarta o resto. Nao descarta todo destino gerado: a Apresentacao criada tambem teria `url` null no formato antigo.

`rowsOf` passa a devolver `createdVenueLinks(record.links)` e deixa de chamar `defaultVenueLinks`. `editorVenueLinks` tambem deixa de trocar lista vazia pelo padrao.

`createVenueLink(rows, kind, url, name, source)`:

- tipo ja presente: devolve as mesmas linhas
- link colado: so acrescenta se o status for verde, com `url` no `href` do check e `visible: true`
- destino gerado: acrescenta com `url: "created"` e `visible` verdadeiro so quando `venueLinkHref` tem destino

`replaceVenueLinkUrl(rows, kind, url)` so troca se o tipo for link colado e o status for verde. Senao devolve as mesmas linhas.

`remainingVenueLinkKinds` passa a listar todo `VENUE_LINK_KINDS` que ainda nao esta nas linhas, nao so os colados.

`venueLinkSummary.withLink` conta URL verde de link colado. O marcador nao conta.

## O que a leitura e a gravacao fazem

`GET` publico, `GET` editor, ordem e ocultar leem so `createdVenueLinks`. O corpo publico continua `{ kind, label, href, subtitle }`.

`normalize` no save:

- link colado verde grava o `href`
- link colado sem URL verde nao entra no conjunto; se a linha veio com texto, o use case responde 400 com a mensagem do check
- destino gerado presente no corpo grava `url: "created"`

`replace` continua apagando as linhas do espaco e gravando o conjunto enviado. A linha legada some da tabela nesse `replace`, nao num script. Ate la, a leitura ja nao a mostra.

Ordem e ocultar operam sobre as linhas criadas. Ocultar so poe `visible: false`. O marcador fica, entao a rede nao volta para o select.

`venueLinkColumns` ignora o marcador. So site, Instagram, Facebook e TikTok com URL verde atualizam as colunas do espaco.

## Tela da aba Redes

`VenueLinkEditor` recebe so linhas criadas.

- select "Escolher rede" lista `remainingVenueLinkKinds`. Escolher link colado abre o modal e nao acrescenta a linha. Escolher destino gerado chama `createVenueLink` na hora.
- sem tipo restante, o select fica sem opcao alem do placeholder.
- modal reusa `Dialog`. Campos: URL, a mensagem ao vivo de `checkVenueLinkUrl`, Cancelar e Criar ou Salvar. O botao de confirmar fica desabilitado enquanto o status nao for verde. Cancelar nao altera a lista. A mensagem ao vivo permanece porque ja e o reconhecimento do link, nao um erro novo de formulario.
- a coluna Link mostra a URL do link colado, ou "—" no destino gerado. Sem input na linha. O marcador nao aparece.
- lapis (`Pencil`), so no link colado, abre o mesmo modal para `replaceVenueLinkUrl`.
- olho e lixeira ficam. A lixeira usa `removeVenueLink`.
- linha no link tree: `border-l-4 border-l-emerald-500 bg-emerald-50`, o mesmo par de `IndicatedPartnersTable`. Linha oculta, ou visivel sem destino: `border-l-transparent`, fundo branco.
- zero redes criadas, sem busca: "Nenhuma rede criada". Busca ou filtro sem resultado: "Nenhuma rede encontrada".
- arraste continua quando a busca esta vazia e a visibilidade e Todas.
- o estado muda na hora na aba e so vai para a API no salvamento que `VenueSettings` ja faz com `saveVenueLinks`.

## Alternativas descartadas

- coluna `created`: o request veda schema, e a coluna `url` ja distingue o legado (`null`) da criacao (marcador)
- filtrar todo destino gerado em toda leitura: a Apresentacao criada teria o mesmo formato do padrao e sumiria de novo
- `DELETE` unico em producao: a leitura filtrada ja corrige o link tree sem escrita; o `replace` seguinte limpa a tabela

## Passada transversal

- architecture: nao. Mesmas rotas e o mesmo corpo; nao ha fronteira nova.
- database: nao. Nenhuma migration. `url` ja existe e passa a guardar o marcador no destino gerado.
- design: sim. Modal, linha verde, select e estado vazio.
- observability: nao. Sem servico novo. URL recusada continua 400.
- security: nao. Token, `EDIT_VENUE_INFO`, `EDIT_VENUE_SITE` e o `GET` publico ficam como estao.
- patterns: nao. Sem fila, retry ou idempotencia nova. O save segue a troca do conjunto.

## Componentes e modulos impactados

- `art56_server_v3/src/functions/venue-link.ts`
- `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.ts`
- `eventhub-vista-dashboard/src/lib/venue-link.ts`
- `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx`
- `topics/public-pages-and-branding.md#Demais paginas publicas`
- `project/api-endpoints.md` na linha do `GET /venue/links/:venueId`

## Reuso previsto

- `checkVenueLinkUrl`, `venueLinkHref`, `canShowVenueLink`, `removeVenueLink`, `reorderVenueLinks`
- `Dialog` ja usado na pagina publica de links
- classes da linha indicada em `IndicatedPartnersTable`
- `saveVenueLinks` e o `PUT` atual

## Contratos e dados

Nenhum campo novo no JSON nem no Prisma. `url` de destino gerado criado vale `created`. Link colado guarda o `href` verde. `visible` e `position` seguem o significado atual.

## Falhas, casos de borda e invariantes

- marcador nao e endereco e nao entra em `venueLinkColumns` nem na coluna Link
- destino gerado sem href (WhatsApp sem numero, mapa sem endereco) grava `visible: false`; o olho nao liga enquanto `canShowVenueLink` for falso
- tipo duplicado no corpo continua 400
- duas copias da funcao precisam do mesmo marcador e do mesmo filtro
- pagina de Configuracoes aberta antes do deploy pode salvar a lista antiga e marcar todo destino gerado como criado; `T-01` e `T-02` saem juntos

## Riscos e mitigacoes

- o link tree de quem usava o padrao perde Apresentacao, orcamento e regras ate criar de novo. E a premissa aceita. Link colado verde nao se perde.
- esquecer o filtro numa leitura mostra o legado de novo. O use case centraliza isso em `rowsOf`.

## Rollout, observabilidade e rollback

Sem migration e sem escrita em massa. Reverter o filtro volta a mostrar as linhas que ainda nao passaram por `replace`. Nao ha metrica nova.

## Estrategia de validacao

Vitest da funcao nos dois repos e do use case, com fixture de lista vazia, legado e gravacao do marcador. Vitest do editor para select, modal, verde, lapis e lixeira. `npm run build` do front na task de tela.

## Fontes que fecharam a solucao

- `topics/public-pages-and-branding.md#Demais paginas publicas`: o link tree mostra so o que o dono ligou, na ordem gravada
- `framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`: confirmar fica desabilitado ate a URL verde; o texto ja reconhecido continua ao vivo
- `framework-libs/design/rules/07_data_display_and_dashboards.md#Tabelas e listas`: a coluna Link mostra o dado, a edicao vai para o modal
- `framework-libs/node/index.md#Implementacao backend Node`: a mudanca fica na funcao e no use case, sem endpoint novo
- `active-libs.md`: Express e Prisma 5; nenhuma migration
