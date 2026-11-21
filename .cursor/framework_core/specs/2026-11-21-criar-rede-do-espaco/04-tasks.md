# Tasks — Criar a rede do espaco

## Ordem macro

`T-02` depende de `T-01`. As duas saem no mesmo ciclo: a tela antiga, se salvar depois so de `T-01`, gravaria o marcador em todo destino gerado que ainda estivesse na lista.

## Tasks

### T-01 - Leitura e gravacao so com rede criada

- objetivo: lista vazia e linha legada sem URL verde ficam fora do editor e do link tree; destino gerado criado grava o marcador e continua na leitura seguinte.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-08`, `R-10`, `R-11`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `checkVenueLinkUrl`, `venueLinkHref`, `publicVenueLinks`, `replace`
- prompt recomendado: normal
- estrategia de teste: vitest de `venue-link` no front e no back, e do use case de links
- cenarios obrigatorios:
  - `venue_link` vazio: `GET` publico e editor devolvem lista vazia, sem Apresentacao
  - legado com Apresentacao `url` null e Instagram verde: a leitura traz so Instagram
  - gravar Apresentacao e ler de novo: a linha volta com `url` `created` e entra no link tree
  - gravar WhatsApp sem numero: a linha volta com `visible` falso e nao entra no link tree
  - Instagram com post, ou URL vazia: 400 e o conjunto anterior intacto
  - segundo Instagram no corpo: 400
  - `GET` publico sem token continua 200; editor sem permissao continua 403
- definition of done:
  - `rowsOf` e `editorVenueLinks` nao chamam `defaultVenueLinks`
  - `normalize` grava `created` no destino gerado e nao zera essa url
  - as duas copias de `venue-link.ts` tem o mesmo marcador, `createdVenueLinks`, `createVenueLink` e `replaceVenueLinkUrl`
  - `topics/public-pages-and-branding.md#Demais paginas publicas` diz que a rede so aparece depois de criada, e o padrao nao liga mais Apresentacao, orcamento e regras
  - a linha do `GET /venue/links/:venueId` em `project/api-endpoints.md` diz que rede nao criada nao entra
  - vitest dos arquivos tocados verde
  - nenhuma migration e nenhum campo alem de `kind`, `url`, `visible`, `position`

#### Context Pack

- frente principal: backend, com a mesma funcao no front
- superficie sensivel: nao
- risco principal: filtrar todo destino gerado e apagar a Apresentacao criada, ou perder Instagram que ja tem URL verde
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: modal, linha verde, lapis e o select da tela
- prova minima desta task: fixture vazio devolve `links: []`; legado so devolve o Instagram verde; gravar Apresentacao e ler de novo devolve essa linha no link tree
- criterio de escalada: parar se distinguir semente de criacao exigir coluna nova
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Rede criada`
- libs obrigatorias: `node`
- documentos obrigatorios:
  - `03-design.md#Rede criada`
  - `03-design.md#O que a leitura e a gravacao fazem`
  - `framework-libs/node/index.md#Implementacao backend Node`
  - `topics/public-pages-and-branding.md#Demais paginas publicas`
- caminhos candidatos: `art56_server_v3/src/functions/venue-link.ts`; `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.ts` (`rowsOf`, `normalize`); `eventhub-vista-dashboard/src/lib/venue-link.ts`
- palavras-chave ou simbolos de busca: `defaultVenueLinks`, `rowsOf`, `normalize`, `createdVenueLinks`, `CREATED_VENUE_LINK_MARK`
- testes provaveis: `art56_server_v3/src/functions/venue-link.spec.ts`; `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.spec.ts`; `eventhub-vista-dashboard/src/lib/venue-link.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, `database`, `VenueLinkEditor.tsx`

### T-02 - Select, modal, linha verde e lapis

- objetivo: a pessoa cria pelo select, edita a URL no lapis e ve verde a linha que esta no link tree.
- cobre requisitos: `R-04`, `R-05`, `R-06`, `R-07`, `R-08`, `R-09`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `createVenueLink`, `replaceVenueLinkUrl`, `remainingVenueLinkKinds`, `Dialog`, classes de `IndicatedPartnersTable`
- prompt recomendado: normal
- estrategia de teste: vitest do `VenueLinkEditor` com markup; `npm run build` do front
- cenarios obrigatorios:
  - lista so com Instagram: Apresentacao nao esta na tabela e esta no select; Instagram nao esta no select
  - escolher Instagram e confirmar perfil verde acrescenta a linha com `bg-emerald-50` e tira Instagram do select; post ou URL vazia nao acrescenta
  - escolher Apresentacao acrescenta a linha sem modal
  - lapis abre o modal; confirmar URL verde troca o texto da linha; confirmar URL nao verde deixa a URL anterior
  - olho tira o verde e deixa a linha; lixeira tira a linha e devolve o tipo ao select
  - WhatsApp sem destino entra branco, sem ir para um href
  - nenhuma rede criada mostra "Nenhuma rede criada"
- definition of done:
  - a coluna Link nao tem `input`
  - o marcador `created` nao aparece na tabela
  - `withLink` nao conta o marcador
  - vitest do editor verde e `npm run build` do front verde
  - o card em `VenueLinks.tsx` nao muda

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o select acrescentar a linha antes da URL, ou pintar de verde linha oculta
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: use case, schema, card publico
- prova minima desta task: o markup do editor mostra a linha verde so com `visible`, o modal no lapis, e o select sem o tipo ja criado
- criterio de escalada: parar se a tela precisar de endpoint ou campo que `T-01` nao gravou
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Tela da aba Redes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Tela da aba Redes`
  - `03-design.md#Rede criada`
  - `framework-libs/design/rules/06_forms_and_input_ux.md#Validacao`
  - `framework-libs/design/rules/07_data_display_and_dashboards.md#Tabelas e listas`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx`; `eventhub-vista-dashboard/src/components/proposal/IndicatedPartnersTable.tsx`; `eventhub-vista-dashboard/src/components/ui/dialog.tsx`
- palavras-chave ou simbolos de busca: `remainingVenueLinkKinds`, `createVenueLink`, `replaceVenueLinkUrl`, `bg-emerald-50`, `Dialog`
- testes provaveis: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.test.tsx`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, `database`, use case de links
