# Solicitacao da Tarefa

## Nome sugerido da tarefa

Criar a rede com URL, linha verde e edicao no lapis

## Resumo da solicitacao

Na aba Redes, a rede so existe depois que a pessoa cria. A linha criada e que esta no link tree fica verde, no mesmo verde de parceiro indicado. A URL nao se edita na tabela: o lapis abre um modal. O select de criar nao oferece a rede que ja existe. Rede vazia nao aparece na lista nem no link tree.

## Context Pack

- frente principal: frontend (`eventhub-vista-dashboard/`), com a mesma regra de "rede criada" no backend (`art56_server_v3/`), porque a lista do painel e a pagina publica leem o mesmo conjunto
- superficie sensivel: nao (a pagina publica de links ja existe; muda quem aparece, sem auth, pagamento ou campo novo)
- camadas transversais: `design`
- risco principal: rede vazia ou semeada pelo padrao continuar na lista ou no link tree; criar a mesma rede duas vezes; gravar URL invalida no lugar de uma URL boa
- repos tocados: `frontend` (`eventhub-vista-dashboard/`); `backend` (`art56_server_v3/`)
- fora de escopo operacional: schema ou coluna nova; tipo novo de rede; redesenhar o card da pagina publica; mexer na tela Indicar parceiros alem de reusar o verde da linha; reabrir o pedido visual que ja esta em revisao
- prova minima desta execucao: na aba Redes, Apresentacao, orcamento, regras e WhatsApp sem criacao nao aparecem na tabela; escolher Instagram, informar um perfil valido e criar coloca a linha verde e tira Instagram do select; um segundo Instagram nao da para criar; o lapis abre o modal e a URL salva muda o que a linha mostra; apagar devolve Instagram ao select; em `/espaco/:id/links` a rede nao criada nao aparece; testes de `venue-link` no front e no back e `npm run build` do front verdes
- criterio de escalada: se distinguir rede semeada de rede criada exigir coluna nova, parar e tratar o schema fora deste recorte; sem coluna, segue nesta spec
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx` (select, linha e URL); `eventhub-vista-dashboard/src/components/proposal/IndicatedPartnersTable.tsx` (linha verde)
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md` no trecho que aponta `topics/public-pages-and-branding.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/lib/venue-link.ts` (`defaultVenueLinks`, `remainingVenueLinkKinds`, `appendVenueLink`, `publicVenueLinks`); `eventhub-vista-dashboard/src/pages/VenueLinks.tsx`; `art56_server_v3/src/functions/venue-link.ts`; `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.ts`
- palavras-chave ou simbolos de busca: `VenueLinkEditor`, `remainingVenueLinkKinds`, `appendVenueLink`, `defaultVenueLinks`, `publicVenueLinks`, `isPastedVenueLink`, `IndicatedPartnersTable`, `bg-emerald-50`
- testes provaveis: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.test.tsx`; `eventhub-vista-dashboard/src/lib/venue-link.test.ts`; `art56_server_v3/src/functions/venue-link.spec.ts`
- nao ler por padrao: `security`, `database`, `patterns`, `observability`, `topics/`

## Contexto informado na entrada

Chat com print da aba Redes e print de Indicar parceiros. O usuario rejeitou a tabela atual: a linha reconhecida continua branca e a URL fica no input da propria linha. Pediu o verde de parceiro indicado, o lapis abrindo modal para a URL, a lista e o link tree sem rede vazia, e o select sem a rede ja criada. A spec [Visual da aba Redes e da pagina publica de links](../specs/2026-11-21-visual-redes-e-link-tree/00-overview.md) segue o fluxo de revisao dela e nao e a origem deste pedido.

## Problema atual

- a lista mostra rede vazia (Apresentacao, Fazer orcamento, Regras, WhatsApp com traco) e o link tree tambem mostra as que o padrao deixa visiveis
- escolher a rede no select ja cria a linha, antes da URL
- a URL se edita no campo da tabela; o texto "link reconhecido" fica verde, a linha nao
- da para perceber a rede na lista mesmo sem a pessoa ter criado

## Objetivo da mudanca

A pessoa cria a rede uma vez, com URL quando a rede pede URL; a linha no link tree fica verde como parceiro indicado; o lapis abre um modal para editar a URL; rede vazia ou ainda nao criada nao aparece na lista nem no link tree, e o select so oferece o que ainda nao existe.

## Escopo inicial percebido

Ajustar a aba Redes e a regra que alimenta a pagina publica: criar vira um passo explicito, a edicao da URL sai da tabela para um modal, a linha no link tree usa o verde de `IndicatedPartnersTable`, e rede nao criada sai da lista e do link tree. A mesma regra vale no front e no back.

## Itens incluidos neste request

- lista e link tree somente com rede criada
- criar: escolher a rede, informar a URL quando for rede de link colado, confirmar
- select sem as redes que ja estao na lista; a mesma rede nao se cria de novo
- linha no link tree verde, no padrao da linha de parceiro indicado
- lapis abre modal para editar a URL
- apagar a rede devolve ela ao select

## Requisitos implicitos ja visiveis

- uma rede por tipo
- o aviso de link invalido, ambiguo ou reconhecido continua existindo, agora no modal de criar e de editar
- KPIs, busca e filtro de visibilidade da aba Redes continuam; a contagem passa a ser das redes criadas
- o card publico (icone, seta, titulo) nao muda
- nao ha pedido de coluna nova

## Casos de erro e borda ja percebidos

- URL invalida ou incompleta na criacao: a rede nao entra na lista e o aviso fica no modal
- URL ambigua (post em vez de perfil): a rede nao entra; o aviso fica no modal
- editar uma URL boa para uma URL invalida: a URL boa permanece
- rede criada e depois oculta: sai do link tree, continua na lista, linha branca, nao volta ao select
- apagar: sai da lista e do link tree e volta ao select
- rede de destino gerado criada sem o dado de origem (WhatsApp sem numero, endereco vazio): entra na lista e fica fora do link tree ate o dado existir
- espaco que ja tem o conjunto padrao salvo: o que nao foi criado pela pessoa deixa de aparecer na lista e no link tree
- select sem nenhuma rede restante: nao da para criar de novo
- arrastar a ordem entre as redes criadas continua

## Dependencias

- a spec `specs/2026-11-21-visual-redes-e-link-tree/` esta em revisao de entrega e desenha a tabela, os KPIs e o card publico; este request muda o que a tabela lista e como a URL entra, e nao substitui aquele card

## Restricoes e cuidados

- nao criar schema, coluna ou tipo novo de rede
- nao reabrir o card da pagina publica nem a faixa de KPIs
- a regra de quem aparece na lista e no link tree precisa valer no front e no back; o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`
- insumo para o bootstrap: editor em `VenueLinkEditor.tsx`; verde em `IndicatedPartnersTable.tsx`; regra em `venue-link.ts` dos dois repos e no use case `use-case-venue-links.ts`

