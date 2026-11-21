# Spec — Foto, video e descricao na caracteristica

## Problema

Quem cadastra uma caracteristica so informa o nome. A proposta publica, no bloco "Conheça nosso espaço", repete esse nome com um check. Nao ha texto, foto nem video do item.

## Objetivos

- gravar uma descricao opcional em cada caracteristica
- gravar uma foto opcional e um link opcional de video do YouTube; os dois podem coexistir
- no bloco publico, mostrar um "?" ao lado do nome quando houver descricao, foto ou video; o clique abre um modal com esse conteudo
- manter validas as caracteristicas que ja so tem nome

## Fora de escopo

- tour do espaco, galeria da casa e foto ou descricao de servico
- upload de arquivo de video; o video e sempre um link
- link de video fora do YouTube
- storage privado ou URL assinada
- miniatura na tabela do painel
- mostrar descricao, foto ou player direto no card publico, fora do modal
- mudar nome unico, posicao ou permissao `EDIT_VENUE_AMENITIES`

## User stories ou cenarios principais

- Quem edita o espaco abre Nova caracteristica, escreve o nome, uma descricao, escolhe uma foto e cola um link do YouTube.
- Quem edita um item troca ou apaga a foto sem mexer no video, e troca ou apaga o video sem mexer na foto.
- Quem abre a proposta ve um "?" ao lado do item com complemento; ao clicar, abre um modal com nome, foto, descricao e o video tocando no player do YouTube. O item sem complemento continua so com check e nome.

## Criterios de aceite

- `R-01`: criar e editar gravam descricao opcional de ate 500 caracteres; vazio vira nulo
- `R-02`: a foto aceita arquivo `image/*` de ate 5 MB; o que fica gravado e a URL devolvida pelo upload, nunca uma URL enviada pelo cliente
- `R-03`: o video aceita so URL `https` do YouTube (`watch`, `youtu.be`, Shorts ou `embed`); arquivo de video, `http` e outro host sao recusados
- `R-04`: foto e video podem coexistir na mesma caracteristica; o mesmo envio aceita arquivo e link juntos
- `R-05`: trocar ou apagar a foto, ou excluir a caracteristica, remove o objeto anterior da foto
- `R-06`: trocar ou apagar o video nao mexe na foto, e trocar ou apagar a foto nao mexe no video
- `R-07`: caracteristica antiga, sem descricao e sem midia, continua listavel e publica so com o nome
- `R-08`: usuario sem `EDIT_VENUE_AMENITIES` naquele venue nao cria, nao edita e nao exclui
- `R-09`: a apresentacao publica da proposta devolve `description`, `imageUrl` e `videoUrl` da caracteristica e nao passa a devolver dado interno do venue
- `R-10`: no bloco publico, item com descricao, foto ou video mostra um botao "?" ao lado do nome, no mesmo padrao dos servicos; o clique abre um modal com nome, foto, descricao e player do YouTube com controles e sem autoplay; o `src` do player e so o embed montado a partir do id, nunca a URL crua; item sem complemento fica com check e nome, sem "?"

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a rota autenticada continua; `VenueAmenityAuthorizer` segue amarrando o venue da caracteristica; a permissao da tela nao substitui a API
- erros e mensagens esperadas: recusa em 400 com `{ title, message }`; conflito de nome segue 409; o painel mostra o toast que a secao ja usa
- observabilidade minima: sem metrica, dashboard ou alerta novo; a prova e o teste e o erro HTTP
- concorrencia, idempotencia ou retry: nome unico no venue continua o unico conflito; sem fila, retry ou cache
- rollout, fallback ou degradacao: as colunas ja existem nulas no main (deploy request 43); linha antiga funciona; rollback e parar de ler e gravar os campos

## Casos de erro e borda obrigatorios

- caso: foto e link no mesmo envio
  impacto: os dois sao gravados
  cobertura esperada: `T-01` unitario
- caso: link mp4, `http` ou host que nao e YouTube
  impacto: video recusado, nada e gravado
  cobertura esperada: `T-01` unitario
- caso: arquivo que nao e imagem ou passa de 5 MB
  impacto: foto nao e salva
  cobertura esperada: `T-01` unitario, pela validacao ja usada no upload de imagem
- caso: descricao acima de 500 ou so espacos
  impacto: acima de 500 recusa; so espacos grava nulo
  cobertura esperada: `T-01` unitario
- caso: editar item com foto e informar video
  impacto: `videoUrl` preenchido e `imageUrl` mantido
  cobertura esperada: `T-01` unitario
- caso: editar item com foto e video e apagar a foto
  impacto: `imageUrl` nulo, objeto removido, `videoUrl` mantido
  cobertura esperada: `T-01` unitario
- caso: excluir item com foto
  impacto: a linha some e o objeto da foto e removido
  cobertura esperada: `T-01` unitario
- caso: usuario sem permissao
  impacto: nao grava
  cobertura esperada: `T-01` unitario
- caso: URL de video invalida chega na pagina publica
  impacto: o modal nao monta o player; nome, foto e descricao ainda aparecem; se o video era o unico complemento, o "?" nao aparece
  cobertura esperada: `T-04` unitario
- caso: item com foto e video
  impacto: o modal mostra os dois
  cobertura esperada: `T-04` unitario

## Impacto esperado

O cadastro de caracteristica passa a carregar texto, foto e link do YouTube. O bloco "Conheça nosso espaço" ganha o "?" e o modal. O contrato da apresentacao publica ganha tres campos nulos.

## Areas impactadas

- `backend`: `VenueAmenity`, rotas de criar e editar, use cases, apresentacao da proposta
- `frontend`: formulario da caracteristica, bloco publico da proposta e o modal de detalhe

## Restricoes e cuidados

- as colunas ja existem no main; a migration do repo precisa bater com elas e nao pode ser reaplicada em producao
- producao usa `prisma migrate deploy`, nao `migrate dev`
- a foto reusa o upload publico do servico; nao abrir storage privado
- nao ler nem versionar `.env`
- nao usar `isTourVideoUrl` nem `resolveTourVideo`: os dois aceitam ou reproduzem video de um jeito que esta feature nao usa

## Dependencias

- cadastro `VenueAmenity` e bloco publico ja existem
- upload de imagem do servico ja existe
- `PublicServiceDetailDialog` e o "?" dos servicos ja existem e servem de base para o modal
- validacao de host do YouTube ja existe no schema do tour e deve ser reaproveitada sem aceitar arquivo de video

## Mapeamento leve requisito -> task -> prova

- `R-01` a `R-08` -> `T-01` -> unitario
- `R-09` -> `T-02` -> unitario
- `R-01`, `R-03`, `R-04`, `R-06` no formulario -> `T-03` -> unitario
- `R-07`, `R-10` -> `T-04` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. Premissas e decisoes em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar entrega`
- entrada publica recomendada: `fw:review`
