# Spec — Total estimado do orcamento no painel

## Problema

Em `/venue/:id/budgets` (criar) e `/proposal/:id/edit` (editar), quem monta o orcamento por pessoa so sabe o total quando digita o campo Total. Com o campo vazio, o backend calcula na gravacao e o valor so aparece depois de salvar. Na edicao, o backend recalcula pela tabela da casa apenas quando o Total enviado e igual ao salvo, e a tela nao mostra isso.

O calculo hoje vive em tres lugares: `create-proposal-per-person` (inline, wall-clock), `update-proposal-per-person` (`adjustProposalUnitPrice`, fuso local e temporada que nao vira o ano) e `recalculate-public-proposal` (wall-clock, funcoes privadas).

## Objetivos

Com data, horarios e convidados preenchidos, o formulario do painel mostra `Total estimado` com espaco, horas extras, servicos e aviso de preco minimo. O valor vem de `POST /proposal/quote`, que nao grava e usa a mesma conta da gravacao. Criar, editar e recalcular no link passam a usar uma unica funcao de conta.

## Fora de escopo

- formularios publicos (`ClientPerPersonProposalForm`, `ClientPerDayProposalForm`) e rota publica de cotacao
- orcamento por diaria (`PerDayProposalForm`, `update-proposal-per-day`, `create-proposal-per-day`)
- mudar regra de preco, sazonalidade, meta ou preco minimo (inclusive a soma `minimo + servicos`)
- modelo `TIERED` e espacos sem preco unitario do modelo
- preencher o Total sem acao do usuario
- schema, migration e politica monetaria (D-07)
- `tr-01` do lote (valor por pessoa na edicao)

## User stories ou cenarios principais

- A equipe cria um orcamento, escolhe data, horario, convidados e servicos, e ve o total estimado mudar a cada ajuste antes de salvar.
- A equipe edita um orcamento, muda convidados, ve a estimativa nova e entende que salvar sem mexer no Total grava esse valor.
- A equipe quer partir da estimativa, clica `Usar este valor` e ajusta o Total a mao.

## Criterios de aceite

- `R-01`: `POST /proposal/quote` sem token responde 401; com token sem permissao `VIEW_VENUE_PROPOSALS` nem `EDIT_VENUE_INFO` no `venueId` responde 403. Nenhum dos casos grava.
- `R-02`: Corpo valido responde 200 com `data` contendo somente `basePrice`, `extraHoursQty`, `extraHourPrice`, `totalAmountService`, `totalAmount` e `minimumApplied`.
- `R-03`: Para a mesma entrada, o `totalAmount` da cotacao e igual ao que `createPerPerson` grava com Total vazio, em `PER_PERSON` e `PER_PERSON_HOUR` (com e sem receita no mes), com sazonalidade, meta, horas extras e preco minimo.
- `R-04`: Tipo `BARTER` responde todos os valores 0 e `minimumApplied: false`.
- `R-05`: Modelo diferente de `PER_PERSON`/`PER_PERSON_HOUR`, ou preco unitario ausente, responde 400 "Este espaço não calcula o orçamento sozinho. Informe o Total."
- `R-06`: Servico por hora sem horas, com horas acima da duracao do evento ou servico de outro espaco responde 400 com a mensagem que a gravacao ja usa.
- `R-07`: O recalculo publico (`PUT /proposal/presentation/:proposalId/recalculate`) grava os mesmos valores de antes; os testes atuais continuam verdes.
- `R-08`: Editar com Total igual ao salvo grava o mesmo `totalAmount` que a cotacao devolve para os valores do formulario.
- `R-09`: Nos dois formularios, com data, inicio, fim e convidados >= 1, aparece o bloco `Total estimado` com Espaço, Horas extras (so se > 0), Serviços e Total, atualizado ~400 ms depois da ultima mudanca, sem gravar.
- `R-10`: Com algum desses quatro campos vazio ou invalido, o bloco mostra `—` e nenhuma cotacao e pedida.
- `R-11`: Com `minimumApplied`, o bloco mostra "Preço mínimo do espaço aplicado".
- `R-12`: `Usar este valor` preenche o campo Total com o total estimado. Substituido em 2026-11-10 pelo campo `Desconto (%)` (`specs/2026-11-10-desconto-percentual-orcamento`).
- `R-13`: Erro da cotacao aparece no bloco com a mensagem do backend (ou "Não foi possível calcular agora."); o botao de salvar continua habilitado.
- `R-14`: Na edicao, quando o Total do campo e igual ao salvo e a estimativa difere dele, o bloco mostra "Ao salvar sem mudar o Total, o valor passa para R$ X."
- `R-15`: Na criacao com Total vazio, o texto ao lado do Total mostra `R$ X / pessoa (estimado)` a partir do total estimado.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: `ensureAuthenticate` na rota e autorizador por espaco no backend (D-05); `ProtectedRoute` nao basta.
- erros e mensagens esperadas: 400 com texto de pessoa; o bloco nunca trava o formulario.
- observabilidade minima: `console.error` na negacao do autorizador, como `ServiceAuthorizer`; sem metrica nova.
- concorrencia, idempotencia ou retry: cotacao e leitura pura; respostas fora de ordem resolvidas pela chave do React Query; `retry: false`.
- rollout, fallback ou degradacao: sem flag. Sem resposta, o formulario funciona como hoje.

