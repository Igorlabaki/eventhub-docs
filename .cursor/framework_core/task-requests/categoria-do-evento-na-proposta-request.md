# Solicitacao da Tarefa

## Nome sugerido da tarefa

Categoria do evento na proposta (empresarial, aniversario, despedida de solteiro, casamento, coffee break, outro)

## Resumo da solicitacao

Quando a proposta for do tipo Evento, ela passa a guardar tambem a categoria do evento, escolhida numa lista fechada. O tipo atual (`EVENT`, `PRODUCTION`, `BARTER`, `OVERNIGHT`, `OTHER`) nao muda; a categoria e um campo novo, obrigatorio nas propostas novas de Evento e vazio nos outros tipos.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: nao — a categoria nao e pagamento, segredo nem PII; o formulario publico de orcamento ja existe e so ganha o campo
- camadas transversais: `database`, `design`
- risco principal: propostas antigas de Evento sem categoria quebrarem a leitura ou a edicao; categoria sobrar gravada numa proposta que trocou de Evento para outro tipo
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: mudar ou renomear o enum `ProposalType`, `DateEventType` ou `NotificationType`; preencher categoria retroativa nas propostas existentes; filtro, KPI ou grafico por categoria nos relatorios; categorias configuraveis por espaco; preco ou servicos por categoria
- prova minima desta execucao: criar orcamento no painel com tipo Evento sem categoria recusa (400 no backend e erro no campo); com Aniversario grava e o detalhe mostra `Evento · Aniversário`; trocar o tipo para Produção limpa o campo e grava `null`; formulario publico pede a categoria e grava; proposta antiga abre sem quebrar; `npx prisma validate` e vitest dos dois repos verdes
- criterio de escalada: a spec e o caminho; voltar para `normal` so se a coluna ja existir no `main` e faltar apenas a tela
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`; `art56_server_v3/prisma/schema.prisma` em `model Proposal` e `enum ProposalType`
- libs obrigatorias: `node`, `database`, `patterns`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/topics/data-and-migrations.md#Regras`
  - `.cursor/framework_core/project/planetscale.md`
  - `.cursor/framework_core/specs/2026-11-05-categoria-parceiro/00-overview.md#Objetivo rapido` (precedente de enum novo opcional)
- caminhos candidatos:
  - backend: `art56_server_v3/src/zod/proposal/create-proposal-per-person-params-schema.ts`, `create-proposal-per-day-params-schema.ts`, `update-proposal-per-person-params-schema.ts`, `update-proposal-per-day--params-schema.ts`, `update-proposal-in-db-params-schema.ts`; `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts`; `art56_server_v3/src/repositories/interface/proposal-repository-interface.ts`; use cases em `art56_server_v3/src/use-cases/proposal/create-proposal-per-*` e `update-proposal-per-*` com os `.spec.ts`
  - frontend: `eventhub-vista-dashboard/src/types/proposal.ts`; `eventhub-vista-dashboard/src/pages/NewBudget.tsx`; `eventhub-vista-dashboard/src/pages/ProposalEdit.tsx`; `eventhub-vista-dashboard/src/pages/ProposalDetails.tsx`; `eventhub-vista-dashboard/src/components/proposal/forms/PerPersonProposalForm.tsx`, `PerDayProposalForm.tsx`, `ClientPerPersonProposalForm.tsx`, `ClientPerDayProposalForm.tsx`; `eventhub-vista-dashboard/src/components/BudgetSidebar.tsx`
- palavras-chave ou simbolos de busca: `ProposalType`, `type: z.enum(["PRODUCTION", "BARTER", "OTHER", "EVENT"])`, `trafficSource` (segue o mesmo caminho do campo novo), `form.watch("type")`, `Tipo de Evento`
- testes provaveis: criar com `EVENT` sem categoria recusa; criar com `EVENT` e categoria valida grava; categoria fora da lista recusa; tipo diferente de `EVENT` grava `null` mesmo recebendo categoria; editar proposta antiga de Evento exige categoria; select aparece so com tipo Evento e limpa ao trocar
- nao ler por padrao: `security`, `topics/` alem de dados e migracoes, relatorios, agenda e notificacoes

## Contexto informado na entrada

Pedido em chat. O usuario quer saber que tipo de evento vai acontecer: confraternizacao empresarial, despedida de solteiro, aniversario, coffee break, filmagem etc. Na conversa ficou decidido:

- e um campo novo, subcategoria do tipo Evento, sem mexer no `type`;
- filmagem ja esta coberta por `PRODUCTION` e nao entra na lista;
- lista fechada (enum), com seis valores: Empresarial / confraternizacao, Aniversario, Despedida de solteiro, Casamento, Coffee break e Outro;
- obrigatoria nas propostas novas de tipo Evento.

