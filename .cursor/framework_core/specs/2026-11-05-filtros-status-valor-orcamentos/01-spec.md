# Spec — Filtros de status e valor na lista de orcamentos

## Problema

Na pagina de orcamentos, busca, copiar o link e dia dividem a mesma faixa, e os cards entram logo abaixo. Nao ha filtro de status nem de valor. O Valor no mes soma o `totalAmount` de Aberto e Fechado no intervalo.

## Objetivos

Quem filtra orcamentos escolhe status e arrasta o valor a partir do preco minimo do espaco, com os cards inteiros abaixo dos filtros. O Valor no mes mostra so a soma do que virou evento naquele mes ou dia.

## Fora de escopo

- visual ou contrato novo na pagina de eventos, alem de ela continuar sem `minAmount`
- status alem de Aberto e Fechado, coluna nova ou migration
- preco minimo por periodo como piso do arraste
- mudar a formula de conversao ou o Total de orcamentos para contar so evento
- faixa com dois pontos no arraste
- relatorio anual, paginas publicas e `Float` de dinheiro (`project-decisions.md#D-07`)
- fechar a lacuna de ownership do espaco

## User stories ou cenarios principais

- Quem gerencia orcamentos filtra Aberto ou Fechado e arrasta o valor minimo; a tabela e o total da pagina acompanham o corte.
- Quem olha o Valor no mes le o que ja virou evento, mesmo com a tabela em Aberto ou com o arraste acima do piso.

## Criterios de aceite

- `R-01`: `minAmount` ausente nao filtra valor; presente exige `totalAmount` maior ou igual a ele no filtro inteiro, nao so na pagina
- `R-02`: `minAmount` vazio e ignorado; nao numerico ou negativo responde 400
- `R-03`: `summary.monthAmount` e `summary.daily.amount` somam `totalAmount` so com `approved` verdadeiro, na janela de mes ou dia, e ignoram busca, status e `minAmount`
- `R-04`: `summary.total` e `summary.conversionRate` seguem mes, dia, busca, status e `minAmount`, e nao a pagina
- `R-05`: `summary.amountMax` e o maior `totalAmount` da janela de mes ou dia, ignorando busca, status e `minAmount`; e 0 se nao houver linha
- `R-06`: status e o arraste ficam numa faixa abaixo dos filtros atuais; os tres cards mantem altura e ficam abaixo dessa faixa
- `R-07`: o arraste comeca no preco minimo padrao do espaco, ou em 0 se ele nao existir; no piso nao envia `minAmount`; ao soltar acima do piso envia `minAmount` e volta a pagina para 1
- `R-08`: o status envia `approved` ausente, `false` ou `true`, e volta a pagina para 1
- `R-09`: a tela exibe `summary.monthAmount` e nao soma as linhas da pagina
- `R-10`: a lista de eventos nao envia `minAmount` e continua pedindo `approved=true`
- `R-11`: `GET /proposal/list` sem JWT continua 401; espaco ausente continua 404

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a rota continua com `ensureAuthenticate` e filtra por `venueId`; esta feature nao passa a checar se o usuario pertence ao espaco
- erros e mensagens esperadas: query invalida responde 400; espaco ausente continua 404
- observabilidade minima: sem metrica nova; a prova e o teste da listagem e a tela de orcamentos
- concorrencia, idempotencia ou retry: nao se aplica; a lista e leitura
- rollout, fallback ou degradacao: `minAmount` e `amountMax` sao opcionais; cliente antigo ignora `amountMax`

## Casos de erro e borda obrigatorios

- caso: orcamento abaixo do preco minimo, com o arraste ainda no piso
  impacto: a linha continua na tabela, porque o piso nao envia `minAmount`
  cobertura esperada: `T-01` e `T-02`
- caso: status Aberto, ou arraste acima do piso, com eventos no mes
  impacto: Valor no mes nao zera
  cobertura esperada: `T-01`
- caso: mes sem orcamento aprovado
  impacto: Valor no mes 0, mesmo com Aberto na tabela
  cobertura esperada: `T-01`
- caso: dia selecionado
  impacto: Valor no mes e `amountMax` usam esse dia, nao o mes inteiro
  cobertura esperada: `T-01`
- caso: `amountMax` menor ou igual ao piso
  impacto: o arraste nao se move e nao envia `minAmount`
  cobertura esperada: `T-02`
- caso: trocar mes, ano ou dia com o arraste acima do piso
  impacto: o arraste volta ao piso e a lista deixa de enviar `minAmount`
  cobertura esperada: `T-02`
- caso: request sem JWT
  impacto: 401, sem lista
  cobertura esperada: `T-01`

## Impacto esperado

O funil do mes separa orcamento aberto de valor que ja virou evento. O corte por valor passa a valer para a pagina e para o total, sem alterar a lista de eventos.

## Areas impactadas

- `backend`: `GET /proposal/list`, schema Zod, use case e repositorio
- `frontend`: pagina de orcamentos, tipos, servico e store da proposta
- `docs/referencias/API_CONTRACTS.md`: secao `GET /proposal/list`

## Restricoes e cuidados

- data de evento permanece wall-clock (`project-decisions.md#D-06`)
- valor permanece `Float` (`project-decisions.md#D-07`)
- contrato compartilhado entre os dois repositorios (`project-decisions.md#D-01`)
- a tela nao recalcula o Valor no mes
- o `R-05` da spec `lista-painel-orcamentos` deixa de valer para `monthAmount`: esse campo nao acompanha mais busca, status nem valor

## Dependencias

- listagem paginada ja no painel (`specs/2026-11-05-lista-painel-orcamentos/`)
- preco minimo padrao do espaco (`minimumPrice`)
- nenhum schema novo

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-01` -> unitario
- `R-03` -> `T-01` -> unitario
- `R-04` -> `T-01` -> unitario
- `R-05` -> `T-01` -> unitario
- `R-11` -> `T-01` -> unitario
- `R-06` -> `T-02` -> tela de orcamentos
- `R-07` -> `T-02` -> tela de orcamentos
- `R-08` -> `T-02` -> tela de orcamentos
- `R-09` -> `T-02` -> tela de orcamentos
- `R-10` -> `T-02` -> chamada da lista de eventos sem `minAmount`

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md#Premissas assumidas`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma; `T-01` e `T-02` escritas
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar entrega`
- entrada publica recomendada: `fw:review`
