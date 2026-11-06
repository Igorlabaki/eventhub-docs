# Clarify — Precos minimos por periodo

## Perguntas criticas

- A faixa vale todo ano ou so num ano? Premissa: todo ano, `dd/MM`, como o adicional. Risco se errada: falta campo `year` e a tela precisa de outro controle.
- Periodos sobrepostos usam qual valor? Premissa: o maior `price`. Risco se errada: a leitura precisa de prioridade ou de bloqueio na gravacao.
- Qual data escolhe a faixa? Premissa: a data de inicio do evento. Risco se errada: pernoite que atravessa o periodo usa o piso do dia errado.
- Total digitado a mao sobe ao piso? Premissa: nao. Risco se errada: o ramo manual dos use cases precisa passar a chamar o piso.
- O painel mostra resumo? Premissa: sim, piso padrao e ate tres faixas. Risco se errada: a secao do painel sai da tela.
- A permissao e propria? Premissa: nao. Reusa `VIEW_VENUE_PRICES` e `EDIT_VENUE_PRICES`, checadas no venue da faixa. Risco se errada: entram permissao nova e backfill.

## Respostas confirmadas

- A entrada pede aba em Metas e Precos, piso padrao visivel e faixas por periodo, com dezembro como exemplo.
- `Venue.minimumPrice` ja e o piso padrao e continua sendo esse campo.
- `SeasonalFee` e percentual de adicional ou desconto e nao guarda piso em reais.
- A tela de Metas e Precos ja libera edicao com `EDIT_VENUE_PRICES`. A rota da pagina ja exige `VIEW_VENUE_PRICES`.
- As rotas atuais de meta e adicional nao checam essa permissao no backend. As rotas novas desta feature checam.

## Requisitos implicitos confirmados

- intervalo com fim anterior ao inicio cobre a virada do ano, no mesmo criterio do adicional
- piso zero ou ausente nao eleva o total
- a faixa nao substitui adicional, desconto nem meta
- permissao no frontend nao substitui autorizacao no backend

## Premissas assumidas

- preco da faixa e obrigatorio e maior que zero; piso padrao pode continuar zero
- gravacao de faixas sobrepostas e permitida; nao ha aviso obrigatorio no formulario
- o piso padrao e salvo pelo `updateVenue` que Configuracoes do espaco ja usa, sem endpoint novo
- a edicao por dia ganha o mesmo `if` de piso que a criacao por dia ja tem, so no ramo que recalcula sozinho
- a conta em volta do piso, em cada ramo que ja existe, permanece; esta feature troca o numero comparado

## Perguntas de erro e borda ainda abertas

- A criacao por pessoa, quando o piso entra, soma servicos de novo e descarta hora extra; a edicao por pessoa substitui o total inteiro pelo piso. Premissa: nao unificar nesta feature. Risco se errada: o total da edicao continua diferente do total da criacao mesmo com a faixa certa.

## Itens bloqueantes

- nenhum

## O que pode seguir mesmo com lacunas

- a divergencia de formula entre criar e editar fica para o request de adicionais na edicao, ou para um pedido futuro de paridade do piso
- aviso visual de faixa sobreposta pode entrar depois, sem mudar a regra do maior preco
