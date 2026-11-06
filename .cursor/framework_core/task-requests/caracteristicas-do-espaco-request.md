# Solicitacao da Tarefa

## Nome sugerido da tarefa

Cadastrar caracteristicas do espaco no venue

## Resumo da solicitacao

No painel de um venue, a pessoa autorizada cadastra a lista do que aquele espaco tem, como piscina aquecida, salao interno e telao. A feature fica no nivel do venue, com tabela propria, junto dos outros cadastros do espaco.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: nao
- risco principal: gravar a caracteristica no venue errado, ou deixar a gravacao so no frontend sem autorizacao no backend
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: substituir os textos de site e proposta que hoje usam `area: "amenities"`; publicar a lista nova no site, no orcamento, no contrato ou no e-mail; cadastro no nivel da organizacao
- prova minima desta execucao: no painel do venue, usuario com permissao de edicao cria, altera e remove uma caracteristica e ela continua la ao reabrir a tela; usuario sem permissao de edicao nao grava; a lista antiga de textos do site permanece como esta
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a reaproveitar o `Text` com `area: "amenities"` numa tela que ja existe, sem tabela nem permissao proprias
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
- caminhos candidatos: cadastro de regras do venue, como referencia de lista por espaco com permissao propria; menu e rotas do venue
- palavras-chave ou simbolos de busca: `Venue`, `VenueRule`, `VenueNav`, `VIEW_VENUE_RULES`, `EDIT_VENUE_RULES`, `amenities`
- testes provaveis: `npx prisma validate` no backend; criar, editar e remover uma caracteristica no painel e recarregar a tela
- nao ler por padrao: `security`, `topics/`, `specs/`, site publico, orcamento e contrato

## Contexto informado na entrada

Pedido em chat: a venue cadastra a lista do que tem (piscina aquecida, salao interno, telao). O nome de produto fechado na conversa e Caracteristicas; no codigo, amenities. A pessoa pediu tabela nova e o CRUD inteiro no nivel do venue, separado do texto solto que ja existe.

## Problema atual

O painel do venue nao tem um cadastro proprio dessa lista. O que existe sao registros de `Text` com `area: "amenities"`, editados no formulario publico do espaco e lidos no site da organizacao e na proposta. Isso nao e uma entidade do venue no mesmo modelo dos outros cadastros do painel.

## Objetivo da mudanca

No painel de um venue, um usuario autorizado cadastra, altera e remove as caracteristicas daquele espaco numa tabela propria, e elas permanecem ao reabrir a tela.

## Escopo inicial percebido

Nova capacidade de negocio do venue, com persistencia, API e tela propria no menu do espaco. Toca `backend` e `frontend` e pede migration aditiva.

## Itens incluidos neste request

- tabela propria das caracteristicas de um venue
- listar, criar, alterar e remover caracteristicas daquele espaco
- acesso separado para ver e para editar, no mesmo modelo dos outros cadastros do venue
- item de navegacao do venue para essa tela

## Requisitos implicitos ja visiveis

- a caracteristica pertence a um venue
- a gravacao passa pelo backend autenticado; a permissao da tela nao substitui a autorizacao da API
- a migration de producao e aditiva
- o frontend nao cria uma terceira forma de estado alem das que o projeto ja usa
- a lista nova nao substitui, nesta entrega, os `Text` com `area: "amenities"`

## Casos de erro e borda ja percebidos

- venue sem caracteristicas: a tela abre vazia, pronta para o primeiro cadastro
- nome vazio: a caracteristica nao e salva
- usuario sem permissao de edicao: ve a lista, se puder ver, e nao grava
- caracteristica de outro venue: a API nao altera nem apaga
- textos antigos de amenities continuam no site e na proposta

## Dependencias

- nenhuma dependencia externa
- o venue e o modelo de permissao do painel ja existem
- o cadastro de regras do venue e a referencia de formato, sem ser dependencia de dados
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao trocar a leitura do site nem da proposta nesta entrega
- nao migrar os `Text` existentes para a tabela nova nesta entrega
- nao criar caracteristicas no nivel da organizacao
- nao ler nem versionar valores de `.env`
- rota autenticada de proposito; autorizacao no backend

## Perguntas em aberto

- A pessoa cadastra varios itens ou um texto unico? Premissa: varios itens do mesmo venue.
- Quais campos entram? Premissa: nome obrigatorio, com ate 120 caracteres, e ordem de exibicao.
- Onde mais a lista nova aparece? Premissa: so no painel do venue nesta entrega.
- A permissao e propria ou reaproveita a de outro cadastro do venue? Premissa: par proprio de ver e editar, no mesmo modelo dos outros cadastros do venue.
- Os textos atuais de amenities entram na tabela nova? Premissa: nao; ficam onde estao.

## Prioridade sugerida

Media. E capacidade nova do espaco, sem correcao de fluxo que ja esteja quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria uma capacidade nova do venue, toca `backend` e `frontend`, inclui schema e se quebra em varias tasks (persistencia, API, permissao e tela). Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/caracteristicas-do-espaco/`

## Sugestao de nome do arquivo

- `caracteristicas-do-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-02-caracteristicas-do-espaco/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
