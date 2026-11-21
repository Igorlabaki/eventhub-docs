# Clarify — link tree do espaco

## Perguntas criticas

Nenhuma em aberto. As cinco lacunas do request foram fechadas como premissa.

## Respostas confirmadas

- O item se chama Link tree e fica na sidebar do espaco.
- A aba nova e Redes, entre Precos e Apresentacao.
- Site, Instagram, Facebook e TikTok saem de Apresentacao.
- WhatsApp, e-mail, mapa e video do tour nao sao pedidos de novo.
- O dono escolhe o tipo, cola a URL, arrasta a ordem e escolhe o que mostrar.
- YouTube no seletor e o canal. O video do tour fica em Apresentacao.
- Uma ocorrencia por tipo.
- Ordem, visivel e os tipos novos nao cabem nas quatro colunas.

## Requisitos implicitos confirmados

- Quem ve Site ve o item. Nao ha permissao nova.
- Link ambar ou vermelho nao aparece no link tree.
- O olho desligado nao tira a linha da lista do editor.
- Criar espaco continua com os quatro campos.

## Premissas assumidas

- Caminho publico: `/espaco/{nome}/links`, com o alias `/venue/:id/links`, no mesmo host das outras paginas. Risco se estiver errado: o item da sidebar aponta para o endereco errado.
- A pagina publica e uma lista vertical na casca da apresentacao (logo e cores). Risco: o dono esperava um visual de link tree diferente.
- Ordem e olho gravam no Salvar alteracoes. Risco: o dono espera gravar ao soltar o arraste.
- O olho vale so para o link tree. Apresentacao e rodape continuam com a URL, mesmo oculta na lista. Risco: o dono espera que desligar o Instagram suma tambem da apresentacao.
- Sem linhas gravadas, a leitura calcula a lista padrao. Nao ha backfill em massa. Risco: um espaco antigo so muda a ordem depois do primeiro Salvar, mas a pagina ja abre com o padrao.
- O `EditVenueForm` da organizacao nao entra. Ele pode continuar gravando as quatro colunas. Risco: depois que a lista existir, esse formulario nao atualiza a ordem do link tree.
- Alem do arraste, Subir e Descer mudam a ordem. Risco: nenhum de produto; e o acesso por teclado.

## Perguntas de erro e borda ainda abertas

Nenhuma. A execucao segue as premissas.

## Itens bloqueantes

Nenhum.

## O que pode seguir mesmo com lacunas

`T-01` em diante. Nao aplicar a migration na `main`.
