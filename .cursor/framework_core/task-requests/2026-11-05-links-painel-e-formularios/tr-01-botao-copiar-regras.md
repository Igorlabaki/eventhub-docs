# Solicitacao da Tarefa

## Nome sugerido da tarefa

Copiar o link das regras com um botao

## Resumo da solicitacao

Na tela de Regras do espaco, sai o campo com o endereco e o botao Copiar ao lado. No lugar fica o botao largo que as outras telas do painel ja usam para copiar um link. O endereco copiado usa a base `https://event-hub-dashboard.vercel.app/`.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — a pagina publica das regras ja existe; este request nao muda quem a ve nem o que ela mostra
- risco principal: o botao copiar um endereco de localhost, ou a tela continuar mostrando o campo com o link
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: conteudo e rota da pagina publica das regras; item Link do evento; tela Indicar parceiros; formulario de criar ou editar regra
- prova minima desta execucao: em Regras, nao ha campo de texto com o endereco; um botao largo copia `https://event-hub-dashboard.vercel.app/venue/{id}/rules/view` e o toast confirma; o mesmo gesto com o painel aberto em localhost continua copiando essa base
- criterio de escalada: `normal` se o botao de copiar das outras telas nao puder ser reusado sem desenhar um componente novo; `spec` nao se aplica
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
- caminhos candidatos: tela Regras do espaco; botao largo de copiar em Orcamentos do espaco e em Contatos
- palavras-chave ou simbolos de busca: `VenueRules`, `Link das regras`, `event-hub-dashboard.vercel.app`, `rules/view`
- testes provaveis: o endereco montado para copiar usa a base de producao e o caminho publico das regras; a tela nao renderiza o campo somente leitura
- nao ler por padrao: `security`, `database`, `topics/`, schema e a spec da pagina publica alem do que o board ja registra

## Contexto informado na entrada

Pedido em chat, na tela Regras. O campo com o link e o botao ao lado nao servem. O painel ja tem, em outras paginas, um botao so para copiar. Os links oferecidos por este gesto precisam da base de producao `https://event-hub-dashboard.vercel.app/`.

## Problema atual

Regras mostra um campo somente leitura com o endereco e um botao Copiar ao lado. O endereco usa a origem da aba aberta, entao no ambiente local o texto copiado comeca com localhost.

## Objetivo da mudanca

Em Regras, um botao copia o link publico das regras ja com a base de producao, sem campo de endereco na tela.

## Escopo inicial percebido

A tela Regras troca o bloco do campo pelo botao largo ja usado para copiar link em outras telas do painel. O texto copiado aponta para a pagina publica das regras daquele espaco, na base de producao.

## Itens incluidos neste request

- remover de Regras o rotulo, o campo e o botao Copiar ao lado do campo
- colocar um botao que copia o link, no padrao visual do botao largo das outras telas
- o endereco copiado e `https://event-hub-dashboard.vercel.app/venue/{id}/rules/view`
- toast de sucesso quando a copia funciona e aviso quando a copia falha

## Requisitos implicitos ja visiveis

- vale para o espaco selecionado no painel
- a base de producao vale tambem quando o painel esta aberto em localhost
- a pagina publica das regras nao muda
- quem nao pode ver Regras continua sem ver a tela

## Casos de erro e borda ja percebidos

- espaco ainda sem id: o botao nao copia um endereco vazio nem um caminho sem o espaco
- a area de transferencia recusa a copia: a pessoa ve o aviso e a lista de regras continua na tela
- painel em localhost: o texto copiado nao contem localhost

## Dependencias

- a pagina publica das regras ja tem caminho `/venue/{id}/rules/view`
- Orcamentos e Contatos ja copiam link com a base `https://event-hub-dashboard.vercel.app/` por um botao largo

## Restricoes e cuidados

- nao criar rota nova
- nao alterar o que a pagina publica das regras mostra
- nao mexer em Link do evento nem em Indicar parceiros
- nao ler nem versionar valores de `.env`
- nao trocar a base por variavel de ambiente neste request; a base pedida e a mesma ja escrita nos outros botoes de copiar

## Perguntas em aberto

- Qual o rotulo do botao? Premissa: `Copiar link das regras`.
- O botao fica acima da lista, como o bloco atual? Premissa: sim, no topo da area de Regras.
- Indicar parceiros, que tambem tem campo e botao Copiar, entra neste ajuste? Premissa: nao.

## Prioridade sugerida

Alta. A tela ja esta em uso e o endereco copiado hoje nao serve para enviar ao cliente.

## Faixa sugerida para task workflow

- `A` — troca de um bloco de tela e do texto copiado, reusando o botao que ja existe
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um gesto de copiar numa tela que ja existe, sem contrato, dado ou pagina nova

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `tr-01-botao-copiar-regras.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-links-painel-e-formularios/`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
