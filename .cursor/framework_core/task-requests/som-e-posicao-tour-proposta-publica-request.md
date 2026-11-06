# Solicitacao da Tarefa

## Nome sugerido da tarefa

Ligar o som do tour e coloca-lo no lugar da capa na proposta publica

## Resumo da solicitacao

Quando o espaco tem link de tour, a pagina publica do orcamento passa a tocar esse video com som e troca tres blocos de lugar: o video fica logo abaixo do logo, a foto de capa vai para onde o grid esta hoje, e o grid vai para onde o video esta hoje. Sem o link, a pagina permanece como esta.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: tirar o mudo e o navegador segurar o autoplay, ou a troca de blocos desfazer capa, grid, carrossel ou arraste das fotos
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: campo, gravacao e validacao do link; upload de video; video fora da pagina publica do orcamento; mudanca de servicos, valores, visita, rodape ou mapa
- prova minima desta execucao: com o link salvo, abrir a proposta publica, ver o video logo abaixo do logo, a capa no lugar do grid e o grid no lugar antigo do video, e ouvir o tour por um controle de som; sem o link, a ordem atual permanece e o video nao aparece
- criterio de escalada: promover para `spec` se a troca passar a alterar o contrato da apresentacao ou a ordem persistida das fotos
- nivel de autonomia: `L2`
- camadas transversais: `design`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/video-tour-do-espaco-request.md#Requisitos implicitos ja visiveis`
- caminhos candidatos: pagina publica do orcamento, bloco da capa abaixo do logo, grid de fotos e bloco do tour acima de "Seu investimento"; resolvedor do link do tour
- palavras-chave ou simbolos de busca: `ProposalView`, `resolveTourVideo`, `tourVideoUrl`, `muted`, `cover`, `gallery`
- testes provaveis: teste do resolvedor do tour; na pagina publica, com link e sem link, conferir ordem dos blocos e o controle de som
- nao ler por padrao: `topics/`, `security`, configuracoes do espaco e o restante de `specs/2026-11-04-video-tour-do-espaco/`

## Contexto informado na entrada

Pedido em chat, com a proposta publica aberta no video do tour: o video esta sem som. Se existir o link do tour, o video deve ficar logo abaixo do logo, no lugar da foto. Essa foto deve ir para o lugar do grid, e o grid deve ir para o lugar onde o video esta hoje.

## Problema atual

O tour da proposta publica entra mudo, em autoplay e sem controle. Ele fica entre "Sua experiencia inclui" e "Seu investimento", enquanto a foto de capa fica abaixo do logo e o grid de fotos fica mais acima.

## Objetivo da mudanca

Com link de tour salvo, a pessoa ouve o video e ve, nesta ordem visual, o video logo abaixo do logo, a foto de capa no lugar atual do grid e o grid no lugar atual do video.

## Escopo inicial percebido

Ajuste de um bloco que ja existe na pagina publica do orcamento. O link, a gravacao e a regra de qual URL e video continuam como estao. A troca de lugar so acontece quando o link existe.

## Itens incluidos neste request

- som no tour da proposta publica, para arquivo direto e para YouTube
- sem legenda do player no tour; texto gravado na propria imagem do video permanece
- com link de tour: video no lugar da capa, logo abaixo do logo
- com link de tour: foto de capa no lugar atual do grid
- com link de tour: grid no lugar atual do video, acima de "Seu investimento"
- sem link de tour: ordem atual, sem bloco de video

## Requisitos implicitos ja visiveis

- o autoplay com som e bloqueado pelo navegador; o video continua comecando sozinho e o som liga por uma acao de quem assiste
- arquivo direto e YouTube cumprem o mesmo resultado de som, dentro do que cada player permite
- a capa continua sendo a primeira foto; so muda de lugar na tela
- arraste para reordenar, ampliar foto e carrossel continuam funcionando depois da troca
- servicos, comodidades, investimento, mapa e rodape nao mudam de papel

## Casos de erro e borda ja percebidos

- sem link, nenhum bloco muda de lugar e o video nao aparece
- ha tour e nao ha foto: o video fica abaixo do logo e nao existe capa nem grid para mover
- ha tour e so a capa, sem grid: a capa desce para o lugar do grid e o lugar antigo do video fica sem grid
- o video nao pode ficar parado e sem controle se o autoplay com som for recusado
- a troca visual nao pode gravar outra ordem de fotos

## Dependencias

- o link do tour ja e salvo no espaco e ja chega na apresentacao publica
- a capa, o grid e o video ja existem na pagina publica

## Restricoes e cuidados

- nao ler nem versionar valores de `.env`
- nao criar rota publica nova
- nao reabrir o campo do link nem a validacao de URL
- nao mexer na ordem persistida das fotos para resolver posicao de tela

## Perguntas em aberto

- Como o som liga se o navegador bloqueia autoplay com audio? Premissa: o video segue em autoplay mudo e ganha um controle visivel para ativar o som.
- A ultima frase pedia o grid no lugar do video, ou corrigia o destino da foto? Premissa: troca em tres — video no lugar da capa, capa no lugar do grid, grid no lugar do video.
- A capa, ao descer, vira mais um item do grid? Premissa: nao; continua uma foto unica, apenas no lugar onde o grid esta hoje.
- Sem o link, a ordem muda? Premissa: nao.

## Prioridade sugerida

Media. A proposta publica ja mostra o tour; este pedido corrige o som e a posicao.

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

## Candidato a spec

- `nao`
- motivo: o dado e o player ja existem; a mudanca e de som e de ordem visual numa unica pagina, so no frontend, e cabe numa task.

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `som-e-posicao-tour-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- execucao: codigo no frontend; falta a revisao da entrega
- derivacao repo-local: `nao se aplica`
