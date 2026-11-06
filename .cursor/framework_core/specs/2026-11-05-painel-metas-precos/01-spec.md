# Spec — Painel de metas e precos

## Problema

A aba Painel de Metas e Precos lista preco, meta, adicional, minimo e desconto, mas a composicao nao e a da referencia. Falta o resumo. As secoes ficam empilhadas. O piso ausente aparece como R$ 0,00. O vazio e um bloco tracejado.

## Objetivos

Na aba Painel, a tela segue a composicao da referencia. Cada bloco sem configuracao diz que nao ha nada configurado.

## Fora de escopo

- abas Metas, Adicionais, Descontos e Minimos, e os formularios delas
- calculo do orcamento
- schema, campo de meta anual e contrato da API
- ilustracao ou foto obrigatoria
- grafico de faturamento
- a spec `precos-minimos-por-periodo`, fora da apresentacao do painel

## User stories ou cenarios principais

- Com dados, a pessoa ve o resumo e as secoes da referencia e abre o restante em Ver todos.
- Sem meta, adicional, desconto, faixa ou piso, o bloco correspondente diz "Nada configurado".
- Quem pode editar preco continua editando o modelo e criando o que falta. Quem nao pode, ve a mensagem sem a acao.

## Criterios de aceite

- `R-01`: o Painel mostra, nesta ordem, preco atual, meta anual, adicionais ativos, descontos ativos e minimo padrao.
- `R-02`: a meta anual e a soma de `minValue` de cada meta vezes a quantidade de meses validos (1 a 12). Sem meta, o card diz "Nada configurado".
- `R-03`: o preco atual mostra o rotulo do modelo e o valor em BRL quando modelo e preco existem e o preco e maior que zero. Sem isso, diz "Nada configurado".
- `R-04`: adicionais ativos e descontos ativos mostram a contagem quando ela e maior que zero. Contagem zero diz "Nada configurado".
- `R-05`: o minimo padrao mostra BRL quando `minimumPrice` e maior que zero. Ausente, nulo ou menor ou igual a zero diz "Nada configurado".
- `R-06`: o modelo de precificacao e um card largo, com o preco atual. Quem tem `EDIT_VENUE_PRICES` ve Editar e o formulario que ja existe.
- `R-07`: a partir do breakpoint largo, Metas e Adicionais ficam lado a lado. Abaixo disso, empilham. Cada cabecalho tem titulo, subtitulo da referencia e Ver todos, que abre a aba atual.
- `R-08`: cada secao do painel mostra no maximo 3 itens. Ver todos chega ao restante.
- `R-09`: o card da meta mostra valor, os meses da meta e a taxa de aumento. O adicional mostra titulo, periodo ou dias e percentual positivo. O desconto mostra titulo, periodo ou dias e percentual negativo. Minimos mostram o padrao e ate 3 faixas.
- `R-10`: lista carregada e vazia mostra "Nada configurado". Com `EDIT_VENUE_PRICES`, a acao de criar daquela secao aparece. Sem a permissao, a acao nao aparece.
- `R-11`: durante o carregamento, e quando a store daquela lista tem `error`, o bloco nao diz "Nada configurado".
- `R-12`: abas de detalhe, formularios, calculo de preco e a API de piso permanecem como estao.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a rota continua exigindo `VIEW_VENUE_PRICES`. Editar e criar continuam em `EDIT_VENUE_PRICES`.
- erros e mensagens esperadas: moeda `pt-BR` em BRL, no formato cheio. A frase de vazio e "Nada configurado". Ver todos e o mesmo texto em todas as secoes.
- observabilidade minima: nenhuma. Nao ha servico novo.
- concorrencia, idempotencia ou retry: nao se aplica. A tela so le o que as stores ja buscam.
- rollout, fallback ou degradacao: sem flag. O painel novo substitui o painel atual.

## Casos de erro e borda obrigatorios

- caso: lista ainda em `isLoading`
  impacto: o vazio apareceria antes da hora
  cobertura esperada: `T-01` no helper; `T-02` nas secoes
- caso: `error` preenchido na store da lista
  impacto: falha de rede viraria "Nada configurado"
  cobertura esperada: `T-01` e `T-02`
- caso: meta sem mes valido
  impacto: a meta existe, mas nao entra na soma anual
  cobertura esperada: `T-01`; o card da meta continua na secao
- caso: piso zero com faixas cadastradas
  impacto: o padrao e o vazio; as faixas continuam visiveis
  cobertura esperada: `T-02`
- caso: mais de tres itens
  impacto: o painel esconderia o restante sem caminho
  cobertura esperada: `T-01` limita a amostra; `T-02` mantem Ver todos
- caso: sem permissao de editar
  impacto: a acao de criar ou editar apareceria para quem nao pode
  cobertura esperada: `T-02`

## Impacto esperado

Quem abre Metas e Precos reconhece a referencia e entende o bloco que ainda nao foi configurado.

## Areas impactadas

- `frontend`: aba Painel de `VenueGoals`
- `backend`: nenhuma

## Restricoes e cuidados

- nao persistir meta anual
- nao desenhar serie de faturamento
- nao bloquear a entrega por falta de ilustracao
- nao alterar o dado de piso da spec vizinha

## Dependencias

- stores e tela atuais de meta, adicional, desconto, preco do espaco e faixa de minimo
- spec `specs/2026-11-02-precos-minimos-por-periodo/`

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-01` -> unitario
- `R-03` -> `T-01` -> unitario
- `R-04` -> `T-01` -> unitario
- `R-05` -> `T-01` -> unitario
- `R-06` -> `T-02` -> componente e browser
- `R-07` -> `T-02` -> componente e browser
- `R-08` -> `T-01` -> unitario
- `R-09` -> `T-02` -> componente
- `R-10` -> `T-02` -> componente
- `R-11` -> `T-01` -> unitario
- `R-12` -> `T-02` -> ausencia de diff em formulario, API e calculo

## Perguntas em aberto

Nenhuma bloqueante. As premissas estao em `02-clarify.md#Premissas assumidas`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `nao se aplica`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
