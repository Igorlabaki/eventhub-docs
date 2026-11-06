# Solicitacao da Tarefa

## Nome sugerido da tarefa

E-mail opcional na criacao do orcamento

## Resumo da solicitacao

O dono do espaco cria um orcamento no painel sem ser obrigado a informar e-mail. No link enviado ao cliente para preencher os dados do contrato, o e-mail continua obrigatorio e valido.

## Context Pack

- frente principal: produto (backend e frontend)
- superficie sensivel: sim (e-mail de cliente e gravacao em rota publica do contrato)
- risco principal: gravar orcamento sem e-mail e o cliente concluir o contrato sem endereco, ou o inverso, bloquear a criacao do dono
- repos tocados: `backend` (`art56_server_v3/`), `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: tornar WhatsApp opcional; alterar o pedido publico de orcamento no site; mudar o envio do orcamento por e-mail; alterar o texto do contrato alem de passar a guardar o e-mail informado pelo cliente
- prova minima desta execucao: no painel, o dono salva um orcamento com o e-mail em branco; nos links de pessoa fisica e pessoa juridica, o cliente nao salva sem e-mail valido e, com e-mail valido, o valor fica no orcamento
- criterio de escalada: a spec e o caminho; voltar para `normal` somente se o pedido for reduzido a afrouxar a validacao do painel sem mexer na coluna nem no link do contrato
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `database`, `design`, `patterns`, `node`, `react`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/database/index.md`
  - `.cursor/framework_global/framework-libs/security/index.md`
  - `.cursor/framework_global/framework-libs/patterns/index.md`
- caminhos candidatos: criacao de orcamento no painel; links publicos de dados do contrato (`person-contract` e `b2b-contract`); atualizacao dos dados pessoais do orcamento
- palavras-chave ou simbolos de busca: `Proposal`, `email`, `updatePersonalInfo`, `person-contract`, `b2b-contract`
- testes provaveis: `npx prisma validate` no backend; criar orcamento no painel sem e-mail; tentar salvar o link do contrato sem e-mail e com e-mail valido
- nao ler por padrao: pagamento, Asaas, site publico de pedido de orcamento, envio de e-mail do orcamento

## Contexto informado na entrada

Pedido em chat: como dono do espaco, criar orcamento sem ser obrigado a colocar e-mail. No link enviado ao cliente para preencher os dados do contrato, o e-mail deve ser obrigatorio.

## Problema atual

O e-mail do orcamento e obrigatorio na criacao, inclusive quando o dono do espaco preenche o painel. O cliente ainda nao informa e-mail no link dos dados do contrato.

## Objetivo da mudanca

O dono salva um orcamento no painel com o e-mail em branco, e o cliente so conclui os dados do contrato depois de informar um e-mail valido.

## Escopo inicial percebido

A mesma coluna de e-mail do orcamento passa a aceitar ausencia. A criacao pelo painel deixa de exigir o campo. Os dois links publicos de dados do contrato passam a exige-lo e a grava-lo. Toca `backend` e `frontend` e pede migration aditiva.

## Itens incluidos neste request

- e-mail opcional na criacao do orcamento pelo dono, nos dois modos do painel
- e-mail obrigatorio e valido nos links de pessoa fisica e pessoa juridica
- persistir o e-mail informado nesses links no orcamento
- coluna do orcamento capaz de ficar sem e-mail

## Requisitos implicitos ja visiveis

- campo vazio na criacao nao grava texto vazio no lugar de ausencia
- e-mail preenchido, no painel ou no link, continua tendo de ser valido
- a gravacao do link publico passa pelo backend; a tela nao substitui a validacao da API
- a migration de producao e aditiva
- o frontend nao cria uma terceira forma de estado alem das que o projeto ja usa
- rota publica do contrato permanece publica de proposito e a gravacao de e-mail nela e intencional

## Casos de erro e borda ja percebidos

- dono deixa o e-mail em branco: o orcamento e criado
- dono informa e-mail invalido: a criacao nao salva
- cliente abre o link sem e-mail: nao salva
- cliente informa e-mail invalido: nao salva
- dono ja tinha preenchido e-mail: o link pode mostrar o valor, e o cliente ainda nao salva em branco
- orcamento antigo com e-mail: continua valido

## Dependencias

- nenhuma dependencia externa
- orcamento, criacao no painel e links de dados do contrato ja existem
- mudanca multi-repo: o request pode ser derivado depois com `tasking/task-request-repo-split-prompt.md`, de preferencia depois da spec

## Restricoes e cuidados

- nao tornar o WhatsApp opcional
- nao afrouxar o e-mail no pedido publico de orcamento feito pelo site
- nao tratar o envio do orcamento por e-mail nesta entrega
- nao ler nem versionar valores de `.env`
- e-mail e dado pessoal; a rota do contrato grava esse dado sem login do cliente

## Perguntas em aberto

- O pedido de orcamento feito pelo cliente no site continua exigindo e-mail? Premissa: sim.
- A edicao do orcamento no painel tambem aceita e-mail vazio? Premissa: sim, para o orcamento criado sem e-mail poder ser salvo de novo.
- O que gravar quando o campo vier vazio? Premissa: ausencia, nao texto vazio.
- O link do contrato mostra o e-mail ja preenchido pelo dono? Premissa: sim, e o cliente nao pode apagar e salvar.

## Prioridade sugerida

Media. E ajuste do fluxo comercial do orcamento, sem correcao de falha que ja impeça a criacao.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o pedido muda a mesma regra nos dois repositorios, altera persistencia e separa a criacao do painel dos links publicos do contrato. Nao e seguro executar como uma task isolada.

## Sugestao de slug da spec

- `framework_core/specs/email-opcional-orcamento/`

## Sugestao de nome do arquivo

- `email-opcional-orcamento-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-02-email-opcional-orcamento/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `necessaria`
