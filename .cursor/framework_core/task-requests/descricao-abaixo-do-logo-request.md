# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mostrar a descricao do espaco abaixo do logo na proposta publica

## Resumo da solicitacao

Na pagina publica do orcamento e no formulario publico de gerar orcamento, a descricao do espaco aparece logo abaixo do logo.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: repetir a mesma descricao no topo e no rodape, ou sumir o bloco quando a descricao estiver vazia
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: texto da descricao, rodape de redes, mapa, card da proposta, cores e schema
- prova minima desta execucao: no link do orcamento, a descricao fica entre o logo e o video; no formulario publico, a descricao fica entre o logo e o formulario; descricao vazia nao deixa bloco; o rodape nao repete o texto
- criterio de escalada: promover para `spec` se a descricao precisar de editor, traducao ou campo novo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no header do logo e `eventhub-vista-dashboard/src/pages/ProposalForm.tsx` no bloco do logo
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/design/rules/03_layout_grid_and_hierarchy.md`
- caminhos candidatos: `ProposalView.tsx` no rodape e no skeleton
- palavras-chave ou simbolos de busca: `house.description`, `logoUrl`, `ProposalTourVideo`
- testes provaveis: abrir `/proposal/:id/view` e conferir o texto entre o logo e o video
- nao ler por padrao: `security`, `database`, `topics/`

## Contexto informado na entrada

Pedido em chat, com a capa da proposta AR756 aberta: embaixo do logo tem que ter a descricao do espaco. Em seguida, o mesmo vale para a pagina publica de gerar orcamento.

## Problema atual

O logo fica no topo e a midia ou o formulario entram em seguida. A descricao do espaco so aparece no rodape, longe da marca, nas duas paginas publicas.

## Objetivo da mudanca

Quem abre o link do orcamento ou o formulario publico ve a descricao do espaco logo abaixo do logo.

## Escopo inicial percebido

Ajuste de posicao na pagina publica que ja existe. A descricao ja vem no pacote da apresentacao.

## Itens incluidos neste request

- renderizar a descricao centralizada abaixo do logo na proposta publica, acima do video ou da capa
- renderizar a mesma descricao abaixo do logo no formulario publico `/venue/:id/form`, acima do formulario
- tirar a copia da descricao do rodape das duas paginas
- reservar o mesmo lugar no skeleton quando a descricao ja for conhecida

## Requisitos implicitos ja visiveis

- descricao vazia nao cria bloco
- o logo e o video continuam na mesma ordem
- quebras de linha do texto longo sao preservadas
- a cor do texto segue a cor da pagina

## Casos de erro e borda ja percebidos

- espaco sem descricao: nada aparece entre o logo e a midia
- espaco sem logo: a descricao fica abaixo do fallback EventHub
- descricao longa: o texto quebra dentro da coluna da proposta

## Dependencias

- a pagina publica e o campo `description` do pacote de apresentacao ja existem

## Restricoes e cuidados

- nao alterar o cadastro da descricao
- nao mudar cores, video, fotos nem o card da proposta

## Perguntas em aberto

- a descricao deve sair do rodape? Premissa: sim, para nao repetir o mesmo texto.

## Prioridade sugerida

alta — o cliente ve a capa sem a descricao do espaco

## Faixa sugerida para task workflow

- `A`

## Candidato a spec

- `nao`
- motivo: ajuste isolado de posicao em um componente existente

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `descricao-abaixo-do-logo-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
