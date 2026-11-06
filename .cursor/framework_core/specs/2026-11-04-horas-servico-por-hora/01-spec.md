# Spec — Horas escolhidas no servico por hora

## Problema

No passo "Como nos encontrou", um servico por hora aparece com o rotulo "/hora". Marcar so envia o id. A quantidade da linha sai das horas inteiras entre o inicio e o fim do evento. O cliente nao diz quantas horas quer daquele servico. O mesmo vale ao marcar um servico por hora no link publico.

## Objetivos

O cliente marca o servico, informa um inteiro de horas e o orcamento grava essa quantidade. Servico fixo e por pessoa continuam sem o campo. O painel segue gravando a duracao do evento, sem input novo. Mudar dia, convidados ou horario no link nao substitui as horas ja escolhidas.

## Fora de escopo

- preco fixo, preco por pessoa e preco da locacao
- regra de obrigatoriedade a partir de N pessoas
- foto, descricao e cadastro do tipo de preco
- input de horas no painel, na edicao autenticada e em `ProposalEdit`
- coluna nova, migration e rate limit proprio
- trocar `Float` do dinheiro ou a semantica wall-clock do horario

## User stories ou cenarios principais

- A cliente marca "Painel de Led (R$ 250,00/hora)", ve "Quantas horas?", informa 3 e o orcamento grava quantidade 3.
- Ela desmarca o servico e o campo some. Limpeza, recepcionista e seguranca, quando nao sao por hora, nao ganham campo.
- No link, ela marca o mesmo tipo de servico, informa as horas e o total muda. Alterar o horario do evento nao troca essa quantidade.

## Criterios de aceite

- `R-01`: Nos formularios publicos por pessoa e por dia, no passo "Como nos encontrou", servico marcado com `pricingType` `PER_HOUR` mostra o rotulo "Quantas horas?" e um input numerico fora do `label` do checkbox. Desmarcar esconde o campo e descarta o valor. `FIXED` e `PER_PERSON` nao mostram o campo.
- `R-02`: Servico por hora obrigatorio, com checkbox marcado e desabilitado, tambem mostra o campo.
- `R-03`: Enviar com horas vazias, zero, negativas ou fracionadas nao cria o orcamento. O erro fica no campo e o passo permanece em "Como nos encontrou". O que ja foi digitado permanece.
- `R-04`: `POST /proposal/createPerPerson` e `POST /proposal/createPerDay` exigem, para cada id `PER_HOUR` em `serviceIds`, um item de `serviceHours` com inteiro de 1 a 8760. Ausencia, zero com evento de duracao maior que zero, negativo, fracao e acima de 8760 respondem erro e nao gravam. A linha fica com essa quantidade e com valor unitario vezes a quantidade.
- `R-05`: Os formularios do painel que criam orcamento nao mostram o campo. Enviam em `serviceHours` as horas inteiras do evento, as mesmas de `calcEventDuration`, inclusive 0 quando inicio e fim caem na mesma hora e inclusive pernoite. `PUT /updatePerPerson` e `PUT /updatePerDay` nao mudam e continuam cotando pela duracao do evento.
- `R-06`: `GET /proposal/presentation/:proposalId/services` inclui `hourly` e `hours` em cada item. `hours` e a quantidade gravada quando o servico por hora ja esta no orcamento; senao e nulo. A resposta continua sem `pricingType`, `price` e `unitPrice`.
- `R-07`: `PUT` dessa rota aceita `serviceHours`. Servico por hora novo, ou obrigatorio que ainda nao estava no orcamento, sem inteiro valido responde erro e nao grava. Horas novas de uma linha ja gravada atualizam quantidade e valor a partir do unitario ja gravado. O mesmo conjunto de ids com as mesmas horas nao chama `update` nem historico.
- `R-08`: O modal "Adicionar servico" mostra o campo nos itens `hourly` marcados, preenchido com `hours` quando houver. Confirmar envia essas horas. Orcamento aprovado ou pago continua sem gravar.
- `R-09`: O recalculo publico de dia, convidados ou horas do evento conserva a quantidade ja gravada do servico por hora. O valor da linha passa a ser o unitario atual do cadastro vezes essa quantidade. Servico por pessoa continua seguindo os convidados novos. Linha por hora sem quantidade gravada continua usando a duracao do evento.
- `R-10`: Orcamento ja salvo nao e reescrito so pela entrada desta feature. Falha de rede no modal conserva o total e o que foi digitado.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: criar orcamento e gravar servicos pelo link seguem publicos, sem `ensureAuthenticate`. O servidor valida as horas. O cliente nao envia unitario nem valor da linha.
- erros e mensagens esperadas: "Informe um número inteiro de horas para o serviço." A tela usa essa frase no campo, nao um banner tecnico.
- observabilidade minima: sem metrica nova. O sinal continua o historico "Cliente atualizou os serviços pelo link" e a resposta HTTP.
- concorrencia, idempotencia ou retry: a mesma selecao com as mesmas horas nao grava de novo. Duas gravacoes seguidas ficam com a ultima. Sem lock, fila ou retry novo.
- rollout, fallback ou degradacao: sem coluna nova. Painel e formulario publico precisam sair juntos, porque a criacao passa a exigir `serviceHours` para servico por hora.

