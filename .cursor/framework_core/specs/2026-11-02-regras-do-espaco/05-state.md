# State — Regras do espaco

## Snapshot

- status: `T-01` a `T-04` implementadas; nao pronta para producao
- ultima task concluida: `T-04`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: `npx prisma validate`; `prisma migrate deploy` aplicou `venue_rule` e o backfill; Vitest `venue-rule.spec.ts` 4 testes; `npm run build` do frontend ok

## Delta da ultima task

- mudou: tabela, permissoes, API `/venue-rule` e tela `/venue/:id/rules`
- ficou pendente: criar, editar e remover uma regra no painel com o app aberto
- lacunas de prova: banco local de permissao estava vazio, entao o backfill nao teve linha real para conferir; fluxo do painel nao foi clicado

## Decisoes recentes

- autorizacao em `VenueRuleAuthorizer`, no venue da regra, sem `ensurePermission`
- backfill escolhe `userVenuePermission` ou `UserPermission`, a tabela que existir
- lista da API devolve `data` como array

## Riscos ou bloqueios

- operador sem permissao de servicos nao recebe regras no backfill
- `migrate dev` nao roda aqui: a shadow falha na migration antiga do Google Calendar

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum
- produto: `product/04-user-journeys.md` e `product/08-data-model.md`

## Veredito

- veredito: implementada, com prova automatica; painel ainda sem clique
- bloqueantes: nenhum
- achados: tabela viva de permissao neste MySQL e `userpermission`, nao o nome do `@@map`
