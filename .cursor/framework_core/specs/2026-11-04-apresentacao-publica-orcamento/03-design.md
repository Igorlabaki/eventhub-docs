# Design — Apresentacao publica do orcamento

## Visao geral da solucao

A pagina publica deixa de pedir o venue inteiro. Ela continua lendo o orcamento em `GET /proposal/byId/:proposalId` para numeros, datas, convidados e servicos, e passa a ler um pacote curto da casa pelo id desse orcamento. As tres cores nascem em Configuracoes e viajam nesse pacote.

Ordem da pagina: capa (logo, descricao, primeira foto); este evento; galeria; caracteristicas; incluso neste orcamento; card de valor; WhatsApp; bairro e cidade com link do mapa e icones. Secao sem dado nao renderiza. O nome em texto nao repete o logo.

## Passada transversal

- architecture: sim — a leitura publica deixa de ser o venue completo e vira um recorte por orcamento, no mesmo monolito; nao pede ADR alem de D-02
- database: sim — tres colunas nulas em `venue`; migration aditiva, sem backfill e sem indice novo
- design: sim — a pagina publica e tres campos em Configuracoes; cores locais da pagina, sem token global novo
- observability: nao — sem dashboard; a leitura publica nao loga corpo nem dado de cliente
- security: sim — leitura publica com allowlist; gravacao segue a rota autenticada que ja existe
- patterns/rules/06: nao — sem fila, cache, retry ou chave de idempotencia; cor usa a ultima escrita

## Componentes e modulos impactados

- `art56_server_v3/prisma/schema.prisma`: tres colunas no `Venue`
- update do venue: aceitar e validar as tres cores no fluxo que Configuracoes ja usa
- novo `GET /proposal/presentation/:proposalId`, publico, no router de proposal
- `eventhub-vista-dashboard/src/pages/VenueSettings.tsx`: tres cores e acao de limpar
- `eventhub-vista-dashboard/src/pages/ProposalView.tsx`: apresentacao; deixa de chamar `fetchVenueById`
- `proposalFooter.tsx`: recebe o recorte da casa, nao o `Venue` completo

## Reuso previsto

- fotos: filtro `isShowOnOrganization` ja usado no site da organizacao
- caracteristicas: tabela `venue_amenity`, lida dentro do pacote publico; nao chamar `GET /venue-amenity/list`, que exige `VIEW_VENUE_AMENITIES`
- servicos e totais: `proposalServices` que `GET /proposal/byId` ja devolve
- datas do evento: `wallClockDateBr` e `wallClockTime`
- gravacao: `PUT /venue/update`, ja com `ensureAuthenticate`
- cores atuais: tokens ja usados na pagina quando o campo vier nulo

## Contratos e dados

Colunas novas em `venue`, todas opcionais, `VarChar(7)`, sem default e sem backfill:

- `proposalPrimaryColor`
- `proposalSecondaryColor`
- `proposalTextColor`

Valor gravado: `#RRGGBB` ou nulo. String vazia vira nulo. Qualquer outro valor responde 400 e nao grava.

`GET /proposal/presentation/:proposalId` nao exige token. Resposta 200 com um unico objeto, ou o nao-encontrado ja usado quando o orcamento nao existe. Campos:

- casa: `name`, `description`, `logoUrl`, `city`, `neighborhood`, `maxGuest`, `hasOvernightStay`, `checkIn`, `checkOut`, `minimumNights`, `openingHour`, `closingHour`, `url`, `instagramUrl`, `facebookUrl`, `tiktokUrl`, `whatsappNumber`
- cores: as tres colunas, nulas se vazias
- `images`: `imageUrl`, `description`, `position`, somente `isShowOnOrganization = true`, ordenadas por `position`
- `amenities`: `name`, `position`, ordenadas por `position` e depois por criacao

Fora desse objeto: CEP, e-mail, precos, dono, contrato, pagamento, regra, texto de amenities e servico de catalogo. Rua, numero e estado entram so para o link do mapa. A query seleciona essa lista; nao faz `include` do venue.

