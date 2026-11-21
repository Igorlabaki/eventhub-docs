# Solicitacao da Tarefa

## Nome sugerido da tarefa

Botao para criar link na link tree, no painel e na pagina publica

## Resumo da solicitacao

A aba Redes cria rede pelo select "Escolher rede". Passa a ter um botao que abre um modal para escolher a rede e colocar o link. Na pagina publica `/espaco/:id/links`, quem tem `EDIT_VENUE_SITE` cria, remove e muda a posicao ali. Sem link, essa pessoa ve o container "Ainda nao ha link cadastrado na sua link tree" e o botao de cadastrar.

## Context Pack

- frente principal: frontend (`eventhub-vista-dashboard/`) na aba Redes e na pagina publica de links; backend (`art56_server_v3/`) so no write de criar a partir da pagina publica, que hoje nao existe
- superficie sensivel: sim (a pagina publica passa a gravar link; a permissao continua `EDIT_VENUE_SITE` / `canEditVenueSite`; visitante nao gerencia)
- camadas transversais: `security`, `design`
- risco principal: o visitante ver o botao ou gravar um link; a aba perder o select sem o modal cobrir rede colada e rede do sistema; URL invalida ou tipo repetido entrar na lista
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: schema ou campo novo; permissao nova; reabrir `task-requests/visual-redes-e-link-tree-request.md` ou a pilula clara; mudar o texto vazio da aba Redes; redesenhar o card publico
- prova minima desta execucao: na aba Redes, o botao abre o modal, Instagram com URL valida vira linha e o select "Escolher rede" saiu da faixa; em `/espaco/AR756/links` sem links, quem tem `EDIT_VENUE_SITE` ve "Ainda nao ha link cadastrado na sua link tree" e o botao, e o visitante nao ve gestao; com links, a mesma pessoa cria (grava na hora), remove e arrasta na propria pagina; teste negativo do visitante no write; `npm test` do front no editor e na pagina, e do back no use case de links se o write mudar
- criterio de escalada: ja e faixa `C`; nao executar como task solta
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx` (select "Escolher rede" e `VenueLinkUrlForm`); `eventhub-vista-dashboard/src/pages/VenueLinks.tsx` em `VenueLinksView` e `venueLinkChrome`
- libs obrigatorias: `react`, `design`, `security`, `node`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro` (rota publica intencional e teste negativo; permissao no front nao substitui o backend)
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Demais paginas publicas`
  - `.cursor/framework_core/project/api-endpoints.md#Venue, precos e configuracao` (as tres linhas de `/venue/links`)
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/lib/venue-link.ts`; `eventhub-vista-dashboard/src/pages/VenueSettings.tsx` (aba `redes`); `eventhub-vista-dashboard/src/services/venue.service.ts`; `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.ts`; `.cursor/framework_core/topics/permissions-catalog.md` (linha `EDIT_VENUE_SITE`)
- palavras-chave ou simbolos de busca: `VenueLinkEditor`, `isPastedVenueLink`, `createVenueLink`, `remainingVenueLinkKinds`, `canReorder`, `canEditVenueSite`, `orderVenueLinks`, `hideVenueLink`, `saveVenueLinks`
- testes provaveis: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.test.tsx`; `eventhub-vista-dashboard/src/pages/VenueLinks.test.tsx`; `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.spec.ts`
- nao ler por padrao: `database`, `observability`, `patterns`, `topics/` fora do trecho de paginas publicas, specs inteiras

## Contexto informado na entrada

Chat com print da aba Redes vazia (busca, "Escolher rede", Visibilidade, cards Total / No link tree / Com link, "0 redes"). O usuario quer o botao nessa aba, o modal com rede e link, e na pagina publica a gestao de criar, remover e mudar posicao para quem esta logado com permissao de editar. Sem link, o container "Ainda nao ha link cadastrado na sua link tree" e o botao so para essa conta.

Nao duplicar: `specs/2026-11-21-visual-redes-e-link-tree/` (visual, select mantido, botao fora de escopo, em execucao); `specs/2026-11-21-criar-rede-do-espaco/` (select cria, modal so de URL, concluida); `specs/2026-11-21-subtitulo-ordem-e-remocao-na-pagina-de-links/` (arrastar e remover na publica, concluida); `specs/2026-11-20-link-tree-do-espaco/` (pagina, concluida).

## Problema atual

- a aba Redes nao tem botao de criar; o select "Escolher rede" acrescenta a linha, e o modal so pede a URL depois que a rede ja foi escolhida
- a pagina publica, com `canReorder`, arrasta (mais de um link) e remove; nao cria
- lista publica vazia nao mostra container nem botao

## Objetivo da mudanca