## Problema atual

O "Tipo de Evento" do painel grava `ProposalType`, que diz a modalidade (evento, producao, permuta, pernoite, outro), nao a ocasiao. A ocasiao so aparece, quando aparece, no texto livre de `description`, sem como filtrar, contar ou exibir de forma padronizada.

## Objetivo da mudanca

Toda proposta nova de tipo Evento grava uma categoria da lista fechada, e o detalhe da proposta mostra essa categoria junto do tipo.

## Escopo inicial percebido

Enum e coluna nova opcional em `Proposal`, validacao condicional no backend nas rotas de criar e editar (por pessoa e por dia), select condicional nos formularios do painel e no formulario publico, e exibicao no detalhe da proposta.

## Itens incluidos neste request

- enum novo, sugestao `EventCategory`: `CORPORATE`, `BIRTHDAY`, `BACHELOR_PARTY`, `WEDDING`, `COFFEE_BREAK`, `OTHER`
- coluna `eventCategory` opcional em `Proposal`, via migration aditiva e deploy request no `main` do PlanetScale
- backend: `type = EVENT` sem categoria recusa com 400 na criacao e na edicao; `type` diferente de `EVENT` grava `null`
- painel (`NewBudget`, formularios por pessoa e por dia, `ProposalEdit`): select "Categoria do evento" visivel e obrigatorio so com tipo Evento; trocar o tipo limpa o valor
- formulario publico (`ClientPerPersonProposalForm`, `ClientPerDayProposalForm`): o tipo ja vai fixo como `EVENT`, entao a categoria aparece sempre e e obrigatoria
- detalhe da proposta: `Evento · <categoria>`; sem categoria, mostra so o tipo
- rotulos em portugues: Empresarial / confraternização, Aniversário, Despedida de solteiro, Casamento, Coffee break, Outro

## Requisitos implicitos ja visiveis

- uma proposta tem no maximo uma categoria
- valor fora da lista nao grava
- validacao no backend, nao so no front
- propostas existentes continuam validas com `eventCategory = null`
- contrato FE/BE atualizado nos dois repos (`types/proposal.ts` e schemas zod)

## Casos de erro e borda ja percebidos

- proposta antiga de Evento sem categoria: abre e lista normalmente; ao salvar a edicao, passa a exigir categoria
- trocar o tipo de Evento para Producao na edicao: categoria vira `null`
- trocar de Producao para Evento: select aparece vazio e obrigatorio
- backend antigo sem o campo: o front nao quebra ao ler proposta sem `eventCategory`
- formulario publico enviado sem categoria: nao grava

## Dependencias

- `ProposalType` e o select "Tipo de Evento" ja existem no painel
- formularios publicos de orcamento ja enviam `type: EVENT`
- acesso ao PlanetScale para deploy request (aprovacao nomeada, conforme as regras de ouro)

## Restricoes e cuidados

- migration aditiva; nada de DDL direto no `main`
- nao alterar `ProposalType`, `DateEventType` nem `NotificationType`
- nao ler nem versionar valores de `.env`
- nao preencher categoria retroativa nas propostas existentes

## Perguntas em aberto

- Nome do campo e do enum? Premissa: `eventCategory` / `EventCategory`.
- A categoria aparece tambem na lista de orcamentos e no link publico da proposta? Premissa: nao nesta entrega; so no detalhe interno. Lista e link publico ficam para depois.
- Edicao de proposta antiga de Evento exige categoria? Premissa: sim, a regra vale sempre que `type = EVENT` for salvo.
- O formulario publico mostra a categoria como primeiro campo do passo de dados do evento? Premissa: sim, junto de data e convidados.

## Prioridade sugerida

Media. Nao bloqueia operacao; habilita leitura comercial por ocasiao e relatorios futuros.

## Faixa sugerida para task workflow

- `C` — enum e coluna nova com migration em producao, validacao no backend e formularios do painel e publico nos dois repositorios
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: schema novo com deploy request, contrato FE/BE, validacao condicional em quatro rotas e formularios do painel e publico; ordem natural de tasks (schema, backend, painel, publico, detalhe)

## Sugestao de slug da spec

- `framework_core/specs/2026-11-09-categoria-do-evento-na-proposta/`

## Sugestao de nome do arquivo

- `categoria-do-evento-na-proposta-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `spec`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-09-categoria-do-evento-na-proposta/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria` depois da spec, com `tasking/task-request-repo-split-prompt.md` se a promocao nao dividir o trabalho (backend antes do frontend)
