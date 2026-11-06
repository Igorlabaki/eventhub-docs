# Tasks — Preco, foto e descricao do servico

## Ordem macro

1. `T-01` schema e formula da linha.
2. `T-02` e `T-03` em paralelo, depois de `T-01`.
3. `T-04` depois de `T-03`.
4. `T-05` depois de `T-02` e `T-03`.

Backend nas tres primeiras. Telas so depois do contrato gravado.

## Tasks

### T-01 - Schema e formula da linha

- objetivo: persistir tipo, descricao e foto no servico, e calcular a linha fixa, por hora e por pessoa num unico lugar.
- cobre requisitos: `R-01`, `R-02`, `R-03`, `R-05`, `R-06`, `R-07`, `R-12`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `calcEventDuration` e o preco minimo que ja soma servico por cima da locacao
- prompt recomendado: `normal`
- estrategia de teste: unitario da formula e `npx prisma validate`
- cenarios obrigatorios:
  - fixo cobra o unitario uma vez
  - por pessoa multiplica pelos convidados
  - por hora multiplica pelas horas de `calcEventDuration`, inclusive fim no dia seguinte
  - duracao 0 gera linha 0
  - id de outro espaco falha e nao devolve linha
  - preco negativo falha; preco zero gera linha 0
- definition of done:
  - migration aditiva com default `FIXED` e colunas novas nulas em `ProposalService`
  - `03-design.md#Contratos e dados` refletido no schema
  - `product/08-data-model.md` ganha uma linha com os campos novos
  - nenhum chamador de orcamento e alterado nesta task

#### Context Pack

- frente principal: backend e banco
- superficie sensivel: sim — valor que depois entra no orcamento
- risco principal: uma segunda formula de hora, diferente de `calcEventDuration`
- repos tocados: `backend`
- fora de escopo desta task: gravar orcamento, upload, tela, permissao
- prova minima desta task: `npx prisma validate` e o unitario dos seis cenarios verde
- criterio de escalada: se a formula precisar de diaria ou de outro relogio, parar e voltar a spec
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `database`, `node`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_core/topics/data-and-migrations.md#Regras`
  - `.cursor/framework_global/framework-libs/database/skills/writing-zero-downtime-migrations.md#1. Classificar a mudanca`
- caminhos candidatos: `art56_server_v3/src/functions/calc-event-duration.ts`, `art56_server_v3/src/repositories/in-prisma/service-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `calcEventDuration`, `getByProposalServiceListTotalAmount`, `pricingType`
- testes provaveis: unitario novo da formula; `npx prisma validate`
- nao ler por padrao: telas, galeria, `01-spec.md` inteiro

### T-02 - Gravar a linha no orcamento

- objetivo: criar, editar e recalcular passam a gravar a linha e a usar a soma dela no total, na mesma transacao.
- cobre requisitos: `R-04`, `R-05`, `R-12`
- depende de: `T-01`
- pode rodar em paralelo com: `T-03`
- reusa: a formula de `T-01`; `createPerPerson`, `createPerDay`, `update` e `updateServices`
- prompt recomendado: `normal`
- estrategia de teste: unitario dos use cases de orcamento que ja cobrem total, mais o recalculo publico
- cenarios obrigatorios:
  - criar por pessoa grava quantidade igual aos convidados e o total inclui essa soma
  - criar ou editar por dia usa as horas do intervalo, nao o numero de diarias, na linha por hora
  - editar convidados ou horario regrava tambem o servico que ja estava ligado
  - recalcular duas vezes com os mesmos dados deixa as mesmas linhas
  - mudar `Service.price` sem save e sem recalculo nao altera o `amount` ja gravado
  - preco minimo continua somando as linhas por cima da locacao
  - permuta continua com total 0
- definition of done:
  - nao resta chamador que monte o total com `_sum` de `price`
  - total e linhas commitam juntos
  - testes dos fluxos citados verdes

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — total do orcamento e recalculo publico
- risco principal: um ramo de criacao ou edicao continuar somando o preco cru
- repos tocados: `backend`
- fora de escopo desta task: upload, formulario, pagina publica, `rpaRequired`
- prova minima desta task: os cenarios obrigatorios verdes em `npm test -- --run` nos specs de proposta tocados
- criterio de escalada: se a transacao exigir reescrever historico, notificacao ou pagamento, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `patterns`, `database`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md`
  - `.cursor/framework_core/project/project-decisions.md#D-06`
- caminhos candidatos: `create-proposal-per-person`, `create-proposal-per-day`, `update-proposal-per-person`, `update-proposal-per-day`, `recalculate-public-proposal`, `proposal-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `getByProposalServiceListTotalAmount`, `totalAmountService`, `applyMinimum`, `proposalServices`
- testes provaveis: specs desses use cases
- nao ler por padrao: cadastro de imagem, `T-04`, `T-05`

### T-03 - Cadastro do servico com permissao e foto

- objetivo: a API grava tipo, descricao e uma foto so para quem tem `EDIT_VENUE_SERVICES` naquele espaco.
- cobre requisitos: `R-06`, `R-07`, `R-08`, `R-09`
- depende de: `T-01`
- pode rodar em paralelo com: `T-02`
- reusa: `VenueRuleAuthorizer` e o upload WebP de `use-cases/image/create-image`
- prompt recomendado: `normal`
- estrategia de teste: unitario do use case de servico com authorizer e arquivo falso
- cenarios obrigatorios:
  - sem `EDIT_VENUE_SERVICES`, criar, atualizar e apagar respondem 403 e nao gravam
  - permissao em outro espaco nao grava neste
  - descricao acima de 500 e preco negativo respondem 400
  - arquivo que nao e imagem, ou acima de 5 MB, nao gera `imageUrl`
  - atualizar sem arquivo mantem a foto; remocao explicita zera `imageUrl`
  - a foto nao cria registro em `Image`
  - nome repetido no espaco continua 409
- definition of done:
  - rotas de escrita seguem autenticadas e passam pelo authorizer
  - `GET /service/list` segue sem autenticacao
  - nenhum valor de `.env` entra em teste ou log

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — upload e autorizacao
- risco principal: gravar foto ou preco sem permissao, ou colocar a foto na galeria da casa
- repos tocados: `backend`
- fora de escopo desta task: orcamento, tela, fechar a listagem publica
- prova minima desta task: os cenarios obrigatorios verdes, incluindo o 403
- criterio de escalada: se o upload precisar de bucket privado ou URL assinada, parar e voltar a spec
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `security`, `aws`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Reuso previsto`
  - `.cursor/framework_core/product/02-business-rules.md#Acesso`
  - `art56_server_v3/src/use-cases/venue-rule/venue-rule-authorizer.ts`
  - `art56_server_v3/src/use-cases/image/create-image/controller-create-image.ts`
