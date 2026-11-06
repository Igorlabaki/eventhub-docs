# Design — Links do painel e formularios de cadastro

## Visao geral da solucao

Tres ajustes no `frontend`, sem API nova. Regras troca o campo por um botao que copia a URL absoluta de producao. Regra e caracteristica passam a remontar o formulario de criacao a cada abertura, sem mexer no switcher compartilhado. O item Link do evento vira uma ancora para a pagina publica, noutra aba.

## Passada transversal

- muda topologia, fronteira ou fluxo entre partes? nao — continua no `frontend`; as rotas publicas ja existem. Sem ADR.
- toca dados persistidos? nao — nenhum schema, indice ou migration.
- toca interface? sim — botao, toast, campos de criacao e o item da sidebar. Estados em `03-design.md#Falhas, casos de borda e invariantes`.
- vai para producao? sim, no deploy do frontend que ja existe. Sem metrica, dashboard ou alerta novo: o toast e a aba sao o sinal.
- toca fluxo sensivel? nao — nao muda auth, audiencia publica, PII nem segredo. `security` fica de fora do runtime.
- gatilho de `patterns/rules/06`? nao — sem retry, fila, cache, concorrencia ou idempotencia.

## Componentes e modulos impactados

- `eventhub-vista-dashboard/src/pages/VenueRules.tsx` — sai o bloco do campo; entra o botao e o contador de abertura
- `eventhub-vista-dashboard/src/pages/VenueAmenities.tsx` — o mesmo contador de abertura
- `eventhub-vista-dashboard/src/components/venue-rule/venue-rule-section.tsx` e `venue-amenity-section.tsx` — `key` do formulario
- `eventhub-vista-dashboard/src/lib/public-venue-rules.ts` — URL absoluta das regras
- `eventhub-vista-dashboard/src/lib/venue-create-form-key.ts` — key de criacao versus edicao
- `eventhub-vista-dashboard/src/components/ProposalNav.tsx` — item externo
- `eventhub-vista-dashboard/src/lib/event-link.ts` — URL absoluta de `/proposal/{id}/links`, sem mudar `eventLinkDestinations`

## Reuso previsto

- visual do botao: `Button` `variant="outline"` e `className="w-full"`, como em `VenueBudgets.tsx` e `contact-list.tsx`
- caminho relativo: `publicVenueRulesPath`
- toast de sucesso ja usado em `VenueRules.tsx`
- classes visuais da linha da sidebar: as do `Link` interno, sem o estado de rota ativa
- `window.open` nao entra. A ancora com `target="_blank"` e `rel="noopener noreferrer"` abre a aba no clique, no clique do meio e no menu do navegador. `ProposalTable.tsx` abre com `window.open` porque a linha da tabela nao e um link; aqui o item e um link.

## Contratos e dados

Nenhum contrato HTTP. Funcoes puras:

- `publicVenueRulesShareUrl(venueId)` devolve `https://event-hub-dashboard.vercel.app` + `publicVenueRulesPath(venueId)`. Nao recebe origem e nao le `window.location`.
- `proposalEventLinksUrl(proposalId)` devolve `https://event-hub-dashboard.vercel.app/proposal/${proposalId}/links`.
- `venueCreateFormKey(recordId, session)` devolve `recordId` quando houver id; senao `new-${session}`.

A base fica duplicada de proposito, no mesmo literal das outras telas. Nao criar helper global de origem.

## Botao de copiar as regras

Substituir o bloco `mb-6` de `VenueRules.tsx` (rotulo "Link das regras", `Input` e botao "Copiar") por um botao largo no mesmo lugar, acima de Nova regra.

- rotulo: `Copiar link das regras`
- so renderiza quando `venue.id` existe
- clique: `navigator.clipboard.writeText(publicVenueRulesShareUrl(venue.id))`
- sucesso: manter titulo "Link copiado" e a descricao atual
- falha: titulo "Não foi possível copiar" e descricao "Tente de novo."
- quem ve a tela ve o botao, com ou sem `EDIT_VENUE_RULES`

## Reset dos formularios

Causa: o switcher nao desmonta o formulario, e o `useEffect` de `reset` nao roda de novo enquanto `rule` ou `amenity` seguem `undefined`.

