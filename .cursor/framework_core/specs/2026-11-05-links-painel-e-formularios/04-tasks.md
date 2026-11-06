# Tasks — Links do painel e formularios de cadastro

## Ordem macro

1. `T-01` troca o campo de Regras pelo botao.
2. `T-03` pode correr junto com `T-01`: nao mexe em `VenueRules.tsx`.
3. `T-02` espera `T-01`, porque as duas editam `VenueRules.tsx`.

## Tasks

### T-01 - Botao para copiar o link das regras

- objetivo: em Regras, um botao largo copia a URL publica de producao e o campo sai da tela
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-04`
- depende de: nenhuma
- pode rodar em paralelo com: `T-03`
- reusa: `publicVenueRulesPath`, `Button` outline `w-full`, `showSuccessToast`
- prompt recomendado: smart
- estrategia de teste: unitario de `publicVenueRulesShareUrl`; browser da tela Regras
- cenarios obrigatorios:
  - a URL de `venue-1` e `https://event-hub-dashboard.vercel.app/venue/venue-1/rules/view`
  - a funcao nao recebe origem e o retorno nao contem `localhost`
  - `publicVenueRulesPath` continua igual
  - no browser, Regras nao mostra campo somente leitura; o botao copia essa URL e o toast confirma
  - com o painel em localhost, o texto copiado continua na base de producao
  - sem espaco selecionado, o botao nao aparece
- definition of done:
  - o bloco do campo saiu e o aviso de falha nao pede para selecionar o link
  - `npm test -- src/lib/public-venue-rules.test.ts` verde
  - pagina publica, Indicar parceiros e Link do evento intocados
  - nao promover memoria: a base fixa ja existe nas outras telas

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: copiar localhost ou deixar o campo na tela
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: formularios de criar e editar, sidebar, pagina publica, helper global de origem
- prova minima desta task: o unitario da URL absoluta e, no browser, o botao copiando a base de producao sem campo na tela
- criterio de escalada: parar se o botao outline de Orcamentos nao puder ser repetido sem componente novo
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Botao de copiar as regras`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/specs/2026-11-05-links-painel-e-formularios/03-design.md#Botao de copiar as regras`
  - `.cursor/framework_core/specs/2026-11-05-links-painel-e-formularios/03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md#Estados de componente interativo`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueRules.tsx`, `eventhub-vista-dashboard/src/lib/public-venue-rules.ts`, `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx`
- palavras-chave ou simbolos de busca: `publicVenueRulesShareUrl`, `Link das regras`, `window.location.origin`
- testes provaveis: `eventhub-vista-dashboard/src/lib/public-venue-rules.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `02-clarify.md`, `security`, `AnimatedFormSwitcher`, spec da pagina publica alem do que `03-design.md#Decisoes arquiteturais importantes` ja fixa

### T-02 - Abrir nova regra e nova caracteristica vazias

- objetivo: cada cadastro novo de regra e de caracteristica nasce vazio, e a edicao continua no item clicado
- cobre requisitos: `R-05`, `R-06`, `R-07`, `R-08`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: `openCreate` no mesmo formato nas duas paginas; `venueCreateFormKey`
- prompt recomendado: smart
- estrategia de teste: unitario da key; browser dos dois cadastros
- cenarios obrigatorios:
  - sem id, a key muda quando a sessao incrementa
  - com id, a key e o id
  - no browser, cadastrar uma regra e abrir Nova regra de novo deixa titulo e texto vazios
  - repetir em Caracteristicas com o nome vazio
  - editar mostra titulo, texto e posicao da regra, e nome e posicao da caracteristica
  - cancelar e abrir de novo comeca vazio
  - sair da edicao e abrir criacao nao herda o item
  - o `catch` da secao nao incrementa a sessao nem fecha o formulario
