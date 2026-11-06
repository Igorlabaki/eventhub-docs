# Spec — Limite de horas do servico pela duracao do evento

## Problema

No modal "Adicionar servico" e na criacao publica do orcamento, "Quantas horas?" aceita qualquer inteiro de 1 a 8760. A frase atual so fala de numero inteiro e so aparece ao confirmar ou enviar. A API grava essa quantidade, mesmo acima da duracao do evento.

## Objetivos

Informar mais horas do que o evento dura nao grava. A mensagem no campo aparece assim que o numero passa da duracao. Quantidade igual a duracao continua valida.

## Fora de escopo

- campo de horas no painel interno
- preco fixo, preco por pessoa e preco da locacao
- obrigatoriedade do servico por numero de pessoas
- reescrever orcamento ja salvo, ou o recalculo publico, so porque a quantidade antiga passa da duracao nova
- coluna, migration e mudanca de `Float` ou de wall-clock

## User stories ou cenarios principais

- No modal, o evento dura 6 horas. A cliente digita 7 em "Painel de Led" e ve na hora que nao pode passar da duracao. Digita 6, a frase some e confirmar grava 6.
- Na criacao publica, o mesmo teto vale por pessoa e por dia. Enviar 7 horas num evento de 6 nao cria o orcamento.
- Um orcamento ja salvo com 10 horas nao muda sozinho. Encurtar o horario no link nao troca essa quantidade.

## Criterios de aceite

- `R-01`: Nos formularios publicos por pessoa e por dia, assim que o inteiro digitado passa da duracao do evento, o campo mostra "O serviço não pode ter mais horas do que o evento (N horas)." Com N igual a 1, a frase usa "1 hora". Apagar o campo ou voltar a um inteiro de 1 ate a duracao tira essa frase. Igual a duracao nao e erro.
- `R-02`: Enviar com horas acima da duracao nao cria o orcamento. O erro fica no campo, o que foi digitado permanece e o passo continua em "Como nos encontrou".
- `R-03`: No modal "Adicionar servico", a mesma frase aparece na hora. Valor ja preenchido acima da duracao mostra a frase ao abrir. Confirmar nao chama a API enquanto a frase estiver visivel. Orcamento aprovado ou pago continua sem gravar.
- `R-04`: `POST /proposal/createPerPerson` e `POST /proposal/createPerDay` recusam, para servico `PER_HOUR`, horas acima de `calcEventDuration`. A resposta usa a mesma frase e nada e gravado. Horas iguais a duracao gravam. Ausencia, zero com evento longo, negativo, fracao e acima de 8760 continuam com "Informe um número inteiro de horas para o serviço."
- `R-05`: `PUT` dos servicos publicos recusa o mesmo caso, com a mesma frase, e nao grava. A leitura publica nao muda.
- `R-06`: O recalculo publico de dia, convidados ou horario conserva a quantidade ja gravada do servico por hora, mesmo se ela passar a ser maior que a duracao nova. `quantityFor` nao aplica este teto.
- `R-07`: Os formularios do painel continuam sem o campo e enviam a duracao do evento. Esse envio segue gravando, inclusive 0 quando inicio e fim caem na mesma hora.
- `R-08`: No formulario por pessoa, o teto so entra quando o fim e posterior ao inicio no mesmo dia. Intervalo incompleto ou invertido nao mostra a frase de duracao. No formulario por dia, a duracao vai do check-in do primeiro dia ao check-out do ultimo, com a mesma conta de pernoite ja usada na cotacao.
- `R-09`: `product/02-business-rules.md#Proposal` e `product/03-user-profiles.md#Cliente proponente` passam a dizer que a quantidade nao passa da duracao do evento.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: criar orcamento e gravar servicos pelo link seguem publicos. O servidor valida o teto. A tela nao substitui a API.
- erros e mensagens esperadas: a frase nova fica no campo. A frase antiga de inteiro permanece para o que nao e inteiro valido.
- observabilidade minima: sem metrica nova. O sinal e a resposta HTTP e o historico que ja existe quando a gravacao publica sucede.
- concorrencia, idempotencia ou retry: selecao repetida com as mesmas horas validas continua sem gravar de novo. Sem lock, fila ou retry novo.
- rollout, fallback ou degradacao: sem coluna. Orcamento antigo fica como esta ate a pessoa informar as horas de novo.

