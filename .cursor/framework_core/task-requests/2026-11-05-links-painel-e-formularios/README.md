# Lote De Task Requests

## Identificacao do lote

- nome do lote: `2026-11-05-links-painel-e-formularios`
- data: 2026-11-05
- origem: chat, a partir das telas de Regras e de Link do evento
- contexto resumido: o painel mostra um campo com o endereco e um botao Copiar ao lado; a base do endereco sai do ambiente aberto (localhost). O formulario de criar regra e o de criar caracteristica reabrem preenchidos. Link do evento abre uma pagina interna so com esse campo.

## Objetivo do lote

- objetivo geral: oferecer os links do jeito que o painel ja oferece nas outras telas, com a base de producao, e reabrir o cadastro de regra e de caracteristica vazio
- tema dominante: gesto do painel em regras, caracteristicas e link do evento

## Requests deste lote

1. `tr-01-botao-copiar-regras.md` - nas regras, um botao que copia o link publico com a base de producao
2. `tr-02-reset-formulario-regra-caracteristica.md` - nova regra e nova caracteristica abrem com o formulario vazio
3. `tr-03-link-evento-nova-aba.md` - Link do evento abre a pagina publica numa aba nova, com a base de producao

## Ordem sugerida de execucao

1. request: `tr-01-botao-copiar-regras.md`
   motivo: foi o primeiro ajuste pedido e nao depende dos outros
2. request: `tr-03-link-evento-nova-aba.md`
   motivo: o mesmo criterio de base de producao, em outra tela e com outro gesto
3. request: `tr-02-reset-formulario-regra-caracteristica.md`
   motivo: defeito separado; pode ir em paralelo com os dois acima

## Dependencias entre requests

- `tr-01-botao-copiar-regras.md`: depende de: nenhuma
- `tr-02-reset-formulario-regra-caracteristica.md`: depende de: nenhuma
- `tr-03-link-evento-nova-aba.md`: depende de: nenhuma

## Grupos que devem virar spec

- nenhum
- motivo: tres ajustes de painel, cada um com objetivo verificavel e frente unica no frontend

## Requests individuais que devem virar spec

- nenhum

## Itens sensiveis

- `tr-01-botao-copiar-regras.md`: exige leitura da lib `security`: `nao`. O destino publico ja existe; o request so muda o botao e a base do endereco copiado.
- `tr-02-reset-formulario-regra-caracteristica.md`: exige leitura da lib `security`: `nao`. Cadastro autenticado que ja existe.
- `tr-03-link-evento-nova-aba.md`: exige leitura da lib `security`: `nao`. A pagina publica ja existe; o request so muda como o menu a abre.

## Status do lote

- nao iniciado: nenhum
- em andamento: nenhum
- concluido: nenhum; `tr-01`, `tr-02` e `tr-03` foram promovidos juntos
- promovido para: `specs/2026-11-05-links-painel-e-formularios/`
- proximo passo: ver spec (`T-01`)

## Observacoes gerais

- pontos em aberto: estao em cada request, cada um com premissa default
- restricoes do lote: base dos enderecos oferecidos por estes dois gestos e `https://event-hub-dashboard.vercel.app/`; nao reabrir a spec do link publico das regras para refazer a pagina publica
- observacoes adicionais: a spec [Abrir o link publico das regras do espaco](../../specs/2026-11-05-link-publico-regras-do-espaco/00-overview.md) segue dona da pagina publica. Este lote corrige o gesto no painel e nao pede campo, rota publica nova nem contrato novo
