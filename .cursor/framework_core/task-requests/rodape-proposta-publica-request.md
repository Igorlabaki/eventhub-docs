# Solicitacao da Tarefa

## Nome sugerido da tarefa

Personalizar o rodape da pagina publica do orcamento

## Resumo da solicitacao

A pagina publica do orcamento deixa o rodape padrao do site. O rodape dessa pagina usa a cor secundaria do espaco, o logo e a descricao do espaco, e as redes sociais do espaco.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o rodape compartilhado das outras telas mudar junto, ou a marca EventHub continuar no lugar do espaco
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: gravacao das cores, schema, API, card de valor, mapa, fotos, caracteristicas, servicos e o rodape das telas que nao sao a pagina publica do orcamento
- prova minima desta execucao: abrir `/proposal/:id/view` de um espaco com cor secundaria, logo, descricao e ao menos uma rede e ver o rodape com fundo na secundaria, logo e descricao do espaco e o bloco "Siga nas redes sociais" apontando para o espaco; uma tela que usa o rodape padrao (agenda, equipe ou formulario) continua com a marca EventHub
- criterio de escalada: promover para `normal` se a troca exigir componente compartilhado com contrato novo; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no fechamento da pagina, onde o rodape e montado
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/frontend-map.md#Componentes e dados`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_core/task-requests/papeis-cores-proposta-request.md#Objetivo da mudanca`
- caminhos candidatos: rodape usado pela pagina publica; bloco de logo e descricao na capa; campos de cor, logo, descricao e redes ja consumidos pela apresentacao
- palavras-chave ou simbolos de busca: `ProposalFooter`, `proposalSecondaryColor`, `proposalTextColor`, `logoUrl`, `Siga nas redes sociais`
- testes provaveis: abrir a pagina publica com e sem logo, descricao, cor secundaria e redes; abrir uma tela interna que ainda usa o rodape padrao
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com a pagina publica do orcamento aberta no rodape roxo da marca EventHub: essa pagina nao deve usar o rodape padrao do site. O rodape do orcamento segue o padrao de cores do espaco, com fundo na cor secundaria. "Siga nas redes sociais" aponta para as redes do espaco. O logo do rodape e o do espaco, junto com a descricao do espaco.

## Problema atual

Quem abre o link publico do orcamento ve, no fim, o rodape do site: fundo indigo, marca EventHub e a frase "Seu hub para gestao de eventos". A identidade escolhida para o espaco para nesse bloco.

## Objetivo da mudanca

Na pagina publica do orcamento, o rodape mostra o espaco: fundo na cor secundaria, logo e descricao do espaco, e redes sociais do espaco.

## Escopo inicial percebido

Ajuste visual no fim da pagina publica que ja existe. As cores, o logo, a descricao e os links do espaco ja chegam nessa pagina.

## Itens incluidos neste request

- tirar o rodape padrao do site desta pagina
- fundo do rodape na cor secundaria do espaco
- demais cores do rodape no padrao escolhido para o espaco
- logo do espaco no rodape
- descricao do espaco junto do logo
- bloco "Siga nas redes sociais" com as redes do espaco

## Requisitos implicitos ja visiveis

- a pagina continua publica, no mesmo link
- a escolha de cores continua a que ja esta em Configuracoes do espaco
- o rodape padrao permanece nas outras telas que o usam
- link de rede so aparece quando o espaco tiver esse link

## Casos de erro e borda ja percebidos

- sem cor secundaria, o fundo do rodape nao pode sumir no fundo da pagina
- sem logo, a marca EventHub nao ocupa o lugar do espaco neste rodape
- sem descricao, a linha de descricao nao aparece
- sem nenhuma rede, o bloco "Siga nas redes sociais" nao aparece
- a descricao nao deve ficar escrita na capa e de novo no rodape

## Dependencias

- a pagina publica da apresentacao ja existe e ja recebe logo, descricao, cores e redes do espaco
- o papel das cores ja esta fechado: primaria no fundo da pagina, secundaria nos cards, cor do texto na fonte

## Restricoes e cuidados

- nao criar coluna, endpoint nem permissao
- nao pintar o painel, o site da organizacao nem o rodape das outras telas
- nao redesenhar capa, fotos, servicos, mapa nem card de valor alem de evitar a descricao repetida

## Perguntas em aberto

- Texto e icones do rodape usam a cor do texto do espaco? Premissa: sim; sem cor de texto, ficam brancos como no rodape atual.
- Sem cor secundaria, qual fundo? Premissa: o indigo atual do rodape padrao.
- A descricao sai da capa? Premissa: sim; o logo permanece na capa e a descricao fica so no rodape.
- WhatsApp entra em "Siga nas redes sociais"? Premissa: sim, quando o espaco tiver numero, junto de site, Instagram, Facebook e TikTok que existirem.

## Prioridade sugerida

Alta. A pagina publica ja apresenta o espaco e o rodape ainda fecha com a marca do site.

## Faixa sugerida para task workflow

- `A` — uma tela, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: ajusta o rodape de uma pagina que ja existe na spec `apresentacao-publica-orcamento`; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; permanece em `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `rodape-proposta-publica-request.md`

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
