# Design — Indicacoes publicas do orcamento

## Visao geral da solucao

O orcamento passa a ter uma lista ordenada de contatos indicados. Enviar Parceiros grava essa lista. A pagina publica le a lista e mostra o cadastro atual de cada parceiro, dentro de `PublicVenueListShell`.

## Passada transversal

- architecture: sim — nasce uma fronteira nova no orcamento, gravacao autenticada e leitura publica; permanece no monolito Express (`D-02`), sem ADR
- database: sim — tabela nova, indice unico e migration aditiva; cascata pelo Prisma, nao por FK fisica (`D-03`)
- design: sim — o painel perde a mensagem e a pagina nova reusa a casca das listas, com vazio, loading e erro
- observability: sim, vai para producao — sem dashboard novo; o sinal minimo e log de falha com id do orcamento e quantidade, nunca com WhatsApp ou e-mail
- security: sim — leitura publica de PII de parceiro; gravacao com JWT, permissao e ownership do espaco
- patterns/rules/06: sim — substituir o conjunto inteiro e idempotente; repetir o mesmo pedido nao muda o resultado visivel

## Dados

Tabela `proposal_indication`, model `ProposalIndication`:

- `id` uuid
- `proposalId` e `contactId`, unicos juntos
- `position` inteiro, comecando em 0, na ordem do pedido ja sem ids repetidos
- `createdAt`
- relacao com `Proposal` e `Contact`, `onDelete: Cascade` nos dois lados
- indice em `proposalId` e em `contactId`

Nao ha colunas de nome, telefone ou rede. O card le `Contact`. Apagar o contato ou o orcamento apaga o vinculo pelo Prisma.

Descartado: copiar os campos do parceiro para a tabela. A pagina ficaria velha e o pedido pede o que o cadastro tem hoje.

## Gravacao

`PUT /proposal/indications/:proposalId`, com `ensureAuthenticate`.

Corpo: `{ contactIds: string[] }`. Lista vazia e valida e zera o orcamento.

O use case, numa transacao:

1. carrega o orcamento; se nao existir, 404
2. confirma que o usuario tem `SEND_PROPOSAL_INFO` em `UserVenuePermission` daquele `venueId`; senao, 403
3. tira ids repetidos, mantendo a primeira ocorrencia
4. exige que cada id restante exista, seja `SUPPLIER` e tenha o mesmo `venueId` do orcamento; se um falhar, 400 e a selecao anterior permanece
5. apaga os vinculos daquele orcamento e cria os novos com `position`

`ensurePermission` fica de fora: ele olha a organizacao inteira e responde com o texto do calendario.

Log de erro: `proposalId` e `contactIds.length`. Sem nome, WhatsApp ou e-mail.

## Leitura publica

`GET /proposal/indications/:proposalId`, sem auth, ao lado de `GET /proposal/byId/:proposalId`.

Resposta, na ordem de `position`:

- `id`, `name`, `role`, `whatsapp`, `email`, `instagramUrl`, `facebookUrl`, `tiktokUrl`, `url`

Somente vinculos cujo contato ainda e `SUPPLIER` daquele espaco. Contato de equipe nao entra, mesmo que um vinculo antigo exista. Orcamento inexistente: 404 e lista ausente. Orcamento sem vinculo: 200 e lista vazia.

O painel reusa este GET para remarcar os checkboxes. O catalogo de fornecedores continua em `GET /contact/list/:venueId`.

## Painel

`SendSuppliers` deixa de ter textarea, `wa.me` e o rotulo de enviar mensagem. Os checkboxes dos fornecedores do espaco continuam.

Ao abrir, marca os ids que o GET publico devolver. Salvar chama o PUT. Sucesso recolhe a selecao pelo mesmo GET. Falha mostra o erro que a API ja devolve e nao troca a marcacao local pela resposta vazia.

O link fica visivel na tela: origem atual + `/proposal/${id}/indications`, com acao de copiar. Nao ha host fixo.

A rota do painel continua em `ProtectedRoute` com `SEND_PROPOSAL_INFO`.

## Pagina publica

Rota nova, sem `ProtectedRoute`: `/proposal/:id/indications`.

