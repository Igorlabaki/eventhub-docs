# Lote De Task Requests

## Identificacao do lote

- nome do lote: `2026-11-09-orcamento-painel-por-pessoa-e-total-estimado`
- data: 2026-11-09
- origem: chat, sobre os formularios de criar e editar orcamento por pessoa no painel
- contexto resumido: a criacao ja mostra `R$ X / pessoa` ao lado do Total; a edicao nao. Quem preenche o orcamento tambem quer ver o total (espaco + horas extras + servicos) enquanto preenche, antes de salvar.

## Objetivo do lote

- objetivo geral: dar a quem monta o orcamento no painel a leitura do valor enquanto preenche, igual na criacao e na edicao
- tema dominante: valor do orcamento no formulario do painel

## Requests deste lote

1. `tr-01-valor-por-pessoa-na-edicao.md` - `R$ X / pessoa` ao lado do Total tambem na edicao do orcamento
2. `tr-02-total-estimado-ao-preencher.md` - total estimado com detalhamento enquanto o formulario e preenchido, calculado pelo backend sem gravar

## Ordem sugerida de execucao

1. request: `tr-01-valor-por-pessoa-na-edicao.md`
   motivo: ajuste pequeno, um arquivo do frontend, reaproveita `perPersonLabel` ja entregue
2. request: `tr-02-total-estimado-ao-preencher.md`
   motivo: precisa de rota nova no backend e de extrair o calculo hoje repetido nos casos de uso; vai por spec

## Dependencias entre requests

- `tr-01-valor-por-pessoa-na-edicao.md`: depende de: nenhuma
- `tr-02-total-estimado-ao-preencher.md`: depende de: nenhuma; se `tr-01` ja estiver entregue, o `/ pessoa` pode passar a usar tambem o total estimado quando o campo Total estiver vazio (ver pergunta em aberto do `tr-02`)

## Grupos que devem virar spec

- nenhum
- motivo: os dois itens tem objetivo e tamanho bem diferentes; nao se completam

## Requests individuais que devem virar spec

- request: `tr-02-total-estimado-ao-preencher.md`
  motivo: rota nova no backend, extracao do calculo de preco compartilhado por criar, editar e recalcular publico, e mudanca nos dois formularios do painel
  sugestao de slug: `framework_core/specs/2026-11-09-total-estimado-orcamento-painel/`

## Itens sensiveis

- `tr-01-valor-por-pessoa-na-edicao.md`: exige leitura da lib `security`: `nao`. So exibicao no formulario autenticado.
- `tr-02-total-estimado-ao-preencher.md`: exige leitura da lib `security`: `sim`. Rota nova que expoe regra de preco, ajuste por meta (derivado do faturamento do mes) e preco minimo; precisa ser autenticada e checar acesso ao espaco no backend.

## Status do lote

- nao iniciado: `tr-01`
- em andamento: nenhum
- concluido: nenhum
- promovido para spec: `tr-02` -> `specs/2026-11-09-total-estimado-orcamento-painel/`
- proximo item recomendado: `tr-01` com `task-workflow-prompt-smart`; spec do `tr-02` em `T-01`

## Observacoes gerais

- pontos em aberto: estao em cada request, cada um com premissa default
- restricoes do lote: so formularios do painel por pessoa (`PerPersonProposalForm` e `ProposalEdit`); formularios publicos e por diaria ficam fora
- observacoes adicionais: `tr-01` completa o request [Valor por pessoa ao lado do Total na criacao do orcamento](../valor-por-pessoa-no-total-do-orcamento-request.md), que deixou a edicao fora de escopo
