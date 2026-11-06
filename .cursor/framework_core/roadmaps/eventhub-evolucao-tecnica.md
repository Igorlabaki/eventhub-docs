# Roadmap — Evolucao Tecnica do EventHub

## Identificacao

- produto: EventHub;
- status: descoberta;
- origem: codigo atual e backlog documental legado;
- regra: cada fase precisa virar plan, task-request ou spec antes de execucao.

## Visao

Evoluir o sistema existente com seguranca e compatibilidade, priorizando protecao e confiabilidade antes de escala ou reescrita.

## Fases

### Fase 1 — Seguranca e contratos basicos

- objetivo: fechar lacunas criticas de auth, refresh, CORS, erros e configuracao;
- entregas principais: allowlist de rotas publicas, autorizacao incremental, envs saneados e testes negativos;
- criterio de conclusao: fluxos criticos protegidos e regressao automatizada;
- status: descoberta.

### Fase 2 — Consistencia de dominio e dados

- objetivo: formalizar estados, dinheiro, datas e escritas atomicas;
- entregas principais: decisoes aprovadas, contratos atualizados e migrations seguras;
- criterio de conclusao: invariantes criticas cobertas por testes;
- status: nao iniciado.

### Fase 3 — Operabilidade e performance

- objetivo: tornar falhas visiveis e crescimento controlavel;
- entregas principais: logs estruturados, health, metricas, alertas, paginacao e indices medidos;
- criterio de conclusao: SLOs definidos e sinais operacionais utilizaveis;
- status: nao iniciado.

### Fase 4 — Qualidade de experiencia e entrega

- objetivo: consolidar frontend, design system e pipeline de qualidade;
- entregas principais: estrategia de estado, lazy loading, componentes canonicos, CI e e2e critico;
- criterio de conclusao: gates automatizados e jornadas principais cobertas;
- status: nao iniciado.

## Fora do roadmap

Reescrita total, microservicos por principio, app mobile, IA e Kubernetes nao estao justificados pelo estado atual.

## Rastreabilidade

- backlog: `topics/delivery-and-known-gaps.md`;
- legado: `docs/estado/integracao/TODO_MASTER.md` e `docs/planos/ROADMAP_TECHNICAL.md`;
- board: `BOARD.md`.

## Operacao

- tipo: roadmap;
- status: descoberta;
- fase atual: Fase 1 — Seguranca e contratos basicos;
- proximo passo: escolher uma iniciativa, confirmar prioridade e derivar plan ou spec;
- promovido para: nenhum artefato ainda.
