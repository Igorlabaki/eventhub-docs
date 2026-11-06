# Solicitacao da Tarefa

## Nome sugerido da tarefa

Logo, descricao e card vertical do parceiro

## Resumo da solicitacao

No cadastro publico de parceiro, a pessoa envia uma logo e uma descricao do servico. No fim do formulario, um preview vertical mostra como o card vai ficar. O card publico das indicacoes do orcamento usa o mesmo formato.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — o cadastro publico passa a aceitar upload de imagem, e a pagina publica de indicacoes mostra logo, descricao e redes
- risco principal: a rota publica gravar arquivo sem limite de tipo ou tamanho, ou o preview prometer um card diferente do que a pessoa ve nas indicacoes
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: categoria do parceiro; quem entra na indicacao de um orcamento; contato de equipe; foto e descricao dos servicos cobrados do espaco; envio de indicacao por WhatsApp; redesenho do restante do formulario
- prova minima desta execucao: no cadastro publico, escolher uma imagem e preencher nome, descricao e uma rede atualiza, acima de Cadastrar, um card vertical com avatar, nome, descricao e icones; depois de salvar, `/proposal/:id/indications` mostra o mesmo card para o parceiro indicado; sem logo, o avatar e a inicial do nome; descricao vazia so aparece como texto de espera no preview e some no card publico; arquivo que nao e imagem e recusado; fornecedor nao indicado naquele orcamento nao aparece
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se logo e descricao ja estiverem gravadas no contato e a mudanca ficar so no preview
- nivel de autonomia: `L2`
- camadas transversais: `security`, `database`, `design`, `patterns`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `database`, `aws`, `architecture`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-01`
  - `.cursor/framework_core/project/project-decisions.md#D-03`
  - `.cursor/framework_global/framework-libs/security/index.md#Quando esta lib e obrigatoria`
- caminhos candidatos: cadastro publico de parceiro; formulario de contato do tipo fornecedor no painel; pagina publica de indicacoes do orcamento; upload de foto de servico ja existente
- palavras-chave ou simbolos de busca: `PartnerForm`, `Cadastro de Parceiro`, `ProposalIndications`, `SUPPLIER`, `indicationLinks`
- testes provaveis: preview ao vivo no formulario publico; gravar logo e descricao e reler no card publico; recusar arquivo que nao e imagem; parceiro sem logo e sem descricao; fornecedor nao indicado fora da pagina
- nao ler por padrao: `topics/`, specs de preco e foto de servico cobrado, pagamento, contrato e envio de orcamento

## Contexto informado na entrada

Pedido em chat, a partir da tela Cadastro de Parceiro. O parceiro precisa poder colocar uma logo ou avatar e uma descricao do servico. No fim do formulario deve haver um preview de como o card dele vai ficar, em formato vertical: avatar, nome, descricao e redes.

## Problema atual

O cadastro publico pede nome, categoria, funcao, WhatsApp, e-mail e redes. Nao ha logo nem descricao do servico. O card publico das indicacoes e horizontal: nome e funcao de um lado, icones do outro. A pessoa que se cadastra nao ve como o card vai aparecer.

## Objetivo da mudanca

O parceiro envia logo e descricao no cadastro publico, ve o card vertical antes de salvar, e esse mesmo card e o que aparece nas indicacoes do orcamento.

## Escopo inicial percebido

O contato do tipo fornecedor passa a guardar logo e descricao. O formulario publico ganha os dois campos e o preview. A pagina publica de indicacoes troca o card horizontal pelo vertical. O painel precisa conseguir corrigir os mesmos dados, porque o registro e o mesmo.

## Itens incluidos neste request

- logo ou avatar opcional no cadastro publico de parceiro
- descricao do servico opcional no mesmo formulario
- preview ao vivo acima de Cadastrar, vertical e centralizado: avatar, nome, descricao, redes
- o preview usa a imagem escolhida antes do envio e acompanha o que esta sendo digitado
- sem logo, o avatar do preview e a inicial do nome
- nome ou descricao vazios no preview mostram um texto de espera
- o preview mostra so as redes preenchidas
- o card de `/proposal/:id/indications` segue a mesma ordem: avatar, nome, descricao, redes
- no card publico, descricao vazia nao aparece e, sem logo, o avatar e a inicial do nome
- o formulario de contato do tipo fornecedor no painel edita logo e descricao

## Requisitos implicitos ja visiveis

- a funcao continua no cadastro e no painel; nao entra no preview nem no card publico
- a categoria do parceiro permanece como esta
- campo de rede vazio nao vira icone
- a pagina de indicacoes continua mostrando so os parceiros ligados a aquele orcamento
- a rota de cadastro publico continua intencional; o upload precisa de limite de tipo e de tamanho
- a permissao da tela do painel nao substitui a autorizacao da gravacao
- migration de producao, se existir, e aditiva
- sem logo, sem descricao ou sem rede, o card degrada sem quebrar o layout

## Casos de erro e borda ja percebidos

- arquivo que nao e imagem
- imagem grande demais
- descricao longa
- nome vazio no preview, antes da validacao do envio
- parceiro sem nenhuma rede
- parceiro ja cadastrado, editado depois no painel, com logo trocada ou removida
- indicacao de orcamento que ainda nao tem esses campos preenchidos
- fornecedor que nao foi indicado naquele orcamento

## Dependencias

- a pagina publica de indicacoes ja existe; este pedido muda o card, nao quem aparece nela
- o pedido de indicacoes publicas deixou foto e descricao do parceiro de fora; este request e o complemento

## Restricoes e cuidados

- nao mudar a categoria do parceiro nem a regra de quem entra na indicacao
- nao colocar a funcao no card vertical
- nao misturar esta descricao com a foto ou a descricao dos servicos cobrados do espaco
- nao incluir contato de equipe
- nao ler nem versionar valores de `.env`
- o upload publico nao pode ficar sem limite de tipo e de tamanho
- a execucao futura e multi-repo e pode ser derivada com `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Logo e descricao sao obrigatorias? Premissa: nao; o cadastro segue valendo sem as duas.
- A funcao aparece no card? Premissa: nao; a ordem e avatar, nome, descricao e redes.
- O painel tambem edita logo e descricao? Premissa: sim, no contato do tipo fornecedor, para o espaco corrigir o que o parceiro enviou.
- A descricao tem tamanho maximo? Premissa: sim, um limite curto definido na spec; o vazio nao aparece no card publico.
- Trocar a logo no painel apaga a anterior? Premissa: sim, o contato fica com uma logo so.

## Prioridade sugerida

Media. O cadastro publico ja existe e a pagina de indicacoes ja lista o parceiro; falta a cara do card e o texto do servico.

## Faixa sugerida para task workflow

- `C` — upload publico, persistencia no contato, formulario, preview e o card das indicacoes, nos dois repositorios
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria logo e descricao no contato, abre upload numa rota publica, muda o formulario e o card das indicacoes, e toca `frontend` e `backend`. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/logo-descricao-card-parceiro/`

## Sugestao de nome do arquivo

- `logo-descricao-card-parceiro-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-logo-descricao-card-parceiro/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria` depois da spec, com `tasking/task-request-repo-split-prompt.md` se a promocao nao dividir o trabalho
