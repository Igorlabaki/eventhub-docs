# Segurança e endurecimento — EventHub

**Objetivo:** Threat model básico, lista priorizada de riscos reais encontrados no código, mitigações incrementais sem quebrar produção e plano de 2 sprints (BE-first, camada de compatibilidade).

**Fontes no repositório:** `art56_server_v3/src/server.ts`, `art56_server_v3/src/middleware/ensureAuthenticate.ts`, `art56_server_v3/src/router/*.ts`, `art56_server_v3/src/errors/error-handler.ts`, `eventhub-vista-dashboard/src/lib/axios.ts`, [BACKEND_ANALISE_ATUAL.md](./BACKEND_ANALISE_ATUAL.md), [INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md](./INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md), [AUTHORIZATION_MODEL.md](./AUTHORIZATION_MODEL.md).

---

## 1. Threat model básico (o que pode dar ruim)

| Ameaça | Cenário | Impacto |
|--------|---------|---------|
| Acesso não autorizado a dados | Rotas sem auth (image, document, payment, proposal byId, etc.) | Leitura/escrita de dados de outros usuários ou dados sensíveis |
| Roubo de token | XSS ou acesso físico; token em localStorage | Uso do token por atacante até expiração/refresh |
| Refresh quebrado | FE GET /auth/refresh sem body → falha → logout | Perda de sessão e má experiência |
| CORS permissivo | origin: "*" com credenciais (token no header) | Requisições de qualquer origem com token (risco em cenários de phishing) |
| DoS por payload | Body limit 50mb | Consumo de memória e CPU |
| Vazamento de informação em erro | 500 com error.toString() | Stack trace ou dados internos expostos |
| Falha silenciosa em async | Sem express-async-errors e middleware global de erro | Rejeições não convertidas em resposta JSON |
| Autorização fraca no BE | req.userId não setado; autorização por parâmetros do cliente | Acesso a recurso de outro usuário se passar outro userId/venueId |

---

## 2. Riscos reais priorizados (encontrados no código)

| Prioridade | Risco | Onde | Mitigação sugerida |
|------------|-------|------|--------------------|
| **P0** | Rotas sensíveis sem autenticação | image, document, payment, text, clause, contract, contact, notification, emailConfig, dateEvent, schedule, question, seasonalFee, proposal (create, byId, updatePersonalInfo), service list | Aplicar ensureAuthenticate por rota; exceção explícita só para rotas realmente públicas |
| **P0** | req.userId não definido após auth | ensureAuthenticate.ts (código que setava comentado) | Decodificar JWT e setar req.userId; tipar Request |
| **P0** | Refresh token FE/BE incompatível | FE: GET /auth/refresh sem body; BE: espera body.accessToken | FE usar POST /token/refresh com body { accessToken }; ou BE implementar GET /auth/refresh lendo token do header |
| **P1** | CORS origin: "*" | server.ts | Restringir origin a lista (env CORS_ORIGIN) |
| **P1** | Body limit 50mb | server.ts express.json/urlencoded | Reduzir para valor adequado (ex.: 10mb); uploads grandes via multipart com limite por campo |
| **P1** | Resposta 500 expõe detalhes | error-handler.ts (último return) | Em produção retornar mensagem genérica; logar erro completo só no servidor |
| **P1** | Sem middleware global de erro / express-async-errors | server.ts | Importar express-async-errors no topo; middleware (err, req, res, next) que chame handleErrors e responda JSON |
| **P2** | Token em localStorage | axios.ts, fluxo de login | Aceitar como trade-off atual; documentar risco XSS; mitigar com CSP e sanitização; futuro: considerar refresh em httpOnly cookie |
| **P2** | Sem rate limit | Aplicação inteira | Rate limit em /auth e /token (ex.: express-rate-limit) |
| **P2** | Duplicação express.json() e ordem do limit | server.ts linhas 42–45 | Um único express.json({ limit }) e um único urlencoded({ limit }) |

