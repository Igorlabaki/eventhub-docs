# Clarify — Reordenar fotos da proposta publica

## Perguntas criticas

- A capa entra no arraste? Premissa: sim. Risco se errada: o dono nao consegue trocar a foto grande.
- Quem grava? Premissa: usuario autenticado com `EDIT_VENUE_SITE` no espaco da proposta. Risco se errada: outro papel do painel ficaria de fora ou entraria gente demais.
- A ordem vale so neste orcamento? Premissa: nao. Vale para as fotos do espaco. Risco se errada: outra proposta publica do mesmo espaco mudaria junto.
- Token invalido derruba o GET publico? Premissa: nao. Responde 200 com `canReorder: false`. Risco se errada: o dono com sessao vencida nao ve o arraste ate entrar de novo.

## Respostas confirmadas

- A pagina publica e `GET /proposal/presentation/:proposalId`, sem `ensureAuthenticate`.
- A edicao de imagens do espaco no painel usa `EDIT_VENUE_SITE` em `VenueWebsiteImages`.
- A capa e `images[0]`; "A casa" e o restante. O carrossel usa so "A casa".
- A apresentacao hoje nao devolve `id` da imagem.
- Nao ha biblioteca de arraste no frontend.

## Requisitos implicitos confirmados

- Permissao de tela nao autoriza a gravacao.
- Fotos ocultas (`isShowOnOrganization` falso) nao entram na lista nem mudam de posicao.
- Soltar no mesmo lugar nao grava.
- Falha de rede devolve a ordem que a pagina tinha antes do arraste.

## Premissas assumidas

- Dois donos gravando juntos: fica a ultima transacao commitada. Nao ha trava de edicao.
- Arraste e por ponteiro. Teclado fica no campo Posicao do painel.
- Sem pacote novo de arraste; vale o arraste nativo do browser.
- `canReorder` vem na leitura que a pagina ja faz, para nao depender da permissao de outro espaco guardada na sessao do painel.

## Perguntas de erro e borda ainda abertas

- Nenhuma que mude o contrato. Os casos de conjunto invalido, foto unica e galeria vazia ja tem premissa em `01-spec.md`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` pode comecar. A revisao da spec (`fw:review`) e o passo recomendado antes do codigo, nao um bloqueio de informacao.
