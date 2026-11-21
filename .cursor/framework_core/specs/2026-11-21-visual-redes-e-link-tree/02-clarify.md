# Clarify

## Perguntas criticas

Nenhuma em aberto. As cinco do request fecharam com premissa e a execucao segue por elas.

## Respostas confirmadas

- A aba Redes deixa o cartao com Subir, Descer, Remover e o texto "No link tree".
- A estrutura e a de Contatos: faixa, KPIs, contador e tabela.
- Escolher rede acrescenta a linha na hora.
- A unica acao a mais e o icone de arrastar. Subir e Descer nao entram.
- A pagina publica usa o card de "Gerencie seu evento", com os titulos no mesmo ponto.

## Requisitos implicitos confirmados

- Sem schema, endpoint ou campo. O payload publico continua `{ kind, label, href }`.
- Logo, slogan e titulo da aba da pagina publica permanecem.
- A pagina publica so lista o que o dono deixou visivel, na ordem gravada. Isso ja e o `GET`.

## Premissas assumidas

- KPIs: Total (todas as linhas), No link tree (`visible`) e Com link (URL preenchida). Contam a lista inteira. Risco se estiver errado: o usuario queria o numero do recorte filtrado, como o total de Contatos segue a busca.
- Filtros: busca por nome e visibilidade Todas / No link tree / Ocultas. Escolher rede fica na faixa e so adiciona. Sem botao de copiar link. Risco se estiver errado: falta um atalho que o usuario chamou de "tudo mais".
- Acoes da linha: olho para `visible`, lixeira so em rede colada, URL e aviso na linha. Risco se estiver errado: a lixeira some de uma rede que o usuario quer apagar.
- Card publico sem descricao. Risco se estiver errado: o card fica mais baixo que o de "Gerencie seu evento".
- Lista publica numa coluna, `max-w-md`, embaixo da logo e do slogan. Risco se estiver errado: a pagina fica estreita demais para o card largo do evento.
- Arraste so com busca vazia e filtro Todas. Com recorte, a alca nao muda a ordem. Risco se estiver errado: o usuario espera arrastar o que esta vendo.
- O contador segue a tabela visivel; os KPIs nao. Risco se estiver errado: os dois numeros divergem e um deles parece bug.

## Perguntas de erro e borda ainda abertas

Nenhuma. Os casos obrigatorios estao em `01-spec.md`.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

`T-01` e `T-02` seguem em paralelo. Nao dependem uma da outra.
