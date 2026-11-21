# Design

## Visao geral da solucao

Cada orcamento ganha um `publicCode` de 8 caracteres. A URL que o cliente ve diz `espaco` e `orcamento`, com o nome da casa no meio. O trecho final e `{rotulo}-{codigo}` ou so `{codigo}` quando nao ha nome. A leitura ignora casa e rotulo e acha o orcamento pelo codigo. O id antigo continua sendo aceito nas rotas que ja existem.

## Passada transversal

- architecture: nao. Continua a mesma SPA e a mesma API; muda o caminho publico do browser, sem ADR.
- database: sim. Coluna nova, aditiva, nula, unica. Sem deploy na `main` nesta spec.
- design: sim. So o endereco. As paginas nao mudam de layout.
- observability: nao. Sem metrica nova.
- security: sim. O codigo e a credencial do link publico. Nao pode ser sequencial.
- patterns/06: sim. Colisao de codigo na criacao tenta outro. Uma gravacao so.

## Componentes e modulos impactados

- `Proposal` em `art56_server_v3/prisma/schema.prisma`: `publicCode String? @unique @db.Char(8)`
- criacao do orcamento (`createPerPerson` e `createPerDay`): gera o codigo antes de gravar
- leitura publica que hoje recebe o id na URL: aceita id ou codigo
- `eventhub-vista-dashboard`, familia do orcamento: `App.tsx`, `lib/event-link.ts`, `ClientPerPersonProposalForm.tsx`, `ClientPerDayProposalForm.tsx`, `ProposalDetails.tsx`, `EmailTab.tsx`, `SendProposalPage.tsx`, `person-list.tsx`, `schedule-list.tsx`, `ProposalContractForm.tsx`, `ProposalEventLinkShare.tsx`, `SendSuppliers.tsx`, `PUBLIC_ROUTES` em `lib/axios.ts` e `hooks/useBootstrapUser.ts`
- familia da casa: `lib/public-venue-presentation.ts`, `lib/public-venue-rules.ts`, `pages/VenueContacts.tsx`, `pages/VenuePresentation.tsx` (atalho para o formulario), `pages/VenueBudgets.tsx`, `components/venue/VenueNav.tsx`

## Reuso previsto

- `isVenueIdKey` em `art56_server_v3/src/functions/venue-public-key.ts` ja separa UUID de nome. A leitura do orcamento usa a mesma regex de UUID para decidir id versus codigo.
- O nome da casa na URL e o mesmo `Venue.name` de `/venue/AR756/form`.
- Funcao pura do rotulo e do formato, duplicada nos dois repositorios, com os mesmos vetores de teste. Nao ha pacote compartilhado.

## Contratos e dados

- Alfabeto: `abcdefghjkmnpqrstuvwxyz23456789`. Tamanho: 8. Gerado com aleatorio criptografico. Em colisao, gera de novo.
- Rotulo: nome em minusculas, sem acento, qualquer coisa que nao seja letra ou numero vira hifen, hifens repetidos e das pontas somem. Vazio nao entra na URL.
- Forma do orcamento: `/espaco/{Venue.name}/orcamento/{rotulo}-{publicCode}`. Sem rotulo: `/espaco/{Venue.name}/orcamento/{publicCode}`.
- Sufixos do orcamento: `evento` (hoje `links`), `convidados`, `colaboradores`, `programacao`, `indicacoes`, `contrato`.
- Forma da casa, sem codigo: `/espaco/{Venue.name}/apresentacao`, `/formulario`, `/regras`, `/parceiro`, `/colaborador`. A chave e o nome, como o formulario ja faz. O id antigo desses caminhos continua valendo.
- `/contrato` renderiza o formulario de pessoa fisica ou juridica conforme o tipo ja gravado. Os caminhos `person-contract` e `b2b-contract` ficam so como link antigo.
- Leitura: se o trecho for UUID, busca por `id`. Senao, o codigo e o ultimo segmento que casa com os 8 caracteres do alfabeto; o resto e ignorado. Casa e rotulo nao filtram.
- A API nao muda de caminho. O parametro que hoje e o id tambem aceita o codigo nas leituras e escritas publicas usadas por essas paginas: apresentacao, `byId`, indicacoes, servicos, recalculo, pessoas, agenda e dados pessoais do contrato. Reordenar e trocar foto continuam exigindo o id e a sessao de quem edita o site.
- O painel recebe `publicCode` no orcamento que ja carrega, para montar o link. A resposta publica de apresentacao nao lista dono, contrato nem pagamento.
- Coluna nula. Orcamento velho sem codigo abre pelo id. Criacao nova sempre grava codigo.
- Migration so adiciona a coluna. Backfill e deploy request na `main` ficam para uma aprovacao nomeada, fora desta spec.

## Falhas, casos de borda e invariantes

- Invariante: o codigo nao muda quando o nome do cliente muda. Links ja copiados seguem validos.
- Invariante: dois orcamentos nao compartilham codigo.
- Codigo que nao existe responde como id que nao existe.
- `maria-silva-1` nao tem 8 caracteres do alfabeto no sufixo e nao acha orcamento.
- Nome `José da Silva` vira `jose-da-silva`.

## Decisoes arquiteturais importantes

- As palavras `espaco`, `orcamento`, `formulario`, `regras`, `parceiro`, `colaborador`, `evento`, `convidados`, `programacao`, `indicacoes` e `contrato` existem so na URL do browser. A API fica `/proposal/` porque o cliente nao ve esse caminho.
- O painel fica `/proposal/:id` porque a troca pedida e a URL enviada ao cliente.
- 8 caracteres, nao 4: `32^4` da para percorrer; `32^8` nao e um contador e cabe no endereco.
- Nao ha redirect do endereco antigo para o novo. Os dois abrem. O que se copia e o novo.
- Descartado: `maria-silva-2`, porque e enumeravel. Descartado: o nome como chave unica.

## Riscos e mitigacoes

- Enumerar codigos: alfabeto sem ambiguos e tamanho 8; teste recusa sufixo numerico.
- Pacote publico maior: a apresentacao nao ganha campo novo; `publicCode` sai na carga que o painel ja usa para copiar o link.
- Link antigo quebrado: as rotas `/proposal/:id/...` permanecem registradas.

## Rollout, observabilidade e rollback

- Ordem: coluna no repositorio, leitura por id ou codigo, depois a URL nova no frontend. Sem a coluna, o frontend nao pode ser publicado.
- Rollback do frontend: voltar a copiar `/proposal/{id}/view`. A coluna pode ficar.
- Sem alerta novo.

## Estrategia de validacao

- Backend: gerador, rotulo, leitura por codigo, homonimos, sufixo invalido, id antigo.
- Frontend: montagem da URL, rotas publicas com `orcamento`, rotas antigas ainda presentes, `PUBLIC_ROUTES` cobrindo o caminho novo.
- Browser, na execucao de `T-02`: abrir o caminho novo e um `/proposal/{id}/view` antigo.

## Fontes

- `task-requests/url-orcamento-nome-e-codigo-request.md`
- `topics/public-pages-and-branding.md` (paginas publicas e marca)
- `topics/data-and-migrations.md` (coluna aditiva, sem deploy na `main` sem aprovacao)
- `project/api-endpoints.md` (id publico dificil de adivinhar)
- `project/frontend-map.md` (lista das paginas `/proposal/:id/...`)
- `framework-libs/security/index.md` (endpoint publico)
