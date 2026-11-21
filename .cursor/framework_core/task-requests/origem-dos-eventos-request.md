# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mostrar de onde vem os eventos na analise de eventos

## Resumo da solicitacao

Na aba EVENTO dos relatorios, mostrar de quais cidades, estados e bairros vieram os eventos do ano, usando o endereco do cliente gravado no cadastro do contrato.

## Context Pack

- frente principal: produto (relatorio agregado no backend e um bloco na aba EVENTO)
- superficie sensivel: sim — a origem e o endereco do cliente (PII); a resposta fica so agregada, no mesmo contrato dos outros blocos de `/venue/reports/*`
- risco principal: devolver rua, numero, CEP, nome ou documento, ou contar uma populacao diferente da aba EVENTO e o ranking nao fechar com o total do ano
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: mapa, distancia por CEP, cruzar lugar com canal de entrada (`trafficSource`), faixa "sem endereco", mudanca no formulario do contrato e schema novo
- prova minima desta execucao: na aba EVENTO, o bloco lista cidade, estado e bairro com a quantidade de eventos do ano e a soma das cidades iguala o total de eventos da aba; a funcao pura junta a mesma cidade escrita com caixa diferente; `GET` sem `VIEW_VENUE_ANALYSIS` nao devolve o agregado e o payload nao traz rua, numero, CEP nem nome
- criterio de escalada: promover para `spec` antes de executar — backend e frontend, endpoint novo e regra de agrupamento
- nivel de autonomia: `L2`
- flags transversais: `security` sim (leitura de endereco; saida agregada); `database` nao (sem migration; leitura das colunas que ja existem); `design` sim (bloco na aba EVENTO); `observability` nao; `patterns` sim (bloco no padrao dos relatorios atuais)

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/topics/reports-and-kpis.md#Blocos agregados`
- libs obrigatorias: `node`, `patterns`, `react`, `design`, `security` (o endpoint le endereco do cliente)
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Provas`
  - `.cursor/framework_core/topics/reports-and-kpis.md#Blocos agregados`
  - `.cursor/framework_core/project/api-endpoints.md#Venue, precos e configuracao`
  - `.cursor/framework_core/topics/auth-and-security.md`
- caminhos candidatos: `art56_server_v3/src/functions/report-event-profile.ts`; `art56_server_v3/src/use-cases/venue/reports/`; `GET /venue/reports/event-profile` em `project/api-endpoints.md`; `eventhub-vista-dashboard/src/components/reports/EventsReport.tsx`; `EventProfileCard.tsx`; `hooks/venue/queries/venueReportBlocks.ts`
- palavras-chave ou simbolos de busca: `city`, `state`, `neighborhood`, `VIEW_VENUE_ANALYSIS`, `ReportAuthorizer`, `approvedInYearWhere`, `EventProfileCard`
- testes provaveis: spec da funcao pura (mesma cidade em caixas diferentes conta uma vez; soma das cidades = quantidade de eventos); use case recusa quem nao tem `VIEW_VENUE_ANALYSIS`; teste do card com lista e vazio
- nao ler por padrao: `topics/` alem de `reports-and-kpis.md` e `auth-and-security.md`; spec de anuncios; formulario de contrato alem do que este request ja fixa

## Contexto informado na entrada

Pedido em chat. Quando o cliente e cadastrado para o contrato, o sistema grava o endereco dele na proposta: rua, numero, bairro, CEP, cidade e estado. A analise de eventos hoje mostra volume, conversao, ticket, pessoas, canal de entrada, categoria, ocupacao, servicos e porte. Nao mostra de onde os eventos vem.

O botao Gerar Contrato, nos formularios de pessoa fisica e juridica, so libera com rua, numero, bairro, CEP, cidade e estado preenchidos. Esses campos sao gravados na proposta por `updateProposalPersonalInfo`. Quem opera o fluxo confirmou que evento de contrato tem endereco.

O canal de entrada (`trafficSource`) ja responde "como chegou". Este pedido responde "de onde e o cliente".

## Problema atual

A aba EVENTO nao usa `city`, `state` nem `neighborhood` da proposta. Nao da para ver quais cidades, estados e bairros concentram os eventos do ano.

## Objetivo da mudanca

Na aba EVENTO, o operador ve quantos eventos do ano vieram de cada cidade, de cada estado e de cada bairro, e a soma das cidades fecha com o total de eventos dessa aba.

## Escopo inicial percebido

Um bloco agregado no padrao de `/venue/reports/*`, lendo o endereco ja gravado, e um card na aba EVENTO ao lado dos blocos que ja existem. Sem coluna nova.

## Itens incluidos neste request

- ranking de cidades, de estados e de bairros dos eventos do ano, so com quantidade
- mesma populacao da aba EVENTO: propostas aprovadas com inicio no ano
- agrupamento que nao separa maiusculas nem espaco no comeco ou no fim
- autorizacao `VIEW_VENUE_ANALYSIS` e resposta sem dado de pessoa

## Requisitos implicitos ja visiveis

- seguir o envelope, o filtro de ano e o card com carregamento, erro e vazio dos blocos atuais
- atualizar `project/api-endpoints.md` e `topics/reports-and-kpis.md` no mesmo contrato dos outros `GET /venue/reports/*`
- a execucao futura e multi-repo; depois da spec, derivar com `spec-driven/spec-repo-split-prompt.md`

## Casos de erro e borda ja percebidos

- "Sao Paulo" e "sao paulo" sao o mesmo lugar; "São Paulo" e "Sao Paulo" continuam separados na v1
- bairro de cidade diferente da casa do espaco entra no ranking de bairros
- o formulario do contrato preenche cidade "São Paulo" e estado "SP" quando o campo da proposta vem vazio; o que foi salvo e o que a analise conta

## Dependencias

- endereco gravado na proposta no cadastro do contrato
- aba EVENTO e permissao `VIEW_VENUE_ANALYSIS` ja existentes

## Restricoes e cuidados

- nao listar rua, numero, complemento, CEP, nome, CPF ou CNPJ
- nao criar faixa "sem endereco"
- nao alterar o formulario do contrato nem o schema
- rota autenticada, no mesmo gate dos outros blocos de relatorio

## Perguntas em aberto

- Mostrar tambem o valor dos eventos, alem da quantidade? Premissa: nao. A v1 mostra so a quantidade, para a soma das cidades fechar com o total da aba.
- Limitar o ranking de bairros a cidade do espaco? Premissa: nao. Os tres rankings cobrem o ano inteiro.

## Prioridade sugerida

Media. Melhora a leitura da aba EVENTO e nao desbloqueia outro fluxo.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: capacidade nova de relatorio, com endpoint, regra de agrupamento e tela, nos dois repositorios. Cabe em poucas tasks, mas nao numa execucao unica sem recorte.

## Sugestao de slug da spec

- `framework_core/specs/2026-11-20-origem-dos-eventos/`

## Sugestao de nome do arquivo

- `origem-dos-eventos-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-20-origem-dos-eventos/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria` depois da spec, com `spec-driven/spec-repo-split-prompt.md`
