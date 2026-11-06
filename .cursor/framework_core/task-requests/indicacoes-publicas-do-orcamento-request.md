# Solicitacao da Tarefa

## Nome sugerido da tarefa

Salvar as indicacoes no orcamento e abrir a pagina publica dos parceiros

## Resumo da solicitacao

Indicar parceiros deixa de montar uma mensagem de WhatsApp. A equipe grava no orcamento quem foi indicado, e a pessoa abre uma pagina publica, no padrao dos outros links da proposta, com os dados que o cadastro do parceiro ja tem.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — a pagina e publica e mostra WhatsApp, e-mail e redes de parceiros
- risco principal: a pagina mostrar fornecedores que nao foram indicados naquele orcamento, ou a equipe continuar dependendo do texto de WhatsApp porque a selecao nao ficou gravada
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: o envio do orcamento por WhatsApp ou e-mail; o cadastro de parceiro e de equipe; foto ou descricao nova no parceiro; listas de convidados, colaboradores e programacao; contratos publicos; a marca das paginas que ja existem
- prova minima desta execucao: no painel, marcar parceiros e salvar nao abre WhatsApp; recarregar a tela mantem a mesma selecao; abrir `/proposal/:id/indications` sem login mostra so esses parceiros, com nome, funcao, WhatsApp, e-mail, Instagram, Facebook, TikTok e site, na marca do espaco; desmarcar e salvar tira o parceiro da pagina; um fornecedor nao marcado nao aparece; orcamento sem indicacao abre a pagina na marca do espaco, vazia
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se a selecao ja estiver gravada no orcamento e a mudanca ficar so na pagina
- nivel de autonomia: `L2`
- camadas transversais: `security`, `database`, `design`, `patterns`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `architecture`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-01`
  - `.cursor/framework_core/project/project-decisions.md#D-03`
  - `.cursor/framework_core/project/project-decisions.md#D-05`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/task-requests/marca-espaco-listas-publicas-request.md#Objetivo da mudanca`
- caminhos candidatos: tela Enviar Parceiros do orcamento; cadastro de contato do tipo fornecedor; casca publica das listas de convidados, colaboradores e programacao
- palavras-chave ou simbolos de busca: `SendSuppliers`, `send-suppliers`, `SUPPLIER`, `PublicVenueListShell`, `guest-list`
- testes provaveis: gravar e reler a selecao no painel; abrir a pagina publica sem sessao; conferir que fornecedor nao indicado e contato de equipe nao aparecem; alterar o WhatsApp do parceiro e ver o valor novo na pagina
- nao ler por padrao: `topics/`, specs de outras frentes, pagamento, contrato e envio de orcamento

## Contexto informado na entrada

Pedido em chat. A equipe quer parar de mandar a indicacao por mensagem. O que foi indicado deve ficar salvo no orcamento. A pessoa recebe uma pagina, no mesmo padrao das paginas publicas dos outros links, e ao abrir ve as informacoes que o sistema ja tem dos parceiros.

## Problema atual

Em Enviar Parceiros, a equipe marca fornecedores do espaco. A tela monta um texto com nome, funcao, Instagram, Facebook, TikTok, WhatsApp e site, e abre o WhatsApp do cliente. Nada disso fica no orcamento. O e-mail do parceiro existe no cadastro e nao entra nesse texto. Nao ha pagina para a pessoa consultar as indicacoes depois.

## Objetivo da mudanca

Salvar no orcamento os parceiros indicados e mostra-los numa pagina publica, sem enviar mensagem, com a marca do espaco e com os dados que o cadastro do parceiro ja guarda.

## Escopo inicial percebido

A tela atual de indicar parceiros passa a gravar a selecao naquele orcamento. Surge uma pagina publica so de leitura para essa selecao, na casca ja usada pelas listas publicas da proposta. A gravacao e a leitura cruzam painel, API e persistencia.

## Itens incluidos neste request

