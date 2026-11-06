# Solicitacao da Tarefa

## Nome sugerido da tarefa

Remover a estrutura de Firebase

## Resumo da solicitacao

O EventHub deixa de usar Firebase. O push que hoje roda ao criar orcamento sai do fluxo, e o formulario publico volta a concluir o envio. A notificacao gravada no banco, visivel no painel, permanece.

## Context Pack

- frente principal: backend
- superficie sensivel: sim (credencial de conta de servico e rota publica de criacao de orcamento)
- risco principal: apagar o aviso do painel junto com o push, ou deixar a conta de servico no repositorio
- repos tocados: `backend` (`art56_server_v3/`); `frontend` (`eventhub-vista-dashboard/`) so se o tipo `fcmToken` existir apenas por causa do Firebase
- fora de escopo operacional: Web Push e chaves `VAPID_*`; a notificacao de orcamento gravada no banco; apagar a coluna `User.fcmToken`; revogar a chave no console do Firebase
- prova minima desta execucao: no link publico de criacao, **Enviar** conclui sem o erro `Service account object must contain a string "project_id" property`; busca no backend nao encontra `firebase-admin` nem `FirebaseNotificationService`
- criterio de escalada: promover para `spec` se a execucao for apagar a coluna `fcmToken` ou remover tambem o Web Push
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
- libs obrigatorias: `node`, `patterns`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/node/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: criacao de orcamento por pessoa; servico e config de Firebase; rota de atualizacao de token FCM; login
- palavras-chave ou simbolos de busca: `FirebaseNotificationService`, `firebase-admin`, `fcmToken`, `FIREBASE_PROJECT_ID`, `sendNotificationToAdmins`
- testes provaveis: `npm test -- --run` no backend; enviar o formulario publico de orcamento e confirmar que a resposta deixa de ser 500 por conta de servico
- nao ler por padrao: `database` (nao ha migration), `design`, Web Push, pagamento

## Contexto informado na entrada

No chat, o link publico de criacao de orcamento falhou ao clicar em **Enviar** com erro de conta de servico sem `project_id`. O dono pediu para remover toda a estrutura de Firebase, porque nao vai mais usar.

## Problema atual

Depois de gravar o orcamento, a criacao chama o Firebase para avisar administradores. A credencial nao tem `project_id`, a API responde 500 e o formulario mostra erro, embora o orcamento possa ja ter sido salvo.

## Objetivo da mudanca

Criar um orcamento pelo link publico conclui sem inicializar Firebase, e o repositorio nao conserva servico, config, rota nem dependencia dessa conta.

## Escopo inicial percebido

Remocao da integracao de push Firebase no `backend`, inclusive a chamada na criacao do orcamento e a rota que guarda token. O painel so entra se ainda carregar o campo de token sem outro uso. Nao ha schema novo.

## Itens incluidos neste request

- tirar a inicializacao e o envio Firebase da criacao de orcamento
- tirar servico, config, JSON da conta de servico, utilitario de push e rota de token FCM
- tirar a dependencia `firebase-admin` e os nomes `FIREBASE_*` do exemplo de ambiente
- limpar no `frontend` o campo opcional de token, se ele so existir para o Firebase

## Requisitos implicitos ja visiveis

- a notificacao do orcamento continua sendo gravada para o sino do painel
- a rota publica de criacao permanece publica de proposito
- nao ler, imprimir nem versionar valores de `.env` nem o conteudo do JSON da conta
- o arquivo da conta de servico sai do repositorio; a revogacao no console fica com o dono
- a coluna `User.fcmToken` permanece; nao criar migration

## Casos de erro e borda ja percebidos

- **Enviar** no link publico nao pode falhar por ausencia de credencial Firebase
- orcamento criado no meio da falha atual pode ja existir; a correcao nao duplica nem apaga esses registros
- login nao depende do token Firebase; o trecho que o gravava ja esta inativo
- Web Push continua podendo existir sem o Firebase

## Dependencias

- nenhuma dependencia externa nova
- criacao de orcamento e notificacao no banco ja existem
- mudanca pode tocar os dois repos; se o `frontend` entrar, o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`

## Restricoes e cuidados

- nao remover o Web Push
- nao apagar a notificacao gravada na criacao do orcamento
- nao dropar `User.fcmToken`
- nao abrir nem copiar o JSON da conta de servico nem o `.env`
- tratar o JSON versionado como incidente de credencial: remover o arquivo e avisar o dono para revogar a chave, sem reproduzir o conteudo

## Perguntas em aberto

- A coluna `User.fcmToken` sai do banco? Premissa: nao. Fica sem uso, sem migration.
- O Web Push sai junto? Premissa: nao. So o Firebase sai.
- O sino do painel continua ao criar orcamento? Premissa: sim, pela notificacao gravada no banco.
- O tipo `fcmToken` do painel sai nesta entrega? Premissa: sim, se nao tiver outro uso.

## Prioridade sugerida

Alta. O link publico de criacao de orcamento responde erro ao enviar.

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

## Candidato a spec

- `nao`
- motivo: e a retirada de uma integracao ja decidida, com um objetivo verificavel e sem jornada, contrato nem migration novos

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `remover-firebase-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
- status: implementado no `backend` e no tipo do `frontend`; aguardando revisao da entrega
- prova executada: o servidor local registrou criacao de orcamento com `Orçamento criado com sucesso`, sem o erro de `project_id`; busca em `src` nao encontra `firebase-admin` nem `FirebaseNotificationService`
