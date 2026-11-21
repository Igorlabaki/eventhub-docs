# Solicitacao da Tarefa

## Nome sugerido da tarefa

KPIs, filtros, paginas e check que salva na tela de parceiros indicados do orcamento

## Resumo da solicitacao

A tela `Parceiros indicados` do orcamento (`/proposal/:id/send-suppliers`) e uma lista solta de cards com checkbox, busca local e botao `Salvar indicações`. Refazer no padrao da lista de contatos: KPIs no alto, busca e filtro de categoria, tabela paginada, linha verde quando o parceiro esta indicado e gravacao no clique do check, sem botao de salvar.

## Context Pack

- frente principal: frontend (`eventhub-vista-dashboard/`), so uma pagina; usa rotas que ja existem
- superficie sensivel: nao (`PUT /proposal/indications/:proposalId` ja autenticado e com `SEND_PROPOSAL_INFO` no use case; nada de contrato novo)
- camadas transversais: `design`
- risco principal: o `PUT` substitui a lista inteira; com pagina de 10, o corpo tem que levar todos os indicados (nao so os da pagina), e cliques rapidos nao podem gravar fora de ordem nem deixar a tela diferente do banco
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: filtro `Indicados / Nao indicados` (a listagem de contatos nao sabe o que foi indicado; exigiria parametro novo no backend), rotas de adicionar ou remover uma indicacao por vez, mudar a ordem das indicacoes na pagina publica, mudar `/proposal/:id/indications` (pagina publica), mexer em `VenueContacts.tsx`
- prova minima desta execucao: em `/proposal/:id/send-suppliers`, os cards mostram total, indicados e nao indicados; buscar e trocar categoria filtram a tabela e voltam para a pagina 1; clicar no check pinta a linha de verde, atualiza o KPI e, ao recarregar a pagina, continua marcado; desmarcar em outra pagina nao apaga os indicados das demais; `npm test` e `npm run build` do front verdes
- criterio de escalada: permanece `normal`; sobe para `spec` se for pedido o filtro por status de indicacao ou gravacao item a item (contrato novo no backend)
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/SendSuppliers.tsx` (pagina inteira); `eventhub-vista-dashboard/src/pages/VenueContacts.tsx` no bloco de busca, categoria, `ContactListSummaryCards` e `ProposalListPager`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/api-endpoints.md` nas linhas de `GET /contact/list` e `GET|PUT /proposal/indications/:proposalId`
  - `.cursor/framework_core/specs/2026-11-05-kpis-filtros-lista-contatos/00-overview.md#Objetivo rapido`
  - `.cursor/framework_core/specs/2026-11-05-indicacoes-publicas-do-orcamento/00-overview.md#Objetivo rapido`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/contact/contact-list-summary.tsx`; `eventhub-vista-dashboard/src/components/contact/contact-list.tsx` (tabela e selo de categoria); `eventhub-vista-dashboard/src/components/proposal/ProposalListPager.tsx`; `eventhub-vista-dashboard/src/store/contactStore.ts`; `eventhub-vista-dashboard/src/services/proposal.service.ts` (`listProposalIndications`, `replaceProposalIndications`); `eventhub-vista-dashboard/src/lib/partner-category.ts`
- palavras-chave ou simbolos de busca: `replaceProposalIndications`, `listProposalIndications`, `fetchContacts`, `contactListPagination`, `contactListSummary`, `PARTNER_CATEGORIES`, `partnerCategoryLabel`, `ProposalListPager`, `FilterList`, `FormLayout`
- testes provaveis: marcar envia o `PUT` com os indicados de todas as paginas mais o novo; desmarcar envia sem ele; erro no `PUT` volta o check e mostra toast; dois cliques seguidos gravam na ordem; trocar busca ou categoria volta para a pagina 1
- nao ler por padrao: `security`, `database`, backend, `topics/`, schema Prisma

## Contexto informado na entrada

Pedido em chat com print da tela: "essa tela ta muito feia"; precisa de KPIs, filtro de categoria, lista no padrao do projeto, check que deixa a linha com fundo verde quando selecionado, sem botao de salvar (clicou no check, ja salva) e paginacao.

## Problema atual

- a pagina e um `FormLayout` com cards empilhados e um botao `Salvar indicações`; marcar sem salvar perde a escolha
- nao ha numeros de quantos parceiros existem nem quantos ja foram indicados
- a busca filtra so no navegador e nao ha filtro de categoria
- todos os fornecedores vem de uma vez, sem paginas
- a linha mostra a `role` digitada no cadastro, nao a categoria do parceiro
- marcado e desmarcado so se distinguem pelo checkbox pequeno

## Objetivo da mudanca

Na tela de parceiros indicados, marcar ou desmarcar o check de um parceiro grava a indicacao na hora e pinta a linha de verde, numa tabela paginada com KPIs, busca e filtro de categoria no padrao da lista de contatos.

## Escopo inicial percebido

Reescrever `SendSuppliers.tsx` usando o que ja existe na lista de contatos (barra de filtros, cards de resumo, tabela, `ProposalListPager`) e a listagem paginada de fornecedores (`type=SUPPLIER`, `q`, `category`, `page`, `summary`). A selecao continua vindo de `listProposalIndications` e e gravada com `replaceProposalIndications`, agora a cada clique.

## Itens incluidos neste request

- KPIs em cards no estilo de `ContactListSummaryCards`: `Parceiros` (total de fornecedores do espaco), `Indicados` (todos os indicados do orcamento, nao so da pagina) e `Nao indicados`
- barra de filtros como em `VenueContacts`: busca com debounce de 300 ms (`q`) e select `Categoria` com `PARTNER_CATEGORIES`
- link publico das indicacoes (`/proposal/:id/indications`) vira botao `Copiar link` na barra de filtros, como o `Link para cadastro de parceiro`
- tabela no padrao de `contact-list.tsx`: check, Nome, Categoria (selo), Funcao
- linha indicada com fundo verde; clicar em qualquer parte da linha alterna o check
- gravacao no clique: atualiza a tela na hora, envia o `PUT` com a lista completa, grava em fila (um de cada vez) e volta o estado com toast se falhar; indicador discreto `Salvando...` / `Salvo`
- remover `FormLayout`, o botao `Salvar indicações` e o `FilterList` desta pagina
- paginacao de 10 com `ProposalListPager`, voltando para a pagina 1 ao mudar busca ou categoria
- skeleton e estado vazio no padrao da lista de contatos

## Requisitos implicitos ja visiveis

- quem nao tem `SEND_PROPOSAL_INFO` continua sem abrir a pagina (rota ja protegida)
- KPI `Indicados` e o verde da linha refletem o mesmo estado
- a busca e o filtro nao alteram a selecao; parceiro indicado fora do filtro continua indicado
- a ordem das indicacoes na pagina publica segue a ordem gravada (`uniqueIds` no backend); marcar novo parceiro entra no fim
- layout em celular: filtros empilham e a tabela nao estoura a largura

## Casos de erro e borda ja percebidos

- erro de rede ou 403 no `PUT`: check volta ao estado anterior e aparece toast
- cliques rapidos em varios parceiros: a ultima gravacao reflete todos os cliques
- parceiro indicado que foi apagado ou deixou de ser `SUPPLIER`: o backend recusa a lista inteira com 400; a pagina deve mostrar o erro e nao travar
- espaco sem fornecedores: estado vazio com orientacao para cadastrar em Contatos
- filtro sem resultado: tabela vazia e KPIs `Parceiros` seguindo o filtro, como em contatos
- pagina alem do total depois de filtrar: volta para a ultima pagina valida

## Dependencias

- spec [kpis-filtros-lista-contatos](../specs/2026-11-05-kpis-filtros-lista-contatos/00-overview.md): listagem paginada, `summary` e filtro de categoria de `GET /contact/list`
- spec [indicacoes-publicas-do-orcamento](../specs/2026-11-05-indicacoes-publicas-do-orcamento/00-overview.md): `GET` e `PUT /proposal/indications/:proposalId`

## Restricoes e cuidados

- nao mudar backend nem contrato
- `contactStore` e compartilhado com `VenueContacts`; a pagina nao pode deixar `lastListParams` quebrando o recarregar da lista de contatos
- reaproveitar componentes existentes em vez de copiar; se precisar generalizar `ContactListSummaryCards`, nao mudar o que a lista de contatos mostra
- nao criar terceira abordagem de estado no frontend

## Perguntas em aberto

- Quais KPIs? Premissa: `Parceiros`, `Indicados` e `Nao indicados`.
- O KPI `Parceiros` segue a busca e a categoria? Premissa: sim, como em contatos; `Indicados` e sempre o total do orcamento.
- Precisa de filtro `Indicados / Nao indicados`? Premissa: nao nesta task (exige backend); registrar como proxima melhoria.
- Mostrar uma coluna com o WhatsApp ou acao de abrir o contato? Premissa: nao; a tela e so de indicar.
- Verde de qual tom? Premissa: o verde de sucesso ja usado no app (`emerald`/`green` claro de fundo, borda verde a esquerda).

## Prioridade sugerida

Media. A tela funciona, mas exige salvar manualmente e fica dificil de usar com muitos parceiros.

## Faixa sugerida para task workflow

- `B` — uma pagina, sem contrato novo, mas com gravacao otimista em fila e reaproveitamento de componentes compartilhados
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, um repo, rotas existentes e padrao de tela ja definido na lista de contatos

## Sugestao de slug da spec

- `framework_core/specs/lista-parceiros-indicados-orcamento/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `lista-parceiros-indicados-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `executar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
