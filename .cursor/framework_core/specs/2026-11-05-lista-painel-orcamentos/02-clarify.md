# Clarify — Lista paginada de orcamentos no painel

## Perguntas criticas

- O selo Enviado da referencia existe no cadastro?
- Os cards acompanham dia e busca, ou so o mes?
- O menu de tres pontos entra agora?
- A pagina de eventos ganha o visual da referencia?
- `approved` ausente continua significando "so nao aprovados"?

## Respostas confirmadas

- Enviado nao existe. Nao ha campo de envio nem de abertura do link em `Proposal`.
- O pedido pede KPIs no backend e o front so consumindo.
- A lista de eventos entra pelo desempenho, nao pelo visual.
- A rota `GET /proposal/list` ja exige JWT em `art56_server_v3/src/router/proposal.ts`.

## Requisitos implicitos confirmados

- Wall-clock vale para o filtro da data do evento (`project-decisions.md#D-06`).
- Dinheiro continua `Float` (`project-decisions.md#D-07`).
- Orcamentos e eventos compartilham a mesma listagem.
- Clique na linha continua abrindo o orcamento.
- Novo Orcamento e o copiar link permanecem.

## Premissas assumidas

- Status da linha: `ABERTO` se `approved` e falso, `FECHADO` se e verdadeiro. Sem selo Enviado e sem migration. Risco se a premissa estiver errada: o roxo da referencia nao aparece.
- Cards e `summary.daily` usam o mesmo filtro da tabela, inclusive dia e nome, e ignoram `page`. Risco: o grafico de um dia unico fica com um ponto.
- Conversao e inteira, `Math.round(aprovados / total * 100)`, e `0` quando o total e zero.
- Ordenacao inicial: `startDate` ascendente, desempate por `id`.
- Menu de tres pontos fica de fora. O clique na linha basta.
- `pageSize` e sempre 10, mesmo se o cliente mandar outro valor.
- Sem `page`, a resposta continua a lista inteira, para nao quebrar quem ainda nao manda pagina. `approved` ausente passa a significar os dois estados.
- Ownership do espaco nao entra nesta spec. Risco: um JWT de outro espaco que saiba o `venueId` continua podendo listar, como hoje (`project-decisions.md#D-05`).
- `startDate` e DATETIME. A serie agrupa com `DATE_FORMAT(startDate, '%Y-%m-%d')`, o calendario gravado. Se a coluna for TIMESTAMP, `T-02` para e extrai o dia em UTC.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Dia invalido, pagina vazia, filtro vazio e request sem JWT estao em `01-spec.md#Casos de erro e borda obrigatorios`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` a `T-04` seguem pelas premissas acima.
- A lacuna de ownership fica registrada e fora das tasks.
