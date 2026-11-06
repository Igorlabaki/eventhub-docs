# Solicitacao da Tarefa

## Nome sugerido da tarefa

Usar no link publico o mesmo modal de servico da criacao do orcamento

## Resumo da solicitacao

O modal de foto e descricao do servico na pagina publica do link de orcamento passa a ser o mesmo container do modal da criacao publica do orcamento. O da criacao e o modelo e nao muda.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao. As duas paginas ja sao publicas e ja abrem foto e descricao do servico; este request nao muda o que e enviado nem cria upload
- risco principal: o modal do link perder a foto, a descricao ou o texto de obrigatoriedade da linha ao trocar o container, ou o modal da criacao ser alterado junto
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: modal da criacao publica (ele e o modelo), formulario autenticado do painel, dialogo "Adicionar servico", lista "Sua experiência inclui", card "Seu investimento", cadastro do servico, schema e API
- prova minima desta execucao: em `/proposal/:id/view`, o clique no icone de um servico com foto ou descricao abre o mesmo container do modal da criacao publica (cor do card do espaco, foto na largura do modal, descricao abaixo); o modal da criacao permanece como esta
- criterio de escalada: promover para `normal` se o link e a criacao nao puderem compartilhar o container sem mudar o da criacao; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: o modal de servico em `eventhub-vista-dashboard/src/pages/ProposalView.tsx` e o container em `eventhub-vista-dashboard/src/components/proposal/forms/PublicServiceDetail.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: pagina publica `/proposal/:id/view`, secao "Sua experiência inclui"; formularios publicos de criar orcamento que ja usam `PublicServiceDetail`
- palavras-chave ou simbolos de busca: `serviceDetail`, `PublicServiceDetail`, `Sua experiência inclui`
- testes provaveis: modal do link com foto e descricao no container da criacao; so foto; so descricao; fechar o modal sem mudar a lista; modal da criacao inalterado
- nao ler por padrao: `security`, `database`, `topics/`, backend, schema e o painel autenticado

## Contexto informado na entrada

Pedido em chat, com o print do modal "Painel de Led" aberto na pagina publica do link de orcamento. A pessoa quer esse modal igual ao da criacao do orcamento: o mesmo container, e o da criacao como modelo a seguir.

## Problema atual

O link publico e a criacao publica do orcamento abrem o detalhe do servico em containers diferentes. No link, o dialogo fica no fundo padrao e a foto aparece com faixas nas laterais. Na criacao, o container segue a cor do card do espaco, a foto ocupa a largura do modal e a descricao fica abaixo.

## Objetivo da mudanca

Na pagina publica do link, o modal de foto e descricao do servico usa o mesmo container do modal da criacao publica do orcamento, e o da criacao permanece o modelo.

## Escopo inicial percebido

Ajuste visual do modal ja aberto pelo icone na lista "Sua experiência inclui". Sem campo novo, sem contrato e sem schema. A lista, o icone e o modal da criacao ficam como estao.

## Itens incluidos neste request

- o modal do link publico usa o mesmo container do modal da criacao publica
- a criacao publica continua sendo o modelo e o container dela nao muda
- foto e descricao que o servico tiver continuam dentro desse container
- o icone da lista "Sua experiência inclui" continua sendo o que abre o modal

## Requisitos implicitos ja visiveis

- "Obrigatorio a partir de N pessoas" continua visivel na linha, fora do modal
- o modal mostra so o que o servico tiver: foto, descricao ou as duas
- o clique no icone nao altera a selecao do servico
- o valor do servico continua em "Seu investimento"
- logo, cores da pagina, visita, fotos da casa e o botao "Adicionar servico" nao mudam de papel

## Casos de erro e borda ja percebidos

- servico sem descricao e sem foto: continua sem icone e sem modal
- servico so com descricao, ou so com foto: o icone abre o mesmo container e mostra apenas o que existe
- fechar o modal: a lista permanece como estava
- descricao longa: o container da criacao ja limita a altura e rola; o do link deve fazer o mesmo

## Dependencias

- a lista "Sua experiência inclui" ja abre foto e descricao por um icone: `task-requests/detalhe-servico-proposta-publica-request.md`
- a criacao publica ja tem o container modelo em `PublicServiceDetail`, usado pelos formularios publicos de orcamento

## Restricoes e cuidados

- nao alterar o container, o gatilho nem o conteudo do modal da criacao
- nao alterar a lista "Sua experiência inclui" alem do container que o icone abre
- nao alterar o dialogo "Adicionar servico" nem o card "Seu investimento"
- nao criar campo, upload nem migration
- nao fazer o clique no icone alterar quais servicos estao no orcamento

## Perguntas em aberto

- O icone da lista do link vira o botao `?` da criacao? Premissa: nao; so o container do modal muda.
- A criacao autenticada no painel tambem entra? Premissa: nao; o modelo e o modal da criacao publica, que ja abre foto e descricao.
- O modal da criacao pode ser ajustado para os dois ficarem iguais? Premissa: nao; ele e o modelo e permanece.
- Servico so com foto ou so com descricao deixa de abrir? Premissa: nao; o mesmo container mostra apenas o que existir.

## Prioridade sugerida

Media. O link ja abre o detalhe; o container diverge do da criacao.

## Faixa sugerida para task workflow

- `A` — um ajuste visual do modal do link, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: troca o container de um modal que o link ja abre pelo container que a criacao publica ja usa; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `modal-servico-link-igual-criacao-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega` (`fw:review`)
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
