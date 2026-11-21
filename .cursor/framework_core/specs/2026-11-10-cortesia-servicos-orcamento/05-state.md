# State — Cortesia de servicos no orcamento

## Snapshot

- status: `T-01` a `T-07` implementadas em lote (2026-11-10); nao pronto para producao
- ultima task concluida: `T-07` (exibicao e docs)
- task em andamento: nenhuma
- proxima acao exata: review de entrega (`fw:review`); depois prova no browser e deploy da API antes do frontend
- prova mais recente: deploy request `#45` `complete_pending_revert`; `SHOW COLUMNS` na `main` mostra `courtesyQuantity int NOT NULL DEFAULT 0`; vitest backend 56 arquivos, 427 testes; vitest frontend 43 arquivos, 246 testes; `npm run build` do frontend ok; `prisma validate` ok

## Delta do lote

- `T-01`: `courtesyQuantity Int @default(0)` no schema, migration `20261110190000_add_proposal_service_courtesy`; branch `add-proposal-service-courtesy` com a coluna; deploy request `#45` aplicado na `main` com aprovacao nomeada
- `T-02`: `quoteServiceLines` com `courtesyByServiceId` e modos `strict`/`clamp`; `serviceCourtesyMap` e `hasCourtesy`
- `T-03`: `serviceCourtesy` nos schemas de criar, editar e cotar; `assertCourtesyAllowed` (401/403) antes de qualquer leitura ou escrita; repositorio grava a cortesia
- `T-04`: editar por pessoa e por dia autoriza pelo Venue gravado; cotacao leva a cortesia
- `T-05`: `GET`/`PUT` publico de servicos devolvem `courtesyQuantity` e `courtesyAmount`; `PUT` mantem a gravada com `min` nas horas; recalculo publico usa `clamp`
- `T-06`: campo de cortesia em `DashboardServiceChoices` (horas, pessoas ou checkbox); criar por pessoa, por dia e `ProposalEdit` enviam `serviceCourtesy`; cotacao estimada desconta
- `T-07`: detalhe do painel, "Seu investimento" e modal "Alterar servicos" mostram a cortesia; unitario por hora no link vem do `unitPrice` gravado; docs atualizados

## Lacunas de prova

- browser do painel e do link nao rodados no lote
- `tsc` do backend e do frontend tem erros antigos fora dos arquivos tocados

## Decisoes recentes

- editar autoriza a cortesia pelo `proposal.venueId` gravado, nunca pelo corpo
- sem authorizer injetado, cortesia > 0 falha fechado com 403
- `PUT` publico de servicos reduz a cortesia por hora com `min` inline em vez de passar `clamp` ao calculo
- `FIXED` grava cortesia 0 ou 1; no painel e um checkbox
- total manual e `BARTER` continuam vencendo; a cortesia so muda a linha

## Riscos ou bloqueios

- revert do `#45` so enquanto durar a janela `complete_pending_revert`; a API nova depende da coluna
- `proposal-in-prisma-repository.ts` e arquivos de relatorios tem mudancas nao commitadas de outra feature; commitar separado

## Memoria promovida

- topics atualizados: `topics/pricing-and-proposal-calculation.md#Servicos`
- product atualizados: `product/02-business-rules.md#Precificacao`, `product/08-data-model.md`
- project atualizados: `project/api-endpoints.md` (cortesia em servicos), `project/planetscale.md` (`#45`)
- project-decisions atualizados: nenhum (decisoes locais da feature)
- ADRs criados ou alterados: nenhum
