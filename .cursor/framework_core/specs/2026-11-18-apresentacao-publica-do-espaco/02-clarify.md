# Clarify — Apresentacao publica do espaco

## Perguntas criticas

- Nenhuma em aberto. As decisoes abaixo vieram do chat e do codigo ja lido.

## Respostas confirmadas

- A pagina e outra, em `/venue/:id/apresentacao`. O orcamento em `/proposal/:id/view` fica como esta.
- A ordem e logo e descricao, video ou foto, uma foto, Conheça nosso espaço, Serviços disponíveis, grid, Seu investimento com WhatsApp, mapa e rodape.
- Serviços disponíveis e o catalogo do espaco, com nome e detalhe, sem preco e sem Alterar servicos.
- Seu investimento explica o modelo gravado, o valor desse modelo e o minimo, e termina em Conversar com nossa equipe. Nao ha total.
- O item Apresentação fica em A casa, abre outra aba e usa `VIEW_VENUE_SITES`. Isso ja esta no codigo.

## Requisitos implicitos confirmados

- A marca, as cores, o video, o `?` das caracteristicas e o mapa seguem a pagina do orcamento.
- Ate o payload chegar, a pagina nao mostra a marca EventHub.
- Sem logo, o fallback EventHub entra so depois da resposta.
- O rodape com logo e redes permanece.
- Agendar uma visita fica dentro de Conheça nosso espaço.

## Premissas assumidas

- Fotos sao as de `isShowOnProposal`, na ordem `position`, as mesmas do orcamento. Premissa: o visitante ve o mesmo conjunto da proposta. Risco se estiver errada: foto marcada so para o site da organizacao (`isShowOnOrganization`) nao entra nesta pagina.
- Servicos saem em ordem alfabetica de `name`. O cadastro nao tem `position`. Risco se estiver errada: a ordem diverge da tela Servicos do painel.
- A lista de servicos nao mostra "obrigatorio a partir de N pessoas" nem horas. Isso depende de convidados e duracao, que esta pagina nao tem.
- Rua e numero vao no JSON e so no `src` do iframe. O texto visivel continua `bairro — cidade`, como na proposta.
- `minimumPrice` igual a 0 conta como ausente, porque o schema grava 0 por padrao.
- O WhatsApp de Agendar uma visita diz que a pessoa recebeu a apresentacao da casa, nao um orcamento. O botao de Seu investimento mantem "gostaria de saber mais sobre a {casa}".

## Perguntas de erro e borda ainda abertas

- Nenhuma. Os casos de foto, servico, preco e WhatsApp vazios estao em `R-09` e nos casos de borda de `01-spec.md`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` e `T-02` seguem com as premissas acima. `R-12` nao vira task.
