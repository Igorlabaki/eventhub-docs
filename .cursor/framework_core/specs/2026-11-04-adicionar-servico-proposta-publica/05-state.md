# State — Adicionar ou tirar servico no link publico

## Snapshot

- status: codigo das 3 tasks escrito; prova de browser bloqueada
- ultima task concluida: `T-03` no codigo; browser nao fechou
- task em andamento: nenhuma
- proxima task exata: nenhuma; falta o modal no browser com a API local saudavel
- prova mais recente: use case 8 testes e controller 6 testes verdes em `npx vitest run`

## Delta da ultima task

- mudou: use case, `GET`/`PUT .../services`, modal "Adicionar servico" e duas frases de produto
- ficou pendente: exercitar o modal no browser
- lacunas de prova: a pagina publica deste ambiente cai em 404 porque `getById` responde 500, coluna ausente no banco local

## Decisoes recentes

- o catalogo do modal inclui `minPeople` para o texto de obrigatorio, alem dos campos ja previstos
- o total continua pela diferenca das linhas; a locacao nao e recalculada

## Riscos ou bloqueios

- browser bloqueado pelo banco local, nao pela regra nova
- total antigo que nao contenha a soma dos servicos ainda se desloca junto

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum
- produto: `product/02-business-rules.md#Proposal` e `product/03-user-profiles.md#Cliente proponente`

## Veredito

- veredito: pronto para `fw:review` + `entrega`; nao esta pronto para producao
- bloqueantes: prova de browser no link publico
- achados: nenhum nos testes unitarios
