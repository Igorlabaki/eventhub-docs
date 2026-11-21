# Solicitacao da Tarefa

## Nome sugerido da tarefa

Link tree do espaco na sidebar, com ordem e selecao do dono

## Resumo da solicitacao

O espaco ganha um item Link tree na sidebar. A pagina publica mostra os links da casa na ordem e na selecao que o dono gravou em Configuracoes, numa aba nova Redes.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — pagina publica nova; pode expor WhatsApp, e-mail e o mapa, que a apresentacao ja mostra, e nao pode levar dono, contrato, pagamento nem dado interno
- risco principal: a pagina publica vazar dado que a apresentacao nao mostra, ou a migracao dos quatro links atuais sumir com Instagram, Facebook, TikTok e site ja gravados
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: formulario de parceiro; formulario de colaborador; links de um orcamento (evento, convidados, indicacoes, programacao, contrato); segunda conta da mesma rede; link com nome livre; rede fora do catalogo; editor na pagina publica; mudar o formulario de criar espaco
- prova minima desta execucao: na sidebar, secao A casa, Link tree abre `https://event-hub-dashboard.vercel.app/espaco/{nome}/links` em outra aba; em Configuracoes, a aba Redes aceita `instagram.com/ar756_` e recusa um Facebook colado no Instagram; `facebook.com/profile.php?id=100085832906065` passa como Facebook; Salvar grava ordem e o que esta ligado; sem login, a pagina mostra so o que esta ligado, nessa ordem; os quatro links ja gravados da AR756 continuam visiveis
- criterio de escalada: a spec e o caminho; a faixa C nao volta para task isolada
- nivel de autonomia: `L2`
- camadas transversais: `design`, `database`, `security`, `patterns`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/database/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: `sidebar-nav-model.ts` secao A casa; `VenueNav.tsx`; `venue-settings-tabs.ts`; `VenueSettings.tsx`; `public-venue-presentation.ts`; `public-venue-rules.ts`; `VenuePresentation.tsx`; `tour-video.ts`; modelo `Venue` e `Organization` no Prisma
- palavras-chave ou simbolos de busca: `opensExternalUrl`, `publicVenuePresentationShareUrl`, `SETTINGS_FIELD_TAB`, `instagramUrl`, `facebookUrl`, `tiktokUrl`, `isTourVideoUrl`, `VIEW_VENUE_SITES`
- testes provaveis: item externo na sidebar; checagem de dominio por tipo, inclusive o `profile.php?id=` da AR756; ordem e visivel gravados no Salvar; pagina publica sem sessao so com o que esta ligado; migracao nao perde os quatro links atuais
- nao ler por padrao: `topics/`; specs de orcamento; formulario de criar espaco alem de saber que os quatro campos continuam la

## Contexto informado na entrada

Pedido em chat. A casa AR756 hoje guarda na aba Apresentacao o site `https://www.ar756.com/`, o Instagram `https://www.instagram.com/ar756_/`, o Facebook `https://www.facebook.com/profile.php?id=100085832906065`, o TikTok `https://www.tiktok.com/@ar756_` e o video do tour `https://www.youtube.com/watch?v=TfdZorJpR1I`. Esses quatro links so conferem se o texto e uma URL. Nao ha lista com posicao nem visivel. A apresentacao publica ja monta WhatsApp, Instagram, Facebook, TikTok, site e o mapa. O mapa nao e uma URL gravada.

Decisoes fechadas na conversa, que a spec nao reabre: aba Redes entre Precos e Apresentacao; site, Instagram, Facebook e TikTok saem de Apresentacao; WhatsApp, e-mail, mapa e video do tour nao sao pedidos de novo; seletor de tipo e depois a URL; aviso verde, ambar e vermelho; arrastar a ordem; escolher o que mostrar; catalogo fechado de automaticos e colados; uma lista com tipo, URL quando houver, visivel e posicao, com migracao dos quatro campos.

## Problema atual