A pagina carrega o orcamento por `GET /proposal/byId/:proposalId`, a marca por `usePublicListVenue` e os cards pelo GET de indicacoes. `PublicVenueListShell` com `variant="people"` segura logo, cores, aba, skeleton e rodape.

Cada card e so leitura. O titulo e o nome; a funcao fica abaixo. So entram os campos preenchidos:

- WhatsApp abre `https://wa.me/` com os digitos
- e-mail abre `mailto:`
- Instagram, Facebook, TikTok e site abrem a URL gravada, em nova aba

Lista vazia: um card com "Ainda nao ha indicacoes para o seu evento." Erro de leitura: uma frase curta dentro da casca, depois que a marca do espaco ja pode aparecer. Falha de logo nao prende o skeleton alem do que a casca ja faz.

Copy de titulo do miolo: "Nossas indicacoes".

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma` e uma migration aditiva
- `art56_server_v3/src/router/proposal.ts`
- use case, factory, controller, Zod e repository novos de indicacao, no desenho `D-02`
- `eventhub-vista-dashboard/src/pages/SendSuppliers.tsx`
- pagina nova ao lado de `GuestList.tsx`, rota em `App.tsx`

## Reuso previsto

- `PublicVenueListShell`, `usePublicListVenue` e as classes de `public-list-pattern.ts`
- listagem de fornecedores e o toast de erro que o painel ja usa
- `ensureAuthenticate`; nao o `ensurePermission` do calendario

## Contratos e dados

O contrato desta feature e o PUT e o GET descritos acima. Nao ha arquivo em `contracts/`: os dois corpos cabem nesta secao e a execucao os valida com Zod e teste.

## Falhas, casos de borda e invariantes

- um orcamento nao aponta o mesmo contato duas vezes
- todo vinculo gravado e de fornecedor do mesmo espaco
- a leitura publica nao lista o catalogo do espaco
- substituir com o mesmo conjunto deixa os mesmos ids na mesma ordem
- a ultima transacao concluida vence uma gravacao concorrente
- apagar contato ou orcamento nao deixa vinculo orfao no uso pelo Prisma

## Decisoes arquiteturais importantes

- Um GET publico serve a pagina e o painel. Um segundo GET autenticado repetiria o mesmo recorte.
- A permissao e checada no use case, no espaco do orcamento, porque o middleware existente nao tem esse recorte.
- Sem feature flag. Antes da primeira gravacao a pagina abre vazia, na marca do espaco.

Descartado: mandar o link pelo fluxo de Enviar Orcamento. O pedido separa a indicacao da mensagem.

## Riscos e mitigacoes

- Quem tem o id do orcamento ve WhatsApp e e-mail dos parceiros indicados. O mesmo ja vale para outras paginas publicas da proposta. A mitigacao e nao devolver o resto dos contatos.
- A listagem geral de contatos segue publica. Esta spec nao a amplia e nao a usa na pagina nova.

## Rollout, observabilidade e rollback

A migration so cria tabela e indices. Reverter o codigo deixa a tabela sem uso. Reverter o frontend devolve o WhatsApp antigo e ignora os vinculos. Nao ha fila nem retry automatico. Log de falha sem PII.

## Estrategia de validacao

- `T-01`: `npx prisma validate`
- `T-02` e `T-03`: `npm test -- --run` nos use cases, com 401, 403, 400 e o recorte publico
- `T-04` e `T-05`: a prova de tela fica no Context Pack de cada task; unitario nao substitui abrir a pagina

## Fontes

- `project/project-decisions.md` `D-01`, `D-02`, `D-03`, `D-05`
- `topics/auth-and-security.md` — rota publica explicita e teste negativo
- `art56_server_v3/src/router/proposal.ts` — `byId` publico e rotas autenticadas no mesmo router
- `art56_server_v3/src/middleware/ensurePermission.ts` — middleware de calendario, nao reutilizado
- `eventhub-vista-dashboard/src/components/proposal/PublicVenueListShell.tsx` — casca das listas
- `framework-libs/patterns/rules/06_senior_engineering_concepts.md` — substituicao idempotente