## Casos de erro e borda obrigatorios

- caso: horas ausentes, 0 com evento longo, negativas, fracionadas ou acima de 8760
  impacto: a linha nao pode cair na duracao do evento nem zerar
  cobertura esperada: unitario da cotacao e dos use cases de criacao e de gravacao publica
- caso: duracao do evento igual a 0 no painel
  impacto: a linha por hora continua quantidade 0, como hoje
  cobertura esperada: unitario da criacao
- caso: so as horas mudam, os ids nao
  impacto: o total muda e uma selecao repetida nao grava de novo
  cobertura esperada: unitario do use case publico
- caso: recalculo publico muda o horario do evento
  impacto: a quantidade escolhida permanece
  cobertura esperada: unitario do recalculo
- caso: orcamento aprovado ou pago, e falha de rede no modal
  impacto: nada e gravado e o texto digitado fica
  cobertura esperada: unitario do use case e browser do modal
- caso: desmarcar e marcar de novo, ou o obrigatorio entrar porque os convidados mudaram
  impacto: o campo volta vazio e o envio nao segue sem horas
  cobertura esperada: browser do formulario publico

## Impacto esperado

A hora do servico deixa de ser sempre o intervalo do evento quando o cliente escolhe a quantidade. A premissa de `specs/2026-11-04-preco-foto-descricao-servico` fica valendo para o painel na edicao autenticada e para linha antiga sem quantidade. O dinheiro continua em `Float`.

## Areas impactadas

- `backend`: `quoteServiceLines`, criacao por pessoa e por dia, leitura e gravacao publica de servicos, recalculo publico
- `frontend`: os dois formularios publicos, os dois formularios de criacao do painel e o modal do link
- produto: uma frase em `product/02-business-rules.md#Proposal` e o complemento em `product/03-user-profiles.md#Cliente proponente`

## Restricoes e cuidados

- D-01: o contrato e unico e a execucao repo-local vem depois, por `fw:split`
- D-05: a tela nao substitui a validacao da API publica
- D-06: inicio, fim e pernoite continuam wall-clock
- D-07: sem migrar o dinheiro para centavos
- nao ler nem versionar `.env`

## Dependencias

- `pricingType` e as colunas `quantity`, `unitPrice` e `amount` de `ProposalService` ja existem
- `quoteServiceLines` ja e a conta unica usada na criacao, na edicao, no recalculo e na gravacao publica
- `POST /proposal/createPerPerson` e `POST /proposal/createPerDay` nao usam `ensureAuthenticate` e atendem o formulario publico e o painel

## Mapeamento leve requisito -> task -> prova

- `R-04` -> `T-01`, `T-02` -> unitario
- `R-05` -> `T-02`, `T-03` -> unitario e browser
- `R-01`, `R-02`, `R-03` -> `T-03` -> browser
- `R-06`, `R-07` -> `T-04` -> unitario
- `R-08`, `R-10` -> `T-05` -> browser
- `R-09` -> `T-06` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. Premissas e o teto tecnico estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
