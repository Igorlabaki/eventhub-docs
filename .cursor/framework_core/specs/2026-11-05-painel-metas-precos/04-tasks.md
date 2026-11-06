# Tasks — Painel de metas e precos

## Ordem macro

1. `T-01` fecha numero, amostra e estado do bloco.
2. `T-02` monta as secoes do painel em cima disso.

Nao ha paralelo: as duas mexem no painel da mesma pagina.

## Tasks

### T-01 - Resumo e regra de bloco vazio

- objetivo: o Painel mostra os cinco indicadores, com meta anual calculada e "Nada configurado" no lugar de zero.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-08`, `R-11`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: dados que `VenueGoals` ja carrega; formatacao BRL da propria tela
- prompt recomendado: `smart`
- estrategia de teste: unitario das funcoes puras
- cenarios obrigatorios:
  - meta de 10000 em 12 meses vale 120000; duas metas somam
  - mes 0 ou 13 nao conta; meta sem mes soma zero
  - lista de metas vazia nao tem total
  - preco sem modelo ou menor ou igual a zero nao esta configurado
  - `minimumPrice` nulo ou zero nao esta configurado
  - contagem zero nao esta configurada
  - amostra devolve no maximo 3
  - `isLoading` e `error` vencem o vazio
- definition of done:
  - funcoes puras e o resumo montados no Painel, acima das secoes atuais
  - os cinco rotulos aparecem na ordem de `03-design.md#Resumo`
  - vitest dessas funcoes verde
  - secoes antigas, formulario e abas ainda no lugar
  - sem promocao de topic, decisao ou ADR

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o resumo mostrar zero, ou a meta anual usar um campo que nao existe
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: visual das secoes, ilustracao, formulario, abas de detalhe, API
- prova minima desta task: vitest cobre os cenarios obrigatorios; no Painel os cinco cards usam essa funcao
- criterio de escalada: parar se a meta anual precisar de coluna nova
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Resumo`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/specs/2026-11-05-painel-metas-precos/03-design.md#Resumo`
  - `.cursor/framework_core/specs/2026-11-05-painel-metas-precos/02-clarify.md#Premissas assumidas`
  - `.cursor/framework_global/framework-libs/design/rules/07_data_display_and_dashboards.md#Numeros e KPIs`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md#Estados de tela com dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueGoals.tsx`; `eventhub-vista-dashboard/src/components/goal/`
- palavras-chave ou simbolos de busca: `minValue`, `months`, `minimumPrice`, `pricingModel`, `viewMode === "panel"`
- testes provaveis: arquivo novo ao lado da funcao pura, no Vitest do frontend
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, `security`, backend

### T-02 - Secoes do painel na composicao da referencia

- objetivo: modelo, metas, adicionais, minimos e descontos ficam na composicao da referencia, com a mensagem de vazio dentro do bloco.
- cobre requisitos: `R-06`, `R-07`, `R-09`, `R-10`, `R-12`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: funcoes de `T-01`, `handleCardClick`, `hasEditPermission`, formulario de preco, `traduzirDiasSemana`
- prompt recomendado: `normal`
- estrategia de teste: teste de componente dos estados da secao; browser do Painel se houver sessao
- cenarios obrigatorios:
  - modelo fechado mostra valor e, com permissao, Editar; sem permissao, nao mostra Editar
  - metas e adicionais lado a lado no largo e empilhados no estreito
  - Ver todos de cada secao abre a aba que ja existia
  - card de meta sem barras; chips so dos meses da meta
  - lista vazia carregada diz "Nada configurado" e oferece criar so com permissao
  - carregando e erro nao usam essa frase
  - piso vazio e faixa preenchida convivem
  - formulario de preco, abas de detalhe e API sem mudanca de comportamento
- definition of done:
  - o bloco tracejado saiu do Painel
  - subtitulos e "Ver todos" batem com `02-clarify.md#Premissas assumidas`
  - vitest do componente verde
  - browser em `/venue/:id/goals`, aba Painel, com dado e com bloco vazio, quando a sessao existir; se o login impedir, registrar a lacuna
  - sem promocao de topic, decisao ou ADR

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o vazio aparecer no carregamento, ou o Ver todos deixar de abrir a aba
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: formula da meta anual, stores, schema, ilustracao, grafico
- prova minima desta task: componente cobre vazio, permissao e Ver todos; o Painel no browser segue a ordem resumo, modelo, metas|adicionais, minimos, descontos
- criterio de escalada: parar se a composicao exigir upload de imagem ou mudanca de API
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Secoes do painel`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/specs/2026-11-05-painel-metas-precos/03-design.md#Secoes do painel`
  - `.cursor/framework_core/specs/2026-11-05-painel-metas-precos/03-design.md#Estados`
  - `.cursor/framework_core/specs/2026-11-05-painel-metas-precos/02-clarify.md#Premissas assumidas`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md#Estados de tela com dados`
- caminhos candidatos: componente do painel criado em `T-01`; `eventhub-vista-dashboard/src/pages/VenueGoals.tsx`; `eventhub-vista-dashboard/src/components/goal/goal-header.tsx`
- palavras-chave ou simbolos de busca: `handleCardClick`, `hasEditPermission`, `EmptyState`, `Ver todos`
- testes provaveis: teste de componente em `eventhub-vista-dashboard`; passagem manual do Painel
- nao ler por padrao: `01-spec.md`, backend, `security`, spec de piso alem do campo que o painel ja le
