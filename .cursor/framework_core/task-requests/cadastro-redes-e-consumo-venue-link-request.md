# Solicitacao da Tarefa

## Nome sugerido da tarefa

Cadastro das redes em Configuracoes e consumo so por venue_link

## Resumo da solicitacao

Configuracoes cadastra a rede e, no mesmo gesto, cria o link, perguntando se ele nasce visivel. O item Link tree da sidebar abre uma tela interna, no molde de Indicar parceiros, so com o que ja foi cadastrado: o clique liga e salva, o outro clique esconde. A pagina publica e as demais telas do espaco leem so `venue_link`. WhatsApp e o video do tour continuam nas colunas de hoje e, ao salvar, criam a propria linha.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — a pagina publica de links ja existe e expoe o WhatsApp do espaco; nao pode levar dono, contrato, pagamento nem dado interno
- risco principal: copiar o que ainda esta nas colunas sem inventar URL vazia, e um salvamento incompleto zerar `url`, `instagramUrl`, `facebookUrl` ou `tiktokUrl` antes da copia
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`), site da Guaeca (`guaeca-house-escapade/`)
- fora de escopo operacional: redes de `Organization` e de `Contact`; redesenho do visual ja entregue da aba Redes e da pagina publica; coluna nova; enum novo; apagar as colunas legadas; mudar Apresentacao, Fazer orcamento, Regras, E-mail, Google Maps e Site da organizacao
- prova minima desta execucao: em Configuracoes, cadastrar um Instagram pergunta se fica visivel e cria o link; o item Link tree da sidebar abre tela interna, lista so o cadastrado, o clique liga e salva e o outro esconde; sem login, `/espaco/AR756/links` mostra so o que esta visivel; salvar o WhatsApp `+55 (11) 983953239` em Geral cria o clique de WhatsApp; salvar o video do tour em Apresentacao cria o link do tour; site, Instagram, Facebook e TikTok que ainda estiverem nas colunas da AR756 voltam pela linha, e coluna vazia nao vira link
- criterio de escalada: a spec e o caminho; a faixa C nao volta para task isolada
- nivel de autonomia: `L2`
- camadas transversais: `design`, `database`, `security`, `patterns`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
  - `.cursor/framework_global/framework-libs/database/index.md`
- caminhos candidatos: `VenueSettings.tsx` aba Redes; `VenueLinkEditor.tsx`; `sidebar-nav-model.ts` item Link tree; `SendSuppliers.tsx`; `proposal-indication-sync.ts`; `VenueLinks.tsx`; `venue-link.ts` (`venueLinkHref`, `venueLinkColumns`, `defaultVenueLinks`); `use-case-venue-links.ts`; `venue-link-in-prisma-repository.ts`; modelo `Venue` e `VenueLink` no Prisma
- palavras-chave ou simbolos de busca: `opensExternalUrl`, `whatsappNumber`, `tourVideoUrl`, `instagramUrl`, `withoutVenueLinkColumns`, `venueLinkColumns`, `createdVenueLinks`, `VIEW_VENUE_SITES`
- testes provaveis: cadastro de URL com a pergunta de visivel; clique da sidebar que liga e esconde e salva sozinho; pagina publica sem sessao so com o visivel; salvar WhatsApp e tour cria a linha; copia do que ainda esta nas colunas sem inventar vazio
- nao ler por padrao: `topics/`; formularios de organizacao e de contato; specs de orcamento

## Contexto informado na entrada

Pedido em chat, corrigindo o recorte das specs `2026-11-21-visual-redes-e-link-tree`, `2026-11-21-criar-link-na-link-tree` e `2026-11-20-link-tree-do-espaco`. O visual dessas entregas fica. O que muda e o papel de cada tela e quem e a fonte do link.

A AR756 tinha site `https://www.ar756.com/`, Instagram `https://www.instagram.com/ar756_/`, Facebook `https://www.facebook.com/profile.php?id=100085832906065`, TikTok `https://www.tiktok.com/@ar756_` e tour `https://www.youtube.com/watch?v=TfdZorJpR1I`, registrados no pedido anterior. A lista nova nao mostrou esses links. O banco de producao nao foi lido neste chat. A migration `20261120233000_add_venue_link` so cria a tabela.

