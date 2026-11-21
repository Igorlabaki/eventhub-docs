# Solicitacao da Tarefa

## Nome sugerido da tarefa

Visual da aba Redes e da pagina publica de links no padrao de Contatos e dos cards do evento

## Resumo da solicitacao

A aba Redes em Configuracoes lista cada rede num cartao com Subir, Descer, Remover e "No link tree". A pagina publica `/espaco/:id/links` mostra pilulas com icone e texto centralizados. A aba passa a ter filtros, KPIs, contador e tabela no desenho de Contatos, com o icone de arrastar como unica acao a mais. A pagina publica passa a usar o card de "Gerencie seu evento", com os titulos comecando no mesmo ponto.

## Context Pack

- frente principal: frontend (`eventhub-vista-dashboard/`); aba Redes do painel e pagina publica de links do mesmo recurso
- superficie sensivel: nao (pagina publica ja existe; mudanca visual, sem endpoint, auth ou dado novo)
- camadas transversais: `design`
- risco principal: o arraste, o select que adiciona a rede, a URL e o aviso de link invalido ja funcionam; o redesenho nao pode perde-los nem reabrir o request antigo das pilulas claras
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: schema, endpoint ou campo novo; botao no estilo "Link para cadastro de parceiro"; reaproveitar `task-requests/visual-pagina-links-espaco-request.md` (aquele objetivo era a pilula clara e ja esta em revisao); copiar o dominio de contato para dentro do editor de redes
- prova minima desta execucao: na aba Redes, a faixa tem busca e "Escolher rede" (escolher acrescenta a linha), tres KPIs, contador e tabela; arrastar Instagram para cima de WhatsApp troca a ordem e nao existem botoes Subir e Descer; em `/espaco/AR756/links`, cada link e um card com icone no canto superior esquerdo, seta no canto superior direito e titulo embaixo, todos os titulos no mesmo alinhamento; `npm test` e `npm run build` do front verdes
- criterio de escalada: promover para `spec` se a execucao for separar as duas telas em tasks; permanece neste request enquanto for um objetivo so, no front, sem contrato novo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx` (select, arraste, visibilidade e URL); `eventhub-vista-dashboard/src/pages/VenueLinks.tsx` em `VenueLinksView`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md` no trecho que aponta `topics/public-pages-and-branding.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueSettings.tsx` (aba `redes`); `eventhub-vista-dashboard/src/pages/VenueContacts.tsx` (faixa de filtros); `eventhub-vista-dashboard/src/components/contact/contact-list-summary.tsx`; `eventhub-vista-dashboard/src/components/contact/contact-list.tsx`; `eventhub-vista-dashboard/src/pages/ProposalEventLink.tsx` (`cardClass`); `eventhub-vista-dashboard/src/components/proposal/PublicVenueListShell.tsx` (`cardStyle`); `eventhub-vista-dashboard/src/services/venue.service.ts` (payload publico `{ kind, label, href }`)
- palavras-chave ou simbolos de busca: `VenueLinkEditor`, `addKind`, `moveVenueLink`, `isPastedVenueLink`, `checkVenueLinkUrl`, `GripVertical`, `VenueLinksView`, `LinkGlyph`, `cardClass`, `cardStyle`
- testes provaveis: `eventhub-vista-dashboard/src/pages/VenueLinks.test.tsx`; o que ja cobrir o editor de links
- nao ler por padrao: `security`, `database`, `patterns`, `observability`, backend, `topics/`

## Contexto informado na entrada

Chat com prints. O usuario rejeitou o cartao da aba Redes e pediu o desenho de Contatos (filtros, KPIs e o resto), mantendo o select que ja adiciona a rede e somando so o icone de arrastar. Na pagina publica, pediu o container de "Gerencie seu evento": icone, seta e titulo alinhado. Nao reabrir `visual-pagina-links-espaco-request.md`.

## Problema atual

- cada rede da aba Redes e um cartao com Subir, Descer, Remover e o texto "No link tree"
- a pagina publica centraliza icone e texto juntos na pilula, entao cada titulo comeca num ponto diferente
- a pilula usa a cor de texto como fundo; o card do evento usa fundo `proposalSecondaryColor` e texto `proposalTextColor`

## Objetivo da mudanca

Na aba Redes, escolher uma rede acrescenta a linha numa tabela com filtros, KPIs e contador no padrao de Contatos, e arrastar o icone troca a ordem, sem Subir e Descer; na pagina publica, cada link e o card de "Gerencie seu evento", com os titulos comecando no mesmo lugar.

