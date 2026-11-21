# Clarify — Criar a rede do espaco

## Perguntas criticas

Nenhuma em aberto. As quatro premissas do request foram aceitas e a marca de rede criada foi fechada no design porque o formato antigo nao distingue semente de criacao.

## Respostas confirmadas

- o pedido veio do chat: linha verde como em Indicar parceiros, lapis com modal da URL, rede vazia fora da lista e do link tree, select sem o tipo que ja existe
- a tabela `venue_link` guarda `kind`, `url`, `visible`, `position`, com unico por espaco e tipo
- lista vazia hoje cai em `defaultVenueLinks`, que liga Apresentacao, orcamento e regras
- `normalize` zera `url` de tudo que nao e link colado
- o `GET` publico nao exige token; editor e `PUT` exigem `EDIT_VENUE_INFO`; ordem e ocultar exigem `EDIT_VENUE_SITE`

## Requisitos implicitos confirmados

- uma rede por tipo, ja garantida no use case e no indice unico
- o aviso de URL continua o de `checkVenueLinkUrl`
- o card publico nao muda
- o olho e a lixeira continuam; o lapis entra so no link colado

## Premissas assumidas

- destino gerado (Apresentacao, Fazer orcamento, Regras, WhatsApp, e-mail, mapa, video, site da organizacao) tambem se cria pelo select, sem campo de URL. Risco se estiver errado: o select oferece tipo que a pessoa nao queria criar na mao.
- a linha fica verde so quando esta no link tree (`visible` e com destino). Oculta fica branca. Risco se estiver errado: a pessoa esperava verde em toda linha criada.
- o que o padrao ja gravou sem URL verde some da leitura ate a pessoa criar de novo. Nao ha coluna nova. Risco se estiver errado: Apresentacao, orcamento e regras somem do link tree de quem ja usava o padrao, ate criar de novo.
- o olho continua ocultando sem devolver ao select; a lixeira remove e devolve. Risco se estiver errado: ocultar e apagar passam a ser o mesmo gesto.
- criar, editar, ocultar e apagar na aba mudam o estado local e gravam no salvamento que Configuracoes ja faz. Risco se estiver errado: a pessoa espera o link tree atualizar antes de salvar a aba.
- o marcador na coluna `url` e a string `created`. Risco se estiver errado: algum leitor trata essa string como endereco. A tabela nao mostra o marcador e o destino gerado nao usa `url` para montar o href.

## Perguntas de erro e borda ainda abertas

Nenhuma. Os casos obrigatorios estao em `01-spec.md`.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

`T-01` e `T-02` seguem pelas premissas acima. Nao ha schema para esperar.
