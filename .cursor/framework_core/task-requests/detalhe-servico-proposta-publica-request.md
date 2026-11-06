# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abrir foto e descricao do servico por um icone na proposta publica

## Resumo da solicitacao

Na lista "Sua experiência inclui" da proposta publica, foto e descricao deixam de aparecer na linha. Se o servico tiver descricao ou foto, um icone de interrogacao ao lado do titulo abre um modal com o que existir.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao. A pagina ja e publica e ja lista os servicos; este request nao muda o que e enviado nem cria upload
- risco principal: o texto "Obrigatorio a partir de N pessoas" sumir junto com a descricao, ou o icone aparecer em servico que nao tem foto nem descricao
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: formulario publico de orcamento, dialogo "Adicionar servico", card "Seu investimento", cadastro do servico, schema e API
- prova minima desta execucao: em `/proposal/:id/view`, na lista "Sua experiência inclui", servico com foto ou descricao nao mostra imagem nem texto na linha e mostra `?` ao lado do titulo; o clique abre um modal com a foto e a descricao que existirem; servico sem os dois nao mostra o icone; "Obrigatorio a partir de N pessoas" continua na linha
- criterio de escalada: promover para `normal` e dividir com `tasking/task-request-repo-split-prompt.md` se a lista da proposta publica nao trouxer descricao e foto; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` na lista `Sua experiência inclui`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: pagina publica `/proposal/:id/view`, secao "Sua experiência inclui"
- palavras-chave ou simbolos de busca: `Sua experiência inclui`, `imageUrl`, `ProposalView`
- testes provaveis: linha sem imagem e sem descricao; icone so com descricao ou foto; modal com um dos dois e com os dois; texto de obrigatoriedade permanece; servico sem os dois sem icone
- nao ler por padrao: `security`, `database`, `topics/`, backend, schema e o formulario publico

## Contexto informado na entrada

Pedido em chat, com a proposta publica do espaco AR756 na secao "Sua experiência inclui". Limpeza, Recepcionista e Seguranca aparecem so com o nome e a obrigatoriedade. Painel de Led mostra a miniatura e a descricao longa na propria linha. A pessoa nao quer ver imagem nem descricao ali. Um `?` ao lado do titulo abre um modal com a foto e a descricao.

## Problema atual

Servico que tem foto troca o icone da linha pela miniatura e, quando tem descricao, o texto longo fica embaixo do nome. A lista fica desigual e a descricao ocupa a secao.

## Objetivo da mudanca

Na lista "Sua experiência inclui", nenhum servico mostra foto ou descricao na linha, e um `?` ao lado do titulo abre a foto e a descricao quando pelo menos uma das duas existir.

## Escopo inicial percebido

Ajuste visual da lista de servicos ja inclusos na proposta publica. Sem campo novo, sem contrato e sem schema. O texto de obrigatoriedade permanece na linha.

## Itens incluidos neste request

- nenhuma foto e nenhuma descricao na linha da lista "Sua experiência inclui"
- icone `?` ao lado do titulo quando o servico tiver descricao ou foto
- clique no icone abre um modal com a foto e a descricao que existirem
- servico sem descricao e sem foto fica sem o icone
- o icone de confirmacao da linha permanece em todos os servicos

## Requisitos implicitos ja visiveis

- "Obrigatorio a partir de N pessoas" continua visivel na linha
- o modal mostra so o que o servico tiver: foto, descricao ou as duas
- o clique no `?` nao altera a selecao do servico
- o valor do servico continua em "Seu investimento"
- logo, cores, visita, fotos da casa e o botao "Adicionar servico" nao mudam de papel

## Casos de erro e borda ja percebidos

- servico sem descricao e sem foto: nao ha icone nem modal
- servico so com descricao, ou so com foto: o icone aparece e o modal mostra apenas o que existe
- fechar o modal: a lista permanece como estava
- servico obrigatorio: o texto de obrigatoriedade continua na linha; o `?`, se houver, ainda abre o modal

## Dependencias

- a proposta publica ja lista os servicos em "Sua experiência inclui"
- descricao e foto ja fazem parte do cadastro do servico e ja aparecem nessa lista
- o formulario publico tem pedido separado e nao entra aqui: `task-requests/preco-e-detalhe-servico-orcamento-request.md`

## Restricoes e cuidados

- nao alterar o dialogo "Adicionar servico"
- nao alterar o formulario publico de orcamento
- nao esconder o preco em "Seu investimento"
- nao criar campo, upload nem migration
- nao fazer o clique no `?` alterar quais servicos estao no orcamento

## Perguntas em aberto

- O dialogo "Adicionar servico" tambem ganha o `?`? Premissa: nao; so a lista "Sua experiência inclui".
- O formulario publico segue a mesma regra neste request? Premissa: nao; ele ja tem request proprio.
- O icone e um `?` simples ao lado do titulo? Premissa: sim, sem texto extra do tipo "saiba mais".
- Servico sem foto mostra o modal so com a descricao? Premissa: sim; o mesmo vale para servico sem descricao e com foto.
- O check da linha some quando existe o `?`? Premissa: nao; o check fica e o `?` fica ao lado do titulo.

## Prioridade sugerida

Media. A proposta publica funciona; a foto e a descricao ocupam a lista em vez de abrir sob demanda.

## Faixa sugerida para task workflow

- `A` — um ajuste visual na lista da proposta publica, um repo, sem contrato nem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: esconde foto e descricao que a lista ja mostra e abre o detalhe num modal; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `detalhe-servico-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega` (`fw:review`)
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
