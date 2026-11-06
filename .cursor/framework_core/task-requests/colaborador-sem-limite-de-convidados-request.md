# Solicitacao da Tarefa

## Nome sugerido da tarefa

Liberar colaboradores quando a lista de convidados esta cheia

## Resumo da solicitacao

No link publico da lista de colaboradores, salvar uma pessoa nova falha quando a lista de convidados da proposta ja esta no limite. Colaborador nao usa esse teto.

## Context Pack

- frente principal: backend
- superficie sensivel: sim. A rota publica ja grava nome e e-mail; este request muda quem essa gravacao aceita
- risco principal: afrouxar a regra e deixar convidado passar do numero do orcamento, ou continuar recusando colaborador
- repos tocados: `backend` (`art56_server_v3/`). `frontend` (`eventhub-vista-dashboard/`) e a tela onde o cliente prova o salvar; derivar com `tasking/task-request-repo-split-prompt.md` so se a pagina tambem barrar o colaborador
- fora de escopo operacional: teto proprio de colaborador; mudar o limite de convidados; planilha; marca da lista; schema
- prova minima desta execucao: com a lista de convidados ja no numero do orcamento, em `/proposal/:id/staff-list` adicionar um colaborador, salvar e ve-lo na lista depois de recarregar; em `/proposal/:id/guest-list` um convidado a mais continua recusado; o colaborador salvo nao ocupa vaga de convidado
- criterio de escalada: promover para `spec` se a correcao exigir contrato novo, schema ou regra de vaga diferente da que a lista ja usa
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `art56_server_v3/src/use-cases/person/create-many-person/use-case-create-many-person.ts` na recusa por vaga de convidado
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/node/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: gravacao de uma pessoa e gravacao em lote; pagina publica de colaboradores
- palavras-chave ou simbolos de busca: `guestNumber`, `PersonType.WORKER`, `PersonType.GUEST`, `createMany`, `Nao ha mais vaga na lista de convidados`, `staff-list`
- testes provaveis: colaborador grava com a lista de convidados cheia; convidado alem da vaga continua recusado; colaborador nao reduz vaga de convidado; lista de convidados ainda com vaga continua aceitando convidado
- nao ler por padrao: `database`, `design`, `topics/` e schema; nao ha mudanca de tabela nem de tela

## Contexto informado na entrada

Pedido em chat. No link da lista de colaboradores, quando a lista de convidados esta cheia, nao da para adicionar colaborador. Essa lista nao deveria usar o limite de convidados.

## Problema atual

A gravacao de pessoa da proposta recusa o lote inteiro quando o numero de convidados ja e igual ao do orcamento. A mensagem e a de lista de convidados sem vaga. O link de colaboradores cai nessa recusa mesmo quando so envia colaborador.

## Objetivo da mudanca

Com a lista de convidados cheia, um colaborador novo grava e permanece na lista da proposta.

## Escopo inicial percebido

A gravacao publica de pessoas da proposta, no caminho que a lista de colaboradores ja usa. O limite de convidados continua valendo so para convidado.

## Itens incluidos neste request

- colaborador grava com a lista de convidados no limite
- convidado alem do numero do orcamento continua recusado
- colaborador nao consome vaga de convidado
- adicionar, buscar e remover na mao continuam como hoje

## Requisitos implicitos ja visiveis

- vale para o link publico de qualquer proposta
- nome continua obrigatorio e e-mail opcional
- a mesma regra vale para um colaborador e para varios no mesmo salvar
- a lista de convidados ja cheia nao ganha convidado novo por causa deste request

## Casos de erro e borda ja percebidos

- lista de convidados cheia e salvar so colaborador: grava
- lista de convidados cheia e salvar convidado: continua recusado, com o aviso de vaga
- lista de convidados ainda com vaga: convidado e colaborador gravam como hoje
- lote com os dois tipos e convidados ja no limite: colaborador grava; convidado novo nao entra
- colaborador salvo nao aparece como convidado nem reduz as vagas restantes

## Dependencias

- as duas listas ja gravam pessoas novas em lote
- o orcamento ja tem o numero de convidados usado como teto
- o pedido de planilha em `task-requests/importar-planilha-listas-publicas-request.md` ja assume que colaborador nao tem esse teto; este request nao implementa a planilha

## Restricoes e cuidados

- nao criar teto de colaborador
- nao aumentar nem remover o limite de convidados
- nao criar schema
- nao alterar a marca das listas
- nome e e-mail continuam dado pessoal em rota publica: nao registra-los em log

## Perguntas em aberto

- Colaborador passa a ter um teto proprio? Premissa: nao.
- Convidado alem da vaga passa a entrar? Premissa: nao.
- Lista de convidados ja acima do numero tambem pode barrar colaborador? Premissa: nao. Nenhum estado da lista de convidados impede gravar colaborador.
- Um lote com convidado e colaborador, sem vaga de convidado, grava os dois? Premissa: nao. Grava o colaborador e recusa o convidado novo.

## Prioridade sugerida

Alta. Com a lista de convidados cheia, o cliente nao consegue montar a equipe pelo link.

## Faixa sugerida para task workflow

- `A` — uma regra ja existente na gravacao; sem tela nova e sem schema
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: um objetivo, na gravacao que a lista de colaboradores ja usa; vira spec so se a correcao exigir contrato, schema ou outra regra de vaga

## Sugestao de slug da spec

- nao se aplica neste recorte; se escalar, `framework_core/specs/2026-11-05-colaborador-sem-limite-de-convidados/`

## Sugestao de nome do arquivo

- `colaborador-sem-limite-de-convidados-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
