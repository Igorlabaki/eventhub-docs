# Solicitacao da Tarefa

## Nome sugerido da tarefa

Icones clicaveis no preview do card do parceiro

## Resumo da solicitacao

No preview do cadastro de parceiro, cada rede preenchida vira um icone que abre a pagina correspondente, com a URL que a pessoa digitou.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o preview abrir um endereco diferente do que foi digitado, ou o clique sair do formulario sem ir para a rede
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: upload da logo, descricao, gravacao do contato, card publico das indicacoes, formulario do painel
- prova minima desta execucao: no cadastro publico, preencher Instagram, Facebook, TikTok, site, WhatsApp e e-mail e ver os icones no bloco Seu card; cada clique abre o destino daquela URL; campo vazio nao mostra icone
- criterio de escalada: promover para a spec `logo-descricao-card-parceiro` se a mudanca passar do componente do preview
- nivel de autonomia: `L2`
- camadas transversais: `design`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/specs/2026-11-05-logo-descricao-card-parceiro/02-clarify.md#Premissas assumidas`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/specs/2026-11-05-logo-descricao-card-parceiro/02-clarify.md#Premissas assumidas`
  - `.cursor/framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
- caminhos candidatos: componente do card do parceiro; montagem dos links de indicacao
- palavras-chave ou simbolos de busca: `PartnerPublicCard`, `indicationLinks`, `variant="preview"`
- testes provaveis: o preview com URL preenchida renderiza link; campo vazio nao renderiza icone; o href segue a URL digitada
- nao ler por padrao: `topics/`, upload, banco, `security`

## Contexto informado na entrada

Pedido em chat, olhando o preview do cadastro de parceiro. Os icones precisam estar no card e, ao clicar, abrir a pagina daquela rede usando a URL que a pessoa colocou.

## Problema atual

O bloco Seu card mostra os icones das redes preenchidas, mas o clique nao abre a pagina. A spec em andamento registrou que o preview nao navega.

## Objetivo da mudanca

Cada icone do preview abre o destino da URL digitada naquele campo.

## Escopo inicial percebido

A mudanca fica no preview do card, no cadastro publico. O card publico das indicacoes ja abre esses destinos.

## Itens incluidos neste request

- WhatsApp, e-mail, Instagram, Facebook, TikTok e site aparecem no preview quando o campo tem valor
- o clique usa a URL informada
- URL sem protocolo continua sendo completada como no card publico
- campo vazio nao ganha icone

## Requisitos implicitos ja visiveis

- o preview continua ao vivo, acima de Cadastrar
- a ordem do card nao muda: avatar, nome, descricao, redes
- link externo abre em nova aba
- e-mail abre o cliente de e-mail; WhatsApp abre a conversa do numero

## Casos de erro e borda ja percebidos

- campo vazio
- URL sem `https://`
- usuario do Instagram, Facebook ou TikTok sem o dominio
- numero de WhatsApp com mascara
- clique no preview nao pode apontar para um endereco inventado

## Dependencias

- o componente do card ja existe na spec `specs/2026-11-05-logo-descricao-card-parceiro/`
- esta pedido troca a premissa "o preview nao navega" dessa spec

## Restricoes e cuidados

- nao mudar o upload, a descricao nem quem aparece nas indicacoes
- nao mostrar icone para campo vazio
- atualizar a premissa da spec para o preview passar a navegar

## Perguntas em aberto

- Os seis icones aparecem mesmo com o campo vazio? Premissa: nao; so a rede preenchida.
- O clique pode sair do formulario? Premissa: sim, em nova aba, como no card publico.

## Prioridade sugerida

Alta para o cadastro que ja esta na tela. E um ajuste do preview, nao uma jornada nova.

## Faixa sugerida para task workflow

- `A` — um componente, um comportamento, so no frontend
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: corrige uma premissa da spec `logo-descricao-card-parceiro`; nao abre outra feature

## Sugestao de slug da spec

- nao se aplica; entra na spec `framework_core/specs/2026-11-05-logo-descricao-card-parceiro/`

## Sugestao de nome do arquivo

- `icones-clicaveis-preview-parceiro-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
