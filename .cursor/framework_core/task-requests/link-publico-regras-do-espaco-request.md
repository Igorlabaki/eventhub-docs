# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abrir o link publico das regras do espaco

## Resumo da solicitacao

O espaco ganha um endereco publico, na marca do espaco, que mostra as regras ja cadastradas. No painel, a tela de regras oferece esse endereco para copiar. O Link do evento ganha um botao que abre a mesma pagina.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — a listagem de regras hoje exige login; a pagina nova e publica de proposito
- risco principal: a leitura publica devolver regra de outro espaco, ou expor dado alem de titulo, texto e ordem
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: alterar o cadastro de regras; publicar regras em orcamento, contrato, e-mail ou site da organizacao; regras no nivel da organizacao
- prova minima desta execucao: na tela Regras do painel, Copiar coloca o endereco publico daquele espaco na area de transferencia; abrir esse endereco sem login mostra a marca do espaco e as regras na ordem cadastrada; espaco sem regras abre a pagina vazia; o Link do evento mostra um botao que abre a mesma pagina; pedido de outro espaco nao mistura regras
- criterio de escalada: a faixa permanece `C`; voltar para `B` somente se a leitura publica das regras ja existir e a mudanca for so a pagina e o botao
- nivel de autonomia: `L2`
- camadas transversais: `design`, `security`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `node`, `patterns`, `react`, `design`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-05`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
- caminhos candidatos: cadastro de regras do venue; casca publica das listas; Link do evento e a tela de copiar o endereco; listagem autenticada de regras
- palavras-chave ou simbolos de busca: `VenueRule`, `VIEW_VENUE_RULES`, `PublicVenueListShell`, `eventLinkDestinations`, `ProposalEventLinkShare`
- testes provaveis: copiar o endereco na tela Regras; abrir a pagina sem sessao; conferir ordem, titulo opcional e estado vazio; abrir o botao no Link do evento; pedir regras de outro espaco e ver a recusa
- nao ler por padrao: `database`, `topics/`, pagamento, contrato e envio de mensagem

## Contexto informado na entrada

Pedido em chat. A equipe quer mais um link publico do espaco, o link sobre as regras do espaco. O cadastro ja existe no painel e a listagem exige login. A pagina publica segue a marca do espaco. O Link do evento passa a ter um botao para essa pagina.

## Problema atual

As regras ficam so na tela autenticada do venue. Quem recebe o material do espaco nao tem um endereco para le-las, e o Link do evento nao aponta para elas.

## Objetivo da mudanca

A equipe copia, na tela de regras, um endereco publico daquele espaco que mostra as regras cadastradas, e o Link do evento abre a mesma pagina.

## Escopo inicial percebido

Uma leitura publica, so de titulo, texto e ordem, alimenta uma pagina na casca das listas publicas. A tela Regras do painel mostra o endereco e o botao Copiar. O Link do evento ganha um sexto botao. A rota autenticada do cadastro permanece.

## Itens incluidos neste request

- leitura publica das regras de um venue, sem login
- a resposta publica traz titulo, texto e ordem, nada alem disso
- pagina publica na casca das listas: cor primaria no fundo, secundaria nos cards e no rodape, cor do texto na fonte, Manrope, logo e descricao no topo, aba com nome e descricao do espaco, skeleton na marca do espaco, entrada animada e o mesmo rodape
- a lista segue a ordem ja cadastrada; titulo ausente nao esconde o texto
- na tela Regras do painel, o endereco e o botao Copiar, para quem ja pode ver as regras
- botao no Link do evento que abre as regras daquele espaco

## Requisitos implicitos ja visiveis

- a regra continua pertencendo a um venue
- a rota publica e intencional e distinta da tela autenticada `/venue/:id/rules`
- a pagina nao grava nada
- a permissao da tela de copiar nao substitui a autorizacao das rotas de criar, alterar e remover
- sem logo, sem descricao ou sem rede do espaco, topo, aba e rodape degradam como nas listas publicas
- ao sair da pagina, a aba volta ao titulo EventHub

## Casos de erro e borda ja percebidos

- espaco sem regras: a pagina abre na marca do espaco e diz que ainda nao ha regras
- regra sem titulo: o texto aparece mesmo assim
- espaco inexistente: a pagina nao mostra regras de outro espaco
- espaco sem alguma cor, sem logo ou sem descricao: a pagina usa o mesmo fallback das listas publicas
- espaco ainda carregando: a tela nao mostra a marca EventHub nem cores de outro espaco
- pessoa sem permissao de ver regras: nao copia o endereco na tela do painel

## Dependencias

- o cadastro de regras do venue ja existe, com titulo opcional, texto e posicao
- a tela Regras ja fica no menu do venue
- as listas publicas ja aplicam a marca do espaco
- o Link do evento ja lista os destinos publicos daquele orcamento e ja conhece o espaco

## Restricoes e cuidados

- nao mudar o que o cadastro grava nem as permissoes de criar, alterar e remover
- nao colocar regras em orcamento, contrato, e-mail ou site da organizacao
- nao criar regras no nivel da organizacao
- nao criar coluna nova
- nao ler nem versionar valores de `.env`
- a leitura publica nao devolve regra de outro venue

## Perguntas em aberto

- Onde fica o botao Copiar? Premissa: na tela Regras do painel.
- Quem copia o endereco? Premissa: quem ja pode ver as regras daquele espaco.
- O Link do evento ganha o botao? Premissa: sim, um botao Regras do espaco, sempre visivel.
- Qual o endereco? Premissa: uma rota publica propria do venue, diferente de `/venue/:id/rules`.
- Espaco sem regras mostra a pagina? Premissa: sim, com a frase de que ainda nao ha regras.
- A ordem publicada e a do cadastro? Premissa: sim, pela posicao ja gravada.

## Prioridade sugerida

Media. O cadastro ja existe; falta o endereco para quem esta fora do painel.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: a leitura das regras e autenticada hoje. O pedido abre essa leitura ao publico, toca `backend` e `frontend` e se quebra em contrato, pagina, copia no painel e botao no Link do evento.

## Sugestao de slug da spec

- `framework_core/specs/link-publico-regras-do-espaco/`

## Sugestao de nome do arquivo

- `link-publico-regras-do-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-link-publico-regras-do-espaco/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
