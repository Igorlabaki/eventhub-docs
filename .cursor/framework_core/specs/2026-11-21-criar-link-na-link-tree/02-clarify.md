# Clarify — criar link na link tree

## Perguntas criticas

Nenhuma em aberto. As cinco perguntas do request foram fechadas na premissa abaixo e o design ja as aplica.

## Respostas confirmadas

- o botao existe na aba Redes e na pagina publica
- o modal escolhe a rede e, na rede colada, o link
- a permissao da publica e `canEditVenueSite` / `EDIT_VENUE_SITE`, a mesma de `canReorder`
- o container "Ainda nao ha link cadastrado na sua link tree" e da pagina publica
- esta feature nao mexe no request visual nem na pilula clara

## Requisitos implicitos confirmados

- visitante nao ve gestao; o backend recusa o write
- arrastar segue sendo a troca de posicao, e so com mais de um link
- tipo repetido nao entra
- URL colada so entra verde
- nenhum campo novo

## Premissas assumidas

- o select "Escolher rede" sai da faixa. Risco se estiver errada: a faixa fica com dois jeitos de criar. A execucao remove o select.
- rede do sistema nao pede URL. Risco: o usuario esperava colar um link tambem nessas redes. A execucao confirma so o tipo; o href continua em `venueLinkHref`.
- o texto do container nao substitui "Nenhuma rede criada" / "Nenhuma rede encontrada" da aba. Risco: a aba vazia continua com a frase atual. A execucao nao troca esse texto.
- criar na publica grava na hora; a aba espera "Salvar Alteracoes". Risco: a pessoa cria na publica e nao ve o botao Salvar. A execucao chama o write novo e nao o `PUT` do editor.
- o botao da publica tambem aparece com a lista cheia, acima dos cards. Risco: o lugar do botao nao foi apontado no print. A execucao usa esse lugar.
- o rotulo dos dois botoes e "Cadastrar link". Risco: o chat nao fixou o rotulo. A execucao usa esse texto.
- create na publica de rede do sistema sem destino responde 400 e nao grava. Risco: a aba hoje cria a linha oculta. A publica nao tem lista de ocultos, entao gravar deixaria o clique sem card. A execucao nao grava nesse caso.

## Perguntas de erro e borda ainda abertas

Nenhuma. As bordas de 401, 403, tipo repetido, URL ruim e destino ausente estao em `01-spec.md` e `03-design.md#Write da pagina publica`.

## Itens bloqueantes

- nenhum

## O que pode seguir mesmo com lacunas

Tudo. `T-01` pode comecar. `T-02` pode correr em paralelo. `T-03` espera o contrato de `T-01`.
