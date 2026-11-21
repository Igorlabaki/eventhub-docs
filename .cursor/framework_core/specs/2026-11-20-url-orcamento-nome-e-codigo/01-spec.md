# URL publica do orcamento

## Problema

O link do orcamento que o cliente recebe e `/proposal/{id}/view`. O id e a chave e e dificil de adivinhar, mas o endereco nao diz de quem e o orcamento e ainda usa a palavra `proposal`. O nome da pessoa nao pode ser a chave: dois clientes podem se chamar Maria Silva.

## Objetivos

Todo link enviado ao cliente comeca em `/espaco/{nome-da-casa}`. O que e da casa usa so o nome. O que e de um orcamento acrescenta o nome da pessoa e o codigo. O link antigo continua abrindo.

## Fora de escopo

- rotas do painel (`/proposal/:id`, edicao, pagamento, documentos, agenda interna)
- caminhos da API (`/proposal/presentation`, `/proposal/byId` e os demais)
- sufixo numerado (`maria-silva-2`)
- aplicar a migration na `main` do PlanetScale
- unificar o dominio dos links (`event-hub-dashboard.vercel.app` permanece onde ja e fixo)

## User stories ou cenarios principais

- O operador copia o link do orcamento da Maria Silva na AR756 e o endereco e `/espaco/AR756/orcamento/maria-silva-` mais o codigo.
- Uma segunda Maria Silva na mesma casa recebe outro codigo e abre outro orcamento.
- O cliente abre o link com o nome errado na URL e ve o orcamento do codigo.
- Um link ja enviado em `/proposal/{id}/...` ou `/venue/{id|nome}/...` continua abrindo.
- Apresentacao, formulario, regras, parceiro e colaborador usam `/espaco/AR756/` e o nome da casa, sem codigo.

## Criterios de aceite

- `R-01`: o link copiado e o destino depois do formulario publico usam `/espaco/{nome-do-espaco}/orcamento/{rotulo}-{codigo}`
- `R-02`: o rotulo sai do nome gravado do cliente; acento e espaco viram `maria-silva`; nome vazio omite o rotulo e a URL fica `/espaco/{nome}/orcamento/{codigo}`
- `R-03`: o codigo tem 8 caracteres do alfabeto `abcdefghjkmnpqrstuvwxyz23456789`, e aleatorio e unico; nao e contador
- `R-04`: dois orcamentos com o mesmo nome de cliente recebem codigos diferentes e abrem orcamentos diferentes
- `R-05`: a leitura usa so o codigo; nome da pessoa ou da casa errado na URL nao troca o orcamento
- `R-06`: `maria-silva-1` e qualquer sufixo que nao seja um codigo valido nao abrem orcamento
- `R-07`: `/proposal/{id}/view`, `/links`, `/guest-list`, `/indications`, `/staff-list`, `/schedule-list`, `/b2b-contract` e `/person-contract` continuam abrindo
- `R-08`: o orcamento e as paginas irmas abrem em `/espaco/{nome}/orcamento/{ref}`, `/evento`, `/convidados`, `/colaboradores`, `/programacao`, `/indicacoes` e `/contrato`
- `R-09`: o painel e a API permanecem em `/proposal/`; a resposta publica nao ganha campo alem do codigo
- `R-10`: orcamento antigo, sem codigo ainda, continua abrindo pelo id
- `R-11`: apresentacao, formulario, regras, parceiro e colaborador abrem em `/espaco/{nome}/apresentacao`, `/formulario`, `/regras`, `/parceiro` e `/colaborador`, com o nome da casa
- `R-12`: `/venue/{nome}/apresentacao`, `/venue/{nome}/form`, `/venue/{id}/rules/view`, `/venue/{id}/partner-form` e `/venue/{id}/crew-form` continuam abrindo
- `R-13`: `/contrato` abre pessoa fisica ou juridica conforme o tipo ja gravado no orcamento

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a URL publica continua sendo o acesso; o codigo substitui o papel do id nesses links e nao pode ser enumeravel
- erros e mensagens esperadas: codigo inexistente mostra a mesma falha de orcamento nao encontrado que o id inexistente
- observabilidade minima: nenhuma metrica nova; o log nao precisa do codigo alem do que a URL ja expoe
- concorrencia, idempotencia ou retry: colisao de codigo na criacao gera outro codigo e grava uma vez
- rollout, fallback ou degradacao: links antigos seguem na rota velha; a coluna nova nasce nula e o id nao depende dela

## Casos de erro e borda obrigatorios

- caso: dois clientes com o mesmo nome
  impacto: um nao pode abrir o orcamento do outro
  cobertura esperada: unitario do gerador e da leitura
- caso: rotulo editado na URL, codigo certo
  impacto: abre o orcamento do codigo
  cobertura esperada: unitario da leitura
- caso: sufixo sequencial ou codigo curto demais
  impacto: nao acha orcamento
  cobertura esperada: unitario da leitura
- caso: id antigo de orcamento sem codigo
  impacto: a pagina publica abre
  cobertura esperada: unitario da leitura por id
- caso: nome do cliente vazio
  impacto: a URL leva so o codigo
  cobertura esperada: unitario do rotulo

## Impacto esperado

Quem recebe o orcamento ve a casa e o proprio nome no endereco. Quem ja tem o link com o id nao perde o acesso.

## Areas impactadas

- `art56_server_v3`: coluna, geracao na criacao, leitura publica por codigo ou id
- `eventhub-vista-dashboard`: rotas publicas, links copiados, redirect do formulario, `PUBLIC_ROUTES`

## Restricoes e cuidados

- nao aplicar a migration na `main` sem aprovacao nomeada
- nao usar o nome da pessoa como chave
- nao colocar o id na URL publica nova
- nao alargar o pacote publico alem do codigo, e so onde o painel precisa montar o link

## Dependencias

- `Venue.name` unico, ja usado em `/venue/AR756/form` e `/venue/AR756/apresentacao`
- `Proposal.completeClientName` e `Proposal.id`
- o acesso publico de hoje depende de o id ser dificil de adivinhar (`project/api-endpoints.md`)

## Mapeamento leve requisito -> task -> prova

- `R-03`, `R-04`, `R-05`, `R-06`, `R-10` -> `T-01` -> unitario
- `R-01`, `R-02`, `R-07`, `R-08`, `R-09`, `R-13` -> `T-02` -> unitario
- `R-11`, `R-12` -> `T-03` -> unitario

## Perguntas em aberto

Nenhuma. Premissas de tamanho do codigo, paginas publicas e painel estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
