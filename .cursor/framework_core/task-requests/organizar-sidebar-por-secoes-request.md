# Solicitacao da Tarefa

## Nome sugerido da tarefa

Organizar a sidebar do painel por secoes

## Resumo da solicitacao

A sidebar do painel deixa de ser uma lista unica. Espaco e orcamento passam a ter secoes que abrem e fecham. Organizacao ganha rotulos, sem sanfona. Rotas, permissoes e o editor de Site continuam como estao.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: esconder um item que a pessoa usa todo dia, ou mostrar item sem a permissao que ja filtra o menu
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: rotas novas, paginas, editor de Site, schema, API e contador novo de notificacao
- prova minima desta execucao: no espaco, ver Dia a dia aberto e Comercial e A casa fechados; abrir uma pagina de Comercial e ver esse grupo aberto com o item marcado; no orcamento, ver so os grupos do orcamento; na organizacao, ver os tres rotulos sem sanfona; item sem permissao continua oculto e grupo vazio nao aparece
- criterio de escalada: `spec` se a sidebar recolhida precisar de popover ou de um modelo de navegacao novo; senao permanece `normal`
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenueNav.tsx` na lista `venueNavItems`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/SidebarNav.tsx`; `eventhub-vista-dashboard/src/components/organization/OrganizationNav.tsx`; `eventhub-vista-dashboard/src/components/ProposalNav.tsx`
- palavras-chave ou simbolos de busca: `venueNavItems`, `organizationActionItems`, `proposalNavItems`, `isCollapsed`, `hasPermission`
- testes provaveis: espaco com os tres grupos; pagina de outro grupo marcada e aberta; orcamento sem a lista do espaco; organizacao com rotulos; usuario sem permissao de um item; sidebar recolhida
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a sidebar do espaco AR756 aberta em Regras. A lista do espaco esta plana: Notificacoes, Visao Geral, Metas/Precos, Contatos, Site, Orcamentos, Despesas, Servicos, Regras, Caracteristicas, Eventos, Relatorios, Agenda e Configuracoes. O mesmo problema existe no orcamento, com 13 itens. Organizacao tem 6. A conversa fechou os grupos abaixo.

## Problema atual

Espaco e orcamento colocam o trabalho do dia, o comercial, a casa e o fechamento na mesma lista. O caminho Organizacoes, organizacao e espaco ja fica no topo, misturado visualmente com as paginas. O link de volta do orcamento para o espaco cai em Notificacoes.

## Objetivo da mudanca

Quem abre o painel encontra, no nivel atual, poucos itens a vista e o restante dentro da secao do assunto, sem mudar para onde cada item leva.

## Escopo inicial percebido

Reorganizacao visual dos tres menus que ja existem. Sem rota, contrato ou tela nova.

## Itens incluidos neste request

Espaco, em sanfona. Dia a dia fica sempre aberto: Visao Geral, Orcamentos, Agenda, Eventos, Notificacoes. Comercial: Metas/Precos, Servicos, Despesas, Relatorios, Contatos. A casa: Site, Regras, Caracteristicas. Configuracoes fica fixa no rodape, fora da rolagem.

Orcamento, em sanfona. Orcamento fica sempre aberto: Visao Geral, Editar, Ver Historico. Falar com o cliente: Entrar em contato, Enviar Orcamento, Link do evento, Indicar parceiros. Fechar: Gerar Contrato, Agendar Data, Efetuar Pagamento. No dia: Lista de Presenca, Programacao, Documentos. O nome do cliente continua como titulo acima dos grupos.

Organizacao, so com rotulos, todos visiveis: Operacao (Espacos), Marca (Site, Contratos), Acesso (Permissoes, Proprietarios). Configuracoes no rodape.

O topo continua o caminho de volta: Organizacoes, organizacao, espaco e, no orcamento, o cliente. Esse caminho fica separado da lista de paginas. A secao da pagina aberta tambem fica aberta, com o item marcado. Visao Geral e a porta do espaco: o link de volta a partir do orcamento vai para ela.

## Requisitos implicitos ja visiveis

- cada item continua na rota que ja tem
- o filtro de permissao de cada item continua valendo
- grupo sem nenhum item permitido nao aparece
- dentro do Site, o editor atual substitui o menu do espaco ou da organizacao
- dentro do orcamento, a lista do espaco nao volta a aparecer
- no modo recolhido, o espaco mostra os icones de Dia a dia e Configuracoes; o orcamento mostra os icones do grupo Orcamento; a organizacao mostra os icones de todos os itens, porque nao ha sanfona

## Casos de erro e borda ja percebidos

- usuario sem permissao de parte de um grupo: os itens restantes ficam; o grupo some se ficar vazio
- pagina atual num grupo fechado por padrao: esse grupo abre junto do grupo que fica sempre aberto
- sidebar recolhida: nao ha sanfona; so os icones do grupo sempre aberto, mais Configuracoes no espaco
- Notificacoes segue como item; nao nasce contador novo
- mobile: a secao abre na propria coluna; nao abre menu para o lado

## Dependencias

- os tres menus ja existem e ja filtram por permissao
- o editor de Site ja substitui o menu do nivel quando a rota e de site

## Restricoes e cuidados

- nao criar rota nem mudar o destino dos itens
- nao recolocar Orçamentos, Agenda ou Eventos como filhos de Visao Geral
- nao juntar Site, Regras, Servicos e Precos num unico cadastro
- nao alterar o editor de Site
- nao empilhar o menu do espaco com o do orcamento

## Perguntas em aberto

- A sanfona lembra o que a pessoa deixou aberto? Premissa: nao; ao entrar, ficam abertos o grupo fixo e o grupo da pagina atual.
- Notificacoes ganha contagem? Premissa: nao neste request; continua item de Dia a dia.
- O editor de Site entra num grupo? Premissa: nao; ao abrir Site, o menu do editor substitui o do espaco, como hoje.
- Configuracoes da organizacao tambem fica no rodape? Premissa: sim.

## Prioridade sugerida

Media. O painel funciona; a lista do espaco e a do orcamento ja passaram do que cabe numa leitura so.

## Faixa sugerida para task workflow

- `B` — tres menus de um repo, com grupos ja fechados e sem rota nova
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so frontend, itens e rotas ja existem. Vira spec somente se a sidebar recolhida exigir popover ou um modelo de navegacao novo.

## Sugestao de slug da spec

- `framework_core/specs/sidebar-por-secoes/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `organizar-sidebar-por-secoes-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: secoes no espaco, no orcamento e na organizacao; Configuracoes no rodape; volta do orcamento para a visao geral do espaco; 8 testes em `sidebar-nav-model.test.ts` e `SectionedNav.test.tsx`; o painel no browser foi para o login
- derivacao repo-local: `nao se aplica`
