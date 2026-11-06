# Clarify — KPIs, filtros e paginas de dez na lista de contatos

## Perguntas criticas

- Quais cards, alem de existirem? Premissa fechada abaixo.
- A categoria entra nos dois tipos de contato?
- A listagem ganha JWT nesta spec?

## Respostas confirmadas

- A pagina e Contatos do painel. O padrao e a pagina de orcamentos.
- Filtro, pagina de dez e cards sao calculados no backend.
- A aba Parceiros / Equipe permanece e continua sendo o tipo.

## Requisitos implicitos confirmados

- A busca de hoje (nome, funcao, WhatsApp e e-mail) sai do navegador.
- Trocar filtro ou aba volta para a primeira pagina.
- Criar, editar e apagar recarregam a consulta atual.
- Quem nao manda `page` recebe a lista inteira. Indicar parceiros e um desses chamadores.

## Premissas assumidas

- Cards: Total, Com logo e Com descricao. Risco se a premissa estiver errada: a tela troca so os tres rotulos e os dois counts; a pagina e o filtro nao mudam.
- Com logo e com descricao exigem texto depois do trim. Nulo ou em branco conta como ausente.
- Categoria so na aba Parceiros, no enum gravado. `OUTROS` nao inclui categoria nula. Nula aparece em Todas. Risco: quem filtra Outros nao ve o contato antigo sem categoria.
- Os cards acompanham busca, tipo e categoria e ignoram a pagina.
- `q` tem no maximo 80 caracteres, como o nome na lista de orcamentos. O parametro `name` antigo permanece e, se vier junto, restringe tambem o nome.
- Sem indice novo. A lista e por espaco e o `@@index([venueId])` ja existe. Risco: uma busca textual grande varre os contatos daquele espaco.
- Esta spec nao coloca `ensureAuthenticate` na listagem. A lacuna segue `project-decisions.md#D-05`.

## Perguntas de erro e borda ainda abertas

Nenhuma. Os casos obrigatorios estao em `01-spec.md#Casos de erro e borda obrigatorios`.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

A execucao segue pelas premissas. Nao ha lacuna que mude o contrato antes de `T-01`.
