# Clarify — Indicacoes publicas do orcamento

## Perguntas criticas

- A pessoa recebe o link por envio automatico? Premissa: nao. Risco se estiver errada: a equipe espera um WhatsApp que esta tela nao abre.
- Salvar acrescenta ou substitui? Premissa: substitui o conjunto daquele orcamento. Risco se estiver errada: uma segunda gravacao apaga indicacoes que a equipe queria manter.
- A pagina guarda copia do dia ou le o cadastro? Premissa: le o cadastro atual. Risco se estiver errada: alterar o WhatsApp do parceiro nao muda a pagina, ou uma copia antiga diverge do cadastro.
- O e-mail entra no card? Premissa: sim, quando existir. Risco se estiver errada: a pagina publica expoe um e-mail que a equipe nao queria mostrar.
- Qual a ordem dos cards? Premissa: a ordem da lista salva, sem duplicar id. Risco se estiver errada: a pagina ordena por nome e a equipe perde a ordem escolhida.
- Parceiro, equipe e contrato mudam de casca junto? Premissa: nao. Risco se estiver errada: o pedido visual era mais largo do que esta spec cobre.

## Respostas confirmadas

- A origem do pedido e deixar de mandar a mensagem e ter uma pagina com as indicacoes daquele orcamento.
- A casca visual e a das listas publicas, nao a de ver o orcamento.
- O cadastro atual do parceiro nao tem foto nem descricao longa.

## Requisitos implicitos confirmados

- Quem salva e quem ja pode enviar informacao do orcamento, e a API confirma isso no espaco daquele orcamento.
- A rota de leitura e publica de proposito. A de gravacao nao e.
- Campo vazio nao vira bloco vazio no card.
- Ao sair da pagina, a aba volta ao titulo EventHub, como nas outras listas.

## Premissas assumidas

- O link copiado usa a origem do painel aberto, nao um host fixo de producao.
- Ids repetidos no mesmo pedido contam uma vez, na primeira posicao, e o pedido segue.
- Gravacoes simultaneas: vale a ultima transacao que concluir.
- Orcamento inexistente na leitura publica responde 404, com corpo sem lista de contatos.
- A lista de todos os fornecedores no painel continua no endpoint de contatos que ja existe. Esta feature nao o fecha e nao o usa para a pagina publica.
- `ensurePermission` atual nao serve: ele exige `organizationId` e a mensagem e a do calendario. A checagem nova olha o espaco do orcamento.

## Perguntas de erro e borda ainda abertas

- Nenhuma que mude o contrato. As bordas de auth, conjunto invalido, lista vazia e marca ausente ja tem premissa acima.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` pode criar a tabela sem esperar review de copy.
- A frase da lista vazia pode ser ajustada na `T-05` sem mudar API. Premissa de copy: "Ainda nao ha indicacoes para o seu evento."
