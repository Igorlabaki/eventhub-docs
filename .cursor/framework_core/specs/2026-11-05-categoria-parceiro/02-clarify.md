# Clarify — Categoria do parceiro

## Perguntas criticas

- A categoria substitui a funcao? Nao. `role` permanece.
- Quem ja existe vira Outros? So `SUPPLIER`. `TEAM_MEMBER` fica com categoria nula.
- A pagina publica agrupa ou filtra? Agrupa. Nao ha filtro nem rota nova.
- O grupo le uma copia da indicacao ou o cadastro atual? O cadastro atual, como a pagina ja faz.

## Respostas confirmadas

- A lista fechada e a da entrada, com `OUTROS` incluso.
- Um parceiro tem uma categoria.
- `OUTROS` e escolha valida no cadastro novo, alem do fallback.
- O cadastro do painel e `/venue/:id/partner-form` pedem a categoria.
- A lista de contatos mostra o rotulo no fornecedor.
- A ordem dos grupos e a ordem do enum. Grupo vazio nao aparece.
- Dentro do grupo, a ordem e a de `position`.

## Requisitos implicitos confirmados

- O `POST /contact/create` continua publico. A categoria entra na validacao, sem auth nova.
- A pagina publica continua sem login e continua limitada aos fornecedores indicados daquele espaco.
- Rotulo em portugues na tela. Valor gravado e o enum.
- Categoria nula na leitura publica aparece em Outros e nao gera escrita.

## Premissas assumidas

- Trocar para `TEAM_MEMBER` zera a categoria. Risco se estiver errado: o retorno para fornecedor exige escolher de novo.
- Trocar para `SUPPLIER` no mesmo pedido exige categoria. Risco se estiver errado: um cliente antigo do painel nao consegue salvar fornecedor ate o frontend novo.
- API nova e formularios sobem juntos. Risco se estiver errado: uma janela em que o cadastro publico recusa envio sem categoria.
- A tabela `contact` nao e quente o bastante para backfill em lotes. Risco se estiver errado: o `UPDATE` unico segura a gravacao de contato durante a migration. A coluna e nova e opcional; o `UPDATE` so preenche nulos de fornecedor.

## Perguntas de erro e borda ainda abertas

Nenhuma. Os casos de tipo, lista vazia e categoria nula ja tem premissa acima.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

- Owner nao definido. Nao impede `T-01`.
- `migrate deploy` em producao fica para depois da review e da execucao, com alvo explicito.
