# Solicitacao da Tarefa

## Nome sugerido da tarefa

Card da biblioteca de fotos só com a imagem e a lixeira no canto

## Resumo da solicitacao

Na pagina Fotos do espaco, cada card mostra só a foto. O campo de descricao sai do card. Excluir vira um icone de lixeira no canto superior direito da foto. A tela nao diz em quais lugares a foto esta sendo usada.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: esconder o bloqueio de exclusao e o usuario achar que a foto sumiu, ou tirar a descricao dos formularios em que a foto e usada (site, servico, caracteristica, e-mail)
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: coluna `description` e `PUT /venue-photo/:id`; icone de lista e modal de usos; faixa que lista Site, Servico, Caracteristica e E-mail; descricao nos formularios que consomem a foto; upload, permissao e regra de 409 do backend
- prova minima desta execucao: em `/venue/:id/photos`, cada card e so a imagem; nao ha input nem texto "Sem descricao"; a lixeira fica no canto superior direito e so para quem tem `EDIT_VENUE_PHOTOS`; excluir uma foto sem uso remove o card; excluir uma foto em uso nao remove o card e nao lista os lugares; `npm test` no frontend cobre o card
- criterio de escalada: permanece `smart`; sobe para `normal` se for preciso mudar o contrato de `GET /venue-photo/list` ou apagar a descricao no backend
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenuePhotos.tsx`
- libs obrigatorias: `design`, `react`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/react/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/types/venue-photo.ts` (`venuePhotoUsageLines`); `eventhub-vista-dashboard/src/services/venue-photo.service.ts`; `eventhub-vista-dashboard/src/components/ui/button.tsx`
- palavras-chave ou simbolos de busca: `onDescription`, `Descricao da foto`, `venuePhotoUsageLines`, `Excluir`, `Trash2`
- testes provaveis: teste de pagina ou componente de `VenuePhotos`, se ja existir; senao, o comportamento observavel na propria pagina
- nao ler por padrao: `security`, `database`, backend, spec `2026-11-14-catalogo-fotos-espaco` inteira, `topics/`

## Contexto informado na entrada

Pedido em chat, com print da pagina Fotos (grade de fotos da casa, input em branco embaixo de cada uma e botao Excluir). O input em branco e a descricao da foto (`aria-label="Descricao da foto"`), salva no `onBlur` por `PUT /venue-photo/:id`.

Decisoes fechadas no chat:

- a foto da biblioteca e so a foto; o card nao tem descricao
- a descricao, quando fizer falta, fica no lugar que usa a foto (site, servico e os demais formularios), nao na biblioteca
- excluir e um icone de lixeira no canto superior direito
- a tela nao mostra onde a foto esta sendo usada: sem icone de lista, sem modal e sem a faixa do topo

## Problema atual

`VenuePhotos.tsx` desenha, em cada card, a imagem, um input de descricao (ou o texto "Sem descricao") e um botao "Excluir". Se a exclusao volta 409, a pagina lista os usos (Site, Servico, Caracteristica, E-mail) numa faixa ambar.

## Objetivo da mudanca

Quem abre Fotos ve a grade so com as imagens, com a lixeira no canto superior direito de cada foto, e a pagina nao informa os lugares em que a foto e usada.

## Escopo inicial percebido

Ajuste visual de `VenuePhotos.tsx`: tirar `onDescription`, o `Input` de descricao e o texto "Sem descricao"; trocar o botao Excluir por icone `Trash2` sobre a foto, no canto superior direito; tirar a faixa `blocked` que lista os usos. Quem nao tem `EDIT_VENUE_PHOTOS` continua vendo so a foto, sem lixeira.

## Itens incluidos neste request

- card composto pela imagem
- lixeira no canto superior direito, visivel so com `EDIT_VENUE_PHOTOS`
- exclusao continua chamando `venuePhotoService.remove`
- foto em uso: o card permanece e a interface nao lista os lugares
- feedback curto quando a exclusao falha, sem nomes de site, servico, caracteristica ou e-mail

## Requisitos implicitos ja visiveis

- o `alt` da imagem nao depende de uma descricao editavel no card
- a descricao ja gravada em `VenuePhoto` pode continuar no banco; esta tela apenas deixa de mostra-la e de edita-la
- upload ("Escolher ficheiros" / "Enviar fotos") permanece como esta

## Casos de erro e borda ja percebidos

- foto referenciada: API responde 409 e a foto nao some; a UI nao monta `venuePhotoUsageLines`
- falha generica de exclusao: toast de erro, como hoje
- usuario sem permissao de edicao: nenhuma lixeira
- grade vazia e estado de carregamento: permanecem

## Dependencias

- pagina Fotos ja entregue pela spec `specs/2026-11-14-catalogo-fotos-espaco/` (`VenuePhotos.tsx`, `venuePhotoService.remove`)
- `DELETE /venue-photo/:id` continua recusando foto em uso; este request nao altera essa regra

## Restricoes e cuidados

- nao remover a coluna `description` nem o `PUT /venue-photo/:id`
- nao alterar os formularios que escolhem a foto e tem descricao propria
- nao reintroduzir icone de lista nem modal de usos (isso foi pedido e depois dispensado no mesmo chat)
- nao mudar permissao, upload nem o seletor `PhotoPicker`

## Perguntas em aberto

- O que a tela diz quando a foto esta em uso e a lixeira nao apaga? Premissa: um toast curto, "Esta foto esta em uso e nao foi excluida", sem listar os lugares.
- A lixeira pede confirmacao? Premissa: nao; o clique exclui na hora, como o botao atual.

## Prioridade sugerida

Media. Ajuste da pagina Fotos ja em revisao; a descricao no card nao sera usada.

## Faixa sugerida para task workflow

- `A` — um arquivo de pagina no frontend, sem contrato e sem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: correcao visual de uma pagina ja entregue pela spec `2026-11-14-catalogo-fotos-espaco`; nao abre fluxo, contrato nem schema novos

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `card-foto-so-imagem-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
