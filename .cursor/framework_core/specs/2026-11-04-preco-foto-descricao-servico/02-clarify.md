# Clarify — Preco, foto e descricao do servico

## Perguntas criticas

- A hora de um servico numa locacao de varios dias conta as diarias ou o intervalo do evento?
- A foto e a descricao de um orcamento ja enviado acompanham o cadastro, ou ficam congeladas como o preco?
- A listagem de servicos, hoje aberta para o formulario publico, passa a exigir login?

## Respostas confirmadas

- Tipos pedidos: fixo, por hora e por pessoa, mais uma foto ilustrativa e uma descricao.
- Servico ja cadastrado continua preco fixo.
- Nome do servico continua unico dentro do espaco (`product/02-business-rules.md`).

## Requisitos implicitos confirmados

- A permissao da tela nao substitui a API. O produto pede que dado restrito so mude com acesso ao recurso (`product/02-business-rules.md#Acesso`). Regras do espaco ja fazem essa checagem no backend.
- Dinheiro segue Float (`project-decisions.md` D-07). Horario do evento segue wall-clock (D-06).
- A foto da casa ja e publica no S3, em WebP. A do servico reaproveita esse caminho, porque a pagina publica precisa exibi-la.

## Premissas assumidas

- Por hora usa `calcEventDuration` entre inicio e fim, inclusive pernoite e varios dias. Risco se estiver errado: uma estadia longa cobra muitas horas de um servico que a pessoa imaginava por diaria. Por diaria ficou de fora de proposito.
- Preco, tipo, quantidade e valor da linha ficam gravados no orcamento. Foto, nome e descricao sao lidos do cadastro na hora de exibir. Risco se estiver errado: o cliente ve uma foto nova num orcamento antigo. O valor nao muda.
- Orcamento antigo sem linha gravada mostra `price` como linha fixa. Risco se estiver errado: algum servico antigo que ja era "por pessoa" na pratica aparece como pacote ate o proximo save.
- Preco zero e permitido. Preco negativo nao. Risco se estiver errado: um servico de cortesia deixa de salvar, ou um desconto disfarçado de preco negativo deixa de existir.
- A listagem `GET /service/list` continua sem autenticacao. Risco se estiver errado: descricao e foto do catalogo inteiro seguem publicas, como o preco ja e. Fechar essa rota quebraria o formulario publico.
- Permuta continua com total zero. As linhas podem ser gravadas, mas o total da permuta nao passa a somar servico. Risco se estiver errado: a permuta continua exibindo linhas e um total zerado, como o link ja pode fazer hoje.
- Limite da foto: 5 MB antes da conversao. Risco se estiver errado: uma foto grande legitima e recusada. A galeria da casa hoje nao declara limite no multer; este limite vale so para o servico.

## Perguntas de erro e borda ainda abertas

- Nenhuma que impeça a execucao. As premissas acima sao o default.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- A formula, o schema, a permissao e as telas podem ser executados com as premissas desta pagina.
- Nao ha owner nomeado. Isso nao bloqueia o desenho.