Na aba Redes, um botao abre o modal em que a pessoa escolhe a rede e coloca o link; na pagina publica, quem tem `EDIT_VENUE_SITE` cria, remove e muda a posicao ali, e a lista vazia mostra "Ainda nao ha link cadastrado na sua link tree" com o botao so para essa pessoa.

## Escopo inicial percebido

Trocar o select da faixa pelo botao e pelo modal na aba `redes`. Na pagina publica, o mesmo gesto de criar para quem ja pode reordenar e remover, gravando na hora, mais o container vazio. O write da publica hoje nao existe: ha `PUT /venue/links/:id/order`, `PUT /venue/links/:id/hide` e o `PUT /venue/links/:id` do editor.

## Itens incluidos neste request

- botao de criar na aba Redes, no lugar do select "Escolher rede"
- modal em que a pessoa escolhe a rede e coloca o link
- criar, remover e mudar posicao na pagina publica para quem tem `EDIT_VENUE_SITE`
- container "Ainda nao ha link cadastrado na sua link tree" quando a publica nao tem link, com o botao so para essa permissao
- visitante sem a permissao nao ve gestao e nao grava

## Requisitos implicitos ja visiveis

- a permissao da publica e a que ja liga `canReorder` (`canEditVenueSite` / `EDIT_VENUE_SITE`); nao criar permissao nova
- arrastar continua sendo a mudanca de posicao quando ha mais de um link
- o modal pede URL so em `PASTED_VENUE_LINK_KINDS`; rede do sistema confirma sem URL e o href segue os dados do espaco
- na aba Redes a linha nova espera "Salvar Alteracoes"; na publica a criacao grava na hora
- o botao de criar na publica tambem aparece quando ja existem links; o texto do container so no vazio
- o texto vazio da aba Redes permanece
- nenhum campo ou tabela nova

## Casos de erro e borda ja percebidos

- visitante ou sessao sem `EDIT_VENUE_SITE`: sem botao, sem alca, sem remover, e o write recusa
- URL invalida ou tipo que nao usa link colado: a linha nao entra
- tipo que ja esta na lista: nao duplica
- rede do sistema sem destino (WhatsApp sem numero, mapa sem endereco): continua fora da pagina publica
- lista publica vazia para o visitante: sem o container de gestao
- falha ao gravar na publica: a lista mostrada volta ao que estava

## Dependencias

- nenhuma spec aberta desta demanda
- nao alterar `specs/2026-11-21-visual-redes-e-link-tree/` nem `task-requests/visual-pagina-links-espaco-request.md`
- ordem e remocao publicas ja existem; este request acrescenta a criacao e o vazio

## Restricoes e cuidados

- nao criar schema, campo ou permissao
- autorizacao no backend; o botao no front nao basta
- a rota publica de leitura continua publica; o write novo entra autenticado e com teste negativo
- preservar `createVenueLink`, `checkVenueLinkUrl`, `canReorder`, ordem e ocultar
- multi-repo: depois da spec, derivar com `tasking/task-request-repo-split-prompt.md` ou o split da spec
- insumo para o bootstrap: editor em `VenueLinkEditor.tsx`; aba em `VenueSettings.tsx`; regras em `venue-link.ts`; publica em `VenueLinks.tsx`; cliente em `venue.service.ts`; permissao e payload em `use-case-venue-links.ts`

## Perguntas em aberto

1. O select "Escolher rede" sai da faixa quando o botao existir? Premissa: sai. A escolha da rede fica no modal.
2. Rede do sistema pede URL no modal? Premissa: nao. URL so nas redes de `PASTED_VENUE_LINK_KINDS`. Nas do sistema, escolhe a rede e confirma.
3. O texto "Ainda nao ha link cadastrado na sua link tree" substitui o vazio da aba Redes? Premissa: nao. Esse container e da pagina publica.
4. Criar pela pagina publica grava na hora? Premissa: sim. Na aba Redes a linha espera "Salvar Alteracoes".
5. Com links ja na pagina publica, onde fica o botao de criar? Premissa: visivel para quem tem `canReorder`, tambem com a lista cheia. O container com o texto so no vazio.

## Prioridade sugerida

Media. As duas telas ja listam e, na publica, ja reordenam e removem. O pedido e o botao, o modal e a criacao na propria pagina.

## Faixa sugerida para task workflow

- `C` — aba Redes e pagina publica, permissao existente e um write de criacao na publica que hoje nao existe
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o mesmo gesto de criar aparece na aba Redes e na pagina publica, e a publica precisa de um write que o editor ainda nao oferece

## Sugestao de slug da spec

- `framework_core/specs/2026-11-21-criar-link-na-link-tree/`

## Sugestao de nome do arquivo

- `criar-link-na-link-tree-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-21-criar-link-na-link-tree/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `necessaria`