## Perguntas em aberto

1. Redes sem URL colada (Apresentacao, Fazer orcamento, Regras, WhatsApp, e-mail, mapa, video, site da organizacao) tambem se criam pelo select? Premissa: sim. Criar so inclui na lista, sem pedir URL. O lapis de URL so aparece em Site, Instagram, Facebook, TikTok, YouTube, Google Meu Negocio, Pinterest, LinkedIn, TripAdvisor, Airbnb e Cardapio.
2. Quando a linha fica verde? Premissa: verde quando esta no link tree, branca quando foi criada e esta oculta, no mesmo desenho da linha indicada (`bg-emerald-50` e borda esquerda verde).
3. O que fazer com as linhas que o padrao ja gravou vazias? Premissa: somem da lista e do link tree ate a pessoa criar de novo. Sem coluna nova.
4. O olho de mostrar ou ocultar continua? Premissa: sim. Ocultar tira do link tree e deixa a linha na lista. A lixeira remove e devolve a rede ao select.

## Prioridade sugerida

Media. A aba ja lista e o link tree ja abre; o pedido muda quem aparece e como a URL entra.

## Faixa sugerida para task workflow

- `C` — o fluxo de criar, editar e publicar a rede muda nos dois repositorios e se separa em regra do que existe e tela do painel
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: a lista do painel e a pagina publica precisam da mesma definicao de rede criada, e essa definicao esta nos dois repositorios; a tela (select, modal, linha verde) e outra tarefa dentro da mesma spec

## Sugestao de slug da spec

- `framework_core/specs/2026-11-21-criar-rede-do-espaco/`

## Sugestao de nome do arquivo

- `criar-rede-do-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-21-criar-rede-do-espaco/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
