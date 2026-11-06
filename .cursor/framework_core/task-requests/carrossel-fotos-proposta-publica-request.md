# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abrir carrossel infinito nas fotos da proposta publica

## Resumo da solicitacao

Na pagina publica do orcamento, cada foto da secao "A casa" abre um carrossel que percorre as fotos da galeria sem parar na ultima.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — as fotos ja aparecem na pagina publica; o carrossel nao expoe dado novo
- risco principal: o carrossel abrir na foto errada ou parar na ultima em vez de voltar a primeira
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: foto de capa, grade de duas colunas, card de valor, cores, caracteristicas, servicos, mapa e pacote publico
- prova minima desta execucao: na pagina publica, clicar uma foto da galeria abre essa foto; avancar depois da ultima volta a primeira; fechar devolve a pagina
- criterio de escalada: promover para `spec` se o carrossel precisar de foto que a pagina ainda nao recebe, ou de upload e permissao novos
- nivel de autonomia: `L2`
- camadas: `design`; `security`, `database`, `observability` e `patterns` nao se aplicam

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx#A casa`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/ui/carousel.tsx`; `eventhub-vista-dashboard/src/components/ui/dialog.tsx`
- palavras-chave ou simbolos de busca: `gallery`, `A casa`, `col-span-2`
- testes provaveis: abrir a pagina publica, clicar uma foto do meio e a ultima, avancar alem da ultima e fechar
- nao ler por padrao: `security`, `database`, `topics/`, backend e painel administrativo

## Contexto informado na entrada

Pedido em chat, com a galeria "A casa" aberta: as fotos devem ser clicaveis e abrir um carrossel infinito com essas fotos. A ultima foto de quantidade impar ja ocupa as duas colunas.

## Problema atual

As fotos da galeria so aparecem na grade. Nao da para amplia-las nem percorrer a sequencia a partir da foto escolhida.

## Objetivo da mudanca

Clicar uma foto de "A casa" abre um carrossel nessa foto, e o percurso continua da ultima de volta para a primeira.

## Escopo inicial percebido

Interacao na galeria da pagina publica que ja existe. As fotos ja estao na pagina; nao ha contrato novo.

## Itens incluidos neste request

- tornar clicavel cada foto da secao "A casa"
- abrir um carrossel na foto clicada
- percorrer a galeria em ciclo, da ultima de volta a primeira
- fechar o carrossel e voltar a pagina

## Requisitos implicitos ja visiveis

- a grade de duas colunas permanece, inclusive a ultima foto larga quando a quantidade e impar
- a foto de capa, acima de "Seu evento", fica de fora do carrossel
- a pagina continua publica e sem dado alem do que ja mostra

## Casos de erro e borda ja percebidos

- uma unica foto: o clique abre essa foto; o ciclo nao tem para onde ir
- galeria vazia: a secao continua oculta e nao ha carrossel
- foto sem descricao: o carrossel usa o nome do espaco como texto alternativo, como a grade ja faz
- fechar no meio do percurso devolve a pagina na galeria, sem trocar a ordem das fotos

## Dependencias

- a pagina publica e a galeria de "A casa" ja existem
- o frontend ja tem carrossel e dialogo reutilizaveis

## Restricoes e cuidados

- nao incluir a foto de capa
- nao mudar a grade, as cores, o valor nem o pacote publico
- nao criar coluna, upload nem permissao
- o carrossel so usa as fotos que a galeria ja mostra

## Perguntas em aberto

- A capa entra no carrossel? Premissa: nao; so as fotos de "A casa".
- Uma unica foto ainda abre? Premissa: sim; o ciclo so aparece quando ha mais de uma.
- A foto que ocupa as duas colunas tambem abre? Premissa: sim; ela e uma foto da galeria como as outras.

## Prioridade sugerida

Media. A pagina publica ja esta em uso e a galeria ainda nao amplia as fotos.

## Faixa sugerida para task workflow

- `B` — uma interacao na pagina publica, com ciclo e foto inicial
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: amplia a galeria da pagina que a spec `apresentacao-publica-orcamento` ja entrega; nao abre jornada, contrato nem migration

## Sugestao de slug da spec

- nao se aplica; permanece em `framework_core/specs/2026-11-04-apresentacao-publica-orcamento/`

## Sugestao de nome do arquivo

- `carrossel-fotos-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-04; review de entrega ainda nao rodou
- derivacao repo-local: `nao se aplica`
