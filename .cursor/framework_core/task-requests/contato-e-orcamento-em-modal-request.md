# Solicitacao da Tarefa

## Nome sugerido da tarefa

Entrar em contato e Enviar Orcamento abrem um modal

## Resumo da solicitacao

No orcamento, "Entrar em contato" e "Enviar Orcamento" deixam de abrir uma tela. O clique abre um modal pequeno, na pagina em que a pessoa ja esta, com a mensagem editavel e o botao de enviar.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — o WhatsApp e o e-mail do cliente ja saem dessas acoes; o pedido so troca a tela por um modal
- risco principal: o modal de orcamento perder o envio por e-mail, que hoje vive na mesma pagina do WhatsApp
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: texto padrao das mensagens; link do evento; indicar parceiros; gerar contrato; gravar historico de mensagem; backend
- prova minima desta execucao: no orcamento de um cliente, clicar em "Entrar em contato" abre um modal com a saudacao editavel e "Enviar via WhatsApp", sem trocar a URL; o mesmo para "Enviar Orcamento", com a mensagem do link; enviar abre o WhatsApp; fechar o modal volta a pagina de onde se clicou
- criterio de escalada: permanece `normal`; vira `spec` se o envio passar a gravar historico, template no servidor ou um canal novo
- nivel de autonomia: `L2`
- camadas transversais: `design`, `patterns`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `patterns`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/agent-entrypoint.md#Provas`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
- caminhos candidatos: `SendMessagePage`, `SendProposalPage`, itens "Entrar em contato" e "Enviar Orcamento" em `sidebar-nav-model`, rotas `send-message` e `send-proposal` em `App.tsx`, `Dialog` em `components/ui/dialog.tsx`
- palavras-chave ou simbolos de busca: `SendMessagePage`, `SendProposalPage`, `SEND_PROPOSAL_TEXT`, `SEND_PROPOSAL_INFO`, `wa.me`
- testes provaveis: o clique dos dois itens nao navega; o modal mostra a mensagem e o botao; sem WhatsApp do cliente o envio nao abre o link
- nao ler por padrao: `security`, `database`, backend, `topics/`

## Contexto informado na entrada

Pedido em chat, com print da tela "Enviar Mensagem" do orcamento da Angela Melissa Salatine Santos (espaco AR756). O texto: a tela nao faz sentido; o clique nao deveria abrir uma tela; deveria ser um modal com a mensagem, editavel, e o botao enviar. O mesmo para "Enviar Orcamento".

No codigo visto no chat, os dois itens do menu "Falar com o cliente" sao links de pagina: `/proposal/:id/send-message` e `/proposal/:id/send-proposal`. As duas paginas ja tem a mensagem pronta e o envio pelo WhatsApp. "Enviar Orcamento" tambem tem aba de e-mail.

## Problema atual

"Entrar em contato" e "Enviar Orcamento" trocam a pagina inteira do orcamento. O que a pessoa precisa e um modal pequeno: ler a mensagem, alterar se quiser e enviar.

## Objetivo da mudanca

Clicar em "Entrar em contato" ou em "Enviar Orcamento" abre um modal na pagina atual, com a mensagem editavel e o botao de enviar, e a URL do orcamento nao muda.

## Escopo inicial percebido

So o frontend do painel, nos dois itens do menu do orcamento. O conteudo que hoje esta nas paginas passa para o modal. Sem backend.

## Itens incluidos neste request

- "Entrar em contato" abre modal com a mensagem editavel e o botao de enviar pelo WhatsApp
- "Enviar Orcamento" abre modal com a mensagem do orcamento editavel e o botao de enviar
- os dois cliques permanecem na pagina do orcamento em que a pessoa ja estava
- as permissoes atuais continuam escondendo o item de quem nao pode enviar

## Requisitos implicitos ja visiveis

- a saudacao e a mensagem do link do orcamento continuam as que as paginas ja preenchem
- o envio pelo WhatsApp continua abrindo `wa.me` com o texto
- sem WhatsApp do cliente, o envio nao segue
- o item do menu nao fica marcado como uma pagina propria

## Casos de erro e borda ja percebidos

- cliente sem WhatsApp
- mensagem apagada antes de enviar
- "Enviar Orcamento" hoje tambem envia por e-mail, com anexo
- alguem abre no navegador a URL antiga `/send-message` ou `/send-proposal`

## Dependencias

- as duas paginas e os dois itens de menu ja existem
- o `Dialog` do painel ja existe
- o menu do orcamento hoje so conhece link interno ou link externo

## Restricoes e cuidados

- nao mudar o texto padrao das mensagens
- nao criar canal novo de envio
- nao gravar historico de mensagem
- nao alterar "Link do evento", "Indicar parceiros" nem "Gerar Contrato"
- nao ler nem versionar valores de `.env`

## Perguntas em aberto

- A aba de e-mail de "Enviar Orcamento" entra no mesmo modal? Premissa: sim. O modal do orcamento continua com WhatsApp e e-mail; so "Entrar em contato" e so WhatsApp.
- A URL antiga das duas paginas ainda abre? Premissa: nao. O menu deixa de ir para elas; quem abrir o endereco antigo cai na visao do orcamento.

## Prioridade sugerida

Media. O fluxo existe e funciona; a tela cheia e que atrapalha o uso no dia a dia.

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, so no frontend, sem dado novo nem contrato. As duas acoes sao a mesma mudanca de tela para modal.

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `contato-e-orcamento-em-modal-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
