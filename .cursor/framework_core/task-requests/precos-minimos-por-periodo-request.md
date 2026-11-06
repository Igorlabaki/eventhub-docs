# Solicitacao da Tarefa

## Nome sugerido da tarefa

Precos minimos por periodo no espaco

## Resumo da solicitacao

Em Metas e Precos, uma aba Minimos mostra o preco minimo padrao do espaco e permite cadastrar faixas de minimo por periodo. Na data do evento, o orcamento usa a faixa que cobre o dia; fora de qualquer faixa, usa o minimo padrao.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: nao
- risco principal: aplicar o piso errado e gravar um total de orcamento diferente do periodo da data
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: mudar a formula de adicional, desconto ou meta; publicar minimo no site; preco minimo por dia da semana; periodo valendo so para um ano
- prova minima desta execucao: na aba Minimos, o usuario com permissao edita o minimo padrao, cria uma faixa de dezembro e a reencontra ao reabrir a tela; um orcamento novo cuja data cai nessa faixa usa o valor da faixa, e um fora dela usa o padrao
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a exibir o `minimumPrice` que ja existe, sem faixas nem mudanca de calculo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `database`, `design`, `patterns`, `node`, `react`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/database/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: aba e painel de Metas e Precos; cadastro de adicional sazonal, como referencia de periodo `dd/MM`; campo `Venue.minimumPrice` e o ponto do calculo do orcamento que compara o total com esse piso
- palavras-chave ou simbolos de busca: `minimumPrice`, `SeasonalFee`, `VenueGoals`, `FeesTab`, `GoalHeader`
- testes provaveis: `npx prisma validate` no backend; na aba Minimos, salvar o padrao, criar e reabrir uma faixa; um orcamento na data da faixa e outro fora dela
- nao ler por padrao: `security`, `observability`, `topics/`, `specs/`, site publico, contrato e pagamento

## Contexto informado na entrada

Pedido em chat: o minimo por orcamento hoje e um unico valor do espaco. A pessoa quer um minimo padrao e outros minimos por periodo, por exemplo so dezembro. A entrada fica na tela Metas e Precos, como mais uma aba. Nessa aba aparece o preco minimo fixo e da para criar faixas de minimo por periodo.

## Problema atual

Cada espaco tem um unico `minimumPrice`. Nao da para cobrar um piso maior so em dezembro e manter outro no resto do ano. O piso existente entra na criacao do orcamento; a edicao por dia nao aplica esse piso.

## Objetivo da mudanca

Na aba Minimos de Metas e Precos, o minimo padrao do espaco fica visivel e editavel, e as faixas por periodo podem ser criadas, alteradas e removidas. O orcamento automatico usa a faixa da data de inicio do evento e, sem faixa, o minimo padrao.

## Escopo inicial percebido

Nova capacidade do venue: persistir faixas, expor na tela Metas e Precos e usar a faixa vigente no calculo automatico do orcamento, na criacao e na edicao. O minimo padrao continua sendo o campo que ja existe no espaco.

## Itens incluidos neste request

- aba Minimos em Metas e Precos, no mesmo grupo de Painel, Metas, Adicionais e Descontos
- card do preco minimo padrao, editavel por quem ja edita essa tela
- lista de faixas com titulo, inicio, fim e valor, com criar, editar e excluir
- resumo no painel da mesma tela, no mesmo papel das secoes de Adicionais e Descontos
- calculo automatico do orcamento escolhe a faixa da data de inicio ou o minimo padrao

## Requisitos implicitos ja visiveis

- periodo no formato `dd/MM`, repetido todo ano, como o adicional sazonal
- intervalo que cruza a virada do ano continua valendo, no mesmo criterio do adicional
- faixa nao substitui adicional, desconto nem meta; o piso entra depois desses ajustes, como o minimo atual
- total digitado a mao continua sendo o valor gravado
- minimo padrao vazio ou zero nao cria piso
- usuario sem permissao de edicao nao grava padrao nem faixa

## Casos de erro e borda ja percebidos

- duas faixas cobrindo o mesmo dia: vale a de maior valor
- evento que comeca antes da faixa e termina dentro dela: vale a data de inicio
- faixa com fim anterior ao inicio representa a virada do ano
- editar a data do orcamento troca a faixa avaliada
- editar um orcamento sem total manual nao pode ignorar o piso da data

## Dependencias

- `Venue.minimumPrice` ja existe e segue como minimo padrao
- tela Metas e Precos ja concentra metas, adicionais e descontos do espaco
- pedido separado de aplicar adicionais e descontos na edicao (`task-requests/edicao-orcamento-adicionais-descontos-request.md`) mexe no mesmo calculo; as duas mudancas nao podem apagar uma a outra

## Restricoes e cuidados

- nao reaproveitar `SeasonalFee` para guardar piso em reais; aquela entidade e percentual de adicional ou desconto
- nao alterar site, contrato, pagamento nem a formula de adicional, desconto e meta
- migration de producao e aditiva
- permissao no frontend nao substitui autorizacao no backend
- execucao futura toca `backend` e `frontend` e pode ser derivada com `tasking/task-request-repo-split-prompt.md` ou o split da spec

## Perguntas em aberto

- A faixa vale todo ano ou so num ano escolhido? Premissa: todo ano, com dia e mes, como o adicional de fim de ano.
- Periodos sobrepostos usam qual valor? Premissa: o maior.
- Qual data escolhe a faixa num evento de varios dias? Premissa: a data de inicio.
- Total digitado a mao recebe o piso por cima? Premissa: nao. O numero informado e o total final.
- O painel de Metas e Precos mostra um resumo dos minimos? Premissa: sim, no mesmo papel das secoes de Adicionais e Descontos.
- A permissao e propria? Premissa: nao. Reaproveita quem ja edita metas e adicionais nessa tela.

## Prioridade sugerida

Media. E capacidade nova de preco do espaco, sem correcao de um fluxo que ja esteja quebrado para o usuario.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria uma capacidade nova de preco, toca `backend` e `frontend`, inclui schema e se quebra em varias tasks (persistencia, API, calculo do orcamento e tela). Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/precos-minimos-por-periodo/`

## Sugestao de nome do arquivo

- `precos-minimos-por-periodo-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-02-precos-minimos-por-periodo/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
