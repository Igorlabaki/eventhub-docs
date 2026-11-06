# Solicitacao da Tarefa

## Nome sugerido da tarefa

Levar a descricao ao fim da proposta e abrir o mapa do espaco

## Resumo da solicitacao

Na pagina publica do orcamento, a descricao da casa fica por ultimo na apresentacao, os icones nao repetem o nome do espaco e o local abre o Google Maps.

## Context Pack

- frente principal: frontend
- superficie sensivel: sim — o pacote publico da casa passa a levar rua e numero so para montar o link do mapa
- risco principal: imprimir o endereco completo na pagina ou repetir o nome do espaco ao lado dos icones
- repos tocados: `frontend` (`eventhub-vista-dashboard/`) e `backend` (`art56_server_v3/`)
- fora de escopo operacional: card de valor, cores, fotos, caracteristicas, servicos, WhatsApp, schema e o texto do endereco visivel
- prova minima desta execucao: na pagina publica, a descricao aparece depois da casa e antes do valor; a capa nao escreve o nome ao lado dos icones; o pino abre o Google Maps do espaco; rua e numero nao aparecem como texto
- criterio de escalada: promover para `spec` se o endereco precisar ser exibido ou se o mapa exigir coordenada que o venue nao tem
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no bloco da capa
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/specs/2026-11-04-apresentacao-publica-orcamento/02-clarify.md#Premissas assumidas`
- caminhos candidatos: `proposalFooter.tsx` na frase das redes; `to-proposal-presentation.ts` e o tipo `ProposalPresentation`
- palavras-chave ou simbolos de busca: `house.description`, `Siga a`, `neighborhood`, `street`, `streetNumber`
- testes provaveis: abrir a pagina publica e o link do mapa; conferir que o JSON publico nao e impresso como endereco
- nao ler por padrao: `database`, `topics/`, schema e painel administrativo

## Contexto informado na entrada

Pedido em chat, com a capa da proposta aberta: a descricao do espaco tem que ficar por ultimo; os icones abaixo nao devem ter o nome do espaco escrito; o local deve abrir o Google Maps.

## Problema atual

A descricao fica na capa, entre o bairro e os icones. O titulo repete o nome que o logo ja mostra, e o rodape escreve "Siga a {nome}". O pino de local nao abre mapa. O pacote publico so traz cidade e bairro.

## Objetivo da mudanca

A descricao fica no fim da apresentacao da casa, os icones nao trazem o nome do espaco e o local abre o Google Maps desse espaco.

## Escopo inicial percebido

Ajuste da pagina publica que ja existe. O link do mapa precisa de rua e numero no pacote publico, sem mostra-los na tela.

## Itens incluidos neste request

- mover a descricao para depois da galeria, das caracteristicas e dos servicos, antes do card de valor
- tirar o titulo em texto com o nome do espaco na capa
- tirar o nome do espaco da frase dos icones do rodape
- tornar o pino e a linha de bairro e cidade um link para o Google Maps
- incluir no pacote publico rua, numero e estado apenas para montar esse link

## Requisitos implicitos ja visiveis

- o card de valor continua por ultimo
- o logo continua sendo a marca da capa
- os icones de site e redes continuam so icone
- CEP nao entra no texto nem no link

## Casos de erro e borda ja percebidos

- descricao vazia: a secao nao aparece
- espaco sem rua ou numero: o link usa o que existir (bairro e cidade) e a linha de local continua visivel
- logo ausente: o fallback EventHub permanece; o nome em texto nao volta no lugar do logo
- o endereco completo nao pode aparecer como texto na pagina

## Dependencias

- a pagina publica e o pacote `GET /proposal/presentation/:proposalId` ja existem
- o venue ja guarda rua, numero, bairro, cidade e estado

## Restricoes e cuidados

- nao exibir rua, numero ou CEP na pagina
- nao mudar cores, fotos, caracteristicas, servicos nem o card de valor
- nao criar coluna nem permissao
- o pacote publico continua sem dono, contrato, pagamento e preco de catalogo

## Perguntas em aberto

- "Por ultimo" inclui o card de valor? Premissa: nao; a descricao fecha a apresentacao da casa e o valor continua depois.
- O nome some do titulo e do rodape? Premissa: sim; o logo permanece e os icones ficam sem o nome do espaco.
- O mapa mostra o endereco na tela? Premissa: nao; rua, numero e estado so entram na URL do Google Maps.

## Prioridade sugerida

Alta. A pagina publica ja esta em uso e a descricao esta no lugar errado da capa.

## Faixa sugerida para task workflow

- `B` — uma pagina, com um acrescimo pequeno no pacote publico
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: ajusta a pagina da spec `apresentacao-publica-orcamento`; nao abre jornada nem migration

## Sugestao de slug da spec

- nao se aplica; permanece em `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `descricao-e-mapa-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `opcional`
