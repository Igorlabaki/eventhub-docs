# Solicitacao da Tarefa

## Nome sugerido da tarefa

Aplicar adicionais e descontos na edicao do orcamento

## Resumo da solicitacao

Ao editar um orcamento, o valor recalculado ignora adicionais e descontos que a criacao ja aplica. A edicao automatica deve chegar no mesmo total que um orcamento novo com os mesmos dados. Valor digitado a mao continua sendo o total final.

## Context Pack

- frente principal: calculo de valor do orcamento no `backend`
- superficie sensivel: nao
- risco principal: gravar total errado e substituir um valor que ja tinha adicional ou desconto
- repos tocados: `backend` (`art56_server_v3/`)
- fora de escopo operacional: cadastro de adicional/desconto, tela de edicao, contrato novo de API, schema e extracao de helper compartilhado
- prova minima desta execucao: no `backend`, um orcamento recalculado na edicao, sem total digitado, fica igual ao total da criacao para a mesma data, convidados e modelo de preco; um total digitado a mao e gravado como informado
- criterio de escalada: promover para `spec` ou dividir por repo se a correcao exigir mudanca de contrato no `frontend` ou regra nova alem da paridade com a criacao
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/use-cases/proposal/update-proposal-per-person/use-case-update-proposal-per-person.ts` e `art56_server_v3/src/use-cases/proposal/update-proposal-per-day/use-case-update-proposal-per-day.ts`
- libs obrigatorias: `node`, `patterns`
- documentos obrigatorios:
  - `.cursor/framework_global/framework-libs/node/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
  - `art56_server_v3/src/use-cases/proposal/create-proposal-per-person/use-case-create-proposal-per-person.ts` (trecho que aplica `seasonalFee`)
  - `art56_server_v3/src/use-cases/proposal/create-proposal-per-day/use-case-create-proposal-per-day.ts` (trecho que aplica `seasonalFee`)
- caminhos candidatos: modelos `PER_PERSON`, `PER_PERSON_HOUR`, `PER_DAY` e `PER_PERSON_DAY` nos use cases de update
- palavras-chave ou simbolos de busca: `seasonalFee`, `SURCHARGE`, `totalAmountInput`, `pricePerPerson`, `pricePerDay`
- testes provaveis: `npm test -- --run` em `art56_server_v3/`
- nao ler por padrao: `security`, `design`, `database`, `observability`, `react`

## Contexto informado na entrada

Pedido: ao editar um valor do orcamento, adicionais e descontos nao entram. Na criacao, esses ajustes de temporada ja alteram o preco antes do total. Na edicao, o recálculo usa o preco de tabela ou o numero digitado, sem esse ajuste.

## Problema atual

Salvar a edicao de um orcamento pode gravar um total sem adicional nem desconto, mesmo quando a criacao do mesmo evento aplicaria os dois. Se o campo de total nao muda, a edicao recalcula pelo preco cru e apaga o ajuste que ja estava no orcamento.

## Objetivo da mudanca

O total recalculado na edicao, quando o usuario nao informa um valor manual, fica igual ao total que a criacao produziria para a mesma data, convidados, duracao, servicos e modelo de preco, incluindo adicionais e descontos vigentes.

## Escopo inicial percebido

Ajuste no calculo dos use cases de update de orcamento por pessoa e por dia. Sem tela nova e sem mudanca de cadastro dos adicionais e descontos.

## Itens incluidos neste request

- recálculo automatico da edicao aplica os adicionais e descontos da data do evento
- troca de data reavalia quais ajustes entram
- total digitado a mao permanece o valor gravado
- permuta continua com total zero

## Requisitos implicitos ja visiveis

- adicional soma percentual e desconto subtrai, como na criacao
- servicos e hora extra continuam entrando no total depois do preco ajustado
- preco minimo existente na criacao nao pode ser ignorado so na edicao
- o aumento de meta usado na criacao entra no recálculo, para o total editado nao divergir de um orcamento novo

## Casos de erro e borda ja percebidos

- intervalo de adicional ou desconto que cruza a virada do ano
- ajuste por dia da semana, inclusive quando vale para todos os dias
- data fora da vigencia nao deve manter o percentual antigo
- total informado a mao nao deve receber percentual por cima
- orcamento de permuta nao deve ganhar valor

## Dependencias

- adicionais e descontos ja cadastrados no espaco
- regra atual de criacao do orcamento, que e a referencia do total esperado

## Restricoes e cuidados

- nao alterar o cadastro nem a formula de quem cria o orcamento, salvo o necessario para a edicao repetir o mesmo resultado
- nao sobrescrever total negociado digitado na edicao
- nao abrir mudanca de schema, pagamento ou contrato de API

## Perguntas em aberto

- O aumento de meta entra neste ajuste? Premissa: sim, porque faz parte do total da criacao e a edicao automatica deve bater com ele.
- Total digitado a mao recebe adicional e desconto por cima? Premissa: nao. O numero informado e o total final.
- A tela de edicao precisa mudar? Premissa: nao. O `frontend` so exibe o total devolvido pelo `backend`.

## Prioridade sugerida

alta

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

Calculo de valor em fluxos que ja existem, com um objetivo so. Nao e feature nova nem pacote de varias tasks.

## Candidato a spec

- `nao`
- motivo: a mudanca e paridade do recálculo da edicao com a criacao, no `backend`, sem jornada nem contrato novo

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `edicao-orcamento-adicionais-descontos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
- status: implementado no `backend`, aguardando revisao da entrega
- prova executada: `npx vitest --run` nos specs de ajuste de preco e de update por pessoa e por dia, 11 testes passando
