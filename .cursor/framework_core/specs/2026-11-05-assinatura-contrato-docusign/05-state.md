# State — Assinatura do contrato no DocuSign

## Snapshot

- status: codigo das tres tasks escrito; nao esta pronto para producao
- ultima task concluida: `T-03`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: vitest backend 16 (envio 10, webhook 6); vitest frontend 5 no estado do botao; `npx prisma validate` ok

## Delta da ultima task

- mudou: envio JWT, botao PF/PJ e webhook com HMAC, S3 e `contractSignedAt`
- ficou pendente: aplicar a migration no banco; Connect real; ensaio no browser
- lacunas de prova: o sandbox e a tela logada nao foram exercitados

## Decisoes recentes

- `docusignEnvelopeId` e `documentId` ficam colunas, sem relacao Prisma, para nao fechar ciclo no validate
- HMAC do DocuSign nao tem timestamp; a idempotencia e o `documentId`

## Riscos ou bloqueios

- a migration `20261105230000_add_docusign_envelope` esta no repo e nao foi aplicada
- `DOCUSIGN_CONNECT_SECRET` entrou so no `.env.example`; o Connect ainda nao existe
- sem a migration, a rota de envio quebra no banco

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote executado com prova unitaria; review de entrega nao rodou
- bloqueantes: migration no banco antes de usar a tela
- achados: nenhum no teste automatico
