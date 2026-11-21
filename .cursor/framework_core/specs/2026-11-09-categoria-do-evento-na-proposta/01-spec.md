# Spec — Categoria do evento na proposta

## Problema

O select "Tipo do aluguel" grava `Proposal.type` (`EVENT`, `OVERNIGHT`, `PRODUCTION`, `BARTER`, `OTHER`), que diz a modalidade. Nao existe campo para a ocasiao do evento. Quando o cliente diz que e aniversario ou confraternizacao de empresa, isso fica no texto livre de `description`, sem como exibir, filtrar ou contar.

## Objetivos

- gravar a categoria do evento em toda proposta nova de tipo Evento
- pedir a categoria nos formularios de criacao do painel, na edicao e no formulario publico
- mostrar a categoria junto do tipo no detalhe da proposta
- manter propostas antigas validas sem preenchimento retroativo

## Fora de escopo

- mudar, renomear ou ampliar `ProposalType`, `DateEventType` ou `NotificationType`
- backfill de categoria nas propostas existentes
- filtro, KPI ou grafico por categoria (lista de orcamentos, relatorios, visao geral)
- categoria no link publico da proposta (`/proposal/:id/view`) e na `BudgetSidebar`
- categorias configuraveis por espaco
- a tela mock `NewBudget.tsx` (`/venue/:id/new-budget`), que nao chama a API
- corrigir o controller de create por pessoa para usar o resultado do parse (ver `03-design.md#Decisoes arquiteturais importantes`)

## User stories ou cenarios principais

- A equipe cria um orcamento em `/venue/:id/budgets`, escolhe tipo Evento e precisa escolher a categoria antes de salvar.
- A equipe escolhe tipo Producao; o campo de categoria some e nada e gravado nele.
- O cliente preenche o formulario publico e escolhe a categoria no passo dos dados do evento.
- A equipe edita uma proposta antiga de Evento; o formulario pede a categoria para salvar.
- A equipe abre o detalhe e le `Evento · Aniversário`.

## Criterios de aceite

- `R-01`: `Proposal.eventCategory` e o enum Prisma `EventCategory`, opcional e sem default, com exatamente `CORPORATE`, `BIRTHDAY`, `BACHELOR_PARTY`, `WEDDING`, `COFFEE_BREAK` e `OTHER`. A migration so adiciona a coluna; nenhuma linha existente e alterada.
- `R-02`: criar proposta (por pessoa ou por dia) com `type = EVENT` sem `eventCategory`, ou com valor fora da lista, responde 400 com a mensagem "Selecione a categoria do evento" e nao grava.
- `R-03`: criar proposta com `type` diferente de `EVENT` grava `eventCategory = null`, mesmo que o payload traga um valor.
- `R-04`: atualizar proposta (por pessoa ou por dia) aplica a mesma regra de `R-02` e `R-03`: `EVENT` exige valor da lista; outro tipo grava `null`.
- `R-05`: a regra vale nas quatro rotas mesmo que o controller nao use o resultado do parse Zod (ela mora no use case).
- `R-06`: `GET` da proposta devolve `eventCategory` (`null` nas antigas) sem quebrar o painel.
- `R-07`: nos formularios do painel (`PerPersonProposalForm`, `PerDayProposalForm`, `ProposalEdit`), o select "Categoria do evento" aparece so com tipo Evento, e obrigatorio nesse caso e e limpo ao trocar para outro tipo. O payload envia `null` quando o tipo nao e Evento.
- `R-08`: nos formularios publicos (`ClientPerPersonProposalForm`, `ClientPerDayProposalForm`), o select aparece sempre (o tipo e fixo `EVENT`), no passo dos dados do evento, e o passo nao avanca sem ele.
- `R-09`: os rotulos sao, nesta ordem: Empresarial / confraternização, Aniversário, Despedida de solteiro, Casamento, Coffee break, Outro.
- `R-10`: o detalhe da proposta mostra a linha "Tipo do evento" com `Evento · <rotulo>`; sem categoria mostra so o rotulo do tipo (`Evento`, `Produção` etc.).

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: as rotas de create e update nao mudam de protecao; o create continua servindo o formulario publico. A validacao no backend nao depende da tela.
- erros e mensagens esperadas: campo vazio no front mostra "Selecione a categoria do evento" no proprio campo; o 400 do backend chega no toast que os formularios ja usam. O formulario nao e limpo apos o erro.
- observabilidade minima: o 400 e o toast atuais. Sem log, metrica ou dashboard novo.
- concorrencia, idempotencia ou retry: ultima gravacao vale; sem fila nem retry novo.
- rollout, fallback ou degradacao: coluna no `main` antes da API; API antes do front. API nova com front antigo recusa Evento sem categoria (por isso sobem juntos). Front novo com API antiga: o campo extra quebra o create no Prisma; nao subir o front antes da API.

