# Horas escolhidas no servico por hora

## Identificacao

- nome da feature: Pedir quantas horas o cliente quer no servico por hora
- slug: `horas-servico-por-hora`
- status: codigo das 6 tasks escrito; falta prova no browser
- origem: `.cursor/framework_core/task-requests/horas-servico-por-hora-request.md`
- owner: nao documentado

## Objetivo rapido

- problema que resolve: o cliente marca um servico por hora e a linha usa a duracao do evento, sem perguntar quantas horas ele quer
- resultado esperado: o campo aparece ao marcar, a quantidade escolhida entra na linha e o link publico nao troca esse numero ao mudar o horario do evento

## Contexto base

- requests relacionados: `task-requests/horas-servico-por-hora-request.md`
- documentos de produto relacionados: `product/02-business-rules.md#Proposal`, `product/03-user-profiles.md#Cliente proponente`
- topics relacionados: nenhum; valem `project-decisions.md` D-01, D-05, D-06 e D-07
- ADRs relacionados: nenhum

## Estado atual da feature

- fase atual: `T-01` a `T-06` escritas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta provar o campo no browser

## Observacoes

- restricoes: sem coluna nova; painel sem campo novo; resposta publica sem preco unitario
- riscos principais: hora omitida cair na duracao do evento, ou hora zero zerar uma linha de evento longo
