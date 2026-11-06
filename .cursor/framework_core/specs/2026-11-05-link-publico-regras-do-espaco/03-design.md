# Design — Link publico das regras do espaco

## Visao geral da solucao

Uma leitura publica nova, no router que ja existe, devolve so id, titulo, texto e posicao. A pagina `/venue/:id/rules/view` usa a casca das listas publicas. A tela Regras mostra esse endereco com Copiar. O Link do evento ganha o sexto destino quando o orcamento tem venue.

## Passada transversal

- topologia: sim, nova fronteira de leitura no mesmo monolito Express; sem servico novo e sem ADR (`project-decisions.md#D-02`)
- dados persistidos: nao; `VenueRule` permanece; sem migration
- interface: sim; pagina publica, campo de copiar e um botao no Link do evento
- producao: sim; sem metrica nem dashboard novo; nao registrar o texto da regra
- fluxo sensivel: sim; endpoint publico com allowlist de campos e teste negativo nas rotas que continuam privadas (`security/rules/02_auth_and_access.md`, `project-decisions.md#D-05`)
- conceito senior (`patterns/rules/06`): nao; leitura sem fila, cache, retry ou idempotencia propria

## Componentes e modulos impactados

- `art56_server_v3/src/router/venue-rule.ts`: `GET /public/:venueId` antes de `ensureAuthenticate`
- use case e factory novos em `art56_server_v3/src/use-cases/venue-rule/list-public-venue-rule/`
- `art56_server_v3/src/use-cases/venue-rule/venue-rule.spec.ts`
- `eventhub-vista-dashboard/src/pages/` pagina publica nova, rota em `App.tsx` sem `ProtectedRoute`
- `eventhub-vista-dashboard/src/lib/axios.ts` e `src/hooks/useBootstrapUser.ts`: allowlist
- `eventhub-vista-dashboard/src/pages/VenueRules.tsx`: endereco e Copiar
- `eventhub-vista-dashboard/src/lib/event-link.ts`, o teste e `src/pages/ProposalEventLink.tsx`
- `product/04-user-journeys.md`: uma frase na jornada de captar

## Reuso previsto

- formato `{ success, message, data, count, type: "VenueRule" }`, com `data` ja filtrado
- `listByVenue`, que ordena por posicao e data de criacao
- existencia do venue pelo `getById` ja usado no authorizer de regras; so o id interessa
- `PublicVenueListShell` com `usePublicListVenue` e `variant="people"`
- copia no gesto de `ProposalEventLinkShare`: campo somente leitura, botao Copiar, toast de sucesso e toast de falha
- `HttpResourceNotFoundError` para venue ausente

Nao reutilizar `ListVenueRuleUseCase` nem abrir `GET /venue-rule/list/:venueId`.

## Contratos e dados

`GET /venue-rule/public/:venueId`

- sem `ensureAuthenticate` e sem `VIEW_VENUE_RULES`
- `venueId` vazio: 400, pelo schema atual de parametro
- venue ausente: 404
- venue presente: 200, `data` com `{ id, title, text, position }` na ordem do repositorio
- lista vazia: 200 e `data: []`
- `title` nulo permanece nulo

Create, update, delete e `GET /list/:venueId` ficam depois de `ensureAuthenticate`, como hoje.

Pagina: `/venue/:id/rules/view`.

Endereco copiado: `window.location.origin + /venue/${venueId}/rules/view`.

## Pagina publica

- rota fora de `ProtectedRoute`, declarada ao lado de `/venue/:id/form`
- a mesma casca das listas: fundo primario, card secundario, texto na cor do texto, Manrope, logo e descricao no topo, aba com nome e descricao, skeleton na marca, entrada animada e o mesmo rodape
- titulo da secao: "Regras do espaço"
- cada regra e um card; com titulo, o titulo vai acima do texto; sem titulo, so o texto
- o texto usa quebra de linha e nao passa por HTML
- a ordem e a do array; a pagina nao reordena
- vazio: "Ainda não há regras deste espaço."
- falha ou venue ausente: "Não foi possível carregar as regras." e nenhum card
- troca de `venueId` zera a lista anterior antes da resposta nova

## Tela Regras e Link do evento

- o bloco de copia fica na tela Regras para quem ja a abre, tambem sem `EDIT_VENUE_RULES`
- rotulo "Link das regras", campo com `aria-label` igual, botao "Copiar"
- sucesso: "Link copiado"; falha: "Não foi possível copiar" e o campo segue selecionavel
- `eventLinkDestinations(proposalId, venueId)` acrescenta o sexto item so quando `venueId` existe
- rotulo "Regras do espaço", descricao "O que vale neste espaço", href `/venue/${venueId}/rules/view`
- os cinco destinos atuais permanecem, na mesma ordem
- orcamento sem venue carregado nao ganha o sexto botao

## Falhas, casos de borda e invariantes

- a leitura publica nunca chama o authorizer
- a resposta publica nao inclui data, `venueId` nem usuario
- regra de outro venue nao entra no `where`
- marcacao no texto nao vira HTML
- 401 numa rota antiga de regra continua exigindo login

## Decisoes arquiteturais importantes

- rota irmã `/public/:venueId`, porque a listagem autenticada devolve a linha inteira e exige permissao
- pagina no venue, porque a regra nao pertence ao orcamento
- `/venue/:id/rules/view`, porque `/venue/:id/rules` ja e o cadastro
- copia na propria tela Regras, porque o pedido nao pediu item novo de menu
- sem ADR: a fronteira nova continua no monolito e no padrao router, controller, use case, repositorio

Alternativa descartada: tornar `GET /list` publico. Mistura contrato autenticado e payload completo.

## Riscos e mitigacoes

- middleware aplicado ao router inteiro esconderia a rota publica atras do 401: registrar `GET /public/:venueId` antes de `use(ensureAuthenticate)`
- `getById` do venue ja e publico e pode trazer dado a mais: a pagina de regras so usa a casca que as listas ja usam; o use case publico nao repassa esse payload
- id da regra na resposta: nao substitui permissao de gravacao, que segue no authorizer

## Rollout, observabilidade e rollback

- sem migration e sem flag
- sem metrica nova; erro HTTP atual basta
- rollback: remover a rota publica, a pagina, o bloco de copia e o sexto destino; a tabela e o cadastro ficam

## Estrategia de validacao

- `T-01`: `npx vitest run src/use-cases/venue-rule/venue-rule.spec.ts` no backend
- `T-02`: vitest do mapeamento da pagina e da allowlist; a casca segue o componente existente
- `T-03`: o teste atual de `eventLinkDestinations` passa a cobrir o sexto href
- prova de ponta, depois das tres: abrir `/venue/:id/rules/view` sem sessao e o botao no Link do evento

## Fontes

- `project-decisions.md#D-02` e `#D-05`
- `security/rules/02_auth_and_access.md`
- `product/08-data-model.md` (`VenueRule`)
- `product/04-user-journeys.md` (a frase nova entra em `T-02`)
- codigo: `router/venue-rule.ts`, `use-case-list-venue-rule.ts`, `venue-rule-in-prisma-repository.ts`, `PublicVenueListShell.tsx`, `event-link.ts`, `axios.ts`, `useBootstrapUser.ts`
