# Clarify — URL publica pelo nome do espaco

## Perguntas criticas

- O link antigo com UUID continua abrindo?
- Nome com maiuscula diferente, barra ou espaco quebra a busca?
- O formulario pode passar a receber o pacote da apresentacao em vez do `getById`?

## Respostas confirmadas

- Os dois enderecos novos usam `Venue.name`, nao um slug. Pedido do chat e o campo ja e `@unique`.
- O orcamento do pedido e `/venue/:id/form`. `/proposal/:id/view` usa o id da proposta e fica fora.
- O painel continua no id.
- A apresentacao publica ja responde sem login em `GET /venue/presentation/:venueId`, buscando `where: { id }`.
- O formulario chama `GET /venue/getById` sem `userId` e hoje repassa o parametro da URL como `venueId` para servicos e criacao.

## Requisitos implicitos confirmados

- rota publica continua intencional e na allowlist; nao nasce permissao
- o nome no link e adivinhavel de proposito; o que nao pode vazar e dado a mais
- `getById` com `userId` filtra permissao daquele usuario e nao entra nesta troca de chave
- dominio dos links copiados continua `https://event-hub-dashboard.vercel.app`

## Premissas assumidas

- Link com UUID segue valido. Premissa do request. Se estiver errada, `R-06` sai e os links ja enviados quebram.
- Chave no formato UUID (8-4-4-4-12) busca so por id. Nome igual a um UUID de outra casa abriria a outra. Risco aceito: nome de espaco nao e UUID.
- A URL usa o `name` como esta gravado, com `encodeURIComponent`. A busca usa o texto decodificado, sem lower case nem trim extra. Maiuscula diferente depende da collation atual do MySQL; esta feature nao normaliza.
- Nome com `/` nao e suportado. `encodeURIComponent` nao segura esse caractere num segmento de path. Nao ha nome assim no pedido.
- Casa renomeada nao redireciona o nome antigo.
- O formulario continua no `getById` atual. Nao troca para o DTO da apresentacao. Limpar `contracts` e `attachments` desse GET publico e outro trabalho.

## Perguntas de erro e borda ainda abertas

- Nenhuma. As premissas acima ja dao o caminho da execucao.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` e `T-02` podem ser executadas com as premissas desta pagina. A review da spec nao precisa fechar collation nem o pacote antigo do `getById`.
