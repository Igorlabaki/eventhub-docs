# Solicitacao da Tarefa

## Nome sugerido da tarefa

Ordem dos links na pagina interna do link tree, fora de Configuracoes

## Resumo da solicitacao

Quem edita o site muda a posicao dos links na pagina interna do link tree, arrastando a linha. A aba Redes de Configuracoes deixa de ordenar. A pagina publica so mostra o resultado, na ordem gravada.

## Context Pack

- frente principal: frontend (`eventhub-vista-dashboard/`); a pagina interna do link tree passa a gravar a ordem e a aba Redes deixa de arrastar
- superficie sensivel: nao — o write de ordem ja existe e continua para quem edita o site; a pagina publica nao ganha controle
- camadas transversais: `design`
- risco principal: o arraste da pagina interna gravar so os links visiveis e embaralhar os desmarcados, ou Configuracoes continuar ordenando em paralelo
- repos tocados: `frontend` (`eventhub-vista-dashboard/`); `backend` (`art56_server_v3/`) so se o write de ordem atual nao aceitar a lista inteira da pagina interna
- fora de escopo operacional: arraste, cadastro ou remocao na pagina publica; campo de URL, criar ou apagar rede na pagina interna; redesenhar KPIs, busca ou checkbox de visibilidade; schema ou coluna nova
- prova minima desta execucao: em `/venue/{id}/link-tree`, sem busca e sem filtro, arrastar Instagram para cima de Facebook grava e a pagina publica `/espaco/{nome}/links` abre nessa ordem depois de recarregar; com busca ou filtro a linha nao arrasta; na aba Redes de Configuracoes nao ha alca e a linha nao troca de lugar; `npm test` do front verde no que cobre as duas telas
- criterio de escalada: promover para spec se gravar a ordem da lista interna (marcados e desmarcados) exigir endpoint novo ou schema
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/frontend-map.md`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Demais paginas publicas`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueLinkTree.tsx`; `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx`; `eventhub-vista-dashboard/src/lib/venue-link.ts`; `eventhub-vista-dashboard/src/services/venue.service.ts` (`orderVenueLinks`, `saveVenueLinks`); `art56_server_v3/src/use-cases/venue/venue-links/use-case-venue-links.ts` (`reorderShown`)
- palavras-chave ou simbolos de busca: `VenueLinkTreeView`, `reorderVenueLinks`, `orderVenueLinks`, `dragEnabled`, `GripVertical`, `panelLinksFromHouse`
- testes provaveis: `eventhub-vista-dashboard/src/pages/VenueLinkTree.test.tsx`; `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.test.tsx`
- nao ler por padrao: `security`, `database`, `observability`, specs inteiras, `topics/` fora do trecho de paginas publicas

## Contexto informado na entrada

Chat, com a pagina interna aberta em `/venue/{id}/link-tree`. O dono consegue mudar a posicao dos links na aba Redes de Configuracoes e nao consegue na pagina do link tree. A ordem deve ser controlada nessa pagina, e nao em Configuracoes.

Decisoes fechadas na conversa, que a execucao nao reabre: o arraste sai de Configuracoes e entra na pagina interna do link tree; a pagina publica nao volta a ordenar.

## Problema atual

A aba Redes grava a `position` arrastando a linha. A pagina interna do link tree so marca o que aparece na pagina publica. A pagina publica mostra a ordem e nao oferece alca.

## Objetivo da mudanca

Na pagina interna do link tree, arrastar uma linha troca a posicao e a pagina publica passa a seguir essa ordem; a aba Redes de Configuracoes nao ordena mais.

## Escopo inicial percebido

A pagina interna ganha a alca e o arraste, e grava a ordem. A aba Redes perde a coluna de ordem e o arraste. Cadastro, URL, edicao e remocao continuam em Configuracoes. A pagina publica permanece sem alca.

## Itens incluidos neste request

- alca e arraste na tabela da pagina interna do link tree, para quem edita o site
- gravar a ordem e refleti-la na pagina publica
- tirar a alca e o arraste da aba Redes

## Requisitos implicitos ja visiveis

- a permissao continua a de editar o site; quem so visualiza ve a lista e nao grava
- busca e filtro de visibilidade ativos desligam o arraste, para a posicao de quem ficou de fora da lista nao se perder
- marcar e desmarcar visibilidade continua na pagina interna
- a pagina publica nao ganha alca, cadastro nem remocao

## Casos de erro e borda ja percebidos

- arrastar para a mesma posicao nao duplica nem perde a linha
- lista filtrada por busca ou por "No link tree" / "Fora" nao arrasta
- link desmarcado continua na pagina interna e fora da pagina publica; a ordem gravada vale quando ele voltar a aparecer
- falha ao gravar devolve a ordem anterior
- quem nao edita o site nao arrasta

## Dependencias

- a pagina interna do link tree ja existe
- a aba Redes ja grava `position`
- a pagina publica ja le a ordem gravada
- o write de ordem ja existe; a execucao confirma se ele aceita a lista inteira da pagina interna

## Restricoes e cuidados

- nao devolver o arraste para a pagina publica
- nao criar schema, coluna nem permissao nova
- nao misturar este pedido com subtitulo ou remocao na pagina publica
- nao reabrir o catalogo de redes nem o formulario de URL da aba Redes
- se o write atual so aceitar os links que ja estao na pagina publica, nao gravar uma lista parcial que embaralhe os desmarcados

## Perguntas em aberto

1. A ordem gravada inclui os links desmarcados? Premissa: sim. A lista inteira da pagina interna, na ordem em que aparece sem busca e sem filtro. A pagina publica segue essa ordem so nos que estao marcados.
2. O arraste fica na linha inteira ou so na alca? Premissa: alca visivel na linha, no mesmo gesto que a aba Redes usa hoje.

## Prioridade sugerida

Media. As duas telas ja funcionam; o controle de ordem esta na tela errada.

## Faixa sugerida para task workflow

- `B` — duas telas de um mesmo recurso, com write de ordem ja existente e decisoes fechadas
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um gesto que ja existe muda de tela; nao ha jornada nova nem schema. Vira spec so se a lista interna nao couber no write de ordem atual

## Sugestao de slug da spec

- nao se aplica
- se escalar: `framework_core/specs/2026-11-21-ordem-dos-links-no-link-tree/`

## Sugestao de nome do arquivo

- `ordem-dos-links-no-link-tree-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `opcional`
- camadas transversais: `design`
