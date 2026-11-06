# Links do painel e formularios de cadastro

## Identificacao

- nome da feature: Links do painel e formularios de cadastro
- slug: `links-painel-e-formularios`
- status: `T-01` a `T-03` escritas; falta o fluxo no browser
- origem: `.cursor/framework_core/task-requests/2026-11-05-links-painel-e-formularios/` (`tr-01`, `tr-02`, `tr-03`)
- owner: nao documentado

## Objetivo rapido

- problema que resolve: Regras copia localhost num campo; Nova regra e Nova caracteristica reabrem preenchidas; Link do evento abre uma pagina interna com o mesmo campo
- resultado esperado: um botao copia o link publico das regras na base de producao; os dois cadastros abrem vazios; o item da sidebar abre `/proposal/{id}/links` em outra aba

## Estado atual da feature

- fase atual: `T-01` a `T-03` escritas
- task em andamento: nenhuma
- proxima task recomendada: nenhuma; falta provar os tres gestos logado

## Observacoes

- restricoes: so `frontend`; sem rota, contrato ou env novo. A pagina publica das regras continua em `specs/2026-11-05-link-publico-regras-do-espaco/`
- riscos principais: limpar outros cadastros pelo `AnimatedFormSwitcher`; a aba nova abrir localhost
- fontes: o lote, `VenueRules.tsx`, `AnimatedFormSwitcher`, `ProposalNav.tsx`, `public-venue-rules.ts`, `event-link.ts`, `react/index.md`, `design/index.md` e `design/rules/06_forms_and_input_ux.md`
