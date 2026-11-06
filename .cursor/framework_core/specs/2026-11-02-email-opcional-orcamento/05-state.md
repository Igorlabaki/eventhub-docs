# State — e-mail opcional na criacao do orcamento

## Snapshot

- status: codigo de `T-01` a `T-04` pronto; nao esta pronto para producao
- ultima task concluida: `T-04`
- task em andamento: nenhuma
- proxima task exata: nenhuma
- prova mais recente: `npx prisma validate`; vitest 7 testes do schema + 6 testes de update de orcamento; `tsc` do frontend sem erro novo

## Delta da ultima task

- mudou: coluna anulavel; painel grava `null`; link e os dois formularios internos exigem e-mail e a API grava
- ficou pendente: aplicar a migration no banco e provar as telas
- lacunas de prova: criar e editar no painel sem e-mail; links PF e PJ sem sessao, com e-mail valido e sem e-mail

## Decisoes recentes

- updates parciais de pagamento e aprovacao continuam sem enviar e-mail, para nao apagar o valor
- pedido publico do site permanece obrigatorio
- nenhum topic, decisao ou ADR

## Riscos ou bloqueios

- migration ainda nao foi aplicada no banco
- `T-04` so vale em producao junto com os quatro formularios

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: lote implementado, prova manual pendente
- bloqueantes: nenhum de codigo
- achados: `update` interno do orcamento precisa aceitar ausencia do campo para nao obrigar e-mail em pagamento e aprovacao
