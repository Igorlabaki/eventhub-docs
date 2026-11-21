# Design — Subtitulo, ordem e remocao na pagina de links

## Visao geral da solucao

O subtitulo nasce ao lado do rotulo, no mapa do backend, e sai no `GET` publico. A pagina nao inventa frase. Quem tem Site ve alca e Remover. A gravacao e dois `PUT` autenticados, so de ordem e de `visible`. O save da aba Redes nao e chamado pela pagina.

## Passada transversal

- architecture: nao. Mesma pagina e a mesma tabela `venue_link`. Sem ADR.
- database: nao. Sem coluna. Ordem e `visible` ja existem.
- design: sim. Subtitulo sob o titulo. Alca, Remover, dialogo e botao desabilitado enquanto grava, nos estados das fotos.
- observability: nao. Sem servico novo. A prova e o status HTTP. Nao logar href, WhatsApp nem e-mail.
- security: sim. `GET` publico com usuario opcional. `PUT` autenticado e autorizado com `EDIT_VENUE_SITE` no espaco da URL.
- patterns/rules/06: sim, so concorrencia leve. A ultima gravacao vence. Ordem igual ou tipo ja fora da pagina nao gravam de novo. Sem fila e sem lock.

## Subtitulos

Mapa `VENUE_LINK_SUBTITLE` em `art56_server_v3/src/functions/venue-link.ts`, ao lado de `VENUE_LINK_LABEL`. `publicVenueLinks` acrescenta `subtitle`. Nao duplicar o mapa no frontend. A pagina so renderiza `link.subtitle`.

| Tipo | Subtitulo |
|---|---|
| PRESENTATION | Conheça o espaço |
| BUDGET_FORM | Peça um orçamento |
| RULES | Veja as regras |
| WHATSAPP | Fale pelo WhatsApp |
| EMAIL | Envie um e-mail |
| GOOGLE_MAPS | Veja no mapa |
| TOUR_VIDEO | Assista ao tour |
| ORGANIZATION_SITE | Abra o site |
| SITE | Abra o site |
| INSTAGRAM | Abra o Instagram |
| FACEBOOK | Abra o Facebook |
| TIKTOK | Abra o TikTok |
| YOUTUBE | Abra o canal |
| GOOGLE_BUSINESS | Veja no Google |
| PINTEREST | Abra o Pinterest |
| LINKEDIN | Abra o LinkedIn |
| TRIPADVISOR | Veja no TripAdvisor |
| AIRBNB | Veja no Airbnb |
| MENU | Abra o cardápio |

## Leitura publica

`GET /venue/links/:venueId` continua publico. O controller passa `readOptionalUserId`. `canReorder` e `canEditVenueSite(userId, record.id)` quando ha usuario; senao `false`. A permissao usa o id da linha, nao o nome da URL.

O objeto publico ganha `canReorder` na raiz. Cada item continua `kind`, `label`, `href` e ganha `subtitle`. Link oculto ou sem href continua de fora. Nao devolver a lista do editor.

## Gravacao

Dois `PUT` novos, os dois com `ensureAuthenticate` e fora de allowlist publica:

- `PUT /venue/links/:venueId/order` com `{ kinds: VenueLinkKind[] }`
- `PUT /venue/links/:venueId/hide` com `{ kind: VenueLinkKind }`

Autorizacao: `canEditVenueSite`. Respostas: 401 sem token, 403 sem Site, 404 espaco ausente, 400 corpo invalido, 200 quando gravou ou quando nada mudou.

O conjunto mostrado e o de `publicVenueLinks` (visivel e com href). `kinds` tem de ser exatamente esse conjunto, sem repeticao. Caso contrario 400 e o repositorio nao e chamado.

Reordenar: na lista completa ja ordenada, os intervalos cujo tipo esta no conjunto mostrado recebem `kinds` na ordem pedida. As outras linhas ficam no lugar. Exemplo: Apresentacao visivel, Instagram oculto, Regras, WhatsApp. O corpo `[PRESENTATION, WHATSAPP, RULES]` produz Apresentacao, Instagram oculto, WhatsApp, Regras. Renumerar `position` de zero. Ordem igual a atual: 200 sem `replace`.

Ocultar: o tipo tem de estar no conjunto mostrado. So `visible` passa a falso. A linha, a URL e a posicao ficam. Tipo ausente da lista ou sem href: 400. Tipo que ja nao aparece: 200 sem `replace`.

