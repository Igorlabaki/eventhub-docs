# Clarify — Video do tour na proposta publica

## Perguntas criticas

- O link e arquivo, YouTube, ou os dois?
- O video pode ter som?
- O que acontece com Vimeo, Drive ou uma pagina qualquer?
- Onde fica o bloco se nao houver servicos?

## Respostas confirmadas

- A entrada pede autoplay, replay infinito e nenhum controle.
- A posicao pedida e entre "Sua experiencia inclui" e o container do valor.
- O link mora nas configuracoes do espaco.

## Requisitos implicitos confirmados

- A pagina publica continua a mesma rota.
- A gravacao continua em `PUT /venue/update`, ja autenticada.
- Migration de producao e aditiva (`topics/data-and-migrations.md`).
- Autoplay de navegador exige video mudo.

## Premissas assumidas

- Aceitar os dois: YouTube e arquivo `https` com extensao `.mp4`, `.webm`, `.ogg` ou `.mov`. Risco se estiver errado: um Drive ou Vimeo que a pessoa cole e rejeitado, e ela precisa de outro link.
- Comecar sempre mudo, sem botao de som. Risco se estiver errado: o tour fica sem audio ate uma feature posterior.
- Rejeitar o resto na gravacao, com mensagem no campo. Risco se estiver errado: um host de video nao listado nao entra.
- Sem servicos, o video fica acima de "Seu investimento". Risco se estiver errado: a pessoa esperava o video só quando a experiencia existe.
- Apagar o campo grava `null` e esconde o player. Risco se estiver errado: baixo; e o comportamento pedido para "se tiver o link salvo".
- Nao abrir a divida D-05 das outras rotas do venue. Risco se estiver errado: a gravacao deste campo segue o mesmo buraco das URLs que ja sao salvas por essa rota, que hoje tem `ensureAuthenticate`.

## Perguntas de erro e borda ainda abertas

- Nenhuma que impeça a execucao. Hosts fora da lista ficam de fora de proposito.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01`, `T-02` e `T-03` seguem com as premissas acima.
