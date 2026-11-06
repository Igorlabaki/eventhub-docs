# Clarify — Recalcular o orcamento no link publico

## Perguntas criticas

Nenhuma em aberto. As decisoes abaixo vieram do pedido e das premissas do request.

## Respostas confirmadas

- O modal fica no card "Seu investimento" e tem so dia, convidados e horas.
- O formulario e React Hook Form com Zod.
- Recalcular grava o orcamento e a pagina mostra o valor novo.
- O horario de inicio gravado permanece; as horas movem o fim.
- Orcamento aprovado ou pago nao e reescrito.
- Total digitado a mao pela equipe e substituido pela tabela da casa.
- Data ocupada nao bloqueia esta entrega.
- Servicos ligados permanecem.

## Requisitos implicitos confirmados

- A rota nova e publica. Quem tem o link altera aquele orcamento enquanto ele nao estiver aprovado nem pago.
- A conta nao roda no navegador. A resposta nao leva a tabela de preco.
- Horario de evento continua em wall-clock (`project-decisions.md` D-06).
- O cliente da jornada publica pode mexer em dados da proposta por link (`product/03-user-profiles.md`). Datas respeitam capacidade e preco do venue (`product/02-business-rules.md#Proposal`).

## Premissas assumidas

- Orcamento de mais de um dia civil nao entra neste modal. Premissa do request: casa com pernoite mantem os tres campos e as horas nao mudam check-in, check-out nem minimo de noites. Decisao: esses campos de espaco nao sao da proposta e nao sao gravados; se o orcamento ja cruza dois dias civis, Recalcular nao roda e o modal explica. Risco: estadia de varias noites continua dependendo da equipe.
- No mesmo dia civil, `PER_DAY` e `PER_PERSON_DAY` contam 1 dia. Risco: uma casa que cobra fracao de diaria no mesmo dia receberia a diaria cheia.
- `PER_PERSON_HOUR` sem receita no mes segue o ramo da edicao do painel: duracao vezes convidados, sem linha de hora extra. Risco: diverge do ramo de criacao que so calcula quando ha receita.
- Data no passado e aceita. Risco: o cliente pode mover o evento para um dia que ja passou.
- O botao "Alterar orçamento" nao usa o verde do WhatsApp. Risco: baixo, so visual.
- Nao ha notificacao interna nesse recálculo. Risco: a equipe so percebe pelo historico da proposta.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Recusa de meia-noite, minimo, `BARTER`, `TIERED` e preco ausente esta fechada em `01-spec.md` e `03-design.md`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- A execucao segue pelas premissas desta pagina. Nao ha lacuna que impeça `T-01`.
