# State — Recalcular o orcamento no link publico

## Snapshot

- status: codigo das 3 tasks escrito; botao no canto superior direito do card
- ultima task concluida: `T-03` no codigo; prova do browser incompleta
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: use case 6 testes e controller 3 testes verdes; no browser o modal abre com dia, convidados e horas, campo vazio e hora 0 mostram erro, total ficou R$ 5.520

## Delta da ultima task

- mudou: `PUT /proposal/presentation/:proposalId/recalculate`, modal e botao ao lado do titulo "Seu investimento"
- ficou pendente: gravacao valida, convidado acima da capacidade e falha de servidor nao foram vistos no browser
- lacunas de prova: esses tres fluxos

## Decisoes recentes

- rota publica nova; nao reusa `updatePerPerson` nem `updatePerDay`
- botao fica no alto, a direita do titulo do card

## Riscos ou bloqueios

- nenhum bloqueio
- link publico grava valor de orcamento ainda nao confirmado

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote implementado; review de entrega so se pedirem `fw:review`
- bloqueantes: nenhum
- achados: gravacao valida e erro de rede ainda sem prova no browser
