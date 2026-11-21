# Clarify — Icone da aba do espaco

## Perguntas criticas

- O campo entra na criacao e na configuracao? Fechado: nos dois, ao lado do logo.
- Quais telas usam o icone? Fechado: as cinco que ja trocam `document.title`.
- Sem icone, a aba fica com o favicon do EventHub? Fechado: sim, `/favicon.ico`.
- Arquivo novo substitui e campo vazio apaga? Fechado: substitui; vazio nao apaga.
- Qual arquivo vale? Fechado: `image/*`, com texto de que fica melhor quadrado e pequeno.
- Qual o nome da coluna? Fechado no design: `faviconUrl`.

## Respostas confirmadas

- o icone e outro arquivo; o logo nao vira icone da aba
- so `<link rel="icon">`; sem apple-touch-icon, manifest ou PWA
- sem recorte e sem tamanhos gerados
- sem botao de remover nesta v1
- o texto da aba e `venueTabTitle` nao mudam
- a migration fica no repositorio e nao entra na `main` sem aprovacao nomeada

## Requisitos implicitos confirmados

- create e update do espaco ja exigem autenticacao; o icone usa essas rotas
- `GET /venue/getById` ja devolve o espaco inteiro, inclusive para as listas publicas que passam por `usePublicListVenue`; a coluna nova aparece nessa resposta sem rota nova
- a apresentacao do espaco e a do orcamento usam `select` explicito e precisam listar `faviconUrl`
- o corpo do update hoje tira `logoUrl` e so grava a URL que o arquivo gerou; o icone segue essa regra

## Premissas assumidas

- nao ha limite novo de tamanho; o logo tambem nao tem. Risco: um arquivo enorme vira o icone da aba. A execucao nao cria limite.
- `image/*` inclui SVG. Risco: um SVG ruim pode ser o icone. A execucao nao cria uma lista extra de tipos.
- `PublicVenueListShell` cobre listas, regras e contratos publicos porque essas paginas ja trocam o titulo por esse componente. Nao e pagina nova.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Falha de upload, tipo invalido, troca de casa e saida da tela estao em `R-04`, `R-05`, `R-08` e `R-09`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` pode comecar. O nome `faviconUrl`, o campo `favicon` e a ordem subir-antes-de-apagar ja estao no design.
