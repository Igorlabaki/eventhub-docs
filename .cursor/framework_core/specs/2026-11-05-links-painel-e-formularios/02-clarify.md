# Clarify — Links do painel e formularios de cadastro

## Perguntas criticas

Nenhuma em aberto. As respostas abaixo vieram do lote e do codigo que os tres gestos ja usam.

## Respostas confirmadas

- O caminho publico das regras e `/venue/{id}/rules/view`, montado por `publicVenueRulesPath`. A pagina nao entra nesta feature.
- A pagina publica do evento ja e `/proposal/:id/links` (`ProposalEventLinkPage`). O item da sidebar hoje aponta para `/proposal/:id/event-link` (`ProposalEventLinkSharePage`), que so mostra o campo.
- Orcamentos (`VenueBudgets.tsx`) e Contatos (`contact-list.tsx`) ja copiam com botao `outline` `w-full` e a base `https://event-hub-dashboard.vercel.app` escrita no codigo.
- `AnimatedFormSwitcher` deixa o formulario montado e so aplica `hidden`. `VenueRuleForm` e `VenueAmenityForm` so dao `reset` quando o registro muda. Na criacao o registro continua `undefined`, entao a segunda abertura reaproveita o que foi digitado.
- `eventLinkDestinations` ja inclui "Regras do espaço" com href relativo. Esse destino nao e o item da sidebar.
- O frontend nao tem Testing Library. A prova de tela e o browser; a prova automatica fica nas funcoes puras.

## Requisitos implicitos confirmados

- o botao de Regras fica visivel para quem abre a tela, nao so para quem tem `EDIT_VENUE_RULES`, como o campo de hoje
- sucesso da copia mantem o toast "Link copiado" / "O link das regras está na área de transferência."
- a falha da copia deixa de dizer "Selecione o link e copie manualmente.", porque o campo sai
- posicao continua so na edicao
- `SEND_PROPOSAL_INFO` continua sendo o filtro do item

## Premissas assumidas

- Rotulo do botao: `Copiar link das regras`. Risco: o texto destoa de "Link para formulário de orçamento"; o endereco copiado continua certo.
- O botao fica no lugar do campo, acima de Nova regra. Risco: a equipe procura o botao dentro da lista.
- Indicar parceiros fica de fora. Risco: aquele campo continua podendo copiar localhost.
- Cancelar sem salvar esvazia a proxima abertura. Risco: um rascunho cancelado nao volta.
- Erro de gravacao nao limpa o que foi digitado. Risco: se a equipe quiser tela limpa depois do erro, o texto antigo continua. A premissa segue `design/rules/06_forms_and_input_ux.md`.
- Outros formularios do painel ficam de fora. Risco: o mesmo sintoma segue onde o switcher tambem nao desmonta.
- A rota `/proposal/:id/event-link` permanece, sem item de menu. Risco: abrir esse endereco direto cai no redirecionamento que a sidebar ja faz quando a rota nao esta na lista. Nao recolocar o `href` para "consertar" isso.
- O clique em Link do evento nao copia o endereco. Risco: a equipe perde o copiar desse atalho e so ganha a aba.
- O item fica na mesma posicao da sidebar. Risco: nenhum alem da ordem.
- A base nao vira variavel de ambiente nesta feature. Risco: qualquer ambiente do painel oferece o host de producao, de proposito, como os outros botoes.

## Perguntas de erro e borda ainda abertas

Nenhuma. Venue sem id, orcamento sem id, clipboard recusada, popup bloqueado e gravacao falha ja tem premissa e criterio em `01-spec.md`.

## Itens bloqueantes

- nenhum

## O que pode seguir mesmo com lacunas

Tudo. `T-01`, `T-02` e `T-03` seguem pelas premissas acima.
