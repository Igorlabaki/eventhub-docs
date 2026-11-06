# State — Preco, foto e descricao do servico

## Snapshot

- status: `T-01` a `T-05` escritas; lote nao pronto para producao
- ultima task concluida: `T-05` no codigo
- task em andamento: nenhuma
- proxima task exata: nenhuma; falta provar a tela e aplicar o schema
- prova mais recente: vitest backend 27 testes verdes; rotulo frontend 4 testes verdes; Vite compilou os modulos alterados

## Delta da ultima task

- mudou: formula unica, snapshot em `ProposalService`, permissao e foto no cadastro, rotulo no painel e na pagina publica
- ficou pendente: gravar os tres tipos num orcamento real e abrir o link
- lacunas de prova: browser do painel parado no login; `main` recusou DDL direto

## Decisoes recentes

- hora do servico continua em `calcEventDuration`
- listagem `GET /service/list` segue publica
- migration `20261104210000_add_service_pricing` fica no repo e nao foi aplicada em `main`

## Riscos ou bloqueios

- bloqueio: `pscale connect ar756 main` desliga DDL direto; colunas novas ainda nao existem em `main`
- risco ativo: o client Prisma novo quebra leitura de `service` e `proposalService` ate o schema entrar

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: codigo do lote entregue em L2; nao marcar pronto para producao
- bloqueantes: schema no branch `main`; sessao do painel para criar os tres tipos
- achados: `prisma migrate deploy` parou em P3005; `prisma db execute` devolveu DDL direto desligado