- caminhos candidatos: `art56_server_v3/src/router/service.ts`, `art56_server_v3/src/zod/services/`
- palavras-chave ou simbolos de busca: `EDIT_VENUE_SERVICES`, `ensureAuthenticate`, `imageUrl`, `sharp`
- testes provaveis: spec novo ao lado dos use cases de servico
- nao ler por padrao: pagina publica, formularios de orcamento

### T-04 - Formulario e lista de servico no painel

- objetivo: o operador escolhe o tipo de preco, escreve a descricao e envia uma foto no cadastro que ja existe.
- cobre requisitos: `R-01`, `R-07`, `R-11`
- depende de: `T-03`
- pode rodar em paralelo com: `T-02`
- reusa: `service-form`, `service-list`, `service-section` e o store de servico
- prompt recomendado: `smart`
- estrategia de teste: a tela do painel, com um servico de cada tipo
- cenarios obrigatorios:
  - criar fixo, por hora e por pessoa mostra o rotulo do unitario na lista
  - descricao e foto opcionais; sem elas o servico salva
  - editar sem escolher arquivo de novo nao apaga a foto
  - usuario sem permissao de edicao nao envia o formulario
- definition of done:
  - o payload aceita os campos novos e o arquivo
  - nao surge um terceiro jeito de guardar estado no frontend
  - a tela foi exercitada no browser, ou o bloqueio de browser ficou declarado

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — envia arquivo e preco, mas a autorizacao ja ficou em `T-03`
- risco principal: o formulario seguir mandando so nome e preco, e a API recusar ou ignorar o tipo
- repos tocados: `frontend`
- fora de escopo desta task: marcacao dentro do orcamento, pagina publica, galeria da casa
- prova minima desta task: no painel, os tres tipos aparecem na lista com o rotulo certo depois de recarregar
- criterio de escalada: se a tela exigir pagina nova ou permissao nova, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Reuso previsto`
  - `.cursor/framework_global/framework-libs/design/rules/main_index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/components/service/service-form.tsx`, `service-list.tsx`, `src/types/service.ts`, `src/services/service.service.ts`
- palavras-chave ou simbolos de busca: `pricingType`, `rpaRequired`, `EDIT_VENUE_SERVICES`
- testes provaveis: fluxo do formulario no browser
- nao ler por padrao: `security` como lib, use cases de orcamento, `01-spec.md` inteiro

### T-05 - Linha no orcamento e na pagina publica

- objetivo: quem monta o orcamento ve o tipo do servico, e o link mostra a apresentacao e o valor gravado.
- cobre requisitos: `R-10`, `R-11`, `R-12`
- depende de: `T-02`, `T-03`
- pode rodar em paralelo com: nenhuma
- reusa: os cinco formularios que marcam servico, `ProposalServicesSummary`, `ProposalDetails`, `ProposalView`
- prompt recomendado: `normal`
- estrategia de teste: browser no painel e na pagina publica
- cenarios obrigatorios:
  - a marcacao mostra unitario com o tipo, nos formularios do painel e nos publicos
  - um orcamento com os tres tipos mostra as tres linhas calculadas no resumo
  - a experiencia do link mostra foto, nome e descricao; sem foto, o circulo permanece
  - o investimento mostra o valor gravado e a multiplicacao so quando o tipo nao e fixo
  - orcamento antigo sem `amount` mostra o preco do cadastro, sem multiplicacao
  - duracao 0 aparece como linha zero, nao como o unitario da hora
- definition of done:
  - resumo, detalhe e link leem `amount` gravado, com o fallback de `R-12`
  - a pagina publica nao passa a listar servicos que nao estao no orcamento
  - o fluxo foi exercitado no browser, ou o bloqueio ficou declarado

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — valor exibido no link publico
- risco principal: o link mostrar `service.price` no lugar do valor gravado
- repos tocados: `frontend`
- fora de escopo desta task: cadastro do servico, formula do backend, contrato e e-mail
- prova minima desta task: no link, a experiencia tem foto e descricao, e o investimento bate com a linha gravada
- criterio de escalada: se a pagina precisar de endpoint novo ou da tabela de preco da casa, parar
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Falhas, casos de borda e invariantes`
  - `.cursor/framework_core/project/project-decisions.md#D-06`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalView.tsx`, `src/components/proposal/ProposalServicesSummary.tsx`, `src/pages/ProposalDetails.tsx`, formularios `PerPersonProposalForm` e `ClientPerPersonProposalForm`
- palavras-chave ou simbolos de busca: `proposalServices`, `service.price`, `Sua experiência inclui`
- testes provaveis: marcar servicos num orcamento e abrir `/proposal/:id/view`
- nao ler por padrao: upload S3, `T-01`, schema Prisma
