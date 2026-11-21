# Design — Card da casa na apresentacao publica

## Visao geral da solucao

O GET publico ganha `slogan`. A pagina deixa de colocar a descricao embaixo do logo e desenha o card da casa entre o hero e a foto solta. A funcao pura que ja escolhe os blocos passa a devolver o slogan, o card e a ordem nova. `ProposalView` nao muda.

Passada transversal:

- fronteira: nao muda; a mesma rota ganha uma chave. Sem ADR.
- dados persistidos: nao; `slogan` ja existe. Sem migration.
- interface: sim; um card a mais e a linha do topo nesta pagina.
- producao: sim, sem dashboard novo; 404 permanece.
- fluxo sensivel: sim; o GET publico so acrescenta `slogan`. A lista de chaves do teste barra o resto.
- conceito senior (`patterns/rules/06`): nao; leitura unica, sem fila, retry, cache ou idempotencia.

## Componentes e modulos impactados

- `art56_server_v3/src/functions/to-venue-presentation.ts`: `slogan` no tipo e no retorno.
- `art56_server_v3/src/repositories/in-prisma/venue-in-prisma-repository.ts`: `slogan: true` no `select` de `getPublicPresentation`.
- `art56_server_v3/src/use-cases/venue/get-venue-presentation/use-case-get-venue-presentation.spec.ts`: `ALLOWED_KEYS` e o fixture.
- `eventhub-vista-dashboard/src/lib/venue-presentation.ts`: tipo, `houseCard`, slogan e o bloco `house`.
- `eventhub-vista-dashboard/src/lib/venue-presentation.test.ts`: ordem e os recortes do card.
- `eventhub-vista-dashboard/src/pages/VenuePresentation.tsx`: topo, aba e o card.
- `topics/public-pages-and-branding.md`: a frase da ordem em `#Demais paginas publicas`.

## Reuso previsto

- Casca do card de `ProposalView`: `rounded-xl px-5 py-6 shadow-lg`, `cardStyle`, rotulo em caixa alta, titulo, divisor `border-t border-current/15`, grade `sm:grid-cols-2`.
- Icones `House`, `Clock` e `Info` de `lucide-react`, como nesse card.
- `venueTabTitle` recebendo o slogan nesta pagina.
- `mapLabel` que ja une bairro e cidade com ` — `.
- Nao extrair componente compartilhado com `ProposalView`.

## Contratos e dados

`GET /venue/presentation/:venueId` ganha `slogan: string | null`. As outras chaves ficam. `slogan` nulo sai `null`, sem virar string vazia no mapper.

O select de `getPublicPresentation` inclui `slogan` e nao inclui e-mail, CEP, complemento nem dono.

`venuePresentationView` recebe tambem `name`, `slogan`, `description`, `maxGuest`, `hasOvernightStay`, `checkIn`, `checkOut`, `minimumNights`, `openingHour` e `closingHour`. Devolve:

- `slogan`: texto com pontas aparadas, ou `null`
- `houseCard.description`: igual, ou `null`
- `houseCard.capacityLabel`: `Até ${maxGuest} pessoas`
- `houseCard.schedule`: `null` ou `{ label, value }`
- `houseCard.minimumNightsLabel`: `null` ou `Mínimo de N noite.` / `Mínimo de N noites.`
- `houseCard.placeLabel`: o `mapLabel` ja calculado, ou `null` quando vazio
- `blocks`: `house` entra sempre, depois de `video` ou `hero-photo` e antes de `solo-photo`

Horario sem pernoite, label `Horário de funcionamento`: os dois lados viram `8h às 22h`; so abertura devolve o rotulo da abertura; so fechamento devolve `até 22h`. Com pernoite, label `Estadia`: `Check-in 14h`, `Check-out 12h`, unidos por ` · ` quando os dois existem. Horario invalido permanece o texto original, como `hourLabel` da proposta.

## Card da casa

Ordem dentro do card: rotulo `A casa`, titulo com o nome, descricao se houver, divisor, grade com capacidade e horario, linha de noites, linha de local. Descricao usa `whitespace-pre-line`. Linha ausente nao reserva espaco.

## Falhas, casos de borda e invariantes

- O card nao depende de descricao, horario ou local.
- Sem hero, `house` fica logo depois de `logo`.
- `planVenuePhotos` conserva os indices atuais.
- Slogan e descricao so com espaco viram `null` na funcao pura. A pagina nao decide isso no JSX.
- A aba usa o slogan devolvido pela funcao, nao `house.description`.
- Troca de venue continua zerando o estado antes da resposta nova.

## Decisoes arquiteturais importantes

- Uma chave no contrato atual, em vez de um endpoint novo. Capacidade, horario e local ja saem nesse GET.
- O card e a linha do topo saem da funcao pura. A pagina so desenha.
- A aba desta pagina acompanha o slogan. As outras paginas continuam passando a descricao para `venueTabTitle`.
- Alternativa descartada: mostrar `—` no horario incompleto. O pedido manda omitir o que falta.
- Alternativa descartada: levar a duracao padrao do evento. Ela serve a hora extra, que fica no orcamento.

## Riscos e mitigacoes

- Vazar campo junto com `slogan`: o teste compara `Object.keys` com `ALLOWED_KEYS` mais `slogan`, e continua falhando se `email`, `cep` ou dono aparecerem.
- Frontend publicado antes da API: slogan vem `undefined` e a linha do topo some; o card usa o resto, que ja existe. Publicar a API antes evita a aba sem o texto curto.
- Descricao antiga copiada no slogan: o topo repete a frase curta ate alguem reescrever a descricao. Aceito; a copia ja foi feita na task do slogan.

## Rollout, observabilidade e rollback

- Sem migration e sem flag. Publicar a API e depois o frontend.
- Rollback: tirar `slogan` do retorno e o card da pagina. Nao ha dado novo.
- Sem alerta novo.

## Estrategia de validacao

- `T-01`: vitest do mapper com slogan preenchido e nulo, e a lista de chaves.
- `T-02`: vitest da funcao pura para ordem, slogan, pernoite, horario pela metade, noites e local; `npm test` do frontend. No browser, a sequencia visivel quando houver sessao.

## Fontes que fecharam a solucao

- `to-venue-presentation.ts` e `ALLOWED_KEYS` do spec do GET: horario, capacidade, pernoite, bairro e cidade ja saem; `slogan` nao
- `getPublicPresentation` no repositorio: o `select` ainda nao pede `slogan`
- `venue-presentation.ts`: `solo-photo` ocupa o vao; `mapLabel` ja formata bairro e cidade
- `ProposalView.tsx`: casca do card e `hourLabel`
- `topics/public-pages-and-branding.md#Demais paginas publicas`: a ordem que esta frase precisa atualizar
- `project-decisions.md#D-05`: leitura publica por id permanece
