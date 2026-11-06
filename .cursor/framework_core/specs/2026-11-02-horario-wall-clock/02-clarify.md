# Clarify — Horario de evento sem fuso

## Perguntas criticas

Nenhuma em aberto que impeça a execucao. As premissas abaixo ja viraram decisao em `03-design.md`.

## Respostas confirmadas

- O pedido do usuario e: o valor informado permanece. `11` e `11` ficam `11:00` e `11:00`.
- D-06 ja fixa wall-clock na agenda. Esta feature aplica a convencao onde a leitura ainda converte.
- A fase 1 do plano ja entregou o util do frontend e as telas P0.
- O backend ja pretende gravar com `moment.utc`. Nao ha `date-fns-tz` no `package.json` do backend. O frontend ja tem `date-fns-tz`.

## Requisitos implicitos confirmados

- O sufixo `Z` do JSON nao autoriza converter para `America/Sao_Paulo` dentro do EventHub.
- Timestamps de auditoria ficam no fuso local da tela.
- Pagamento e despesa sao dia civil, sem hora de evento.

## Premissas assumidas

- Datas so de dia entram no tratamento literal. Premissa: gravar `YYYY-MM-DDT12:00:00.000Z` e exibir o componente de data UTC. Risco se estiver errado: um pagamento exatamente a meia-noite local continua ambíguo; o meio-dia UTC evita o dia anterior no Brasil.
- `createdAt` e `updatedAt` ficam de fora. Premissa: instante real. Risco se estiver errado: alguma tela de auditoria continuaria mostrando horario local, que e o comportamento desejado hoje.
- Nao regravar historico. Premissa: quem ja foi salvo via `transformDate` tem os digitos certos; a correcao e de leitura e das gravacoes que ainda deslocam. Risco se estiver errado: linhas gravadas pelo caminho quebrado do cronograma ou da despesa permanecem com o dia errado ate uma migration futura.
- Google Calendar entra. Premissa: enviar os digitos sem `Z` e manter o rotulo `America/Sao_Paulo`, que o sync ja usa. Risco se estiver errado: venue fora de Sao Paulo veria o rotulo SP; isso ja e o contrato atual da integracao, e fuso por venue fica fora desta spec.
- Sazonalidade usa o dia civil UTC do `startDate`. Premissa: a taxa deve ver o mesmo dia que o usuario digitou. Risco se estiver errado: a virada de preco deixaria de coincidir com o relogio do servidor; o relogio do servidor e justamente a causa do dia errado.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Bordas de hora igual, virada de meia-noite, data invalida e dia so-data estao em `R-06`, `R-08` e `R-11`.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` pode comecar. `T-04`, `T-05` e `T-08` nao dependem do util novo do backend.
- Review da spec (`fw:review`) e o passo recomendado antes de implementar, nao um bloqueio de conteudo.