Decisao: nao alterar `AnimatedFormSwitcher`, `venue-rule-form.tsx` nem `venue-amenity-form.tsx`. Em `VenueRules` e `VenueAmenities`, um `createSession` comeca em 0. `openCreate` incrementa a sessao, zera o registro selecionado e abre a criacao. Esse callback vale para o `PageHeader` e para o `onCreateClick` da lista. A secao aplica `key={venueCreateFormKey(id, createSession)}` no formulario.

Editar usa o id do item, entao troca de item remonta com os `defaultValues` daquele registro. A posicao continua so na edicao. O `catch` da secao nao incrementa a sessao e nao fecha o formulario.

## Link do evento na sidebar

O item ja nao e um `NavItem` solto: a sidebar esta em secoes. Em `sidebar-nav-model.ts`, "Link do evento" fica com `opensExternalUrl` e `SEND_PROPOSAL_INFO`. `presentNavItems` pede a URL a `ProposalNav`, que passa `proposalEventLinksUrl(proposal.id)`. Sem id, o item sai da lista.

`SectionedNav` renderiza `<a href target="_blank" rel="noopener noreferrer">` com as classes da linha interna, sem marcar a rota como ativa. O clique chama `onNavigate`, sem `preventDefault`.

O efeito de `ProposalNav` so chama `navigate` com o retorno string de `internalItemHref`. Item externo devolve `null` e nao entra nessa escolha.

Nao apagar `ProposalEventLinkShare.tsx` nem a rota `/proposal/:id/event-link`. Nao recolocar o `href` dessa rota no menu. Nao editar os seis destinos de `eventLinkDestinations`.

## Falhas, casos de borda e invariantes

- clipboard rejeita: toast de falha, lista intacta, nenhum campo para selecionar
- sem `venue.id`: botao ausente
- sem `proposal.id`: item ausente
- popup bloqueado: a ancora nao navega a aba do painel
- painel em localhost: as duas URLs absolutas nao contem `localhost`
- falha ao salvar regra ou caracteristica: campos preservados
- criacao depois de edicao: key `new-${session}`, nao o id anterior
- edicao depois de um rascunho: key igual ao id clicado

## Decisoes arquiteturais importantes

- ancora externa, e nao `Link` do React Router: o destino e outra aba, fora da arvore autenticada do painel
- key por sessao, e nao reset global do switcher: o defeito esta no ciclo de vida destes dois formularios
- rota interna conservada: o pedido tira o destino do menu; apagar a pagina seria outro recorte
- a spec `2026-11-05-link-publico-regras-do-espaco` segue dona da leitura publica e do destino "Regras do espaço". O campo com `window.location.origin` que ela colocou em Regras e substituido aqui

Alternativas descartadas: variavel de ambiente para o host; helper unico para todos os links do dashboard; desmontar todo formulario no switcher; `window.open` no item da sidebar; apagar `ProposalEventLinkShare` nesta feature.

## Riscos e mitigacoes

- `T-01` e `T-02` editam `VenueRules.tsx`. `T-02` espera `T-01`.
- um `navigate(undefined)` se o primeiro item permitido nao tiver `href`. O guard do `useEffect` cobre isso.
- recolocar o campo "para facilitar a copia manual" viola `R-01`. A falha da copia so mostra o toast.

## Rollout, observabilidade e rollback

Deploy do frontend, junto do que ja sai para a Vercel. Sem flag. Rollback: reverter o commit destas tres tasks. Nao ha migration.

## Estrategia de validacao

- `npm test -- src/lib/public-venue-rules.test.ts src/lib/venue-create-form-key.test.ts src/lib/event-link.test.ts` no `frontend`
- browser: Regras sem campo, copia da URL de producao, toast; Nova regra e Nova caracteristica vazias apos um cadastro; edicao com o item clicado; sidebar abre a aba de producao e o painel nao troca de rota
- nao ha Testing Library; nao instalar nesta feature

## Docs determinantes

- `design/rules/06_forms_and_input_ux.md`: falha de envio preserva o que foi digitado; por isso a sessao nao incrementa no `catch`
- `react/index.md`: implementacao no React existente, sem terceira camada de estado
- `topics/frontend-application.md`: nao adiciona regra alem de manter o gesto no frontend
- nenhum ADR e nenhuma decisao de `project-decisions.md`
