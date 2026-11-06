# Solicitacao da Tarefa

## Nome sugerido da tarefa

Horario de evento sem fuso (wall-clock)

## Resumo da solicitacao

Data e hora de evento devem permanecer exatamente como foram informadas. Se o usuario informa inicio e fim `11:00`, salvar, reabrir, exibir, notificar e sincronizar devem continuar `11:00`, sem deslocar pelo fuso do navegador ou do servidor.

## Context Pack

- frente principal: agenda e datas de evento (proposta, date event, cronograma)
- superficie sensivel: nao
- risco principal: exibir ou comunicar um horario diferente do digitado (no Brasil, `11:00` gravado como componente UTC vira `08:00` se for formatado no fuso local) e, no cronograma, deslocar o dia ao remontar a data
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: `createdAt`, `updatedAt` e expiracao de sessao/token continuam instante real; nao introduzir fuso de negocio (`America/Sao_Paulo`) no lugar do wall-clock; nao migrar schema nem regravar historico nesta entrada
- prova minima desta execucao: criar ou editar uma proposta com data escolhida e horarios `11:00`–`11:00`, reabrir a edicao, o calendario do espaco e o detalhe do orcamento, e confirmar que data e hora permanecem `11:00` nos dois repositorios (tela e texto de e-mail ou notificacao do mesmo evento)
- criterio de escalada: promover para spec antes de executar; escalar de novo se a correcao exigir migration, regravacao de dados ja salvos ou troca da semantica wall-clock por um fuso real
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `project/project-decisions.md#D-06` e `project/agent-entrypoint.md` (regra wall-clock e escalada de timezone)
- libs obrigatorias: `node` (`framework-libs/node/index.md`), `react` (`framework-libs/react/index.md`)
- documentos obrigatorios:
  - `docs/planos/horario-wall-clock/03-convencao-wall-clock.md#Definicoes`
  - `docs/planos/horario-wall-clock/03-convencao-wall-clock.md#Regras DO / DON'T`
  - `docs/planos/horario-wall-clock/README.md#Resumo das fases`
- caminhos candidatos: `eventhub-vista-dashboard/src/lib/wall-clock-datetime.ts`, `art56_server_v3/src/functions/transform-date.ts`, fluxos de proposta, date event, cronograma, e-mail de presenca e sync de calendario
- palavras-chave ou simbolos de busca: `wallClock`, `transformDate`, `toLocaleDateString`, `toTimeString`, `format(`, `setHours`, `getHours`, `America/Sao_Paulo`
- testes provaveis: `eventhub-vista-dashboard/src/lib/wall-clock-datetime.test.ts`; prova manual da proposta `11:00`–`11:00` nas telas de edicao, calendario e detalhe
- nao ler por padrao: `security`; `topics/` inteiros; specs ainda inexistentes; plano de fases alem das secoes citadas

## Contexto informado na entrada

O usuario pediu que todas as datas e horarios sigam um unico padrao, sem fuso: o valor informado permanece o valor exibido. Exemplo dado: informar `11` e `11` e esses horarios ficarem `11`.

A convencao D-06 ja define wall-clock para agenda. A fase 1 do plano em `docs/planos/horario-wall-clock/` (util central e telas P0 de proposta e calendario) ja foi aplicada. As fases seguintes desse plano continuam abertas.

## Problema atual

O mesmo evento pode aparecer com a hora digitada numa tela e com a hora deslocada em outra, em e-mail, notificacao ou calendario externo. A gravacao pretende guardar os componentes literais; parte da leitura ainda formata no fuso local.

## Objetivo da mudanca

Toda leitura e gravacao de data/hora de evento devolve os mesmos componentes informados pelo usuario, inclusive quando inicio e fim sao iguais (`11:00` e `11:00`).

## Escopo inicial percebido

Frontend e backend, nos fluxos de proposta, data de evento, cronograma, e-mail/notificacao de evento e sincronizacao com Google Calendar. Datas so de dia (pagamento e despesa) entram apenas para nao deslocar o dia civil. A mudanca se quebra em varias tasks e nao cabe numa execucao unica de task workflow.

## Itens incluidos neste request

- padronizar exibicao e releitura de data/hora de evento no frontend que ainda usa fuso local
- padronizar persistencia, e-mail e notificacao no backend para os mesmos componentes literais
- alinhar o sync do Google Calendar a essa semantica, sem aplicar um segundo deslocamento
- manter a prova do par `11:00`–`11:00` no caminho de proposta

## Requisitos implicitos ja visiveis

- reutilizar o util wall-clock ja existente no frontend em vez de criar outra convencao
- nao tratar o sufixo `Z` do valor salvo como ordem para converter ao fuso de Sao Paulo
- timestamps de auditoria ficam fora da regra
- a execucao futura e multi-repo e deve ser dividida com `tasking/task-request-repo-split-prompt.md` somente depois da spec, se a spec nao fizer essa divisao

## Casos de erro e borda ja percebidos

- inicio e fim iguais (`11:00` e `11:00`) nao podem virar outro horario nem sumir
- fim menor que inicio (evento que atravessa a meia-noite) nao pode perder o dia seguinte por causa de fuso
- data vinda como `YYYY-MM-DD` ou `dd/MM/yyyy` nao pode ser reinterpretada no fuso do servidor
- remontar o dia do cronograma a partir da data da proposta nao pode mudar o dia civil
- data so de dia nao pode aparecer como o dia anterior

## Dependencias

- convencao D-06 e util `wall-clock-datetime` da fase 1
- plano existente em `docs/planos/horario-wall-clock/` como referencia de convencao, nao como execucao direta deste request

## Restricoes e cuidados

- nao abrir uma terceira forma de formatar data
- nao converter agenda para instante local nem para `America/Sao_Paulo`
- nao incluir migration de producao nem regravacao de linhas antigas neste recorte
- mudanca multi-repo: nao executar o request inteiro num unico passo de task workflow

## Perguntas em aberto

- Datas so de dia (pagamento e despesa) entram no mesmo tratamento literal? Premissa: sim, o dia informado permanece o dia exibido, sem tratar isso como hora de evento.
- `createdAt` e `updatedAt` tambem ficam sem fuso? Premissa: nao; continuam instante real, como na convencao atual.
- Registros ja salvos precisam ser regravados? Premissa: nao; a correcao vale para ler e gravar os componentes ja armazenados, sem migration.
- Google Calendar entra nesta entrega? Premissa: sim, porque o horario externo do evento faz parte do mesmo padrao; se o payload exigir contrato externo diferente, isso vira task propria dentro da spec.

## Prioridade sugerida

Alta. Horario errado afeta operacao do evento, contrato, e-mail e calendario.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cobre um fluxo inteiro de data/hora, toca `frontend` e `backend`, inclui integracao de calendario e se quebra em varias tasks (telas restantes, persistencia e mensagens, integracoes). Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/horario-wall-clock/`

## Sugestao de nome do arquivo

- `horario-wall-clock-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-02-horario-wall-clock/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
