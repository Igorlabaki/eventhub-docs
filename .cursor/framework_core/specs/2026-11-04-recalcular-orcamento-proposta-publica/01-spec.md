# Spec — Recalcular o orcamento no link publico

## Problema

Quem abre `/proposal/:id/view` ve dia, convidados, horas e o total no card "Seu investimento", e so a equipe consegue mudar isso no painel.

## Objetivos

O cliente abre um modal nesse card, altera somente o dia, os convidados e a quantidade de horas, e Recalcular grava o orcamento com a tabela da casa. Cada falha aparece no modal, no campo ou num aviso, e o total anterior permanece.

## Fora de escopo

- servicos, descontos e adicionais
- formulario de edicao do painel e as rotas `updatePerPerson` e `updatePerDay`
- agenda, data ocupada e o erro `http-date-not-available`
- check-in, check-out e minimo de noites do espaco
- orcamento que comeca num dia e termina em outro
- modelo `TIERED`, tipo `BARTER` e casa sem preco unitario do modelo
- nova regra de preco, migration e exposicao da tabela de preco
- notificacao de "novo orcamento"

## User stories ou cenarios principais

- O cliente abre o modal, ve os tres valores atuais, corrige e ve locacao, horas extras, total, convidados e horario novos.
- O cliente erra um campo ou o servidor recusa, le o motivo e os numeros digitados continuam no modal.

## Criterios de aceite

- `R-01`: No card "Seu investimento" ha o botao "Alterar orçamento", que abre um modal.
- `R-02`: O modal tem somente os campos "Dia do evento", "Convidados" e "Horas do evento", preenchidos com o orcamento atual, em React Hook Form e Zod.
- `R-03`: Campo vazio, data invalida, convidado menor que 1 ou hora fora de 1 a 24 mostra a mensagem daquele campo e nao envia.
- `R-04`: Recalcular com valores validos grava e a pagina passa a mostrar a nova locacao, as horas extras, o total, os convidados e o horario.
- `R-05`: Falha de rede ou erro inesperado mostra "Não foi possível recalcular. Tente de novo.", mantem o que foi digitado e nao troca o total da pagina.
- `R-06`: Orcamento com `approved` ou `paid` verdadeiro nao e gravado; o modal diz "Este orçamento já foi confirmado e não pode ser recalculado."
- `R-07`: Convidados acima de `maxGuest` nao gravam; a mensagem cita essa capacidade.
- `R-08`: Orcamento cujo inicio e fim caem em dias civis diferentes nao grava; o modal diz "Este orçamento tem mais de um dia. Para mudar o período, fale com a equipe."
- `R-09`: O valor gravado sai da tabela da casa na data nova (sazonalidade, meta e preco minimo ja usados no painel). O cliente nao envia total, preco nem lista de servicos.
- `R-10`: A resposta e o erro nao incluem preco de tabela, dono, contrato, pagamento nem documento do cliente.
- `R-11`: Os servicos ja ligados permanecem no total. O horario de inicio gravado permanece; as horas movem o fim, no mesmo dia civil.
- `R-12`: O historico da proposta ganha "Cliente atualizou data, convidados e horas pelo link", sem usuario.
- `R-13`: Enquanto a gravacao nao volta, o botao Recalcular nao dispara de novo.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a rota e publica de proposito, no orcamento da URL; nao usa `ensureAuthenticate`. Nao grava se `approved` ou `paid` for verdadeiro.
- erros e mensagens esperadas: texto de pessoa, no campo ou em `role="alert"`; falha nao limpa o formulario.
- observabilidade minima: sem metrica nova. O sinal e o historico na proposta e a mensagem HTTP que o modal mostra.
- concorrencia, idempotencia ou retry: o mesmo dia, os mesmos convidados e as mesmas horas gravam os mesmos numeros. Dois cliques diferentes no mesmo orcamento ficam com a ultima gravacao. O botao trava no envio.
- rollout, fallback ou degradacao: sem flag. O botao aparece em todo orcamento de um dia. Casa sem conta aplicavel responde que nao da para recalcular por ali e nao grava.

## Casos de erro e borda obrigatorios

- caso: hora que passaria da meia-noite
  impacto: o fim iria para o dia seguinte e o preco de diarias mudaria
  cobertura esperada: recusa "A quantidade de horas precisa terminar no mesmo dia." e nao grava
- caso: `PER_DAY` ou `PER_PERSON_DAY` no mesmo dia civil
  impacto: `differenceInCalendarDays` daria zero e zeraria a locacao
  cobertura esperada: a conta usa 1 dia
- caso: `PER_PERSON_HOUR` sem receita mensal
  impacto: o painel multiplica duracao por convidados e nao lanca hora extra
  cobertura esperada: o recálculo segue esse ramo
- caso: total abaixo do preco minimo
  impacto: o minimo substitui a locacao e as horas extras saem do total, como no painel
  cobertura esperada: teste do use case
- caso: total que a equipe digitou a mao
  impacto: Recalcular troca pela tabela
  cobertura esperada: o use case nao le um total vindo do cliente
- caso: tipo `BARTER`, modelo `TIERED` ou preco unitario ausente
  impacto: nao existe conta segura
  cobertura esperada: recusa sem gravar

## Impacto esperado

O link publico passa a alterar data, convidados e valor daquele orcamento. O painel ve o historico e os mesmos campos que ja edita.

## Areas impactadas

- `frontend`: `ProposalView` e o servico de proposta
- `backend`: rota publica nova, use case, Zod e historico
- produto: jornada do cliente no link, em `product/03-user-profiles.md`

## Restricoes e cuidados

- D-06: inicio e fim nascem de `transformDate` e dos helpers `wallClock*`
- D-02: router, controller, use case, repositorio
- D-05: permissao de tela nao protege esta gravacao; a protecao e a regra de aprovado/pago e o corpo estreito
- nao ler nem versionar `.env`
- nao criar estado novo no frontend; o retorno entra no `currentProposal` que a pagina ja usa

## Dependencias

- card "Seu investimento" em `ProposalView`
- helpers `transformDate`, `calcEventDuration`, `calcExtraHoursQty`, `calcExtraHourPrice`, `resolveVenueMinimumPrice`, `wallClock*`
- `Dialog` de `components/ui/dialog.tsx`, React Hook Form e `zodResolver`
- `History.userId` opcional

## Mapeamento leve requisito -> task -> prova

- `R-04`, `R-06`, `R-07`, `R-08`, `R-09`, `R-11`, `R-12` -> `T-01` -> unitario
- `R-10` -> `T-02` -> unitario
- `R-01`, `R-02`, `R-03`, `R-05`, `R-13` -> `T-03` -> browser

## Perguntas em aberto

Nenhuma bloqueante. Premissas e o risco de cada uma estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