## Casos de erro e borda obrigatorios

- caso: digitacao rapida em convidados
  impacto: varias cotacoes e resposta velha sobrescrevendo a nova
  cobertura esperada: debounce de 400 ms e chave do `useQuery` com a entrada
- caso: temporada de dezembro a janeiro com evento em janeiro
  impacto: `adjustProposalUnitPrice` nao aplica a taxa; wall-clock aplica
  cobertura esperada: teste do update depois de `T-03`; mudanca de valor intencional e registrada
- caso: horario de fim antes do inicio
  impacto: `transformDate` leva o fim ao dia seguinte e a duracao cresce
  cobertura esperada: a cotacao segue `transformDate`, igual a gravacao; a validacao do formulario de criar continua
- caso: convidados acima de `maxGuest`
  impacto: a gravacao recusa pelo formulario, nao pelo backend
  cobertura esperada: a cotacao calcula normalmente
- caso: espaco `TIERED` ou sem preco unitario
  impacto: nao ha conta
  cobertura esperada: `R-05`; bloco mostra a mensagem
- caso: total abaixo do minimo
  impacto: espaco vira o minimo e horas extras saem
  cobertura esperada: `R-11` e teste da funcao

## Impacto esperado

A equipe ve o valor antes de salvar e as tres gravacoes calculam igual. O link publico nao muda de comportamento.

## Areas impactadas

- `backend`: `src/functions/` (conta compartilhada), rota, Zod, autorizador, use case e controller de cotacao; create e update por pessoa; recalculo publico
- `frontend`: `proposal.service.ts`, hook de cotacao, componente do bloco, `PerPersonProposalForm.tsx`, `ProposalEdit.tsx`, `per-person-amount.ts`

## Restricoes e cuidados

- D-02: router -> controller/factory -> use case -> repository
- D-05: autorizacao no backend, com teste negativo
- D-06: datas por `transformDate` e helpers `wallClock*`
- D-07: valores continuam em Float; sem arredondamento novo
- nao criar terceira abordagem de estado no frontend (React Query ja existe)
- nao ler nem versionar `.env`

## Dependencias

- `quoteServiceLines`, `serviceHoursMap`, `assertChosenServiceHours`, `sumServiceQuote`
- `serviceRepository.listForQuote`, `proposalRepository.monthlyRevenueAnalysis`, `goalRepository.findByVenueAndRevenue`
- `PrismaUserVenuePermissionRepository.getUserVenuePermission`
- pacote `use-debounce` e `@tanstack/react-query` no dashboard

## Mapeamento leve requisito -> task -> prova

- `R-07` -> `T-01` -> vitest do recalculo publico e da funcao
- `R-01`, `R-02`, `R-04`, `R-05`, `R-06` -> `T-02` -> vitest do use case, autorizador e controller
- `R-03`, `R-08` -> `T-03` -> vitest de create e update comparando com a funcao
- `R-09`, `R-10`, `R-11`, `R-12`, `R-13`, `R-15` -> `T-04` -> vitest do montador de entrada e browser na criacao
- `R-14` -> `T-05` -> browser na edicao

## Perguntas em aberto

Nenhuma bloqueante. Premissas e risco de cada uma em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao` (opcional com `spec-driven/spec-repo-split-prompt.md`, backend antes do frontend)
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
