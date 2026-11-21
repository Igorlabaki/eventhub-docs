# Clarify — Cadastro das redes e consumo por venue_link

## Perguntas criticas

- A linha de WhatsApp e a do tour nascem visiveis? Premissa: nascem desligadas. Risco se estiver errado: o dono espera o clique no ar assim que salva o numero ou o video, e a pagina publica fica sem eles ate o clique na sidebar.
- Esvaziar WhatsApp ou tour remove a linha? Premissa: remove. Risco se estiver errado: a sidebar continua listando um link sem destino.
- A sidebar reordena? Premissa: nao. A ordem publica fica a `position` do cadastro. Risco se estiver errado: o dono perde o arraste que hoje existe na pagina publica e nao acha outro lugar para ordenar.
- Apresentacao, Fazer orcamento, Regras, E-mail, Google Maps e Site da organizacao mudam? Premissa: nao. Risco se estiver errado: esses atalhos somem ou passam a exigir cadastro manual.
- O salvamento continua copiando as quatro URLs para as colunas? Premissa: nao escreve nessas colunas. Tambem nao apaga o que ja esta la. Risco se estiver errado: uma tela ainda nao migrada perde o icone antes da propria task de leitura.

## Respostas confirmadas

- Configuracoes cadastra. Cadastrar a URL colada cria o link e pergunta se fica visivel.
- A sidebar nao abre a pagina publica. O clique liga ou esconde e salva.
- A pagina publica mostra so cadastrado e visivel.
- Nao ha coluna nova nem enum novo. As quatro colunas ficam como legado.
- `whatsappNumber` e `tourVideoUrl` continuam sendo o telefone e o video.
- Organizacao e contato ficam fora.
- O visual dos cards publicos e da lista de Configuracoes nao e redesenho.

## Requisitos implicitos confirmados

- Um link por tipo.
- Quem ve Site abre a tela. Quem edita o site grava.
- A rota publica continua publica e nao leva dado interno.
- URL que nao passa na checagem verde nao vira linha na copia.

## Premissas assumidas

- A copia das quatro colunas cria a linha visivel, porque o pedido e fazer o link antigo voltar a aparecer. Isso vale so quando a linha daquele tipo ainda nao existe.
- Trocar o numero ou o video atualiza o clique e nao mexe no visivel.
- A pagina publica deixa de oferecer Cadastrar, arrastar e Remover. Esses gestos saem dela: cadastro em Configuracoes, visivel na sidebar.
- `CreateVenueForm` ainda pode gravar as colunas na criacao. A primeira leitura de links copia para a linha. `EditVenueForm` e `MinimumPricesTab` deixam de alterar as quatro URLs: o update do espaco ignora esses quatro campos.
- O olho de visivel sai da lista de Configuracoes. A pergunta fica so no formulario de cadastro. Depois, a sidebar muda o visivel.

## Perguntas de erro e borda ainda abertas

- Nenhuma alem das premissas acima. A execucao segue por elas.

## Itens bloqueantes

- Nenhum. O banco de producao nao foi lido e nao bloqueia: a copia usa o que estiver na coluna na hora da leitura.

## O que pode seguir mesmo com lacunas

- `T-01` em diante. Nao esperar leitura manual da AR756 no PlanetScale.
