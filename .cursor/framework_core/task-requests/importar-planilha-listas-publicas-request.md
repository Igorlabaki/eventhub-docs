# Solicitacao da Tarefa

## Nome sugerido da tarefa

Importar planilha nas listas publicas de convidados e colaboradores

## Resumo da solicitacao

Nas listas publicas de convidados e de colaboradores, o cliente pode enviar um arquivo Excel com nomes. A tela le o arquivo e grava essas pessoas na lista da proposta.

## Context Pack

- frente principal: frontend
- superficie sensivel: sim. As rotas ja sao publicas e ja gravam nome e e-mail; este request passa a aceitar esses dados num arquivo enviado pelo cliente
- risco principal: gravar nome de mais, apagar quem ja estava na lista, ou aceitar um arquivo que nao e uma lista de pessoas
- repos tocados: `frontend` (`eventhub-vista-dashboard/`). `backend` (`art56_server_v3/`) so entra se a gravacao atual nao servir; nesse caso derivar com `tasking/task-request-repo-split-prompt.md`
- fora de escopo operacional: programacao do evento; painel; guardar o arquivo; schema novo; troca da marca das listas
- prova minima desta execucao: em `/proposal/:id/guest-list` e em `/proposal/:id/staff-list`, enviar uma planilha com varios nomes e um e-mail, ver essas pessoas gravadas e ainda na lista depois de recarregar; arquivo sem nome nenhum mostra erro e nao grava; a lista de convidados nao passa das vagas do orcamento; adicionar um nome na mao continua gravando como hoje
- criterio de escalada: promover para `spec` se a leitura exigir contrato novo, schema ou gravacao diferente da que a lista ja usa
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/GuestList.tsx` no adicionar e no salvar da lista
- libs obrigatorias: `react`, `design`, `security`
- documentos obrigatorios: cinco caminhos, cada um `arquivo#secao`
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md#Upload, arquivos ou storage privado`
- caminhos candidatos: listas publicas de convidados e colaboradores; gravacao em lote de pessoas
- palavras-chave ou simbolos de busca: `GuestList`, `WorkerList`, `createManyPersons`, `PersonType.GUEST`, `PersonType.WORKER`, `guestNumber`
- testes provaveis: planilha valida nas duas rotas; arquivo vazio ou sem nome; nome repetido; convidados alem das vagas; colaborador sem teto; um nome digitado na mao
- nao ler por padrao: `database`, `topics/`, schema e o restante do backend, salvo se a gravacao atual nao servir

## Contexto informado na entrada

Pedido em chat. O cliente precisa montar a lista de convidados e a lista de colaboradores. Para facilitar, ele envia um Excel com a lista de nomes; o sistema le o arquivo e salva a lista.

## Problema atual

`/proposal/:id/guest-list` e `/proposal/:id/staff-list` so aceitam um nome por vez, com e-mail opcional. Uma lista grande depende de digitar e adicionar cada pessoa antes de salvar.

## Objetivo da mudanca

Nas duas listas, um arquivo de planilha com nomes e lido e as pessoas novas ficam gravadas na proposta.

## Escopo inicial percebido

As duas paginas publicas que ja existem e ja gravam pessoas. O arquivo e so a entrada dos nomes. A gravacao continua sendo a da lista.

## Itens incluidos neste request

- convidados e colaboradores aceitam o mesmo tipo de arquivo
- o arquivo traz o nome e, se houver, o e-mail
- nomes lidos entram na lista e sao gravados
- quem ja estava salvo permanece
- adicionar, buscar e remover um nome na mao continuam como hoje
- arquivo invalido nao grava ninguem e o cliente ve o motivo

## Requisitos implicitos ja visiveis

- vale para qualquer proposta aberta nessas duas rotas
- nome e obrigatorio; e-mail e opcional, como no formulario atual
- linha em branco nao vira pessoa
- o mesmo nome nao entra duas vezes
- a lista de convidados respeita as vagas do orcamento; colaboradores nao tem esse teto
- o arquivo em si nao fica guardado
- a marca da lista, ja pedida em outro request, nao muda por causa deste

## Casos de erro e borda ja percebidos

- arquivo que nao e planilha, aba vazia ou coluna de nome ausente: nada e gravado e a tela explica
- so a primeira aba entra
- nome repetido no arquivo ou ja presente na lista: entra uma vez
- e-mail ausente: a pessoa entra so com o nome
- convidados alem das vagas: grava ate o limite e avisa o que ficou de fora
- lista de convidados ja cheia: o arquivo nao grava convidado novo
- arquivo grande demais para a tela tratar: a leitura para e nada e gravado

## Dependencias

- as duas listas ja carregam a proposta e ja gravam pessoas novas em lote
- o orcamento ja tem o numero de convidados usado como teto

## Restricoes e cuidados

- nao guardar o arquivo enviado
- nao apagar nem substituir pessoas ja salvas
- nao criar schema se a gravacao atual servir
- nao incluir a programacao do evento
- nao alterar a marca visual das listas
- nome e e-mail continuam dado pessoal em rota publica: nao registrar o conteudo do arquivo em log

## Perguntas em aberto

- O cliente confirma a lista antes de gravar? Premissa: nao. Arquivo valido e lido e gravado em seguida. O nome digitado na mao continua no fluxo atual.
- A planilha substitui quem ja foi salvo? Premissa: nao. So acrescenta pessoas novas.
- Quais colunas? Premissa: nome obrigatorio e e-mail opcional. Sem cabecalho, a primeira coluna e o nome e a segunda, se existir, e o e-mail.
- Quais extensoes? Premissa: `.xlsx`, `.xls` e `.csv`.
- Convidado alem da vaga entra? Premissa: nao. Grava ate as vagas restantes e avisa o restante. Colaborador nao tem esse teto.
- A programacao do evento entra? Premissa: nao.

## Prioridade sugerida

Media. O cliente ja consegue montar as duas listas nome a nome; a planilha encurta esse trabalho.

## Faixa sugerida para task workflow

- `B` — duas telas publicas, leitura de arquivo e dado pessoal; a gravacao da lista ja existe e nao ha schema previsto
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, nas duas listas que ja gravam pessoas; vira spec so se a leitura exigir contrato, schema ou gravacao nova

## Sugestao de slug da spec

- nao se aplica neste recorte; se escalar, `framework_core/specs/2026-11-04-importar-planilha-listas-publicas/`

## Sugestao de nome do arquivo

- `importar-planilha-listas-publicas-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar` a entrega (`fw:review`)
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- status: executado em 2026-11-05; a planilha entra nas duas listas publicas e a gravacao segue o salvamento que ja existia; review de entrega ainda nao rodou
- derivacao repo-local: `opcional`
