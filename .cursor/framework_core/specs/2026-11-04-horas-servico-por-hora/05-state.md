# State — Horas escolhidas no servico por hora

## Snapshot

- status: `T-01` a `T-06` escritas; lote nao pronto para producao
- ultima task concluida: `T-06` no codigo
- task em andamento: nenhuma
- proxima task exata: nenhuma; falta provar o campo no browser
- prova mais recente: vitest da cotacao 10, criacao 12, link 19, recalculo 7 e duracao do painel 3 testes verdes

## Delta da ultima task

- mudou: a cotacao usa as horas informadas; a criacao exige o mapa; o formulario publico pede as horas; o painel envia a duracao; o link le `hourly` e grava a quantidade; o recalculo conserva a quantidade
- ficou pendente: abrir o passo "Como nos encontrou" e o modal com a API no ar
- lacunas de prova: browser do formulario publico e do modal; a API local em `localhost:3000` estava fechada

## Decisoes recentes

- sem coluna nova; quantidade em `ProposalService.quantity`
- criacao exige `serviceHours` para servico por hora
- zero so passa quando a duracao do evento tambem e 0
- leitura publica usa `hourly` e `hours`, sem unitario

## Riscos ou bloqueios

- bloqueio de prova: o frontend em `localhost:8080` responde, a API nao
- risco ativo: publicar o POST sem o formulario do painel quebra a criacao de servico por hora

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum
- produto: uma frase em `product/02-business-rules.md#Proposal` e o complemento em `product/03-user-profiles.md#Cliente proponente`

## Veredito

- veredito: codigo do lote entregue em L2; nao marcar pronto para producao
- bloqueantes: browser do campo com a API ligada
- achados: a criacao publica e a do painel compartilham o mesmo POST
