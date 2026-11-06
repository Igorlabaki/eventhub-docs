# State — Trocar a foto do link de orcamento

## Snapshot

- status: `T-01` a `T-03` escritas; coluna no main; falta a troca com o dono logado
- ultima task concluida: `T-03` no codigo; prova do dono pendente
- task em andamento: nenhuma
- proxima task exata: nenhuma; prova do dono no browser
- prova mais recente: vitest backend 27 e frontend 7; GET publico 200 com 7 fotos, `canReorder` falso e `catalog` vazio; visitante ve Ampliar e nao ve Trocar foto; carrossel abre; backfill atualizou 11 fotos

## Delta da ultima task

- mudou: coluna `isShowOnProposal`, filtro do link, `PUT .../image-choice` e botao Trocar foto
- ficou pendente: dono logado trocar uma foto e recarregar
- lacunas de prova: uma unica foto no catalogo e a falha de gravacao nao foram vistas no browser

## Decisoes recentes

- a coluna subiu pelo deploy request 37 em `ar756/main`
- o backfill copiou `isShowOnOrganization` verdadeiro; 11 linhas
- o catalogo publico continua vazio

## Riscos ou bloqueios

- sem sessao de dono nesta prova; o botao Trocar foto nao foi exercitado
- deploy request 37 ficou em `complete_pending_revert`

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo do lote pronto; nao marcar para producao enquanto o dono nao trocar uma foto no link
- bloqueantes: nenhum de codigo
- achados: a fila do deploy 37 esperou o fim da janela do deploy 36
