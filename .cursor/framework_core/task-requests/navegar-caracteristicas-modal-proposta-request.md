# Solicitacao da Tarefa

## Nome sugerido da tarefa

Passar para a proxima caracteristica dentro do modal de detalhe na proposta publica

## Resumo da solicitacao

Na proposta publica, o card `Conheça nosso espaço` ja mostra o `?` ao lado das caracteristicas que tem foto, descricao ou video, e o `?` abre o modal com esses dados, como nos servicos. Falta navegar entre elas: com o modal aberto, o cliente toca na seta lateral, desliza para o lado ou usa as setas do teclado e o modal mostra a proxima (ou a anterior) caracteristica que tem detalhe.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- camadas transversais: `design`
- risco principal: cair numa caracteristica sem detalhe (modal vazio), ou o video do YouTube da caracteristica anterior continuar tocando depois da troca
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: backend e contrato da apresentacao (ja devolvem `description`, `imageUrl` e `videoUrl`); cadastro da caracteristica no painel; navegacao no modal dos servicos (`Sua experiência inclui` e formularios publicos); layout da lista de caracteristicas
- prova minima desta execucao: em `/proposal/:id/view` de uma casa com 3 ou mais caracteristicas com detalhe e ao menos 1 sem, abrir o `?` da primeira; a seta da direita, a tecla `ArrowRight` e o deslize para a esquerda no celular mostram a proxima com detalhe, pulando a que nao tem; o contador mostra `2 de N`; trocar com video tocando para o video; com uma unica caracteristica com detalhe, nao aparecem setas
- criterio de escalada: permanece `smart`; sobe para `normal` se a navegacao tiver de valer tambem nos servicos e nos formularios publicos
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/proposal/forms/PublicServiceDetail.tsx` em `PublicServiceDetailDialog`; `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no bloco `house.amenities` (card `Conheça nosso espaço`) e no estado `amenityDetail`/`amenityDetailOpen`
- libs obrigatorias: `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/specs/2026-11-05-foto-video-descricao-caracteristica/00-overview.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/lib/amenity-video.ts` (`hasAmenityDetail`, `amenityVideoEmbedUrl`); `eventhub-vista-dashboard/src/components/ui/dialog.tsx`; `eventhub-vista-dashboard/src/components/ui/carousel.tsx` (so como referencia, se ajudar no deslize)
- palavras-chave ou simbolos de busca: `PublicServiceDetailDialog`, `hasAmenityDetail`, `amenityDetail`, `amenityDetailOpen`, `HelpCircle`, `surfaceStyle`, `cardStyle`
- testes provaveis: `PublicServiceDetail.test.tsx` (setas e contador so aparecem com as props de navegacao; sem elas o modal fica igual); `amenity-video.test.ts` se a filtragem virar funcao em `lib/`
- nao ler por padrao: `security`, `database`, backend, `topics/`

## Contexto informado na entrada

Pedido em chat: "agora que caracteristicas esta com foto e descricao la no orcamento, quando tiver listando eles deve funcionar assim como o servico: se tiver descricao ou foto ou video fica um `?` que a pessoa clica e abre o modal com foto e descricao; se ele aperta pro lado vai pra proxima caracteristica com foto e descricao".

Leitura previa do codigo: o `?` com `hasAmenityDetail` e o modal com foto, descricao e video ja existem em `ProposalView.tsx`, entregues pela spec `2026-11-05-foto-video-descricao-caracteristica` (ainda nao commitada). O que falta e a navegacao entre caracteristicas.

## Problema atual

O estado guarda o objeto da caracteristica aberta (`amenityDetail`), entao o modal nao sabe qual e a anterior nem a proxima. Para ver outra, o cliente tem de fechar o modal e achar o proximo `?` na lista.

## Objetivo da mudanca

Com o modal de uma caracteristica aberto na proposta publica, seta lateral, deslize e teclado levam a proxima ou a anterior caracteristica que tem foto, descricao ou video, sem fechar o modal.

## Escopo inicial percebido

Props opcionais de navegacao no `PublicServiceDetailDialog` (anterior, proxima, posicao) e, no `ProposalView`, o estado passa a ser o indice dentro da lista filtrada por `hasAmenityDetail`. Sem backend, sem campo novo.

## Itens incluidos neste request

- lista das caracteristicas com detalhe, na ordem de `position` em que ja aparecem no card
- estado por indice no `ProposalView`, com o reset que ja existe ao trocar de proposta
- setas laterais e contador `x de N` no modal, so quando houver mais de uma caracteristica com detalhe
- teclas `ArrowLeft`/`ArrowRight` e deslize horizontal no toque
- troca do conteudo zera o scroll do modal e desmonta o `iframe` anterior

## Requisitos implicitos ja visiveis

- o modal dos servicos continua igual (props novas opcionais)
- setas e contador nas cores da casa (`surfaceStyle`), com alvo de toque confortavel no celular
- botoes com `aria-label` (`Caracteristica anterior`, `Proxima caracteristica`)
- o deslize nao pode brigar com a rolagem vertical do modal nem com o `iframe` do video

## Casos de erro e borda ja percebidos

- uma unica caracteristica com detalhe: sem setas nem contador
- caracteristica sem detalhe entre duas com detalhe: pulada
- video tocando ao trocar: para
- foto alta com scroll no meio: a proxima abre no topo
- deslize curto ou diagonal: nao troca

## Dependencias

- spec `2026-11-05-foto-video-descricao-caracteristica` no codigo (`T-01` a `T-04`, nao commitada em 2026-11-12); este request parte do `?` e do modal que ela entregou

## Restricoes e cuidados

- nao mexer na regra de `hasAmenityDetail` (video so conta se for YouTube valido)
- nao trocar o `Dialog` por outro componente; reaproveitar o `PublicServiceDetailDialog`
- manter `.scrollbar-house` e o `surfaceStyle` do modal

## Perguntas em aberto

- Na ultima caracteristica, a seta volta para a primeira ou para? Premissa: navegacao circular, como o carrossel de fotos da proposta publica.
- Levar a mesma navegacao para o modal dos servicos? Premissa: nao nesta task; as props ficam prontas para isso.
- Mostrar o contador `x de N`? Premissa: sim, discreto, perto das setas.

## Prioridade sugerida

Media. Melhora a apresentacao do espaco para o cliente; nada quebrado.

## Faixa sugerida para task workflow

- `A` — um repo, dois arquivos e um teste, sem contrato
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: ajuste de interacao em um componente que ja existe, sem backend nem dado novo

## Sugestao de slug da spec

- `framework_core/specs/navegar-caracteristicas-modal-proposta/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `navegar-caracteristicas-modal-proposta-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `executar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica` (um repo)
