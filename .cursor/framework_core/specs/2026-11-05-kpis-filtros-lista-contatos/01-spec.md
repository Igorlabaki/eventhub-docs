# Spec — KPIs, filtros e paginas de dez na lista de contatos

## Problema

A pagina de contatos pede a lista do espaco e filtra nome, funcao, WhatsApp e e-mail no navegador. Nao ha pagina nem cards. O `GET /contact/list` devolve todos os contatos do filtro de tipo.

## Objetivos

Quem abre Contatos busca, escolhe a categoria na aba Parceiros, ve tres cards e avanca de dez em dez. Filtro, pagina e cards saem do backend, no mesmo padrao da pagina de orcamentos. Quem lista sem pedir pagina continua recebendo a lista inteira.

## Fora de escopo

- cadastro, edicao e exclusao do contato, alem de recarregar a lista atual
- a tela Indicar parceiros e os formularios publicos de parceiro e colaborador
- coluna, indice ou migration
- colocar JWT na listagem (`project-decisions.md#D-05`)
- grafico, comparacao anual ou filtro de data
- apagar o componente `FilterList`, que outras telas usam

## User stories ou cenarios principais

- Quem gerencia parceiros busca por nome, funcao, WhatsApp ou e-mail, filtra a categoria e le o total, quem tem logo e quem tem descricao do conjunto inteiro, em paginas de 10.
- Quem gerencia a equipe usa a mesma pagina e os mesmos cards, sem o filtro de categoria.

## Criterios de aceite

- `R-01`: com `page`, a lista devolve no maximo 10 itens e `pagination.total` do filtro inteiro
- `R-02`: `q` casa nome, funcao, WhatsApp ou e-mail; vazio e ignorado; passa de 80 caracteres responde 400
- `R-03`: `type` filtra o tipo; `category` filtra o enum exato; os dois juntos restringem os dois
- `R-04`: a ordem e `name` ascendente, com desempate por `id`
- `R-05`: `summary.total`, `summary.withLogo` e `summary.withDescription` usam o filtro inteiro; `summary.total` e igual a `pagination.total`
- `R-06`: `summary=true` sem `page` responde 400; sem `summary`, a chave nao vem; sem `page`, a lista inteira vem e `pagination` nao
- `R-07`: a pagina de contatos so exibe a resposta; nao filtra nem conta no navegador
- `R-08`: busca, categoria e aba voltam para a pagina 1; o controle de categoria so aparece em Parceiros
- `R-09`: filtro sem linhas devolve lista vazia e cards zerados; o pager some quando ha no maximo uma pagina
- `R-10`: Indicar parceiros, que nao manda `page`, continua recebendo todos os parceiros do espaco
- `R-11`: criar, editar e apagar recarregam o filtro e a pagina atuais; apagar a ultima linha da pagina mostra a anterior
- `R-12`: nao ha coluna nem indice novo

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a query continua no `venueId` pedido. Esta spec nao acrescenta `ensureAuthenticate`. A lacuna segue `project-decisions.md#D-05`.
- erros e mensagens esperadas: query invalida responde 400 pelo Zod. A tela mostra o erro da lista e um botao de tentar de novo, como em orcamentos.
- observabilidade minima: sem log novo de nome, WhatsApp ou e-mail. A prova e o unitario e a tela.
- concorrencia, idempotencia ou retry: leitura paginada, sem escrita nova.
- rollout, fallback ou degradacao: sem `page`, o contrato antigo permanece. Sem feature flag.

## Casos de erro e borda obrigatorios

- caso: pagina alem do fim
  impacto: a lista da pagina vem vazia e `pagination.total` permanece o do filtro
  cobertura esperada: unitario
- caso: logo ou descricao nulos ou so com espaco
  impacto: nao entram em `withLogo` nem em `withDescription`
  cobertura esperada: unitario
- caso: menos de dez contatos no filtro
  impacto: uma pagina e o pager oculto
  cobertura esperada: tela
- caso: aba Equipe
  impacto: a tela nao envia `category`
  cobertura esperada: tela
- caso: chamada sem `page`, inclusive Indicar parceiros
  impacto: lista completa, sem `pagination` e sem `summary`
  cobertura esperada: unitario

## Impacto esperado

O painel de contatos passa a pedir pagina, filtro e resumo. O restante dos chamadores da listagem so muda se passar a mandar `page`.

## Areas impactadas

- `backend`: `GET /contact/list`
- `frontend`: pagina Contatos, servico e store de contato

## Restricoes e cuidados

- nao calcular card, filtro ou pagina a partir das linhas ja carregadas
- nao criar outra rota de listagem
- a tela de orcamentos e a referencia de faixa, cards e pager, nao de filtro de data ou valor

## Dependencias

- `GET /proposal/list` com `page` e `summary` ja no painel (`specs/2026-11-05-lista-painel-orcamentos/`)
- nenhum schema novo

## Mapeamento leve requisito -> task -> prova

- `R-01` -> `T-01` -> unitario
- `R-02` -> `T-01` -> unitario
- `R-03` -> `T-01` -> unitario
- `R-04` -> `T-01` -> unitario
- `R-05` -> `T-01` -> unitario
- `R-06` -> `T-01` -> unitario
- `R-07` -> `T-02` -> tela
- `R-08` -> `T-02` -> tela
- `R-09` -> `T-01` e `T-02` -> unitario e tela
- `R-10` -> `T-01` -> unitario
- `R-11` -> `T-02` -> tela
- `R-12` -> `T-01` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md#Premissas assumidas`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
