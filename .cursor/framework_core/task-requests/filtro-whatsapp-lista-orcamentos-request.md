# Solicitacao da Tarefa

## Nome sugerido da tarefa

Campo de busca por WhatsApp na lista de orcamentos

## Resumo da solicitacao

Na lista de orcamentos do painel (`/venue/budgets`), adicionar um segundo campo de busca, separado do campo de nome, para encontrar orcamentos pelo numero de WhatsApp do cliente. O campo atual continua buscando so pelo nome.

## Context Pack

- frente principal: frontend, com um filtro novo no contrato do backend
- superficie sensivel: nao (rota ja autenticada; o filtro nao devolve campo novo, so restringe a lista)
- camadas transversais: `design`
- risco principal: o numero esta gravado com mascara `(11) 99999-8888`; buscar so digitos (`11999998888`) nao casa com `contains`. Tambem nao pode esquecer o filtro no `summarize`, senao os cards de KPI divergem da tabela
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: busca unica nome-ou-WhatsApp, busca por final do numero (so digitos), normalizar os numeros ja gravados, mexer na busca de Contatos, schema, migration e indice
- prova minima desta execucao: em `/venue/budgets`, digitar `(11) 9` (ou o DDD e o comeco de um numero real) no campo WhatsApp filtra tabela e cards; combinado com o campo de nome, so sobra o que casa com os dois; limpar o campo volta a lista; vitest do schema/use case/repositorio com `whatsapp` e build do front verdes
- criterio de escalada: permanece `normal`; sobe para `spec` se for preciso buscar por qualquer trecho de digitos (comparacao sem mascara no banco, SQL bruto no `list`) ou normalizar os numeros gravados
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts` em `list` e `summarize` (filtros de `email` e `completeClientName`); `eventhub-vista-dashboard/src/pages/VenueBudgets.tsx` no debounce da busca e em `proposalQuery`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/api-endpoints.md` na linha de `GET /proposal/list`
  - `.cursor/framework_core/specs/2026-11-05-lista-painel-orcamentos/00-overview.md#Objetivo rapido`
- caminhos candidatos: `art56_server_v3/src/zod/proposal/list-proposal-query-schema.ts`; `art56_server_v3/src/use-cases/proposal/list-proposal/use-case-list-proposal.ts` e `.spec.ts`; `art56_server_v3/src/repositories/interface/proposal-repository-interface.ts` (`ListProposalDbQuery`); `eventhub-vista-dashboard/src/services/proposal.service.ts` (`ListProposalParams`, `listProposals`); `eventhub-vista-dashboard/src/components/proposal/forms/ClientPerPersonProposalForm.tsx` (`formatWhatsapp`)
- palavras-chave ou simbolos de busca: `completeClientName`, `containsLike`, `ListProposalDbQuery`, `listProposalRequestQuerySchema`, `ListProposalParams`, `formatWhatsapp`, `searchInput`, `searchTerm`
- testes provaveis: schema aceita `whatsapp` e transforma vazio em `undefined`; use case repassa `whatsapp` para `list` e `summarize`; repositorio monta `whatsapp contains` no `list` e `whatsapp LIKE` escapado no `summarize`; `whatsapp` e nome juntos viram E
- nao ler por padrao: `security`, `database`, `topics/`, schema Prisma

## Contexto informado na entrada

Pedido em chat: no filtro de texto da lista de orcamentos, poder procurar pelo nome ou pelo WhatsApp. Na conversa ficou decidido que pode ser um input novo, so para o WhatsApp, para ficar mais separado. A busca de Contatos ja procura no WhatsApp via `q` e nao entra nesta task.

## Problema atual

O campo `Buscar orçamentos...` manda `completeClientName` e o backend filtra so essa coluna. Quem tem apenas o numero do cliente (ex.: chegou mensagem no WhatsApp) nao consegue achar o orcamento.

## Objetivo da mudanca

Na lista de orcamentos, digitar o WhatsApp do cliente num campo proprio filtra a tabela e os cards para os orcamentos daquele numero.

