# Solicitacao da Tarefa

## Nome sugerido da tarefa

Aba Redes sem o container de fundo e com o botao Cadastrar link no padrao

## Resumo da solicitacao

Na aba Redes de Configuracoes, o conteudo aparece com um container atras. Esse container sai, e o que fica segue o desenho que o projeto ja usa na faixa e na tabela de Contatos. O botao "Cadastrar link" da faixa passa a ser o botao do projeto, no mesmo lugar.

## Context Pack

- frente principal: frontend (`eventhub-vista-dashboard/`); aba Redes de Configuracoes
- superficie sensivel: nao (so visual do painel; sem endpoint, auth ou dado novo)
- camadas transversais: `design`
- risco principal: tirar o fundo ou trocar o botao nao pode desligar busca, filtro de visibilidade, cadastro, edicao de URL nem remocao
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: pagina publica `/espaco/:id/links`; KPIs, contador e colunas da tabela; modal de cadastro e de edicao de URL; schema, endpoint ou campo novo; reabrir `task-requests/visual-redes-e-link-tree-request.md`
- prova minima desta execucao: na aba Redes, as linhas nao tem bloco de fundo atras de nome, link e acoes; "Cadastrar link" na faixa usa o botao outline pill da faixa de Contatos; busca, visibilidade, abrir o cadastro, editar a URL e remover continuam; `npm test` do editor de links verde
- criterio de escalada: parar se a correcao pedir redesenho da aba inteira ou mudanca na pagina publica; permanece neste request enquanto for so a aba Redes, no front
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.tsx` (faixa, botao "Cadastrar link" e linha da tabela)
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueContacts.tsx` (botao da faixa); `eventhub-vista-dashboard/src/components/contact/contact-list.tsx` (linha da tabela); `eventhub-vista-dashboard/src/components/ui/button.tsx`; `eventhub-vista-dashboard/src/components/ui/form-layout.tsx` (card branco que ja envolve a aba); `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.test.tsx`
- palavras-chave ou simbolos de busca: `Cadastrar link`, `bg-emerald-50`, `rounded-3xl`, `VenueLinkEditor`, `Button`
- testes provaveis: `eventhub-vista-dashboard/src/components/venue/VenueLinkEditor.test.tsx`
- nao ler por padrao: `security`, `database`, `patterns`, `observability`, backend, `topics/`, pagina publica

## Contexto informado na entrada

Chat com print da aba Redes. O usuario pediu para tirar o container que fica atras do conteudo e deixar o desenho no padrao do projeto. No mesmo print, o botao "Cadastrar link" esta fora desse padrao.

## Problema atual

- a aba Redes mostra um container atras do conteudo
- o botao "Cadastrar link" da faixa nao usa o botao do projeto

## Objetivo da mudanca

Na aba Redes, o container atras do conteudo sai e a faixa e a tabela ficam no desenho de Contatos, com "Cadastrar link" no botao outline pill dessa faixa.

## Escopo inicial percebido

Ajuste visual em `VenueLinkEditor`, na aba `redes` de Configuracoes. A linha da tabela perde o bloco de fundo. O botao da faixa passa a ser o `Button` outline pill usado em Contatos.

## Itens incluidos neste request

- remover o container de fundo atras das linhas da aba Redes
- trocar o "Cadastrar link" da faixa pelo botao do projeto, no mesmo lugar e com a mesma acao
- manter busca, filtro de visibilidade, cadastro, edicao de URL e remocao

## Requisitos implicitos ja visiveis

- o padrao da linha e o da tabela de Contatos: fundo limpo, hover so ao passar o mouse
- o padrao do botao na faixa e o `Button` outline, altura da faixa, pill, como em Contatos e Indicar parceiros
- a cor de fundo nao pode ser o unico sinal de "no link tree"; o filtro de visibilidade continua existindo
- a aba ja fica dentro do card branco de Configuracoes

## Casos de erro e borda ja percebidos

- rede no link tree e rede fora dele ficam com a mesma linha, sem bloco colorido atras
- lista filtrada sem resultado continua com o texto de vazio
- botao desabilitado quando nao ha rede restante para cadastrar
- abrir, cancelar e confirmar o cadastro continuam iguais

## Dependencias

- nenhuma. A aba Redes ja existe. Nao depende da spec `specs/2026-11-21-visual-redes-e-link-tree/`.

## Restricoes e cuidados

- nao criar schema, endpoint ou campo
- nao alterar a pagina publica de links
- nao mudar o que o botao faz, so o componente visual
- nao reabrir o request do visual anterior da aba e da pagina publica

## Perguntas em aberto

1. Qual container sai? Premissa: o bloco verde atras das linhas que estao no link tree. A caixa branca da busca permanece, porque e a faixa de Contatos. Se o pedido for essa caixa, ela sai e busca, botao e visibilidade ficam direto no card de Configuracoes.
2. Qual botao e o padrao? Premissa: o `Button` outline pill da faixa de Contatos. O botao preenchido "Novo Contato" do topo fica de fora, porque "Cadastrar link" fica na faixa.
3. Os botoes de dentro do modal entram? Premissa: nao. So o botao visivel na faixa.

## Prioridade sugerida

Baixa. A aba funciona; o pedido e de visual.

## Faixa sugerida para task workflow

- `A` — um ajuste visual, uma tela, uma frente, decisoes com premissa; sem contrato novo
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: correcao visual de uma aba que ja existe, so no front, sem fluxo novo

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `aba-redes-container-e-botao-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `executar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