- definition of done:
  - `PageHeader` e a lista usam o mesmo `openCreate`
  - `npm test -- src/lib/venue-create-form-key.test.ts` verde
  - `AnimatedFormSwitcher` e os outros cadastros intocados
  - nao promover memoria

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: esvaziar a edicao ou o switcher dos outros cadastros
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: botao de copiar, sidebar, validacao, campos novos
- prova minima desta task: unitario da key e, no browser, os dois cadastros abrindo vazios depois de salvar, com a edicao ainda mostrando o item
- criterio de escalada: parar se o estado preso nao estiver no ciclo de vida destes dois formularios e a correcao precisar entrar no switcher
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Reset dos formularios`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/specs/2026-11-05-links-painel-e-formularios/03-design.md#Reset dos formularios`
  - `.cursor/framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Envio e resultado`
  - `.cursor/framework_global/framework-libs/react/rules/07_forms_and_user_interactions.md#Regra principal`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueRules.tsx`, `eventhub-vista-dashboard/src/pages/VenueAmenities.tsx`, `eventhub-vista-dashboard/src/components/venue-rule/venue-rule-section.tsx`, `eventhub-vista-dashboard/src/components/venue-amenity/venue-amenity-section.tsx`, `eventhub-vista-dashboard/src/components/ui/animated-form-switcher.tsx`
- palavras-chave ou simbolos de busca: `venueCreateFormKey`, `createSession`, `isCreating`, `AnimatedFormSwitcher`
- testes provaveis: `eventhub-vista-dashboard/src/lib/venue-create-form-key.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, formularios de servico, contato e orcamento

### T-03 - Abrir o link do evento numa aba nova

- objetivo: o item da sidebar abre a pagina publica do orcamento na base de producao, sem ir para a pagina do campo
- cobre requisitos: `R-09`, `R-10`, `R-11`
- depende de: nenhuma
- pode rodar em paralelo com: `T-01` e `T-02`
- reusa: filtro `SEND_PROPOSAL_INFO`, classes da linha da sidebar, `onNavItemClick`
- prompt recomendado: smart
- estrategia de teste: unitario da URL e da regressao dos destinos; browser da sidebar
- cenarios obrigatorios:
  - `proposalEventLinksUrl("proposal-1")` e `https://event-hub-dashboard.vercel.app/proposal/proposal-1/links`
  - o retorno nao contem `localhost`
  - `eventLinkDestinations` segue com "Regras do espaço" em href relativo
  - o item nao tem `href` para `/event-link`
  - no browser, o clique abre essa URL noutra aba e a aba do painel fica na rota atual
  - o item continua atras de `SEND_PROPOSAL_INFO`
  - `navigate` do efeito so recebe `href` string
- definition of done:
  - rota e pagina `ProposalEventLinkShare` conservadas, fora do menu
  - `npm test -- src/lib/event-link.test.ts` verde
  - Indicar parceiros e a tela Regras intocados
  - nao promover memoria

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: continuar na pagina do campo ou abrir localhost
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo desta task: conteudo de `/proposal/:id/links`, botao de Regras, apagar a rota interna
- prova minima desta task: unitario da URL absoluta e, no browser, a sidebar abrindo a aba de producao sem trocar a rota do painel
- criterio de escalada: parar se a ancora externa nao puder passar pelo filtro de permissao que o item ja tem
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Link do evento na sidebar`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/specs/2026-11-05-links-painel-e-formularios/03-design.md#Link do evento na sidebar`
  - `.cursor/framework_core/specs/2026-11-05-links-painel-e-formularios/03-design.md#Contratos e dados`
  - `.cursor/framework_global/framework-libs/react/rules/06_navigation_and_url_state.md#Regra principal`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/ProposalNav.tsx`, `eventhub-vista-dashboard/src/lib/event-link.ts`, `eventhub-vista-dashboard/src/App.tsx`
- palavras-chave ou simbolos de busca: `proposalEventLinksUrl`, `Link do evento`, `event-link`, `SEND_PROPOSAL_INFO`
- testes provaveis: `eventhub-vista-dashboard/src/lib/event-link.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, miolo de `ProposalEventLink.tsx`, `ProposalEventLinkShare.tsx` alem de saber que a rota fica
