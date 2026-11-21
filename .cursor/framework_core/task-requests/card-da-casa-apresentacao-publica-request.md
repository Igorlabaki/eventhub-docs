# Solicitacao da Tarefa

## Nome sugerido da tarefa

Card da casa na apresentacao publica

## Resumo da solicitacao

Na apresentacao publica, o vao entre o video e a foto ganha um card sobre a casa. O card mostra a descricao, o horario, a capacidade, as noites minimas quando houver pernoite, e o bairro com a cidade. O texto curto embaixo do logo passa a ser o slogan.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — `GET` publico da apresentacao passa a devolver horario, capacidade e pernoite; o recorte nao pode levar rua, numero, CEP, e-mail nem dono
- risco principal: o card repetir a descricao no topo, ou a resposta publica incluir endereco completo
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: trocar o texto do topo do orcamento e do formulario publico; card Proposta personalizada; preco, servicos, caracteristicas, WhatsApp e duracao padrao do evento dentro deste card; mapa; rua, numero e CEP
- prova minima desta execucao: sem login, `/venue/:id/apresentacao` mostra o slogan embaixo do logo, o video, o card da casa e depois a foto; o card traz descricao, horario, capacidade, noites minimas so com pernoite, e bairro com cidade; a resposta publica nao inclui rua, numero, CEP nem e-mail
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pacote publico da apresentacao ja devolver slogan, descricao, horario, capacidade, pernoite e bairro com cidade, e a mudanca for so o card
- nivel de autonomia: `L2`
- camadas transversais: `design`, `security`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `node`, `patterns`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/topics/public-pages-and-branding.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: `VenuePresentation.tsx`; card Proposta personalizada em `ProposalView.tsx`; leitura publica da apresentacao do venue; `slogan` e `description` em Configuracoes
- palavras-chave ou simbolos de busca: `soloPhoto`, `Proposta personalizada`, `openingHour`, `closingHour`, `hasOvernightStay`, `maxGuest`, `slogan`
- testes provaveis: ordem dos blocos com video; casa com pernoite e casa sem pernoite; campo vazio some; a resposta publica nao inclui rua, numero, CEP nem e-mail
- nao ler por padrao: spec da apresentacao alem da ordem dos blocos; `topics/pricing-and-proposal-calculation.md`

## Contexto informado na entrada

Pedido em chat, com a apresentacao publica aberta. No orcamento, entre o video e a foto, o card Proposta personalizada mostra o evento. Na apresentacao esse vao esta ocupado por uma foto. O card novo fala da casa. Decisoes fechadas: descricao no card; horario de abertura e fechamento, ou check-in e check-out quando houver pernoite; capacidade; noites minimas so com pernoite; bairro e cidade numa linha. O slogan fica embaixo do logo. A task do slogan parou no schema e no input de Configuracoes e deixou este card de fora.

## Problema atual

A apresentacao nao tem um card da casa entre o video e a foto. A descricao ainda aparece embaixo do logo, no lugar do slogan. Horario, capacidade e noites minimas nao entram na pagina.

## Objetivo da mudanca

Quem abre a apresentacao ve, entre o video e a foto, um card com a descricao e os dados da casa, e o slogan no topo.

## Escopo inicial percebido

Card novo na pagina publica da apresentacao e o recorte publico que alimenta esse card. Toca `frontend` e `backend`. O orcamento publico e o formulario publico nao mudam.

## Itens incluidos neste request

- card da casa em `/venue/:id/apresentacao`, entre o video e a foto, no visual do card da proposta
- titulo com o nome da casa e a descricao no corpo do card
- slogan embaixo do logo nesta pagina; a descricao sai desse lugar
- sem pernoite: horario de abertura e de fechamento
- com pernoite: check-in, check-out e noites minimas
- capacidade, no formato Até N pessoas
- bairro e cidade numa linha
- a leitura publica da apresentacao passa a devolver o que o card usa e ainda nao devolve
- a foto que hoje ocupa o vao continua na pagina, depois do card

## Requisitos implicitos ja visiveis

- campo vazio nao aparece
- casa sem pernoite nao mostra check-in, check-out nem noites minimas
- casa com pernoite nao mostra abertura e fechamento
- slogan vazio: a linha embaixo do logo nao aparece
- descricao vazia: o paragrafo do card nao aparece
- o card da proposta no orcamento permanece como esta
- rua, numero, CEP, e-mail e dono continuam fora da resposta publica
- preco, servicos, caracteristicas e WhatsApp continuam nos blocos que ja existem

## Casos de erro e borda ja percebidos

- sem video: o card fica entre a capa e a foto seguinte
- sem foto: o card permanece e os blocos de imagem vazios continuam ocultos
- descricao, horario e bairro vazios: o card segue com o nome e a capacidade
- noites minimas vazias: a linha nao aparece
- bairro ou cidade ausente: a linha mostra so o que existir
- espaco inexistente: a pagina continua sem dado de outra casa

## Dependencias

- a pagina `/venue/:id/apresentacao` ja existe
- `description`, `slogan`, `maxGuest`, `openingHour`, `closingHour`, `hasOvernightStay`, `checkIn`, `checkOut`, `minimumNights`, `neighborhood` e `city` ja existem no cadastro da casa
- a task do slogan ja gravou a coluna e o input; esta pagina passa a ler o slogan

## Restricoes e cuidados

- nao colocar preco, duracao padrao, servicos, caracteristicas nem WhatsApp neste card
- nao mostrar rua, numero, CEP, e-mail nem proprietarios
- nao trocar o topo do orcamento nem do formulario publico
- nao alterar o card Proposta personalizada
- nao ler nem versionar valores de `.env`
- a rota publica continua publica; o que ela devolve precisa ser o recorte do card

## Perguntas em aberto

- Nenhuma. O card fica so na apresentacao. Orcamento e formulario publico continuam com a descricao embaixo do logo.

## Prioridade sugerida

Media. Completa a apresentacao da casa. O orcamento de um evento continua valendo.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: a pagina publica muda de ordem e a leitura publica passa a devolver horario, capacidade e pernoite. Toca `frontend` e `backend`. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/card-da-casa-apresentacao-publica/`

## Sugestao de nome do arquivo

- `card-da-casa-apresentacao-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-19-card-da-casa-apresentacao-publica/`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `opcional`
