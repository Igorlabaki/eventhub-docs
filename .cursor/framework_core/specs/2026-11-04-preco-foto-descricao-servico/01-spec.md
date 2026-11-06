# Spec — Preco, foto e descricao do servico

## Problema

O cadastro de `Service` guarda um unico `price`. Criar, editar e recalcular o orcamento somam esse numero inteiro em `getByProposalServiceListTotalAmount`. A pagina publica e o resumo do painel mostram o mesmo numero. Nao ha descricao nem foto. `ProposalService` so liga os ids.

## Objetivos

Um usuario com permissao de editar servicos daquele espaco cadastra preco fixo, por hora ou por pessoa, com descricao e uma foto opcionais. O orcamento grava o valor da linha. A pagina publica mostra a apresentacao e esse valor, sem reescrever um orcamento ja salvo quando o cadastro muda.

## Fora de escopo

- preco por diaria do servico
- modelo de preco, sazonalidade ou preco minimo da locacao do espaco
- `rpaRequired` e `rpaMinPeople`
- coluna `teste` de `ProposalService`
- trocar Float por Decimal
- galeria `Image` da casa, contrato, e-mail e site
- fechar a listagem publica de servicos que o formulario de orcamento ja usa
- autorizacao dos outros cadastros do venue

## User stories ou cenarios principais

- operador cadastra limpeza com preco fixo, open bar por pessoa e DJ por hora, com texto e uma foto
- operador marca esses servicos num orcamento e ve a linha fixa, a linha vezes os convidados e a linha vezes as horas do evento
- cliente abre o link e ve foto, nome e descricao na experiencia, e o valor gravado no investimento
- operador muda o preco no cadastro e o orcamento ja salvo permanece ate salvar de novo ou recalcular
- usuario sem permissao de editar servicos daquele espaco nao grava cadastro nem foto

## Criterios de aceite

- `R-01`: `Service` tem `pricingType` `FIXED`, `PER_HOUR` ou `PER_PERSON`, com padrao `FIXED`. Servico ja existente permanece fixo, sem descricao e sem foto.
- `R-02`: `price` e o valor unitario. A linha e `price` no fixo, `price` vezes as horas do evento na hora, e `price` vezes os convidados na pessoa.
- `R-03`: as horas sao as de `calcEventDuration`: inteiras, wall-clock, com virada de meia-noite. Nao sao o numero de diarias.
- `R-04`: criar, editar e recalcular gravam em `ProposalService` o tipo, o unitario, a quantidade e o valor da linha, e o total do orcamento usa a soma dessas linhas. Editar o cadastro nao altera orcamento ja salvo.
- `R-05`: o preco minimo da casa continua trocando so a locacao. As linhas de servico entram por cima, como hoje.
- `R-06`: id de servico de outro espaco responde erro e nao grava o orcamento. Nome de servico continua unico dentro do espaco.
- `R-07`: descricao e opcional, no maximo 500 caracteres. Foto e opcional, uma por servico, e nao entra na galeria da casa.
- `R-08`: criar, alterar e remover servico, inclusive a foto, exigem `EDIT_VENUE_SERVICES` naquele espaco. Sem a permissao, a API responde 403 e nao grava. A listagem usada pelo formulario publico continua acessivel.
- `R-09`: a foto vai para o mesmo bucket publico das imagens da casa, em WebP. Arquivo acima de 5 MB ou que nao seja imagem responde erro e nao grava. Trocar ou remover a foto nao altera servico de outro espaco.
- `R-10`: na pagina publica, a experiencia mostra foto, nome e descricao dos servicos daquele orcamento. O investimento mostra o valor gravado e a conta (unitario vezes horas ou pessoas). Sem foto, permanece o circulo. Sem descricao, o texto some.
- `R-11`: o formulario do servico e as listas de marcacao do orcamento mostram o tipo junto do unitario. O resumo do painel usa o valor gravado da linha.
- `R-12`: inicio e fim na mesma hora deixam a linha por hora em 0, e o orcamento salvo mostra 0. Orcamento antigo, sem valor gravado na linha, continua mostrando o `price` do cadastro como linha fixa.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: escrita do servico autentica e confere `EDIT_VENUE_SERVICES` no espaco do registro, no mesmo modelo de `VenueRuleAuthorizer`. A tela nao substitui a API. A pagina publica nao ganha tabela de preco alem das linhas daquele orcamento.
- erros e mensagens esperadas: 400 para preco negativo, descricao longa, arquivo invalido e servico de outro espaco; 403 sem permissao; 409 para nome repetido no espaco, como hoje.
- observabilidade minima: a recusa de permissao registra usuario e espaco, como nas regras. Nao ha metrica nem alerta novo.
- concorrencia, idempotencia ou retry: recalcular duas vezes com os mesmos dados grava as mesmas linhas. O total e as linhas do orcamento commitam juntos.
- rollout, fallback ou degradacao: colunas novas sao aditivas. Codigo antigo convive com elas nulas. Orcamento sem linha gravada cai no `price` fixo.

