# Solicitacao da Tarefa

## Nome sugerido da tarefa

Reordenar e trocar fotos no orcamento e na apresentacao

## Resumo da solicitacao

Nas tres paginas publicas da galeria — orcamento na URL antiga, orcamento na URL nova e apresentacao do espaco — quem edita o site do espaco reordena as fotos e troca uma foto por outra do catalogo. Quem nao edita so ve a galeria parada.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — as tres rotas sao publicas; o catalogo das fotos que ficaram de fora so pode sair para quem tem `EDIT_VENUE_SITE` naquele espaco
- risco principal: a URL nova ou a apresentacao entregar o catalogo, ou aceitar a gravacao, para visitante, cliente ou usuario sem a permissao Site
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: criar ou alterar permissao; upload, exclusao e a biblioteca de Fotos; fotos de caracteristica, servico ou e-mail; mudar o formato da URL; redesenhar a ordem dos blocos de cada pagina
- prova minima desta execucao: logado com Site no espaco, a URL antiga do orcamento, `/espaco/{casa}/orcamento/{nome}-{codigo}` e `/espaco/{casa}/apresentacao` mostram alca e Trocar foto, a nova ordem persiste e a troca persiste; sem essa permissao, as tres paginas ficam sem alca e sem botao, e a resposta nao traz as fotos de fora
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se a apresentacao ja recebesse `canReorder` e o catalogo e a URL nova ja resolvesse o codigo publico nessa leitura
- nivel de autonomia: `L2`
- camadas transversais: `security`, `design`, `patterns`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
- libs obrigatorias: `security`, `node`, `patterns`, `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/topics/public-pages-and-branding.md`
  - `.cursor/framework_core/topics/permissions-catalog.md`
- caminhos candidatos: `ProposalView`; `VenuePresentation`; `canEditVenueSite`; `listVenueImageCatalog`; `getProposalPresentation`; `getVenuePresentation`
- palavras-chave ou simbolos de busca: `Trocar foto`, `canReorder`, `EDIT_VENUE_SITE`, `image-choice`, `image-order`, `proposalPublicLookup`
- testes provaveis: apresentacao do orcamento com codigo publico devolve catalogo so para quem tem Site; sem token ou sem permissao o catalogo sai vazio e a gravacao responde recusa; a apresentacao do espaco repete essa regra; a URL antiga continua trocando e reordenando
- nao ler por padrao: specs de preco, servico e caracteristica; `database` (nao ha schema novo)

## Contexto informado na entrada

Pedido em chat, com as tres telas abertas. Decisoes fechadas: as tres funcionam da mesma maneira, com ordem e troca; so edita quem tem a permissao Site (`EDIT_VENUE_SITE`) naquele espaco. Quem criou o espaco ja nasce com ela. Outra pessoa da equipe so edita se a permissao tiver sido concedida. Cliente no link e visitante da apresentacao nao editam.

A URL antiga do orcamento ja faz as duas coisas. Na URL nova da para arrastar, mas Trocar foto nao aparece. Na apresentacao nao ha alca nem botao.

## Problema atual

A mesma galeria do espaco se comporta diferente conforme o endereco. No orcamento antigo, quem tem Site move a foto e troca. No orcamento com `/espaco/{casa}/orcamento/{nome}-{codigo}`, a alca aparece e a troca nao. Na apresentacao publica do espaco, a galeria e estatica para todo mundo, inclusive para quem edita o site.

## Objetivo da mudanca

Quem tem Site naquele espaco reordena e troca a foto na URL antiga do orcamento, na URL nova do orcamento e na apresentacao do espaco. Quem nao tem so assiste.

## Escopo inicial percebido

Ajustar a leitura e a gravacao da galeria publica para o codigo do orcamento e levar os mesmos dois controles para a apresentacao do espaco, com a mesma permissao que o orcamento ja usa. Toca `frontend` e `backend`. Nao ha schema novo.

## Itens incluidos neste request

- URL antiga do orcamento: alca e Trocar foto continuam, so para quem tem Site
- URL nova do orcamento: alca e Trocar foto, com a troca persistindo
- apresentacao do espaco: alca e Trocar foto nas fotos que a pagina ja mostra
- visitante, cliente e usuario sem Site: galeria parada nas tres, sem o catalogo das fotos de fora
- a gravacao continua autorizada no backend; o botao no frontend nao substitui essa checagem

## Requisitos implicitos ja visiveis

- e a mesma galeria do espaco nas tres paginas; mudar a ordem ou a foto numa delas vale para as outras
- vale a regra que a URL antiga ja usa: mais de uma foto visivel libera a alca; mais de uma foto no catalogo libera Trocar foto
- uma foto visivel e outras de fora ainda permite trocar, sem alca de ordem
- nenhuma foto marcada: a pagina segue sem os controles
- o layout de cada pagina permanece o que ja e; so entram os controles nas fotos existentes
- nao criar permissao nova
- rota publica continua publica; o que muda e o recorte quando ha sessao com Site

## Casos de erro e borda ja percebidos

- sem sessao: sem alca, sem Trocar foto e sem fotos ocultas na resposta
- sessao sem Site naquele espaco: igual ao visitante; a gravacao e recusada
- codigo publico inexistente ou espaco inexistente: a pagina nao mostra galeria de outra casa
- uma unica foto no catalogo: nao ha o que trocar
- uma unica foto visivel: nao ha ordem para mudar
- falha ao salvar: a foto anterior volta, como o orcamento antigo ja faz

## Dependencias

- a URL antiga ja reordena e troca com `EDIT_VENUE_SITE`
- a URL nova do orcamento ja abre a mesma pagina e ja resolve o codigo para as fotos visiveis
- a apresentacao publica do espaco ja existe e ja lista as fotos marcadas
- `canEditVenueSite` ja decide quem edita o site daquele espaco

## Restricoes e cuidados

- nao alargar quem edita: Site neste espaco, e somente isso
- nao devolver o catalogo, nem a url de foto de fora, para quem nao tem Site
- nao ler nem versionar valores de `.env`
- a rota publica e intencional; entrar na allowlist nao autoriza a gravacao
- nao criar terceira abordagem de estado no frontend
- multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Nenhuma. As tres paginas ganham os dois controles, e quem edita e quem tem Site naquele espaco.

## Prioridade sugerida

Media. A URL nova ja esta em uso e a troca de foto sumiu nela; a apresentacao ficou de fora da mesma edicao.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: a mesma edicao atravessa a URL antiga, a URL nova e a apresentacao, com contrato publico e permissao. Toca `frontend` e `backend` e se quebra em mais de uma task. Nao e seguro executar como task isolada.

## Sugestao de slug da spec

- `framework_core/specs/2026-11-20-editar-fotos-orcamento-e-apresentacao/`

## Sugestao de nome do arquivo

- `editar-fotos-orcamento-e-apresentacao-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-20-editar-fotos-orcamento-e-apresentacao/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
