# Spec — Apresentacao publica do espaco

## Problema

Quem quer mostrar a casa antes de um evento so tem o link do orcamento. Esse link pede data, convidados e total. Nao existe uma pagina da casa sozinha.

## Objetivos

- uma pagina publica do espaco, no desenho do orcamento, sem evento fechado
- a sidebar, secao A casa, continua abrindo esse endereco em outra aba
- o orcamento publico permanece como esta

## Fora de escopo

- alterar `/proposal/:id/view`, inclusive proposta, total, Alterar orcamento e Alterar servicos
- total fechado, locacao calculada, horas extras, desconto e referencia por convidado
- preco, tipo de cobranca ou minimo de pessoas na lista Serviços disponíveis
- regras do espaco, rua, numero, CEP e proprietarios escritos na pagina
- permissao nova, coluna nova e migration
- reordenar ou trocar foto nesta pagina

## User stories ou cenarios principais

- Visitante abre `/venue/:id/apresentacao` sem login e percorre a casa ate o mapa.
- Pessoa do painel com acesso ao Site clica em Apresentação e o link abre em outra aba.
- Espaco sem foto, sem servico ou sem WhatsApp abre a pagina com as secoes que existem.

## Criterios de aceite

- `R-01`: `GET /venue/presentation/:venueId` nao exige login e devolve so nome, descricao, logo, tres cores, redes, video, WhatsApp, bairro, cidade, estado, rua e numero para o mapa, capacidade, pernoite, check-in, check-out, minimo de noites, abertura, fechamento, fotos com `isShowOnProposal`, caracteristicas no formato da proposta, servicos com `id`, `name`, `description` e `imageUrl`, e o preco do modelo ativo mais o minimo
- `R-02`: a mesma resposta nao inclui e-mail, CEP, complemento, dono, organizacao, contrato, pagamento, preco de servico, precos dos modelos que nao estao ativos, `canReorder` nem catalogo de fotos
- `R-03`: venue inexistente responde 404 e nao devolve dado de outro espaco
- `R-04`: `/venue/:id/apresentacao` abre sem `ProtectedRoute`, esta nas duas `PUBLIC_ROUTES`, e o titulo da aba usa `venueTabTitle`
- `R-05`: a ordem visivel e logo e descricao, video ou capa, uma foto, Conheça nosso espaço, Serviços disponíveis, grid, Seu investimento, mapa e rodape
- `R-06`: com video, a foto do terceiro bloco e a primeira foto e o grid sao as demais; sem video, a capa e o hero, a foto seguinte ocupa o terceiro bloco e o restante vai para o grid
- `R-07`: Conheça nosso espaço repete caracteristicas, o `?` e Agendar uma visita; Serviços disponíveis lista o catalogo sem preco e sem Alterar servicos
- `R-08`: Seu investimento mostra o rotulo do modelo ativo, o valor desse modelo, o preco minimo quando for maior que zero, e Conversar com nossa equipe; nao mostra total
- `R-09`: secao sem dado nao aparece; preco minimo 0 ou vazio nao aparece; WhatsApp vazio esconde os dois botoes
- `R-10`: o texto do mapa e bairro e cidade; rua e numero nao aparecem escritos
- `R-11`: `/proposal/:id/view` conserva proposta, total e os botoes de alterar
- `R-12`: o item Apresentação em A casa abre `https://event-hub-dashboard.vercel.app/venue/{id}/apresentacao` em outra aba para quem tem `VIEW_VENUE_SITES`, e nao fica marcado como pagina atual

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: leitura publica por id do venue, no mesmo padrao de `/venue-rule/public/:venueId`; gravacao do espaco continua autenticada; sem permissao nova
- erros e mensagens esperadas: 404 sem corpo de outro venue; falha de rede nao mantem dados do espaco anterior
- observabilidade minima: nenhuma metrica nova; 404 e secoes omitidas sao a prova
- concorrencia, idempotencia ou retry: leitura unica, sem fila, cache ou retry proprio
- rollout, fallback ou degradacao: sem coluna nova; a sidebar ja aponta para o endereco antes da pagina existir

## Casos de erro e borda obrigatorios

- caso: nenhuma foto marcada para o orcamento
  impacto: pagina segue com logo e descricao, sem hero, sem foto solta e sem grid
  cobertura esperada: `T-02`
- caso: uma foto so e sem video
  impacto: essa foto e o hero; o terceiro bloco e o grid ficam de fora
  cobertura esperada: `T-02`
- caso: casa sem logo
  impacto: fallback EventHub, o mesmo da proposta, so depois que o payload chegou
  cobertura esperada: `T-02`
- caso: catalogo de servicos vazio
  impacto: Serviços disponíveis nao aparece
  cobertura esperada: `T-01` e `T-02`
- caso: modelo sem valor, ou minimo igual a zero
  impacto: a linha correspondente sai; a secao sai se nao restar valor nem WhatsApp
  cobertura esperada: `T-01` e `T-02`

## Impacto esperado

O painel ganha um destino real para o item que ja esta na sidebar. O cliente recebe um link da casa sem total. O orcamento de um evento nao muda.

## Areas impactadas

- `art56_server_v3`: rota publica em `router/venue.ts`, use case e mapper novos
- `eventhub-vista-dashboard`: pagina, rota, as duas allowlists
- docs: `project/api-endpoints.md`, `project/frontend-map.md`, `topics/public-pages-and-branding.md`

## Restricoes e cuidados

- dinheiro continua `Float`, como o restante do cadastro (`project-decisions.md#D-07`)
- a autorizacao desta leitura e publica de proposito (`project-decisions.md#D-05`)
- fotos sao as de `isShowOnProposal`, as mesmas do orcamento, nao as de `isShowOnOrganization`
- rua e numero viajam no JSON so para montar o iframe, como a proposta ja faz

## Dependencias

- apresentacao publica do orcamento, video, cores, mapa e caracteristicas ja existem
- servicos e modelo de preco ja existem no cadastro
- `R-12` ja esta no codigo (`sidebar-nav-model.ts`, `VenueNav.tsx`, `public-venue-presentation.ts`)

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-01` -> unitario
- `R-03` -> `T-01` -> unitario
- `R-04` -> `T-02` -> unitario
- `R-05` -> `T-02` -> unitario
- `R-06` -> `T-02` -> unitario
- `R-07` -> `T-02` -> unitario
- `R-08` -> `T-02` -> unitario
- `R-09` -> `T-02` -> unitario
- `R-10` -> `T-02` -> unitario
- `R-11` -> `T-02` -> unitario
- `R-12` -> ja entregue -> unitario existente da sidebar

## Perguntas em aberto

- nenhuma bloqueante; premissas em `02-clarify.md`

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`

## Base documental

- `task-requests/apresentacao-publica-do-espaco-request.md`
- `topics/public-pages-and-branding.md#Marca do espaco` e `#Orcamento publico`
- `project/api-endpoints.md` (`GET /proposal/presentation/:proposalId`, `GET /venue-rule/public/:venueId`)
- `project-decisions.md#D-05` e `#D-07`
- `to-proposal-presentation.ts`; fotos do orcamento filtradas por `isShowOnProposal` em `proposal-in-prisma-repository.ts`
- `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- `framework-libs/patterns/index.md#Decidir a estrutura de uma solucao nova`
- `framework-libs/design/index.md#Criar pagina ou tela nova`
- `framework-libs/react/index.md#Criacao de pagina React`