A pagina aplica as cores so em `ProposalView`: primaria no fundo, secundaria no fundo dos cards e texto na fonte. Nulo usa a classe que a pagina ja tem naquele papel. Configuracoes nao pinta o painel. O rodape indigo permanece.

## Cores no cadastro

Os tres campos entram no formulario de `VenueSettings`, no mesmo submit. Cada um aceita o seletor e o hex. Uma acao limpa os tres e grava nulo. Quem nao tem a permissao que a rota `/venue/:id/settings` ja exige nao abre a tela. O backend da gravacao continua autenticado; esta feature nao abre esse `PUT` ao anonimo e nao cria string nova de permissao.

## Pacote publico

O use case carrega o orcamento pelo id, le o `venueId` dele e monta o select acima. Nao existe listagem. Id desconhecido nao revela se a casa existe. `ProposalView` troca `fetchVenueById` por essa leitura. O rodape usa nome, WhatsApp e as quatro URLs desse objeto.

## Pagina publica

A capa usa `logoUrl` e a primeira imagem do pacote. As imagens seguintes formam a galeria. Caracteristicas e nomes de `proposalServices` sao listas. O card de valor que ja existe permanece no fim, com base, horas extras, preco de servico e total. Pernoite esconde abertura e fechamento; sem pernoite esconde check-in, check-out e minimo de noites.

## Falhas, casos de borda e invariantes

- imagem, caracteristica, servico, link ou logo ausentes omitem so o seu bloco
- uma cor nula nao anula as outras
- o pacote de um orcamento nao inclui linha de outro `venueId`
- a pagina publica nao chama `getById` do venue nem a lista autenticada de caracteristicas

## Decisoes arquiteturais importantes

- pacote novo em vez de alargar `getById` ou `getWebData`: o primeiro leva dono e contrato; o segundo nao tem descricao, bairro, capacidade, pernoite nem caracteristica, e leva o catalogo de servicos
- cores em coluna do venue, nao em tabela nova: sao tres campos do mesmo cadastro
- nao corrigir aqui o `GET /proposal/byId`, que ja devolve pagamento e pessoas: misturar esse enxugamento com a apresentacao muda o painel que tambem le essa rota

## Riscos e mitigacoes

- allowlist furar e devolver relacao inteira: o teste de `T-03` afirma a ausencia das chaves proibidas
- `ProposalView` continuar no venue completo: `T-05` remove essa chamada
- cor gravada pintar o `:root`: as variaveis ficam no container da proposta

## Rollout, observabilidade e rollback

- rollout: colunas nulas; pagina antiga continua valida ate o frontend trocar de chamada
- observabilidade: sem metrica nova; erro publico sem corpo de cliente no log
- rollback: remover a chamada nova no frontend; as colunas podem ficar nulas

## Estrategia de validacao

- `T-01`: `npx prisma validate` e SQL so com tres colunas nulas
- `T-02`: hex valido grava, vazio vira nulo, invalido responde 400, request sem token nao grava
- `T-03`: payload do orcamento certo contem foto marcada e caracteristica; nao contem dono, contrato, pagamento, rua nem preco; id inexistente nao devolve casa
- `T-04`: salvar e limpar as cores em Configuracoes e ve-las ao reabrir
- `T-05`: percorrer a pagina no browser com casa completa, casa vazia e cores gravadas

## Fontes determinantes

- `project/project-decisions.md` D-01, D-02, D-05 e D-06
- `topics/auth-and-security.md`: rota publica precisa de allowlist e teste negativo
- `product/06-design-system-direction.md`: tokens atuais em `src/index.css` e `tailwind.config.ts`
- `framework-libs/database/index.md`: migration em tabela existente, aditiva
- `framework-libs/security/index.md`: endpoint publico
- `framework-libs/design/index.md`: hierarquia da pagina e formulario
