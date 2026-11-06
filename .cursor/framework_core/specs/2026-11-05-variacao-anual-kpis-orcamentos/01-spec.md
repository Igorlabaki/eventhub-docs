# Spec — Variacao anual dos KPIs na lista de orcamentos

## Problema

Na pagina de orcamentos, Total de orcamentos, Valor no mes e Conversao mostram o periodo selecionado. O canto do card nao diz se aquele resultado esta melhor ou pior que o mesmo periodo do ano anterior.

## Objetivos

Quem olha os tres cards le, no canto superior direito de cada um, o percentual inteiro de alta ou queda contra o mesmo periodo do ano anterior. O numero principal de cada card permanece o que ja e.

## Fora de escopo

- comparar com o mes anterior, ou so ate o dia de hoje dentro do mes corrente
- tooltip ou texto com o valor absoluto do ano anterior
- tirar o sparkline ou mudar a serie diaria
- mudar a formula de total, valor no mes, conversao ou `amountMax`
- endpoint novo de KPI, coluna nova ou migration
- a pagina de eventos e as paginas publicas
- fechar a lacuna de ownership do espaco

## User stories ou cenarios principais

- Quem abre novembro ve, em cada card, quanto aquele numero esta acima ou abaixo de novembro do ano anterior.
- Quem escolhe um dia ve a variacao daquele dia contra o mesmo dia do ano anterior.
- Quem nao teve movimento no ano anterior ve um traco, e o numero atual do card continua visivel.

## Criterios de aceite

- `R-01`: com `summary`, `change.total`, `change.monthAmount` e `change.conversionRate` sao o inteiro de `Math.round(((atual - anterior) / anterior) * 100)`, ou `null` quando o anterior e 0
- `R-02`: o periodo anterior e o mesmo mes, e o mesmo dia quando houver dia, um ano antes, em wall-clock; total e conversao usam busca, status e `minAmount`; `monthAmount` soma so o aprovado da janela e ignora esses filtros
- `R-03`: anterior 0, dia 29 de fevereiro sem par, dia invalido ou ausencia de mes deixam os tres `change` em `null`; os numeros atuais do `summary` nao mudam
- `R-04`: sem `summary` a chave nao vem; nao nasce endpoint; nao ha schema novo; a lista de eventos nao pede nem exibe `change`
- `R-05`: cada card mostra o percentual no canto superior direito, com sinal, cor e icone; positivo verde, negativo vermelho, zero neutro; o sparkline e o numero principal permanecem
- `R-06`: enquanto `summary` ou `change` nao chegou, o canto fica vazio; a tela nao calcula o percentual
- `R-07`: `null` aparece como traco, sem seta; o nome acessivel diz acima, abaixo, igual ou sem comparacao com o ano anterior
- `R-08`: `GET /proposal/list` sem JWT continua 401; espaco ausente continua 404

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a rota segue com JWT e `venueId`; esta feature nao amplia o que a listagem devolve alem do percentual
- erros e mensagens esperadas: dia invalido continua a lista vazia; o canto em traco nao e mensagem de erro
- observabilidade minima: sem metrica nova; a prova e o teste da listagem e o canto na tela
- concorrencia, idempotencia ou retry: leitura; cada campo de `change` e independente
- rollout, fallback ou degradacao: backend antes da tela; tela antiga ignora `change`; tela nova sem o campo deixa o canto vazio

## Casos de erro e borda obrigatorios

- caso: os dois anos com movimento, inclusive 21,5% e -10,5%
  impacto: o inteiro visivel tem de bater com `Math.round`, e `Math.round(-10.5)` e -10
  cobertura esperada: unitario em `T-01`
- caso: anterior 0 num KPI e positivo no outro
  impacto: so o KPI sem base fica `null`
  cobertura esperada: unitario em `T-01`
- caso: busca ou status zera o total do ano anterior e o Valor no mes daquele ano continua positivo
  impacto: o canto do total fica em traco e o do valor mostra percentual
  cobertura esperada: unitario em `T-01` e a tela em `T-02`
- caso: `summary` ainda nulo
  impacto: o canto nao pode mostrar 0% nem traco
  cobertura esperada: tela em `T-02`

## Impacto esperado

O `summary` de `GET /proposal/list` passa a trazer `change`. A pagina de orcamentos desenha esse campo no canto dos tres cards.

## Areas impactadas

- `backend`: use case da listagem e o texto de `docs/referencias/API_CONTRACTS.md#GET /proposal/list`
- `frontend`: tipo `ProposalListSummary` e `ProposalListSummaryCards`
- a store ja repassa `response.data.summary`; o servico nao mapeia campo de KPI

## Restricoes e cuidados

- nao recalcular o percentual no navegador
- nao comparar dia selecionado com o mes inteiro do ano anterior
- a data do evento continua em wall-clock (`project-decisions.md#D-06`)
- a segunda leitura usa a mesma janela e o indice `(venueId, startDate)` que a listagem ja tem
- atualizar o contrato em `docs/` na mesma entrega do backend (`project-decisions.md#D-08`)

## Dependencias

- `summary` da listagem paginada (`specs/2026-11-05-lista-painel-orcamentos/`)
- Valor no mes so do aprovado (`specs/2026-11-05-filtros-status-valor-orcamentos/`)
- nenhum schema novo

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-01` -> unitario
- `R-03` -> `T-01` -> unitario
- `R-04` -> `T-01` -> unitario
- `R-08` -> `T-01` -> unitario
- `R-05` -> `T-02` -> tela de orcamentos
- `R-06` -> `T-02` -> tela de orcamentos
- `R-07` -> `T-02` -> tela de orcamentos

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md#Premissas assumidas`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `executar task`
- entrada publica recomendada: `fw:run`
