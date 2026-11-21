# Tasks

## Ordem macro

`T-01` e `T-02` nao dependem uma da outra. A recomendada para comecar e `T-01`.

## Tasks

### T-01 - Aba Redes no desenho de Contatos

- objetivo: a aba Redes mostra faixa, KPIs, contador e tabela, com arraste so na lista inteira e sem Subir/Descer
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-06`, `R-07`, `R-08`, `R-09`, `R-10`
- depende de: nenhuma
- pode rodar em paralelo com: `T-02`
- reusa: faixa de `VenueContacts.tsx`, markup de KPI de `contact-list-summary.tsx`, `Table` de `contact-list.tsx`, `addKind` e `moveVenueLink`
- prompt recomendado: normal
- estrategia de teste: vitest no editor, com `renderToStaticMarkup` ou testing-library se o arraste precisar de evento
- cenarios obrigatorios:
  - escolher uma rede ainda ausente acrescenta uma linha e o select volta a "Selecione"
  - KPIs Total, No link tree e Com link nao mudam ao buscar ou filtrar
  - o contador acompanha o recorte
  - busca e filtro Ocultas nao renderizam as outras linhas
  - com filtro, a linha nao e `draggable`
  - com lista inteira, soltar uma linha acima de outra regrava `position`
  - nao existe botao Subir nem Descer
  - lixeira so na rede colada; olho alterna `visible`; URL invalida mostra o aviso
- definition of done:
  - `VenueLinkEditor` implementa `03-design.md#Contratos e dados` e `#Falhas, casos de borda e invariantes`
  - a aba `redes` de `VenueSettings` continua so montando o editor
  - teste novo cobre os cenarios acima
  - `npm test` do front verde no arquivo novo e em `venue-link.test.ts`

#### Context Pack

- frente principal: editor de links no painel
- superficie sensivel: nao
- risco principal: arrastar com a lista filtrada mudaria a ordem das linhas escondidas
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: `VenueLinks.tsx`, payload, topic
- prova minima desta task: o teste do editor mostra KPIs estaveis no filtro, arraste desligado no recorte, arraste livre reordenando, e o markup sem Subir e Descer
- criterio de escalada: sobe se for preciso endpoint de resumo ou gravar a ordem fora do `onChange` atual
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `framework_core/specs/2026-11-21-visual-redes-e-link-tree/03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `framework_core/specs/2026-11-21-visual-redes-e-link-tree/03-design.md#Reuso previsto`
  - `framework_core/specs/2026-11-21-visual-redes-e-link-tree/03-design.md#Falhas, casos de borda e invariantes`
  - `framework_global/framework-libs/design/rules/07_data_display_and_dashboards.md#Tabelas e listas`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx`; `eventhub-vista-dashboard/src/pages/VenueContacts.tsx`; `eventhub-vista-dashboard/src/components/contact/contact-list-summary.tsx`; `eventhub-vista-dashboard/src/components/contact/contact-list.tsx`; `eventhub-vista-dashboard/src/lib/venue-link.ts`
- palavras-chave ou simbolos de busca: `addKind`, `moveVenueLink`, `isPastedVenueLink`, `canShowVenueLink`, `checkVenueLinkUrl`, `GripVertical`
- testes provaveis: `eventhub-vista-dashboard/src/lib/venue-link.test.ts`; teste novo ao lado de `VenueLinkEditor.tsx`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, `database`, `VenueLinks.tsx`

### T-02 - Card publico no estilo do evento

- objetivo: cada link publico vira o card de "Gerencie seu evento", com os titulos no mesmo ponto e a cor do card
- cobre requisitos: `R-11`, `R-12`, `R-13`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01`
- reusa: `cardClass` de `ProposalEventLink.tsx`, `cardStyle` de `PublicVenueListShell.tsx`, `LinkGlyph`
- prompt recomendado: smart
- estrategia de teste: atualizar `VenueLinks.test.tsx`, que hoje exige a cor invertida da pilula
- cenarios obrigatorios:
  - logo, slogan e ausencia do nome no topo continuam
  - cada link e um card `rounded-xl` com seta, icone e titulo, sem descricao
  - o titulo nao usa `justify-center` junto do icone
  - fundo do card e a cor secundaria e a letra e a cor de texto
  - `mailto` sem `target`; os outros com `target="_blank"`
  - sem logo usa EventHub; sem links nao abre lista; slogan so com espaco nao aparece
- definition of done:
  - `VenueLinksView` segue `03-design.md#Reuso previsto` no card publico
  - `VenueLinks.test.tsx` cobre os cenarios acima e nao exige mais a cor invertida
  - a frase da pilula em `topics/public-pages-and-branding.md#Demais paginas publicas` passa a descrever o card
  - `npm test` do arquivo e `npm run build` do front verdes

#### Context Pack

- frente principal: pagina publica de links
- superficie sensivel: nao
- risco principal: o teste atual congela a pilula de cor invertida
- repos tocados: `frontend` (`eventhub-vista-dashboard/`); topic em `eventhub-docs`
- fora de escopo desta task: aba Redes, save, payload
- prova minima desta task: `VenueLinks.test.tsx` ve card com fundo da secundaria, texto da cor de texto, seta e titulos, e o topic nao chama mais o link de pilula
- criterio de escalada: sobe se o card precisar de campo de descricao no `GET`
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `framework_core/specs/2026-11-21-visual-redes-e-link-tree/03-design.md#Reuso previsto`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `framework_core/specs/2026-11-21-visual-redes-e-link-tree/03-design.md#Decisoes arquiteturais importantes`
  - `framework_core/topics/public-pages-and-branding.md#Demais paginas publicas`
  - `framework_core/topics/public-pages-and-branding.md#Marca do espaco`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueLinks.tsx`; `eventhub-vista-dashboard/src/pages/VenueLinks.test.tsx`; `eventhub-vista-dashboard/src/pages/ProposalEventLink.tsx`; `eventhub-vista-dashboard/src/components/proposal/PublicVenueListShell.tsx`
- palavras-chave ou simbolos de busca: `VenueLinksView`, `LinkGlyph`, `cardClass`, `cardStyle`, `rounded-full`, `justify-center`
- testes provaveis: `eventhub-vista-dashboard/src/pages/VenueLinks.test.tsx`
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, `database`, `VenueLinkEditor.tsx`
