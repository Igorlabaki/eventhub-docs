# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abrir o link universal do orcamento na sidebar

## Resumo da solicitacao

O orcamento ganha um item na sidebar com o endereco para copiar. Esse endereco abre uma pagina publica, na marca do espaco, com dia, hora, numero de convidados, contagem regressiva e botoes para orcamento, parceiros indicados, programacao, lista de convidados e lista de colaboradores.

## Context Pack

- frente principal: frontend
- superficie sensivel: sim — a pagina e publica e resume dia, hora e numero de convidados; esses dados a proposta publica ja mostra
- risco principal: a pagina nova exibir preco, documento ou contato do cliente, ou a contagem tratar o horario do evento como instante UTC
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: gravar dado novo no orcamento; alterar o conteudo das cinco paginas ligadas; envio automatico do link por WhatsApp ou e-mail; contrato, pagamento e documentos
- prova minima desta execucao: no painel, o item da sidebar mostra o endereco e Copiar coloca `/proposal/:id/links` na area de transferencia; abrir esse endereco sem login mostra a marca do espaco, o dia, a hora, o numero de convidados, a contagem ate o inicio e os cinco botoes; cada botao abre a pagina publica que ja existe; orcamento sem data abre a pagina sem contagem; depois do inicio, a contagem da lugar a frase de evento ja iniciado
- criterio de escalada: promover para `spec` se a pagina precisar de leitura publica nova ou de campo que a proposta publica ainda nao devolve; `normal` permanece enquanto a pagina so compuser a casca e os links atuais
- nivel de autonomia: `L2`
- camadas transversais: `design`, `security`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-06`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: sidebar do orcamento; tela de copiar link em Indicar parceiros; casca publica das listas; paginas publicas de ver o orcamento, indicacoes, programacao, convidados e colaboradores
- palavras-chave ou simbolos de busca: `ProposalNav`, `SendSuppliers`, `PublicVenueListShell`, `guestNumber`, `startDate`, `wallClock`
- testes provaveis: copiar o link no painel; abrir `/proposal/:id/links` sem sessao; conferir os cinco destinos; comparar a contagem com o horario de parede do evento; sair da pagina e ver a aba voltar ao titulo EventHub
- nao ler por padrao: `database`, `topics/`, schema, pagamento, contrato e envio de orcamento

## Contexto informado na entrada

Pedido em chat, na sidebar do orcamento. A equipe quer mais um item, o link universal daquele orcamento. A pagina segue o padrao publico ja padronizado com os parametros do espaco. Mostra um resumo do evento (dia, hora e numero de convidados), uma contagem regressiva de quanto tempo falta e, no estilo de um linktree, um botao para orcamento, parceiros indicados, programacao, lista de convidados e lista de colaboradores.

## Problema atual

Cada pagina publica do orcamento tem o proprio endereco. Quem recebe o material precisa de varios links para chegar no orcamento, nos parceiros, na programacao, nos convidados e nos colaboradores. A sidebar nao oferece um endereco unico desse conjunto, nem uma pagina que resuma quando o evento acontece e quanto tempo falta.

## Objetivo da mudanca

A equipe copia, na sidebar do orcamento, um unico endereco publico que resume o evento e leva as cinco paginas que ja existem.

## Escopo inicial percebido

Um item novo na sidebar abre a tela de copiar o link, no mesmo gesto de Indicar parceiros. O endereco abre uma pagina publica so de leitura, na casca das listas publicas, com o resumo, a contagem e os cinco botoes. A leitura reaproveita o que a proposta publica ja devolve.

## Itens incluidos neste request

- item novo na sidebar do orcamento, visivel para quem ja pode enviar o orcamento
- a tela do painel mostra o endereco e o botao Copiar
- a pagina publica fica em `/proposal/:id/links`, sem login
- a casca segue as listas publicas: cor primaria no fundo, secundaria nos cards e no rodape, cor do texto na fonte, Manrope, logo e descricao no topo, aba com nome e descricao do espaco, skeleton na marca do espaco, entrada animada e o mesmo rodape
- o resumo mostra dia, horario e numero de convidados daquele orcamento
- a contagem regressiva usa o horario de parede do evento e conta ate o inicio
- cinco botoes: Orcamento, Parceiros indicados, Programacao, Lista de convidados, Lista de colaboradores
- cada botao abre a pagina publica correspondente daquele orcamento

## Requisitos implicitos ja visiveis

- vale para qualquer orcamento, nao para um registro so
- a pagina nao grava nada
- a rota publica e intencional e mostra so dia, hora e convidados, alem dos cinco destinos
- a referencia visual e a casca das listas publicas
- sem logo, sem descricao ou sem rede do espaco, topo, aba e rodape degradam como nas listas publicas
- ao sair da pagina, a aba volta ao titulo EventHub
- o horario do evento continua wall-clock; a contagem nao converte a agenda para UTC

## Casos de erro e borda ja percebidos

- orcamento sem data: a pagina abre na marca do espaco, sem contagem
- inicio ja passou: a contagem da lugar a uma frase de que o evento ja comecou
- fim em outro dia: o resumo mostra o intervalo de datas
- numero de convidados ausente: o resumo omite essa linha
- espaco sem alguma cor, sem logo ou sem descricao: a pagina usa o mesmo fallback das listas publicas
- espaco ainda carregando: a tela nao mostra a marca EventHub nem cores de outro espaco
- lista de destino vazia: o botao continua na pagina; a lista vazia fica na pagina de destino
- pedido de outro orcamento: resumo e botoes nao misturam dados

## Dependencias

- a sidebar do orcamento ja lista as acoes daquele orcamento e ja filtra por permissao
- Indicar parceiros ja mostra um endereco publico com botao Copiar
- as listas publicas ja aplicam a marca do espaco
- ja existem as paginas publicas de ver o orcamento, indicacoes, programacao, convidados e colaboradores
- dia, hora e numero de convidados ja pertencem ao orcamento

## Restricoes e cuidados

- nao criar campo novo nem migration
- nao alterar o que as cinco paginas de destino gravam ou mostram
- nao enviar o link por WhatsApp nem por e-mail
- nao ler nem versionar valores de `.env`
- a pagina publica nao renderiza preco, documento, endereco ou contato do cliente
- preservar o horario de parede na contagem

## Perguntas em aberto

- O item da sidebar abre a pagina publica ou a tela de copiar? Premissa: abre a tela de copiar, no painel; a pagina publica e o endereco copiado.
- Qual o rotulo do item? Premissa: Link do evento.
- Onde o item fica na sidebar? Premissa: logo abaixo de Enviar Orcamento.
- Quem ve o item? Premissa: quem ja pode enviar informacao do orcamento.
- A contagem vai ate o inicio ou ate o fim? Premissa: ate o inicio; depois do inicio, a frase diz que o evento ja comecou.
- O fim do evento tambem troca a frase? Premissa: sim; depois do fim, a frase diz que o evento ja aconteceu.
- Algum botao some quando a lista esta vazia? Premissa: nao; os cinco botoes ficam sempre.
- O link sai em algum envio automatico? Premissa: nao; a tela so copia.

## Prioridade sugerida

Media. Os links publicos ja existem separados; falta o endereco unico para a pessoa do evento.

## Faixa sugerida para task workflow

- `B` — uma pagina publica e um item de sidebar, reusando a casca e a leitura que ja existem
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: o objetivo e um so, a frente dominante e o frontend e a pagina compoe a casca e os links atuais. Vira spec somente se a leitura publica precisar de contrato novo.

## Sugestao de slug da spec

- `framework_core/specs/link-universal-orcamento/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `link-universal-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- entrega: pagina `/proposal/:id/links` e item Link do evento em `/proposal/:id/event-link`; 10 testes em `event-link.test.ts`; no browser, o orcamento AR756 mostrou dia, hora, convidados, contagem e os cinco destinos sem login; a tela de copiar sem sessao foi para o login
- derivacao repo-local: `nao se aplica`