## Casos de erro e borda obrigatorios

- caso: duracao 0 num servico por hora
  impacto: a linha entra como 0 e o total nao inventa hora
  cobertura esperada: unitario no calculo e um save de orcamento
- caso: estadia de varios dias ou pernoite
  impacto: a hora usa o intervalo entre inicio e fim, nao as diarias da locacao
  cobertura esperada: unitario de `calcEventDuration`
- caso: preco minimo da casa menor que a locacao mais servicos
  impacto: o minimo substitui a locacao e os servicos continuam somados
  cobertura esperada: um fluxo de orcamento que ja aplica o minimo
- caso: cadastro muda depois do save
  impacto: a linha gravada permanece ate o proximo save ou recalculo
  cobertura esperada: unitario do recalculo e leitura do orcamento
- caso: arquivo que nao e imagem, ou foto de servico de outro espaco
  impacto: nada e gravado no servico errado
  cobertura esperada: API de servico
- caso: usuario autenticado sem `EDIT_VENUE_SERVICES`
  impacto: 403, sem foto e sem texto novo
  cobertura esperada: API de servico

## Impacto esperado

O valor comercial do orcamento passa a depender da quantidade. A pagina publica ganha apresentacao do servico. A gravacao do servico passa a checar a permissao que a tela ja usa.

## Areas impactadas

- `backend`: schema, cadastro de servico, criacao e edicao de orcamento por pessoa e por dia, recalculo publico
- `frontend`: formulario e lista de servico, marcacao nos formularios de orcamento, resumo do painel, pagina publica
- dados: `service` e `proposalService`
- upload: uma imagem publica por servico

## Restricoes e cuidados

- dinheiro permanece Float, decisao `D-07`
- horario permanece wall-clock, decisao `D-06`
- migration de producao e aditiva e usa `prisma migrate deploy`
- nao ler nem versionar `.env`
- `relationMode = "prisma"`: a checagem de espaco fica na aplicacao

## Dependencias

- `Service`, `ProposalService`, `calcEventDuration` e o upload WebP da galeria ja existem
- `EDIT_VENUE_SERVICES` ja existe no conjunto de permissoes do espaco
- multi-repo: a spec pode ser derivada com `spec-driven/spec-repo-split-prompt.md` antes da execucao

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-03`, `R-07` schema -> `T-01` -> unitario e `prisma validate`
- `R-02`, `R-05`, `R-06`, `R-12` formula -> `T-01` -> unitario
- `R-04`, `R-05` gravacao da linha -> `T-02` -> unitario dos fluxos de orcamento
- `R-06`, `R-07`, `R-08`, `R-09` cadastro -> `T-03` -> unitario da API
- `R-01`, `R-07`, `R-11` tela de cadastro -> `T-04` -> tela do painel
- `R-10`, `R-11`, `R-12` orcamento e link -> `T-05` -> tela do painel e pagina publica

## Perguntas em aberto

Nenhuma bloqueante. Premissas e o risco de cada uma estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
