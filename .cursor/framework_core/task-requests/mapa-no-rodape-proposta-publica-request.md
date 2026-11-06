# Solicitacao da Tarefa

## Nome sugerido da tarefa

Trocar as redes do rodape pelo mapa do espaco

## Resumo da solicitacao

No rodape da pagina publica do orcamento, o bloco de redes sociais sai. No lugar entra o mapa do Google com a localizacao do espaco.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o mapa pedir chave ou segredo novo, ou as redes sumirem de outra tela que nao e este rodape
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: capa, logo, descricao, cores, linha de bairro e cidade, card de valor, schema, API e o rodape das telas que nao sao a pagina publica do orcamento
- prova minima desta execucao: em `/proposal/:id/view`, o rodape nao mostra site, Instagram, Facebook nem TikTok e mostra um mapa do Google no lugar desse bloco; a linha de bairro e cidade continua; uma tela interna que usa o rodape padrao permanece como esta
- criterio de escalada: promover para `normal` se o mapa exigir chave, coluna ou campo novo no pacote publico; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no fechamento da pagina, onde o rodape e montado
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/rodape-proposta-publica-request.md#Objetivo da mudanca`
  - `.cursor/framework_core/task-requests/descricao-e-mapa-proposta-publica-request.md#Objetivo da mudanca`
- caminhos candidatos: componente do rodape da proposta publica; bloco de icones de site e redes; link de mapa ja montado para o pino de local
- palavras-chave ou simbolos de busca: `ProposalFooter`, `Siga nas redes`, `instagram`, `google.com/maps`
- testes provaveis: abrir a pagina publica com redes preenchidas e ver o mapa no rodape sem esses icones; abrir uma tela interna com o rodape padrao
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com o rodape da pagina publica aberto: local "Vila Prudente — Sao Paulo" e, abaixo, os icones de site, Instagram, Facebook e TikTok. Com o rodape do espaco ja no ar, as redes nesse bloco deixam de fazer sentido. Elas saem dali e entra o mapa do Google com a localizacao do espaco.

## Problema atual

O rodape da proposta publica fecha com os icones das redes do espaco. A localizacao ja aparece como bairro e cidade, e o pedido anterior so abre o Google Maps por link. Falta o mapa no proprio rodape, e as redes ocupam o lugar onde ele deve ficar.

## Objetivo da mudanca

No rodape da pagina publica do orcamento, as redes sociais nao aparecem e o visitante ve o mapa do Google na localizacao do espaco.

## Escopo inicial percebido

Ajuste visual no rodape da pagina publica que ja existe. A localizacao usada pelo link do mapa ja faz parte dessa pagina.

## Itens incluidos neste request

- remover do rodape o bloco de site e redes sociais
- colocar no lugar o mapa do Google com a localizacao do espaco

## Requisitos implicitos ja visiveis

- a pagina continua publica, no mesmo link
- a linha de bairro e cidade permanece
- logo, descricao e cor do rodape permanecem
- o rodape das outras telas nao muda
- o mapa usa a localizacao que a pagina ja conhece, sem chave nem variavel nova

## Casos de erro e borda ja percebidos

- espaco sem rua ou numero: o mapa usa o que a pagina ja usa no link (bairro e cidade) e a linha de local continua visivel
- sem nenhuma rede hoje: o rodape ganha o mapa mesmo assim
- o mapa nao pode estourar a largura do rodape no celular
- rua, numero e CEP nao ganham uma linha nova de texto na pagina

## Dependencias

- o rodape proprio da pagina publica ja existe
- o pedido `descricao-e-mapa-proposta-publica-request.md` ja levou a localizacao do espaco para o link do Google Maps

## Restricoes e cuidados

- nao criar coluna, endpoint, permissao nem segredo
- nao introduzir chave de API do Google
- nao tirar redes de outra superficie alem deste rodape
- nao redesenhar capa, fotos, servicos, card de valor nem as cores do rodape

## Perguntas em aberto

- As redes saem so deste rodape? Premissa: sim; se a capa ainda tiver icones, eles ficam.
- O mapa fica incorporado na pagina? Premissa: sim, no lugar do bloco de redes; nao basta o link que ja abre o Google Maps.
- A linha "Vila Prudente — Sao Paulo" sai? Premissa: nao; ela permanece acima do mapa.
- O mapa escreve rua e numero na pagina? Premissa: nao; nao acrescentar linha de endereco alem do que o proprio mapa mostrar.
- Sem local utilizavel, o que aparece? Premissa: o rodape segue sem o bloco de redes e sem uma area vazia de mapa.

## Prioridade sugerida

Alta. A pagina publica ja esta em uso e o rodape ainda fecha com as redes.

## Faixa sugerida para task workflow

- `A` — um bloco de uma tela, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: troca um bloco do rodape da pagina que ja existe na spec `apresentacao-publica-orcamento`; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; permanece em `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `mapa-no-rodape-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
