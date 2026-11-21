# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abrir as regras publicas pelo nome do espaco

## Resumo da solicitacao

`/espaco/AR756/regras` e o unico link publico da casa que nao mostra o espaco. Em producao a leitura das regras trata o nome como se fosse o id e responde que o espaco nao existe. A pagina fica no logo generico do EventHub, com "Nao foi possivel carregar as regras."

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — leitura publica de regras ja existente; nao pode devolver regra de outro espaco nem campo alem de titulo, texto e ordem
- risco principal: publicar a busca por nome e listar regras de outra casa, ou pintar a pagina com a marca de outro espaco
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: mudar o cadastro de regras no painel; criar outra rota publica; alterar apresentacao, formulario, parceiro ou colaborador; mudar o formato do endereco `/espaco/{nome}/regras`
- prova minima desta execucao: sem login, `https://event-hub-dashboard.vercel.app/espaco/AR756/regras` mostra logo, cores e slogan da AR756 e as 6 regras ja cadastradas, na ordem; `GET /venue-rule/public/AR756` deixa de responder 404; `/venue/{id}/rules/view` continua abrindo a mesma casa; um nome que nao existe nao mostra regras de outra casa
- criterio de escalada: promover para `spec` se a resolucao por nome passar a valer para parceiro e colaborador, ou se a resposta publica ganhar campo novo
- nivel de autonomia: `L2`
- camadas transversais: `design`, `security`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `node`, `react`, `design`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Pedido de orcamento`
  - `.cursor/framework_global/framework-libs/security/index.md`
- caminhos candidatos: `art56_server_v3/src/use-cases/venue-rule/list-public-venue-rule/use-case-list-public-venue-rule.ts`; `art56_server_v3/src/functions/venue-public-key.ts`; `eventhub-vista-dashboard/src/pages/PublicVenueRules.tsx`; `eventhub-vista-dashboard/src/components/proposal/usePublicListVenue.ts`
- palavras-chave ou simbolos de busca: `ListPublicVenueRuleUseCase`, `getPublicId`, `venuePublicKeyWhere`, `usePublicListVenue`, `venueIdForPublicForm`, `listPublic`
- testes provaveis: `art56_server_v3/src/use-cases/venue-rule/venue-rule.spec.ts`; `eventhub-vista-dashboard/src/lib/public-venue-rules.test.ts`
- nao ler por padrao: `database`, pagamento, contrato e o cadastro autenticado de regras

## Contexto informado na entrada

Pedido em chat, com a tela de producao aberta em `event-hub-dashboard.vercel.app/espaco/AR756/regras`. A pagina mostra o logo generico EventHub e "Nao foi possivel carregar as regras." Os outros links publicos da mesma casa abrem.

Conferido no ar, sem login: `GET /venue-rule/public/AR756` responde 404; o mesmo caminho com o id `8159e209-0057-4df3-ae72-855363c3b84e` devolve as 6 regras. `GET /venue/presentation/AR756` e `GET /venue/getById?venueId=AR756` acham a casa pelo nome.

No workspace, a listagem publica ja chama `getPublicId` e a pagina ja aceita o nome da URL em `venueIdForPublicForm`. Essa versao nao e a que responde em producao.

## Problema atual

Quem abre `/espaco/AR756/regras` pede `GET /venue-rule/public/AR756`. A API no ar nao acha a casa, porque trata `AR756` como id. A pagina cai no aviso de falha e descarta a marca: o id da casa nao e o trecho da URL, entao logo, cores e slogan nao entram.

As regras continuam gravadas no id da casa. O endereco antigo com esse id abre as mesmas 6 regras.

## Objetivo da mudanca

Abrir `/espaco/AR756/regras` sem login mostra a marca da AR756 e as regras cadastradas nela.

## Escopo inicial percebido

A leitura publica que ja esta no ar passa a achar o espaco pelo nome ou pelo id, no mesmo criterio da apresentacao, e lista as regras pelo id resolvido. A pagina publica mantem o espaco quando o trecho da URL e o nome. A resposta continua so com titulo, texto e ordem.

O codigo local ja aponta para essa leitura. A prova desta execucao e a pagina de producao, nao só o arquivo.

## Itens incluidos neste request

- a leitura publica de regras em producao acha o espaco por nome ou por id
- a pagina `/espaco/{nome}/regras` mostra logo, cores e slogan dessa casa
- as regras listadas sao as do id resolvido, na ordem
- `/venue/{id}/rules/view` continua abrindo a mesma pagina

## Requisitos implicitos ja visiveis

- a rota publica continua a mesma e sem login
- a resposta publica nao ganha campo
- nome e id da mesma casa mostram as mesmas regras
- a tela autenticada de cadastro nao muda
- o endereco copiado no painel continua `/espaco/{nome}/regras`
- a API sobe antes do frontend, porque a pagina pelo nome depende da leitura nova

## Casos de erro e borda ja percebidos

- casa com regras, aberta pelo nome: a pagina mostra a marca e as regras, na ordem
- casa sem regras, aberta pelo nome: a pagina mostra a marca e o aviso de que ainda nao ha regras
- nome que nao existe: a pagina nao mostra regras de outra casa
- endereco antigo com o id: continua abrindo a mesma casa
- espaco ainda carregando: a pagina nao usa a marca de outro espaco

## Dependencias

- a pagina publica e `GET /venue-rule/public/:venueId` ja existem
- a apresentacao e o `getById` publicos ja resolvem o nome `AR756` em producao
- o formulario publico ja reconhece o espaco pelo nome na URL

## Restricoes e cuidados

- nao alargar o que a leitura publica devolve
- nao criar outra forma de achar o espaco; reusar o criterio que a apresentacao ja usa
- nao tratar o codigo local como prova de producao: o nome ainda responde 404 no ar

## Perguntas em aberto

- Parceiro e colaborador, que tambem usam o nome na URL, entram neste ajuste? Premissa: nao; ficam de fora.
- A tela de regras do painel, em `/venue/{id}/rules`, muda? Premissa: nao; ela ja usa o id do espaco selecionado.

## Prioridade sugerida

Alta. O link que o painel copia abre uma pagina de producao que nao mostra a casa nem as regras cadastradas.

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

## Candidato a spec

- `nao`
- motivo: a pagina publica e a leitura por nome ja existem no workspace; o buraco confirmado e a versao no ar, que ainda trata o nome como id. Nao ha jornada, contrato nem schema novos

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `regras-publicas-pelo-nome-do-espaco-request.md`

## Resultado da execucao

A leitura por nome ja estava no workspace, fora do commit publicado. `ListPublicVenueRuleUseCase` chama `getPublicId`, que usa o mesmo criterio da apresentacao (`venuePublicKeyWhere`): nome unico ou id. A pagina aceita a casa quando a URL traz o nome e o cadastro tem outro id. A resposta continua so com id, titulo, texto e posicao.

O commit em `main` ainda chama `getById` e procura so o id. Por isso a producao segue em 404 para `AR756`. Esse ajuste esta no mesmo arquivo de outras mudancas ainda nao publicadas (links do espaco); nao foi para o ar neste passo.

Prova desta execucao: `vitest` do backend, 7 testes em `venue-rule.spec.ts`; `vitest` do frontend, 8 testes em `public-venue-rules` e `public-venue-presentation`. A pagina `https://event-hub-dashboard.vercel.app/espaco/AR756/regras` continua na versao antiga ate a API subir e, depois, o frontend.

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `opcional`
