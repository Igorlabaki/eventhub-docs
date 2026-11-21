# Tasks — Subtitulo, ordem e remocao na pagina de links

## Ordem macro

`T-01` le. `T-02` grava e depende de `T-01`. `T-03` desenha a pagina e depende dos dois. Sem paralelo: os dois primeiros mexem no mesmo use case.

## Tasks

### T-01 - Subtitulo e canReorder na leitura publica

- objetivo: o `GET` publico devolve `subtitle` por tipo e `canReorder` so para quem tem Site naquele espaco
- cobre requisitos: `R-01`, `R-03`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `publicVenueLinks`, `readOptionalUserId`, `canEditVenueSite` da apresentacao
- prompt recomendado: smart
- estrategia de teste: vitest do use case de links e do mapa de subtitulo
- cenarios obrigatorios: cada tipo do mapa tem a frase de `03-design.md#Subtitulos`; link oculto e link sem href ficam de fora; usuario com Site recebe `canReorder: true`; sem usuario e sem Site recebem `false`; o payload nao traz URL de link oculto
- definition of done: testes verdes; `GET` documentado em `project/api-endpoints.md`; nenhum `PUT` novo nesta task

#### Context Pack

- frente principal: backend, leitura publica dos links
- superficie sensivel: sim — o booleano de edicao nao pode ser verdadeiro para visitante
- risco principal: `canReorder` verdadeiro sem Site, ou link oculto no JSON
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: `PUT`, pagina, aba Redes, schema
- prova minima desta task: vitest do use case com Site, sem usuario e com link oculto; o item visivel traz o subtitulo do mapa
- criterio de escalada: parar se a frase pedir coluna ou texto livre
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Subtitulos` e `03-design.md#Leitura publica`
- libs obrigatorias: `node`, `security`
- documentos obrigatorios: `03-design.md#Leitura publica`; `framework-libs/security/references/auth-and-access-control.md#Principios`; `topics/permissions-catalog.md` na linha `venue-site-edit-permission`
- caminhos candidatos: `art56_server_v3/src/functions/venue-link.ts`; `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.ts`; `art56_server_v3/src/use-cases/venue/venue-links/controller-venue-links.ts`; `art56_server_v3/src/use-cases/venue/get-venue-presentation/controller-get-venue-presentation.ts`
- palavras-chave ou simbolos de busca: `publicVenueLinks`, `VENUE_LINK_LABEL`, `readOptionalUserId`, `canEditVenueSite`
- testes provaveis: `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.spec.ts`; `art56_server_v3/src/functions/venue-link.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `database`, frontend

### T-02 - Gravar ordem e ocultar com Site

- objetivo: dois `PUT` autenticados reordenam so os botoes mostrados e ocultam um tipo sem apagar a linha
- cobre requisitos: `R-05`, `R-06`, `R-07`, `R-09`, `R-10`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `replace` e `venueLinkColumns` do repositorio de links; `ensureAuthenticate`
- prompt recomendado: normal
- estrategia de teste: vitest do use case, com permissao falsa de Site
- cenarios obrigatorios: ordem com um oculto no intervalo, como o exemplo de `03-design.md#Gravacao`; ordem igual nao chama `replace`; conjunto diferente responde 400 sem write; hide poe `visible` falso e a linha segue na lista; tipo ja fora da pagina nao grava; sem token 401; sem Site 403; espaco ausente 404
- definition of done: testes verdes; as duas rotas em `project/api-endpoints.md`; o save da aba Redes intacto; sem schema

#### Context Pack

- frente principal: backend, gravacao de ordem e de `visible`
- superficie sensivel: sim — `PUT` novo em recurso de pagina publica
- risco principal: lista parcial apagar link, ou visitante gravar
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo desta task: dialogo, alca, subtitulo visual, lixeira da aba Redes, schema
- prova minima desta task: vitest cobre ordem, hide, 400, 401 e 403 sem chamar `replace` nos casos proibidos
- criterio de escalada: parar se a gravacao precisar do `PUT` da aba Redes ou de coluna nova
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Gravacao`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios: `03-design.md#Gravacao`; `03-design.md#Decisoes arquiteturais importantes`; `framework-libs/security/references/auth-and-access-control.md#Principios`; `framework-libs/patterns/index.md#Aplicar conceito distribuido`
- caminhos candidatos: `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.ts`; `art56_server_v3/src/router/venue.ts`; `art56_server_v3/src/use-cases/venue/reorder-venue-images/use-case-reorder-venue-images.ts`; `art56_server_v3/src/repositories/in-prisma/venue-link-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `ensureAuthenticate`, `canEditVenueSite`, `replace`, `venueLinkColumns`, `visible`
- testes provaveis: `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.spec.ts`; `art56_server_v3/src/use-cases/venue/reorder-venue-images/use-case-edit-venue-images.spec.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `database`, frontend

### T-03 - Subtitulo, arraste e confirmacao na pagina

- objetivo: a pagina mostra o subtitulo e, com `canReorder`, arrasta e pede confirmacao antes de omitir
- cobre requisitos: `R-02`, `R-04`, `R-08`, `R-11`, `R-12`, `R-13`
- depende de: `T-01`, `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: card de `VenueLinksView`; `Dialog`; o cuidado de clique depois do arraste em `usePublicPhotoEdit`
- prompt recomendado: normal
- estrategia de teste: vitest de `VenueLinks`
- cenarios obrigatorios: subtitulo sob o titulo; sem `canReorder` nao ha alca nem Remover; um botao nao tem alca e tem Remover; cancelar nao chama hide; confirmar chama hide e tira o botao; falha devolve o botao; arraste com mais de um botao chama order e nao navega
- definition of done: vitest verde; `topics/public-pages-and-branding.md#Demais paginas publicas` descreve subtitulo, alca e Remover com confirmacao para quem tem Site; a aba Redes sem mudanca

#### Context Pack

- frente principal: frontend, pagina publica de links
- superficie sensivel: sim — os controles so aparecem com `canReorder`; a autorizacao permanece no backend
- risco principal: visitante ver Remover, ou o arraste abrir o href
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: frase no cliente, aba Redes, endpoint, schema
- prova minima desta task: `VenueLinks.test.tsx` cobre subtitulo, ausencia dos controles, cancelar, confirmar e falha
- criterio de escalada: parar se a pagina precisar chamar `saveVenueLinks`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Frontend`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Frontend`; `03-design.md#Falhas, casos de borda e invariantes`; `framework-libs/design/rules/05_component_states_and_variants.md#Estados de componente interativo`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueLinks.tsx`; `eventhub-vista-dashboard/src/pages/VenueLinks.test.tsx`; `eventhub-vista-dashboard/src/services/venue.service.ts`; `eventhub-vista-dashboard/src/components/proposal/public-photo-edit.tsx`
- palavras-chave ou simbolos de busca: `VenueLinksView`, `canReorder`, `link.subtitle`, `ignoreClick`, `Dialog`
- testes provaveis: `eventhub-vista-dashboard/src/pages/VenueLinks.test.tsx`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, backend, aba Redes
