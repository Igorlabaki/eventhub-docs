# Solicitacao da Tarefa

## Nome sugerido da tarefa

Campo slogan do espaco nas configuracoes

## Resumo da solicitacao

O espaco ganha um campo slogan, gravado ao lado da descricao. Em Configuracoes, Informacoes Gerais, o operador preenche o slogan. A descricao que ja existe e copiada para o slogan e continua gravada.

## Context Pack

- frente principal: produto (banco e frontend)
- superficie sensivel: sim — migration na `venue` com copia de texto ja gravado; aplicar na `main` do PlanetScale exige aprovacao nomeada
- risco principal: a copia apagar ou cortar a descricao atual, ou o slogan novo substituir o texto publico antes da hora
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: card da casa na apresentacao publica; trocar o texto do topo do orcamento, do formulario publico e da apresentacao; titulo da aba; formulario de criar espaco
- prova minima desta execucao: `npx prisma validate` aceita `slogan` em `Venue`; a migration adiciona a coluna e copia `description` para `slogan` sem limpar `description`; em Configuracoes do espaco, Informacoes Gerais, o campo Slogan salva, recarrega com o valor e a Descricao permanece editavel
- criterio de escalada: promover para `spec` se a execucao precisar exibir o slogan nas paginas publicas ou montar o card da casa entre o video e a foto
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `database`, `node`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Provas`
  - `.cursor/framework_core/product/08-data-model.md`
  - `.cursor/framework_core/topics/data-and-migrations.md`
  - `.cursor/framework_core/project/planetscale.md`
- caminhos candidatos: model `Venue` em `art56_server_v3/prisma/schema.prisma`; migration no estilo de `add_venue_tour_video_url`; Informacoes Gerais em `VenueSettings.tsx`; schemas de atualizar venue
- palavras-chave ou simbolos de busca: `description`, `slogan`, `maxGuest`, `update-info-venue`, `Informacoes Gerais`
- testes provaveis: `npx prisma validate`; teste do schema de update do venue aceitando `slogan` opcional; salvar e reabrir Configuracoes com slogan preenchido e vazio
- nao ler por padrao: `topics/` alem de `data-and-migrations.md`; spec da apresentacao publica; `security`

## Contexto informado na entrada

Pedido em chat, depois de comparar o link do orcamento com o da apresentacao. O texto curto embaixo do logo, como "O OASIS URBANO", esta gravado em Descricao. Esse campo passa a ser a descricao da casa. O slogan e outro campo e entra onde esse texto curto aparece hoje. Nesta etapa o trabalho para no schema, na copia e no input de Configuracoes.

## Problema atual

So existe `description` em `venue`. Configuracoes tem um unico campo, Descricao, e o texto curto do espaco esta gravado nele. Nao ha onde guardar o slogan separado da descricao.

## Objetivo da mudanca

Em Configuracoes do espaco da para gravar um slogan, a descricao atual continua no banco, e cada casa que ja tinha descricao passa a ter esse mesmo texto tambem no slogan.

## Escopo inicial percebido

Coluna nova, migration com copia e o input na tela de Configuracoes que ja edita a descricao. Toca `backend` e `frontend`. As paginas publicas nao mudam.

## Itens incluidos neste request

- coluna `slogan` opcional em `Venue`, texto longo, para a copia nao cortar uma descricao ja grande
- migration que adiciona a coluna e copia `description` para `slogan` quando a descricao tiver texto
- a descricao copiada permanece em `description`
- campo Slogan em Configuracoes, Informacoes Gerais, no mesmo salvamento da descricao
- a API que grava as informacoes gerais aceita e devolve `slogan`

## Requisitos implicitos ja visiveis

- slogan vazio e valido
- salvar sem mexer no slogan nao apaga a descricao
- o texto copiado fica editavel nos dois campos
- casa nova pode ficar sem slogan
- a migration no repositorio nao e aplicada na `main` sem aprovacao nomeada

## Casos de erro e borda ja percebidos

- descricao vazia ou so com espaco: a copia nao grava slogan
- descricao longa: a coluna do slogan aceita o texto inteiro
- rodar a copia de novo nao pode apagar um slogan ja editado por cima da descricao
- falha ao salvar o slogan mostra o erro na propria tela e mantem o valor digitado

## Dependencias

- `description` ja existe em `venue` e ja e editada em Informacoes Gerais
- o salvamento de Configuracoes ja persiste a descricao

## Restricoes e cuidados

- nao limpar `description` na migration
- nao exibir o slogan no orcamento, no formulario publico, na apresentacao nem no titulo da aba nesta tarefa
- nao criar o card da casa entre o video e a foto
- nao ler nem versionar valores de `.env`
- nao aplicar a migration em producao nesta execucao

## Perguntas em aberto

- Nenhuma. O campo fica em Informacoes Gerais, acima da Descricao, com o rotulo Slogan. A copia inicial leva a descricao para o slogan e deixa a descricao no lugar.

## Prioridade sugerida

Media. Separa o texto curto da descricao da casa. A apresentacao publica continua como esta.

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

## Candidato a spec

- `nao`
- motivo: um campo, uma copia e um input. Nao redesenha a apresentacao. Vira spec se as paginas publicas ou o card da casa entrarem no mesmo trabalho.

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `slogan-espaco-configuracoes-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `opcional`
