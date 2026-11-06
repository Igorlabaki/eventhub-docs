# Clarify — Variacao anual dos KPIs na lista de orcamentos

## Perguntas criticas

- Com um dia selecionado, a comparacao e o dia ou o mes inteiro?
- O percentual tem casa decimal?
- O que aparece quando o ano anterior e 0?

## Respostas confirmadas

- O pedido pede o percentual no canto superior direito dos tres cards, contra o mesmo periodo do ano anterior.
- O numero principal dos cards, o sparkline e a pagina de eventos ficam como estao.
- O calculo entra no `summary` que a pagina ja pede. Nao nasce endpoint.

## Requisitos implicitos confirmados

- Subir o numero e melhor nos tres cards.
- Total e conversao continuam no filtro da tabela; Valor no mes continua so o aprovado da janela. A comparacao repete essa separacao nos dois anos.
- A data do evento continua em wall-clock.
- A tela nao soma as linhas da pagina para achar o percentual.

## Premissas assumidas

- Dia selecionado compara com o mesmo dia do ano anterior, porque o numero do card ja e esse dia. Premissa errada mostraria um dia contra um mes inteiro.
- O percentual e inteiro, via `Math.round`. Premissa errada mudaria o texto do canto e os testes de 21,5% e -10,5%.
- Anterior 0 vira `null` e o canto mostra traco. Premissa errada inventaria um percentual sem base.
- Mes corrente compara o mes civil inteiro, nao so ate hoje. Premissa errada cortaria eventos futuros do mes.
- `change` ausente ou `summary` nulo deixam o canto vazio, sem 0% e sem traco. Premissa errada confundiria carregamento com ano anterior zerado.

## Perguntas de erro e borda ainda abertas

Nenhuma. Os casos de 29 de fevereiro, dia invalido, filtros e campos independentes estao fechados em `01-spec.md#Casos de erro e borda obrigatorios` e em `03-design.md#Falhas, casos de borda e invariantes`.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

A execucao de `T-01` e `T-02` segue pelas premissas acima. Nao ha lacuna de negocio aberta.
