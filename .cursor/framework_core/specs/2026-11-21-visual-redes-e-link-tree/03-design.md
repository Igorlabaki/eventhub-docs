# Design

## Visao geral da solucao

Dois desenhos no front, o mesmo recurso. A aba Redes de Configuracoes troca o cartao por faixa, tres KPIs, contador e tabela. A pagina publica troca a pilula pelo card ja usado em "Gerencie seu evento". Nada muda no `GET` nem no `PUT` de links.

Passada transversal:

- muda topologia, fronteira ou fluxo entre partes? nao — so UI no dashboard
- toca dados persistidos? nao — `kind`, `url`, `visible` e `position` ja sao o corpo do save
- toca interface? sim — faixa, KPIs, tabela com arraste e card publico
- vai para producao? nao como servico novo — sem log, metrica ou alerta
- toca fluxo sensivel? nao — a rota publica ja existe e o payload nao ganha dado
- gatilho de conceito senior (`patterns/rules/06`)? nao — sem fila, retry, cache ou idempotencia nova

## Componentes e modulos impactados

- `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx`: passa a renderizar a faixa, os KPIs, o contador e a tabela. Continua dono de `rows` e `onChange`.
- `eventhub-vista-dashboard/src/pages/VenueSettings.tsx`: a aba `redes` segue so montando o editor. Sem campo novo no formulario.
- `eventhub-vista-dashboard/src/pages/VenueLinks.tsx`: `VenueLinksView` troca o `<a class="rounded-full justify-center">` pelo card.
- `eventhub-vista-dashboard/src/pages/VenueLinks.test.tsx`: o teste que exige fundo `#f7f7f5` e texto `#111111` passa a exigir o inverso do card.

## Reuso previsto

- Faixa: o bloco `rounded-3xl border bg-white` de `VenueContacts.tsx` (busca com lupa e select em pilula). O select Escolher rede usa esse formato e continua com `value=""` e `onChange` chamando `addKind`.
- KPIs: o grid de `contact-list-summary.tsx` (icone, rotulo, numero). Nao generalizar o componente de contatos; repetir o markup no editor para nao alterar Total / Com logo / Com descricao.
- Tabela: `Table` de `contact-list.tsx` (`bg-white rounded-md shadow-lg`). Colunas: alca, Nome, Link, Acoes.
- Card publico: `cardClass` de `ProposalEventLink.tsx` e `cardStyle` de `PublicVenueListShell.tsx` (fundo `proposalSecondaryColor` ou `#ffffff`, texto `proposalTextColor` ou `#181818`). Icone via `LinkGlyph`. Seta `ArrowUpRight` absoluta em `right-4 top-4`. Titulo `mt-6 block text-[16px] font-semibold`. Sem o `<span>` de descricao.
- Ordem: `moveVenueLink` e o `onDrop` que ja regrava `position`.

Descartado: extrair um componente compartilhado de KPI ou de card nesta feature. O visual se repete; o dominio nao.

## Contratos e dados

- Save atual, sem mudanca: `{ kind, url, visible, position }`.
- Leitura publica, sem mudanca: `{ kind, label, href }` so dos visiveis, na ordem.
- KPI Total = `rows.length`.
- KPI No link tree = linhas com `visible`.
- KPI Com link = linhas com `url` preenchida depois do trim.
- Busca: nome (`label`) contem o texto, sem acento obrigatorio. Filtro Todas mostra tudo; No link tree so `visible`; Ocultas so `!visible`.
- Contador: quantidade de linhas depois da busca e do filtro, texto `N redes`.
- `addKind` permanece: nova linha no fim, `visible: false`, `url: null`, `position` = tamanho anterior.

## Falhas, casos de borda e invariantes

- A ordem persistida e a de `rows`, nao a da tabela filtrada.
- Com busca preenchida ou filtro diferente de Todas, `draggable` fica desligado. A alca continua visivel.
- Soltar a linha no mesmo indice nao duplica.
- Rede fixa nao renderiza lixeira. Rede colada renderiza.
- Olho desligado quando `canShowVenueLink` impede mostrar, como o botao faz hoje.
- Filtro sem resultado: tabela sem linhas e uma frase de vazio. KPIs intactos.
- Pagina publica sem links: nao renderiza a lista. Sem logo: marca EventHub. Slogan vazio ou so espaco: sem paragrafo.
- `mailto` sem `target`. Os outros links com `target="_blank"` e `rel="noopener noreferrer"`.

## Decisoes arquiteturais importantes

- Os KPIs nao seguem a regra generica de "numero com comparacao" de `design/rules/07`. O usuario fechou o desenho de Contatos, que e rotulo mais numero. Filtro nao vai para a URL pelo mesmo motivo: Contatos nao faz isso.
- Arraste desligado no recorte filtrado. Reordenar um subconjunto mudaria `position` das linhas escondidas sem o usuario ver.
- O card publico nao usa `buttonStyle` invertido. Usa o `cardStyle` do evento, para a cor bater com orcamento e regras.
- Uma coluna. O grid `sm:grid-cols-2` do evento nao entra; a pagina de links ja e `max-w-md`.

## Riscos e mitigacoes

- `VenueLinks.test.tsx` ainda descreve a pilula. `T-02` atualiza o teste junto com a view, senao o verde atual trava o visual velho.
- `topics/public-pages-and-branding.md` ainda diz que o link publico e uma pilula. `T-02` troca essa frase. Nao atualizar o topic antes do codigo.

## Rollout, observabilidade e rollback

- Sem flag e sem telemetria.
- Rollback: reverter o commit do front. Nao ha migration.

## Estrategia de validacao

- `T-01`: teste do editor para busca, filtro, KPIs estaveis, arraste bloqueado no recorte, arraste livre reordenando, lixeira so na rede colada e ausencia de Subir/Descer.
- `T-02`: `VenueLinks.test.tsx` passa a ver `rounded-xl`, seta, titulos e as cores do card (fundo da secundaria, texto da cor de texto). Mantem logo, slogan, EventHub sem logo, lista vazia, `mailto` e `target="_blank"`.
- `npm test` e `npm run build` no `eventhub-vista-dashboard`.

## Fontes

- `topics/public-pages-and-branding.md#Marca do espaco` e `#Demais paginas publicas`
- `framework-libs/design/index.md#Tabelas, listas e dashboards` e `rules/07_data_display_and_dashboards.md#Tabelas e listas`
- codigo ja lido: `VenueLinkEditor.tsx`, `VenueLinks.tsx`, `ProposalEventLink.tsx`, `PublicVenueListShell.tsx`, `VenueContacts.tsx`, `contact-list.tsx`, `contact-list-summary.tsx`
