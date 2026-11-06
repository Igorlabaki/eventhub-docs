# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abrir o link do evento numa aba nova

## Resumo da solicitacao

O item Link do evento deixa de abrir a pagina do painel que so tem um campo com o endereco. O clique abre outra aba ja na pagina publica daquele orcamento, com a base `https://event-hub-dashboard.vercel.app/`.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — a pagina publica do link do evento ja existe; este request nao muda quem a ve nem o que ela mostra
- risco principal: o clique continuar na pagina interna do campo, ou a aba nova abrir localhost
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: conteudo da pagina publica `/proposal/{id}/links`; botao de copiar em Regras; tela Indicar parceiros; envio por WhatsApp ou e-mail
- prova minima desta execucao: na sidebar do orcamento, Link do evento abre outra aba em `https://event-hub-dashboard.vercel.app/proposal/{id}/links`; a aba do painel permanece onde estava; o mesmo clique com o painel em localhost nao abre localhost
- criterio de escalada: `normal` se o item da sidebar nao puder abrir aba sem perder o filtro de permissao que ja existe; `spec` nao se aplica
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
- caminhos candidatos: item Link do evento na sidebar do orcamento; pagina interna que hoje mostra o campo do endereco; pagina publica `/proposal/{id}/links`
- palavras-chave ou simbolos de busca: `Link do evento`, `ProposalNav`, `event-link`, `/links`
- testes provaveis: o endereco aberto usa a base de producao e o caminho `/proposal/{id}/links`; o item nao navega para a pagina interna do campo
- nao ler por padrao: `security`, `database`, `topics/`, schema e o miolo da pagina publica

## Contexto informado na entrada

Pedido em chat, na sidebar do orcamento. Em vez de Link do evento abrir uma pagina com o campo de endereco, o clique abre outra aba ja com o link. Esse link, como o das regras, usa a base de producao `https://event-hub-dashboard.vercel.app/`.

## Problema atual

Link do evento leva a uma pagina do painel cujo conteudo e um campo somente leitura com o endereco e um botao Copiar. O endereco mostrado usa a origem da aba, entao no ambiente local comeca com localhost. A pagina publica daquele orcamento ja existe em `/proposal/{id}/links`.

## Objetivo da mudanca

Clicar em Link do evento abre a pagina publica daquele orcamento numa aba nova, no endereco de producao, sem passar pela pagina do campo.

## Escopo inicial percebido

O item da sidebar deixa de navegar para a pagina interna do campo e passa a abrir outra aba na pagina publica do link do evento. A aba do painel fica onde estava.

## Itens incluidos neste request

- o clique em Link do evento abre `https://event-hub-dashboard.vercel.app/proposal/{id}/links` numa aba nova
- a aba do painel nao vai para a pagina do campo
- quem ja via o item continua vendo; quem nao via continua sem ver
- a pagina interna do campo deixa de ser o destino desse item

## Requisitos implicitos ja visiveis

- vale para o orcamento aberto na sidebar
- a base de producao vale tambem quando o painel esta aberto em localhost
- a pagina publica nao ganha bloco, botao nem campo novo
- o gesto e abrir a aba, nao copiar o endereco

## Casos de erro e borda ja percebidos

- orcamento sem id: o item nao abre uma aba com endereco incompleto
- o navegador bloqueia a aba nova: a pessoa permanece na tela atual do painel
- painel em localhost: a aba nova nao abre localhost

## Dependencias

- a sidebar do orcamento ja tem o item Link do evento e ja filtra por permissao
- a pagina publica ja responde em `/proposal/{id}/links`

## Restricoes e cuidados

- nao alterar o conteudo da pagina publica
- nao recolocar o campo de endereco em outro lugar do painel
- nao mudar Regras nem Indicar parceiros
- nao enviar o link por WhatsApp nem por e-mail
- nao ler nem versionar valores de `.env`
- nao trocar a base por variavel de ambiente neste request; a base pedida e a mesma ja escrita nos outros botoes de link

## Perguntas em aberto

- A pagina interna do campo deve sumir do roteador ou pode ficar sem entrada no menu? Premissa: o menu nao aponta mais para ela; apagar a rota fica a criterio da execucao, desde que ninguem caia nela pelo item.
- O clique tambem copia o endereco? Premissa: nao; so abre a aba.
- Onde o item fica na sidebar? Premissa: no lugar em que ja esta.

## Prioridade sugerida

Alta. O atalho do orcamento hoje entrega uma tela que a equipe nao quer usar, e o endereco mostrado nao e o de producao.

## Faixa sugerida para task workflow

- `A` — o item da sidebar passa a abrir um endereco que ja existe
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: muda o destino de um item de menu, sem pagina, contrato ou dado novo

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `tr-03-link-evento-nova-aba.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-links-painel-e-formularios/`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
