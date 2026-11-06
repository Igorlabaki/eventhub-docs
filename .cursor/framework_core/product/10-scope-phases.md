# Scope and Phases — EventHub

## Escopo atual

Manter e evoluir o produto existente sem reescrever o historico. O sistema ja cobre organization, venue, proposal, contratos, agenda, pagamentos, pessoas, documentos, comunicacao, site e relatorios.

## Fase 1 — proteger e estabilizar

Alinhar auth/refresh, proteger rotas sensiveis, restringir CORS/configuracao, corrigir exposicao de erros e criar testes de regressao dos fluxos criticos.

## Fase 2 — contratos e consistencia

Formalizar API, estados de Proposal, dinheiro, timezone, transacoes e estrategia React Query/Zustand.

## Fase 3 — operabilidade e escala

Introduzir logging estruturado, correlation id, health/readiness, metricas, alertas, paginacao e processamento assincrono onde medicao justificar.

## Fase 4 — experiencia e evolucao

Consolidar design system, performance do frontend, automacao de testes/e2e e novas capacidades priorizadas pelo produto.

Cada iniciativa deve ser confirmada contra o estado atual e entrar por `fw:intake` ou `fw:spec`; este documento nao autoriza implementacao automatica.