## Escopo inicial percebido

Um filtro opcional `whatsapp` no `GET /proposal/list`, no mesmo molde do filtro `email` que ja existe, e um segundo input na pagina com a mascara do formulario de orcamento.

## Itens incluidos neste request

- backend: `whatsapp` opcional no `listProposalRequestQuerySchema` (vazio vira `undefined`, tamanho maximo curto), repassado pelo use case e aplicado em `list` (`contains`) e `summarize` (`LIKE` com `containsLike`)
- frontend: `whatsapp` em `ListProposalParams` e na query string de `listProposals`
- frontend: input `Buscar por WhatsApp...` ao lado do campo de nome em `VenueBudgets.tsx`, com icone de telefone, mascara `formatWhatsapp` ao digitar, debounce de 300 ms e volta para a pagina 1 quando muda
- placeholder do campo atual passa a deixar claro que busca por nome
- `project/api-endpoints.md`: registrar o parametro novo na linha de `GET /proposal/list`

## Requisitos implicitos ja visiveis

- nome e WhatsApp combinam com E
- cards de resumo e tabela usam os mesmos filtros
- trocar mes, ano, dia, status ou valor nao apaga o texto do WhatsApp
- layout em celular: os dois campos empilham sem quebrar a linha de botoes

## Casos de erro e borda ja percebidos

- usuario digita so digitos: a mascara formata e casa com o comeco do numero gravado
- busca pelo final do numero (`8888`): nao encontra com a mascara; limitacao aceita nesta task
- numeros gravados sem mascara (orcamentos antigos ou vindos de outro formulario): podem nao casar; conferir uma amostra antes de fechar
- `%` e `_` no termo: escapados pelo `containsLike` no `summarize`
- sem resultado: tabela vazia e cards zerados, como hoje com o nome

## Dependencias

- spec [lista-painel-orcamentos](../specs/2026-11-05-lista-painel-orcamentos/00-overview.md): paginacao, `summary` e filtros atuais do `GET /proposal/list`

## Restricoes e cuidados

- nao mudar o comportamento de `completeClientName` nem de `email`
- nao duplicar `formatWhatsapp`; se precisar reaproveitar, extrair para `lib/` sem mudar o comportamento dos formularios
- nao criar indice nem migration nesta task

## Perguntas em aberto

- Aplicar a mascara no campo de busca? Premissa: sim, igual ao formulario publico, para casar com o formato gravado.
- Os numeros no banco estao todos com mascara? Resposta (leitura em `ar756/main`, 2026-11-13): nao. 2588 propostas com mascara completa e 2045 so com digitos. Por isso o backend procura o termo como veio **ou** so os digitos dele; para `(11) 9`, a busca passou de 2296 para 4222 propostas.
- O campo de WhatsApp fica sempre visivel ou atras de um botao? Premissa: sempre visivel, ao lado do campo de nome.

## Prioridade sugerida

Media. A lista funciona; o ganho e achar o orcamento quando so se tem o numero.

## Faixa sugerida para task workflow

- `B` — dois repos e um parametro novo no contrato, sem schema nem fluxo novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, filtro no molde de um que ja existe, ordem obvia (backend e depois front)

## Sugestao de slug da spec

- `framework_core/specs/filtro-whatsapp-lista-orcamentos/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `filtro-whatsapp-lista-orcamentos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- status: codigo escrito em 2026-11-13; backend com `whatsapp` no schema, use case e repositorio (`list` e `summarize`, mascara ou digitos); frontend com o campo `Buscar por WhatsApp...` em `VenueBudgets.tsx` e `formatWhatsapp` extraido para `lib/whatsapp-mask.ts` (os quatro formularios passaram a importar dele); vitest back 520 (suite inteira, antes do ajuste dos digitos) e 19 no spec da listagem depois dele, front 296, build do front ok, eslint sem erro; prova no browser pendente (login e backend local)
- proximo passo: `review` (L2) e prova em `/venue/budgets` com o backend novo
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: opcional com `tasking/task-request-repo-split-prompt.md` (backend antes do frontend)
