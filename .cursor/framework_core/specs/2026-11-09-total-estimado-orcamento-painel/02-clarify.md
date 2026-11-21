# Clarify — Total estimado do orcamento no painel

## Perguntas criticas

Nenhuma bloqueante. As abaixo seguem pela premissa.

## Respostas confirmadas

- Total = valor base + preco da hora extra x horas extras + servicos (confirmado no chat).
- Escopo: formularios do painel por pessoa, criar e editar.
- A conta roda no backend; o frontend nao replica regra de preco.
- Total digitado continua sendo o total final com servicos incluidos.

## Requisitos implicitos confirmados

- Rota autenticada com autorizacao por espaco no backend (D-05).
- Datas em wall-clock (D-06).
- Resposta sem preco unitario, percentual de meta nem faturamento do mes.

## Premissas assumidas

- Permissao exigida: `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` no espaco, as que guardam `/venue/:id/budgets` e `/proposal/:id/edit`. Risco: usuario com acesso so por outra permissao recebe 403 e ve o aviso no bloco.
- Preco minimo continua comparado com o total com servicos e somado aos servicos depois (`minimo + servicos`). Risco: se a regra estiver errada, a estimativa reproduz o erro; corrigir e outro request.
- A edicao por pessoa passa a ajustar preco pelos helpers wall-clock, como criar e o link. Muda valor so em temporada que vira o ano (evento em janeiro) e em servidor fora de UTC. Risco: orcamento antigo reeditado sem mexer no Total pode mudar nesses casos; e a correcao desejada.
- A cotacao so calcula `PER_PERSON` e `PER_PERSON_HOUR`, os modelos que `createPerPerson` calcula com Total vazio. Risco: espaco `PER_DAY` sem pernoite recebe a mensagem de `R-05`.
- `PER_PERSON_HOUR` sem receita no mes segue duracao x convidados x preco, sem hora extra, como hoje.
- O bloco fica logo abaixo da lista de Serviços, ultimo campo que muda o valor. Risco: so visual.
- `Usar este valor` na edicao transforma o total em valor digitado; o valor gravado fica igual ao estimado.
- Com Total vazio na criacao, o `/ pessoa` usa o total estimado com o sufixo `(estimado)`. Na edicao o Total e obrigatorio e o texto nao muda.
- Sem cotacao para permuta no frontend: tipo Troca mostra `R$ 0,00` sem chamar a rota. O backend responde 0 se chamado.
- Debounce de 400 ms, `staleTime` de 30 s e `retry: false`.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Fim antes do inicio, capacidade, `TIERED`, minimo e servico por hora estao em `01-spec.md#Casos de erro e borda obrigatorios`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- Todas as tasks seguem pelas premissas acima.
