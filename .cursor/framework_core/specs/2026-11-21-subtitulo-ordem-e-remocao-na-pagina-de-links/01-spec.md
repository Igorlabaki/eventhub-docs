# Spec — Subtitulo, ordem e remocao na pagina de links

## Problema

Em `/espaco/{casa}/links` o botao so tem o titulo do catalogo. A ordem e o que aparece so mudam em Configuracoes, na aba Redes, no Salvar. Na propria pagina ninguem arrasta nem tira um link.

## Objetivos

Cada botao visivel mostra um subtitulo embaixo do titulo. Quem tem Site naquele espaco reordena na propria pagina, no mesmo criterio das fotos da apresentacao, e so omite um link depois de confirmar.

## Fora de escopo

- texto livre de subtitulo e edicao desse texto na pagina ou na aba Redes
- apagar a linha do catalogo
- mudar a lixeira da aba Redes, que continua sem este dialogo e so no link colado
- tipo novo, nome livre de botao, parceiro ou colaborador
- mover icone, seta ou titulo do card
- permissao nova
- schema ou migration

## User stories ou cenarios principais

- Visitante abre a pagina, le titulo e subtitulo e clica no botao. Nao ve alca nem Remover.
- Quem tem Site arrasta WhatsApp para cima de Regras, recarrega e ve a ordem nova.
- Quem tem Site pede para remover Instagram, cancela e o botao continua. Confirma e o botao some. Na aba Redes o olho mostra de novo.

## Criterios de aceite

- `R-01`: cada link do `GET` publico traz `subtitle` da frase fixa do tipo, a tabela de `03-design.md#Subtitulos`
- `R-02`: a pagina mostra o subtitulo embaixo do titulo; subtitulo ausente deixa so o titulo
- `R-03`: `canReorder` e verdadeiro so quando o usuario opcional tem `EDIT_VENUE_SITE` naquele espaco; o payload nao inclui link oculto nem link sem destino
- `R-04`: sem `canReorder` a pagina nao mostra alca nem Remover
- `R-05`: com Site e mais de um botao, arrastar grava a ordem, ela sobrevive a recarregar, e os links ocultos ficam nos mesmos intervalos da lista completa
- `R-06`: a mesma ordem, ou ocultar um tipo que ja nao aparece, responde 200 e nao grava de novo
- `R-07`: ordem que nao e exatamente o conjunto mostrado responde 400 e nao muda posicao nem `visible`
- `R-08`: Remover abre "Tem certeza que quer remover?"; cancelar mantem o botao
- `R-09`: confirmar grava `visible` falso, o botao sai da pagina e a linha continua na aba Redes
- `R-10`: os dois `PUT` exigem sessao; 401 sem token, 403 sem Site, 404 espaco ausente
- `R-11`: falha ao gravar devolve a ordem ou o botao anterior
- `R-12`: o arraste nao abre o destino; o clique de quem visita abre
- `R-13`: um unico botao visivel tem Remover e nao tem alca

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: `GET` le usuario opcional; `PUT` passa por `ensureAuthenticate` e `canEditVenueSite` no id real da casa, nao no texto da URL. A aba Redes continua em `EDIT_VENUE_INFO`
- erros e mensagens esperadas: 400 com a mensagem ja usada no use case de links; a pagina nao manda para `/login` — `/espaco/:id/links` e `/venue/:id/links` ja estao em `PUBLIC_ROUTES`
- observabilidade minima: o status HTTP prova a gravacao. Nao logar href, WhatsApp nem e-mail
- concorrencia, idempotencia ou retry: a ultima gravacao vence; ordem igual ou tipo ja oculto nao escreve
- rollout, fallback ou degradacao: sem flag e sem migration. Cliente antigo ignora `subtitle` e `canReorder`

## Casos de erro e borda obrigatorios

- caso: sessao de outra casa, ou token ausente no `PUT`
  impacto: nao altera os links desta casa
  cobertura esperada: unitario do use case, 401 e 403
- caso: lista de ordem com tipo repetido, oculto ou faltando um botao mostrado
  impacto: a lista gravada permanece
  cobertura esperada: unitario, 400
- caso: um so botao, ou confirmacao cancelada, ou rede falha no meio
  impacto: nao ha alca; cancelar nao chama o `PUT`; falha restaura o estado anterior
  cobertura esperada: teste do componente da pagina
- caso: espaco inexistente
  impacto: 404, sem dado de outra casa
  cobertura esperada: unitario

## Impacto esperado

A pagina de links passa a explicar cada botao e a deixar quem tem Site ajustar ordem e presenca sem abrir Configuracoes. Visitante so ve o que ja estava ligado, com a segunda linha.

## Areas impactadas

- backend: leitura publica dos links e duas gravacoes novas de ordem e de ocultar
- frontend: `VenueLinks`
- docs: `project/api-endpoints.md` e `topics/public-pages-and-branding.md#Demais paginas publicas`

## Restricoes e cuidados

Nao reutilizar o `PUT /venue/links/:venueId` da aba Redes a partir da pagina. Aquele save troca a lista inteira, regrava URL e as quatro colunas, e autoriza `EDIT_VENUE_INFO`.

## Dependencias

A pagina, a aba Redes e o arraste das fotos da apresentacao ja existem.

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-03` -> `T-01` -> unitario
- `R-05`, `R-06`, `R-07`, `R-09`, `R-10` -> `T-02` -> unitario
- `R-02`, `R-04`, `R-08`, `R-11`, `R-12`, `R-13` -> `T-03` -> unitario

## Perguntas em aberto

As frases do subtitulo e o significado de "omite" estao em `02-clarify.md`, com premissa. Nenhuma bloqueia `T-01`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`

## Base documental

- `task-requests/subtitulo-ordem-e-remocao-links-request.md`
- `topics/public-pages-and-branding.md#Demais paginas publicas`
- `topics/permissions-catalog.md` na linha `venue-site-edit-permission`
- `project/api-endpoints.md` nas linhas de `GET /venue/presentation/:venueId` e `PUT /venue/presentation/:venueId/image-order`
- `framework-libs/security/references/auth-and-access-control.md#Principios`
- `framework-libs/patterns/index.md#Aplicar conceito distribuido`
- `framework-libs/design/index.md#Criar ou evoluir componente`
