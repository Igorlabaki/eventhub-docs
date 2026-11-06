# Clarify — Trocar a foto do link de orcamento

## Perguntas criticas

- A marca do link pode ser a mesma do site? Nao. O pedido pede uma coluna nova para o link de orcamento.
- A troca vale para um orcamento ou para o espaco? Para o espaco. A marca fica na foto, como a ordem do arraste.
- Quem grava? O dono logado com `EDIT_VENUE_SITE` naquele espaco. O visitante so le.

## Respostas confirmadas

- O arraste e o carrossel permanecem.
- A pagina continua publica, no mesmo link.
- A gravacao passa pelo backend.

## Requisitos implicitos confirmados

- A leitura publica nao passa a exigir token.
- A permissao e checada no espaco da proposta, nao em qualquer espaco da organizacao.
- Foto nova, sem a marca do link, fica de fora ate alguem coloca-la no lugar de outra.

## Premissas assumidas

- Fotos que hoje aparecem no link entram ja marcadas. Risco se estiver errado: os links atuais abrem sem foto. A migration copia `isShowOnOrganization` verdadeiro para a marca nova.
- O controle de troca e separado do clique que amplia. Risco se estiver errado: o dono esperaria clicar na foto inteira. O carrossel deixaria de abrir se o clique inteiro virasse seletor.
- Com uma unica foto no catalogo, o controle nao aparece. Risco se estiver errado: o dono abre um seletor sem alternativa. A tela explica a ausencia pelo proprio sumico do controle, no mesmo espirito do arraste com uma foto so.
- Nao ha checkbox desta marca no painel nesta feature. Risco se estiver errado: o dono so troca a partir de um link de orcamento. O pedido aponta a troca no link.
- O campo `catalog` vai na leitura como lista vazia quando `canReorder` e falso, e so recebe fotos depois da permissao. Risco se estiver errado: um cliente trata lista vazia como espaco sem foto. A pagina visivel continua em `images`.
- Nao ha retry automatico da troca. Risco se estiver errado: uma segunda tentativa depois do sucesso encontra a foto de origem ja fora do link e responde 400. O controle fica desabilitado enquanto grava.

## Perguntas de erro e borda ainda abertas

- Nenhuma que mude o contrato. As bordas de auth, outro espaco, mesma foto e falha de gravacao ja tem premissa acima e requisito em `01-spec.md`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` pode gravar a coluna, o backfill e o filtro do link e da reordenacao sem o seletor.
- O painel do site fica como esta.
