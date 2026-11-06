# Spec — Video do tour na proposta publica

## Problema

O espaco nao tem um link de tour, e quem abre o orcamento publico nao ve o video do espaco entre o que a experiencia inclui e o valor.

## Objetivos

- gravar o link do tour nas configuracoes do espaco
- mostrar o video na proposta publica so quando o link existir
- tocar sozinho, mudo, em repeticao, sem controle para quem assiste

## Fora de escopo

- upload do arquivo
- video no site, no e-mail, no contrato ou no painel
- Vimeo, Instagram, Google Drive ou pagina generica
- som, legenda ou botao de play
- rota publica nova
- corrigir a autorizacao legada das outras rotas do venue

## User stories ou cenarios principais

- Quem edita o espaco cola um YouTube ou um arquivo `.mp4`, `.webm`, `.ogg` ou `.mov` e salva.
- Quem abre `/proposal/:id/view` ve o tour entre "Sua experiencia inclui" e "Seu investimento".
- Quem apaga o link deixa de ver o video na proxima abertura da proposta.

## Criterios de aceite

- `R-01`: Configuracoes do espaco grava `tourVideoUrl` no venue pela rota `PUT /venue/update`, que ja exige autenticacao.
- `R-02`: Campo vazio ou apagado persiste `null`. A proposta publica nao renderiza player.
- `R-03`: `GET /proposal/presentation/:proposalId` devolve `tourVideoUrl` e continua publico, sem rota nova.
- `R-04`: Link `https` cujo caminho termina em `.mp4`, `.webm`, `.ogg` ou `.mov` vira `<video>` com `autoPlay`, `muted`, `loop`, `playsInline` e sem `controls`, entre a experiencia e o investimento.
- `R-05`: Link do YouTube (`watch`, `youtu.be`, `shorts` ou `embed`, inclusive `m.youtube.com`) vira iframe mudo, em loop, com controles desligados e sem receber clique.
- `R-06`: Qualquer outro valor, inclusive `http`, `javascript:` e pagina HTML, e rejeitado ao salvar com a mensagem "Use um link do YouTube ou um arquivo de video (mp4, webm, ogg ou mov)." e nao vira iframe.
- `R-07`: Sem a secao "Sua experiencia inclui", o video continua imediatamente acima de "Seu investimento".
- `R-08`: A migration so adiciona `tourVideoUrl` nullable. Nao ha backfill, indice nem `NOT NULL`.
- `R-09`: Valor ja gravado que o resolver nao reconhece nao renderiza player.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a gravacao reusa `PUT /venue/update` com `ensureAuthenticate`. A leitura reusa a apresentacao publica. Nao criar permissao nova. D-05 permanece divida fora desta feature.
- erros e mensagens esperadas: erro no campo, em portugues, sem mensagem tecnica do Zod.
- observabilidade minima: sem metrica, log ou alerta novo. A prova e o teste do schema e o video na pagina.
- concorrencia, idempotencia ou retry: nao se aplica. Um save substitui o link anterior.
- rollout, fallback ou degradacao: coluna nova e ignorada pelo codigo antigo. Sem o link, a pagina fica como hoje.

## Casos de erro e borda obrigatorios

- caso: string vazia no update
  impacto: player quebrado ou string vazia no banco
  cobertura esperada: schema transforma `""` em `null`
- caso: URL de pagina ou esquema que nao e `https`
  impacto: iframe arbitrario na proposta publica
  cobertura esperada: schema rejeita; o resolver nao renderiza
- caso: YouTube sem id de 11 caracteres
  impacto: embed invalido
  cobertura esperada: schema rejeita
- caso: arquivo de video com query string
  impacto: link assinado de CDN rejeitado a toa
  cobertura esperada: a extensao vale no caminho, antes da query
- caso: experiencia ausente
  impacto: video some junto com os servicos
  cobertura esperada: o bloco do video nao depende de `serviceList`

## Impacto esperado

Quem configura o espaco passa a salvar o tour. Quem recebe o link do orcamento ve o video no meio da proposta, sem poder pausar ou tirar o mudo.

## Areas impactadas

- `backend`: `Venue`, migration, schemas de update, pacote `getPresentation`
- `frontend`: `VenueSettings`, tipo do venue, `ProposalPresentation`, `ProposalView`

## Restricoes e cuidados

- nao ler nem versionar `.env`
- producao aplica migration com `prisma migrate deploy`, nunca `migrate dev`
- nao embutir o link como pagina
- o video comeca mudo

## Dependencias

- configuracoes do espaco e `GET /proposal/presentation/:proposalId` ja existem
- `T-02` e `T-03` dependem do contrato fechado em `T-01`

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01`, `T-02` -> integracao do formulario com o update
- `R-02` -> `T-01`, `T-03` -> unitario do schema e ausencia do player
- `R-03` -> `T-01` -> unitario do pacote publico
- `R-04`, `R-05`, `R-07`, `R-09` -> `T-03` -> unitario do resolver e pagina publica
- `R-06` -> `T-01`, `T-02` -> unitario do schema e erro no campo
- `R-08` -> `T-01` -> `npx prisma validate` e SQL aditivo

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma de codigo; falta provar a tela
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar entrega` se o usuario pedir
- entrada publica recomendada: `fw:review`
