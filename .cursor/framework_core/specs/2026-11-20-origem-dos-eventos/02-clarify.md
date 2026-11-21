# Clarify — De onde vem os eventos

## Perguntas criticas

- Mostrar valor alem da quantidade?
- Limitar bairro a cidade do espaco?
- O que fazer com acento e com linha sem um dos tres campos?

## Respostas confirmadas

- So quantidade. O pedido fecha o ranking com o total de eventos, nao com receita.
- Os tres rankings cobrem o ano inteiro. Bairro de outra cidade entra.
- Evento de contrato tem rua, numero, bairro, CEP, cidade e estado. O botao Gerar Contrato so libera com esses campos, gravados na proposta por `updateProposalPersonalInfo`. Nao ha faixa "sem endereco".
- "Sao Paulo" e "sao paulo" sao o mesmo lugar. "São Paulo" e "Sao Paulo" ficam separados.

## Requisitos implicitos confirmados

- Mesma populacao da aba EVENTO: aprovadas com `startDate` no ano (`approvedInYearWhere`).
- Mesmo gate `VIEW_VENUE_ANALYSIS` e o mesmo envelope `{ success, message, data, count: 1, type }`.
- O card usa carregamento, erro e vazio do `ReportBlock`.

## Premissas assumidas

- Lista completa, sem top N. Se o card ficar longo, a v1 aceita. Risco: muitos bairros numa casa so. A execucao nao pagina.
- Linha com cidade, estado ou bairro vazio depois do `trim` sai do bloco inteiro. Risco se a premissa do contrato falhar: o KPI "Total de eventos" da aba fica maior que `events` deste card. Nao se cria rotulo para cobrir o buraco.
- `month` e `eventCategory` na query, se vierem, passam no schema compartilhado e o use case ignora, como em `event-profile`.
- O formulario preenche "São Paulo" / "SP" quando a proposta vem vazia. O valor salvo e o que conta. Nao ha correcao de default.
- Rotulo exibido e o `trim` da primeira linha lida, nao um title case.

## Perguntas de erro e borda ainda abertas

Nenhuma. As bordas de caixa, acento, espaco interno e campo vazio estao em `R-01` a `R-03`.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

A review da spec. A execucao nao espera outra resposta de produto.
