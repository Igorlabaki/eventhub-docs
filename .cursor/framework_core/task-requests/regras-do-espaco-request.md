# Solicitacao da Tarefa

## Nome sugerido da tarefa

Cadastrar regras do espaco no venue

## Resumo da solicitacao

No painel de um venue, a pessoa autorizada cadastra as regras daquele espaco. A feature fica no nivel do venue, junto dos outros cadastros do espaco.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: nao
- risco principal: gravar regra no venue errado, ou deixar a gravacao so no frontend sem autorizacao no backend
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: publicar as regras no site; incluir regras em orcamento, contrato ou e-mail; regras no nivel da organizacao
- prova minima desta execucao: no painel do venue, usuario com permissao de edicao cria, altera e remove uma regra e ela continua la ao reabrir a tela; usuario sem permissao de edicao nao grava
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a um campo de texto unico dentro de uma tela de venue que ja existe, sem entidade nem permissao proprias
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
- caminhos candidatos: cadastro de servicos do venue, como referencia de lista por espaco; menu e rotas do venue
- palavras-chave ou simbolos de busca: `Venue`, `Service`, `VenueNav`, `VIEW_VENUE_SERVICES`, `EDIT_VENUE_SERVICES`
- testes provaveis: `npx prisma validate` no backend; criar, editar e remover uma regra no painel e recarregar a tela
- nao ler por padrao: `security`, `topics/`, `specs/`, site publico, orcamento e contrato

## Contexto informado na entrada

Pedido em chat: no nivel de venue, ter mais uma feature chamada regras, em que a pessoa cadastra as regras do espaco.

## Problema atual

O venue nao tem um lugar para cadastrar as regras do espaco. Textos de site e FAQ existem, mas nao cobrem esse cadastro.

## Objetivo da mudanca

No painel de um venue, um usuario autorizado cadastra, altera e remove as regras daquele espaco, e elas permanecem ao reabrir a tela.

## Escopo inicial percebido

Nova capacidade de negocio do venue, com persistencia, API e tela propria no menu do espaco. Toca `backend` e `frontend` e pede migration aditiva.

## Itens incluidos neste request

- cadastro das regras de um venue no painel
- listar, criar, alterar e remover regras daquele espaco
- acesso separado para ver e para editar, no mesmo modelo dos outros cadastros do venue
- item de navegacao do venue para essa tela

## Requisitos implicitos ja visiveis

- a regra pertence a um venue
- a gravacao passa pelo backend autenticado; a permissao da tela nao substitui a autorizacao da API
- a migration de producao e aditiva
- o frontend nao cria uma terceira forma de estado alem das que o projeto ja usa

## Casos de erro e borda ja percebidos

- venue sem regras: a tela abre vazia, pronta para o primeiro cadastro
- texto vazio: a regra nao e salva
- usuario sem permissao de edicao: ve a lista, se puder ver, e nao grava
- regra de outro venue: a API nao altera nem apaga

## Dependencias

- nenhuma dependencia externa
- o venue e o modelo de permissao do painel ja existem
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao publicar as regras no site nem em orcamento, contrato ou mensagem nesta entrega
- nao criar regras no nivel da organizacao
- nao ler nem versionar valores de `.env`
- rota autenticada de proposito; autorizacao no backend

## Perguntas em aberto

- A pessoa cadastra varias regras ou um texto unico? Premissa: varias regras do mesmo venue.
- Quais campos entram? Premissa: titulo opcional, texto obrigatorio e ordem de exibicao.
- Onde mais as regras aparecem? Premissa: so no painel do venue nesta entrega.
- A permissao e propria ou reaproveita a de informacoes do venue? Premissa: par proprio de ver e editar, no mesmo modelo dos outros cadastros do venue.

## Prioridade sugerida

Media. E capacidade nova do espaco, sem correcao de fluxo que ja esteja quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria uma capacidade nova do venue, toca `backend` e `frontend`, inclui schema e se quebra em varias tasks (persistencia, API, permissao e tela). Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/regras-do-espaco/`

## Sugestao de nome do arquivo

- `regras-do-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-02-regras-do-espaco/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