---

## 3. Mitigações incrementais (sem quebrar produção)

- **BE-first:** Todas as alterações de auth e rotas no backend primeiro; manter rotas antigas ou mesmo comportamento até o FE estar alinhado.
- **Compatibilidade:** Ao exigir token em rota que hoje é pública, garantir que o FE já envia o token nesse fluxo (e que usuários públicos tenham caminho alternativo documentado, ex.: proposal/create e byId podem permanecer sem auth por design).
- **Feature flag / rollout:** Não confirmado no repositório; opcionalmente variável de ambiente para ativar CORS restrito ou novo limite de body por fases.
- **Logs:** Ao setar req.userId, não logar token nem userId em produção em nível debug sem política clara.

---

## 4. Plano de 2 sprints

### Sprint 1 (BE-first, compatibilidade)

| Dia | Tarefa | Detalhe |
|-----|--------|---------|
| 1 | express-async-errors + middleware global de erro | Importar no topo de server.ts; middleware 4 params que chame handleErrors e responda JSON |
| 1 | 500 em produção não vazar detalhes | Em error-handler, se NODE_ENV=production retornar mensagem genérica; logar erro completo |
| 2 | Setar req.userId no ensureAuthenticate | Decodificar JWT (verify retorna payload); req.userId = decoded.id; tipar Request (userId?: string) |
| 2 | Um único express.json e urlencoded com limit | Remover duplicata; definir limit (ex.: 10mb) |
| 3 | CORS por variável de ambiente | origin: process.env.CORS_ORIGIN?.split(',') \|\| '*' ; documentar CORS_ORIGIN |
| 3 | .env.example no BE | Listar DATABASE_URL, JWT_SECRET_KEY, AWS_*, EMAIL_*, FIREBASE_*, VAPID_*, NODE_ENV |
| 4 | Aplicar ensureAuthenticate em image, document, payment | Por rota; testar fluxos de upload e listagem com token |
| 5 | Aplicar ensureAuthenticate em text, clause, contract, contact, emailConfig, notification, dateEvent, schedule, question, seasonalFee | Idem; exceção para rotas que precisem ser públicas (ex.: list para site público) |
| 5 | Documentar rotas públicas por design | Lista em README ou neste doc: proposal create/byId, venue getById/getWebData, organization getHubData/getOrganizationWebData, etc. |

### Sprint 2 (FE + BE alinhados)

| Dia | Tarefa | Detalhe |
|-----|--------|---------|
| 1 | FE: refresh com POST /token/refresh | No interceptor (401), POST com body { accessToken: localStorage.getItem('@EventHub:token') }; atualizar token da resposta |
| 1 | BE: manter GET /auth/refresh funcionando (opcional) | Se houver outros clientes, implementar GET que leia token do header Authorization e chame use case de refresh |
| 2 | FE: typo organizattionId → organizationId | Store e ProtectedRoute; manter contrato do service |
| 2 | FE: useGetVenuesList com { organizationId, userId } | Ajustar hook e chamada ao service |
| 3 | FE: centralizar rotas públicas | constants/publicRoutes.ts; usar em axios e useBootstrapUser |
| 3 | FE: .env.example | VITE_API_URL, VITE_GOOGLE_CLIENT_ID, etc. |
| 4 | Rate limit em /auth e /token | express-rate-limit por IP (ex.: 5 req/min para login/refresh) |
| 5 | Smoke test e revisão | Checklist [PRODUCTION_SETUP.md](./PRODUCTION_SETUP.md); revisar lista de rotas protegidas vs públicas |

---

## Decisões e recomendações

- Não remover autenticação de rotas já protegidas.
- Ao adicionar auth em rotas que hoje são públicas, comunicar e garantir que o FE envia token nesses fluxos antes do deploy do BE.
- Manter documento de “rotas públicas por design” atualizado para evitar que novas features quebrem formulários ou sites públicos.
