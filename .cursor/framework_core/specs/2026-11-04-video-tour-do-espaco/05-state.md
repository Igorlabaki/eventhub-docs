# State — Video do tour na proposta publica

## Snapshot

- status: `T-01`, `T-02` e `T-03` escritas; coluna `tourVideoUrl` no main de `ar756` (deploy request 36)
- ultima task concluida: `T-03` no codigo
- task em andamento: nenhuma
- proxima task exata: nenhuma; provar o save e o video na tela
- prova mais recente: schema e apresentacao 18 testes verdes; `prisma validate` ok; resolver 10 testes verdes. Tela nao exercitada

## Delta da ultima task

- mudou: coluna no schema, allowlist no update, campo nas configuracoes, player na proposta
- ficou pendente: save e video no browser
- lacunas de prova: login bloqueou Configuracoes; a coluna ja esta no main

## Decisoes recentes

- chave ausente no update nao zera `tourVideoUrl`; `""` e `null` gravam `null`
- API de dev reiniciada depois do generate, porque o processo antigo nao via o client novo

## Riscos ou bloqueios

- nenhum bloqueio de codigo; rollback da coluna e `DROP COLUMN tourVideoUrl` enquanto a janela de revert do deploy request 36 existir

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo do lote pronto; nao esta pronta para producao
- bloqueantes: nenhum
- achados: prova de tela ficou de fora