## Casos de erro e borda obrigatorios

- caso: inteiro uma hora acima da duracao
  impacto: nao grava e a frase aparece antes de confirmar
  cobertura esperada: unitario da criacao e da gravacao publica; formulario e modal
- caso: inteiro igual a duracao
  impacto: grava
  cobertura esperada: unitario da criacao e da gravacao publica
- caso: duracao 0 e inteiro positivo
  impacto: a frase de duracao aparece e a API recusa
  cobertura esperada: unitario
- caso: zero, ausencia, fracao, negativo ou acima de 8760
  impacto: continua a frase de inteiro, nao a de duracao
  cobertura esperada: unitario existente mais um caso que distingue as duas frases
- caso: recalculo encurta o evento e a quantidade gravada fica maior
  impacto: a quantidade permanece
  cobertura esperada: unitario do recalculo ou de `quantityFor` com mapa acima da duracao
- caso: painel envia exatamente a duracao, inclusive 0
  impacto: continua gravando
  cobertura esperada: unitario da criacao
- caso: modal abre com valor ja acima da duracao
  impacto: a frase esta visivel e confirmar nao chama a API
  cobertura esperada: modal
- caso: fim anterior ao inicio no formulario por pessoa
  impacto: nao usa a frase de duracao
  cobertura esperada: formulario por pessoa

## Impacto esperado

A quantidade escolhida pelo cliente fica limitada a duracao do evento nos dois lugares em que ela e digitada. A premissa de conservar a quantidade no recalculo publico permanece. O dinheiro continua em `Float`.

## Areas impactadas

- `backend`: a checagem na criacao por pessoa e por dia e na gravacao publica de servicos
- `frontend`: os dois formularios publicos e o modal do link
- produto: uma frase em `product/02-business-rules.md#Proposal` e o complemento em `product/03-user-profiles.md#Cliente proponente`

## Restricoes e cuidados

- D-01: o contrato e unico; a execucao repo-local vem depois, por `fw:split`, se a sessao for separada por repositorio
- D-05: a tela nao substitui a validacao da API publica
- D-06: inicio, fim e pernoite continuam wall-clock; o teto usa `calcEventDuration` e `eventDurationHours`, nao o arredondamento exibido no link
- D-07: sem migrar o dinheiro para centavos
- nao ler nem versionar `.env`

## Dependencias

- o campo "Quantas horas?" e a gravacao de `serviceHours` ja existem
- `assertChosenServiceHours` ja roda na criacao; `resolvePublicHours` ja roda no ajuste publico
- `quoteServiceLines` ja e a conta do recalculo e nao pode ganhar este teto

## Mapeamento leve requisito -> task -> prova

- `R-04`, `R-05`, `R-06`, `R-07` -> `T-01` -> unitario
- `R-01`, `R-02`, `R-03`, `R-08`, `R-09` -> `T-02` -> unitario do helper e browser

## Perguntas em aberto

Nenhuma bloqueante. Premissas estao em `02-clarify.md`.

## Base documental

- `task-requests/limite-horas-servico-duracao-evento-request.md`
- `product/02-business-rules.md#Proposal`
- `product/03-user-profiles.md#Cliente proponente`
- `project/project-decisions.md#D-05`, `#D-06`, `#D-07`
- `specs/2026-11-04-horas-servico-por-hora/01-spec.md#Criterios de aceite`

## Operacao

- tipo: `spec`
- proxima task: nenhuma
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `nao feita; o lote foi pedido direto`
- proxima acao: `revisar entrega`
- entrada publica recomendada: `fw:review` + `entrega`
