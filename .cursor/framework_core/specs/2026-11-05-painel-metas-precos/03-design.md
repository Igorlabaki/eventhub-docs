# Design — Painel de metas e precos

## Visao geral da solucao

A aba Painel de `VenueGoals` passa a ser apresentacao. Os fetches, o formulario de preco e as abas de detalhe ficam onde estao. Duas funcoes puras decidem numero e estado; os componentes so renderizam.

As cinco perguntas do painel, nesta ordem: qual e o preco atual, qual e a meta anual, quantos adicionais ativos, quantos descontos ativos, qual e o minimo padrao.

## Resumo

Funcao pura, testavel sem tela:

- meses validos: inteiros de 1 a 12 em `goal.months`
- meta anual: soma de `minValue` vezes essa contagem; lista vazia nao tem total
- preco atual configurado: modelo conhecido e preco maior que zero
- minimo configurado: `minimumPrice` maior que zero
- contagem configurada: length maior que zero
- amostra: os 3 primeiros itens
- estado do bloco: `loading` se `isLoading`; senao `error` se `error`; senao `empty` se nao ha dado; senao `ready`

O resumo usa o estado `empty` com a frase "Nada configurado" no lugar do numero. Nao usa R$ 0,00 nem o digito 0 para "nao configurado".

Rotulos: o nome do modelo ja usado na tela ("Preço por pessoa" e os equivalentes), "Meta anual", "Adicionais ativos", "Descontos ativos", "Mínimo padrão". Icones: calendario, alvo, capelo, etiqueta, escudo.

O card de meta anual nao ganha percentual de variacao. A taxa de aumento continua so no card da meta, porque ela e dado real. Um delta de KPI seria numero inventado.

## Secoes do painel

Ordem: resumo, modelo de precificacao, metas ao lado de adicionais, precos minimos, descontos.

- Modelo: card largo. Fechado, mostra rotulo, valor e, com permissao, o botao Editar. Aberto, o formulario atual permanece. A ilustracao da calculadora vira icone no canto, escondido quando a largura nao comporta.
- Metas e Adicionais: duas colunas a partir de `lg`; uma coluna abaixo. Cabecalho com icone, titulo, subtitulo e Ver todos em variante de link, nao botao preenchido.
- Card da meta: valor, chips so dos meses da meta, taxa de aumento. Sem mes valido, o card omite os chips. Sem barras.
- Card do adicional: titulo, periodo ou dias traduzidos, percentual positivo.
- Minimos: card do padrao e, ao lado em `md`, as faixas. Padrao vazio nao apaga faixa. Faixa vazia nao apaga padrao.
- Descontos: ate tres cards. Percentual negativo. Uma coluna no estreito, tres no largo.

Ver todos chama a mesma troca de aba que o painel ja faz.

## Estados

- `loading`: esqueleto no formato do card. A frase "Nada configurado" nao aparece.
- `empty`: a frase e, se `EDIT_VENUE_PRICES`, a acao de criar da secao. Sem permissao, so a frase.
- `error`: a `error` que a store ja gravou. Nao trocar por vazio.
- `ready`: os cards da amostra.

Adicional e desconto compartilham `isLoading` e `error` na mesma store. O painel usa esse estado como esta. Separar a store fica fora.

O `EmptyState` tracejado sai do painel. As abas de detalhe podem continuar com ele.

## Componentes e modulos impactados

- `eventhub-vista-dashboard/src/pages/VenueGoals.tsx`: o bloco `viewMode === "panel"` passa a montar o resumo e as secoes
- novos arquivos em `eventhub-vista-dashboard/src/components/goal/`: funcoes do resumo e os componentes do painel
- `goal-header.tsx`: nao muda
- stores, servicos e abas de detalhe: nao mudam

## Reuso previsto

- `pricingType` e o formulario de preco que a pagina ja tem
- `traduzirDiasSemana`, `monthLabels`, `hasEditPermission`, `handleCardClick`
- `Card`, `Button` e icones `lucide-react` ja usados na tela
- formatacao `pt-BR` / `BRL` ja usada nos cards

## Contratos e dados

Nenhum contrato novo. Leitura dos objetos que a pagina ja carrega: venue (`pricingModel`, precos, `minimumPrice`), goals, surcharges, discounts, periods.

## Falhas, casos de borda e invariantes

- vazio nao e zero
- erro nao e vazio
- carregando nao e vazio
- amostra nunca passa de 3
- faixa e piso padrao falham separados
- meta sem mes continua listada e soma zero

## Decisoes arquiteturais importantes

- so frontend, porque o dado ja esta na tela
- meta anual derivada na hora, porque nao existe campo e a entrada proibe criar um
- sem grafico, porque nao ha serie de faturamento e a regra de dashboard pede grafico so para pergunta real
- sem asset novo, porque a entrega e a hierarquia e a mensagem
- extrair o painel da pagina, porque `VenueGoals.tsx` ja concentra fetch, formulario e as quatro abas
- Zustand atual, sem terceira camada de estado

Alternativa descartada: persistir meta anual. A entrada proibe campo novo.

Alternativa descartada: copiar as ilustracoes da imagem. Nao estao no repositorio e nao mudam a informacao.

Alternativa descartada: mostrar um unico item por secao. Esconderia dado que o painel ja mostra.

## Riscos e mitigacoes

- o resumo anual surpreender o operador: a formula fica na funcao pura e no teste
- a store compartilhada de taxa esconder uma lista: registrado; nao se mexe na store aqui
- a spec de piso mudar o campo: esta feature so le `minimumPrice` e `periods`

## Rollout, observabilidade e rollback

- rollout: o painel novo substitui o antigo no mesmo lugar
- observabilidade: nenhuma metrica nova
- rollback: reverter o componente do painel; nao ha migracao

## Estrategia de validacao

- unitario da funcao de total, configurado/vazio, estado e amostra
- teste do componente das secoes para frase, acao condicionada a permissao, tres itens e Ver todos
- no browser, `/venue/:id/goals` na aba Painel, com dados e com bloco vazio, se a sessao existir

## Fontes que fecharam a solucao

- `design/rules/07_data_display_and_dashboards.md#Numeros e KPIs` e `#Dashboards`
- `design/rules/05_component_states_and_variants.md#Estados de tela com dados`
- `topics/frontend-application.md`: Zustand e React Query ja coexistem; esta tela permanece na store atual
- `product/04-user-journeys.md`: metas seguem configuracao do espaco
- `specs/2026-11-02-precos-minimos-por-periodo/00-overview.md`: dona do piso

## Passada transversal

- architecture: nao. A pagina e as stores continuam as mesmas; nenhuma fronteira nova.
- database: nao. Nada persistido. A meta anual e soma de leitura.
- design: sim. Hierarquia do resumo, estados loading/empty/error/ready e tokens que a tela ja usa.
- observability: nao. Nao ha servico nem fluxo de producao novo.
- security: nao. Nao muda auth, segredo, PII nem a permissao. So respeita a permissao que a pagina ja consulta.
- patterns/rules/06: nao. Nao ha retry, fila, webhook, concorrencia nem cache novo.
