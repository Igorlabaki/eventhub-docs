# Spec — KPIs, filtros, paginas e leitura na lista de notificacoes

## Problema

A pagina de notificacoes pede `GET /notification/list/:venueId` e recebe no maximo 25 linhas. A busca por texto roda no navegador, so nesse recorte. Nao ha cards nem paginas. `isRead` nasce falso e nenhuma rota grava verdadeiro, entao o selo Novo permanece depois de abrir o orcamento.

## Objetivos

- filtro, pagina de dez e os quatro cards saem do backend, no conjunto filtrado
- abrir o orcamento no painel marca como lidas as notificacoes daquele orcamento
- Marcar todas como lidas zera as nao lidas do espaco
- a leitura publica do orcamento nao muda `isRead`

## Fora de escopo

- valor em reais extraido do texto da notificacao
- um card por tipo do enum
- schema, coluna ou indice novo
- colocar `ensureAuthenticate` na listagem que hoje e aberta (`project-decisions.md#D-05`)
- marcar como lida ao abrir o link publico, a apresentacao ou o link do evento

## User stories ou cenarios principais

- quem abre Notificacoes filtra por texto, tipo e lida/nao lida, ve os quatro cards desse conjunto e avanca de dez em dez
- quem abre o orcamento no painel, por qualquer atalho, ve o selo Novo sumir nas notificacoes daquele orcamento
- quem clica em Marcar todas como lidas limpa o espaco inteiro, mesmo com filtro ou pagina ativos
- o cliente no link publico abre o orcamento e as notificacoes do espaco continuam nao lidas

## Criterios de aceite

- `R-01`: com `page`, a lista devolve no maximo 10 linhas, `pagination.total` e o total do filtro, e a ordem e `createdAt` descendente com desempate por `id` descendente
- `R-02`: `q` restringe `content`; `type` so aceita o enum; `isRead` so aceita lida ou nao lida; `summary=true` sem `page`, ou valor fora do enum, responde 400
- `R-03`: sem `page`, a resposta continua com no maximo 25 linhas, sem `pagination` e sem `summary`
- `R-04`: `summary` traz `unread`, `last7Days`, `last30Days` e `newProposals`, contados no filtro inteiro, sem `skip` e sem `take`
- `R-05`: `last7Days` e `last30Days` usam `createdAt` contra o instante do servidor menos 7 ou 30 dias de 24 horas; `newProposals` e `type = PROPOSAL` dentro da janela de 30 dias
- `R-06`: depois que o detalhe do orcamento carrega no painel, toda notificacao nao lida daquele `proposalId` fica com `isRead` verdadeiro
- `R-07`: `GET /proposal/byId/:proposalId` nao grava `isRead`, com ou sem token
- `R-08`: Marcar todas como lidas grava `isRead` verdadeiro em todas as nao lidas do espaco e ignora pagina, busca e filtro
- `R-09`: as duas gravacoes exigem JWT valido e uma `UserVenuePermission` naquele espaco; sem token responde 401, sem permissao 403, orcamento ausente 404
- `R-10`: repetir a gravacao nao altera linha que ja esta lida
- `R-11`: a pagina de notificacoes envia busca, tipo, lida/nao lida, `page` e `summary=true`, e nao filtra a lista no navegador
- `R-12`: o selo Novo so aparece com `isRead` falso; depois de marcar todas, a lista recarregada nao mostra o selo nas linhas do espaco
- `R-13`: `ProposalDetails` chama a marcacao depois de carregar o orcamento; `ProposalEventLink` e a apresentacao publica nao chamam

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a listagem segue aberta, como hoje; so a gravacao de lida exige sessao e vinculo com o espaco. A permissao da tela nao substitui a checagem no backend
- erros e mensagens esperadas: 400 na query invalida; 401 sem token nas gravacoes; 403 sem vinculo com o espaco; 404 se o orcamento nao existe. Falha ao marcar lida no detalhe nao impede ver o orcamento
- observabilidade minima: sem log do `content`. A prova e o teste e a tela
- concorrencia, idempotencia ou retry: `updateMany` so nas linhas com `isRead` falso. Dois cliques seguidos gravam uma vez
- rollout, fallback ou degradacao: sem `page`, o chamador antigo continua recebendo ate 25 linhas. Sem migration

## Casos de erro e borda obrigatorios

- caso: filtro sem linhas e `summary=true`
  impacto: lista vazia e os quatro numeros em 0
  cobertura esperada: unitario
- caso: `type` diferente de `PROPOSAL`
  impacto: `newProposals` e 0
  cobertura esperada: unitario
- caso: filtro `isRead=true`
  impacto: `unread` e 0
  cobertura esperada: unitario
- caso: notificacao sem `proposalId`
  impacto: abrir um orcamento nao a marca; so o botao de marcar todas
  cobertura esperada: unitario
- caso: varias notificacoes do mesmo orcamento
  impacto: abrir o detalhe marca todas as nao lidas daquele `proposalId` e nao mexe em outro orcamento
  cobertura esperada: unitario
- caso: link publico ou `GET /proposal/byId`
  impacto: `isRead` nao muda
  cobertura esperada: unitario no backend e ausencia da chamada nas paginas publicas
- caso: usuario autenticado sem permissao naquele espaco
  impacto: 403 e nenhuma linha muda
  cobertura esperada: unitario

## Impacto esperado

A caixa de notificacoes passa a paginar e a resumir no servidor. O selo Novo acompanha a abertura do orcamento no painel e o botao de marcar todas.

## Areas impactadas

- `backend`: listagem de notificacao; duas gravacoes de lida
- `frontend`: `VenueNotifications` e `ProposalDetails`
- `docs/referencias/API_CONTRACTS.md`: secao Notification

## Restricoes e cuidados

- nao contar os cards nas dez linhas da pagina
- nao gravar `isRead` dentro de `GetProposalByIdUseCase`
- `createdAt` e instante; a janela nao usa wall-clock de agenda (`project-decisions.md#D-06`)
- a query da lista continua no `venueId` do path

## Dependencias

- padrao de pagina e `summary` de `specs/2026-11-05-kpis-filtros-lista-contatos/03-design.md#Contratos e dados`
- `isRead`, `type` e `createdAt` ja existem em `Notification`

## Mapeamento leve requisito -> task -> prova

- `R-01` `R-02` `R-03` `R-04` `R-05` -> `T-01` -> unitario
- `R-06` `R-07` `R-08` `R-09` `R-10` -> `T-02` -> unitario
- `R-11` `R-12` -> `T-03` -> browser
- `R-06` `R-13` -> `T-04` -> browser

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma no codigo
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
