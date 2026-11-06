# Plano de observabilidade — EventHub

**Objetivo:** Logs estruturados (o que logar), métricas mínimas (requests, erros, latência, uploads), alertas e health check; onde instrumentar no código. Baseado no estado atual (console.log, sem lib estruturada, GET / como health).

**Fontes no repositório:** `art56_server_v3/src/server.ts`, `art56_server_v3/src/errors/error-handler.ts`, uso de console.log/console.error em controllers e use cases, [BACKEND_ANALISE_ATUAL.md](./BACKEND_ANALISE_ATUAL.md).

---

## 1. Logs estruturados

### O que logar

| Evento | Campos sugeridos | Onde |
|--------|-------------------|------|
| Request recebida | method, path, statusCode, durationMs, userId (se autenticado) | Middleware de request (após response) |
| Erro tratado | level: "error", message, code, path, statusCode, stack (apenas em não-produção ou em log interno) | error-handler (antes de responder) |
| Auth falhou | path, reason (token missing / invalid) | ensureAuthenticate ou error-handler |
| Upload concluído | resource (image/document/payment), id, durationMs | Controller de upload (opcional) |

**Formato:** JSON (ex.: `{"level":"info","msg":"request","method":"GET","path":"/venue/list","statusCode":200,"durationMs":45}`). Lib sugerida: pino (leve, JSON nativo).

### Onde instrumentar

- **Middleware de logging:** Após todas as rotas, antes do middleware de erro; em `res.on('finish', () => { ... })` registrar method, url, statusCode, duration.
- **error-handler.ts:** Ao formatar erro, chamar `logger.error({ err, path, statusCode })`; não incluir stack no body da resposta em produção.
- **ensureAuthenticate:** Ao rejeitar (401), logar path e motivo (token missing / invalid) em nível warn.

---

## 2. Métricas mínimas

| Métrica | Descrição | Onde coletar |
|---------|-----------|--------------|
| Requests por path e método | Contagem por (method, path) | Middleware |
| Status por path | Contagem por (path, statusCode) | Middleware ou error-handler |
| Latência | Histograma ou p95 por path | Middleware (tempo entre request e response) |
| Erros 5xx | Contagem global ou por path | error-handler |
| Uploads | Contagem ou tamanho por tipo (image/document/payment) | Controllers de upload |

**Ferramenta:** Não confirmada no repositório. Opções: Prometheus (métricas), exportação para Vercel Analytics ou provedor de APM; ou contadores simples em memória expostos em GET /metrics (apenas em ambiente com acesso restrito).

---

## 3. Alertas

- **Health check falhou:** GET / retorna não-200 ou timeout.
- **Taxa de 5xx acima de X%** (ex.: 5%) em janela de 5 min.
- **Latência p95 acima de Y ms** (ex.: 3000) para paths críticos (ex.: /auth/authenticate, /venue/list).
- **Falha de banco:** Prisma throw em health check (se implementado).

Canal de alerta (e-mail, Slack, PagerDuty) não confirmado no repositório; configurar conforme infra.

---

## 4. Health check

- **Atual:** GET `/` retorna "API online!" (text/plain). Suficiente para “processo vivo”.
- **Recomendação:** Manter GET `/`; opcionalmente GET `/health` com status 200 e body `{ "status": "ok", "db": "ok" }` após `prisma.$queryRaw` simples (ex.: `SELECT 1`). Em falha de DB, retornar 503 e `db: "error"`.
- **Uso:** Vercel ou load balancer podem usar GET `/` ou `/health` como health check.

---

## 5. Onde instrumentar no código (resumo)

| Arquivo / camada | Ação |
|------------------|------|
| server.ts | Registrar middleware de request logging (e opcionalmente de métricas) antes das rotas; middleware de erro no final que logue e responda. |
| errors/error-handler.ts | Chamar logger com nível e contexto; nunca vazar stack na resposta em produção. |
| middleware/ensureAuthenticate.ts | Logar falhas de auth (warn). |
| Controllers de upload (image, document, payment) | Opcional: log ou métrica de sucesso (tamanho, tipo, duration). |

---

## Decisões e recomendações

- Introduzir logger estruturado (pino) em uma única entrada (middleware + error-handler) para não poluir todos os use cases no primeiro passo.
- Métricas podem começar com contadores simples (requests, errors) em memória e endpoint GET /metrics; depois integrar com Prometheus ou provedor de nuvem.
- Health check com checagem de DB só adicionar quando houver necessidade de orquestração (ex.: Kubernetes) ou monitoramento de dependência.
