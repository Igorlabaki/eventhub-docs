# Spec — Link publico das regras do espaco

## Problema

Quem recebe o material do espaco nao tem endereco para ler as regras. Elas existem no painel, em `/venue/:id/rules`, e `GET /venue-rule/list/:venueId` exige login e `VIEW_VENUE_RULES`.

## Objetivos

A equipe copia, na tela Regras, um endereco publico daquele espaco. Sem login, a pagina mostra as regras cadastradas, na marca do espaco. O Link do evento abre a mesma pagina.

## Fora de escopo

- mudar o que o cadastro grava, a ordem ou as permissoes de criar, alterar e remover
- colocar regras no corpo do orcamento, no contrato, no e-mail ou no site da organizacao
- regras no nivel da organizacao
- coluna, tabela ou migration
- corrigir as outras rotas publicas que faltam nas allowlists do frontend

## User stories ou cenarios principais

- operador abre Regras, copia o endereco e outra pessoa abre sem login
- visitante ve as regras na ordem do cadastro, com a marca do espaco
- espaco sem regras abre a pagina e diz que ainda nao ha regras
- no Link do evento, o botao Regras do espaco abre essa pagina

## Criterios de aceite

- `R-01`: `GET /venue-rule/public/:venueId`, sem token, responde 200 com as regras daquele venue, na ordem `position` ascendente e `createdAt` ascendente
- `R-02`: cada item publico tem so `id`, `title`, `text` e `position`
- `R-03`: venue inexistente responde 404 e nao devolve regra de outro venue
- `R-04`: venue existente sem regras responde 200 com `data: []`
- `R-05`: `GET /venue-rule/list/:venueId`, `POST /venue-rule/create`, `PUT /venue-rule/update` e `DELETE /venue-rule/delete/:ruleId` sem token continuam 401 e nao gravam
- `R-06`: `/venue/:id/rules/view`, sem login, mostra a casca publica do espaco e as regras na ordem da API; titulo ausente nao esconde o texto
- `R-07`: venue sem regras mostra "Ainda não há regras deste espaço." dentro da casca
- `R-08`: venue inexistente nao mostra regras nem marca de outro espaco
- `R-09`: ao sair de `/venue/:id/rules/view`, a aba volta ao titulo EventHub
- `R-10`: a tela Regras mostra o endereco publico e Copiar para quem ja abre essa tela; se a area de transferencia falhar, o campo continua selecionavel
- `R-11`: no Link do evento, quando o orcamento tem venue, existe o botao "Regras do espaço" para `/venue/:venueId/rules/view`, e os outros cinco destinos permanecem
- `R-12`: `/venue/:id/rules/view` esta nas allowlists publicas do frontend, e um 401 nessa pagina nao redireciona para o login

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a leitura publica e intencional e so daquele `venueId`; a permissao da tela de copiar nao libera gravacao; a gravacao continua no venue da regra
- erros e mensagens esperadas: 400 para `venueId` vazio, 404 para venue ausente, 200 com lista vazia, 401 nas rotas que ja exigem login
- observabilidade minima: sem dashboard novo; falha nao registra o texto da regra
- concorrencia, idempotencia ou retry: leitura; duas consultas simultaneas devolvem o que estiver gravado
- rollout, fallback ou degradacao: rota nova, sem migration; tirar a rota e a pagina desfaz a publicacao e o cadastro permanece

## Casos de erro e borda obrigatorios

- caso: venue sem regras
  impacto: a pagina nao pode parecer quebrada
  cobertura esperada: use case e pagina
- caso: regra sem titulo
  impacto: o texto precisa aparecer
  cobertura esperada: pagina
- caso: venue de outro id
  impacto: nao misturar regras nem marca
  cobertura esperada: use case e pagina
- caso: token ausente na gravacao e na listagem autenticada
  impacto: a publicacao nao abre create, update, delete nem `GET /list`
  cobertura esperada: teste negativo da API
- caso: texto com marcacao
  impacto: a pagina nao interpreta o texto como HTML
  cobertura esperada: pagina
- caso: espaco sem cor, logo ou descricao
  impacto: topo, aba e rodape degradam como nas listas publicas
  cobertura esperada: casca ja existente
- caso: copiar sem permissao do navegador
  impacto: o endereco continua no campo
  cobertura esperada: tela Regras

## Impacto esperado

O espaco passa a ter um endereco estavel das regras. O cadastro e as permissoes de gravacao nao mudam.

## Areas impactadas

- `backend`: rota publica, use case e teste em `venue-rule`
- `frontend`: pagina, allowlists, copia na tela Regras e botao no Link do evento
- produto: uma frase na jornada de captar, na task da pagina

## Restricoes e cuidados

- `GET /venue/getById` ja e publico e so serve a marca; esta feature nao alarga o retorno dele
- nao reutilizar `ListVenueRuleUseCase`: ele autoriza e devolve a linha inteira do Prisma
- registrar a rota publica antes de `ensureAuthenticate` no router de `venue-rule`
- nao ler nem versionar valores de `.env`

## Dependencias

- `VenueRule` ja persiste titulo opcional, texto e posicao
- a casca `PublicVenueListShell` ja aplica a marca do espaco
- o Link do evento ja lista cinco destinos do orcamento

## Mapeamento leve requisito -> task -> prova

- `R-01` a `R-05` -> `T-01` -> unitario
- `R-06` a `R-10` e `R-12` -> `T-02` -> unitario
- `R-11` -> `T-03` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma; `T-01` a `T-03` escritas
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