O dono nao tem uma pagina so com os links da casa, nem escolhe a ordem ou o que aparece. Instagram, Facebook, TikTok e site ficam soltos na aba Apresentacao, e um link de uma rede cabe no campo de outra.

## Objetivo da mudanca

Quem recebe o Link tree ve so os links que o dono ligou, na ordem que ele arrastou. Quem esta no painel monta essa lista na aba Redes e abre a pagina pela sidebar.

## Escopo inicial percebido

Item Link tree na sidebar, pagina publica, aba Redes com seletor, checagem, ordem e visivel, e a lista persistida no lugar das quatro colunas. Toca `frontend` e `backend`.

## Itens incluidos neste request

- item Link tree na secao A casa, abrindo a pagina publica em outra aba, para quem ja ve Site
- abas de Configuracoes nesta ordem: Geral, Endereco, Precos, Redes, Apresentacao
- aba Redes com seletor (icone, nome e formato); tipo ja colocado some
- depois da escolha, o campo de URL, com aviso verde, ambar ou vermelho; sem `https://`, o campo completa
- arrastar para ordenar; escolher o que mostrar; oculto fica na lista, no mesmo lugar, e a pagina publica pula
- gravar ordem e visivel no Salvar alteracoes
- catalogo automatico, sem URL colada: Apresentacao, Fazer orcamento, Regras, WhatsApp, E-mail, Google Maps, Video do tour, Site da organizacao
- catalogo colado: Site, Instagram, Facebook, TikTok, YouTube (canal), Google Meu Negocio, Pinterest, LinkedIn, TripAdvisor, Airbnb, Cardapio ou PDF
- migracao de `url`, `instagramUrl`, `facebookUrl` e `tiktokUrl` para a lista, visiveis; Apresentacao, Fazer orcamento e Regras comecam visiveis; tipo novo so entra quando o dono adiciona

## Requisitos implicitos ja visiveis

- Apresentacao fica com video do tour, logo, cores e proprietarios
- WhatsApp e e-mail continuam em Geral; o mapa continua saindo do endereco; o video do tour continua em Apresentacao
- YouTube no seletor e o canal; o video do tour nao entra nele
- link automatico com origem vazia nao aparece na pagina publica, e o editor diz onde preencher
- link vermelho ou ambar nao pode ficar ligado no link tree
- uma ocorrencia por tipo
- a pagina publica reutiliza a casca da apresentacao: logo e cores do espaco, lista vertical, sem bloco a mais
- caminho default `/espaco/{nome}/links`, no mesmo host das outras paginas publicas
- quem ve Site ve o item; nao criar permissao nova
- o formulario de criar espaco continua com os quatro campos; a migracao leva o que ja foi gravado

## Casos de erro e borda ja percebidos

- Instagram com post, reel, story ou explore: aviso ambar, nao liga
- Facebook `profile.php?id=` da AR756: passa
- TikTok de um video (`/video/`): aviso ambar
- site com dominio de Instagram, Facebook ou TikTok: nao passa como site
- YouTube `watch?v=` ou `youtu.be`: aviso de que e um video e de que o tour fica em Apresentacao
- WhatsApp, e-mail, endereco, video do tour ou site da organizacao vazios: a linha explica onde preencher e nao sai na pagina publica
- espaco inexistente: a pagina publica nao mostra dado de outra casa
- casa sem nenhum link ligado: a pagina abre sem lista

## Dependencias

- apresentacao, formulario de orcamento e regras publicas ja existem
- WhatsApp, e-mail, endereco, video do tour e `Organization.url` ja existem
- `Venue.url`, `instagramUrl`, `facebookUrl` e `tiktokUrl` ja estao gravados e sao lidos pela apresentacao publica e pelo rodape do orcamento
- a sidebar ja abre Apresentacao em outra aba com `opensExternalUrl`

## Restricoes e cuidados

