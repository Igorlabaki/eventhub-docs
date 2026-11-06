# Solicitacao da Tarefa

## Nome sugerido da tarefa

Adicionar ou tirar servico no link publico do orcamento

## Resumo da solicitacao

No card "Sua experiencia inclui" da pagina publica, o cliente clica em "Adicionar servico", abre um modal e marca ou desmarca servicos do espaco. Servico obrigatorio para o numero atual de convidados permanece marcado e nao desmarca. Ao confirmar, o orcamento gravado, a lista da experiencia e o card "Seu investimento" passam a mostrar a selecao e o total novos.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — `/proposal/:id/view` e publica e a gravacao muda servicos e valor do orcamento sem login
- risco principal: qualquer pessoa com o link tirar um servico obrigatorio ou reescrever o total fora da conta da casa
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: mudar a regra de obrigatoriedade; dia, convidados e horas; descontos e adicionais; cadastro de servico no painel; foto e descricao do servico; incluir servico obrigatorio sozinho quando "Alterar orcamento" muda o numero de convidados
- prova minima desta execucao: em `/proposal/:id/view`, o botao "Adicionar servico" abre o modal com os servicos do espaco; os ja ligados vem marcados; obrigatorio para os convidados atuais fica marcado e travado; confirmar atualiza a lista e o total na pagina; tirar um opcional baixa o total; orcamento aprovado ou pago explica por que nao grava; falha de rede mantem a lista e o total anteriores
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a um modal que nao grava
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: card "Sua experiencia inclui" na pagina publica da proposta; selecao de servicos no formulario publico de orcamento; gravacao publica de "Alterar orcamento"
- palavras-chave ou simbolos de busca: `ProposalView`, `Sua experiência inclui`, `rpaRequired`, `rpaMinPeople`, `proposalServices`, `quoteServiceLines`
- testes provaveis: `npm test -- --run` no backend na gravacao publica de servicos; `npm run lint` no frontend; o modal no browser com opcional marcado, obrigatorio travado, orcamento aprovado ou pago e falha de gravacao
- nao ler por padrao: `topics/`, `database` alem do vinculo de servico que o orcamento ja grava, cadastro de servico no painel

## Contexto informado na entrada

Pedido em chat, com print do card "Sua experiencia inclui". O botao deve ficar nesse container, no mesmo jeito do "Alterar orcamento", e abrir um modal em que a pessoa marca ou desmarca servicos. Servico obrigatorio nao desmarca.

Fechado na conversa anterior: o texto do botao e "Adicionar servico"; a obrigatoriedade segue a regra ja usada no formulario, `rpaRequired` a partir de `rpaMinPeople` comparado aos convidados atuais; a gravacao fica no servidor e devolve a lista e o total para os dois cards.

## Problema atual

Quem abre o link publico ve os servicos ja ligados ao orcamento e o valor de cada linha, e nao consegue incluir nem tirar nenhum. Para mudar a selecao, a equipe precisa editar o orcamento no painel.

## Objetivo da mudanca

Na pagina publica, o cliente abre "Adicionar servico", marca ou desmarca o que pode, confirma e ve a experiencia e o investimento gravados com a selecao nova, ou ve no proprio modal o motivo de nao ter gravado.

## Escopo inicial percebido

Botao e modal no card de experiencia da pagina publica, mais a gravacao da nova lista de servicos naquele orcamento. Toca `frontend` e `backend`. O request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`.

## Itens incluidos neste request

- botao "Adicionar servico" no card "Sua experiencia inclui", no mesmo estilo de "Alterar orcamento"
- modal com os servicos do espaco; os ja ligados ao orcamento vem marcados
- servico obrigatorio para os convidados atuais permanece marcado e nao desmarca
- confirmar grava a selecao, recalcula as linhas e o total e atualiza os dois cards
- orcamento aprovado ou pago nao e reescrito e o modal diz o motivo
- card visivel quando o espaco tem servico, mesmo que o orcamento ainda nao tenha nenhum

## Requisitos implicitos ja visiveis

- a pagina continua publica, no mesmo link
- a conta da linha permanece no servidor: preco fixo, preco vezes as horas ou preco vezes os convidados
- a tela nao envia preco nem total; envia somente a selecao
- a resposta publica nao inclui a tabela de preco do cadastro alem da linha deste orcamento
- o frontend nao cria uma terceira forma de estado alem das que o projeto ja usa
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`
- camadas transversais da execucao: `security`, `design`, `patterns`

## Casos de erro e borda ja percebidos

- servico obrigatorio desmarcado na tela: a gravacao o recoloca e o total o inclui
- servico obrigatorio so a partir de N pessoas, com convidados abaixo de N: continua opcional e pode sair
- orcamento sem nenhum servico e espaco com servico cadastrado: o card e o botao aparecem para incluir o primeiro
- orcamento aprovado ou pago: o modal explica que nao da para alterar
- falha de rede ou erro do servidor: o modal mostra o que falhou e a lista e o total da pagina continuam os anteriores
- servico de outro espaco: nao entra no orcamento
- dois cliques em confirmar: a gravacao em andamento nao dispara de novo

## Dependencias

- a pagina publica ja mostra "Sua experiencia inclui" e "Seu investimento"
- o formulario publico ja trata servico obrigatorio a partir de um numero de pessoas
- o orcamento ja grava a linha do servico e o total
- o botao "Alterar orcamento" ja existe no card de investimento e nao muda a lista de servicos

## Restricoes e cuidados

- nao deixar a tela decidir o total
- nao publicar preco unitario de cadastro alem da linha calculada para este orcamento
- nao mudar dia, convidados, horas, descontos nem adicionais neste fluxo
- nao alterar a regra de quando um servico passa a ser obrigatorio
- nao ler nem versionar valores de `.env`
- a rota publica que grava precisa ser intencional e nao devolver dado interno
- quem tem o link pode alterar a selecao enquanto o orcamento nao estiver aprovado ou pago

## Perguntas em aberto

- O clique em cada caixa ja grava? Premissa: nao; a pessoa confirma a selecao e ai grava.
- O modal mostra o valor da linha? Premissa: sim, o valor ja calculado para os convidados e as horas atuais.
- Obrigatorio abaixo do minimo de pessoas pode sair? Premissa: sim; so trava quando os convidados atuais atingem o minimo.
- Orcamento aprovado ou pago pode mudar servico? Premissa: nao; o modal explica o motivo.
- O card aparece sem nenhum servico ligado? Premissa: sim, quando o espaco tem servico cadastrado.
- A mudanca entra no historico da proposta? Premissa: sim, no mesmo espirito do recalculo publico, sem usuario.
- Onde fica o botao no celular? Premissa: no topo do card "Sua experiencia inclui", visivel em qualquer largura.

## Prioridade sugerida

Media. O cliente passa a ajustar os servicos do orcamento que ja recebeu, sem corrigir um calculo quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria uma gravacao publica da lista de servicos e do total, reutiliza a conta de linha do orcamento e separa o modal do contrato que grava. Toca `frontend` e `backend` e nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/adicionar-servico-proposta-publica/`

## Sugestao de nome do arquivo

- `adicionar-servico-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-04-adicionar-servico-proposta-publica/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