Os dois chamam o `replace` ja existente, com as linhas ajustadas e `venueLinkColumns` dessas linhas, para as quatro colunas nao divergirem. Nao criar outro write.

O 200 devolve o mesmo `data` do `GET`, com `canReorder: true`.

## Frontend

`PublicVenueLinks` ganha `canReorder` e `links[].subtitle`. `VenueLinks` desenha o subtitulo sob o titulo, menor e com opacidade. Sem subtitulo, a linha nao aparece.

`canReorder` e mais de um botao: alca no cartao e o cartao arrasta. Um botao: sem alca. `canReorder`: botao Remover em cada cartao, com `aria-label` `Remover {titulo}`. O clique do Remover nao abre o href e nao inicia arraste. Depois de um arraste, o clique que sobraria nao abre o destino. O clique de quem visita abre.

O dialogo usa o `Dialog` ja existente. Titulo: "Tem certeza que quer remover?". Texto: "{titulo} deixa de aparecer nesta página." Acoes: Cancelar e Remover. Enquanto grava, alca e Remover ficam desabilitados. Falha de rede restaura a lista anterior. Sucesso troca a lista pela resposta.

`venue.service` ganha a chamada dos dois `PUT`, no `venueId` da rota. Nao chama `saveVenueLinks`.

## Falhas, casos de borda e invariantes

- Sem sessao ou sem Site: `canReorder` falso e nenhum `PUT` grava.
- A pagina nao envia URL, tipo novo nem lista parcial.
- Link oculto nao entra no `GET` para ser escondido no cliente.
- Falha de rede no cliente restaura a lista. O servidor, se chegou a gravar, ja respondeu 200.

## Decisoes arquiteturais importantes

- Subtitulo no mapa do backend, nao em coluna. Alternativa descartada: texto livre em `VenueLink`, que pedia migration e editor.
- `PUT` so de ordem e so de ocultar, com `EDIT_VENUE_SITE`. Alternativa descartada: a pagina chamar o save da aba Redes, que troca a lista inteira e autoriza `EDIT_VENUE_INFO`.
- Ocultar, nao apagar. Alternativa descartada: repetir a lixeira do link colado, que tira a linha.
- Alca e Remover condicionados a `canReorder`, o mesmo booleano das fotos. Alternativa descartada: qualquer usuario logado.

## Riscos e mitigacoes

- Visitante reordenar. Mitigacao: `ensureAuthenticate`, `canEditVenueSite` e teste 401 e 403.
- Lista parcial apagar link. Mitigacao: o corpo tem de ser o conjunto mostrado; senão 400 sem `replace`.
- `PUT` publico por engano. Mitigacao: `ensureAuthenticate` na rota, fora de allowlist.

## Rollout, observabilidade e rollback

Sem flag e sem migration. O `GET` novo e compativel: campo a mais nao quebra a pagina atual. Rollback e reverter o deploy. Ordem e `visible` ja gravados pelo usuario permanecem, que e o efeito pedido. Nao ha dado novo para migrar de volta.

## Estrategia de validacao

Vitest no backend: subtitulo por tipo, `canReorder` verdadeiro e falso, ordem com oculto no intervalo, ordem igual sem write, ordem invalida 400, hide sem apagar a linha, 401 e 403. Vitest no frontend: subtitulo, ausencia de alca e Remover, um botao sem alca, cancelar, confirmar, falha restaura, arraste nao segue o link. `npm test -- --run` no spec de links; `npm test` em `VenueLinks.test.tsx`. Browser, se a sessao de Site estiver disponivel: arrastar, confirmar e cancelar; sem sessao, ausencia dos controles.

## Contrato a documentar

`project/api-endpoints.md`: linha do `GET /venue/links/:venueId` (publica, usuario opcional, `canReorder` so com Site) e as duas linhas de `PUT`. `topics/public-pages-and-branding.md#Demais paginas publicas`: o bullet de `/espaco/{casa}/links` ganha subtitulo, alca e Remover com confirmacao para quem tem Site.

## Fontes

- `topics/public-pages-and-branding.md#Demais paginas publicas`
- `topics/permissions-catalog.md` na linha `venue-site-edit-permission`
- `project/api-endpoints.md` nas linhas da apresentacao
- `framework-libs/security/references/auth-and-access-control.md#Principios`
- `framework-libs/patterns/index.md#Aplicar conceito distribuido`
- `framework-libs/design/index.md#Criar ou evoluir componente`
- `specs/2026-11-20-editar-fotos-orcamento-e-apresentacao/03-design.md#Apresentacao do espaco`