Decisoes fechadas, que a spec nao reabre: Configuracoes cadastra e cria o link junto, e a URL colada pergunta se fica visivel; a sidebar deixa de abrir a pagina publica e passa a ligar e esconder, no molde de Indicar parceiros, so o que ja foi cadastrado; a pagina publica usa so cadastrado e visivel; nao ha coluna nem enum novo; quem mostra rede do espaco le so `venue_link`; as quatro colunas de URL ficam como legado; `whatsappNumber` e `tourVideoUrl` continuam e, ao salvar, criam a linha; organizacao e contato ficam fora.

## Problema atual

A aba Redes cadastra e tambem escolhe o que aparece. O item Link tree da sidebar abre a pagina publica. Salvar Geral ou Apresentacao nao cria linha de WhatsApp nem de tour. As telas do espaco ainda montam Instagram, Facebook, TikTok e site pelas colunas. Um salvamento da lista nova pode gravar essas colunas vazias.

## Objetivo da mudanca

Cadastrar uma rede em Configuracoes cria o link, com a pergunta de visivel na URL colada. O Link tree da sidebar so liga e esconde o que ja foi cadastrado, salvando no clique. WhatsApp e tour nascem ao salvar o numero e o video. Quem mostra rede do espaco le `venue_link`, e o que ainda estiver nas colunas da AR756 volta por essa lista.

## Escopo inicial percebido

Papel da aba Redes, tela interna da sidebar, criacao automatica das linhas de WhatsApp e tour, copia do que ainda esta nas colunas e troca dos leitores do espaco para `venue_link`. Toca `frontend`, `backend` e o site da Guaeca. A execucao futura e multi-repo e pode ser derivada com `tasking/task-request-repo-split-prompt.md`.

## Itens incluidos neste request

- aba Redes continua o cadastro, com filtros, KPIs e o botao de cadastrar; cadastrar cria o link e, na URL colada, pergunta se fica visivel
- item Link tree da sidebar abre tela interna no molde de Indicar parceiros, so com redes ja cadastradas; o clique liga e salva, o outro esconde
- pagina publica `/espaco/{nome}/links` mostra so cadastrado e visivel
- salvar `whatsappNumber` em Geral cria a linha `WHATSAPP`; o clique usa esse numero para falar com o espaco
- salvar `tourVideoUrl` em Apresentacao cria a linha `TOUR_VIDEO`
- o que ainda estiver em `url`, `instagramUrl`, `facebookUrl` e `tiktokUrl` passa a aparecer por `venue_link`
- leitores do espaco listados nas notas passam a ler `venue_link`

## Requisitos implicitos ja visiveis

- uma ocorrencia por tipo, como o unico `venueId` + `kind` ja garante
- Airbnb, Pinterest e as outras redes coladas usam uma linha, nao uma coluna
- WhatsApp e tour nao ganham uma segunda URL: o destino sai de `whatsappNumber` e `tourVideoUrl`
- a rota publica continua intencional e na allowlist
- quem ja ve Site continua vendo o item; nao criar permissao nova
- o visual da lista de Configuracoes e o da pagina publica nao sao redesenhados aqui

## Casos de erro e borda ja percebidos

- coluna legada vazia nao vira link
- salvar a lista sem Instagram, Facebook, TikTok ou site nao pode apagar URL que ainda nao foi copiada para a linha
- numero de WhatsApp ou video do tour vazio: a linha some da lista e da pagina publica
- espaco inexistente nao mostra link de outra casa
- casa sem nada visivel: a pagina publica abre sem lista
- organizacao e parceiro continuam com os campos proprios

## Dependencias

- `venue_link` e o enum `VenueLinkKind` ja existem
- a pagina publica, a aba Redes e os endpoints de links ja existem
- `whatsappNumber` fica em Geral e `tourVideoUrl` fica em Apresentacao
- Indicar parceiros ja liga, esconde e salva no clique
- as specs de link tree e de visual da aba Redes ja estao no BOARD; este request corrige o recorte, nao refaz o visual

## Restricoes e cuidados

- nao reabrir as decisoes fechadas da entrada
- nao criar coluna nem enum
- nao apagar `url`, `instagramUrl`, `facebookUrl` nem `tiktokUrl`
- nao migrar organizacao nem contato para `venue_link`
- nao mudar, nesta entrega, Apresentacao, Fazer orcamento, Regras, E-mail, Google Maps e Site da organizacao
- nao redesenhar a aba Redes nem a pagina publica
- nao inventar URL para a AR756 se a coluna estiver vazia
- a pagina publica nao leva dono, contrato, pagamento nem dado interno
- escrita no banco real exige aprovacao nomeada; nao ha DDL novo
- nao ler nem versionar valores de `.env`
- a execucao futura e multi-repo e pode ser derivada com `tasking/task-request-repo-split-prompt.md`

