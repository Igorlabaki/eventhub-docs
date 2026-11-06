# Solicitacao da Tarefa

## Nome sugerido da tarefa

Recalcular o orcamento no link publico

## Resumo da solicitacao

No card "Seu investimento" da pagina publica, o cliente abre um modal, altera so o dia, o numero de convidados e a quantidade de horas, e ao clicar em Recalcular o orcamento gravado e o card passam a mostrar o valor novo. O formulario usa React Hook Form e Zod, e todo erro aparece no modal para a pessoa saber o que aconteceu.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — `/proposal/:id/view` e publica e o recálculo grava data, convidados e valor do orcamento sem login
- risco principal: qualquer pessoa com o link reescrever o orcamento oficial, ou a tela recalcular por conta propria e divergir da tabela da casa
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: servicos, descontos e adicionais; formulario de edicao do painel; agenda e data ocupada; modelo de pernoite; nova regra de preco; expor a tabela de preco do cadastro
- prova minima desta execucao: em `/proposal/:id/view`, abrir o modal no card "Seu investimento", ver dia, convidados e horas preenchidos, e so esses tres campos; campo vazio, convidado acima da capacidade ou hora invalida mostra a mensagem do Zod e nao grava; Recalcular com valores validos atualiza locacao, total, convidados e horario na pagina; falha de rede ou do servidor mostra a mensagem no modal e o total anterior permanece; orcamento aprovado ou pago explica por que nao recalcula
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a um modal que nao grava e nao recalcula no servidor
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
- caminhos candidatos: card "Seu investimento" na pagina publica da proposta; calculo ja usado ao criar e editar orcamento no painel
- palavras-chave ou simbolos de busca: `ProposalView`, `Seu investimento`, `guestNumber`, `extraHoursQty`, `updatePerPerson`, `updatePerDay`
- testes provaveis: `npm run build` e `npm run lint` no frontend; `npm test -- --run` no backend no calculo reutilizado; o modal no browser com campo invalido, recálculo valido, erro de servidor e orcamento aprovado ou pago
- nao ler por padrao: `topics/`, `database` alem do que o calculo ja gravado exigir, formulario completo do painel

## Contexto informado na entrada

Pedido em chat, sobre o card "Seu investimento" da proposta publica. O cliente clica e abre um modal com somente tres campos: dia, numero de convidados e quantidade de horas. Pode alterar e clicar em Recalcular, e o orcamento atualiza. O formulario deve usar React Hook Form e Zod, com validacao e erro visivel para a pessoa sempre saber o que esta acontecendo.

Fechado na conversa anterior: o botao fica nesse card; o clique grava o orcamento; a conta fica no servidor, com a tabela da casa; o horario de inicio ja gravado permanece e a quantidade de horas ajusta o fim.

## Problema atual

Quem abre o link publico ve data, convidados, horas e o total, e nao consegue muda-los. Para outro dia, outro numero de pessoas ou outra duracao, a equipe precisa editar o orcamento no painel.

## Objetivo da mudanca

Na pagina publica, o cliente abre o modal, corrige dia, convidados e horas, clica em Recalcular e ve o orcamento gravado com o valor novo, ou ve no proprio modal o motivo de nao ter gravado.

## Escopo inicial percebido

Modal no card de investimento da pagina publica, mais a gravacao do recálculo no orcamento daquele link. Toca `frontend` e `backend`. O request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`.

## Itens incluidos neste request

- botao no card "Seu investimento" que abre o modal
- modal com somente tres campos: dia, convidados e quantidade de horas, ja preenchidos com o orcamento atual
- formulario em React Hook Form e Zod
- mensagem em cada campo invalido e mensagem quando a gravacao falha, para a pessoa saber o que aconteceu
- botao Recalcular que grava e atualiza locacao, horas extras, total, convidados e horario na pagina
- servicos ja ligados ao orcamento permanecem
- orcamento aprovado ou pago nao e reescrito e o modal diz o motivo

## Requisitos implicitos ja visiveis

- a pagina continua publica, no mesmo link
- horario do evento permanece em wall-clock
- o horario de inicio ja gravado permanece; a quantidade de horas move o fim
- convidados nao passam da capacidade do espaco
- o recálculo usa a mesma conta do painel, inclusive minimo e ajuste por data; a tela nao inventa o total
- a resposta publica nao inclui a tabela de preco do cadastro
- o frontend nao cria uma terceira forma de estado alem das que o projeto ja usa
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`

## Casos de erro e borda ja percebidos

- campo vazio, data invalida, zero convidados ou zero horas: o Zod aponta o campo e nao grava
- convidados acima da capacidade: a mensagem cita o maximo e nao grava
- falha de rede ou erro do servidor: o modal mostra o que falhou e o total da pagina continua o anterior
- orcamento aprovado ou pago: o modal explica que nao da para recalcular
- casa com pernoite: os tres campos continuam; horas nao trocam check-in, check-out nem minimo de noites
- total que a equipe digitou a mao: Recalcular substitui pela tabela da casa
- sem WhatsApp ou sem servico: o modal e o total novo continuam disponiveis

## Dependencias

- a pagina publica do orcamento ja mostra o card "Seu investimento"
- o painel ja calcula orcamento por pessoa e por dia a partir de dia, horario e convidados
- capacidade maxima do espaco ja aparece na pagina publica
- React Hook Form e Zod ja sao a validacao do frontend

## Restricoes e cuidados

- nao recalcular o valor so no navegador
- nao publicar preco por pessoa, preco por dia nem preco minimo do cadastro
- nao alterar servicos, descontos nem adicionais neste fluxo
- nao consultar agenda nem bloquear data ocupada nesta entrega
- nao mudar o modelo de pernoite
- nao ler nem versionar valores de `.env`
- a rota publica que grava precisa ser intencional e nao devolver dado interno
- quem tem o link pode alterar enquanto o orcamento nao estiver aprovado ou pago

## Perguntas em aberto

- O recálculo grava ou so mostra uma previa? Premissa: grava, e a pagina passa a mostrar o valor novo.
- Orcamento aprovado ou pago pode ser recalculado? Premissa: nao; o modal explica o motivo.
- Um total negociado a mao e substituido? Premissa: sim; Recalcular usa a tabela da casa.
- Casa com pernoite perde o campo de horas? Premissa: nao; os tres campos permanecem e as horas nao mudam check-in, check-out nem minimo de noites.
- Data ja reservada bloqueia o recálculo? Premissa: nao nesta entrega.
- O horario de inicio tambem muda? Premissa: nao; so a quantidade de horas, e o fim acompanha.
- Onde fica o botao? Premissa: no card "Seu investimento".

## Prioridade sugerida

Media. O cliente passa a ajustar o orcamento que ja recebeu, sem corrigir um calculo quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido cria uma gravacao publica de data, convidados, horas e valor, reutiliza o calculo do painel e separa a tela do modal do contrato que grava. Toca `frontend` e `backend` e nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/recalcular-orcamento-proposta-publica/`

## Sugestao de nome do arquivo

- `recalcular-orcamento-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-04-recalcular-orcamento-proposta-publica/`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
