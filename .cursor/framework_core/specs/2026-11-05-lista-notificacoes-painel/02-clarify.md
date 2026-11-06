# Clarify — KPIs, filtros, paginas e leitura na lista de notificacoes

## Perguntas criticas

- Os cards acompanham busca, tipo e lida/nao lida?
- Sem `page`, a lista segue no teto de 25?
- Marcar todas age no espaco inteiro?
- Abrir o orcamento no link publico marca como lida?

## Respostas confirmadas

- Os quatro cards sao Nao lidas, Ultimos 7 dias, Ultimos 30 dias e Orcamentos novos. Visita nao e card.
- Busca, tipo e lida/nao lida entram no mesmo filtro dos cards. A pagina nao entra.
- Sem `page`, a lista continua com no maximo 25, sem `summary`.
- Marcar todas ignora pagina, busca e filtro.
- O link publico nao marca como lida. Vale qualquer tela do painel que abre o detalhe do orcamento.

## Requisitos implicitos confirmados

- `summary=true` sem `page` responde 400, como na lista de contatos.
- `pageSize` vindo do cliente e ignorado. O servidor usa 10.
- Repetir a marcacao e no-op nas linhas ja lidas.
- Falha ao marcar lida nao bloqueia a tela do orcamento.
- Nao ha valor em reais nem card por tipo.

## Premissas assumidas

- Janela de 7 e de 30 dias e o instante do servidor menos 7 ou 30 periodos de 24 horas em `createdAt`. Premissa errada se o produto quiser meia-noite no fuso do espaco: a execucao segue o instante.
- Qualquer `UserVenuePermission` do usuario naquele espaco autoriza a gravacao. Premissa errada se so `VIEW_VENUE_NOTIFICATIONS` puder marcar: a execucao nao exige essa permissao especifica, porque quem abre o orcamento no painel precisa limpar o selo.
- `q` usa `contains` em `content`, no maximo 80 caracteres, no mesmo estilo da busca de contatos.
- O botao Marcar todas como lidas permanece clicavel com filtro ativo. Ele nao se desliga pelo card filtrado. A segunda chamada grava zero linhas.
- Ordem da pagina: `createdAt` descendente e `id` descendente.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Os casos de filtro vazio, tipo diferente de `PROPOSAL`, `isRead=true`, aviso sem orcamento e usuario sem vinculo estao em `01-spec.md#Casos de erro e borda obrigatorios`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` e `T-02` podem seguir em paralelo. A tela espera as duas.
