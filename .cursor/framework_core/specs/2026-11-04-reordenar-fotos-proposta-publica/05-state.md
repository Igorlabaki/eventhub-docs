# State — Reordenar fotos da proposta publica

## Snapshot

- status: codigo de `T-01` a `T-03` escrito; nao esta pronto para producao
- ultima task concluida: `T-03`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest backend 14 testes e frontend 3 testes verdes; GET publico devolve id e `canReorder: false`; PUT sem token responde 401; visitante no browser nao ve alca e o clique abre o carrossel

## Delta da ultima task

- mudou: a pagina arrasta capa e galeria quando `canReorder` e verdadeiro e grava ao soltar
- ficou pendente: arraste com o dono logado no browser
- lacunas de prova: a sessao deste browser era de visitante; a troca real de posicao pelo dono nao foi exercitada na tela

## Decisoes recentes

- token ausente ou invalido no GET continua 200
- a gravacao e `PUT /proposal/presentation/:proposalId/image-order`
- foto oculta nao entra na escrita; a posicao 2 ocupada por ela foi pulada no teste
- nenhum topic, decisao ou ADR novo

## Riscos ou bloqueios

- o dono logado ainda nao arrastou na tela; o painel numerico continua como fallback

## Memoria promovida

- topics: nenhum
- project-decisions: nenhuma
- ADRs: nenhum

## Veredito

- veredito: codigo entregue, review nao rodou
- bloqueantes: nenhum de implementacao
- achados: falta provar o gesto do dono no browser
