# Clarify — Variacao anual dos KPIs da visao geral do espaco

## Perguntas criticas

- O que aparece quando o ano anterior e 0?
- Em `Anual`, a comparacao e com o ano anterior inteiro?
- Os campos `*Variation` mudam de significado ou nasce um campo novo?
- O canto mostra o ano comparado?
- A janela que termina a meia-noite do ultimo dia do mes e corrigida junto?

## Respostas confirmadas

- O pedido pede percentual nos quatro cards contra o mesmo mes do ano passado.
- O numero principal dos cards, os graficos e o seletor ficam como estao.
- O calculo entra no analytics que a pagina ja pede. Nao nasce endpoint.

## Requisitos implicitos confirmados

- Subir o numero e melhor nos quatro cards.
- Cada percentual usa o mesmo filtro do numero do card, nos dois anos.
- A tela nao calcula o percentual.

## Premissas assumidas

- Anterior 0 vira `null` e o canto mostra traco, como na lista de orcamentos. Premissa errada inventaria `+100%` sem base.
- `Anual` compara com o ano anterior inteiro. Premissa errada compararia o ano com um mes.
- Nasce `yearlyChange`; os `*Variation` ficam como estao. Trocar o formato deles quebraria o bundle antigo (`proposalsVariation.value.toFixed` em `null` ou `number`). Remover os antigos fica para depois que a tela nova estiver no ar.
- O canto mostra so o percentual; o nome acessivel diz "mesmo periodo do ano anterior", igual a lista de orcamentos. Premissa errada so muda o texto do canto.
- Percentual inteiro via `Math.round`. Premissa errada mudaria o texto e os testes.
- Mes corrente compara o mes civil inteiro, nao so ate hoje. Premissa errada cortaria eventos futuros do mes.
- A janela anterior repete a construcao local da janela do card (`new Date(ano - 1, mes, 1)` ate `new Date(ano - 1, mes + 1, 0)`). Assim os dois lados perdem a mesma borda e a comparacao e justa.
- A janela que termina a meia-noite do ultimo dia nao e corrigida aqui, porque mudaria o numero principal do card. Registrada como achado; vale um request proprio.

## Perguntas de erro e borda ainda abertas

Nenhuma. Os casos estao em `01-spec.md#Casos de erro e borda obrigatorios` e em `03-design.md#Falhas, casos de borda e invariantes`.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

`T-01` e `T-02` seguem pelas premissas acima.
