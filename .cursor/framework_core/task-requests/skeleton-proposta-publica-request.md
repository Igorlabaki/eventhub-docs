# Solicitacao da Tarefa

## Nome sugerido da tarefa

Segurar a pagina publica do orcamento ate a midia baixar

## Resumo da solicitacao

Quem abre o link publico do orcamento ve um skeleton de containers no formato da pagina inteira enquanto o que falta ainda carrega. Texto, fotos e video so aparecem depois que esse conjunto ja baixou. Nesse momento as animacoes de entrada que ja existem comecam.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: a pagina ficar presa num skeleton, ou o conteudo aparecer e animar antes da midia, ou a tela de carregamento interna perder a marca EventHub
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: rotas internas e a tela EventHub delas, painel, textos, fotos, cores, calculo, rota publica, duracao e distancia das animacoes ja definidas, schema e API
- prova minima desta execucao: abrir `/proposal/:id/view` com logo, fotos e video de arquivo e ver so o skeleton ate esses arquivos terminarem; em seguida a pagina aparece e as animacoes de entrada comecam; abrir uma rota interna que ainda carrega e continuar vendo a tela EventHub
- criterio de escalada: promover para `normal` se a espera da midia precisar valer para outros links publicos; `spec` nao se aplica
- nivel de autonomia: `L2`
- camadas transversais: `design`. `security`, `database`, `observability` e `patterns` nao se aplicam

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no estado de carregamento e nas classes de entrada
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/animacoes-proposta-publica-request.md#Objetivo da mudanca`
- caminhos candidatos: pagina publica da proposta; tela de carregamento atual do link; animacoes de entrada ja aplicadas no primeiro paint
- palavras-chave ou simbolos de busca: `PublicProposalLoadingScreen`, `ProposalView`, `animate-logo-in`, `animate-cover-in`, `animate-rise-in`, `RevealBlock`
- testes provaveis: abrir o link com fotos e video de arquivo e confirmar que nada real aparece antes do download; repetir com espaco sem foto ou sem video; simular arquivo que falha; abrir uma rota interna carregando
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a pagina publica da AR756 aberta. O link deve mostrar um skeleton de containers simulando a pagina completa para o que ainda esta carregando. As coisas so podem aparecer depois que tudo ja tiver baixado. So entao as animacoes sao liberadas.

## Problema atual

No link `/proposal/:id/view`, a espera acaba quando os dados da proposta e da apresentacao chegam. A pagina monta e as animacoes de entrada comecam enquanto logo, fotos, video e a fonte ainda baixam. A tela dessa espera e um logo centralizado com spinner, e nao o formato da pagina.

## Objetivo da mudanca

Na pagina publica de qualquer orcamento, o intervalo de espera e um skeleton no formato da pagina; o conteudo real entra somente depois do download da midia dessa pagina; as animacoes de entrada comecam nesse instante.

## Escopo inicial percebido

Ajuste visual de uma pagina que ja existe. Os dados, as fotos, o video, as cores e as animacoes permanecem. Muda o momento em que a pagina pronta substitui a espera.

## Itens incluidos neste request

- o carregamento de `/proposal/:id/view` passa a ser um skeleton de containers no formato da pagina completa
- o skeleton acompanha os blocos que a proposta vai mostrar
- texto, fotos e video do tour em arquivo so entram depois de baixados
- as animacoes de entrada ja existentes so comecam quando esse conteudo aparece
- a tela de carregamento de dentro do EventHub permanece como esta

## Requisitos implicitos ja visiveis

- a mudanca vale para todo link publico de orcamento; AR756 e o exemplo, nao um estilo so daquele registro
- bloco que o orcamento nao tem nao deixa skeleton sobrando nem buraco
- a paleta do skeleton, quando as cores do espaco ja chegaram, e a mesma da pagina pronta
- as animacoes nao mudam de duracao, distancia ou alvo; so deixam de disparar cedo
- `prefers-reduced-motion` continua mostrando a pagina inteira e parada, depois da espera
- a tela EventHub das rotas internas nao entra nesse fluxo

## Casos de erro e borda ja percebidos

- dados ainda nao chegaram: skeleton generico no formato da pagina, no fundo de fallback, sem a marca EventHub
- espaco sem logo, sem foto ou sem video: o skeleton e a pagina so incluem o que existe
- um arquivo falha ou nao termina: a pagina nao fica presa; depois de um prazo curto o conteudo aparece e as animacoes disparam
- apresentacao falha e a pagina cai em nao encontrado: o skeleton nao vira a marca de outro espaco
- rota interna carregando ao mesmo tempo: continua com a tela EventHub

## Dependencias

- a pagina publica ja existe em `ProposalView.tsx`
- a espera atual do link ja usa a marca e as cores do espaco (`carregamento-proposta-publica-request.md`); este pedido substitui essa peca no link
- as animacoes de entrada ja existem (`animacoes-proposta-publica-request.md`); este pedido so segura o comeco delas

## Restricoes e cuidados

- nao alterar a tela de carregamento das rotas internas
- nao mudar texto, foto, calculo, cor, rota publica, schema nem API
- nao redesenhar as animacoes de entrada
- nao recolocar a marca EventHub no carregamento do link
- nao deixar o link preso para sempre se um arquivo nao baixar

## Perguntas em aberto

- O que conta como "tudo baixado"? Premissa: os dados da proposta, a apresentacao, o logo, todas as fotos, o video de arquivo do tour e a fonte Manrope. O iframe do mapa e o player do YouTube nao seguram a pagina.
- O skeleton substitui o logo com spinner do link? Premissa: sim. A tela EventHub interna permanece.
- Antes dos dados, o skeleton e generico? Premissa: sim, no formato geral da pagina; quando os dados chegam, ele espelha os blocos que vao existir, e o conteudo real espera a midia.
- As animacoes mudam? Premissa: nao. Comecam juntas no instante em que o conteudo aparece, inclusive a revelacao por scroll que ja existe.
- Quanto esperar se um arquivo falhar? Premissa: um prazo curto, e em seguida a pagina aparece mesmo assim.

## Prioridade sugerida

Media. Melhora o primeiro contato com o link, sem corrigir um fluxo quebrado.

## Faixa sugerida para task workflow

- `A` — uma pagina, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: ajuste visual da espera de uma pagina publica que ja existe; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; a pagina continua na spec `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `skeleton-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
