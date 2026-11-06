# Clarify — Apresentacao publica do orcamento

## Perguntas criticas

- Onde as cores sao escolhidas? Confirmado: Configuracoes do espaco, `/venue/:id/settings`.
- Quais cores? Confirmado: primaria, secundaria e texto.
- A pagina publica pode reutilizar `GET /venue/getById`? Nao. Esse retorno inclui dono, contrato e anexo.

## Respostas confirmadas

- fotos: somente `isShowOnOrganization`, na ordem de `position`
- lista da casa: caracteristicas do painel, nao o `Text` de amenities
- servicos: os ligados a este orcamento; nome antes do total e preco no card final
- logo: `logoUrl` das informacoes gerais; sem logo, fallback EventHub
- icones: site, Instagram, Facebook e TikTok na capa; o rodape atual permanece; WhatsApp no fim
- local visivel: cidade e bairro. Rua, numero e estado entram so na URL do Google Maps, sem texto na pagina. CEP continua de fora.
- pernoite e horario de funcionamento sao mutuamente exclusivos na pagina
- cores nao pintam painel nem site da organizacao

## Requisitos implicitos confirmados

- a leitura nova e publica porque o link do cliente ja e publico
- a gravacao continua no update autenticado do venue
- secao vazia some e o valor no fim nao depende dela
- horario do evento continua wall-clock

## Premissas assumidas

- formato da cor: `#RRGGBB`; vazio grava nulo. Risco se estiver errado: o operador nao consegue colar outro formato, e a tela precisa aceitar limpar a cor.
- papel das cores na pagina: primaria no fundo; secundaria nos cards; texto na fonte, inclusive titulo, icone e total. Corrigido em `task-requests/papeis-cores-proposta-request.md`. Risco se estiver errado: o contraste fica trocado de novo, sem mudar o que e gravado.
- cada cor ausente cai no token atual da pagina, independente das outras. Risco se estiver errado: uma cor vazia apagaria as tres.
- Configuracoes oferece limpar as tres cores de volta ao padrao. Risco se estiver errado: depois da primeira gravacao nao da para voltar ao visual atual.
- nao se cria permissao nova; quem ja edita Configuracoes grava as cores. Risco se estiver errado: um papel que edita o venue e nao deveria pintar a proposta passa a poder pintar.
- o rodape de redes permanece alem dos icones da capa. Risco se estiver errado: a capa e o rodape repetem os mesmos links.

## Perguntas de erro e borda ainda abertas

- nenhuma que mude schema ou contrato. As premissas acima cobrem cor invalida, cor vazia e fallback.

## Itens bloqueantes

- nenhum

## O que pode seguir mesmo com lacunas

- `T-01` pode criar as tres colunas nulas sem esperar o review visual dos papeis de cor
- `T-02` e `T-03` podem seguir em paralelo depois de `T-01`