- a tela de indicar parceiros grava a selecao no orcamento e nao abre WhatsApp
- salvar de novo substitui o conjunto daquele orcamento
- a tela mostra o link da pagina para copiar
- a pagina publica fica em `/proposal/:id/indications`, sem login
- a casca segue as listas publicas: cor primaria no fundo, secundaria nos cards e no rodape, cor do texto na fonte, Manrope, logo e descricao no topo, aba com nome e descricao do espaco, skeleton na marca do espaco, entrada animada e o mesmo rodape
- cada card mostra nome, funcao, WhatsApp, e-mail, Instagram, Facebook, TikTok e site
- campo vazio nao aparece
- a pagina le o cadastro atual do parceiro
- a leitura publica devolve so os parceiros ligados a aquele orcamento

## Requisitos implicitos ja visiveis

- vale para qualquer orcamento, nao para um registro so
- quem salva continua sendo quem ja pode enviar informacao do orcamento
- a permissao da tela nao substitui a autorizacao da gravacao
- a rota publica e intencional e precisa ser testada para nao devolver o restante dos contatos do espaco
- contato de equipe nao entra na lista nem na pagina
- a referencia visual e a casca das listas publicas, nao a pagina de ver o orcamento
- sem logo, sem descricao ou sem rede do espaco, topo, aba e rodape degradam como nas listas publicas
- ao sair da pagina, a aba volta ao titulo EventHub

## Casos de erro e borda ja percebidos

- nenhum parceiro marcado: a pagina abre na marca do espaco, com a lista vazia
- desmarcar e salvar: o parceiro sai da pagina
- parceiro apagado do espaco: sai da pagina daquele orcamento
- WhatsApp ou rede alterados no cadastro: a pagina mostra o valor novo
- espaco sem alguma cor, sem logo ou sem descricao: a pagina usa o mesmo fallback das listas publicas
- espaco ou lista ainda carregando: a tela nao mostra a marca EventHub nem cores de outro espaco
- pedido publico de outro orcamento: nao mistura parceiros
- gravacao sem permissao: a selecao nao muda

## Dependencias

- a tela Enviar Parceiros ja lista os fornecedores do espaco e ja exige permissao para enviar informacao do orcamento
- o cadastro de contato ja guarda nome, funcao, WhatsApp, e-mail, Instagram, Facebook, TikTok e site
- as listas publicas de convidados, colaboradores e programacao ja aplicam a marca do espaco
- o contato hoje pertence ao espaco; o orcamento ainda nao guarda quem foi indicado

## Restricoes e cuidados

- nao enviar a indicacao por WhatsApp nem por e-mail nesta entrega
- nao alterar Enviar Orcamento nem Entrar em contato
- nao criar foto nem descricao longa no parceiro
- nao incluir contato de equipe
- nao alterar o que as outras paginas publicas gravam ou mostram
- nao ler nem versionar valores de `.env`
- a rota publica continua intencional; o que ela devolve e so a indicacao daquele orcamento
- migration de producao, se existir, e aditiva

## Perguntas em aberto

- A pessoa recebe o link por algum envio automatico? Premissa: nao; a tela so mostra o link para copiar.
- Salvar acrescenta ou substitui? Premissa: substitui o conjunto daquele orcamento.
- A pagina guarda uma copia do dia da indicacao? Premissa: nao; mostra o cadastro atual do parceiro.
- O e-mail entra no card? Premissa: sim, porque ja existe no cadastro; campo vazio nao aparece.
- A ordem dos cards segue a marcacao ou o nome? Premissa: a ordem em que foram salvos.
- Parceiro, equipe e contrato mudam de casca junto? Premissa: nao; so a pagina nova de indicacoes usa a casca das listas publicas.

## Prioridade sugerida

Media. A indicacao hoje se perde na mensagem, e a pessoa nao tem uma pagina para consultar os parceiros.

## Faixa sugerida para task workflow

- `C` — jornada nova, persistencia no orcamento, pagina publica e os dois repositorios
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido troca o fluxo de indicar parceiros, grava a selecao no orcamento, abre uma pagina publica com dado de contato e toca `frontend` e `backend`. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/indicacoes-publicas-do-orcamento/`

## Sugestao de nome do arquivo

- `indicacoes-publicas-do-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-indicacoes-publicas-do-orcamento/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria` depois da spec, com `tasking/task-request-repo-split-prompt.md` se a promocao nao dividir o trabalho
