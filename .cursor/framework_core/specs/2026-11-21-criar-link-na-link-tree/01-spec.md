# Spec — criar link na link tree

## Problema

A aba Redes cria a rede num select. Rede colada abre um modal que so pede a URL, porque a rede ja foi escolhida. A pagina publica deixa quem tem `EDIT_VENUE_SITE` arrastar e remover, mas nao criar. Lista vazia nao mostra container.

## Objetivos

- a aba Redes troca o select por um botao que abre o modal de rede e link
- a pagina publica cria, remove e muda a posicao para a mesma permissao que hoje liga `canReorder`
- sem link, essa pessoa ve "Ainda nao ha link cadastrado na sua link tree" e o botao
- visitante nao gerencia e o write recusa

## Fora de escopo

- schema, campo ou permissao nova
- reabrir o visual da aba, a pilula clara, a criacao pelo select ja entregue e a ordem/remocao ja entregues
- trocar o texto vazio da aba Redes
- redesenhar o card publico
- incluir `links` em `PUBLIC_ROUTES`
- o `PUT /venue/links/:id` do editor passar a aceitar `EDIT_VENUE_SITE`

## User stories ou cenarios principais

- na aba Redes vazia, a pessoa aperta "Cadastrar link", escolhe Instagram, cola a URL e a linha entra; "Salvar Alteracoes" grava
- em `/espaco/AR756/links`, logada com `EDIT_VENUE_SITE` e sem links, ve o container e cadastra; o card aparece na hora
- com links, a mesma pessoa cadastra outro, remove e arrasta sem voltar ao painel
- visitante ve os cards, sem botao, alca, lixeira ou container

## Criterios de aceite

- `R-01`: a aba Redes mostra o botao "Cadastrar link" e nao mostra o select "Escolher rede"
- `R-02`: o botao abre um modal para escolher a rede; rede de `PASTED_VENUE_LINK_KINDS` pede URL e so confirma com `checkVenueLinkUrl` verde; rede do sistema confirma sem campo de URL
- `R-03`: confirmar na aba acrescenta a linha no editor; a API so recebe a lista em "Salvar Alteracoes"
- `R-04`: tipo que ja esta nas linhas nao aparece no modal e um segundo confirmar nao duplica
- `R-05`: pagina publica com `canReorder` e zero links mostra o texto "Ainda nao ha link cadastrado na sua link tree" e o botao "Cadastrar link"
- `R-06`: com `canReorder` falso, a pagina nao mostra botao, alca, remover nem esse container; zero links continua sem lista
- `R-07`: com `canReorder` e links, o botao fica acima da lista; criar grava na hora e o card novo aparece sem "Salvar Alteracoes"
- `R-08`: `PUT /venue/links/:id/create` sem token responde 401; com token sem `EDIT_VENUE_SITE` responde 403 e nao grava
- `R-09`: create com URL que nao fica verde, ou com tipo que ja existe, responde 400 e nao grava
- `R-10`: create de rede do sistema sem destino responde 400 e nao grava
- `R-11`: `GET /venue/links/:id` sem a permissao nao traz `usedKinds`; com `canReorder` traz os kinds criados, inclusive o oculto
- `R-12`: arrastar e remover na publica continuam para `EDIT_VENUE_SITE`, com a alca so quando ha mais de um link

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: o write novo usa `loadEditable` e `canEditVenueSite`; o botao no front nao autoriza; `GET` segue publico, com usuario opcional
- erros e mensagens esperadas: 400 repete a mensagem de `checkVenueLinkUrl` na URL ruim; tipo repetido diz que a rede ja existe; sem destino usa `venueLinkSourceHint` ou "Esse link ainda nao tem destino."; o modal da publica permanece aberto com essa mensagem
- observabilidade minima: nenhuma; o status HTTP da rota existente basta para provar a recusa
- concorrencia, idempotencia ou retry: um create do mesmo tipo responde 400 e nao cria a segunda linha; sem fila, cache ou retry
- rollout, fallback ou degradacao: sem migration; rollback e tirar a rota e o botao; links ja gravados permanecem

## Casos de erro e borda obrigatorios

- caso: visitante ou conta sem `EDIT_VENUE_SITE` chama o create
  impacto: 401 ou 403, lista intacta, gestao invisivel
  cobertura esperada: `unitario` no use case e no markup da pagina
- caso: Instagram ja criado, ainda que oculto
  impacto: o modal nao oferece o tipo; o write responde 400
  cobertura esperada: `unitario` no `usedKinds` e no create
- caso: WhatsApp sem numero, ou mapa sem endereco, criado na publica
  impacto: 400, nenhuma linha nova, a pagina nao ganha um card invisivel
  cobertura esperada: `unitario` no use case
- caso: a gravacao na publica falha
  impacto: a lista mostrada nao muda e o modal mostra a mensagem
  cobertura esperada: `unitario` no cliente da pagina
- caso: nenhuma rede restante na aba
  impacto: o botao "Cadastrar link" fica desabilitado
  cobertura esperada: `unitario` no editor

## Impacto esperado

Quem edita o site passa a cadastrar o link no modal e, na pagina publica, sem voltar a Configuracoes. O visitante continua so lendo.

## Areas impactadas

- `art56_server_v3`: use case, controller, factory, rota e zod de `/venue/links`
- `eventhub-vista-dashboard`: `VenueLinkEditor`, `VenueLinks`, `venue.service`
- docs: `project/api-endpoints.md` e `topics/public-pages-and-branding.md` na task que mudar o comportamento

## Restricoes e cuidados

- as duas copias de `venue-link` (front `src/lib/venue-link.ts`, back `src/functions/venue-link.ts`) continuam a fonte de `createVenueLink` e `checkVenueLinkUrl`; o write authoritative e o do back
- nao criar permissao, enum ou backfill
- rota de leitura permanece sem `ensureAuthenticate`

## Dependencias

- `EDIT_VENUE_SITE` e os writes `order` e `hide` ja existem
- `T-03` depende do contrato de `T-01`; `T-02` nao

## Mapeamento leve requisito -> task -> prova

- `R-08`, `R-09`, `R-10`, `R-11` -> `T-01` -> `unitario`
- `R-01`, `R-02`, `R-03`, `R-04` -> `T-02` -> `unitario`
- `R-05`, `R-06`, `R-07`, `R-12` -> `T-03` -> `unitario`

## Perguntas em aberto

Nenhuma bloqueante. Premissas e o risco de cada uma estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
