# Solicitacao da Tarefa

## Nome sugerido da tarefa

URL publica do orcamento com o nome da pessoa e um codigo

## Resumo da solicitacao

O link do orcamento que vai para o cliente passa a mostrar o nome da pessoa, no endereco da casa. O nome nao identifica o orcamento. Um codigo curto e aleatorio, no fim da URL, e a chave. Dois clientes com o mesmo nome convivem. O link antigo, com o id, continua abrindo.

## Context Pack

- frente principal: produto (frontend e backend)
- superficie sensivel: sim — a URL publica do orcamento e o acesso ao orcamento; o nome da pessoa fica visivel no link; o codigo nao pode ser um contador adivinhavel
- risco principal: duas pessoas com o mesmo nome cairem no mesmo orcamento, ou um codigo curto demais deixar enumerar orcamentos de uma casa
- repos tocados: `frontend` (`eventhub-vista-dashboard/`), `backend` (`art56_server_v3/`)
- fora de escopo operacional: rotas do painel; formulario e apresentacao do espaco (ja usam o nome da casa); trocar o nome unico do espaco; numerar orcamentos em sequencia (`maria-silva-2`)
- prova minima desta execucao: um orcamento de Maria Silva na AR756 abre em `/espaco/AR756/orcamento/maria-silva-` seguido de um codigo; um segundo orcamento da mesma Maria Silva recebe outro codigo; abrir o primeiro com o nome trocado na URL ainda mostra o primeiro orcamento; `/proposal/{id}/view` de um orcamento ja enviado continua abrindo; `maria-silva-1` nao abre orcamento
- criterio de escalada: promover para `spec` antes de executar; a URL nova, a chave gravada e os links antigos nao cabem numa task isolada
- nivel de autonomia: `L2`
- camadas transversais: `security`, `database`, `design`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `node`, `patterns`, `security`, `database`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/agent-entrypoint.md#Provas`
  - `.cursor/framework_core/project/api-endpoints.md` (rotas publicas de proposta e a nota de que o id e dificil de adivinhar)
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_core/topics/data-and-migrations.md`
- caminhos candidatos: montagem de `/proposal/${proposalId}/view`; `GET /proposal/presentation/:proposalId`; chave publica da casa em `venue-public-key`
- palavras-chave ou simbolos de busca: `completeClientName`, `/proposal/:id/view`, `proposalId`, `isVenueIdKey`
- testes provaveis: dois orcamentos com o mesmo nome de cliente; URL com nome errado e codigo certo; id antigo ainda abre; codigo sequencial nao acha orcamento
- nao ler por padrao: specs da apresentacao publica do orcamento alem do contrato do link publico

## Contexto informado na entrada

Pedido em chat, depois de comparar o link do espaco (`/venue/AR756/form`) com o do orcamento. O orcamento poderia levar o nome da pessoa, mas dois clientes podem ter o mesmo nome.

Decisao fechada no chat, com o primeiro trecho ajustado depois para `espaco`: a URL fica `/espaco/AR756/orcamento/maria-silva-k7m2`. `maria-silva` e o rotulo, vindo do nome gravado. `k7m2` ilustra o codigo, que e a chave. Outra Maria Silva fica `maria-silva-` com outro codigo. Quem abre e reconhecido pelo codigo; nome errado ou editado na URL ainda abre o orcamento certo. O link ja enviado com `/proposal/{id}/view` continua valendo. Sufixo numerado (`maria-silva-2`) foi recusado, porque da para ir tentando.

## Problema atual

O link publico do orcamento e `/proposal/{id}/view`. O id e unico e dificil de adivinhar, e e isso que fecha o acesso. O endereco nao diz de quem e o orcamento. O nome da pessoa nao e unico, entao nao pode substituir o id.

## Objetivo da mudanca

O link enviado ao cliente identifica a casa pelo nome, mostra o nome da pessoa e distingue cada orcamento por um codigo que nao da para adivinhar percorrendo uma sequencia. Um link antigo com o id continua abrindo o mesmo orcamento.

## Escopo inicial percebido

Endereco publico novo do orcamento, gravacao da chave curta e leitura por essa chave, com o id antigo ainda aceito. Toca `frontend` e `backend`. Vira spec.

## Itens incluidos neste request

- URL no formato `/espaco/{nome-do-espaco}/orcamento/{nome-da-pessoa}-{codigo}`
- o nome da pessoa e rotulo, gerado do nome gravado no orcamento
- o codigo e aleatorio, unico e a unica chave nova
- dois orcamentos com o mesmo nome de cliente recebem codigos diferentes
- nome ausente, errado ou editado na URL nao troca o orcamento: vale o codigo
- `/proposal/{id}/view` ja enviado continua abrindo

## Requisitos implicitos ja visiveis

- o nome do espaco na URL e o nome unico que o formulario e a apresentacao ja usam
- espacos e acentos do nome da pessoa saem do rotulo, como em `maria-silva`
- cliente sem nome: a URL leva o codigo, sem inventar um nome
- mudar o nome do cliente depois nao invalida um link ja enviado
- o codigo nao muda quando o nome muda
- o painel interno pode continuar no id

## Casos de erro e borda ja percebidos

- dois clientes com o mesmo nome na mesma casa
- codigo conhecido com o rotulo de outra pessoa na URL
- tentativa `maria-silva-1`, `maria-silva-2`
- orcamento antigo, criado antes do codigo, aberto pelo id
- nome da pessoa vazio ou so com espaco

## Dependencias

- `Venue.name` ja e unico e ja abre formulario e apresentacao
- o acesso publico do orcamento hoje depende de o id ser dificil de adivinhar
- o nome do cliente ja e gravado no orcamento

## Restricoes e cuidados

- nao usar contador nem sufixo sequencial
- nao tratar o nome da pessoa como chave
- nao deixar de abrir links ja enviados com o id
- nao alargar o pacote publico do orcamento
- nao aplicar migration de producao sem aprovacao nomeada
- nao ler nem versionar valores de `.env`
- a derivacao por repositorio pode esperar a spec; se separar antes, usar `tasking/task-request-repo-split-prompt.md`

## Perguntas em aberto

- Nenhuma. Chats seguintes fecharam as palavras da URL publica: `proposal` vira `orcamento` e `venue` vira `espaco`. O tamanho do codigo e as paginas incluidas ficaram na spec.

## Prioridade sugerida

Media. O link do espaco ja e legivel. O do orcamento ainda e o id.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: URL nova, chave gravada, leitura publica e links antigos. Muda o acesso ao orcamento e toca backend e frontend.

## Sugestao de slug da spec

- `framework_core/specs/2026-11-20-url-orcamento-nome-e-codigo/`

## Sugestao de nome do arquivo

- `url-orcamento-nome-e-codigo-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `spec`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-20-url-orcamento-nome-e-codigo/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `opcional`