## Escopo inicial percebido

Redesenhar `VenueLinkEditor` na aba `redes` de `VenueSettings.tsx` com a faixa, os cards e a tabela de Contatos, preservando `addKind`, o arraste que grava `position`, a URL e o aviso. Em `VenueLinksView`, trocar a pilula `rounded-full` pelo `cardClass` de `ProposalEventLink.tsx` e pelo `cardStyle` de `PublicVenueListShell.tsx`.

## Itens incluidos neste request

- faixa, tres KPIs, contador e tabela na aba Redes, no visual de Contatos
- select "Escolher rede" na faixa, continuando a adicionar a linha na hora
- icone de arrastar para reordenar; Subir e Descer fora
- pagina publica com card: icone no canto superior esquerdo, seta no canto superior direito, titulo embaixo, titulos alinhados
- as duas telas no mesmo request; nao separar

## Requisitos implicitos ja visiveis

- KPIs e filtros calculados no cliente a partir das linhas do editor; nao ha pedido de API de resumo
- redes fixas continuam sem remocao; Remover hoje so existe quando `isPastedVenueLink`
- o card publico nao inventa descricao: o payload e `{ kind, label, href }`
- icones por `kind` ja estao em `LinkGlyph`
- reaproveitar o visual de Contatos e o `cardClass` sem copiar dominio de contato nem de orcamento

## Casos de erro e borda ja percebidos

- busca ou filtro de visibilidade sem resultado: tabela vazia, KPIs ainda sobre as linhas reais
- rede oculta: continua na tabela do painel e sai da pagina publica
- URL invalida: o aviso de `checkVenueLinkUrl` permanece na linha
- lista publica vazia: a pagina nao abre uma lista vazia, como hoje
- arrastar para a mesma posicao nao duplica nem perde a linha

## Dependencias

- nenhuma spec aberta. O request `visual-pagina-links-espaco-request.md` segue o fluxo de revisao dele e nao e a origem deste.

## Restricoes e cuidados

- nao criar schema, endpoint ou campo
- preservar `addKind`, `moveVenueLink`, `onDrop`, `isPastedVenueLink`, `canShowVenueLink` e `checkVenueLinkUrl`
- nao ler nem alterar o request da pilula clara para cumprir este
- a lib `patterns` nao entra: o reuso e de componente visual, coberto por `react` e `design`
- insumo para o bootstrap, se promover: editor em `VenueLinkEditor.tsx`; encaixe em `VenueSettings.tsx` aba `redes`; faixa de `VenueContacts.tsx`; cards de `contact-list-summary.tsx`; tabela de `contact-list.tsx`; card publico de `ProposalEventLink.tsx` e `PublicVenueListShell.tsx`; payload em `venue.service.ts`

## Perguntas em aberto

1. Quais sao os tres KPIs? Premissa: Total (todas as linhas), No link tree (`visible`) e Com link (URL preenchida), no visual de `ContactListSummaryCards`.
2. Quais filtros alem da busca por nome? Premissa: busca pelo nome e visibilidade Todas / No link tree / Ocultas. Escolher rede fica na mesma faixa e so adiciona. Sem botao novo de copiar link.
3. Quais acoes na linha alem do arraste? Premissa: olho para mostrar ou ocultar, e lixeira so nas redes coladas. As duas como icone. URL e aviso de link invalido continuam na linha.
4. O card publico leva a linha de descricao do card do evento? Premissa: nao. So icone, seta e titulo.
5. A lista publica fica em uma coluna ou em duas? Premissa: uma coluna, embaixo da logo e do slogan, na largura `max-w-md` atual, com `cardClass` e `cardStyle`.

## Prioridade sugerida

Media. As duas telas funcionam; o pedido e de visual.

## Faixa sugerida para task workflow

- `B` — duas telas de um mesmo recurso, so no front, decisoes fechadas e padrao visual ja existente; sem contrato novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o mesmo recurso aparece na aba Redes e na pagina publica; se a execucao separar as telas, o recorte vira spec em vez de dois requests soltos

## Sugestao de slug da spec

- `framework_core/specs/2026-11-21-visual-redes-e-link-tree/`

## Sugestao de nome do arquivo

- `visual-redes-e-link-tree-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-21-visual-redes-e-link-tree/`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
