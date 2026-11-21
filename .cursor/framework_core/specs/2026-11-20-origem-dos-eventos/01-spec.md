# Spec — De onde vem os eventos

## Problema

A aba EVENTO mostra volume, canal de entrada, categoria, ocupacao, servicos e porte. O endereco do cliente ja fica na proposta quando o contrato e gerado, e a aba nao usa cidade, estado nem bairro.

## Objetivos

Na aba EVENTO, o operador ve quantos eventos aprovados do ano vieram de cada cidade, de cada estado e de cada bairro. A soma de cada ranking fecha com o total desse bloco.

## Fora de escopo

- mapa, distancia por CEP e geocodificacao
- valor, ticket ou cruzamento com `trafficSource`
- faixa "Sem endereco"
- filtro por categoria ou por mes
- corte dos rankings (top N)
- mudar o formulario do contrato, o schema ou os outros blocos da aba
- unir grafias com acento diferente (`São Paulo` e `Sao Paulo`)

## User stories ou cenarios principais

- O operador abre a aba EVENTO de um ano e ve tres listas: cidades, estados e bairros, da maior quantidade para a menor.
- Duas propostas da mesma cidade, uma "Sao Paulo" e outra "sao paulo", contam como um lugar.
- Quem nao tem `VIEW_VENUE_ANALYSIS` no espaco nao recebe o agregado.

## Criterios de aceite

- `R-01`: a populacao e a de `approvedInYearWhere` (aprovada, `startDate` no ano, sem filtro de categoria). So entra no bloco a linha em que cidade, estado e bairro, depois do `trim`, sao nao vazios. `events` e essa quantidade. A soma de `cities`, a de `states` e a de `neighborhoods` sao iguais a `events`.
- `R-02`: a chave do lugar e `trim` + `toLocaleLowerCase("pt-BR")`. Espaco no meio nao some. O rotulo exibido e o `trim` da primeira linha do grupo.
- `R-03`: acento diferente continua sendo outro lugar.
- `R-04`: o JSON de `data` so tem `year`, `events`, `cities`, `states` e `neighborhoods`. Cada item e `{ label, count }`. Nao ha rua, numero, complemento, CEP, nome, CPF, CNPJ nem id de proposta.
- `R-05`: `GET /venue/reports/event-origin` exige JWT e `VIEW_VENUE_ANALYSIS` no espaco. Sem token, 401. Espaco inexistente, 404. Sem a permissao, 403. Ano fora de 2000–2100, 400. `type` da resposta e `EventOriginReport`.
- `R-06`: a query Prisma seleciona somente `city`, `state` e `neighborhood`.
- `R-07`: na aba EVENTO, abaixo dos cards de servicos e porte, um card "De onde vem os eventos" lista as tres colunas. Carregando, erro com "Tentar de novo" e vazio quando `events` e 0 usam o `ReportBlock` atual.
- `R-08`: ordem de cada lista: `count` decrescente; empate por `label` com `localeCompare` `pt-BR`.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: o mesmo `ReportAuthorizer` e `ReportController` dos outros `GET /venue/reports/*`. A rota nao entra em allowlist publica.
- erros e mensagens esperadas: as que o controller compartilhado ja devolve. O card usa `blockErrorMessage`.
- observabilidade minima: nenhum log novo. O `console.error` de permissao negada que ja existe no authorizer nao recebe endereco.
- concorrencia, idempotencia ou retry: leitura. O hook reusa `staleTime` de 5 min e `retry: 1` de `venueReportBlocks.ts`. Sem cache no servidor.
- rollout, fallback ou degradacao: o card falha sozinho. Os outros blocos da aba continuam. Nao ha flag.

## Casos de erro e borda obrigatorios

- caso: cidade, estado ou bairro nulo ou so com espaco
  impacto: a linha inteira fica fora de `events` e dos tres rankings, para as somas fecharem
  cobertura esperada: unitario
- caso: "Sao Paulo" e "sao paulo"; "São Paulo" a parte; "São  Paulo" (dois espacos) a parte
  impacto: dois, tres e quatro lugares conforme a regra de `R-02` e `R-03`
  cobertura esperada: unitario
- caso: usuario sem permissao, sem token ou espaco de outro contexto
  impacto: 403, 401 ou 404, sem corpo com endereco
  cobertura esperada: use case com authorizer fake, no mesmo arquivo `reports.spec.ts`
- caso: ano `1999` ou ausente
  impacto: 400 pelo schema compartilhado
  cobertura esperada: o schema ja cobre ano; a rota nova nao cria outro parser

## Impacto esperado

Um endpoint autenticado e um card. Quem ja ve a aba EVENTO passa a ver a origem geografica dos eventos com contrato.

## Areas impactadas

- backend: funcao pura, metodo do repositorio de proposta, use case, factory, rota em `venue.ts`
- frontend: tipo, `venue.service`, hook, card, `EventsReport`
- docs: `project/api-endpoints.md` e `topics/reports-and-kpis.md`

## Restricoes e cuidados

- endereco do cliente e PII. O agregado nao reconstitui a pessoa.
- colunas de endereco no schema sao opcionais. O fluxo do contrato as exige. Linha legada incompleta nao ganha rotulo.
- indice `@@index([venueId, startDate])` em `Proposal` ja existe. Sem migration.

## Dependencias

- `approvedInYearWhere`, `ReportController`, `ReportAuthorizer`, `ReportBlock`, `useReportEventProfile` como modelo

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-02`, `R-03` -> `T-01` -> unitario
- `R-04`, `R-05`, `R-06` -> `T-02` -> unitario do use case
- `R-07`, `R-08` -> `T-03` -> unitario do card e da ordenacao ja provada em `T-01`

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