## Notas tecnicas para a spec

Insumo do bootstrap. Nao e plano de implementacao.

`Venue` guarda `url`, `facebookUrl`, `instagramUrl`, `tiktokUrl`, `whatsappNumber` e `tourVideoUrl`. `VenueLink` guarda `kind`, `url`, `visible` e `position`. `venueLinkHref` ja monta `https://wa.me/{numero}` e usa `tourVideoUrl`. `defaultVenueLinks` montaria a lista a partir das colunas, mas so o teste chama. `createdVenueLinks` so considera linha gravada.

`replace` em `venue-link-in-prisma-repository.ts` apaga as linhas do espaco, recria e grava as quatro colunas. `venueLinkColumns` faz essa copia. Uma lista incompleta zera a coluna.

Salvar Geral tira as quatro URLs do payload com `withoutVenueLinkColumns`. `whatsappNumber` e `tourVideoUrl` seguem nesse salvamento e hoje nao criam linha. `CreateVenueForm.tsx`, `EditVenueForm.tsx` e `MinimumPricesTab.tsx` ainda gravam as colunas. O de precos reenvia as quatro URLs num salvamento que nao e de rede.

A sidebar abre Link tree em `/links` com `opensExternalUrl: true`. A pagina publica e `VenueLinks.tsx` em `/espaco/:id/links` e ja devolve `kind`, `label`, `subtitle` e `href`. O molde do clique e `SendSuppliers.tsx` com `proposal-indication-sync.ts`.

Leitores do espaco a apontar para `venue_link`: `VenuePresentation.tsx`, `ProposalView.tsx`, `ProposalForm.tsx`, `PublicVenueListShell.tsx`, `proposalFooter.tsx`, `EmailTab.tsx`, `VenuesList.tsx`, `guaeca-house-escapade/src/components/layout/Footer.tsx`, `to-venue-presentation.ts`, `to-proposal-presentation.ts`, `getPublicPresentation`, `getWebData`, `getHubData` e `listPermitted` em `venue-in-prisma-repository.ts`, a copia em `proposal-in-prisma-repository.ts`, e os tipos em `types/venue.ts`, `lib/venue-presentation.ts`, `services/proposal.service.ts` e `guaeca-house-escapade/src/types/venue.ts`.

Fora: formularios de `Organization` e o fluxo de contato (`indication-links.ts`, `PartnerPublicCard.tsx`, `PartnerForm.tsx`).

## Perguntas em aberto

- Linha de WhatsApp e de tour ao salvar. Default: nasce desligada e entra na lista da sidebar. A pergunta "visivel no link tree?" fica no cadastro de URL colada.
- Campo de WhatsApp ou tour esvaziado. Default: a linha some da lista e da pagina publica.
- Sidebar reordena. Default: nao. So liga e esconde, como Indicar parceiros. A ordem publica continua a `position` gravada no cadastro.
- Apresentacao, Fazer orcamento, Regras, E-mail, Google Maps e Site da organizacao. Default: nao mudam neste pedido.
- Espelho das quatro colunas no salvamento do link. Default: as telas listadas leem `venue_link`. As colunas ficam. O espelho nao e requisito da v1 e nao pode apagar URL ainda nao copiada para a linha.

## Prioridade sugerida

Media. A lista nova ja escondeu links gravados da AR756, e WhatsApp e tour nao nascem sozinhos.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: troca a fonte dos links do espaco, separa cadastro de visibilidade e cria linha ao salvar WhatsApp e tour. Toca `frontend`, `backend` e o site da Guaeca e se quebra em mais de uma task.

## Sugestao de slug da spec

- `framework_core/specs/2026-11-21-cadastro-redes-e-consumo-venue-link/`

## Sugestao de nome do arquivo

- `cadastro-redes-e-consumo-venue-link-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-21-cadastro-redes-e-consumo-venue-link/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
- promocao: usar `framework_global/framework-base/prompts/spec-driven/spec-feature-bootstrap-prompt.md` a partir deste request
- split posterior: `framework_global/framework-base/prompts/tasking/task-request-repo-split-prompt.md`
- sem `observability`: o salvamento no clique ja existe em Indicar parceiros