- nao reabrir o catalogo, a aba Redes, o arraste, o visivel nem a saida dos quatro links de Apresentacao
- nao incluir formulario de parceiro, formulario de colaborador nem link de um orcamento
- nao criar segunda conta da mesma rede, link com nome livre nem rede fora do catalogo
- nao colocar editor na pagina publica
- nao mudar o formulario de criar espaco nesta entrega
- a rota publica e intencional e entra na allowlist; o pacote nao leva dono, contrato, pagamento nem dado interno
- migration de producao e aditiva e entra na `main` do PlanetScale por deploy request; escrita no banco real exige aprovacao nomeada
- nao ler nem versionar valores de `.env`
- a execucao futura e multi-repo e pode ser derivada com `tasking/task-request-repo-split-prompt.md`

## Notas tecnicas para a spec

Insumo do bootstrap. Nao e plano de implementacao.

Checagem do link colado:

- Instagram: `instagram.com/usuario`. Recusa `/p/`, reel, story, explore e outro dominio
- Facebook: `facebook.com/…` e `profile.php?id=`. O perfil numerico da AR756 tem que passar
- TikTok: `tiktok.com/@usuario`. Recusa `/video/` e outro dominio
- Site: `https://` cujo dominio nao seja Instagram, Facebook nem TikTok
- YouTube: `youtube.com/@canal`, `/channel/`, `/c/` ou `/user/`. `watch?v=` e `youtu.be` avisam que e um video e que o tour fica em Apresentacao
- Google Meu Negocio: `g.page`, `maps.app.goo.gl` ou `google.com/maps`
- Pinterest: `pinterest.com` ou `br.pinterest.com`
- LinkedIn: `linkedin.com/company/…` ou `/in/…`
- TripAdvisor: `tripadvisor.com` ou `tripadvisor.com.br`
- Airbnb: `airbnb.com` ou `airbnb.com.br`
- Cardapio ou PDF: qualquer `https://`

Resolucao dos automaticos na leitura publica: apresentacao, formulario e regras pelos helpers ja existentes; WhatsApp em `wa.me` a partir de `whatsappNumber`; e-mail em `mailto:`; mapa pela busca do endereco, como em `VenuePresentation.tsx`; video do tour por `tourVideoUrl`; site da organizacao por `Organization.url`, e a linha so existe quando esse campo esta preenchido.

A apresentacao publica e o rodape do orcamento leem hoje `instagramUrl`, `facebookUrl`, `tiktokUrl` e `url` direto no venue. A spec diz como esses leitores passam a usar a lista sem perder o link ja gravado.

`firstInvalidSettingsTab` em `venue-settings-tabs.ts` passa a apontar os links colados para a aba Redes.

Cada link e um item com tipo, URL quando for colada, visivel e posicao. `url`, `instagramUrl`, `facebookUrl` e `tiktokUrl` migram para essa lista.

## Perguntas em aberto

- Caminho publico e clique da sidebar. Default: `/espaco/{nome}/links`, secao A casa, outra aba, mesmo mecanismo de Apresentacao. Quem ve Site ve o item.
- Aparencia da pagina publica. Default: lista vertical na casca da apresentacao, com logo e cores do espaco.
- Uma ocorrencia por tipo. Default: sim.
- Quando a ordem e o olho gravam. Default: junto com Salvar alteracoes.
- Criar espaco. Default: o editor novo e so a aba Redes. O formulario de criar espaco segue com os quatro campos; a migracao leva o que ja foi gravado.

## Prioridade sugerida

Media. Cria a peca publica de links da casa. O orcamento e a apresentacao continuam valendo.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: pagina publica nova, editor com arraste e selecao, checagem por tipo e lista persistida com migracao dos quatro links. Toca `frontend` e `backend` e se quebra em mais de uma task.

## Sugestao de slug da spec

- `framework_core/specs/link-tree-do-espaco/`

## Sugestao de nome do arquivo

- `link-tree-do-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-20-link-tree-do-espaco/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
- promocao: usar `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\spec-driven\spec-feature-bootstrap-prompt.md` a partir deste request
- split posterior: `framework_global/framework-base/prompts/tasking/task-request-repo-split-prompt.md`