## Casos de erro e borda obrigatorios

- caso: proposta antiga de Evento sem categoria
  impacto: abre no detalhe e na edicao sem erro; salvar a edicao exige categoria
  cobertura esperada: `T-02` (update), `T-03` (edicao), `T-05` (detalhe)
- caso: troca de Evento para Producao na edicao com categoria preenchida
  impacto: grava `null`
  cobertura esperada: `T-02` e `T-03`
- caso: troca de Producao para Evento
  impacto: select aparece vazio e obrigatorio
  cobertura esperada: `T-03`
- caso: payload com categoria desconhecida (ex.: `"FESTA"`) no create por pessoa, onde o parse e ignorado
  impacto: 400, nada gravado
  cobertura esperada: `T-02`
- caso: create de permuta (`BARTER`), que sai cedo no use case
  impacto: grava `null` sem exigir categoria
  cobertura esperada: `T-02`
- caso: formulario publico enviado sem categoria
  impacto: o passo nao avanca; se chegar ao backend, 400
  cobertura esperada: `T-04` e `T-02`

## Impacto esperado

A equipe passa a saber a ocasiao de cada evento novo sem ler a descricao. A base fica pronta para relatorios por categoria em outra entrega.

## Areas impactadas

- `backend`: `Proposal` no Prisma, migration, schemas Zod de proposta, quatro use cases de create e update, `CreateProposalInDbParams`
- `frontend`: `types/proposal.ts`, modulo novo de rotulos, formularios do painel, formularios publicos, `ProposalDetails`

## Restricoes e cuidados

- migration aditiva; DDL numa branch de desenvolvimento do PlanetScale e entrada no `main` por deploy request com aprovacao nomeada
- nao rodar `prisma migrate` pelo tunel do banco de producao
- `relationMode = "prisma"`: sem FK envolvida
- sem indice novo (sem consulta por categoria nesta entrega)
- nao ler nem versionar `.env`

## Dependencias

- `Proposal.type` e o select "Tipo do aluguel" ja existem nos formularios do painel
- os formularios publicos ja enviam `type: EVENT` fixo
- os use cases de create e update espalham `...rest` no repositorio, que espalha no `prisma.proposal.create/update`
- `HttpBadRequestError` ja e usado em regra de use case (`assertChosenServiceHours`)

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> `npx prisma validate` e leitura do SQL
- `R-02`, `R-03`, `R-04`, `R-05`, `R-06` -> `T-02` -> unitario da regra e dos use cases
- `R-07`, `R-09` -> `T-03` -> unitario do modulo de rotulos e do payload
- `R-08` -> `T-04` -> unitario do payload e browser do formulario publico
- `R-10` -> `T-05` -> unitario do formatador

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma (`T-01` a `T-05` no codigo)
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `nao feita`
- proxima acao: deploy request da coluna no `main` e prova no browser; review de entrega opcional
- entrada publica recomendada: `fw:review` + `entrega`
