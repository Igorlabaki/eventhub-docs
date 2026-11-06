# Spec — Lista de servicos no painel

## Problema

Criar e editar orcamento no painel mostram os servicos na mesma linha, com o preco entre parenteses. Nao ha "Obrigatório a partir de N pessoas.". Marcar um servico por hora nao pede a quantidade. Na criacao, `serviceHours` sai da duracao do evento. Na edicao, a API descarta `serviceHours` e a linha volta a usar essa duracao.

O link publico de criar orcamento ja empilha os servicos, mostra o texto de obrigatorio e, no servico por hora marcado, pede "Quantas horas?".

## Objetivos

Quem cria ou edita um orcamento no painel ve uma linha por servico, o texto de obrigatorio quando houver minimo de pessoas, e o campo de horas quando o servico por hora estiver marcado. A quantidade digitada e a que fica na linha. A duracao do evento so limita o teto.

## Fora de escopo

- redesenhar o link publico de criar orcamento e o modal de servicos do link
- esconder o preco, ou acrescentar foto, descricao e icone de detalhe, na linha do painel
- preco da locacao, cadastro da regra de obrigatoriedade e novo tipo de preco
- tela nova de edicao de pernoite; a unica tela de editar continua sendo a por pessoa
- coluna, migration, troca de `Float` e troca da semantica wall-clock

## User stories ou cenarios principais

- No painel, a operadora ve Recepcionista, Limpeza, Painel de Led e Seguranca um embaixo do outro. O servico obrigatorio a partir de 120 pessoas mostra esse texto. Com 120 convidados, o checkbox marca e trava.
- Ela marca Painel de Led, informa 3 em "Quantas horas?" e o orcamento grava quantidade 3. Desmarcar esconde o campo.
- Ela abre o mesmo orcamento para editar, ve 3 no campo, troca para 2 e a linha fica com 2.

## Criterios de aceite

- `R-01`: Em criar orcamento por pessoa e por dia no painel, os servicos ficam um por linha, ordenados pelo minimo de pessoas como no link publico. O preco continua ao lado do nome. Nao ha controle de foto ou descricao.
- `R-02`: Servico com `rpaRequired` e `rpaMinPeople` mostra "Obrigatório a partir de 1 pessoa." ou "Obrigatório a partir de N pessoas.". Com convidados maiores ou iguais ao minimo, o checkbox marca e trava. Abaixo do minimo, destrava e continua marcado se ja estava.
- `R-03`: Servico `PER_HOUR` marcado mostra "Quantas horas?" fora do `label` do checkbox. Desmarcar esconde o campo e descarta o valor. `FIXED` e `PER_PERSON` nao mostram o campo. Servico por hora obrigatorio tambem mostra o campo, vazio ate alguem digitar.
- `R-04`: Horas vazias, zero com evento longo, negativas, fracionadas, acima de 8760 ou acima da duracao do evento impedem o envio. O erro fica no campo e o que foi digitado permanece. Acima da duracao, a frase "O serviço não pode ter mais horas do que o evento (N horas)." aparece na hora. Igual a duracao nao e erro.
- `R-05`: Criar por pessoa e por dia envia as horas digitadas em `serviceHours`. Nao envia a duracao do evento. Tres horas gravam quantidade 3 e valor unitario vezes 3.
- `R-06`: `PUT /updatePerPerson` e `PUT /updatePerDay` aceitam `serviceHours` com as mesmas regras da criacao. Hora ausente ou invalida num servico por hora responde erro, nao grava e nao cai na duracao do evento. Servico fixo sem `serviceHours` continua gravando.
- `R-07`: A tela de editar orcamento usa a mesma lista. O campo do servico por hora abre com a quantidade gravada. Salvar outro inteiro valido atualiza a linha. So abrir a tela nao reescreve o orcamento.
- `R-08`: Formularios publicos, modal do link, preco da locacao e cadastro do servico permanecem como estao.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: criar e editar no painel continuam autenticados. O servidor valida as horas. O cliente nao envia unitario nem valor da linha.
- erros e mensagens esperadas: "Informe um número inteiro de horas para o serviço." e a frase de teto pela duracao do evento, no proprio campo.
- observabilidade minima: sem metrica nova. O historico de atualizacao do orcamento permanece o que ja existe.
- concorrencia, idempotencia ou retry: duas gravacoes seguidas ficam com a ultima. Sem lock, fila ou retry novo.
- rollout, fallback ou degradacao: sem coluna nova. A edicao passa a exigir `serviceHours` para servico por hora; a tela de editar precisa sair no mesmo lote do backend.

## Casos de erro e borda obrigatorios

- caso: horas ausentes, 0 com evento longo, negativas, fracionadas, acima de 8760 ou acima da duracao
  impacto: a linha nao pode cair na duracao do evento nem zerar
  cobertura esperada: unitario da edicao e browser de criar e editar
- caso: duracao do evento igual a 0
  impacto: zero continua valido, como na criacao
  cobertura esperada: unitario da edicao
- caso: desmarcar e marcar de novo, ou o obrigatorio por hora entrar porque os convidados subiram
  impacto: o campo volta vazio e o envio nao segue sem horas
  cobertura esperada: browser de criar
- caso: orcamento antigo cuja quantidade por hora era a duracao do evento
  impacto: a edicao mostra esse numero e nao troca sozinha
  cobertura esperada: browser de editar
- caso: convidados caem abaixo do minimo
  impacto: o checkbox destrava e permanece marcado
  cobertura esperada: browser de criar
- caso: publicar so o backend da edicao
  impacto: salvar servico por hora na tela antiga falha
  cobertura esperada: nota de rollout; a prova da feature e o lote junto

## Impacto esperado

No painel, a hora do servico deixa de ser a duracao do evento. A premissa de `specs/2026-11-04-horas-servico-por-hora` que deixava o painel de fora fica valendo so para o que esta fora deste escopo. O dinheiro continua em `Float`.

## Areas impactadas

- `backend`: edicao por pessoa e por dia
- `frontend`: os dois formularios de criar no painel e a tela de editar
- produto: uma frase em `product/02-business-rules.md#Proposal`

## Restricoes e cuidados

- D-01: o contrato e unico; a execucao repo-local vem depois, por `fw:split`
- D-06: o teto de horas usa o mesmo wall-clock da criacao
- D-07: o valor da linha continua `Float`
- nao ler nem versionar `.env`

## Dependencias

- `quoteServiceLines`, `assertChosenServiceHours` e `serviceHours` na criacao ja existem
- `chosenServiceHours`, `serviceHourFieldError`, `sameDayEventHours` e `stayEventHours` ja existem no frontend
- a lista, o texto e o campo do link publico sao o modelo e nao entram no diff
- nao ha tela de edicao de pernoite; `PUT /updatePerDay` muda o contrato para nao continuar cotando pela duracao

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-02` -> browser
- `R-02` -> `T-02` -> browser
- `R-03` -> `T-02` -> browser
- `R-04` -> `T-02`, `T-03` -> browser
- `R-05` -> `T-02` -> browser
- `R-06` -> `T-01` -> unitario
- `R-07` -> `T-03` -> browser
- `R-08` -> `T-02`, `T-03` -> browser

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md#Premissas assumidas`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
