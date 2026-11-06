# Solicitacao da Tarefa

## Nome sugerido da tarefa

Trocar a foto do link de orcamento por qualquer foto do espaco

## Resumo da solicitacao

No link publico do orcamento, o dono logado clica numa foto e troca por qualquer foto daquele espaco. Uma marca nova em cada foto do espaco diz se ela entra nesse link. O site da organizacao continua com a marca que ja tem.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — a pagina `/proposal/:id/view` e publica; a troca so pode ser gravada pelo dono autenticado daquele espaco, e a resposta publica nao pode listar as fotos de fora do link
- risco principal: o visitante do link trocar ou ver uma foto que nao foi marcada para o orcamento, ou a marca nova alterar o que o site da organizacao ja mostra
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: arraste que reordena as fotos ja visiveis; carrossel ao ampliar; escolha de fotos do site da organizacao; upload de foto nova pelo link; conjunto de fotos diferente por orcamento
- prova minima desta execucao: dono logado abre `/proposal/:id/view`, troca uma foto por outra do mesmo espaco que nao estava no link, recarrega e ve a nova no lugar e a anterior fora; visitante sem essa sessao nao ve o seletor nem a foto de fora; foto marcada so para o site da organizacao nao entra no link
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a reusar a marca do site, sem coluna nova e sem gravar a troca a partir da pagina publica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `security`, `architecture`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/database/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: pagina publica da proposta; fotos do venue e a marca de exibicao no site da organizacao; gravacao da ordem das fotos visiveis no link
- palavras-chave ou simbolos de busca: `ProposalView`, `isShowOnOrganization`, `canReorder`, `Image`
- testes provaveis: dono troca e recarrega; visitante nao troca e nao recebe a lista completa; foto so do site fica de fora do link; falha ao gravar devolve a foto anterior
- nao ler por padrao: `topics/`; a spec de reordenar fotos alem do que precisar para saber que o arraste ja grava a ordem do espaco

## Contexto informado na entrada

Pedido em chat, com as fotos do link publico ja arrastaveis. O dono quer clicar numa foto e troca-la por qualquer foto que o espaco tenha. Sugestao da mesma conversa: cada foto do espaco ganha uma coluna que diz se ela aparece no link de orcamento.

## Problema atual

O arraste so muda a ordem das fotos que o link ja mostra. Essas fotos sao as marcadas para o site da organizacao. Uma foto do espaco que nao tem essa marca nao entra no link, e nao ha como coloca-la no lugar de outra a partir da pagina publica.

## Objetivo da mudanca

O dono logado troca, no link do orcamento, uma foto visivel por qualquer foto daquele espaco, e a marca de entrar no link fica gravada na foto.

## Escopo inicial percebido

Coluna nova na foto do espaco, filtro do link publico por essa coluna e um controle de troca na pagina publica, gravado so para o dono daquele espaco. Toca `frontend` e `backend`, com migration aditiva.

## Itens incluidos neste request

- marca em cada foto do espaco para aparecer ou nao no link de orcamento
- o link publico passa a usar essa marca
- o dono logado clica numa foto do link e escolhe qualquer foto daquele espaco no lugar
- a troca fica gravada e aparece na proxima abertura, para o dono e para o visitante
- quem nao e o dono logado daquele espaco nao troca e nao ve as fotos de fora do link

## Requisitos implicitos ja visiveis

- a pagina continua publica, no mesmo link que o cliente ja recebe
- a marca do site da organizacao permanece; esta entrega nao a reaproveita como filtro do orcamento
- a escolha vale para o espaco, e portanto para os links de orcamento daquela casa
- a migration de producao e aditiva
- fotos que hoje aparecem no link continuam aparecendo ate alguem troca-las
- o arraste das fotos que ja estao no link permanece
- ampliar a foto no carrossel permanece
- a gravacao da troca passa pelo backend; a tela nao substitui essa autorizacao
- a resposta publica continua sem a lista das fotos de fora do link
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Casos de erro e borda ja percebidos

- visitante ou dono de outro espaco: as fotos ficam fixas e a lista completa nao aparece
- foto escolhida ja esta no link: as duas trocam de lugar
- foto escolhida esta fora do link: ela entra no lugar e a anterior sai
- espaco com uma unica foto: nao ha outra para escolher
- nenhuma foto marcada para o link: a capa e a galeria seguem o comportamento de hoje, sem foto
- falha ao gravar: a foto anterior volta
- marcar ou desmarcar para o site da organizacao nao muda, por si so, o que o link de orcamento mostra

## Dependencias

- fotos do venue e a marca de aparecer no site da organizacao ja existem
- o link publico ja mostra essas fotos e o dono logado ja pode reordena-las arrastando
- a coluna de aparecer no link de orcamento ainda nao existe; a gravacao pede migration aditiva

## Restricoes e cuidados

- nao alterar o conjunto de fotos do site da organizacao
- nao remover o arraste nem o carrossel
- nao criar um conjunto de fotos por orcamento
- nao aceitar upload de foto nova a partir do link publico
- nao ler nem versionar valores de `.env`
- a rota publica continua intencional; o que ela devolve precisa ser o recorte marcado para o orcamento

## Perguntas em aberto

- A marca nova substitui a do site no link? Premissa: sim; o site continua com a marca atual e o link passa a ler so a marca nova.
- Fotos que hoje estao no link entram ja marcadas? Premissa: sim, para os links atuais nao ficarem sem foto.
- A troca vale para todos os orcamentos da casa? Premissa: sim; a marca fica na foto do espaco.
- O clique que amplia a foto vira o seletor? Premissa: nao; a troca e um controle a parte e o carrossel permanece.
- O arraste sai? Premissa: nao; ele continua reordenando as fotos que ja estao no link.

## Prioridade sugerida

Media. Completa a peca que o cliente recebe, sem corrigir um calculo quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria uma marca nova na foto do espaco, muda o recorte da pagina publica e grava a troca a partir desse link, com autorizacao do dono. Toca `frontend` e `backend` e pede migration aditiva. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/trocar-foto-proposta-publica/`

## Sugestao de nome do arquivo

- `trocar-foto-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-04-trocar-foto-proposta-publica/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
