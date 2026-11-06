# E-mail opcional na criacao do orcamento

## Problema

O dono do espaco nao consegue criar um orcamento no painel sem e-mail. O link em que o cliente preenche os dados do contrato nao pede e-mail.

## Objetivos

- o dono salva o orcamento no painel com o e-mail em branco
- o cliente so conclui o link do contrato com um e-mail valido, gravado no orcamento

## Fora de escopo

- tornar WhatsApp opcional
- afrouxar o e-mail no pedido de orcamento feito pelo cliente no site
- envio do orcamento ou do contrato por e-mail
- texto ou PDF do contrato
- criar login no link do contrato
- autenticar rotas de criacao que hoje ja sao publicas

## User stories ou cenarios principais

- dono cria orcamento por dia ou por pessoa sem e-mail e o registro existe
- dono informa e-mail valido na criacao e esse valor fica gravado
- cliente abre o link de pessoa fisica ou pessoa juridica, informa e-mail valido e o orcamento passa a ter esse e-mail
- cliente tenta salvar o link sem e-mail, ou com e-mail invalido, e nada e gravado

## Criterios de aceite

- `R-01`: criacao por dia no painel com e-mail em branco grava o orcamento sem e-mail
- `R-02`: criacao por pessoa no painel com e-mail em branco grava o orcamento sem e-mail
- `R-03`: e-mail preenchido e invalido na criacao ou na edicao do painel nao salva
- `R-04`: e-mail valido informado na criacao do painel fica gravado
- `R-05`: edicao do orcamento no painel salva com o e-mail em branco
- `R-06`: o link de pessoa fisica nao salva sem e-mail valido
- `R-07`: o link de pessoa juridica nao salva sem e-mail valido
- `R-08`: e-mail valido enviado pelo link fica gravado no orcamento
- `R-09`: o pedido de orcamento no site continua exigindo e-mail valido
- `R-10`: a coluna passa a aceitar ausencia; orcamento antigo com e-mail permanece
- `R-11`: `PUT /proposal/updatePersonalInfo` rejeita e-mail ausente ou invalido
- `R-12`: WhatsApp continua obrigatorio na criacao do painel

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: o link segue publico, como hoje; a validacao do e-mail e da API, nao so da tela. Nao ha permissao nova
- erros e mensagens esperadas: "E-mail invalido" ou "E-mail e obrigatorio", no campo; falha de API no formato ja usado `{ title, message }`
- observabilidade minima: nenhum log, metrica ou URL com o e-mail
- concorrencia, idempotencia ou retry: reenvio do link sobrescreve o e-mail; sem fila nem retry novo
- rollout, fallback ou degradacao: a coluna anulavel sai antes da tela; o endurecimento do link sai junto com os formularios que gravam dados pessoais

## Casos de erro e borda obrigatorios

- caso: dono deixa o campo vazio ou so com espacos
  impacto: o orcamento e criado ou editado sem e-mail
  cobertura esperada: `T-02`, `T-03`
- caso: dono ou cliente informa texto que nao e e-mail
  impacto: a tela nao envia e a API rejeita
  cobertura esperada: `T-02`, `T-03`, `T-04`
- caso: o dono ja tinha preenchido e-mail e o cliente apaga o campo no link
  impacto: o link nao salva
  cobertura esperada: `T-04`
- caso: chamada direta a `updatePersonalInfo` sem e-mail
  impacto: a API rejeita e o e-mail anterior permanece
  cobertura esperada: `T-04`
- caso: orcamento antigo com e-mail
  impacto: o valor continua e o link pode mostra-lo preenchido
  cobertura esperada: `T-01`, `T-04`

## Impacto esperado

Criar orcamento no painel deixa de depender de e-mail. O e-mail do cliente passa a ser coletado quando ele preenche o contrato.

## Areas impactadas

- `backend`: `Proposal.email`, criacao, edicao e `updatePersonalInfo`
- `frontend`: formularios de criacao e edicao do painel; links `person-contract` e `b2b-contract`; formularios internos que salvam os mesmos dados pessoais

## Restricoes e cuidados

- e-mail e dado pessoal; nao entra em log nem na URL
- migration de producao e aditiva e usa `prisma migrate deploy`
- o frontend nao cria outra forma de estado
- `project-decisions.md` D-05: a tela publica nao substitui a validacao da API

## Dependencias

- orcamento, painel e links de contrato ja existem
- nenhuma dependencia externa
- execucao multi-repo: derivar com `spec-driven/spec-repo-split-prompt.md` se for repo-local

## Mapeamento leve requisito -> task -> prova

- `R-10` -> `T-01` -> integracao (`prisma validate` e SQL anulavel)
- `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-09`, `R-12` -> `T-02` -> unitario
- `R-01`, `R-02`, `R-03`, `R-04`, `R-05`, `R-09`, `R-12` -> `T-03` -> e2e manual no painel
- `R-06`, `R-07`, `R-08`, `R-11` -> `T-04` -> unitario e e2e manual nos dois links

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
