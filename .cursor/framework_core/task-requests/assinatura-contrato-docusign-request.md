# Solicitacao da Tarefa

## Nome sugerido da tarefa

Assinar o contrato da proposta no DocuSign

## Resumo da solicitacao

Na tela de contrato da proposta, o operador envia o PDF que o painel ja gera. O cliente assina pelo e-mail do DocuSign, sem criar conta. Quando a assinatura termina, a proposta mostra o contrato assinado.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim — segredo da conta DocuSign, PDF com dado pessoal do cliente e, na volta da assinatura, webhook
- risco principal: vazar a chave privada ou o token, enviar o contrato de uma proposta para o e-mail de outra, ou marcar como assinado sem o PDF voltar
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: cada organizacao conectar a propria conta DocuSign; assinatura embutida dentro do EventHub; templates DocuSign; segunda assinatura do espaco; ida para producao (go-live)
- prova minima desta execucao: na tela de contrato de uma proposta com e-mail do cliente, Enviar abre um envelope no sandbox e o cliente recebe o convite; a proposta mostra enviado; ao assinar no sandbox, a proposta mostra assinado e o PDF assinado fica nos documentos daquela proposta; proposta sem e-mail nao envia
- criterio de escalada: ja e `spec`; a faixa nao desce, porque o fluxo cruza os dois repositorios, segredo e o retorno da assinatura
- nivel de autonomia: `L2`
- camadas transversais: `security`, `database`, `design`, `observability`, `patterns`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `node`, `patterns`, `react`, `design`, `security`, `database`, `aws`, `observability`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
  - `docs/planos/PLANO_INTEGRACAO_DOCUSIGN.md`
- caminhos candidatos: tela de contrato da proposta; geracao do PDF no browser; envio do PDF por e-mail; documentos da proposta no S3; cifragem ja usada no Google Calendar
- palavras-chave ou simbolos de busca: `generateContractPdf`, `send-contratct-to-email`, `ProposalContract`, `Document`, `EncryptionService`
- testes provaveis: enviar com e-mail valido; recusar proposta sem e-mail; nao devolver segredo na resposta; so depois da assinatura o documento assinado aparece na proposta
- nao ler por padrao: `.env`, valores de chave, topics de agenda e de relatorio

## Contexto informado na entrada

Pedido em chat para integrar o EventHub ao DocuSign e assinar os documentos. Ficou fechado: uma conta DocuSign do proprio EventHub, no sandbox, com JWT. O cliente nao tem conta e nao entra no painel para assinar; recebe o e-mail do DocuSign. O operador tambem nao faz login no DocuSign a cada contrato. O app no sandbox ja existe (integracao privada, par RSA gerado). As variaveis ja foram colocadas no `.env` local da API, sem entrar no git: `DOCUSIGN_INTEGRATION_KEY`, `DOCUSIGN_USER_ID`, `DOCUSIGN_API_ACCOUNT_ID`, `DOCUSIGN_RSA_PRIVATE_KEY`, `DOCUSIGN_OAUTH_BASE_URL`, `DOCUSIGN_BASE_URL`, `DOCUSIGN_REDIRECT_URI`.

O plano em `docs/planos/PLANO_INTEGRACAO_DOCUSIGN.md` descreve o mesmo fluxo de envelope, webhook e PDF assinado, mas ainda fala em conta por organizacao. Nesta entrada a conta e uma so.

## Problema atual

O contrato da proposta vira um PDF no navegador e sai por e-mail pedindo que o cliente assine e devolva uma copia. Nao ha estado de enviado nem de assinado, e o PDF assinado nao volta para os documentos da proposta.

## Objetivo da mudanca

Na tela de contrato da proposta, o operador envia o PDF ao cliente pelo DocuSign e, quando o cliente assina, a proposta mostra o contrato assinado daquela proposta.

## Escopo inicial percebido

O envio usa o PDF que a tela ja gera e a conta unica do sandbox. A proposta passa a mostrar o estado do envelope. Quando o DocuSign confirma a assinatura, o PDF assinado entra nos documentos da proposta. O plano antigo serve de referencia do fluxo, nao da decisao de uma conta por organizacao.

## Itens incluidos neste request

- enviar o contrato da proposta pelo DocuSign, a partir da tela de contrato
- o signatario e o cliente da proposta, pelo e-mail e pelo nome que ela ja tem
- a proposta mostra enviado e, depois, assinado
- o PDF assinado fica nos documentos daquela proposta
- nomes das variaveis no `.env.example`, sem valor

## Requisitos implicitos ja visiveis

- o segredo fica no servidor; a resposta da API nao devolve chave, token nem a chave privada
- o webhook, se existir neste fluxo, nao usa login de usuario; a autenticidade vem da assinatura do DocuSign
- so quem ja pode enviar documento da proposta envia o contrato
- o PDF de uma proposta nao sai para o e-mail de outra
- a conta e a do sandbox ate haver pedido explicito de producao

## Casos de erro e borda ja percebidos

- proposta sem e-mail: nao envia
- DocuSign recusa o envelope: a proposta nao fica como enviada
- cliente recusa ou o envelope e cancelado: a proposta nao fica como assinada
- aviso de assinatura repetido: nao grava o documento duas vezes
- falha ao guardar o PDF assinado: a proposta nao fica como assinada

## Dependencias

- o PDF do contrato ja e gerado na tela da proposta
- o cliente da proposta ja tem nome e pode ter e-mail
- a conta sandbox e o consentimento JWT ja foram criados pelo operador
- os nomes das variaveis acima ja estao no `.env` local

## Restricoes e cuidados

- nao ler, imprimir nem versionar valores de `.env`
- nao colocar a chave privada no frontend nem no git
- nao abrir login do DocuSign para o operador nem para o cliente
- nao trocar o modelo de clausulas nem o jeito como o PDF e montado, alem do necessario para enviar o arquivo que ja existe
- migration em producao, se houver, e aditiva

## Perguntas em aberto

- Quem assina alem do cliente? Premissa: so o cliente da proposta.
- A assinatura abre dentro do EventHub? Premissa: nao; o cliente usa o e-mail do DocuSign.
- Cada organizacao conecta a propria conta? Premissa: nao; uma conta do EventHub.
- O plano antigo manda no desenho? Premissa: nao na parte de conta por organizacao; sim como referencia do envio, do retorno e do PDF assinado.
- Producao entra nesta feature? Premissa: nao; sandbox ate um pedido separado.

## Prioridade sugerida

Media. O envio por e-mail com pedido de assinatura manual continua no ar.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: e uma integracao nova. Cruza `backend` e `frontend`, guarda segredo, manda dado pessoal do cliente e so fecha quando o retorno da assinatura grava o PDF. Isso se quebra em envio, estado na proposta e documento assinado.

## Sugestao de slug da spec

- `framework_core/specs/assinatura-contrato-docusign/`

## Sugestao de nome do arquivo

- `assinatura-contrato-docusign-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-05-assinatura-contrato-docusign/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
