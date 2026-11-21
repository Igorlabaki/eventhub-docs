# Solicitacao da Tarefa

## Nome sugerido da tarefa

Ate tres fotos, em ordem escolhida, em cada caracteristica do espaco

## Resumo da solicitacao

A caracteristica do espaco deixa de aceitar uma foto so e passa a aceitar ate tres. No criar e no editar da caracteristica, o usuario adiciona, remove e reordena as fotos. Na proposta publica, o modal de detalhe da caracteristica mostra as fotos em grid, na ordem escolhida.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — upload de imagem e exposicao na pagina publica do orcamento
- risco principal: perder a foto que cada caracteristica ja tem ao trocar o modelo de uma foto para varias, ou deixar foto removida acessivel no storage como se ainda fosse do item
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: video da caracteristica (continua um link do YouTube), descricao, galeria da casa, foto do servico, arrastar e soltar, apagar a coluna `imageUrl` antiga
- prova minima desta execucao: no painel, criar uma caracteristica com 3 fotos e conferir que a quarta e recusada; editar trocando a ordem, removendo uma e adicionando outra; caracteristica que ja tinha foto abre no editar com essa foto como primeira; no link publico, o modal mostra 1, 2 ou 3 fotos em grid na ordem salva; usuario sem permissao de edicao nao grava; `npx prisma validate` e `npm test -- --run` no backend, `npm test` e `npm run build` no frontend
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido ao painel, sem schema novo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `database`, `node`, `patterns`, `react`, `design`, `aws`, `security`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/specs/2026-11-05-foto-video-descricao-caracteristica/03-design.md`
  - `.cursor/framework_core/project/planetscale.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/aws/index.md`
- caminhos candidatos:
  - `art56_server_v3/prisma/schema.prisma` (`VenueAmenity`)
  - `art56_server_v3/src/router/venue-amenity.ts`
  - `art56_server_v3/src/use-cases/venue-amenity/`
  - `art56_server_v3/src/functions/venue-amenity-image.ts` e `venue-amenity-image-storage.ts`
  - `art56_server_v3/src/repositories/in-prisma/proposal-in-prisma-repository.ts` e `src/functions/to-proposal-presentation.ts`
  - `eventhub-vista-dashboard/src/components/venue-amenity/venue-amenity-form.tsx`
  - `eventhub-vista-dashboard/src/lib/amenity-form.ts` e `src/lib/amenity-video.ts`
  - `eventhub-vista-dashboard/src/components/proposal/forms/PublicServiceDetail.tsx` (`PublicServiceDetailDialog`)
- palavras-chave ou simbolos de busca: `VenueAmenity`, `imageUrl`, `removeImage`, `upload.single("file")`, `hasAmenityDetail`, `PublicServiceDetailDialog`
- testes provaveis: `venue-amenity.spec.ts`, `use-case-get-proposal-presentation.spec.ts`, `amenity-form.test.ts`, `amenity-video.test.ts`, `PublicServiceDetail.test.tsx`
- nao ler por padrao: `topics/`, specs de outras frentes, galeria da casa, servicos

## Contexto informado na entrada

Pedido em chat, no formulario de editar caracteristica (exemplo: "2 saloes cobertos"), que hoje tem um campo Foto com um arquivo so. Decisoes do usuario: no maximo 3 fotos; reordenar tudo no criar e no editar da caracteristica; no modal publico, as fotos em grid.

## Problema atual

A caracteristica guarda uma unica foto (`imageUrl`). O formulario aceita um arquivo e oferece so "Remover foto". As rotas de criar e editar recebem um arquivo. O modal publico mostra uma imagem.

## Objetivo da mudanca

Um usuario autorizado grava ate tres fotos por caracteristica, em ordem escolhida por ele no criar e no editar, e a proposta publica mostra essas fotos em grid nessa ordem.

## Escopo inicial percebido

Schema com fotos por caracteristica e migration aditiva que leva a foto atual de cada item para o novo modelo. Rotas, validacao e use cases de criar, editar, listar e apagar. Formulario do painel com varias fotos e reordenacao. Leitura da apresentacao publica e modal de detalhe em grid. Toca `backend` e `frontend`.

## Itens incluidos neste request

- ate 3 fotos por caracteristica, todas opcionais
- no criar e no editar: adicionar, remover e reordenar as fotos, inclusive misturando fotos ja salvas com novas
- a foto que cada caracteristica ja tem vira a primeira, sem reenvio
- apagar a caracteristica remove as fotos dela do storage
- foto removida na edicao sai do storage
- modal publico de detalhe com as fotos em grid, na ordem salva
- o `?` da caracteristica aparece quando houver pelo menos uma foto, descricao ou video

## Requisitos implicitos ja visiveis

- a gravacao passa pelo backend autenticado com `EDIT_VENUE_AMENITIES`; o limite de 3 vale no backend, nao so na tela
- a migration de producao e aditiva e entra na `main` por deploy request; a coluna `imageUrl` fica no banco, sem uso, ate uma limpeza futura
- as fotos reaproveitam o upload de imagem que a caracteristica ja usa (imagem, ate 5 MB)
- a pagina publica recebe so a URL e a ordem das fotos
- contrato FE/BE muda nos dois repos e atualiza `project/api-endpoints.md`
- o frontend nao cria uma terceira forma de estado

## Casos de erro e borda ja percebidos

- quarta foto: a tela nao deixa adicionar e o backend recusa
- arquivo que nao e imagem ou que passa de 5 MB: recusado, sem gravar as outras mudancas pela metade
- id de foto que pertence a outra caracteristica: recusado
- caracteristica sem foto: cadastro e modal seguem como hoje
- remover todas as fotos: o item fica sem foto e o `?` depende de descricao ou video
- falha no upload de uma das novas: nenhuma foto antiga e apagada
- grid com 1, 2 e 3 fotos sem distorcer a imagem no celular

## Dependencias

- a [spec de foto, video e descricao](../specs/2026-11-05-foto-video-descricao-caracteristica/00-overview.md) criou a foto unica; as colunas ja estao na `main` (deploy request 43), mas em 2026-11-12 o codigo estava nao commitado. Confirmar que ele existe nos repos antes de desenhar a nova migration
- [navegar entre caracteristicas no modal](navegar-caracteristicas-modal-proposta-request.md) mexe no mesmo modal publico; o grid nao pode conflitar com as setas e o deslizar entre caracteristicas
- mudanca multi-repo: pode ser derivada depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao adicionar biblioteca de arrastar e soltar; com 3 fotos, botoes de mover bastam
- nao alterar video, descricao, galeria da casa nem foto do servico
- nao apagar a coluna `imageUrl` nesta entrega
- nao ler nem versionar valores de `.env`
- escrita no banco real e deploy request na `main` exigem aprovacao nomeada

## Perguntas em aberto

- Quantas fotos? Decidido: no maximo 3.
- Onde reordenar? Decidido: no criar e no editar da caracteristica.
- Como o modal publico mostra? Decidido: grid. Premissa: 1 foto ocupa a largura toda; 2 lado a lado; 3 com uma grande em cima e duas embaixo.
- Clicar na foto do grid amplia? Premissa: nao nesta entrega.
- A foto ganha legenda? Premissa: nao.
- Como reordenar sem arrastar? Premissa: botoes de mover para a esquerda e para a direita em cada miniatura.

## Prioridade sugerida

Media. E evolucao do cadastro da caracteristica, sem fluxo quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: pede schema novo com migracao de dados existentes, muda o contrato de upload de criar e editar, o formulario do painel e a pagina publica. Toca `backend` e `frontend` e se quebra em varias tasks com ordem (schema, API, painel, publico).

## Sugestao de slug da spec

- `framework_core/specs/2026-11-13-multiplas-fotos-caracteristica/`

## Sugestao de nome do arquivo

- `multiplas-fotos-caracteristica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-13-multiplas-fotos-caracteristica/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
