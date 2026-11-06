# Solicitacao da Tarefa

## Nome sugerido da tarefa

Levar a lista de servicos do link publico para criar e editar orcamento no painel

## Resumo da solicitacao

No painel, criar e editar orcamento passam a listar os servicos um embaixo do outro, com o texto de obrigatorio quando a obrigacao e por numero de pessoas, e com o campo de horas quando o servico por hora esta marcado. O modelo e o link publico de criar orcamento.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — a quantidade de horas muda o valor da linha do orcamento
- risco principal: a lista mudar so na tela e a edicao continuar gravando a duracao do evento, ou a criacao seguir enviando a duracao inteira no lugar das horas digitadas
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: redesenhar o link publico de criar orcamento e o modal de servicos do link do orcamento; esconder o preco na linha do painel; foto, descricao e icone de detalhe do servico; preco da locacao do espaco; cadastro da regra de obrigatoriedade
- prova minima desta execucao: no painel, criar orcamento mostra cada servico em uma linha; servico obrigatorio a partir de N pessoas mostra esse texto; marcar servico por hora abre o campo de horas e desmarcar esconde; enviar 3 horas grava quantidade 3; servico fixo nao pede horas; editar o mesmo orcamento abre o campo com 3 e salvar 2 grava 2; a API de edicao recusa hora ausente, zero ou maior que a duracao do evento
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se a edicao ja aceitar as horas escolhidas e a mudanca ficar só visual
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `architecture`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/project/project-decisions.md#D-01`
  - `.cursor/framework_core/project/project-decisions.md#D-06`
  - `.cursor/framework_core/project/project-decisions.md#D-07`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/task-requests/horas-servico-por-hora-request.md#Perguntas em aberto`
- caminhos candidatos: lista de servicos ao criar orcamento no painel (evento e pernoite); lista de servicos ao editar orcamento no painel; lista de servicos do link publico de criar orcamento, so como modelo; gravacao das horas na criacao e na edicao do orcamento
- palavras-chave ou simbolos de busca: `PER_HOUR`, `rpaRequired`, `rpaMinPeople`, `serviceHours`, `Obrigatório a partir de`
- testes provaveis: `npm test -- --run` no backend na cotacao e na edicao do orcamento; no painel, criar e editar um orcamento com servico obrigatorio e servico por hora
- nao ler por padrao: `topics/`, specs de outras frentes, contrato, pagamento e e-mail

## Contexto informado na entrada

Pedido em chat, com a tela de criar orcamento do painel aberta. Os servicos aparecem na mesma linha, com o preco entre parenteses. O pedido vale para criar e para editar. A lista deve ficar um servico embaixo do outro, com o texto de obrigatorio quando a obrigacao for por numero de pessoas. Servico por hora, ao ser marcado, pede a quantidade de horas. Esse comportamento ja existe no link de criar orcamento.

## Problema atual

No painel, criar e editar orcamento mostram os servicos lado a lado. Nao ha o texto de obrigatorio por numero de pessoas. Marcar um servico por hora nao pede a quantidade. Na criacao, as horas da linha saem da duracao do evento. Na edicao, a API nao recebe as horas escolhidas e a conta volta a usar essa duracao.

O link publico de criar orcamento ja empilha os servicos, mostra "Obrigatório a partir de N pessoas." e, no servico por hora marcado, pede "Quantas horas?".

## Objetivo da mudanca

Quem cria ou edita um orcamento no painel ve a mesma lista de servicos do link publico: uma linha por servico, o texto de obrigatorio quando houver minimo de pessoas, e o campo de horas quando o servico por hora estiver marcado, com essa quantidade gravada na linha.

## Escopo inicial percebido

As listas de servicos dos formularios de criar orcamento no painel e da tela de editar orcamento. A gravacao precisa usar as horas digitadas na criacao e passar a aceitar essas horas na edicao. Toca `frontend` e `backend` e substitui, no painel, a premissa de que a hora do servico e a duracao do evento.

## Itens incluidos neste request

- servicos um embaixo do outro ao criar e ao editar orcamento no painel
- texto de obrigatorio quando o servico exige um numero minimo de pessoas
- campo de horas visivel so quando o servico por hora esta marcado
- a quantidade digitada entra na linha na criacao e na edicao
- a edicao abre o campo com a quantidade ja gravada
- o servidor da edicao recusa hora ausente ou invalida no servico por hora

## Requisitos implicitos ja visiveis

- o link publico continua sendo o modelo e nao e redesenhado neste pedido
- o preco pode continuar ao lado do nome na linha do painel
- servico fixo e servico por pessoa nao pedem horas
- servico por hora obrigatorio, com o checkbox travado, tambem pede as horas
- quando o numero de convidados atinge o minimo, o servico obrigatorio marca sozinho e trava, como no link publico
- desmarcar o servico esconde o campo e nao envia as horas
- dinheiro continua no tipo ja usado no legado
- horario do evento permanece wall-clock
- a hora digitada na tela nao vale se o servidor nao usar essa quantidade

## Casos de erro e borda ja percebidos

- horas vazias, zero, negativas, fracionadas ou maiores que a duracao do evento: o envio para e o servidor recusa
- desmarcar e marcar de novo: o campo volta vazio
- mudar convidados faz o servico obrigatorio entrar ou sair da selecao travada
- orcamento antigo com servico por hora: a edicao mostra a quantidade ja gravada, sem trocar sozinha pela duracao do evento
- criar nos dois modelos do painel, evento e pernoite: os dois seguem a mesma lista

## Dependencias

- o link publico de criar orcamento ja tem a lista, o texto de obrigatorio e o campo de horas
- o tipo de preco por hora e a regra de obrigatorio a partir de N pessoas ja existem no cadastro do servico
- a criacao do orcamento ja aceita horas escolhidas; o painel hoje envia a duracao do evento
- a edicao do orcamento hoje nao recebe essas horas
- a spec de horas do servico deixou o painel de fora de proposito; este pedido cobre essa parte
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao criar outro tipo de preco
- nao alterar o preco da locacao do espaco
- nao mudar a regra de a partir de quantas pessoas o servico e obrigatorio
- nao esconder o preco nem acrescentar foto ou descricao na linha do painel
- nao ler nem versionar valores de `.env`
- a quantidade de horas e validada no backend, nao so no formulario

## Perguntas em aberto

- O preco some da linha, como no link publico? Premissa: nao. O painel continua mostrando o preco ao lado do nome.
- O checkbox obrigatorio trava ao atingir o minimo de pessoas? Premissa: sim, como no link publico.
- Servico por hora obrigatorio tambem pede horas? Premissa: sim.
- Qual numero de horas vale? Premissa: a mesma regra do link publico, inteiro de 1 ate a duracao do evento.
- A edicao abre com a quantidade gravada? Premissa: sim.
- Os dois formularios de criar no painel entram? Premissa: sim, evento e pernoite. A tela da entrada e a de evento.

## Prioridade sugerida

Media. O padrao ja existe no link publico; o painel ainda cobra a duracao do evento e nao mostra a obrigacao.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: a lista entra em criar e editar no painel, e a quantidade escolhida precisa valer na criacao e passar a ser aceita na edicao. Toca `frontend` e `backend` e substitui, no painel, a premissa ja fechada de que a hora do servico e a duracao do evento. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/lista-servicos-painel-orcamento/`

## Sugestao de nome do arquivo

- `lista-servicos-painel-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-lista-servicos-painel-orcamento/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
